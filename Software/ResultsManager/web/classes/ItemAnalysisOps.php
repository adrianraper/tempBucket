<?php
class ItemAnalysisOps {

	/**
	 * This class helps with item analysis.
	 *
     * Get data from the original database into a smaller one, then anaylsis it
	 */
	var $db;
	var $whiteList;
	
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

    // Add a whitelist of testIds that are considered valid
    //$whiteList = '(366,364,358,345,338,330,328,327,274,273,251,238,229,226,225,78,68,65,64,63,62,61,60,59,58,57,51,50,49,48,47,46,45,44,43)';
    //$whiteList = '(1021,1017,1011,1010,1008,1004,997,996,992,991,987,984,983,982,977,976,975,973,972,966,961,955,952,944,936,935,934,933,932,931,928,927,926,925,922,918,917,916,913,912,911,910,909,907,906,905,904,903,902,901,900,899,898,897,896,893,888,885,884,883,882,881,880,879,878,876,874,872,871,870,869,868,867,865,864,863,862,861,860,859,858,857,856,854,853,852,851,850,849,848,847,838,836,815,814,807,806,805,803,793,785,784,783,782,779,774,771,769,768,767,766,764,763,762,760,759,758,757,755,754,753,752,751,750,749,748,747,746,745,744,743,742,741,740,739,737,736,735,734,732,731,730,729,728,726,725,724,722,721,720,719,718,717,711,710,706,705,700,699,698,697,696,688,685,683,678,677,674,667,664,661,656,654,649,648,647,643,639,638,631,630,629,625,624,620,612,611,610,609,608,607,606,605,604,603,590,579,575,563,558,555,551,550,538,524,512,502,501,500,499,497,494,490,488,485,484,473,449,439,431,426,425,416,410,407,404,402,396,395,394,393,392,391,390,389,388,387,386,385,381,380,379,378,377,376,375,371,366,364,358,345,338,330,328,327,274,273,251,238,229,226,225,78,68,65,64,63,62,61,60,59,58,57,51,50,49,48,47,46,45,44,43)';
    //$whiteList = array(484, 638); // AsiaU TOEIC comparison tests
    public function setWhiteList($list) {
	    $this->whiteList = $list;
    }
    public function getWhiteList() {
	    if (!isset($this->whiteList))
	        throw new Exception("The white list must be set, even to []");
        return $this->whiteList;
    }

    public function getItemDetails($apiInformation, $titleFolder) {
	    $files = $this->getFilesFromMenu($apiInformation, $titleFolder);
	    foreach ($files as $file) {
            $this->readItemsFromExercise($file, $apiInformation, $titleFolder);
        }
    }
    public function distractorAnalysis($apiInformation, $titleFolder) {
        $files = $this->getFilesFromMenu($apiInformation, $titleFolder);
        $qids = [];
        foreach ($files as $file) {
            $qids = array_merge($qids, $this->readItemsFromFile($file, $apiInformation, $titleFolder));
        }
        $this->readDistractorsForItems($qids);
    }
    // Read all items that could possibly be in the test (based on files)
    // Read all results from valid tests, sort by user then item
    // For each user, retrieve their score for each of the list of items (if any) and output
    public function getCandidateAnswers($apiInformation, $titleFolder) {
        $files = $this->getFilesFromMenu($apiInformation, $titleFolder);
        $qids = [];
        foreach ($files as $file) {
            $qids = array_merge($qids, $this->readItemsFromFile($file, $apiInformation, $titleFolder));
        }
        $this->readDataForItems($qids);
    }
    public function checkContent($apiInformation, $titleFolder) {
        //$menuFile = $apiInformation['menuFile'];
        $files = $this->getFilesFromMenu($apiInformation, $titleFolder);
        foreach ($files as $file) {
            $this->checkContentFromExercise($file, $apiInformation, $titleFolder);
        }
    }

    public function makeNewItemId($apiInformation, $titleFolder) {
        $files = $this->getFilesFromMenu($apiInformation, $titleFolder);
        foreach ($files as $file) {
            $rc = $this->changeItemInExercise($file, $apiInformation, $titleFolder);
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
                // Is this exercise a straight html (question bank) or a template?
                if (stripos($exercise->href, '.hbs') !== false) {
                    $files = array_merge($files, $this->readItemsFromTemplate($exercise->href, $apiInformation, $titleFolder));
                } else {
                    // filter if not matching - use a regex or not, determined if first char is /
                    $filterPattern = $apiInformation['filter'];
                    if ($filterPattern != '') {
                        if (substr($filterPattern, 0, 1) == '/') {
                            if (preg_match($filterPattern, $exercise->href) != 1) {
                                continue;
                            }
                        } else {
                            if (stristr($exercise->href, $filterPattern) === false)
                                continue;
                        }
                    }
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
                // filter if not matching - use a regex or not, determined if first char is /
                $filterPattern = $apiInformation['filter'];
                if ($filterPattern != '') {
                    if (substr($filterPattern, 0, 1) == '/') {
                        if (preg_match($filterPattern, $templateFolder.$matches[1][$i]) != 1)
                            continue;
                    } else {
                        if (stristr($templateFolder.$matches[1][$i], $filterPattern) === false)
                            continue;
                    }
                }

                $files[] = $templateFolder.$matches[1][$i];
            }

        return $files;
    }

    public function changeItemInExercise($file, $apiInformation, $titleFolder) {
        $originalID = $apiInformation['id'];

        // Do a quick check if the text exists in the file
        $plainText = file_get_contents($titleFolder . '/' . $file);
        if (stristr($plainText, $originalID) === false)
            return false;

        $newID = $this->generateItemID();
        $newText = str_ireplace($originalID, $newID, $plainText, $count);
        if ($count == 1) {
            file_put_contents($titleFolder . '/' . $file, $newText);
            $this->writeChangeLog($file . ': change ' . $originalID . ' to ' . $newID);
        } else {
            $this->writeChangeLog($file . ': too many ' . $originalID . '=' . $count);
        }
        return true;
    }

    protected function generateItemID() {
	    return UUID::v4();
    }
    protected function writeChangeLog($msg) {
	    logit($msg);
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
                    echo "check content tags from $file";
                    foreach ($model->questions as $question) {
                        $root = $context = $readingText = '';
                        $attempts = $wrongPatterns = false;
                        $qid = $question->id;
                        $qtype = $question->questionType;
                        $tags = $question->tags;
                        iagOutput($file, $qid, $qtype, $root, $context, $readingText, $tags);
                    }
                    break;

                case "ids":
                    echo "check content ids from $file";
                    foreach ($model->questions as $question) {
                        $qid = $question->id;
                        $tags = $question->tags;
                        $tagsString = '['.(is_array($tags)) ? implode(',', $tags) : (string) $tags.']';
                        $otherFiles = $this->findDuplicateId($qid, $file, $apiInformation, $titleFolder);
                        if ($otherFiles != '') {
                            echo $qid . $tab . $file . '&nbsp;' . $tagsString . $tab . $otherFiles . "$newline";
                        } else {
                            echo $qid . "$newline";
                        }
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

    // Read full item details from a file
    // This includes an output of the details, nothing comes back from this function
    protected function readItemsFromExercise($file, $apiInformation, $titleFolder) {
        logit("read items from $file");

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
                // The order of .content and .header is not fixed
                //$reading = $html->find('.page-split .content', 0);
                $reading = $html->find('.page-split', 0);
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
                        $domQuestion = $html->find($qblock, 0);
                        $domNodes = $domQuestion->find('span[!class]'); // Note that the span could easily have a class... so this would not work
                        if (!$domNodes)
                            $domNodes = $domQuestion->find('span[class=dragzone]'); // But then this might pick up some of them
                        $domDraggle = $html->find($qsource, 0)->innertext;
                        foreach ($domNodes as $span) {
                            $span->find('span',0)->outertext = ' *'.$domDraggle.'*'.($span->find('span[class=space]') ? ' ' : '');
                            $root .= $span->innertext;
                        }

                        break;
                    case 'ReconstructionQuestion':
                        $domQuestion = $html->find($qblock, 0);
                        // Pick up the answers so you can reorder the sources
                        $roots = array();
                        foreach ($question->answers as $answer){
                            $source = $answer->source;
                            $roots[] = $domQuestion->find($source, 0)->innertext;
                        }
                        $root = implode(' | ', $roots);

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
                // You might skip this if you just want header information about the items, not the data
                //if ($apiInformation["method"] == "itemAnalysisWithData")
                //    $attempts = $this->iaAttempts($qid);

                iagOutput($file, $qid, $qtype, $root, $context, $readingText, $tags);
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

    // Get a list of all the items in a file
    // Returns an array of item ids
    protected function readItemsFromFile($file, $apiInformation, $titleFolder) {

	    $qids = [];
        $html = file_get_html($titleFolder . '/' . $file);
        $modelJson = $html->find('#model', 0)->innertext;
        if ($modelJson) {
            $model = json_decode($modelJson);

            // For each question in the model, pick the item id and save
            $qids = [];
            foreach ($model->questions as $question) {
                // Filter by tag if you want
                if (isset($apiInformation['tags'])) {
                    $tags = $apiInformation['tags'];
                    // If there are many tags, are they AND or OR
                    $andTags = explode('^', $tags); // You can't put & or + in the query line!
                    $orTags = explode(',', $tags);
                    if (count($andTags) > 1) {
                        // each andTag must exist
                        foreach ($andTags as $tag) {
                            if (!in_array($tag, $question->tags))
                                continue 2;
                        }
                        $qids[] = $question->id;
                    } else {
                        // any orTag must exist
                        foreach ($orTags as $tag) {
                            if (in_array($tag, $question->tags))
                                break;
                        }
                        $qids[] = $question->id;
                    }
                } else {
                    $qids[] = $question->id;
                }
            }
        }
        $html->clear();
        unset($html);
        return $qids;
    }
    protected function readDistractorsForItems($qids) {

        // First a header record
        distractorOutput('id', 'qType', 'cIdx', array('answers'));

	    foreach ($qids as $qid) {
            $distractors = $this->iaAttempts($qid);

            // Now we have an array of items, each with a count of the selected answers
            $answers = (isset($distractors['answers'])) ? $distractors['answers'] : [];
            $qtype = (isset($distractors['qtype'])) ? $distractors['qtype'] : '';
            $qcidx = (isset($distractors['correctIdx'])) ? $distractors['correctIdx'] : '';
            distractorOutput($qid, $qtype, $qcidx, $answers);
        }
    }

    protected function readDataForItems($qids) {

        // For each test-taker in the valid tests - this is a matrix of users and results
        $userRS = $this->getTestTakerResults();

        $records = [];
        if ($userRS) {
            $lastUid = 0; $record = [];
            while ($dbObj = $userRS->FetchNextObj()) {
                $uid = $dbObj->uid;
                $qid = $dbObj->qid;
                $score = $dbObj->score;
                $result = $dbObj->result;
                // If you are working on a new user, clear the stacks and write out the last one
                if ($lastUid != $uid) {
                    // Write out the previous record
                    if ($lastUid>0) {
                        $records[] = $record;
                    }
                    $lastUid = $uid;
                    $record = ["uid" => $uid, "result" => $result];
                }
                // For each item that they answered, if it is part of the test record the score
                if (in_array($qid, $qids)) {
                    $record[$qid] = $score;
                }
            }
            // And the final one...
            $records[] = $record;

        } else {
            AbstractService::$log->notice("no test takers, no results");
        }

        // Now we have an array of users, each with an array of the items and their score.
        // Need to format each line so that the items are in the right order and ones the user didn't see are included
        // First a header record
        testTakerOutput('item id', $qids, 'result');

        foreach ($records as $record) {
            $uid = $record["uid"];
            $result = $record["result"];
            $qidScores = [];
            foreach ($qids as $qid) {
                $qidScores[] = (isset($record[$qid])) ? $record[$qid] : '';
            }
            testTakerOutput($uid, $qidScores, $result);
        }
    }

    // Get all the data for test takers in the tests we are counting
    public function getTestTakerResults() {
	    $whiteList = '('.implode(',',$this->getWhiteList()).')';
	    // dpt#469 Read all records written even with null score as that is seen but not answered
        // if(F_Duration>3600,3600,F_Duration)
        $sql = <<<EOD
            select d.F_UserID as uid, d.F_ItemID as qid, if(d.F_Score is null,0,d.F_Score) as score, t.F_Result as result 
            FROM T_ScoreDetail d, T_TestSession t
            WHERE t.F_TestID in $whiteList
            AND t.F_SessionID = d.F_SessionID
            order by uid, qid;
EOD;
        $bindingParams = array();
        return $this->db->Execute($sql, $bindingParams);
    }

    // Count the number of times this item id has been attempted
    // dpt#487 Show the times each answer (correct plus distractors) has been chosen
    public function iaAttempts($itemId) {
        $whiteList = '('.implode(',',$this->getWhiteList()).')';

        // {"questionType":"DragQuestion","state":{..."current":[{"dropTargetIdx":2,"answerIdx":null}]},"tags":["A2","word-placement"]}
        // a score of -1 means it was attempted and got wrong - always true??
        $answerPatterns = array();
        $sql = <<<EOD
			SELECT *  
            FROM T_ScoreDetail d, T_TestSession t
            WHERE d.F_ItemID=?
            AND t.F_TestID in $whiteList
            AND t.F_SessionID = d.F_SessionID;
EOD;
        $bindingParams = array($itemId);
        $rs = $this->db->Execute($sql, $bindingParams);
        if ($rs) {
            // Handle cases where no-one answered this item
            if ($rs->RecordCount() == 0)
                return false;

            $specialSort = false;
            while ($dbObj = $rs->FetchNextObj()) {
                //$answers = array();
                $scoreDetail = new ScoreDetail();
                $scoreDetail->fromDatabaseObj($dbObj);
                $detail = json_decode($scoreDetail->detail);
                // If the item was skipped, we write a scoredetail record, but with no detail. For distractor analysis it is irrelevant.
                if (is_null($detail))
                    continue;
                $qtype = $detail->questionType;
                $rc['qtype'] = $qtype;
                $state = $detail->state;
                switch ($qtype) {
                    case 'MultipleChoiceQuestion':
                        // $state->selectedAnswerIdxs holds an array of the chosen answers, currently we only have questions with one
                        // $state->answerIdxToStringMap holds array showing answers
                        $selectedAnswer = $state->selectedAnswerIdxs[0];
                        if (isset($answerPatterns[$selectedAnswer])) {
                            $answerPatterns[$selectedAnswer]++;
                        } else {
                            $answerPatterns[$selectedAnswer] = 1;
                        }
                        // Note the correct index (only needs to be done once really)
                        if (intval($scoreDetail->score) > 0)
                            $rc['correctIdx'] = $selectedAnswer;
                        break;

                    case 'DropdownQuestion':
                        // $state->selectedAnswerIdx holds the chosen answer
                        // $state->answerIdxToStringMap holds array showing answers
                        $selectedAnswer = $state->selectedAnswerIdx;
                        if (isset($answerPatterns[$selectedAnswer])) {
                            $answerPatterns[$selectedAnswer]++;
                        } else {
                            $answerPatterns[$selectedAnswer] = 1;
                        }
                        // Note the correct index (only needs to be done once really)
                        if (intval($scoreDetail->score) > 0)
                            $rc['correctIdx'] = $selectedAnswer;
                        break;

                    case 'DragQuestion':
                        // $state->draggableIdx is the option you chose
                        // $state->draggableIdxToAnswerIdxMap holds array showing answers, 0 is the correct one
                        $answers = $state->draggableIdxToAnswerIdxMap;
                        for ($ix = 0; $ix < count($answers); $ix++) {
                            // Whilst this gets reset for every data point to the same thing, it is simplest just to keep it here for now
                            if (!is_null($answers[$ix]))
                                $rc['correctIdx'] = $ix;
                            // Add up how many times each answer was selected
                            if ($ix == $state->draggableIdx) {
                                if (isset($answerPatterns[$ix])) {
                                    $answerPatterns[$ix]++;
                                } else {
                                    $answerPatterns[$ix] = 1;
                                }
                            }
                        }
                        break;

                    case 'FreeDragQuestion':
                        // Word placement questions
                        // $state->current holds the answer you chose
                        // $state->initial holds nothing
                        // $state->dropTargetIdxToAnswerIdxMap holds array showing answers, 0 is the correct one
                        $answers = $state->dropTargetIdxToAnswerIdxMap;
                        for ($ix = 0; $ix < count($answers); $ix++) {
                            // Whilst this gets reset for every data point to the same thing, it is simplest just to keep it here for now
                            if (!is_null($answers[$ix]))
                                $rc['correctIdx'] = $ix;
                            // Add up how many times each answer was selected
                            if ($ix == $state->current) {
                                if (isset($answerPatterns[$ix])) {
                                    $answerPatterns[$ix]++;
                                } else {
                                    $answerPatterns[$ix] = 1;
                                }
                            }
                        }
                        break;

                    case 'ReconstructionQuestion':
                        // Text organisation and sentence reconstruction
                        // $state->current holds the answer pattern you made
                        // $state->initial holds original order of answers in the question
                        // $state->dropTargetIdxToAnswerIdxMap holds a meaningless array - as far as I can see

                        // The correct is always listed first, just as idx=0
                        if (intval($scoreDetail->score) > 0) {
                            $rc['correctIdx'] = 0;
                            if (isset($answerPatterns[0])) {
                                $answerPatterns[0]++;
                            } else {
                                $answerPatterns[0] = 1;
                            }
                        } else {
                            // What pattern did they make (wrongly)?
                            $patternString = implode(',', $state->current);
                            // And tally up the number who also wrongly did this same pattern
                            if (isset($answerPatterns[$patternString])) {
                                $answerPatterns[$patternString]++;
                            } else {
                                $answerPatterns[$patternString] = 1;
                            }
                        }
                        $specialSort = true;
                        break;
                    default:
                }

            }
            $sortedAnswers = array();
            if ($specialSort) {
                // TODO For now I don't know how to display the incorrect sequence. Perhaps it doesn't matter unless
                // there is an item that too many people get wrong in the same way. Then we can look at that item in detail.
                if (count($answerPatterns) > 1) {
                    $a2 = array_values(array_slice($answerPatterns,1));
                    arsort($a2);
                    $sortedAnswers = array_merge(array($answerPatterns[0]), array_slice($a2,0, 6));
                } else {
                    if (count($answerPatterns) > 0)
                        $sortedAnswers[0] = $answerPatterns[0];
                }
            } else {
                if (count($answerPatterns) >= 1) {
                    $maxKey = max(array_keys($answerPatterns));
                    for ($i = 0; $i <= $maxKey; $i++) {
                        $sortedAnswers[] = (isset($answerPatterns[$i])) ? $answerPatterns[$i] : 0;
                    }
                }
            }
            $rc['answers'] = $sortedAnswers;
        }

        return $rc;
    }

    // You can stop a test being picked up because of the account it is in, its own id, or if it ran before a certain date
    public function getTestsForWhiteList($blackListRoots, $blackListTests, $blackListDate) {
        $blackListRootsText = implode(',', $blackListRoots);
        if ($blackListDate) {
            $d = DateTime::createFromFormat('Y-m-d', $blackListDate);
            if ($d && $d->format('Y-m-d') == $blackListDate) {
                $blackListDateText = $d->format('Y-m-d');
            }
        }
        $sql = <<<EOD
            select t.F_TestID as testId from T_ScheduledTests t
              where exists
                (select 1 
                 from T_TestSession 
                 where F_TestID = t.F_TestID
                 and F_RootID not in ($blackListRootsText)
                )
EOD;
        if (isset($blackListDateText))
            $sql .= "and F_OpenTime > '$blackListDateText'";

        $sql .= <<<EOD
            order by F_TestID asc;
EOD;
        $bindingParams = array();
        $rs = $this->db->GetArray($sql, $bindingParams);
        if ($blackListTests != array())
            $rs = array_filter($rs, function($record) use ($blackListTests) {
                return !in_array($record['testId'], $blackListTests);
            });
        if (!$rs)
            return array();
        return array_map(function($record) {
            return $record['testId'];
        }, $rs);;
    }
}
