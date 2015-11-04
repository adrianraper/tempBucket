<?php
require_once(dirname(__FILE__)."/../core/shared/util/Authenticate.php");
require_once(dirname(__FILE__)."/PracticalWritingService.php");

header('Content-type: application/json');
if ($_SERVER['REQUEST_METHOD'] === "OPTIONS") return;

try {
    // Decode the body
    $json = json_decode(file_get_contents('php://input'));
    echo json_encode(router($json));
} catch (Exception $e) {
    header(':', false, $e->getCode() === 0 ? 500 : $e->getCode());
    echo json_encode(array("error" => $e->getMessage()));
}

// Router
function router($json) {
    // Security
    if ($json->command !== "login") {
        new PracticalWritingService(); // We need this in order to set the session name!
        // Clarity#gh#1292, PW#gh#80 Is this call needed at all?
        if (!Authenticate::isAuthenticated()) throw new Exception("errorLostAuthentication", 403);
    }

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