<?php
$json = json_decode(file_get_contents('php://input'));
/*
$json = json_decode('{"command":"addUser","name":"why do you love me so much?",'.
                '"prefix":"Clarity","group":74548,'.
                '"email":"'.substr(str_shuffle(MD5(microtime())), 0, 10).'",'.
                '"password":"'.substr(str_shuffle(MD5(microtime())), 0, 10).'"'.
              '}');
*/
$json_error = json_last_error();

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
    $jsonResult = router($json);
    $jsonWrapped = array("success" => true, "details" => $jsonResult);
    if ($jsonResult == []) {
        echo json_encode($jsonWrapped, JSON_FORCE_OBJECT);
    } else {
        echo json_encode($jsonWrapped);
    }

} catch (Exception $e) {
    switch ($e->getCode()) {
        case 250:
        case 251:
        case 255:
            // These are the exceptions that are handled by the backend in some way
            // Send back http header 401, but with failure in the JSON
            headerDateWithStatusCode(401);
            break;
        default:
            headerDateWithStatusCode(500);
    }
    echo json_encode(array("success" => false, "error" => array("message" => $e->getMessage(), "code" => (string)$e->getCode())));
}

function router($json) {
    // Check for mandatory data
    if (!isset($json->command))
        throw new Exception("Must send a command");

    $protocol = (stristr(strtolower($_SERVER['SERVER_PROTOCOL']), 'https')) ? 'https://' : 'http://';
    $host = $_SERVER['SERVER_NAME'];
    $port = $_SERVER['SERVER_PORT'];
    //$host = 'dock.projectbench';
    //$port = '80';
    $gateway = 'ExternalLoginGateway.php';
    $folder = '/Software/ResultsManager/web/amfphp/services/';
    $newURL = "https://www-staging.clarityenglish.com" . $folder . $gateway;

    switch ($json->command) {
        case "addUser":

            if (!isset($json->group))
                throw new Exception("Must send a group for addUser");

            // Remember this account must have APIpassword in the licence attributes
            $data = array("method" => $json->command,
                "prefix" => $json->prefix,
                "groupID" => $json->group,
                "loginOption" => 1,
                "subscriptionPeriod" => "1month",
                "adminPassword" => "uyHj8YtT7d8w89",
                "name" => $json->name,
                "email" => $json->email,
                "password" => $json->password
            );
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_POST, TRUE);
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
            curl_setopt($ch, CURLOPT_URL, $newURL);
            curl_setopt($ch, CURLOPT_HEADER, true);
            $headers = getallheaders();
            curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
            if (isset($headers['Cookie'])) {
                curl_setopt($ch, CURLOPT_COOKIE, $headers['Cookie']);
            }
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
            $response = curl_exec($ch);
            $header_size = curl_getinfo($ch, CURLINFO_HEADER_SIZE);
            //$headers = substr($response, 0, $header_size);
            $body = substr($response, $header_size);
            curl_close($ch);

            // The return from the gateway is already in standard json success data format
            $jsonResult = json_decode($body);
            if ($jsonResult->success) {
                return $jsonResult->details;
            } else {
                throw new Exception($jsonResult->error->message, $jsonResult->error->code);
            }
            break;
        default:
    }
}
