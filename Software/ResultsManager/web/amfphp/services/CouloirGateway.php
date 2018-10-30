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
$json_error = json_last_error();
//$json = json_decode('{"command":"getAnalysis","appVersion":"2.0.0","token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJjbGFyaXR5ZW5nbGlzaC5jb20iLCJpYXQiOjE1NDA4NzkxNTEsInNlc3Npb25JZCI6IjY0NzE0In0.PVpUpfxVKCNR_B5C1yym-XeRabTu0ngMfakZdjILjsw"}');
//$json = json_decode('{"appVersion":"1.3.2-dev","command":"login","login":"user_01@TD01.com", "password":"5bbe3101701f49bd0b23eaec55f4aaad","productCode":"68","rootId":"201"}');

// sss#257 Detect if this request is aimed at PWVocabApp so that it can be handled specially later
if ($json && !isset($json->appVersion)) {
    $PWVocabApp = true;
    require_once(dirname(__FILE__)."/../core/shared/util/Authenticate.php");
    require_once(dirname(__FILE__)."/PracticalWritingService.php");
    $service = new PracticalWritingService();
} else {
    $PWVocabApp = false;
    require_once(dirname(__FILE__)."/CouloirService.php");
    $service = new CouloirService();
}
set_time_limit(360);

// For setting the header when you want to send back an exception
function headerDateWithStatusCode($statusCode) {
    $utcDateTime = new DateTime();
    $utcTimestamp = $utcDateTime->format('U')*1000;
    header("Date: ".$utcTimestamp, false, $statusCode);
}

// Following for debug and logging dates and times
// Pick up the current time and convert as if it came from app  (local timezone, microseconds)
$timeStart = new DateTime();
//$utcTimestamp = $utcDateTime->format('U')*1000;
//$utcDateTime->setTimezone(new DateTimeZone('Asia/Hong_Kong'));
//$localDate = $utcDateTime->format('Y-m-d H:i:s');
// Or simply set a date time that you want to test with
//$localDate = '2017-09-01 11:33:00';
//$localDateTime = new DateTime($localDate);
//$localTimestamp = $localDateTime->format('U')*1000;
//$GLOBALS['fake_now'] = '2017-10-10 09:00:00';

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
        // Token errors
        case 103:
        case 104:
        case 106:
        case 107:
        case 108:
        case 109:
        // ctp#75 m#346
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
        case 216:
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
// m#484 For recording how long each call took and what it was
$timeEnd = new DateTime();
$duration = $timeEnd->diff($timeStart)->format('%s');
AbstractService::$log->info("CG-call: duration=$duration call=" . substr(json_encode($json), 0, 100));

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

    // m#316 If an apiToken has been sent, confirm it and then use the payload to populate the regular json parameters
    if (isset($json->apiToken)) {
        $payload = $service->authenticationCops->getApiPayload($json->apiToken);
        $key = (isset($payload->prefix)) ? $service->authenticationCops->getAccountApiKey($payload->prefix) : '0';
        $service->authenticationCops->validateApiToken($json->apiToken, $key);

        // Merge the payload into the regular parameters now it is validated
        // Parameters that come from payload will overwrite those from outside
        $json = (object) array_merge((array) $json, (array) $payload);
    } else {
        $json->apiToken = null;
    }

    // Save the version of the app that called us
    $service->setAppVersion((isset($json->appVersion)) ? $json->appVersion : '0.0.0');

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
            // ctp#428 m#397
            if (!isset($json->platform)) $json->platform = null;
            if (!isset($json->rootId)) $json->rootId = null;
            return login($json->login, $json->password, $json->productCode, $json->rootId, $json->apiToken, $json->platform);
        case "getLoginConfig":
            // sss#285
            if (!isset($json->prefix)) $json->prefix = null;
            // sss#374
            if (!isset($json->referrer)) $json->referrer = null;
            return getLoginConfig($json->productCode, $json->prefix, $json->referrer, $json->apiToken);
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
        // m#454
        case "writeTestDate":
            if (!isset($json->timestamp)) $json->timestamp = null;
            return writeTestDate($json->token, $json->timestamp);
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
            // m#322 Cope with old style sending of course information
            if (!isset($json->courseInfo)){
                if (isset($json->courseName) && isset($json->courseId)) {
                    $json->courseInfo = json_decode('{"name":"'.$json->courseName.'", "id":"'.$json->courseId.'", "exercises":100}');
                } else {
                    $json->courseInfo = null;
                }
            }
            return getCertificate($json->token, $json->courseInfo);
        case "dbCheck": return dbCheck();
        case "acquireLicenseSlots":
            return acquireLicenceSlots($json->tokens);
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
function login($login, $password, $productCode, $rootId, $apiToken = null, $platform = null) {
    global $service;
    // ctp#428
    try {
        $msg = "Attempt login";
        $message = json_encode(array("message" => $msg, "productCode" => $productCode, "login" => $login, "password" => $password, "rootId" => $rootId));
        AbstractService::$dashboardLog->setIdent($login);
        AbstractService::$dashboardLog->info($message);
    } catch (Exception $e) {
        // do nothing
    }
    return $service->login($login, $password, $productCode, $rootId, $apiToken, $platform);
}
// sss#61 Return login option details for this account
// Returns exception if no account found - 223 is an expected one
// sss#285
function getLoginConfig($productCode, $prefix, $referrer, $apiToken) {
    global $service;
    return $service->getLoginConfig($productCode, $prefix, $referrer, $apiToken);
}
// sss#177 Add a new user to a self-registering account
function addUser($selfRegistrationToken, $loginObj) {
    global $service;
    return $service->addUserFromToken($selfRegistrationToken, $loginObj);
}
// sss#228 write memory for this user from the app
function memoryWrite($token, $key, $value) {
    global $service;
    return $service->memoryWrite($token, $key, $value);
}
// m#454 write test date
function writeTestDate($token, $timestamp) {
    global $service;
    return $service->writeTestDate($token, $timestamp);
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
    return $service->getAnalysis($token);
}
// sss#17 This returns a array of objects, each containing the exerciseId, the score (as a percent), the date and the duration (in seconds).
function getScoreDetails($token) {
    global $service;
    return $service->getScoreDetails($token);
}
// m#11 App asking for a certificate
function getCertificate($token, $courseInfo) {
    global $service;
    return $service->getCertificate($token, $courseInfo);
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
// This is not usually called from here as it goes through the licence server
// but it makes it easier to test as an api call to also run from here
function acquireLicenceSlots($tokens) {
    global $service;
    return $service->checkLicenceSlots($tokens);
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
