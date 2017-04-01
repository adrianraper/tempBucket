<?php
/*
 * This is not really an AMFPHP service but its in this folder to maintain path integrity in all of the require_once calls.
 * Since there are no classes or methods here it does not represent a security risk.
 */

/*
 * The purpose of this script is to get data for an item analysis dashboard
 * It works its way through a menu.json.hbs file pulling out all files (which perhaps come from templates)
 * Then it reads each file to find each item and the associated root, answer and alternative options
 *
 * It can't work with hbs stuff in the menu, so you need to run a Notepad++ python script expand-menu-hbs.py
 * which will do a pre-process to list out full exercise nodes, then you save as expanded-menu.json
 *
 * http://dock.projectbench/Software/ResultsManager/web/amfphp/services/ItemAnalysisGateway.php?output=json&unitName=gauge
 */
//session_id($_GET['PHPSESSID']);

libxml_use_internal_errors(true);

require_once(dirname(__FILE__)."/ContentService.php");
require_once($GLOBALS['common_dir']."/simple_html_dom.php");

$thisService = new ContentService();

$outputStream = array();
$filter = '';
$timeStarted = new DateTime();
const MAX_EXECUTION_TIME = 3600;
ini_set('max_execution_time', MAX_EXECUTION_TIME);

// Account information will come in JSON format
function loadAPIInformation() {
	global $thisService;
	global $filter;
	global $unitName;

    $output = (isset($_GET['output'])) ? $_GET['output'] : "browser"; // or json, excel, text
    $filter = (isset($_GET['filter'])) ? $_GET['filter'] : ""; // or gauge, gauge1, a1, l1, later would be nice if could do regex: a1-e[0-9].html
    $unitName = (isset($_GET['unitName'])) ? $_GET['unitName'] : ""; // or Gauge, Track A etc
    // If you pass a unit name it will be used first so you may never match your filter

	//$inputData = file_get_contents("php://input");
	//$inputData = '{"method":"getRecordsForItemId","id":"11124987-ae36-4d18-a3c3-df935dbf4447","dbHost":2}';
	$inputData = '{"method":"processMenu","dbHost":3}';

	$postInformation= json_decode($inputData, true);
	if (!$postInformation) 
		throw new Exception('Error decoding data: '.': '.$inputData);

	// Have you sent any extra parameters from the url?
    $postInformation['output'] = $output;

	// First check mandatory fields exist
	if (!isset($postInformation['method'])) {
		throw new Exception("No method has been sent");
	}
	
	return $postInformation;
}	
function returnError($errCode, $data = null) {
	global $thisService;
	global $apiInformation;
	$apiReturnInfo = array('error'=>$errCode);
	switch ($errCode) {
		case 1:
			$apiReturnInfo['message'] = 'Exception, '.$data;
			break;
		default:
			$apiReturnInfo['message'] = 'Unknown error';
			break;
	}
	// Write out the error to the log (we probably don't know the orderRef, but if we do, include it)
	$logMessage = 'returnError '.$errCode.': '.$apiReturnInfo['message'];
	AbstractService::$debugLog->err($logMessage);

	$apiReturnInfo['dsn'] = $GLOBALS['db'];
	$apiReturnInfo['dbHost'] = $GLOBALS['dbHost'];

	$returnInfo = array_merge($apiReturnInfo);
	echo json_encode($returnInfo);
	exit(0);
}
function logit($message) {
    global $log;
    global $tab;
    global $newline;
    if ($log)
        echo $message."$newline";
}
function iagOutput($file, $qid, $qtype, $root, $context, $readingText, $tags, $attempts) {
    global $tab;
    global $newline;
    global $apiInformation;
    global $outputStream;
    global $outputFilename;
    switch ($apiInformation['output']) {
        case 'text':
        case 'excel':
        case 'export':
            $tagsString = (is_array($tags)) ? implode(',', $tags) : (string) $tags;
            $ia1 = (isset($attempts['attempted'])) ? $attempts['attempted'] : 0;
            $ia2 = (isset($attempts['correct'])) ? $attempts['correct'] : 0;
            $ia3 = (isset($attempts['distractors'])) ? json_encode($attempts['distractors']) : '';
            file_put_contents($outputFilename, $file . $tab . $qid . $tab . $qtype . $tab . $tagsString . $tab . $ia1 . $tab . $ia2 . $tab . $ia3. $tab . nlstripper($root) . $tab . nlstripper($context) . $tab . nlstripper($readingText) . "$newline", FILE_APPEND | LOCK_EX);
            break;
        case 'browser':
            $tagsString = (is_array($tags)) ? implode(',', $tags) : (string) $tags;
            $ia1 = (isset($attempts['attempted'])) ? $attempts['attempted'] : 0;
            $ia2 = (isset($attempts['correct'])) ? $attempts['correct'] : 0;
            $ia3 = (isset($attempts['distractors'])) ? json_encode($attempts['distractors']) : '';
            echo $file . $tab . $qid . $tab . $qtype . $tab . $tagsString . $tab . $ia1 . $tab . $ia2 . $tab . $ia3. $tab . nlstripper($root) . $tab . nlstripper($context) . $tab . nlstripper($readingText) . "$newline";
            break;
        case 'json':
            $outputStream[] = '{"file":"'
                .$file.
                '", "qid":"'
                .$qid.
                '", "qtype":"'
                .$qtype.
                '", "tags":'
                .json_encode($tags).
                ', "text":"'
                .nlstripper($readingText).
                '", "context":"'.
                nlstripper($context).
                '", "root":"'
                .nlstripper($root).
                '", "ia":'
                .json_encode($attempts).
                '}';
            break;
    }
}
function cloneAndPlain($node) {
    $newhtml = str_get_html($node);
    return $newhtml->plaintext;
}

function nlstripper($message) {
    return preg_replace('/[\s\r\n]+/', ' ', $message);
}
/*
 * Action for the script
 */
// Load the passed data
try {
	// Read and validate the data
	$apiInformation = loadAPIInformation();
	//AbstractService::$log->notice("calling validate=".$apiInformation->resellerID);
	//echo "loaded API";

    // Folder configuration
    $contentFolder = dirname(__FILE__).'/../../../../../../../Testbench';
    $titleFolder = $contentFolder.'/content-ppt';
    $outputFilename = $contentFolder.'/export.txt';
    //$outputFile = false;

	// You might want a different dbHost which you have now got - so override the settings from config.php
	if ($GLOBALS['dbHost'] != $apiInformation['dbHost'])
		$thisService->changeDB($apiInformation['dbHost']);

    switch ($apiInformation['output']) {
        case 'text':
            header('Content-Type: text/plain; charset=utf-8');
            $newline = "\n"; $tab = "\t";
            $log = false;
            break;
        case 'json':
            header('Content-Type: text/json; charset=utf-8');
            $newline = "\n"; $tab = "\t";
            $log = false;
            break;
        // Need to take full control of writing a file due to time issues
        case 'excel':
        case 'export':
            //header("Content-Type: text/csv; charset=utf-8");
            //header("Content-Disposition: attachment; filename=\"export.csv\"");
            header('Content-Type: text/plain; charset=utf-8');
            $newline = "\n"; $tab = "\t";
            $log = true;
            // Initialise the file
            //file_put_contents($outputFilename,"Hello");

            // Write a header record
            iagOutput('Filename','Item id','Q Type','Options','Context','Reading text','Tags',array('attempted' => 'Attempts','correct' =>'Correct','distractors' => 'Distractors'));
            break;
        case 'export':
            header('Content-Type: text/plain; charset=utf-8');
            $newline = "\n"; $tab = "\t";
            $log = false;
            break;
        default:
            header('Content-Type: text/html; charset=utf-8');
            $newline = "<br/>"; $tab = "&nbsp;&nbsp;&nbsp;&nbsp;";
            $log = true;
    }

    switch ($apiInformation['method']) {
		case 'getRecordsForItemId':
			$rc = $thisService->internalQueryOps->getScoreDetailsForItemId($apiInformation['id']);
			break;

		case 'processMenu':

            $menuFile = $titleFolder.'/expanded-menu.json';
            //$menuFile = $titleFolder.'/requirements/expanded-requirements.json';
            logit("processing $menuFile");
            	
            $menuContents = file_get_contents($menuFile);
            $menu = json_decode($menuContents);

            // For each node in the menu, get the unit and its exercises
            foreach ($menu->courses[0]->units as $unit) {

                logit("$newline"."unit ".$unit->caption);
                if ($unitName && stristr($unit->caption, $unitName) === false)
                    continue;

                // Then loop for all exercises in that unit node
                foreach ($unit->exercises as $exercise) {
                    // echo "exercise ".$exercise->progressBarCaption."$newline";
                    // Is this exercise a straight html (question bank) or a template?
                    if (stripos($exercise->href, '.hbs') !== false) {
                        readItemsFromTemplate($exercise->href);
                    } else {
                        readItemsFromExercise($exercise->href);
                    }

                    // Occasionally write out
                    //if ($outputFile && $iterations > 10) {
                    //    fclose($outputFile);
                    //    $outputFile = fopen($outputFilename, 'w');
                    //}
                }
            }
            //fclose($outputFile);
            break;
	}
	if ($apiInformation['output'] == 'excel')
	    logit("output to $outputFilename");

	if ($outputStream) {
        echo '{"data":['.implode(',',$outputStream).']}';
    }
	
	if (isset($rc['errCode']) && intval($rc['errCode']) > 0) {
		returnError($rc['errCode'], $rc['data']);
	}
	
	// Send back success variables
	//echo json_encode($rc);
	
} catch (Exception $e) {
	// Lets assume that we are generating plain text
	returnError(1, $e->getMessage());
}
flush();
exit(0);

// Read all questions banks from a template
function readItemsFromTemplate($file) {
    global $newline;
    global $tab;
    global $titleFolder;
    logit("template $file");
     
    $templateContents = file_get_contents($titleFolder.'/'.$file);
    $template = json_decode($templateContents);
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
            readItemsFromExercise($templateFolder.$matches[1][$i]);
        }    
}

// Read all items from a question bank
function readItemsFromExercise($file) {
    global $newline;
    global $tab;
    global $titleFolder;
    global $thisService;
    global $filter;
    global $timeStarted;

    $timeNow = new DateTime();
    $timeSpent = $timeNow->diff($timeStarted, true);
    if ($timeSpent->s > 3400) {
        $thisService->log->notice("You have spent too long=".$timeSpent->s);
        return;
    }

    set_time_limit(300); // allow 5 minutes per file

    // Debug - if you just want to check one or a pattern of files
    if ($filter!='' && stristr($file, $filter) === false) return;
    logit("file is $file");
    
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
            $attempts = $thisService->testOps->iaAttempts($qid);

            iagOutput($file, $qid, $qtype, $root, $context, $readingText, $tags, $attempts);
            if (isset($newhtml)) {
                $newhtml->clear();
                unset($newhtml);
            }
        }
    } else {
        logit("no items in this file");
    }
    $html->clear();
    unset($html);
}