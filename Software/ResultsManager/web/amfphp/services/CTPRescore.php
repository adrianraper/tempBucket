<?php
/**
 * This file will rescore a test using the latest marking scheme
 * ?testID=xx&sessionID=xx&mode=overwrite
 *
 * or show you details for a test taker ?email=ferko@email
 */

header('Content-type: application/json');
if ($_SERVER['REQUEST_METHOD'] === "OPTIONS") return;

require_once(dirname(__FILE__)."/../core/shared/util/Authenticate.php");
require_once(dirname(__FILE__)."/CTPService.php");

$service = new CTPService();
set_time_limit(3600);
$requestedSessionID = (isset($_GET['sessionID'])) ? $_GET['sessionID'] : '';
$requestedTestID = (isset($_GET['testID'])) ? $_GET['testID'] : '';
$testTakerEmail = (isset($_GET['email'])) ? $_GET['email'] : '';

// If you want to really do a rescore and change the database, mode=overwrite
$mode = (isset($_GET['mode'])) ? $_GET['mode'] : 'debug';

if ($requestedSessionID == null && $requestedTestID == null && $testTakerEmail == null)
    throw new Exception("Parameter should be sessionID=xx, testID=xx or email=x@y.z");

try {
    $json = json_decode('{"command":"getTestResults","sessionID":"'.$requestedSessionID.'","testID":"'.$requestedTestID.'","email":"'.$testTakerEmail.'","mode":"'.$mode.'"}');

    if (!$json)
        throw new Exception("Empty request");

    echo json_encode(router($json));
    flush();
} catch (UserAccessException $e) {
    header(':', false, 403);
    echo json_encode(array("error" => $e->getMessage(), "code" => $e->getCode()));
} catch (Exception $e) {
    switch ($e->getCode()) {
        // ctp#75
        case 200:
        case 205:
        case 206:
        case 207:
        case 208:
        case 210:
        case 213:
        case 214:
        case 215:
            header(':', false, 401);
            break;
        default:
            header(':', false, 500);
    }
    echo json_encode(array("error" => $e->getMessage(), "code" => $e->getCode()));
}

function router($json) {

    // Conversion between general Couloir data and Bento formats
    // gh#1231
    if (isset($json->timezoneOffset)) {
        // Timezone has format {minutes:xx, negative:boolean} in Bento, but just xx in Couloir
        if (!isset($json->timezoneOffset->minutes))
            $json->timezoneOffset = json_decode('[{"minutes":'.abs($json->timezoneOffset).'},{"negative":'.($json->timezoneOffset < 0).'}]');
    }

    if (!isset($json->mode))
    	$json->mode = null;
    	
    switch ($json->command) {
        case "getTestResults": return getTestResults($json->sessionID, $json->email, $json->testID, $json->mode);
        case "getTranslations": return getTranslations($json->lang);
        default: throw new Exception("Unknown command");
    }
}

// Only for batch processing of results
function getTestResults($sessionID, $email, $testID, $mode = null) {
    global $service;
    $results = array();
    // Get all the sessions for people who completed this test
    foreach ($service->getSessionsForTest($sessionID, $email, $testID) as $session)
        $results[] = $service->getTestResult($session->sessionId, $mode);
    return $results;
}

// ctp#60
function getTranslations($lang) {
    global $service;
    return $service->getTranslations($lang);
}
