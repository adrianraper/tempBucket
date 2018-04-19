<?php
/*
 * This is the entry point for api requests from PWVocabApp to the backend
 *
 */
header('Content-type: application/json');
if ($_SERVER['REQUEST_METHOD'] === "OPTIONS") return;

$json = json_decode(file_get_contents('php://input'));
$json = json_decode('{"command":"login","email":"pinky@email","password":"password","timezoneOffset":"-480"}');
$json_error = json_last_error();

require_once(dirname(__FILE__)."/../core/shared/util/Authenticate.php");
require_once(dirname(__FILE__)."/PracticalWritingService.php");
$service = new PracticalWritingService();
set_time_limit(60);

// For setting the header when you want to send back an exception
function headerDateWithStatusCode($statusCode) {
    $utcDateTime = new DateTime();
    $utcTimestamp = $utcDateTime->format('U')*1000;
    header("Date: ".$utcTimestamp, false, $statusCode);
}
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

try {
    if ($json_error !== JSON_ERROR_NONE)
        throw new Exception("Passed request not valid json");
    if (!$json)
        throw new Exception("Empty request");

    $jsonResult = router($json);
    echo json_encode($jsonResult);

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
    echo json_encode(array("message" => $e->getMessage(), "code" => (string)$e->getCode()));
}
// Router
function router($json) {
    global $service;

    if (!isset($json->command))
        throw new Exception("No command");

    // Security
    if ($json->command !== "login")
        if (!Authenticate::isAuthenticated()) throw Exception("errorLostAuthentication");

    switch ($json->command) {
        case "login":
            if (!isset($json->email)) $json->email = null;
            if (!isset($json->timezoneOffset)) $json->timezoneOffset = null;
            return login($json->email, $json->password, $json->timezoneOffset);
        case "updateSession": return updateSession($json->sessionID);
        case "getMastery": return getMastery($json->userID);
        case "writeScore": return writeScore($json->userID, $json->sessionID, $json->dateNow, $json->scoreObj);
        default: throw new Exception("Unknown command ".$json->command);
    }
}

function login($email, $password, $timezoneOffset) {
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

function getMastery($userID) {
    global $service;
    $productCode = 61;

    return $service->progressOps->getMastery($userID, $productCode);
}

function writeScore($userID, $sessionID, $dateNow, $scoreObj) {
    global $service;
    $user = $service->manageableOps->getUserById($userID);

    return $service->writeScore($user, $sessionID, $dateNow, (array)$scoreObj);
}

function updateSession($sessionID) {
    global $service;

    return $service->updateSession($sessionID);
}
