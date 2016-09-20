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
    $json = json_decode('{"command":"getTestResult","sessionID":"47"}');
    /*
    $json = json_decode('{"command": "scoreWrite",
            "score": {
                "sessionID": "47",
                "uid": "63.20160630.201606301.20160630001",
                "testID": "2",
                "exerciseScore": {
                    "questionScores": [{
                        "id": "2561567001aa49dca9c9ced953794418",
                        "questionType": "MultipleChoiceQuestion",
                        "state": [0],
                        "score": -1,
                        "answerTimestamp": 1474277220933,
                        "tags": [],
                        "group": null
                    },
                    {
                        "id": "d8bf84df-502f-4203-8c63-18549a183a1e",
                        "questionType": "FreeDragQuestion",
                        "state": {
                            "dropTargetIdx": 19,
                            "answerIdx": null
                        },
                        "score": null,
                        "answerTimestamp": 1474277224187,
                        "tags": [],
                        "group": null
                    },
                    {
                        "id": "d1258b72785c4709b683019c553ae8da",
                        "questionType": "DropdownQuestion",
                        "state": 0,
                        "score": 1,
                        "answerTimestamp": 1474277227839,
                        "tags": [],
                        "group": null
                    },
                    {
                        "id": "52d3c75c18194d15837e5d73bbab7487",
                        "questionType": "DragQuestion",
                        "state": [{
                            "draggableIdx": 1,
                            "answerIdx": 0
                        }],
                        "score": 1,
                        "answerTimestamp": 1474277232599,
                        "tags": [],
                        "group": null
                    }],
                    "exerciseMark": {
                        "correctCount": 2,
                        "incorrectCount": 1,
                        "missedCount": 1
                    },
                    "duration": 155632,
                    "submitTimestamp": 1474277235232
                }
            },
            "localTimestamp": ' . time()*1000 . ',
            "timezoneOffset": -480
        }');
    $json = json_decode('{"command":"login","email":"tracka@ppt","password":"eecea6bb1dd86ecb255f070b9b263f7c","productCode":63}');
    */
    if (!$json)
        throw new Exception("Empty request");

    // Some data adjustment until the app and server are in sync with names etc
    //if (!isset($json->productCode)) $json->productCode = 63;
    //if (!isset($json->sessionID) && isset($json->score)) $json->sessionID = $json->score->sessionID;

    echo json_encode(router($json));
} catch (UserAccessException $e) {
    header(':', false, 403);
    echo json_encode(array("error" => $e->getMessage(), "code" => $e->getCode()));
} catch (Exception $e) {
    switch ($e->getCode()) {
        // ctp#75
        case 200:
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

// Router
function router($json) {
    // Security
    if ($json->command !== "login") {
        $service = new CTPService(); // We need this in order to set the session name!
//        if (!Authenticate::isAuthenticated()) throw new UserAccessException("errorLostAuthentication");
    }
    
    switch ($json->command) {
        case "login": return login($json->email, $json->password, $json->productCode);
        case "getTestResult": return getResult($json->sessionID);
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
    return $service->getTestResult($sessionId);
}

function scoreWrite($sessionId, $scoreObj, $localTimestamp, $clientTimezoneOffset=null) {
    global $service;
    $service->scoreWrite($sessionId, $scoreObj, $localTimestamp, $clientTimezoneOffset);
    return array("sessionID" => $sessionId);
}
