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
    $json = json_decode('{"command":"login","email":"beast@dpt","password":"2921e2c5e0d89ed8ff95179a38f009e0","productCode":63}');
    $json = json_decode('{"command":"getTestResult","sessionID":"132","mode":"overwrite"}');
    $json = json_decode('{"command":"getTranslations","lang":"EN"}');
    $json = json_decode('{"command":"login","email":"asra@hct","password":"c15521c9a6e45e0192345f66a34bd634","productCode":63}');
    $json = json_decode('{"command": "login","email": "","password": "d41d8cd98f00b204e9800998ecf8427e","productCode": "63"}');
    */
    /*
    $json = json_decode('{"command":"scoreWrite",
            "sessionID": "6",
            "score": {
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
            "localTimestamp": 1480039838000, 
            "timezoneOffset": -480
        }');
     *  // . time()*1000 . ',
    */
    //1475543370002 - timestamp for 4th Oct about 9:04am
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
// Security not provided by php session anymore
//    if ($json->command !== "login") {
//        $service = new CTPService(); // We need this in order to set the session name!
//        if (!Authenticate::isAuthenticated()) throw new UserAccessException("errorLostAuthentication");
//    }

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
        case "login": return login($json->email, $json->password, $json->productCode);
        case "getTestResult": return getResult($json->sessionID, $json->mode);
        case "scoreWrite": return scoreWrite($json->sessionID, $json->score, $json->localTimestamp, $json->timezoneOffset);
        case "getTranslations": return getTranslations($json->lang);
        default: throw new Exception("Unknown command");
    }
}

// In general, exceptions are thrown if something blocks login. Like an expired user or no licence slots.
function login($email, $password, $productCode) {
    global $service;
    return $service->testLogin($email, $password, $productCode);
}

function getResult($sessionId, $mode = null) {
    global $service;
    return $service->getTestResult($sessionId, $mode);
}

function scoreWrite($sessionId, $scoreObj, $localTimestamp, $clientTimezoneOffset=null) {
    global $service;
    $rc = $service->scoreWrite($sessionId, $scoreObj, $localTimestamp, $clientTimezoneOffset);
    // ctp#166
    if ($rc["success"]===false) {
        return array("sessionID" => $sessionId, "error" => $rc["error"]);
    } else {
        return array("sessionID" => $sessionId);
    }
}
// ctp#60
function getTranslations($lang) {
    global $service;
    return $service->getTranslations($lang);
}
