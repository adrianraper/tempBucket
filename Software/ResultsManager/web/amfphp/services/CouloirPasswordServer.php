<?php

header('Content-type: text/plain');
if ($_SERVER['REQUEST_METHOD'] === "OPTIONS") return;

require_once(dirname(__FILE__)."/../core/shared/util/Authenticate.php");
require_once(dirname(__FILE__)."/CTPService.php");

class UserAccessException extends Exception {}

$service = new CTPService();
set_time_limit(360);

try {
    // Pick up the passed data
    $testId = filter_input(INPUT_GET, 'testId', FILTER_SANITIZE_ENCODED);
    if ($testId) {
        $json = json_decode('{"command":"getCode","testId":'.$testId.'}');
        echo router($json);
    } else {
        header(':', false, 200);
        echo json_encode(array("error" => "No test id passed"));
    }
} catch (UserAccessException $e) {
    header(':', false, 403);
    echo json_encode(array("error" => $e->getMessage()));
} catch (Exception $e) {
    header(':', false, 500);
    echo json_encode(array("error" => $e->getMessage()));
}

// Router
function router($json) {
    if ($json->command == "getCode") {
        return getCode($json->testId);
    }
    throw new Exception("Unknown command");
}

function getCode($testId) {
    global $service;
    return $service->testOps->getTestAccessCode($testId);
}
