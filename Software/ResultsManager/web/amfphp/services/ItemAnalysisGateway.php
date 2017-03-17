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
 * which will do a pre-process to list out full exercise nodes.
 */
//session_id($_GET['PHPSESSID']);

libxml_use_internal_errors(true);

require_once(dirname(__FILE__)."/ContentService.php");
require_once($GLOBALS['common_dir']."/simple_html_dom.php");

$thisService = new ContentService();

ini_set('max_execution_time', 300); // 5 minutes
ini_set('set_time_limit', 300); // 5 minutes

// Account information will come in JSON format
function loadAPIInformation() {
	global $thisService;
	
	$inputData = file_get_contents("php://input");
	$inputData = '{"method":"getRecordsForItemId","id":"11124987-ae36-4d18-a3c3-df935dbf4447","dbHost":2}';
	$inputData = '{"method":"processMenu","dbHost":2,"output":"browser"}';
    $inputData = '{"method":"processMenu","dbHost":2,"output":"excel"}';
    //$inputData = '{"method":"processMenu","dbHost":2,"output":"json"}';

	$postInformation= json_decode($inputData, true);	
	if (!$postInformation) 
		throw new Exception('Error decoding data: '.': '.$inputData);
		
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
    global $newline;
    if ($log)
        echo $message."$newline";
}
function nlstripper($message) {
    return str_replace(array("\r", "\n"), ' ', $message);
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
	
	// You might want a different dbHost which you have now got - so override the settings from config.php
	if ($GLOBALS['dbHost'] != $apiInformation['dbHost'])
		$thisService->changeDB($apiInformation['dbHost']);

    switch ($apiInformation['output']) {
        case 'text':
            header('Content-Type: text/plain; charset=utf-8');
            $newline = "\n"; $tab = "\t";
            $log = true;
            break;
        case 'json':
            header('Content-Type: text/json; charset=utf-8');
            $newline = "\n"; $tab = "\t";
            $log = false;
            break;
        case 'excel':
            header("Content-Type: text/csv; charset=utf-8");
            header("Content-Disposition: attachment; filename=\"export.csv\"");
            $newline = "\n"; $tab = "\t";
            $log = false;
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
		    // Get the file
		    $contentFolder = dirname(__FILE__).'/../../../../../../../Testbench';
		    $titleFolder = $contentFolder.'/content-ppt';
		    $titleFolderOut = $contentFolder.'/results.txt';
		    
            $menuFile = $titleFolder.'/expanded-menu.json';
            logit("processing $menuFile");
            	
            $menuContents = file_get_contents($menuFile);
            $menu = json_decode($menuContents);

            // For each node in the menu, get the unit and its exercises
            foreach ($menu->courses[0]->units as $unit) {

                echo "$newline"."unit ".$unit->caption."$newline";
                // Then loop for all exercises in that unit node
                foreach ($unit->exercises as $exercise) {
                    // echo "exercise ".$exercise->progressBarCaption."$newline";
                    // Is this exercise a straight html (question bank) or a template?
                    if (stripos($exercise->href, '.hbs') !== false) {
                        readItemsFromTemplate($exercise->href);
                    } else {
                        readItemsFromExercise($exercise->href);
                    }
                }
            }
		    break;
	}
	$rc['data'] = 'done';
	
	if (isset($rc['errCode']) && intval($rc['errCode']) > 0) {
		returnError($rc['errCode'], $rc['data']);
	}
	
	// Send back success variables
	echo json_encode($rc);
	
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
    
    // Debug - if you just want to check one or a pattern of files
    //if (stristr($file, 'c1-e2') === false) return;
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
            $root = $context = '';
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
            $readingText = $html->find('.page-split .content', 0);
            if ($readingText)
                $context = $readingText->plaintext;
            
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
                    $context = $domQuestion;
                    // Replace any selects that are NOT this one with []
                    foreach ($context->find('select') as $select)
                        $select->outertext = '[]';

                    // TODO I don't understand why I do this AFTER the replace of all the selects! Surely it should be first...
                    // Replace this select with a *
                    $context->find($qsource, 0)->outertext = '*';

                    // What are the options? correct first
                    $options = $domQuestion->find($qsource.' option');
                    $roots = array();
                    $roots[] = $options[$qcorrect]->plaintext;

                    // Then the rest
                    foreach ($answers as $answer) {
                        $optionSelArray = explode(' > ', $answer->source);
                        if ($answer->correct === false) {
                            $qoption = intval(substr($optionSelArray[1], -2, 1)) - 1;
                            $roots[] = $options[$qoption]->plaintext;
                        }
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
                        //echo $answer->correct.$answer->source." $newline";
                        if ($answer->correct) {
                            $qsource = $optionSelArray[0];
                            // convert something like li:nth-child(1) to li then $e->children(1)
                            $qcorrect = intval(substr($optionSelArray[1], -2, 1)) - 1;
                        }
                    }
                    
                    // What is the question?
                    $domQuestion = $html->find($qsource, 0);
                    $rubric = trim($domQuestion->find('.questions-list-title', 0)->innertext);
                    
                    // What are the options? correct first
                    $options = $domQuestion->find('.questions-list-answers li');
                    $roots = array();
                    $roots[] = $options[$qcorrect]->plaintext;
                    
                    // Then the rest
                    foreach ($answers as $answer) {
                        $optionSelArray = explode(' ', $answer->source);
                        if ($answer->correct === false) {
                            $qoption = intval(substr($optionSelArray[1], -2, 1)) - 1;
                            $roots[] = $options[$qoption]->plaintext;
                        }
                    }
                    
                    $root = $rubric.' '.implode(' | ', $roots);;
                    break;
                    
                case 'FreeDragQuestion':
                    // First deal with sentence reconstruction
                    if ($reorderable) {
                        $domQuestion = $html->find($qblock, 0);
                        // Pick up the answers so you can reorder the sources
                        $roots = [];
                        foreach ($question->answers as $answer){
                            $source = $answer->source;
                            $roots[] = $domQuestion->find($source, 0)->innertext;
                        }
                        $root = implode(' | ', $roots);

                    // Then word placement
                    } else {
                        $domQuestion = $html->find($qblock, 0);
                        $domNodes = $domQuestion->find('span[!class]'); // Note that the span could easily have a class... so this would not work
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
                    
                    $answer = $question->answers[0]->source;
                    
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
                            $rubric = trim($e->find('.questions-list-title', 0)->innertext);
                        }
                    } elseif ($skill == 'reading') {
                        $e = $html->find($qsource, 0);
                        while ($e->class!='questions-list' && '#'.$e->id!=$qblock) {
                            $e = $e->parent;
                        }
                        if ($e) {
                            $rubric = trim($e->find('.questions-list-title', 0)->innertext);
                        }
                    } elseif ($skill == 'language-elements') {
                        $e = $html->find($qsource, 0);
                        // This looks VERY specific to a1-e3.html...
                        $rubricNode = $html->find($qsource, 0)->parent;
                        $rubricNode->find($qsource, 0)->outertext = '*';
                        $rubric = $rubricNode; // ->plaintext; // TODO Why can't I do ->plaintext and still see the *? It just disappears
                    }
                    
                    // Find the element that refers to the answer
                    $answerNode = $html->find($answer, 0);
                    if ($answerNode->find('img')) {
                        $correct = $answerNode->find('img', 0)->src;
                    } else {
                        $correct = $answerNode->innertext;
                    }
                    
                    // How to report it?
                    $root = $rubric.' '.$audio.' '.$correct;
                    break;
                default:
                    $root = $skill;
            }
            echo $file.$tab.$qid.$tab.$qtype.$tab.nlstripper($root).$tab.nlstripper($context)."$newline";
        }
    } else {
        logit("no items in this file");
    }
    $html->clear();
    unset($html);
}