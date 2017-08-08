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
 * http://dock.projectbench/Software/ResultsManager/web/amfphp/services/ItemAnalysisGateway.php?output=json&unitname=gauge
 */
//session_id($_GET['PHPSESSID']);

libxml_use_internal_errors(true);

require_once(dirname(__FILE__)."/ContentService.php");
require_once($GLOBALS['common_dir']."/simple_html_dom.php");

$thisService = new ContentService();

$outputStream = array();
//$filter = '';
//$timeStarted = new DateTime();
const MAX_EXECUTION_TIME = 3600;
ini_set('max_execution_time', MAX_EXECUTION_TIME);
set_time_limit(MAX_EXECUTION_TIME);

// Account information will come in JSON format
function loadAPIInformation() {
	global $thisService;

    $output = (isset($_GET['output'])) ? $_GET['output'] : "browser"; // or json, excel, text
    $filter = (isset($_GET['filter'])) ? $_GET['filter'] : ""; // a1-r1.html, gauge, gauge1, a1, l1, later would be nice if could do regex: a1-e[0-9].html
    $unitname = (isset($_GET['unitname'])) ? $_GET['unitname'] : ""; // Gauge, Track A etc
    $method = (isset($_GET['method'])) ? $_GET['method'] : ""; // checkContentIntegrity etc

	//$inputData = file_get_contents("php://input");
	//$inputData = '{"method":"getRecordsForItemId","id":"11124987-ae36-4d18-a3c3-df935dbf4447","dbHost":2}';
	//$inputData = '{"method":"itemAnalysis","dbHost":3}';
    //$inputData = '{"method":"grabData", "targetHost":2, "sourceHost":3}';
    $inputData = '{"method":"checkContentIntegrity", "check":"ids", "dbHost":3}';

	$postInformation = json_decode($inputData, true);
	if (!$postInformation) 
		throw new Exception('Error decoding data: '.': '.$inputData);

	// Have you sent any extra parameters from the url?
    $postInformation['method'] = (isset($postInformation['method'])) ? $postInformation['method'] : $method;
    $postInformation['output'] = (isset($postInformation['output'])) ? $postInformation['output'] : $output;
    $postInformation['filter'] = (isset($postInformation['filter'])) ? $postInformation['filter'] : $filter;
    $postInformation['unitname'] = (isset($postInformation['unitname'])) ? $postInformation['unitname'] :  $unitname;

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
    AbstractService::$log->notice($message);
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
    $apiInformation['menuFile'] = $titleFolder.'/expanded-menu.json';
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
            iagOutput('Filename','Item id','Q Type','Options', 'Context','Reading text','Tags',array('attempted' => 'Attempts','correct' =>'Correct','distractors' => 'Distractors'));
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

        case 'checkContentIntegrity';
            $rc = $thisService->itemAnalysisOps->checkContent($apiInformation, $titleFolder);
		    break;

		case 'itemAnalysis':
            AbstractService::$log->notice("processing $menuFile");
            $rc = $thisService->itemAnalysisOps->itemAnalysis($apiInformation, $titleFolder);
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

