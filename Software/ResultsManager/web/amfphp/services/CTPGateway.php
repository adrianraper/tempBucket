<?php

header('Content-type: application/json');
if ($_SERVER['REQUEST_METHOD'] === "OPTIONS") return;

require_once(dirname(__FILE__)."/CouloirService.php");

// For setting the header when you want to send back an exception
function headerDateWithStatusCode($statusCode) {
    $utcDateTime = new DateTime();
    $utcTimestamp = $utcDateTime->format('U')*1000;
    header("Date: ".$utcTimestamp, false, $statusCode);
}
class UserAccessException extends Exception {}

$service = new CouloirService();
set_time_limit(360);

// Pick up the current time and convert as if it came from app  (local timezone, microseconds)
$utcDateTime = new DateTime();
$utcTimestamp = $utcDateTime->format('U')*1000;
$utcDateTime->setTimezone(new DateTimeZone('Asia/Hong_Kong'));
$localDate = $utcDateTime->format('Y-m-d H:i:s');
// Or simply set a date time that you want to test with
//$localDate = '2017-09-01 11:33:00';
$localDateTime = new DateTime($localDate);
$localTimestamp = $localDateTime->format('U')*1000;

try {
    // Decode the body
    $json = json_decode(file_get_contents('php://input'));
    //$json = json_decode('{"command":"getCoverage","token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9kb2NrLnByb2plY3RiZW5jaCIsImlhdCI6MTUwNDc3MDQ4OCwic2Vzc2lvbklkIjoiMjU5In0.v0b1YdNxmx7NLrZopGmX7yavtn1v397nYf2LIBjzkvc"}');
    //$json = json_decode('{"command":"login","email":"dave@sss","password":"b36dd0fe2ba555a061660f857f842596","productCode":66, "rootID":10719}');
    $json = json_decode('{"command":"getTranslations","lang":"de", "productCode":66}');
    /*
    $json = json_decode('{"command":"login","email":"dandy@email","password":"f7e41a12cd326daa74b73e39ef442119","productCode":65, "rootID":163}');
    //$json = json_decode('{"command":"dbCheck"}');
    $json = json_decode('{"command":"login","email":"ferko.spits@email","password":"20863ef31d598f9c020c0d5b872e2fbe","productCode":66, "rootID":163}');
    $json = json_decode('{"command":"login","email":"xx@noodles.hk","password":"68f1e135ba6167a2a4665b267d8fde39","productCode":66, "rootID":163}');
    $json = json_decode('{"command":"getAccount","productCode":66,"IP":"192.168.8.68","RU":""}');
    $json = json_decode('{"command":"getAccount","productCode":66,"prefix":"clarity","IP":"192.168.8.61","RU":""}');
    $json = json_decode('{"command":"getTestResult","appVersion":"1.1.0","testID":"73","sessionID":"201"}');
    $json = json_decode('{"command":"getScoreDetails","token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9kb2NrLnByb2plY3RiZW5jaCIsImlhdCI6MTUwNDU5MTc0Niwic2Vzc2lvbklkIjoiMjQ2In0.MZlSRH6vJsa1ExDi4o17xWkVErQCa5-Iu9JYWXdJ_Ls"}');

    */
    /*
    $json = json_decode('{"command": "scoreWrite",
                "appVersion": "0.8.1",
                "score": {
                    "uid": "66.2017066010000.2017066010200.2017066010202",
                    "exerciseScore": {
                        "questionScores": [{
                            "id": "2b722a83-afc4-4006-8a05-6b0b4c8ab9e4",
                            "questionType": "DragQuestion",
                            "state": {
                                "draggableIdxToAnswerIdxMap": [0, null, null, null, null, null, null],
                                "draggableIdxToStringMap": ["online news", "index", "textbook", "library website", "weather report", "food label", "social networking site"],
                                "draggableIdx": 0
                            },
                            "score": 1,
                            "answerTimestamp": 1503026898929,
                            "tags": []
                        }, {
                            "id": "9be66051-2e04-4fa6-a8df-c43b9075378c",
                            "questionType": "DragQuestion",
                            "state": {
                                "draggableIdxToAnswerIdxMap": [null, null, null, null, 0, null, null],
                                "draggableIdxToStringMap": ["online news", "index", "textbook", "library website", "weather report", "food label", "social networking site"],
                                "draggableIdx": 4
                            },
                            "score": 1,
                            "answerTimestamp": 1503026910321,
                            "tags": []
                        }, {
                            "id": "ebedd2df-da83-44f1-9701-c86d7f9e4177",
                            "questionType": "DragQuestion",
                            "state": {
                                "draggableIdxToAnswerIdxMap": [null, null, 0, null, null, null, null],
                                "draggableIdxToStringMap": ["online news", "index", "textbook", "library website", "weather report", "food label", "social networking site"],
                                "draggableIdx": null
                            },
                            "score": null,
                            "answerTimestamp": null,
                            "tags": []
                        }, {
                            "id": "157bf8c7-6eed-4d14-b18a-869c6c78a53e",
                            "questionType": "DragQuestion",
                            "state": {
                                "draggableIdxToAnswerIdxMap": [null, 0, null, null, null, null, null],
                                "draggableIdxToStringMap": ["online news", "index", "textbook", "library website", "weather report", "food label", "social networking site"],
                                "draggableIdx": null
                            },
                            "score": null,
                            "answerTimestamp": null,
                            "tags": []
                        }, {
                            "id": "4149b4c5-b5f7-46a6-aaa7-de4a2f688212",
                            "questionType": "DragQuestion",
                            "state": {
                                "draggableIdxToAnswerIdxMap": [null, null, null, null, null, 0, null],
                                "draggableIdxToStringMap": ["online news", "index", "textbook", "library website", "weather report", "food label", "social networking site"],
                                "draggableIdx": null
                            },
                            "score": null,
                            "answerTimestamp": null,
                            "tags": []
                        }, {
                            "id": "de39b5c7-9232-422d-b9f1-21729e92a49c",
                            "questionType": "DragQuestion",
                            "state": {
                                "draggableIdxToAnswerIdxMap": [null, null, null, 0, null, null, null],
                                "draggableIdxToStringMap": ["online news", "index", "textbook", "library website", "weather report", "food label", "social networking site"],
                                "draggableIdx": null
                            },
                            "score": null,
                            "answerTimestamp": null,
                            "tags": []
                        }, {
                            "id": "d0d404dd-8d19-49b1-a573-64158dc7e89d",
                            "questionType": "DragQuestion",
                            "state": {
                                "draggableIdxToAnswerIdxMap": [null, null, null, null, null, null, 0],
                                "draggableIdxToStringMap": ["online news", "index", "textbook", "library website", "weather report", "food label", "social networking site"],
                                "draggableIdx": null
                            },
                            "score": null,
                            "answerTimestamp": null,
                            "tags": []
                        }],
                        "exerciseMark": {
                            "correctCount": 3,
                            "incorrectCount": 2,
                            "missedCount": 5
                        },
                        "duration": 92001,
                        "submitTimestamp": '. $utcTimestamp .'
                    },
                    "anomalies": {
                        "lostFocus": 3,
                        "lostVisibility": 1
                    }
                },
                "token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9kb2NrLnByb2plY3RiZW5jaCIsImlhdCI6MTUwNDc3MDQ4OCwic2Vzc2lvbklkIjoiMjU5In0.v0b1YdNxmx7NLrZopGmX7yavtn1v397nYf2LIBjzkvc",
                "localTimestamp": '. $utcTimestamp .',
                "timezoneOffset": -480
        }');
    */
    /*
    $json = json_decode('{
	"command": "scoreWrite",
	"appVersion": "1.1.0",
	"score": {
		"uid": "63.2016063999.20166301999.2016063990",
		"exerciseScore": {
			"questionScores": [{
				"id": "11124987-ae36-4d18-a3c3-df935dbf4447",
				"questionType": "MultipleChoiceQuestion",
				"state": {
					"answerIdxToStringMap": ["orange",
					"egg",
					"apple",
					"avocado"],
					"selectedAnswerIdxs": [1]
				},
				"score": 1,
				"answerTimestamp": 1503557450490,
				"tags": []
			},
			{
				"id": "5674435b-61f7-4222-9f77-b7b0c10d41ac",
				"questionType": "DropdownQuestion",
				"state": {
					"answerIdxToStringMap": ["loves",
					"prefers",
					"thinks"],
					"selectedAnswerIdx": 0
				},
				"score": 1,
				"answerTimestamp": 1503557452500,
				"tags": []
			},
			{
				"id": "5674435b-61f7-4222-9f77-b7b0c10d41ad",
				"questionType": "DropdownQuestion",
				"state": {
					"answerIdxToStringMap": ["love",
					"prefer",
					"think"],
					"selectedAnswerIdx": 2
				},
				"score": 1,
				"answerTimestamp": 1503557454598,
				"tags": []
			},
			{
				"id": "5674435b-61f7-4222-9f77-b7b0c10d41ae",
				"questionType": "DropdownQuestion",
				"state": {
					"answerIdxToStringMap": ["listen",
					"prefer",
					"think"],
					"selectedAnswerIdx": 1
				},
				"score": 1,
				"answerTimestamp": 1503557456060,
				"tags": []
			},
			{
				"id": "b810a84f-01f7-49f5-8f23-062a257d709d",
				"questionType": "DragQuestion",
				"state": {
					"draggableIdxToAnswerIdxMap": [0,
					null,
					null],
					"draggableIdxToStringMap": ["take",
					"go",
					"endure"],
					"draggableIdx": 0
				},
				"score": 1,
				"answerTimestamp": 1503557457501,
				"tags": []
			}],
			"exerciseMark": {
				"correctCount": 5,
				"incorrectCount": 0,
				"missedCount": 0
			},
			"duration": 333743,
			"submitTimestamp":  '. time()*1000 .'
		},
		"anomalies": {
			"lostFocus": 1
		}
	},
	"sessionID": "201",
	"localTimestamp": 1503557638530,
	"timezoneOffset": -480
}');

    */
    //1475543370002 - timestamp for 4th Oct about 9:04am
    if (!$json)
        throw new Exception("Empty request");

    $jsonResult = router($json);
    switch ($json->command) {
        case "login":
        case "getTranslations":
            AbstractService::$debugLog->info("CTP return " . $json->command);
            break;
        default:
            AbstractService::$debugLog->info("CTP return " . json_encode($jsonResult));
    }
    if ($jsonResult == []) {
        echo json_encode($jsonResult, JSON_FORCE_OBJECT);
    } else {
        echo json_encode($jsonResult);
    }

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

    // Save the version of the app that called us
    $service->setAppVersion((isset($json->appVersion)) ? $json->appVersion : '0.0.0');

    // Just in case we are using the old SSS product code
    if ((isset($json->productCode) && $json->productCode==60))
        $json->productCode = 66;

    $localDateTime = new DateTime();
    $localTimestamp = $localDateTime->format('Y-m-d H:i:s');
    AbstractService::$debugLog->info("CTP ".$json->command." at ".$localTimestamp);
    switch ($json->command) {
        case "login":
            $loginObj = Array();
            $loginObj["email"] = (isset($json->email)) ? $json->email : null;
            $loginObj["studentID"] = (isset($json->studentID)) ? $json->studentID : null;
            $loginObj["username"] = (isset($json->name)) ? $json->name : null;
            // ctp#428
            if (!isset($json->platform)) $json->platform = '*not passed from app*';
            if (!isset($json->rootID)) $json->rootID = null;
            return login($loginObj, $json->password, $json->productCode, $json->rootID, $json->platform);
        case "getAccount":
            if (!isset($json->prefix)) $json->prefix = null;
            if (!isset($json->IP)) $json->IP = null;
            if (!isset($json->RU)) $json->RU = null;
            return getAccount($json->productCode, $json->prefix, $json->IP, $json->RU);
        case "getTestResult": return getResult($json->token, $json->mode);
        case "scoreWrite": return scoreWrite($json->token, $json->score, $json->localTimestamp, $json->timezoneOffset);
        // sss#155
        case "getTranslations":
            if (!isset($json->productCode)) $json->productCode = null;
            return getTranslations($json->lang, $json->productCode);
        case "getCoverage": return getCoverage($json->token);
        case "getComparison": return getComparison($json->token, $json->mode);
        case "getAnalysis": return getAnalysis($json->token);
        case "getScoreDetails": return getScoreDetails($json->token);
        case "dbCheck": return dbCheck();
        default: throw new Exception("Unknown command");
    }
}

// In general, exceptions are thrown if something blocks login. Like an expired user or no licence slots.
function login($loginObj, $password, $productCode, $rootId, $platform = null) {
    global $service;
    // ctp#428
    try {
        //AbstractService::$controlLog->setIdent($loginObj->email);
        //AbstractService::$controlLog->info("Attempt login from $platform");
    } catch (Exception $e) {
        // do nothing
    }
    return $service->login($loginObj, $password, $productCode, $rootId, $platform);
}
// sss#61 Return an account that matches any given prefix or IP.
// Returns exception if no account found - 223 is an expected one
function getAccount($productCode, $prefix, $ip, $ru) {
    global $service;
    return $service->getAccount($productCode, $prefix, $ip, $ru);
}
// sss#17 Return a map of exercise ids which have been done
function getCoverage($token) {
    global $service;
    return $service->getCoverage($token);
}
// sss#17 Return a map of unit ids showing my score and the average score for worldwide | country | institution
function getComparison($token, $mode = 'worldwide') {
    global $service;
    return $service->getUnitComparison($token, $mode);
}
// sss#17 Return a map of unit ids with the time spent on each
function getAnalysis($token) {
    global $service;
    return $service->getUnitProgress($token);
}
// sss#17 This returns a array of objects, each containing the exerciseId, the score (as a percent), the date and the duration (in seconds).
function getScoreDetails($token) {
    global $service;
    return $service->getScoreDetails($token);
}

function getResult($token, $mode = null) {
    global $service;
    return $service->getResult($token, $mode);
}

function scoreWrite($token, $scoreObj, $localTimestamp, $clientTimezoneOffset=null) {
    global $service;
    return $service->scoreWrite($token, $scoreObj, $localTimestamp, $clientTimezoneOffset);
    /*
    // ctp#166
    if ($rc["success"]===false) {
        return array("token" => $token, "error" => $rc["error"]);
    } else {
        return array("token" => $token);
    }
    */
}
// ctp#60
// sss#155
function getTranslations($lang, $productCode) {
    global $service;
    return $service->getTranslations($lang, $productCode);
}
// Just for testing new gateways
function dbCheck() {
    global $service;
    return $service->dbCheck();
}
