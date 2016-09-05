<?php

header('Content-type: application/json');
if ($_SERVER['REQUEST_METHOD'] === "OPTIONS") return;

require_once(dirname(__FILE__)."/../core/shared/util/Authenticate.php");
require_once(dirname(__FILE__)."/CTPService.php");

class UserAccessException extends Exception {}

$service = new CTPService();
set_time_limit(360);

try {
    // Decode the body
    $json = json_decode(file_get_contents('php://input'));
    /*
    $json = json_decode('{"command":"login","email":"tracka@ppt","password":"eecea6bb1dd86ecb255f070b9b263f7c","productCode":63}');
    $json = json_decode('{"command":"scoreWrite",
                "score":{
                  "sessionID":"7",
                  "uid":"63.2015063020000.2015063020100.2015063020101",
                  "testID":"1",
                  "exerciseScore":{
                    "duration":373109,
                    "questionScores":[{"id":"d8bf84df-502f-4203-8c63-18549a183a1e","score":0}],
                    "exerciseMark":{"correctCount":0, "incorrectCount":0, "missedCount":1}
                  }
                },
                "localTimestamp":1473066576911,
                "timezoneOffset":-480}');
    */
    if (!$json)
        throw new Exception("Empty request");

    // Some data adjustment until the app and server are in sync with names etc
    //if (!isset($json->productCode)) $json->productCode = 63;
    if (!isset($json->sessionID) && isset($json->score)) $json->sessionID = $json->score->sessionID;

    echo json_encode(router($json));
} catch (UserAccessException $e) {
    header(':', false, 403);
    echo json_encode(array("error" => $e->getMessage(), "code" => $e->getCode()));
} catch (Exception $e) {
    header(':', false, 500);
    echo json_encode(array("error" => $e->getMessage(), "code" => $e->getCode()));
}

// Router
function router($json) {
    // Security
    if ($json->command !== "login") {
        $service = new CTPService(); // We need this in order to set the session name!
//        if (!Authenticate::isAuthenticated()) throw new UserAccessException("errorLostAuthentication");
    }
    
    switch ($json->command) {
        case "login": return login($json->email, $json->password, $json->productCode);
        case "getResult": return getResult($json->sessionID);
        case "scoreWrite": return scoreWrite($json->sessionID, $json->score, $json->localTimestamp, $json->timezoneOffset);
        default: throw new Exception("Unknown command");
    }
}

// In general, exceptions are thrown if something blocks login. Like an expired user or no licence slots.
function login($email, $password, $productCode) {
    global $service;
    return $service->testLogin($email, $password, $productCode);
}

function getResult($sessionId) {
    global $service;
    return $service->getResult($sessionId);
}

function scoreWrite($sessionId, $scoreObj, $localTimestamp, $clientTimezoneOffset=null) {
    global $service;
    $service->scoreWrite($sessionId, $scoreObj, $localTimestamp, $clientTimezoneOffset);
    return array("sessionID" => $sessionId);
}
