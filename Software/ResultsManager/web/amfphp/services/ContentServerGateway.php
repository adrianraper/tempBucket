<?php

/*
 * This is purely for backend calls coming from the ContentServer so will have it's own firewall
 */
header('Content-type: application/json');
if ($_SERVER['REQUEST_METHOD'] === "OPTIONS") return;

require_once(dirname(__FILE__)."/CouloirService.php");

// For setting the header when you want to send back an exception
function headerDateWithStatusCode($statusCode) {
    $utcDateTime = new DateTime();
    $utcTimestamp = $utcDateTime->format('U')*1000;
    header("Date: ".$utcTimestamp, false, $statusCode);
}
// sss#256
//class UserAccessException extends Exception {}

$service = new CouloirService();
set_time_limit(360);

// Just for testing
// Pick up the current time and convert as if it came from app (microseconds)
$utcDateTime = new DateTime();
$utcTimestamp = $utcDateTime->format('U')*1000;

// sss#257 Cope with old DPT content server calls
$oldTestId = filter_input(INPUT_GET, 'id', FILTER_SANITIZE_ENCODED);
if (isset($oldTestId))
    AbstractService::$debugLog->info("old SPS call for id=$oldTestId");

try {
    // Decode the body
    $json = json_decode(file_get_contents('php://input'));
    //$json = json_decode('{"command":"acquireLicenseSlots","tokens":["eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9kb2NrLnByb2plY3RiZW5jaCIsImlhdCI6MTUwNjU5MzcyOCwic2Vzc2lvbklkIjoiOCJ9.e62Njadljh2vAweWivqvv3CaWAU7wZx0IOz3qtaTJj8",
    //                                                              "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9kb2NrLnByb2plY3RiZW5jaCIsImlhdCI6MTUwNjQ3MjY4Niwic2Vzc2lvbklkIjoiMzA2In0.qDdsEn0Lfb0e4HSyJaK1Mh6YC0hYN-hodh0eu-NY23Y"]}');
    //$json = json_decode('{"command":"updateActivity","token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9kb2NrLnByb2plY3RiZW5jaCIsImlhdCI6MTUwNTkwMjA5Niwic2Vzc2lvbklkIjoiMjkxIn0.vyougpOHKi5ctolqh56e6f0fd5NEQp1rxtXCt3X9iNI","timestamp":'.$utcTimestamp.'}');
    //$json = json_decode('{"command":"releaseLicenseSlot","token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9kb2NrLnByb2plY3RiZW5jaCIsImlhdCI6MTUwNDI0NTM3Mywic2Vzc2lvbklkIjoiMjQ1In0.t_IJ-xCH5m94ZZUR7oSKa4KIMyfuDXf4GnYL3_TXleA","timestamp":'.$utcTimestamp.'}');
    /*
    $json = json_decode('{"command":"getEncryptionKey","id":298}');
    $json = json_decode('{"command":"dbCheck"}');
    */
    if (!$json)
        throw new Exception("Empty request");

    AbstractService::$debugLog->info("CSG-staging call ".json_encode($json));
    $jsonResult = router($json);

    AbstractService::$debugLog->info("CSG return ".json_encode($jsonResult));
    // sss#256 put a success wrapper around the returning data
    $jsonWrapped = array("success" => true, "details" => $jsonResult);
    // If you need to run this code but the app is not implementing #256, include the next line
    $jsonWrapped = $jsonResult;
    if ($jsonResult == []) {
        echo json_encode($jsonWrapped, JSON_FORCE_OBJECT);
    } else {
        echo json_encode($jsonWrapped);
    }

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
        // sss#256 These are the exceptions that are handled by the backend in some way
        // Send back http header 200, but with failure in the JSON
        //headerDateWithStatusCode(401);
        break;
        default:
            headerDateWithStatusCode(500);
    }
    echo json_encode(array("success" => false, "error" => array("message" => $e->getMessage(), "code" => (string) $e->getCode())));
}

// Note American spelling of license in these calls which is converted to British licence from here on in
function router($json) {
    global $service;
    $localDateTime = new DateTime();
    $localTimestamp = $localDateTime->format('Y-m-d H:i:s');
    // Debugging of session ids
    if (isset($json->token))
        $sids = [$service->authenticationCops->getSessionId($json->token)];
    if (isset($json->tokens)) {
        $sids = array_map(function($token) use ($service) {return $service->authenticationCops->getSessionId($token);}, $json->tokens);
    }

    if (isset($sids)) {
        AbstractService::$debugLog->info("CSG " . $json->command . " for [" . implode(',', $sids) . "] at " . $localTimestamp);
    } else {
        AbstractService::$debugLog->info("CSG call " . $json->command);
    }
    switch ($json->command) {
        case "acquireLicenseSlots": return acquireLicenceSlots($json->tokens);
        case "releaseLicenseSlot": return releaseLicenceSlot($json->token, $json->timestamp);
        case "updateActivity": return updateActivity($json->token, $json->timestamp);
        case "getEncryptionKey": return getEncryptionKey($json->id);
        case "dbCheck": return dbCheck();
        default: throw new Exception("Unknown command");
    }
}

// Take a token and a timestamp. This is evidence that at that local time, the app was active.
// Update the session, return success or failure
function updateActivity($token, $utcTimestamp) {
    global $service;
    return $service->updateActivity($token, $utcTimestamp);
}
// sss#61 Return an array of tokens that can get a licence
// Assume that this is only called by a licence server, not directly by an app
// Each token is something that holds a session id, in an authenticated format
function acquireLicenceSlots($tokens) {
    global $service;
    return $service->checkLicenceSlots($tokens);
}
// sss#171 This will be called by app signout too
function releaseLicenceSlot($token, $utcTimestamp) {
    global $service;
    return $service->releaseLicenceSlot($token, $utcTimestamp);
}
function getEncryptionKey($testId) {
    global $service;
    return $service->testOps->getTestAccessCode($testId);
}
// Just for testing new gateways
function dbCheck() {
    global $service;
    return $service->dbCheck();
}
