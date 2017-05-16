﻿<?php
/*
 * This is not really an AMFPHP service but its in this folder to maintain path integrity in all of the require_once calls.
 * Since there are no classes or methods here it does not represent a security risk.
 */
require_once(dirname(__FILE__)."/../../../../BentoTitles/Tools/vo/com/clarityenglish/Utils/UUID.php");


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

    $output = (isset($_GET['output'])) ? $_GET['output'] : "export"; // or json, excel, text
    $filter = (isset($_GET['filter'])) ? $_GET['filter'] : "gauge1"; // a1-r1.html, gauge, gauge1, a1, l1, can do regex ONLY FROM FILE, not from browser parameters
    $unitname = (isset($_GET['unitname'])) ? $_GET['unitname'] : ""; // Gauge, Track A etc
    if ($unitname == "") $unitname = (isset($_GET['unitName'])) ? $_GET['unitName'] : ""; // old case style
    $method = (isset($_GET['method'])) ? $_GET['method'] : ""; // checkContentIntegrity etc
    $outputFilename = (isset($_GET['file'])) ? $_GET['file'] : "export-full-remote-test"; // export-gauge-Bahrain etc

	//$inputData = file_get_contents("php://input");
	//$inputData = '{"method":"getRecordsForItemId","id":"4386248d-db3e-4c11-ae4f-0e4194cbe067","dbHost":2}';
	//inputData = '{"method":"itemAnalysisWithData","dbHost":2}';
	//$inputData = '{"method":"itemAnalysis","dbHost":200}';
	$inputData = '{"method":"getCandidateAnswers","dbHost":200}';
    //$inputData = '{"method":"grabData", "targetHost":2, "sourceHost":3}';
    //$inputData = '{"method":"checkContentIntegrity", "check":"tags", "filter":"/a[12]+-l/", "dbHost":3}';
    //$inputData = '{"method":"makeNewItemId","dbHost":3}';

	$postInformation = json_decode($inputData, true);
	if (!$postInformation) 
		throw new Exception('Error decoding data: '.': '.$inputData);

	// Have you sent any extra parameters from the url?
    $postInformation['method'] = (isset($postInformation['method'])) ? $postInformation['method'] : $method;
    $postInformation['output'] = (isset($postInformation['output'])) ? $postInformation['output'] : $output;
    $postInformation['filter'] = (isset($postInformation['filter'])) ? $postInformation['filter'] : $filter;
    $postInformation['unitname'] = (isset($postInformation['unitname'])) ? $postInformation['unitname'] :  $unitname;
    $postInformation['$outputFilename'] = (isset($postInformation['$outputFilename'])) ? $postInformation['$outputFilename'] : $outputFilename;

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
function testTakerOutput($uid, $qidScore, $result) {
    global $tab;
    global $newline;
    global $apiInformation;
    global $outputStream;
    global $outputFilename;
    $builtLine = $uid . $tab . implode($tab, $qidScore) . $tab . $result;
    switch ($apiInformation['output']) {
        case 'text':
        case 'excel':
        case 'export':
            file_put_contents($outputFilename, $builtLine . "$newline", FILE_APPEND | LOCK_EX);
            break;
        case 'browser':
            echo $builtLine . "$newline";
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
    // If you haven't set a specific output name, make one up from the filters
    $specificName = (isset($apiInformation['$outputFilename'])) ? $apiInformation['$outputFilename'] : false;
    if (!$specificName) $specificName = 'export-'.(isset($apiInformation['unitname'])) ? $apiInformation['unitname'] : false;
    if (!$specificName) $specificName = 'export-'.(isset($apiInformation['filter'])) ? $apiInformation['filter'] : false;
    if (!$specificName) $specificName = 'export-'.date('jS-F-Y');
    $outputFilename = $contentFolder.'/'.$specificName.'.txt';
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

            // Write a header record (if not done by individual method)
            if ($apiInformation['method'] != 'getCandidateAnswers')
                iagOutput('Filename','Item id','Q Type','Options', 'Context','Reading text','Tags',array('attempted' => 'Attempts','correct' =>'Correct','distractors' => 'Distractors'));
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

        case 'makeNewItemId':
            $allIds = array();
            /*
            $allIds[] = array("id" => "7c5977fd-2ec7-4980-a60c-b78f9513e8f3", "filter" => "c1-");
            $allIds[] = array("id" => "f4ff2a08-c5fc-4337-a81e-ae52e31d689b", "filter" => "c1-");
            $allIds[] = array("id" => "4ae8bf7c-bf06-465f-9c43-75f25ba9a41b", "filter" => "c1-");
            $allIds[] = array("id" => "992efdc6-8fb5-42c7-93f3-9873f1dbda94", "filter" => "c1-");
            $allIds[] = array("id" => "0a9c282e-daf6-42e0-a570-6935de9a4d0e", "filter" => "c1-");
            $allIds[] = array("id" => "49afb3e0-35c7-4a51-bcfe-54d66cabe504", "filter" => "c1-");

            $allIds[] = array("id" => "a5eba467-ddef-4081-b941-bb1c61ac459e", "filter" => "b1-");
            $allIds[] = array("id" => "043b2908-5dcc-4d31-967d-1c5c50b4ec0b", "filter" => "b1-");
            $allIds[] = array("id" => "4d81a325-9fcb-4ef3-ad5c-68cb0ebba00a", "filter" => "b1-");
            $allIds[] = array("id" => "bf760459-f684-4327-8fe0-52228feb88e9", "filter" => "b1-");
            $allIds[] = array("id" => "97acc60e-db46-4741-abcc-2539d4b199b8", "filter" => "b1-");
            $allIds[] = array("id" => "900d37b4-11a6-4571-a5a5-1a8b554e5225", "filter" => "b1-");
            $allIds[] = array("id" => "58a24c6f-6939-4b9e-9bc3-1975bc3b852e", "filter" => "b1-");
            $allIds[] = array("id" => "9c9aed17-8530-4e00-acc7-cc106d747a35", "filter" => "b1-");

            $allIds[] = array("id" => "88cb1583-5428-4550-8600-561f677916d9", "filter" => "/[ab]+[12]+-[rl]+/");
            $allIds[] = array("id" => "360983f7-7c7d-4e5a-9bb7-470f358ec2ae", "filter" => "/[ab]+[12]+-[rl]+/");
            $allIds[] = array("id" => "cbfaa4e0-3565-41c1-87fd-516f43551000", "filter" => "/[ab]+[12]+-[rl]+/");
            $allIds[] = array("id" => "1256650a-eb2b-4cac-9a2c-062db5354496", "filter" => "/[ab]+[12]+-[rl]+/");
            $allIds[] = array("id" => "1dd8c056-389c-4f13-8de9-43a8550286bc", "filter" => "/[ab]+[12]+-[rl]+/");
            $allIds[] = array("id" => "f20e2e85-708d-4c73-bc0d-f25cbbe1b142", "filter" => "/[ab]+[12]+-[rl]+/");

            $allIds[] = array("id" => "5b412bfa-2388-4ef6-854e-67a7665ae3e9", "filter" => "a1-e1");
            $allIds[] = array("id" => "951ea413-5d8f-437a-b3aa-687155e0d8bd", "filter" => "a1-e1");
            $allIds[] = array("id" => "55b8a564-c53a-42d5-9cf3-ba8fc923b828", "filter" => "a1-e1");
            $allIds[] = array("id" => "86b03843-2cc1-4409-a0ae-f68fe6a0ea6b", "filter" => "a1-e1");
            $allIds[] = array("id" => "6a495251-c533-4606-a900-696abbc4b57e", "filter" => "a1-e1");

            $allIds[] = array("id" => "4c53990a-66c7-453b-84b4-b77d05f01318", "filter" => "a1-l");
            $allIds[] = array("id" => "e2fd79bf-7454-425e-8eee-a01232eaf75e", "filter" => "a1-l");
            $allIds[] = array("id" => "b406a350-bf45-4898-9eb2-3630e9dc3f21", "filter" => "a1-l");
            $allIds[] = array("id" => "48912b3f-8a43-4314-835a-acd08c832339", "filter" => "a1-l");
            $allIds[] = array("id" => "6075b26b-f5ee-42e8-a8b7-c211d3e19668", "filter" => "a1-l");
            $allIds[] = array("id" => "5c6a0fa0-3179-4c8e-904a-2b81769a4beb", "filter" => "a1-l");
            $allIds[] = array("id" => "7c39fd92-960f-4497-90c0-50ca02a7fb37", "filter" => "a1-l");
            $allIds[] = array("id" => "57dad688-abb6-43bb-a88f-5beaa0ef22de", "filter" => "a1-l");
            $allIds[] = array("id" => "244b338f-acf3-45c3-a7fc-e87063b3ff4c", "filter" => "a1-l");

            $allIds[] = array("id" => "9c91e56d-df3b-4e41-909d-406e8c17ce2f", "filter" => "b1-l2");
            $allIds[] = array("id" => "433492ed-6c19-4c87-a7e1-bdf4f08cb664", "filter" => "b1-l2");
            $allIds[] = array("id" => "1b9b22b4-6747-4a54-b902-f194da811c98", "filter" => "b1-l2");
            */

            foreach ($allIds as $thisId) {
                $apiInformation['id'] = $thisId['id'];
                $apiInformation['filter'] = $thisId['filter'];
                $rc = $thisService->itemAnalysisOps->makeNewItemId($apiInformation, $titleFolder);
            }
            break;

        case 'checkContentIntegrity';
            $rc = $thisService->itemAnalysisOps->checkContent($apiInformation, $titleFolder);
		    break;

        case 'getCandidateAnswers';
            $rc = $thisService->itemAnalysisOps->getCandidateAnswers($apiInformation, $titleFolder);
            break;

        case 'itemAnalysis':
		case 'itemAnalysisWithData':
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

