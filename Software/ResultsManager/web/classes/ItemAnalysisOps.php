<?php
class ItemAnalysisOps {

	/**
	 * This class helps with item analysis.
	 *
     * Get data from the original database into a smaller one, then anaylsis it
	 */
	var $db;
	
	function ItemAnalysisOps($db) {
		$this->db = $db;
		$this->copyOps = new CopyOps();
        $this->manageableOps = new ManageableOps($db);
	}
	
	/**
	 * If you changed the db, you'll need to refresh it here
	 * Not a very neat function...
	 */
	function changeDB($db) {
		$this->db = $db;
	}

    public function itemAnalysis($apiInformation, $titleFolder) {
        $menuFile = $apiInformation['menuFile'];
	    $files = $this->getFilesFromMenu($menuFile, $apiInformation, $titleFolder);
	    foreach ($files as $file) {
            $this->readItemsFromExercise($file, $apiInformation, $titleFolder);
        }
    }
    public function checkContent($apiInformation, $titleFolder) {
        $menuFile = $apiInformation['menuFile'];
        $files = $this->getFilesFromMenu($apiInformation, $titleFolder);
        foreach ($files as $file) {
            $this->checkContentFromExercise($file, $apiInformation, $titleFolder);
        }
    }

    public function getFilesFromMenu($apiInformation, $titleFolder) {
        $menuFile = $apiInformation['menuFile'];
        $menuContents = file_get_contents($menuFile);
        $menu = json_decode($menuContents);
        $files = array();

        // For each node in the menu, get the unit and its exercises
        foreach ($menu->courses[0]->units as $unit) {

            //logit("$newline"."unit ".$unit->caption);
            if ($apiInformation['unitname'] != '' && stristr($unit->caption, $apiInformation['unitname']) === false)
                continue;

            // Then loop for all exercises in that unit node
            foreach ($unit->exercises as $exercise) {
                if ($apiInformation['filter'] != '' && stristr($exercise->href, $apiInformation['filter']) === false)
                    continue;

                // Is this exercise a straight html (question bank) or a template?
                if (stripos($exercise->href, '.hbs') !== false) {
                    $files = array_merge($files, $this->readItemsFromTemplate($exercise->href, $apiInformation, $titleFolder));
                } else {
                    //$this->readItemsFromExercise($exercise->href, $apiInformation, $titleFolder);
                    $files[] = $exercise->href;
                }
            }
        }
        return $files;

    }
    // Read all questions banks from a template
    protected function readItemsFromTemplate($file, $apiInformation, $titleFolder) {
        $files = array();

        $templateContents = file_get_contents($titleFolder.'/'.$file);
        //$template = json_decode($templateContents);
        //echo "starting id ".$menu->startingExerciseId."$newline";

        // Pick up any subfolder that the template is in as files in it are relative to it
        $folderPos = strrpos($file, '/');
        $templateFolder = ($folderPos === false) ? '' : substr($file, 0, $folderPos+1);

        // Pattern match to pick up the question banks referenced
        // (fromExercise source="../preliminary/gauge1.html" count=9)
        $pattern = '/fromExercise source="([a-zA-Z0-9.\/]+)"/i';
        if (preg_match_all($pattern, $templateContents, $matches))
            //echo "got matches=".count($matches[1])."$newline";
            for ($i=0; $i < count($matches[1]); $i++) {
                //$this->readItemsFromExercise($templateFolder.$matches[1][$i], $apiInformation, $titleFolder);
                $files[] = $templateFolder.$matches[1][$i];
            }

        return $files;
    }

    protected function checkContentFromExercise($file, $apiInformation, $titleFolder) {
        global $tab;
        global $newline;

        $html = file_get_html($titleFolder . '/' . $file);
        $modelJson = $html->find('#model', 0)->innertext;
        if ($modelJson) {
            $model = json_decode($modelJson);

            // For each question in the model, pick the item id and related information
            switch ($apiInformation["check"]) {
                case "tags":
                    logit("check content tags from $file");
                    foreach ($model->questions as $question) {
                        $root = $context = $readingText = '';
                        $attempts = $wrongPatterns = false;
                        $qid = $question->id;
                        $qtype = $question->questionType;
                        $tags = $question->tags;
                        iagOutput($file, $qid, $qtype, $root, $context, $readingText, $tags, $attempts);
                    }
                    break;

                case "ids":
                    logit("check content ids from $file");
                    foreach ($model->questions as $question) {
                        $qid = $question->id;
                        $tags = $question->tags;
                        $tagsString = '['.(is_array($tags)) ? implode(',', $tags) : (string) $tags.']';
                        $otherFiles = $this->findDuplicateId($qid, $file, $apiInformation, $titleFolder);
                        if ($otherFiles != '')
                            echo $qid . $tab . $file . '&nbsp;'. $tagsString . $tab . $otherFiles . "$newline";
                    }
                    break;

                default:
            }
        } else {
            AbstractService::$log->notice("no model in this file");
        }
        $html->clear();
        unset($html);
    }

    protected function findDuplicateId($id, $originalFile, $apiInformation, $titleFolder) {
        $originalFilter = $apiInformation['filter'];
        $originalUnit = $apiInformation['unitname'];
        $apiInformation['filter'] = '';
        $apiInformation['unitname'] = '';

        $files = $this->getFilesFromMenu($apiInformation, $titleFolder);
        //logit('check '.$id.' in '.count($files).' files');
        $otherFiles = array();
        foreach ($files as $file) {
            if ($file !== $originalFile)
                $tags = $this->fileHasId($id, $file, $apiInformation, $titleFolder);
                if ($tags)
                    $otherFiles[] = $file . '&nbsp;' . $tags;
        }
        $apiInformation['filter'] = $originalFilter;
        $apiInformation['unitname'] = $originalUnit;
        return (count($otherFiles) > 0) ? implode(', ', $otherFiles) : '';
    }

    protected function fileHasId($id, $file, $apiInformation, $titleFolder) {
        $html = file_get_html($titleFolder.'/'.$file);
        $modelJson = $html->find('#model',0)->innertext;
        if ($modelJson) {
            $model = json_decode($modelJson);
            foreach ($model->questions as $question) {
                $qid = $question->id;
                $tags = $question->tags;
                if ($qid == $id) {
                    unset($html);
                    return '['.(is_array($tags)) ? implode(',', $tags) : (string) $tags.']';
                }
            }
        }
        unset($html);
        return false;
    }

    // Read all items from a question bank
    protected function readItemsFromExercise($file, $apiInformation, $titleFolder) {
        logit("read items from $file");

        //$html = file_get_contents($titleFolder.'/'.$file);
        //$dom = new DOMDocument;
        //$dom->loadHTMLFile($titleFolder.'/'.$file, LIBXML_NOWARNING | LIBXML_NOERROR);
        //$modelJson = $dom->getElementByID('model');
        $html = file_get_html($titleFolder.'/'.$file);
        $modelJson = $html->find('#model',0)->innertext;
        if ($modelJson) {
            $model = json_decode($modelJson);

            // For each question in the model, pick the item id and related information
            // so we can format the items
            foreach ($model->questions as $question) {
                $root = $context = $readingText = '';
                $attempts = $wrongPatterns = false;
                $qid = $question->id;
                $qtype = $question->questionType;
                $qsource = (isset($question->source)) ? $question->source : null;
                $qblock = $question->block;
                $reorderable = (isset($question->reorderable)) ? $question->reorderable : false;
                $tags = $question->tags;
                $skill = false;
                foreach ($tags as $tag) {
                    switch ($tag) {
                        case "listening":
                        case "reading":
                        case "language-elements":
                            $skill = $tag;
                            break 2;
                    }
                }
                // Is there a reading text?
                $reading = $html->find('.page-split .content', 0);
                if ($reading) { // && $skill == 'reading')
                    // Build the header and first paragraph - is this enough to provide context?
                    $readingText = $reading->find('header', 0)->plaintext;
                    $readingText .= $reading->find('p', 0)->plaintext;
                }

                // Grab the item from the appropriate element in the dom
                switch ($qtype) {
                    case 'DropdownQuestion':
                        // Assume that ALL selectors are like ' > option:nth-child(x)' where x is 1 digit...
                        $answers = $question->answers;
                        foreach ($answers as $answer) {
                            $optionSelArray = explode(' > ', $answer->source);
                            if ($answer->correct) {
                                // convert something like #s1 > option:nth-child(1) to option then $e->children(1)
                                $qcorrect = intval(substr($optionSelArray[1], -2, 1)) - 1;
                            }
                        }

                        // What is the question text - the whole block
                        $domQuestion = $html->find($qblock, 0);

                        // TODO I can't figure out how to clone a node so that I can change it without impacting the original
                        // Similarly, once I change $e->outertext the $e->plaintext doesn't seem to update itself
                        // So I end up with making new nodes from saved strings a couple of times...
                        $newhtml = str_get_html($domQuestion->outertext);

                        // Replace any selects that are NOT this one with []
                        foreach ($newhtml->find('select') as $select)
                            $select->outertext = '*';

                        // TODO Setting the outertext doesn't really change the base element
                        // Replace the target select with a * - which you would think had to go before the first replace above
                        $newhtml->find($qsource, 0)->outertext = '[]';
                        $context = cloneAndPlain($newhtml);

                        // What are the options? Show in display order with correct one highlighted
                        $options = $domQuestion->find($qsource.' option');
                        $roots = array();
                        foreach ($answers as $answer) {
                            $optionSelArray = explode(' > ', $answer->source);
                            $qoption = intval(substr($optionSelArray[1], -2, 1)) - 1;
                            if ($answer->correct === true) {
                                $displayAnswer = '*' . trim($options[$qoption]->plaintext) . '*';
                            } else {
                                $displayAnswer = $options[$qoption]->plaintext;
                            }
                            $roots[] = $displayAnswer;
                        }


                        $root = implode(' | ', $roots);
                        break;

                    case 'MultipleChoiceQuestion':
                        // Find the question id - assume that all the answers come from the same question id
                        // Assume that there is only one correct answer...
                        // Assume that ALL selectors are like li:nth-child(x) where x is 1 digit...
                        $answers = $question->answers;
                        foreach ($answers as $answer) {
                            $optionSelArray = explode(' ', $answer->source);
                            if ($answer->correct) {
                                $qsource = $optionSelArray[0];
                                break;
                                // convert something like li:nth-child(1) to li then $e->children(1)
                                //$qcorrect = intval(substr($optionSelArray[1], -2, 1)) - 1;
                            }
                        }

                        // What is the question?
                        $domQuestion = $html->find($qsource, 0);
                        $context = trim($domQuestion->find('.questions-list-title', 0)->innertext);

                        // What are the options? Show in display order with correct one highlighted
                        $options = $domQuestion->find('.questions-list-answers li');
                        $roots = array();
                        foreach ($answers as $answer) {
                            $optionSelArray = explode(' ', $answer->source);
                            $qoption = intval(substr($optionSelArray[1], -2, 1)) - 1;
                            if ($answer->correct === true) {
                                $displayAnswer = '*' . trim($options[$qoption]->plaintext) . '*';
                            } else {
                                $displayAnswer = $options[$qoption]->plaintext;
                            }
                            $roots[] = $displayAnswer;
                        }

                        $root = implode(' | ', $roots);
                        break;

                    case 'FreeDragQuestion':
                        // First deal with sentence reconstruction
                        if ($reorderable) {
                            $domQuestion = $html->find($qblock, 0);
                            // Pick up the answers so you can reorder the sources
                            $roots = array();
                            foreach ($question->answers as $answer){
                                $source = $answer->source;
                                $roots[] = $domQuestion->find($source, 0)->innertext;
                            }
                            $root = implode(' | ', $roots);

                            // Then word placement
                        } else {
                            $domQuestion = $html->find($qblock, 0);
                            $domNodes = $domQuestion->find('span[!class]'); // Note that the span could easily have a class... so this would not work
                            if (!$domNodes)
                                $domNodes = $domQuestion->find('span[class=dragzone]'); // But then this might pick up some of them
                            $domDraggle = $html->find($qsource, 0)->innertext;
                            foreach ($domNodes as $span) {
                                $span->find('span',0)->outertext = ' *'.$domDraggle.'*'.($span->find('span[class=space]') ? ' ' : '');
                                $root .= $span->innertext;
                            }

                        }
                        break;

                    case 'DragQuestion':
                        // If this is a listening, see if we can reference the audio
                        // If the drags are images, then reference the filename, otherwise show text
                        // BUT you can't readily link the audio to a question though the id

                        $qcorrect = $question->answers[0]->source;
                        //$domQuestion = $html->find($qblock, 0);

                        // Find the question that contains this source id
                        // Grab the element with the id and go up until you find a parent that contains an audio
                        // If you find yourself at the block level, quit!
                        // If one question doesn't have audio, this traversal will eventually include all questions and the next audio will be found...
                        $audio = $rubric = '';
                        if ($skill == 'listening') {
                            $e = $html->find($qsource, 0);
                            while (!$e->find('audio') && '#'.$e->id!=$qblock)
                                $e = $e->parent;

                            if ($e) {
                                $audio = $e->find('audio', 0)->src;
                                $context = trim($e->find('.questions-list-title', 0)->innertext) . ' ' . $audio;
                            }
                        } elseif ($skill == 'reading') {
                            $e = $html->find($qsource, 0);
                            while ($e->class!='questions-list' && '#'.$e->id!=$qblock) {
                                $e = $e->parent;
                            }
                            if ($e) {
                                $context = trim($e->find('.questions-list-title', 0)->innertext);
                            }
                        } elseif ($skill == 'language-elements') {
                            // This looks VERY specific to a1-e3.html...
                            $rubricNode = $html->find($qsource, 0)->parent;
                            $rubricNode->find($qsource, 0)->outertext = '*';
                            $context = cloneAndPlain($rubricNode);
                        } else {
                            $rubricNode = $html->find($qsource, 0)->parent;
                            $rubricNode->find($qsource, 0)->outertext = '*';
                            $context = cloneAndPlain($rubricNode);
                        }

                        // What are the options? Show in display order with correct one highlighted
                        $e = $html->find($qcorrect, 0);
                        while (!$e->find('.draggables') && '#'.$e->id!=$qblock)
                            $e = $e->parent;

                        $roots = array();
                        $answers = $e->find('[draggable=true]');
                        foreach ($answers as $answer) {
                            // Draggables might be text or images
                            $thisAnswer = ($answer->find('img', 0)) ? $answer->find('img', 0)->src : trim($answer->plaintext);
                            if ('#'.$answer->id == $qcorrect) {
                                $displayAnswer = '*' . $thisAnswer . '*';
                            } else {
                                $displayAnswer = $thisAnswer;
                            }
                            $roots[] = $displayAnswer;
                        }

                        $root = implode(' | ', $roots);
                        break;
                    default:
                        $root = $skill;
                }
                // Query the database to get attempt information for item analysis
                $attempts = $this->iaAttempts($qid);

                iagOutput($file, $qid, $qtype, $root, $context, $readingText, $tags, $attempts);
                if (isset($newhtml)) {
                    $newhtml->clear();
                    unset($newhtml);
                }
            }
        } else {
            AbstractService::$log->notice("no items in this file");
        }
        $html->clear();
        unset($html);
    }

    // Count the number of times this item id has been attempted
    public function iaAttempts($itemId) {
        // We can't know the number of times the question has been presented and not attempted
        // as we don't write scoreDetails for such a case. Should we?
        // COUNT(*) presented,
        $sql = <<<EOD
			SELECT sum(CASE WHEN F_Score is not null THEN 1 ELSE 0 END) as attempts, 
			       sum(CASE WHEN F_Score > 0 THEN 1 ELSE 0 END) as correct  
			FROM T_ScoreDetail
			WHERE F_ItemID=?
EOD;
        $bindingParams = array($itemId);
        $rs = $this->db->Execute($sql, $bindingParams);
        if ($rs) {
            $dbObj = $rs->FetchNextObj();
            //$rc['presented'] = intval($dbObj->presented);
            $rc['attempted'] = ($dbObj->attempts) ? intval($dbObj->attempts) : 0;
            $rc['correct'] = ($dbObj->correct) ? intval($dbObj->correct) : 0;
        } else {
            //$rc['presented'] = 0;
            $rc['attempted'] = 0;
            $rc['correct'] = 0;
        }

        // Find the pattern for the top 3 errors
        // First word placement...
        // {"questionType":"FreeDragQuestion","state":{..."current":[{"dropTargetIdx":2,"answerIdx":null}]},"tags":["A2","word-placement"]}
        // a score of -1 means it was attempted and got wrong - always true??
        $wrongPatterns = array();
        $sql = <<<EOD
			SELECT *  
			FROM T_ScoreDetail
			WHERE F_ItemID=?
            AND F_Score = -1
EOD;
        $bindingParams = array($itemId);
        $rs = $this->db->Execute($sql, $bindingParams);
        if ($rs) {
            $wrongPatterns = array();
            while ($dbObj = $rs->FetchNextObj()) {
                $wrongs = array();
                $scoreDetail = new ScoreDetail();
                $scoreDetail->fromDatabaseObj($dbObj);
                $detail = json_decode($scoreDetail->detail);
                $qtype = $detail->questionType;
                $state = $detail->state;
                switch ($qtype) {
                    case 'MultipleChoiceQuestion':
                        if (isset($state[0]))
                            $wrongs[0] = $state[0];
                        break;
                    case 'DropdownQuestion':
                        $wrongs[0] = $state;
                        break;
                    case 'DragQuestion':
                        if (isset($state[0]->draggableIdx))
                            $wrongs[0] = $state[0]->draggableIdx;
                        break;
                    case 'FreeDragQuestion':
                        $current = $state->current;
                        foreach ($current as $answer) {
                            // This is for word placement
                            if (is_null($answer->answerIdx)) {
                                $wrongs[0] = $answer->dropTargetIdx;
                            } else {
                                // This is for any reorganisation
                                $wrongs[$answer->answerIdx] = $answer->dropTargetIdx;
                            }
                        }
                        break;
                    default:
                }
                $pattern = array();
                for ($i = 0; $i < count($wrongs); $i++) {
                    $pattern[] = $wrongs[$i] + 1; // Make it 1 based so easier to read
                }
                $wrongPatterns[] = implode(',', $pattern);
            }
        }
        if (count($wrongPatterns) > 0) {
            // Find unique values and count them
            $summary = array_count_values($wrongPatterns);
            arsort($summary);
            // But only worth reporting top (3?) results?
            array_splice($summary, 5);
            $rc['distractors'] = $summary;
        }

        return $rc;
    }

}
