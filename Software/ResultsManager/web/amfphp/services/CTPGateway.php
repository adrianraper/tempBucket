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
    //$json = json_decode(file_get_contents('php://input'));
    //$json->productCode = 63;
    $json = json_decode('{"command":"login","email":"tracka@ppt","password":"ppt","productCode":63}');

    echo json_encode(router($json));
} catch (UserAccessException $e) {
    header(':', false, 403);
    echo json_encode(array("error" => $e->getMessage()));
} catch (Exception $e) {
    header(':', false, 500);
    echo json_encode(array("error" => $e->getMessage()));
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
        case "getResult": return getResult($json->sessionID);
        case "scoreWrite": return scoreWrite($json->sessionID, $json->scoreObj, $json->clientTimezoneOffset);
        default: throw new Exception("Unknown command");
    }
}

// In general, exceptions are thrown if something blocks login. Like an expired user or no licence slots.
function login($email, $password, $productCode) {
    global $service;
    return $service->testLogin($email, $password, $productCode);
}

function getMastery($sessionId) {
    global $service;
    $session = new TestSession($sessionId);
    $user = $service->manageableOps->getUserById($session->userId);

    return $service->progressOps->getResult($user, $session->productCode);
}

function scoreWrite($sessionId, $scoreObj, $clientTimezoneOffset=null) {
    global $service;
    $session = new TestSession($sessionId);
    $user = $service->manageableOps->getUserById($session->userId);

    return $service->scoreWrite($user, $session, $scoreObj, $clientTimezoneOffset);
}
