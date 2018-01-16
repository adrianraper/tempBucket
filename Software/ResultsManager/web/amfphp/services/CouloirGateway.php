<?php
/*
 * This is the entry point for api requests from Couloir apps to the backend
 *
 * It is (temporarily) also the entry point for calls from PWVocabApp until such time
 * as that app can point to PWVAGateway.php
 *
*/
header('Content-type: application/json');
if ($_SERVER['REQUEST_METHOD'] === "OPTIONS") return;

$json = json_decode(file_get_contents('php://input'));
/**
 * Pretend to pass variables for easier debugging

$json = json_decode('{"appVersion":"0.10.14","command":"login","login":"dandelion","password":"c3ae35e6f2bddba4b092c476adf91ccd","productCode":"66","rootId":163,"token":null}');
$json = json_decode('{"command":"login","appVersion":"0.9.10","login":"dandy@email","password":"cf44fcc8f5d27a7d4431b623eda91888","productCode":"66","rootId":163}');
$json = json_decode('{"appVersion":"0.10.10","command":"getComparison","token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9kb2NrLnByb2plY3RiZW5jaCIsImlhdCI6MTUxMTI0OTY0NCwic2Vzc2lvbklkIjoiNDMwIn0.d5NEPkbwQ03tw3hHwcvRqnILwhvN-NRCceiBzfQy-9g"}');
$json = json_decode('{"appVersion":"0.10.9","command":"addUser","email":"jonon@seagull.com","login":"Jonon Seagull","password":"34c9a6ae8bafe22f538970104d67609f",
"selfRegistrationToken":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9kb2NrLnByb2plY3RiZW5jaCIsImlhdCI6MTUxMTIzMTQ1MCwiZXhwIjoxNTExMjM1MDUwLCJmaWVsZHMiOjIxLCJwcm9kdWN0Q29kZSI6IjY2Iiwicm9vdElkIjoiMTA3MTkifQ.QVDXFIuG3D9t1Rn7jWZgu-dHZ0AR9z9mt2GSd9Uy6qc",
"token":null}');
$json = json_decode('{"command":"getLoginConfig","productCode":"66","appVersion":"1.0.0","prefix":"dev"}');
$json = json_decode('{"command":"scoreWrite","appVersion":"0.9.14","score":{"uid":"66.2017066000000.2017066060000.2017066060201","exerciseScore":{"questionScores":[{"id":"58256e35-1852-4e0c-ae82-c068546c0dd1","questionType":"MultipleChoiceQuestion","state":{"answerIdxToStringMap":["Yes","No"],"selectedAnswerIdxs":[1]},"scores":[1],"mark":{"correctCount":1,"incorrectCount":0,"missedCount":0},"answerTimestamp":1508914741802,"tags":[]},{"id":"63714645-e117-43ae-ab5a-a63aebec05df","questionType":"MultipleChoiceQuestion","state":{"answerIdxToStringMap":["Yes","No"],"selectedAnswerIdxs":[]},"scores":[null],"mark":{"correctCount":0,"incorrectCount":0,"missedCount":1},"answerTimestamp":null,"tags":[]},{"id":"9c115863-9da6-486b-ba04-3d818c9975a4","questionType":"MultipleChoiceQuestion","state":{"answerIdxToStringMap":["Yes","No"],"selectedAnswerIdxs":[]},"scores":[null],"mark":{"correctCount":0,"incorrectCount":0,"missedCount":1},"answerTimestamp":null,"tags":[]},{"id":"ae3444a2-c5f0-4227-8768-29f5d2ab66bc","questionType":"MultipleChoiceQuestion","state":{"answerIdxToStringMap":["Yes","No"],"selectedAnswerIdxs":[]},"scores":[null],"mark":{"correctCount":0,"incorrectCount":0,"missedCount":1},"answerTimestamp":null,"tags":[]},{"id":"cbd54a2c-c224-4b07-a111-cd9ad90680b9","questionType":"MultipleChoiceQuestion","state":{"answerIdxToStringMap":["Yes","No"],"selectedAnswerIdxs":[]},"scores":[null],"mark":{"correctCount":0,"incorrectCount":0,"missedCount":1},"answerTimestamp":null,"tags":[]},{"id":"6e2b5687-ddfb-4568-8f5c-1b64b7e3a3b9","questionType":"MultipleChoiceQuestion","state":{"answerIdxToStringMap":["Yes","No"],"selectedAnswerIdxs":[]},"scores":[null],"mark":{"correctCount":0,"incorrectCount":0,"missedCount":1},"answerTimestamp":null,"tags":[]},{"id":"542103f2-75ab-4b17-ade4-b39b57d5724f","questionType":"MultipleChoiceQuestion","state":{"answerIdxToStringMap":["Yes","No"],"selectedAnswerIdxs":[]},"scores":[null],"mark":{"correctCount":0,"incorrectCount":0,"missedCount":1},"answerTimestamp":null,"tags":[]},{"id":"4751fd3b-8f24-47ee-ae5d-5e52574831db","questionType":"MultipleChoiceQuestion","state":{"answerIdxToStringMap":["Yes","No"],"selectedAnswerIdxs":[]},"scores":[null],"mark":{"correctCount":0,"incorrectCount":0,"missedCount":1},"answerTimestamp":null,"tags":[]}],"exerciseMark":{"correctCount":1,"incorrectCount":0,"missedCount":7},"duration":25615,"submitTimestamp":1508914751725},"anomalies":{}},"token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9kb2NrLnByb2plY3RiZW5jaCIsImlhdCI6MTUwODkxNDY5Nywic2Vzc2lvbklkIjoiMzk3In0.ur1eizKEOX6tLoNc1wSkiI9M-pqEetou-YU380RRajQ",
  "localTimestamp":1508914759727,"timezoneOffset":-480}');
$json = json_decode('{"command":"memoryWrite","key":"gettingStartedVideos","value":"[{unit:speaking, video:true}]", "token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9kb2NrLnByb2plY3RiZW5jaCIsImlhdCI6MTUwODIxMjExMSwic2Vzc2lvbklkIjoiMzc0In0.Pf4icYhhIz_VmBnmVQL8DHmUaAb-rLXfB_QNZCV7Do4"}');
$json = json_decode('{"command":"memoryWrite","key":"dob","value":"2017-12-31", "token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9kb2NrLnByb2plY3RiZW5jaCIsImlhdCI6MTUwODIxMjExMSwic2Vzc2lvbklkIjoiMzc0In0.Pf4icYhhIz_VmBnmVQL8DHmUaAb-rLXfB_QNZCV7Do4"}');
$json = json_decode('{"command":"memoryClear","token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9kb2NrLnByb2plY3RiZW5jaCIsImlhdCI6MTUwODIxMjExMSwic2Vzc2lvbklkIjoiMzc0In0.Pf4icYhhIz_VmBnmVQL8DHmUaAb-rLXfB_QNZCV7Do4"}');
$json = json_decode('{"command":"addUser","appVersion":"0.9.10","email":"donald-3@trump","name":"Donald Trump 3","password":"f7e41a12cd326daa74b73e39ef442119","token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9kb2NrLnByb2plY3RiZW5jaCIsImlhdCI6MTUwNzUzNDczMywiZXhwIjoxNTA3NTM3NzMzLCJwcm9kdWN0Q29kZSI6NjYsInJvb3RJZCI6IjE2MyJ9.2q8KF1lqGHZo9xdfz27BbWb77ZXagAikrmHNOmoUc8E"}');
$json = json_decode('{"command":"getLoginConfig","productCode":"66","prefix":"Clarity"}');
$json = json_decode('{"command":"getLoginConfig","appVersion":"0.9.10","productCode":"66","prefix":null}');
$json = json_decode('{"command":"login","email":"dandy@email","password":"f7e41a12cd326daa74b73e39ef442119","productCode":66}');
$json = json_decode('{"command":"getScoreDetails","token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9kb2NrLnByb2plY3RiZW5jaCIsImlhdCI6MTUwNjQxNzk5Mywic2Vzc2lvbklkIjoiMzA0In0._P3S0Ll3960dwzV4S-WWWS4F-P_sQr3RwNz6V4HdxMo"}');
$json = json_decode('{"command":"login","productCode":"66", "rootId":163}');
$json = json_decode('{"command":"login","email":"dave@sss","password":"b36dd0fe2ba555a061660f857f842596","productCode":"66", "rootId":10719}');
$json = json_decode('{"command":"getTranslations","lang":"de", "productCode":"66"}');
$json = json_decode('{"command":"dbCheck"}');
$json = json_decode('{"command":"login","email":"ferko.spits@email","password":"20863ef31d598f9c020c0d5b872e2fbe","productCode":"66", "rootId":163}');
$json = json_decode('{"command":"login","email":"xx@noodles.hk","password":"68f1e135ba6167a2a4665b267d8fde39","productCode":"66", "rootId":163}');
$json = json_decode('{"command":"getAccount","productCode":"66","prefix":"clarity"}');
$json = json_decode('{"command":"getTestResult","appVersion":"1.1.0","testID":"73","sessionID":"201"}');
$json = json_decode('{"command":"getScoreDetails","token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9kb2NrLnByb2plY3RiZW5jaCIsImlhdCI6MTUwNDU5MTc0Niwic2Vzc2lvbklkIjoiMjQ2In0.MZlSRH6vJsa1ExDi4o17xWkVErQCa5-Iu9JYWXdJ_Ls"}');
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
            "token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9kb2NrLnByb2plY3RiZW5jaCIsImlhdCI6MTUwODIxMjExMSwic2Vzc2lvbklkIjoiMzc0In0.Pf4icYhhIz_VmBnmVQL8DHmUaAb-rLXfB_QNZCV7Do4",
            "localTimestamp": '. $utcTimestamp .',
            "timezoneOffset": -480
    }');
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
//1475543370002 - timestamp for 4th Oct about 9:04am
 */

// sss#257 Detect if this request is aimed at PWVocabApp, and swiftly redirect if it is
if ($json && !isset($json->appVersion)) {
    $folder = substr($_SERVER['SCRIPT_NAME'],0,strrpos($_SERVER['SCRIPT_NAME'], 'CouloirGateway.php'));
    $protocol = (stristr(strtolower($_SERVER['SERVER_PROTOCOL']),'https')) ? 'https://' : 'http://';
    $host = $_SERVER['SERVER_NAME'];
    $port = $_SERVER['SERVER_PORT'];
    $gateway = 'PWVocabAppGateway.php';
    $newURL = $protocol.$host.':'.$port.$folder.$gateway;
    // If I simply use a header to redirect, I lose my request body.
    // stackoverflow suggests to use curl instead
    // https://stackoverflow.com/questions/22437548/php-how-to-redirect-forward-http-request-with-header-and-body
    // Also note how that answer has different option if headers get all bound into the content. See /script/LoginGateway.php
    //header('Location: '.$newURL);
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_POST, true);
    // As the php://input stream can only be read once, put it into curl through postfields
    // PHP5.6++ is supposed to let multiple reads, but it is fine for us
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($json));
    curl_setopt($ch, CURLOPT_URL, $newURL);
    curl_setopt($ch, CURLOPT_HEADER, true);
    $headers = getallheaders();
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    if (isset($headers['Cookie'])) {
        curl_setopt($ch, CURLOPT_COOKIE, $headers['Cookie']);
    }
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, false);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, false);
    $response = curl_exec($ch);
    exit;
}

// For setting the header when you want to send back an exception
function headerDateWithStatusCode($statusCode) {
    $utcDateTime = new DateTime();
    $utcTimestamp = $utcDateTime->format('U')*1000;
    header("Date: ".$utcTimestamp, false, $statusCode);
}

require_once(dirname(__FILE__)."/CouloirService.php");
$service = new CouloirService();
set_time_limit(360);

// Following for debug and logging dates and times
// Pick up the current time and convert as if it came from app  (local timezone, microseconds)
$utcDateTime = new DateTime();
$utcTimestamp = $utcDateTime->format('U')*1000;
$utcDateTime->setTimezone(new DateTimeZone('Asia/Hong_Kong'));
$localDate = $utcDateTime->format('Y-m-d H:i:s');
// Or simply set a date time that you want to test with
//$localDate = '2017-09-01 11:33:00';
$localDateTime = new DateTime($localDate);
$localTimestamp = $localDateTime->format('U')*1000;
//$GLOBALS['fake_now'] = '2017-10-10 09:00:00';

try {
    if (!$json)
        throw new Exception("Empty request");

    $jsonResult = router($json);
    /*
    switch ($json->command) {
        case "login":
        case "getTranslations":
        case "memoryWrite":
        case "memoryClear":
            //AbstractService::$debugLog->info("CTP return" . $json->command);
            break;
        default:
            AbstractService::$debugLog->info("CTP return " . json_encode($jsonResult));
    }
    */
    // sss#256 put a success wrapper around the returning data
    $jsonWrapped = array("success" => true, "details" => $jsonResult);
    // sss#344 This command requires a list even if empty
    if ($json->command == "getScoreDetails" && $jsonResult == array()) {
        echo json_encode($jsonWrapped);
    } else {
        if ($jsonResult == []) {
            echo json_encode($jsonWrapped, JSON_FORCE_OBJECT);
        } else {
            echo json_encode($jsonWrapped);
        }
    }

    /*
     * sss#256
    } catch (UserAccessException $e) {
        // Throw UserAccessExceptions in the code if this is an authentication issue
        headerDateWithStatusCode(403);
        echo json_encode(array("error" => $e->getMessage(), "code" => $e->getCode()));
    */
} catch (Exception $e) {
    switch ($e->getCode()) {
        // ctp#75
        case 200:
        case 201:
        case 203:
        case 204:
        case 205:
        case 206:
        case 207:
        case 208:
        case 209:
        case 210:
        case 213:
        case 214:
        case 215:
        case 217:
        case 218:
        case 220:
        case 221:
        case 224:
        case 300:
        case 301:
        case 303:
        case 304:
        case 306:
        case 311:
        case 312:
        case 313:
            // sss#256 These are the exceptions that are handled by the backend in some way
            // Send back http header 200, but with failure in the JSON
            //headerDateWithStatusCode(401);
            break;
        default:
            headerDateWithStatusCode(500);
    }
    echo json_encode(array("success" => false, "error" => array("message" => $e->getMessage(), "code" => (string) $e->getCode())));
    // sss#236 If you need to run this code but the app is not implementing #256, include the next line and comment the above one
    //echo json_encode(array("message" => $e->getMessage(), "code" => (string) $e->getCode()));
}

function router($json) {
    global $service;

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

    // Just in case we are using the old SSS product code - will certainly be redundant by release date
    if ((isset($json->productCode) && $json->productCode=='60')) {
        throw new Exception("Using old SSS productCode=60");
    }

    $localDateTime = new DateTime();
    $localTimestamp = $localDateTime->format('Y-m-d H:i:s');
    //AbstractService::$debugLog->info("CTP ".$json->command." at ".$localTimestamp);
    switch ($json->command) {
        case "logout": return logout($json->token);
        case "login":
            /*
            $loginObj = Array();
            $loginObj["email"] = (isset($json->login)) ? $json->login : null;
            $loginObj["studentID"] = (isset($json->studentID)) ? $json->studentID : null;
            $loginObj["username"] = (isset($json->name)) ? $json->name : null;
            $loginObj["password"] = (isset($json->password)) ? $json->password : null;
            */
            if (!isset($json->login)) $json->login = null;
            if (!isset($json->password)) $json->password = null;
            // ctp#428
            if (!isset($json->platform)) $json->platform = '*not passed from app*';
            if (!isset($json->rootId)) $json->rootId = null;
            return login($json->login, $json->password, $json->productCode, $json->rootId, $json->platform);
        case "getLoginConfig":
            // sss#285
            if (!isset($json->prefix)) $json->prefix = null;
            // sss#374
            if (!isset($json->referrer)) $json->referrer = null;
            return getLoginConfig($json->productCode, $json->prefix, $json->referrer);
        // sss#177
        case "addUser":
            $loginObj = Array();
            $loginObj["email"] = (isset($json->email)) ? $json->email : null;
            $loginObj["login"] = (isset($json->login)) ? $json->login : null;
            $loginObj["password"] = (isset($json->password)) ? $json->password : null;
            return addUser($json->selfRegistrationToken, $loginObj);
        case "getTestResult": return getResult($json->token, $json->mode);
        case "scoreWrite": return scoreWrite($json->token, $json->score, $json->localTimestamp, $json->timezoneOffset);
        // sss#228
        case "memoryWrite":
            if (!isset($json->key)) $json->key = null;
            if (!isset($json->value)) $json->value = null;
            return memoryWrite($json->token, $json->key, $json->value);
        // sss#228
        case "memoryClear":
            return memoryClear($json->token);
        // sss#155
        case "getTranslations":
            if (!isset($json->productCode)) $json->productCode = null;
            return getTranslations($json->lang, $json->productCode);
        case "getCoverage": return getCoverage($json->token);
        case "getComparison": return getComparison($json->token, $json->mode);
        case "getAnalysis": return getAnalysis($json->token);
        case "getScoreDetails": return getScoreDetails($json->token);
        case "dbCheck": return dbCheck();
        default: throw new Exception("Unknown command ".$json->command);
    }
}

// In general, exceptions are thrown if something blocks login. Like an expired user or no licence slots.
function login($login, $password, $productCode, $rootId, $platform = null) {
    global $service;
    // ctp#428
    try {
        //AbstractService::$controlLog->setIdent($loginObj->email);
        //AbstractService::$controlLog->info("Attempt login from $platform");
    } catch (Exception $e) {
        // do nothing
    }
    return $service->login($login, $password, $productCode, $rootId, $platform);
}
// sss#61 Return login option details for this account
// Returns exception if no account found - 223 is an expected one
// sss#285
function getLoginConfig($productCode, $prefix, $referrer) {
    global $service;
    return $service->getLoginConfig($productCode, $prefix, $referrer);
}
// sss#177 Add a new user to a self-registering account
function addUser($selfRegistrationToken, $loginObj) {
    global $service;
    return $service->addUser($selfRegistrationToken, $loginObj);
}
// sss#228 write memory for this user from the app
function memoryWrite($token, $key, $value) {
    global $service;
    return $service->memoryWrite($token, $key, $value);
}
function memoryClear($token) {
    global $service;
    return $service->memoryClear($token);
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
