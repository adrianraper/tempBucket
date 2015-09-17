<?php
require_once(dirname(__FILE__)."/../core/shared/util/Authenticate.php");
require_once(dirname(__FILE__)."/PracticalWritingService.php");

// CORS
header("Access-Control-Allow-Origin: http://localhost:3000");
header("Access-Control-Allow-Credentials: true");
header("Access-Control-Allow-Methods: OPTIONS, GET, POST");
header("Access-Control-Allow-Headers: Content-Type, Depth, User-Agent, X-File-Size, X-Requested-With, If-Modified-Since, X-File-Name, Cache-Control");
header('Content-type: application/json');
if ($_SERVER['REQUEST_METHOD'] === "OPTIONS") return;

try {
    // Decode the body
    $json = json_decode(file_get_contents('php://input'));
    echo json_encode(router($json));
} catch (Exception $e) {
    header(':', false, 500);
    echo json_encode(array("error" => $e->getMessage()));
}

// Router
function router($json) {
    switch ($json->command) {
        case "login": return login($json->email, $json->password, $json->timezoneOffset);
        case "updateSession": return updateSession($json->sessionID);
        case "getMastery": return getMastery($json->userID);
        case "writeScore": return writeScore($json->userID, $json->sessionID, $json->dateNow, $json->scoreObj);
        default: throw new Exception("Unknown command");
    }
}

function login($email, $password, $timezoneOffset) {
    $rootID = null;
    $productCode = 61;

    $service = new PracticalWritingService();

    // Get PW account settings
    $accountSettings = $service->getAccountSettings(
        array("productCode" => $productCode, "prefix" => "Clarity", "dbHost" => 2, "rootID" => $rootID, "ip" => "127.0.0.1")
    );
    $title = $accountSettings['account']->titles[0];

    // Login
    $login = $service->login(
        array("email" => $email, "password" => $password, "timezoneOffset" => $timezoneOffset),
        User::LOGIN_BY_EMAIL,
        true,
        microtime(true) * 10000,
        $accountSettings['licence']
    );
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
    $productCode = 61;
    $service = new PracticalWritingService();

    return $service->progressOps->getMastery($userID, $productCode);
}

function writeScore($userID, $sessionID, $dateNow, $scoreObj) {
    $service = new PracticalWritingService();
    $user = $service->manageableOps->getUserById($userID);

    return $service->writeScore($user, $sessionID, $dateNow, (array)$scoreObj);
}

function updateSession($sessionID) {
    $service = new PracticalWritingService();

    return $service->updateSession($sessionID);
}

/**
 * Need languageCode on the client so I can choose the localized content.  i.e. this will be used to
 * choose what to download (when we do that).  (That's in the title).  Also content locations are
 * in the account settings - this will give us a folder which we can download from somewhere.
 * http://www.clarityenglish.com/content/<whateveritis>
 *
 * Sessions:
 *
 * When you login you login, then load the menu xml, then startSession where we pass a bunch of
 * stuff.
 *
 * Every minute that the program is running it calls updateLicence (really should be called updateSession).
 * every minute.  If you don't trigger any mouse/touch action for 5 minutes it then stops this one minute
 * call.  I might get a new session_id back!
 */