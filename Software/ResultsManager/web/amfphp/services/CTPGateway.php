<?php

header('Content-type: application/json');
if ($_SERVER['REQUEST_METHOD'] === "OPTIONS") return;

require_once(dirname(__FILE__)."/../core/shared/util/Authenticate.php");
require_once(dirname(__FILE__)."/CTPService.php");
// For setting the header when you want to send back an exception
function headerDateWithStatusCode($statusCode) {
    $utcDateTime = new DateTime();
    $utcTimestamp = $utcDateTime->format('U')*1000;
    header("Date: ".$utcTimestamp, false, $statusCode);
}
class UserAccessException extends Exception {}

$service = new CTPService();
set_time_limit(360);

try {
    // Decode the body
    $json = json_decode(file_get_contents('php://input'));
    /*
    $json = json_decode('{"command":"getTranslations","lang":"zh-tw"}');
    $json = json_decode('{"command":"login","email":"dandy@dpt","password":"2e93f6f5de7b09f1987ae0b9e5b3f383","productCode":63,"platform":"Chrome 58.0.3029.110 on Windows 10 64-bit","appVersion":"0.6.1"}');
    $json = json_decode('{"command":"getTestResult","appVersion":"0.7.4","testID":"49","sessionID":"177","mode":"overwrite"}');
    $json = json_decode('{"command":"login","email":"dandy@dpt","password":"2e93f6f5de7b09f1987ae0b9e5b3f383","productCode":63,"appVersion":"0.6.1"}');
    $json = json_decode('{"command":"getTestResult","appVersion":"0.7.4","testID":"35","sessionID":"166","mode":"overwrite"}');
    $json = json_decode('{"command":"login","email":"asra@hct","password":"c15521c9a6e45e0192345f66a34bd634","productCode":63}');
    $json = json_decode('{"command": "login","email": "","password": "d41d8cd98f00b204e9800998ecf8427e","productCode": "63"}');
    */
    /*
    $json = json_decode('{"command": "scoreWrite",
            "appVersion": "0.6.3",
            "score": {
                "uid": "63.2016063999.20166301999.2016063990",
                "testID": "27",
                "exerciseScore": {
                    "questionScores": [{
                        "id": "11124987-ae36-4d18-a3c3-df935dbf4447",
                        "questionType": "MultipleChoiceQuestion",
                        "state": [1],
                        "score": 1,
                        "answerTimestamp": 1484704516218,
                        "tags": []
                    },
                    {
                        "id": "5674435b-61f7-4222-9f77-b7b0c10d41ac",
                        "questionType": "DropdownQuestion",
                        "state": 0,
                        "score": 1,
                        "answerTimestamp": 1484704519512,
                        "tags": []
                    },
                    {
                        "id": "5674435b-61f7-4222-9f77-b7b0c10d41ad",
                        "questionType": "DropdownQuestion",
                        "state": null,
                        "score": null,
                        "answerTimestamp": null,
                        "tags": []
                    },
                    {
                        "id": "5674435b-61f7-4222-9f77-b7b0c10d41ae",
                        "questionType": "DropdownQuestion",
                        "state": null,
                        "score": null,
                        "answerTimestamp": null,
                        "tags": []
                    },
                    {
                        "id": "b810a84f-01f7-49f5-8f23-062a257d709d",
                        "questionType": "DragQuestion",
                        "state": [{
                            "draggableIdx": 1,
                            "answerIdx": -1
                        }],
                        "score": null,
                        "answerTimestamp": 1484704521302,
                        "tags": []
                    }],
                    "exerciseMark": {
                        "correctCount": 2,
                        "incorrectCount": 0,
                        "missedCount": 3
                    },
                    "duration": 62380,
                    "submitTimestamp": 1484704529712
                },
                "anomalies": {
                    
                }
            },
            "sessionID": "159",
            "localTimestamp": 1484704529856,
            "timezoneOffset": -480
        }');
     *  // . time()*1000 . ',
    */
    //1475543370002 - timestamp for 4th Oct about 9:04am
    if (!$json)
        throw new Exception("Empty request");

    echo json_encode(router($json));
} catch (UserAccessException $e) {
    // Throw UserAccessExceptions in the code if this is an authentication issue
    headerDateWithStatusCode(403);
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
            headerDateWithStatusCode(401);
            break;
        default:
            headerDateWithStatusCode(500);
    }
    echo json_encode(array("error" => $e->getMessage(), "code" => $e->getCode()));
}

function router($json) {
    global $service;
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
            $json->timezoneOffset = json_decode('{"minutes":'.abs($json->timezoneOffset).',"negative":'.($json->timezoneOffset < 0).'}');
    }

    if (!isset($json->mode))
    	$json->mode = null;
    // ctp#428
    if (!isset($json->platform))
        $json->platform = '*not passed from app*';

    // Save the version of the app that called us
    $service->setAppVersion((isset($json->appVersion)) ? $json->appVersion : '0.0.0');

    switch ($json->command) {
        case "login": return login($json->email, $json->password, $json->productCode, $json->platform);
        case "getTestResult": return getResult($json->sessionID, $json->mode);
        case "scoreWrite": return scoreWrite($json->sessionID, $json->score, $json->localTimestamp, $json->timezoneOffset);
        case "getTranslations": return getTranslations($json->lang);
        default: throw new Exception("Unknown command");
    }
}

// In general, exceptions are thrown if something blocks login. Like an expired user or no licence slots.
function login($email, $password, $productCode, $platform = null) {
    global $service;
    // ctp#428
    try {
        AbstractService::$controlLog->setIdent($email);
        $rc = AbstractService::$controlLog->info("Attempt login from $platform");
    } catch (Exception $e) {
        // do nothing
    }
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
