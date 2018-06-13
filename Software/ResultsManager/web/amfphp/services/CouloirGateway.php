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

$json = json_decode(file_get_contents('php://input'));
$json_error = json_last_error();
//$json = json_decode('{"appVersion":"1.1.3-dev","command":"scoreWrite","localTimestamp":1528867718961,"score":{"uid":"63.2015063020000.2015063020001.2015063020003","exerciseScore":{"questionScores":[{"id":"7485edf5-3471-403b-935c-ed6f9d40dc93","questionType":"FreeDragQuestion","state":{"dropTargetIdxToAnswerIdxMap":[null,0,null,null,null,null,null,null,null,null],"initial":null,"current":1},"scores":[1],"mark":{"correctCount":1,"incorrectCount":0,"missedCount":0},"answerTimestamp":1528867672550,"tags":["A1","word-placement"]},{"id":"c3a8b965-2612-433d-a4e8-1e2c6baa8d72","questionType":"ReconstructionQuestion","state":{"draggableIdxToAnswerIdxMap":[3,2,4,1,0],"initial":[0,1,2,3,4],"current":[4,3,1,0,2]},"scores":[1],"mark":{"correctCount":1,"incorrectCount":0,"missedCount":0},"answerTimestamp":1528867681060,"tags":["A1","text-organisation"]},{"id":"4522e29d-6149-44a3-85ed-c96ee77f6765","questionType":"FreeDragQuestion","state":{"dropTargetIdxToAnswerIdxMap":[null,null,null,null,null,0,null],"initial":null,"current":5},"scores":[1],"mark":{"correctCount":1,"incorrectCount":0,"missedCount":0},"answerTimestamp":1528867683795,"tags":["A2","word-placement"]},{"id":"ac771676-4e9d-4ded-9267-437c66677533","questionType":"FreeDragQuestion","state":{"dropTargetIdxToAnswerIdxMap":[null,0,null,null,null,null,null],"initial":null,"current":1},"scores":[1],"mark":{"correctCount":1,"incorrectCount":0,"missedCount":0},"answerTimestamp":1528867687313,"tags":["A2","word-placement"]},{"id":"a3a76c27-825b-43a0-a192-36fb8a034da3","questionType":"ReconstructionQuestion","state":{"draggableIdxToAnswerIdxMap":[3,0,6,5,2,1,4],"initial":[0,1,2,3,4,5,6],"current":[1,5,4,0,6,3,2]},"scores":[1],"mark":{"correctCount":1,"incorrectCount":0,"missedCount":0},"answerTimestamp":1528867696835,"tags":["A2","sentence-reconstruction"]},{"id":"dfaa2714-f245-40a1-ad83-b5a8c8cf013e","questionType":"ReconstructionQuestion","state":{"draggableIdxToAnswerIdxMap":[1,4,0,2,3],"initial":[0,1,2,3,4],"current":[0,1,2,3,4]},"scores":[null],"mark":{"correctCount":0,"incorrectCount":0,"missedCount":1},"answerTimestamp":null,"tags":["A2","text-organisation"]},{"id":"bb3bb4d2-7fb1-48fb-a7f7-2047f9fe4780","questionType":"FreeDragQuestion","state":{"dropTargetIdxToAnswerIdxMap":[null,null,null,null,null,null,0,null,null,null,null],"initial":null,"current":6},"scores":[1],"mark":{"correctCount":1,"incorrectCount":0,"missedCount":0},"answerTimestamp":1528867705918,"tags":["B1","word-placement"]},{"id":"db5bb6ca-2c16-4ae5-bfa9-b2a2b5db0f3f","questionType":"FreeDragQuestion","state":{"dropTargetIdxToAnswerIdxMap":[null,null,0,null,null,null,null,null,null,null,null,null,null],"initial":null,"current":null},"scores":[null],"mark":{"correctCount":0,"incorrectCount":0,"missedCount":1},"answerTimestamp":null,"tags":["B1","word-placement"]},{"id":"4ddf28e1-d520-46a7-909f-9a655e6879f4","questionType":"ReconstructionQuestion","state":{"draggableIdxToAnswerIdxMap":[7,4,2,6,1,5,0,3],"initial":[0,1,2,3,4,5,6,7],"current":[0,1,2,3,4,5,6,7]},"scores":[null],"mark":{"correctCount":0,"incorrectCount":0,"missedCount":1},"answerTimestamp":null,"tags":["B1","sentence-reconstruction"]},{"id":"5a1ee2a3-126a-4bd4-90c9-0780a82c1d67","questionType":"ReconstructionQuestion","state":{"draggableIdxToAnswerIdxMap":[2,4,3,0,5,1],"initial":[0,1,2,3,4,5],"current":[0,1,2,3,4,5]},"scores":[null],"mark":{"correctCount":0,"incorrectCount":0,"missedCount":1},"answerTimestamp":null,"tags":["B1","text-organisation"]}],"exerciseMark":{"correctCount":6,"incorrectCount":0,"missedCount":4},"duration":41928,"submitTimestamp":'. $utcTimestamp .'},"anomalies":{}},"timezoneOffset":-480,"token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJjbGFyaXR5ZW5nbGlzaC5jb20iLCJpYXQiOjE1Mjg4NjE4NTIsInNlc3Npb25JZCI6IjU5OSJ9.wBdh7nTsHtypN9cl8D1_B5RHhlrqcqNCYfgsOmiIN3w"}');
//$json = json_decode('{"command":"getTestResult","appVersion":"1.1.3-dev","token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJjbGFyaXR5ZW5nbGlzaC5jb20iLCJpYXQiOjE1Mjg5NjE3NTksInNlc3Npb25JZCI6IjYwMyJ9.tAEz7TwS_Bi4_z-aqbdcktgmG9QjpRoeV1QXdn6d78k"}');
/**
 * Pretend to pass variables for easier debugging
$json = json_decode('{"appVersion":"1.3.2-dev","command":"login","login":"dandy@clarity","password":"93bc9620dea7442a898e5396b2b8e346","productCode":"63","rootId":null,"token":null}');
$json = json_decode('{"command":"login","appVersion":"1.0.0","login":"dandelion dev","password":"3938e4d558baf3f3ff9924a84ad66cd6","productCode":"68","rootId":10719}');
$json = json_decode('{"command":"getCertificate","courseId":"2018068010000","courseName":"Elementary","token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJjbGFyaXR5ZW5nbGlzaC5jb20iLCJpYXQiOjE1MjU5MjkyMTMsInNlc3Npb25JZCI6IjUzOCJ9.H7eI5vSe8aFFdaDYKBENFlxLeB5HGBQS2pHjh2axsWQ", "appVersion":"1.0"}');
$json = json_decode('{"appVersion":"1.0","command":"login","login":"dandelion","password":"2bdc02c98d80ce8ff84f58a0140d5471","productCode":"68","rootId":163,"token":null}');
$json = json_decode('{"command":"login","email":"pinky@email","password":"password","timezoneOffset":"-480"}');
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
$json = json_decode('{"command":"getAccount","productCode":"66","prefix":"clarity"}');
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
 */

// sss#257 Detect if this request is aimed at PWVocabApp so that it can be handled specially later
if ($json && !isset($json->appVersion)) {
    $PWVocabApp = true;
    require_once(dirname(__FILE__)."/../core/shared/util/Authenticate.php");
    require_once(dirname(__FILE__)."/PracticalWritingService.php");
    $service = new PracticalWritingService();
    //AbstractService::$debugLog->info("PWVA" . json_encode($json));
} else {
    $PWVocabApp = false;
    require_once(dirname(__FILE__)."/CouloirService.php");
    $service = new CouloirService();
}
set_time_limit(60);

// For setting the header when you want to send back an exception
function headerDateWithStatusCode($statusCode) {
    $utcDateTime = new DateTime();
    $utcTimestamp = $utcDateTime->format('U')*1000;
    header("Date: ".$utcTimestamp, false, $statusCode);
}

try {
    if ($json_error !== JSON_ERROR_NONE)
        throw new Exception("Passed request not valid json");
    if (!$json)
        throw new Exception("Empty request");

    // m#173 Prefix all commands to handle vocab app differently
    if ($PWVocabApp)
        $json->command = 'PWVA'.$json->command;
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
    // m#174 no wrapping for PWVocabApp
    // sss#256 put a success wrapper around the returning data
    if ($PWVocabApp) {
        echo json_encode($jsonResult);
    } else {
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
        case 604:
            // sss#256 These are the exceptions that are handled by the backend in some way
            // Send back http header 200, but with failure in the JSON
            //headerDateWithStatusCode(401);
            break;
        default:
            headerDateWithStatusCode(500);
    }
    if ($PWVocabApp) {
        echo json_encode(array("message" => $e->getMessage(), "code" => (string)$e->getCode()));
    } else {
        echo json_encode(array("success" => false, "error" => array("message" => $e->getMessage(), "code" => (string)$e->getCode())));
    }
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
            $json->lang = strtolower($json->lang);
            return getTranslations($json->lang, $json->productCode);
        case "getCoverage": return getCoverage($json->token);
        case "getComparison": return getComparison($json->token, $json->mode);
        case "getAnalysis": return getAnalysis($json->token);
        case "getScoreDetails": return getScoreDetails($json->token);
        case "getCertificate":
            if (!isset($json->courseId)) $json->courseId = null;
            if (!isset($json->courseName)) $json->courseName = null;
            return getCertificate($json->token, $json->courseId, $json->courseName);
        case "dbCheck": return dbCheck();
        // m#174
        case "PWVAlogin":
            if (!isset($json->email)) $json->email = null;
            if (!isset($json->timezoneOffset)) $json->timezoneOffset = null;
            return PWVAlogin($json->email, $json->password, $json->timezoneOffset);
        case "PWVAupdateSession": return PWVAupdateSession($json->sessionID);
        case "PWVAgetMastery": return PWVAgetMastery($json->userID);
        case "PWVAwriteScore": return PWVAwriteScore($json->userID, $json->sessionID, $json->dateNow, $json->scoreObj);
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
// m#11 App asking for a certificate
function getCertificate($token, $courseId, $courseName) {
    global $service;
    return $service->getCertificate($token, $courseId, $courseName);
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
// m#174 Calls unique to PWVocabApp. Will be useless once the app can be updated to call PWVocabAppGateway directly
// or to use regular Couloir calls
function PWVAlogin($email, $password, $timezoneOffset) {
    global $service;
    $rootID = null;
    $productCode = 61;

    // Fake a licence just to allow Bento to login with email - which gets the real licence (or does it?)
    $minimalLicence = new Licence();
    $minimalLicence->licenceType = 1;

    // Login
    $login = $service->login(
        array("email" => $email, "password" => $password, "timezoneOffset" => $timezoneOffset),
        User::LOGIN_BY_EMAIL,
        true,
        microtime(true) * 10000,
        $minimalLicence, null, $productCode
    );
    $title = $login['account']->titles[0];
    $user = $login['group']->manageables[0];

    // Start a new session
    $session = $service->startSession($user, $rootID, $productCode);
    $sessionID = $session['sessionID'];

    return array(
        "user" => $user,
        "title" => $title,
        "sessionID" => $sessionID
    );
}

function PWVAgetMastery($userID) {
    global $service;
    $productCode = 61;

    return $service->progressOps->getMastery($userID, $productCode);
}

function PWVAwriteScore($userID, $sessionID, $dateNow, $scoreObj) {
    global $service;
    $user = $service->manageableOps->getUserById($userID);

    return $service->writeScore($user, $sessionID, $dateNow, (array)$scoreObj);
}

function PWVAupdateSession($sessionID) {
    global $service;

    return $service->updateSession($sessionID);
}
