<?php

header('Content-type: text/plain');
if ($_SERVER['REQUEST_METHOD'] === "OPTIONS") return;

require_once(dirname(__FILE__)."/../core/shared/util/Authenticate.php");
require_once(dirname(__FILE__)."/CTPService.php");

class UserAccessException extends Exception {}

const PRODUCT_CODE_DPT = 63;
const PRODUCT_CODE_SSS = 66;
const PRODUCT_CODE_DE = 65; // Deutscher Einstufungstest

$service = new CTPService();
set_time_limit(360);

try {
    // Pick up the passed data
    $testId = filter_input(INPUT_GET, 'id', FILTER_SANITIZE_ENCODED);
    if ($testId) {
        $json = json_decode('{"command":"getCode","testId":'.$testId.'}');
        if ($json) {
            echo router($json);
        } else {
            header(':', false, 500);
            echo json_encode(array("error" => "Invalid JSON passed"));
        }
    } else {
        header(':', false, 500);
        echo json_encode(array("error" => "No id passed"));
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

function getCode($id) {
    global $service;
    // If you are passed just an integer, assume product is dpt for compatability
    $idBreakdown = explode('.', $id);
    $pc = count($idBreakdown) > 1 ? $idBreakdown[0] : PRODUCT_CODE_DPT;
    $key = count($idBreakdown) > 1 ? $idBreakdown[1] : $idBreakdown[0];
    switch ($pc) {
        case PRODUCT_CODE_DPT:
        case PRODUCT_CODE_DE:
            $code = $service->testOps->getTestAccessCode($key);
            break;
        case PRODUCT_CODE_SSS:
        default:
            $code = $service->getDefaultCode($key);
            break;
    }
    if (!$code)
        throw new Exception("Passed id did not match database");

    return $code;
}
