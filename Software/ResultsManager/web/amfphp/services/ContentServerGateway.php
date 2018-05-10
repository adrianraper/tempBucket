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

try {
    // Decode the body
    $json = json_decode(file_get_contents('php://input'));
    /*
    $json = json_decode('{"command":"getEncryptionKey","id":"68"}');
    $json = json_decode('{"command":"acquireLicenseSlots","tokens":["eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9kb2NrLnByb2plY3RiZW5jaCIsImlhdCI6MTUwNjU5MzcyOCwic2Vzc2lvbklkIjoiOCJ9.e62Njadljh2vAweWivqvv3CaWAU7wZx0IOz3qtaTJj8",
                                                                  "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9kb2NrLnByb2plY3RiZW5jaCIsImlhdCI6MTUwNjQ3MjY4Niwic2Vzc2lvbklkIjoiMzA2In0.qDdsEn0Lfb0e4HSyJaK1Mh6YC0hYN-hodh0eu-NY23Y"]}');
    $json = json_decode('{"command":"updateActivity","token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9kb2NrLnByb2plY3RiZW5jaCIsImlhdCI6MTUwNTkwMjA5Niwic2Vzc2lvbklkIjoiMjkxIn0.vyougpOHKi5ctolqh56e6f0fd5NEQp1rxtXCt3X9iNI","timestamp":'.$utcTimestamp.'}');
    $json = json_decode('{"command":"releaseLicenseSlot","token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9kb2NrLnByb2plY3RiZW5jaCIsImlhdCI6MTUwNDI0NTM3Mywic2Vzc2lvbklkIjoiMjQ1In0.t_IJ-xCH5m94ZZUR7oSKa4KIMyfuDXf4GnYL3_TXleA","timestamp":'.$utcTimestamp.'}');
    $json = json_decode('{"command":"dbCheck"}');
    $json = json_decode('{"command":"releaseLicenseSlots","slots":[{"token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9kb2NrLnByb2plY3RiZW5jaCIsImlhdCI6MTUwNDI0NTM3Mywic2Vzc2lvbklkIjoiMjQ1In0.t_IJ-xCH5m94ZZUR7oSKa4KIMyfuDXf4GnYL3_TXleA","timestamp":'.$utcTimestamp.'}]}');
    */
    if (!$json)
        throw new Exception("Empty request");

    //AbstractService::$debugLog->info("CSG-staging call ".json_encode($json));
    $jsonResult = router($json);

    // sss#256 put a success wrapper around the returning data. NO, not for content server (yet at least)
    //$jsonWrapped = array("success" => true, "details" => $jsonResult);
    // If you need to run this code but the content server is not implementing #256, include the next line
    $jsonWrapped = $jsonResult;
    //AbstractService::$debugLog->info("CSG return ".json_encode($jsonWrapped));
    if ($jsonResult == []) {
        echo json_encode($jsonWrapped, JSON_FORCE_OBJECT);
    // sss#461 Code return as a string with quotes
    } elseif ($json->command == "getEncryptionKey" && $jsonResult == intval($jsonResult)) {
        echo json_encode((string)$jsonWrapped);
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
    /*
     * If you need to record session ids for token debugging
     *
    $localDateTime = new DateTime();
    $localTimestamp = $localDateTime->format('Y-m-d H:i:s');
    if (isset($json->token))
        $sids = [$service->authenticationCops->getSessionId($json->token)];
    if (isset($json->tokens)) {
        // sss#361 Don't break if token is invalid
        $sids = array_map(function ($token) use ($service) {
            try {
                $sid = $service->authenticationCops->getSessionId($token);
            } catch (Exception $e) {
                $sid = null;
            };
            return $sid;
        }, $json->tokens);
    }
    if (isset($sids)) {
        //AbstractService::$controlLog->info("CSG " . $json->command . " for [" . implode(',', $sids) . "] at " . $localTimestamp);
    } else {
        //AbstractService::$controlLog->info("CSG call " . $json->command);
    }
    */
    switch ($json->command) {
        case "acquireLicenseSlots":
            return acquireLicenceSlots($json->tokens);
        case "releaseLicenseSlots":
            return releaseLicenceSlots($json->slots);
        case "releaseLicenseSlot":
            return releaseLicenceSlot($json->token, $json->timestamp);
        case "updateActivity":
            return updateActivity($json->token, $json->timestamp);
        case "getEncryptionKey":
            return getEncryptionKey($json->id);
        case "dbCheck":
            return dbCheck();
        default:
            throw new Exception("Unknown command");
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
// m#202
function releaseLicenceSlots($slots) {
    global $service;
    return $service->releaseLicenceSlots($slots);
}
function getEncryptionKey($testId) {
    global $service;
    // m#247 For tb/sss etc this is NOT a testId - it is a productCode+userId.
    // And we expect to just return null. Need to figure out how DPT inside Couloir will handle this call
    // For now just test to see the . and react with a null
    if (stristr($testId, '.') !== false)
        return null;
    return $service->testCops->getTestAccessCode($testId);
}
// Just for testing new gateways
function dbCheck() {
    global $service;
    return $service->dbCheck();
}
