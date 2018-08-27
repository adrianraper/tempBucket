<?php
/*
 * This page expects product, prefix and user details which it passes to the product start page.
 * The user is assumed to exists - so use integration.php if you are not sure about that.
 */

/*
 * This page takes an apiToken, validates it and reads the payload.
 * This payload is then used to attempt automatic sign in to the right program.
 * If the token is not valid, or other errors occur, you end up on the sign in page for the program.
 *
 * It uses LoginService to access the PHP classes and functions.
 */
$json = json_decode(file_get_contents('php://input'));
$json_error = json_last_error();
/**
 * Pretend to pass variables for easier debugging
 */
//$json = json_decode('{"apiToken":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJjbGFyaXR5ZW5nbGlzaC5jb20iLCJpYXQiOjE1MzQxMjk1NDQsImV4cCI6MTUzNDIxNTc5MiwicHJlZml4IjoiTk1TIiwibG9naW4iOiIzNjMxMDM1MTNAY2xhcml0eSIsInByb2R1Y3RDb2RlIjoiNjgifQ.HXEK_5qCkRAiVJ1LZPBGli5ADlIaPiTnztoYewtyQs4"}');

if (!$json) {
    if (isset($_POST['apiToken'])) {
        $jsonStr = '{"apiToken":"'.$_POST["apiToken"].'"}';
    } elseif (isset($_GET['apiToken'])) {
        $jsonStr = '{"apiToken":"'.$_GET['apiToken'].'"}';
    } else {
        $jsonStr = "";
    }
    $json = json_decode($jsonStr);
}

require_once(dirname(__FILE__)."/../ResultsManager/web/amfphp/services/LoginService.php");
$loginService = new LoginService();

// Get the token contents
try {
    if (!isset($json->apiToken))
        throw new Exception("Passed request does not contain a token");

    $payload = getPayloadFromToken($json->apiToken);

    // Data validation
    // 1. You must set name/email, prefix, productCode as a minimum
    if (!isset($payload->prefix))
        throw new Exception("Passed request does not contain: prefix");
    if (!isset($payload->productCode))
        throw new Exception("Passed request does not contain: productCode");
    if (!isset($payload->name) && !isset($payload->email) && !isset($payload->login))
        throw new Exception("Passed request does not contain: name or email");

    // 2. If there is a login set, force the name to mimic it
    // 2. If there is no name or no email set, copy it from the other
    if (isset($payload->login))
        $payload->name = $payload->login;
    if (isset($payload->name) && !isset($payload->email))
        $payload->email = $payload->name;
    if (isset($payload->email) && !isset($payload->name))
        $payload->name = $payload->email;

    // 2a. Send login as a parameter as well as name/email until we figure out the loginOption
    if (!isset($payload->login))
        $payload->login = $payload->name;

    // 3. If there is no password, create one based on hash of name
    if (!isset($payload->password))
        $payload->password = md5(str_pad($payload->name, 16, 'nasfunklanmsdiun'));

    switch ($payload->productCode) {
        case 63:
        case 66:
        case 57:
        case 68:
            // Call to addUser for Bento and older Couloir titles
            // For now use this for all titles as the password will then be help plainly
            $rc = addUser($payload);
            break;
        default:
            // Just direct to Couloir titles that can accept token
            break;
    }
} catch (Exception $e) {
    $msg = $e->getMessage();
    switch ($e->getCode()) {
        case 255:
            // This is fine, the user already exists
            continue;
            break;
        case 251:
            // Account doesn't allow this API to run
            $msg = "This account does not allow remote access.";
        default:
            // display the message on screen
            echo $msg;
            exit();
            flush();
    }
}

// Start the program
switch ($payload->productCode) {
    case 68:
        //$url = "https://tb.clarityenglish.com/#apiToken=".$json->apiToken;
        $url = "https://tb-staging.clarityenglish.com#prefix=".$payload->prefix."&login=".$payload->name."&password=".$payload->password."&reset";
        break;
    case 63:
        $url = "https://dpt-staging.clarityenglish.com#prefix=".$payload->prefix."&login=".$payload->email."&password=".$payload->password."&reset";
        // Force online mode for DPT to solve downloading issues
        $url .= "&online";
        break;
    case 66:
        $url = "https://sss-staging.clarityenglish.com#prefix=".$payload->prefix."&login=".$payload->name."&password=".$payload->password;
        break;
    default:
        if ($payload->productCode == 57) $programStartPage = "ClearPronunciationV10/Start-sounds.php";
        if ($payload->productCode == 61) $programStartPage = "PracticalWriting/Start.php";
        $url = "https://www-staging.clarityenglish.com/area1/".$programStartPage."?prefix=".$payload->prefix."&email=".$payload->email."&password=".$payload->password;
        break;
}
forwardTo($url);
flush();
exit();

function headerDateWithStatusCode($statusCode) {
    $utcDateTime = new DateTime();
    $utcTimestamp = $utcDateTime->format('U')*1000;
    header("Date: ".$utcTimestamp, false, $statusCode);
}

function addUser($payload) {
    global $loginService;

    $method = (!isset($payload->group)) ? "addUserAutoGroup" : "adduser";

    // Remember this account must have APIpassword in the licence attributes
    $data = array("method" => $method,
        "prefix" => $payload->prefix,
        "subscriptionPeriod" => "1year",
        "adminPassword" => "uyHj8YtT7d8w89",
        "name" => $payload->name,
        "password" => $payload->password
    );
    if (isset($payload->group)) $data["groupID"] = $payload->group;
    $data["email"] = (isset($payload->email)) ? $payload->email : '';

    $apiInformation = json_decode(json_encode($data), false);
    /*

    $apiCall = json_encode($data);
    $domain = "https://www.clarityenglish.com";
    $domain = "http://dock.projectbench";
    $toolsGateway = $domain."/Software/ResultsManager/web/amfphp/services/ExternalLoginGateway.php";

    $ch = curl_init();
    $headers = getallheaders();
    $options = array(CURLOPT_URL => $toolsGateway,
                    CURLOPT_POST => true,
                    CURLOPT_POSTFIELDS => $apiCall,
                    CURLOPT_HEADER => true,
                    CURLOPT_ENCODING => "",
                    CURLOPT_HTTPHEADER => $headers,
                    CURLOPT_RETURNTRANSFER => true,
                    CURLOPT_FOLLOWLOCATION => true
    );
    curl_setopt_array($ch, $options);
    if (isset($headers['Cookie'])) {
        curl_setopt($ch, CURLOPT_COOKIE, $headers['Cookie']);
    }

    $response = curl_exec($ch);
    if (curl_errno($ch) != 0)
        throw new Exception(curl_error($ch), curl_errno($ch));

    $header_size = curl_getinfo($ch, CURLINFO_HEADER_SIZE);
    $body = substr($response, $header_size);
    curl_close($ch);

    // The return from the gateway is already in standard json success data format
    $jsonResult = json_decode($body);
    $json_error = json_last_error();
    if ($json_error !== JSON_ERROR_NONE)
        throw new Exception($body, 0);

    if ($jsonResult->success) {
        return $jsonResult->details;
    } else {
        throw new Exception($jsonResult->error->message, $jsonResult->error->code);
    }
    */
    // If you are using just a group to add user, need to get rootID now
    // Get the whole account info as well
    if (!$apiInformation->prefix && !$apiInformation->rootID) {
        $group = $loginService->getGroup($apiInformation);
        if (!$group)
            returnError(252, $apiInformation->groupID);

        $account = $loginService->getAccountFromGroup($group);
        if (!$account)
            returnError(253, $apiInformation->groupID);

        $apiInformation->rootID = $account->id;

    } elseif (!isset($apiInformation->rootID)) {
        $account = $loginService->getAccountFromPrefix($apiInformation);
        $apiInformation->rootID = $account->id;

    } else {
        $account = $loginService->getAccountFromRootID($apiInformation);
    }
    if (!$account)
        returnError(254, $apiInformation->rootID);

    // Pick up account loginOption if possible
    $apiInformation->loginOption = (isset($account->loginOption)) ? $account->loginOption : '1';

    // Authentication. You can only use this API if the account has the special licence attribute
    if (!isset($apiInformation->adminPassword)) {
        returnError(250, $account->name);
    } else {
        $licenceAttributes = $loginService->accountOps->getAccountLicenceDetails($account->id, null, 2);
        $dbPassword = '';
        foreach ($licenceAttributes as $attribute) {
            if ($attribute["licenceKey"] == "APIpassword")
                $dbPassword = $attribute["licenceValue"];
        }
        if ($apiInformation->adminPassword != $dbPassword)
            returnError(251, $account->name);
    }

    // Find the user if you can
    $user = $loginService->getUser($apiInformation);

    if ($user==false) {
        if (!isset($group)) {
            $group = $loginService->getGroup($apiInformation, $account);
        }

        if ($group==false) {
            // Autogroup. We need to add new groups
            if ($apiInformation->method == "getOrAddUserAutoGroup") {
                // If you don't know a rootID, you can't add the group
                if (!$apiInformation->rootID)
                    returnError(210, $apiInformation->groupID);

                $group = $loginService->addGroup($apiInformation, $account);
            } else {
                returnError(210, $apiInformation->groupID);
            }
        }

        // Check that the found group is in the right account
        $groupRootId = $loginService->manageableOps->getRootIdForGroupId($group->id);
        if ($groupRootId != $account->id)
            returnError(210, $group->name);

        $user = $loginService->addUser($apiInformation, $group);
        //AbstractService::$debugLog->info("added new user ".$user->name." expire on ".$user->expiryDate);

        // If we want to send an email on adding a new user, do it here
        if ($apiInformation->emailTemplateID) {
            $loginService->subscriptionOps->sendUserEmail($user, $apiInformation);
            //AbstractService::$debugLog->info("queued email to ".$user->email.' using '.$apiInformation->emailTemplateID);
        }
    } else {
        // An error if you are trying to add a user
        returnError(255, $user->name);
    }

}

function returnError($errCode, $data = null) {

    switch ($errCode) {
        case 1:
            $msg = 'Exception, '.$data;
            break;
        case 210:
            $msg = 'Invalid group ID '.$data;
            break;
        case 200:
            $msg = 'No such user '.$data;
            break;
        case 207:
            $msg = 'User expired '.$data;
            break;
        case 250:
            $msg = 'You must send a password for the account '.$data;
            break;
        case 251:
            $msg = 'This is the wrong password for account '.$data;
            break;
        case 252:
            $msg = 'Group not found '.$data;
            break;
        case 253:
            $msg = 'Wrong password';
            break;
        case 254:
            $msg = 'Account not found '.$data;
            break;
        case 255:
            $msg = 'User already exists '.$data;
            break;
        default:
            $msg = 'Unknown error';
            break;
    }
    // Write out the error to the log
    AbstractService::$debugLog->err('returnError '.$errCode.': '.$msg);
    throw new exception($msg, $errCode);
}

function getPayloadFromToken($token) {
    global $loginService;

    try {
        $rc = $loginService->readJWT($token);
        return $rc['payload'];
    } catch (Exception $e) {
        throw new Exception("Invalid token. JWT:" . $e->getMessage());
    }
    $service = null;

    // Call ToolsGateway to read the token
    /*
    $data = array("command" => "readJWT", "token" => $token);
    $apiCall = json_encode($data);
    $domain = "https://www.clarityenglish.com";
    //$domain = "http://dock.projectbench";
    $toolsGateway = $domain."/Software/Tools/apiGateway.php";

    $ch = curl_init();
    $headers = getallheaders();
    $options = array(CURLOPT_URL => $toolsGateway,
                    CURLOPT_POST => true,
                    CURLOPT_POSTFIELDS => $apiCall,
                    CURLOPT_HEADER => true,
                    CURLOPT_ENCODING => "",
                    CURLOPT_HTTPHEADER => $headers,
                    CURLOPT_RETURNTRANSFER => true,
                    CURLOPT_FOLLOWLOCATION => true
    );
    curl_setopt_array($ch, $options);
    if (isset($headers['Cookie'])) {
        curl_setopt($ch, CURLOPT_COOKIE, $headers['Cookie']);
    }

    $response = curl_exec($ch);
    if (curl_errno($ch) != 0)
        throw new Exception(curl_error($ch), curl_errno($ch));

    $header_size = curl_getinfo($ch, CURLINFO_HEADER_SIZE);
    $body = substr($response, $header_size);
    curl_close($ch);

    // The return from the gateway is already in standard json success data format
    $jsonResult = json_decode($body);
    $json_error = json_last_error();
    if ($json_error !== JSON_ERROR_NONE)
        throw new Exception($body, 0);

    if ($jsonResult->success) {
        return $jsonResult->details->payload;
    } else {
        throw new Exception($jsonResult->error->message, $jsonResult->error->code);
    }
    */
}

function dbCheck() {

    // Call ToolsGateway to read the token
    $data = array("command" => "dbCheck");
    $apiCall = json_encode($data);
    $toolsGateway = "https://www.clarityenglish.com/Software/Tools/apiGateway.php";

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_POST, TRUE);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $apiCall);
    curl_setopt($ch, CURLOPT_URL, $toolsGateway);
    curl_setopt($ch, CURLOPT_HEADER, true);
    $headers = getallheaders();
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    if (isset($headers['Cookie'])) {
        curl_setopt($ch, CURLOPT_COOKIE, $headers['Cookie']);
    }
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch,CURLOPT_FAILONERROR,true);
    //curl_setopt($ch, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows NT 6.2; WOW64; rv:17.0) Gecko/20100101 Firefox/17.0');
    $response = curl_exec($ch);
    $header_size = curl_getinfo($ch, CURLINFO_HEADER_SIZE);
    //$headers = substr($response, 0, $header_size);
    $body = substr($response, $header_size);
    curl_close($ch);

    // The return from the gateway is already in standard json success data format
    $jsonResult = json_decode($body);
    $json_error = json_last_error();
    if ($json_error !== JSON_ERROR_NONE)
        throw new Exception($body, 0);

    if ($jsonResult->success) {
        return $jsonResult->details->database;
    } else {
        throw new Exception($jsonResult->error->message, $jsonResult->error->code);
    }
}

function forwardTo($url) {
    headerDateWithStatusCode(200);
    header('Location: '.$url);
}
?>