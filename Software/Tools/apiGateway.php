<?php
/*
 * This is the entry point for api requests for Clarity tools
 *
 *
*/
header('Content-type: application/json');
if ($_SERVER['REQUEST_METHOD'] === "OPTIONS") return;

$json = json_decode(file_get_contents('php://input'));
//$json = json_decode('{"command":"generateTokens","quantity":2,"productCode":68,"rootId":163,"groupId":74548,"duration":90,"productVersion":"FV"}');
//$json = json_decode('{"command":"checkEmail","email":"adrian@clarity"}');
//$json = json_decode('{"command":"activateToken", "token":"9853-5602-0024-0", "email":"adrian@clarity", "name":"Peanuts", "password":"28e05e0207c6706531b2f60a6038ae8b"}');
//$json = json_decode('{"command":"getTokenStatus", "token":"3208-5356-0209-7"}');
//$json = json_decode('{"command":"getLicenceUsage","productCode":50,"token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJjbGFyaXR5ZW5nbGlzaC5jb20iLCJpYXQiOjE1MzU1MjAzMDMsInVzZXJJZCI6MTEyNTksInByZWZpeCI6ImNsYXJpdHkiLCJyb290SWQiOiIxNjMiLCJncm91cElkIjoxMDM3OX0.5taJkI1FVQv7lOLnrbfw7T1ow68ev4A-sfnpAI6MAAc"}');
//$json = json_decode('{"command":"signin","email":"adrian@clarity","password":"28e05e0207c6706531b2f60a6038ae8b"}');
//$json = json_decode('{"command":"getResult","productCode":63,"token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJjbGFyaXR5ZW5nbGlzaC5jb20iLCJpYXQiOjE1MzU1MjAzMDMsInVzZXJJZCI6MTEyNTksInByZWZpeCI6ImNsYXJpdHkiLCJyb290SWQiOiIxNjMiLCJncm91cElkIjoxMDM3OX0.5taJkI1FVQv7lOLnrbfw7T1ow68ev4A-sfnpAI6MAAc"}');
//$json = json_decode('{"command":"readJWT","token":"eyJ0e.eyJpc3.O9kQ-jX"}');
/**
 * Pretend to pass variables for easier debugging
$json = json_decode('{"appVersion":"1.3.5","command":"createJWT","payload":{"iss":"clarityenglish.com", "iat":1508212111, "prefix":"Clarity", "login":"nathan@clarity", "startNode":"unit:2018068010300"}}');
 */
$json_error = json_last_error();

// For dedicated tool functions
require_once(dirname(__FILE__) . "/apiService.php");
$service = new apiService();
set_time_limit(300);

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
$localDate = $utcDateTime->format('Y-m-d H:i:s');
//$GLOBALS['fake_now'] = '2017-10-10 09:00:00';

try {
    if ($json_error !== JSON_ERROR_NONE)
        throw new Exception("Passed request not valid json");
    if (!$json)
        throw new Exception("Empty request");

    $jsonResult = router($json);
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

} catch (Exception $e) {
    switch ($e->getCode()) {
        // Token errors
        case 103:
        case 106:
        case 107:
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
    echo json_encode(array("success" => false, "error" => array("message" => $e->getMessage(), "code" => (string)$e->getCode())));
}

function router($json) {
    global $service;

    // Save the version of the app that called us
    $service->setAppVersion((isset($json->appVersion)) ? $json->appVersion : '0.0.0');

    switch (strtolower($json->command)) {
        // {"command":"generateToken","quantity":1,"productCode":68,"rootId":163,"groupId":74548,"duration":90,"productVersion":"FV","expiryDate":"2018-12-31"}
        case "generatetokens":
            // Some parameters are mandatory
            if (!isset($json->rootId) || !isset($json->productCode))
                throw new Exception("Request is missing key information");
            // Some can be defaulted
            if (!isset($json->expiryDate)) $json->expiryDate = null;
            if (!isset($json->quantity)) $json->quantity = null;
            if (!isset($json->duration)) $json->duration = null;
            if (!isset($json->productVersion)) $json->duration = null;
            return generateTokens($json->quantity, $json->productCode, $json->rootId, $json->groupId, $json->duration, $json->productVersion, $json->expiryDate);
        case "activatetoken":
            if (!isset($json->token) || !isset($json->email))
                throw new Exception("Request is missing key information");
            return activateToken($json->token, $json->email, $json->name, $json->password);
        case "gettokenstatus":
            if (!isset($json->token))
                throw new Exception("Request is missing key information");
            return getTokenStatus($json->token);
        case "checkemail":
            if (!isset($json->email))
                throw new Exception("Request is missing key information");
            return checkEmail($json->email);
        case "signin":
            if (!isset($json->email) || !isset($json->password))
                throw new Exception("Request is missing key information");
            return signIn($json->email, $json->password);
        case "getlicenceusage":
            if (!isset($json->productCode)) $json->productCode = null;
            return getLicenceUsage($json->token, $json->productCode);
        case "getresult":
            if (!isset($json->productCode)) $json->productCode = null;
            return getResult($json->token, $json->productCode);
        case "createjwt":
            if (!isset($json->payload)) $json->payload = null;
            if (!isset($json->key)) $json->key = null;
            return createJWT($json->payload, $json->key);
        case "readjwt":
            if (!isset($json->token)) $json->token = null;
            //if (!isset($json->key)) $json->key = null;
            return readJWT($json->token);
        case "dbcheck": return dbCheck();
        default: throw new Exception("Unknown command ".$json->command);
    }
}

function signIn($email, $password) {
    global $service;
    return $service->signIn($service->cleanInputs($email, 'email'),
                            $service->cleanInputs($password, 'password'));
}
function checkEmail($email) {
    global $service;
    return $service->checkEmail($service->cleanInputs($email, 'email'));
}
// This is tokens that customers purchase to subscribe to ClarityEnglish
function getTokenStatus($token) {
    global $service;
    return $service->getTokenStatus($service->cleanInputs($token, 'token'));
}
function generateTokens($quantity, $productCode, $rootId, $groupId, $duration, $productVersion, $expiryDate){
    global $service;
    return $service->generateTokens($quantity, $productCode, $rootId, $groupId, $duration, $productVersion, $expiryDate);
}
function activateToken($token, $email, $name, $password){
    global $service;
    $rc = $service->activateToken($service->cleanInputs($token, 'token'),
                                    $service->cleanInputs($email, 'email'),
                                    $service->cleanInputs($name, 'name'),
                                    $service->cleanInputs($password, 'password'));
    return $service->signIn($email, $password);
}
function getLicenceUsage($token, $productCode=null) {
    global $service;
    return $service->getLicenceUsageWrapper($token, $productCode);
}
function getResult($token, $productCode=null) {
    global $service;
    return $service->getResult($token, $productCode);
}
function createJWT($payload, $key) {
    global $service;
    return $service->createJWT($payload, $key);
}
function readJWT($token) {
    global $service;
    try {
        return $service->readJWT($token);
    } catch (Exception $e) {
        throw new Exception("Invalid token. JWT:" . $e->getMessage());
    }
}

// Just for testing new gateways
function dbCheck() {
    global $service;
    return $service->dbCheck();
}
