<?php
require 'aws_php_sdk/aws-autoloader.php';
/*
 * This is the entry point for aws requests for Clarity tools
 *
 *
*/
header('Content-type: application/json');
if ($_SERVER['REQUEST_METHOD'] === "OPTIONS") return;

$json = json_decode(file_get_contents('php://input'));
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

    if (isset($json->dbHost) &&  ($json->dbHost != $GLOBALS['dbHost']))
        $service->changeDB($json->dbHost);

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
        // General errors that you haven't added yet!
        case 101:
            // Token errors
        case 103:
        case 106:
        case 107:
        case 108:
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
        case "getprediction":
            if (!isset($json->text))
                throw new Exception("Request is missing key information");
            return getPrediction($json->text);
        case "dbcheck": return dbCheck();
        default: throw new Exception("Unknown command ".$json->command);
    }
}

// clarityenglish.ai NewDirections
function getPrediction($review) {
    global $service;
    $prediction = $service->getPrediction($review);
    return $prediction;
}
// Just for testing new gateways
function dbCheck() {
    global $service;
    return $service->dbCheck();
}
