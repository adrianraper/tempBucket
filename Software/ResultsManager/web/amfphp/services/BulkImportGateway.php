<?php
/**
 * This script is a gateway for bulk import functions
 * 
 * TODO: Need to consider authentication as you use this to add to any old account.
 * At least you should pass the admin user password for the account.
 */
require_once(dirname(__FILE__)."/../core/shared/util/Authenticate.php");
require_once(dirname(__FILE__)."/ClarityService.php");

$thisService = new ClarityService();

// API information will come in JSON format
function loadAPIInformation() {
	global $thisService;
	
	$inputData = file_get_contents("php://input");
	//$inputData = '{"method":"authenticateUser","name":"dandelion","password":"password","dbHost":2,"prefix":"Clarity","loginOption":1}';

	$postInformation= json_decode($inputData, true);
	if (!$postInformation) 
		// TODO. Ready for PHP 5.3
		//throw new Exception("Error decoding data: ".json_last_error().': '.$inputData);
		throw new Exception('Error decoding data: '.': '.$inputData);
	
	// We are expecting a method and parameters as an object
	// First check mandatory fields exist
	if (!isset($postInformation['method']))
		throw new Exception("No method has been sent");
	
	$apiInformation = new LoginAPI();
	$apiInformation->createFromSentFields($postInformation);
	return $apiInformation;
}
	
function returnError($errCode, $data = null) {
	$apiReturnInfo = array('error'=>$errCode);
	switch ($errCode) {
		case 1:
			$apiReturnInfo['message'] = 'Exception, '.$data;
			break;
		case 210:
			$apiReturnInfo['message'] = 'Invalid group ID '.$data;
			break;
		case 200:
			$apiReturnInfo['message'] = 'No such user '.$data;
			break;
		case 250:
			$apiReturnInfo['message'] = 'You must send a password for the account '.$data;
			break;
		case 251:
			$apiReturnInfo['message'] = 'This is the wrong password for account '.$data;
			break;
		case 252:
			$apiReturnInfo['message'] = 'Group not found '.$data;
			break;
		case 253:
			$apiReturnInfo['message'] = 'Wrong password';
			break;
		default:
			$apiReturnInfo['message'] = 'Unknown error';
			break;
	}
	// Write out the error to the log (we probably don't know the orderRef, but if we do, include it)
	$logMessage = 'returnError '.$errCode.': '.$apiReturnInfo['message'];
	//if (isset($apiInformation->orderRef)) {
	//	$logMessage.= ' orderRef='.$apiInformation->orderRef;
	//}
	AbstractService::$debugLog->err($logMessage);

	$dbDetails = new DBDetails($GLOBALS['dbHost']);
	$apiReturnInfo['dsn'] = $dbDetails->getDetails();
	$apiReturnInfo['dbHost'] = $GLOBALS['dbHost'];

	echo json_encode($apiReturnInfo);
	exit(0);
}
/*
 * Action for the script
 */
// Load the passed data
try {
	// Read and validate the data
	// This will return an array of login requests
	$apiInformation = loadAPIInformation();
	AbstractService::$debugLog->info("api=".$apiInformation->toString());

	switch ($apiInformation->method) {

        // The following signs the user in fully, with authentication
        case 'authenticateUser':

            // Login needs rootID rather than prefix
            if (!$apiInformation->rootID)
                $apiInformation->rootID = $thisService->getRootIDFromPrefix($apiInformation);
            $user = $thisService->login($apiInformation->name, $apiInformation->password, $apiInformation->rootID);
            AbstractService::$debugLog->info("got user id = " . $user->userID);
            if ($user==false) {
                // Return the key information you used to search
                switch ($apiInformation->loginOption) {
                    case 1:
                        $key = $apiInformation->name;
                        break;
                    case 2:
                        $key = $apiInformation->studentID;
                        break;
                    case 128:
                        $key = $apiInformation->email;
                        break;
                    default:
                        $key = "unknown login option ".$apiInformation->loginOption;
                }
                returnError(200, $key);
            }
            break;

		default:
			returnError(1, 'Invalid method '.$apiInformation->method);
	}

	// Send back data.
	// It might be better to only send back limited account data
	// BUG: No, I need lots of data for working out if titles are not expired etc
	if (!isset($account) || !$account)
		$account = new Account();
	if (!isset($group) || !$group)
		$group = new Group();
		
	$returnInfo = array('user' => $user, 'account' => $account, 'group' => $group);

    // gh#1171
    if ($apiInformation->encryptData)
        $returnInfo['encryptedData'] = $apiInformation->toEncryptedString();
    if ($subscription)
        $returnInfo['subscription'] = $subscription;

    // gh#1275 Send back the session id this authentication was done under
    $returnInfo['sessionId'] = session_id();

	echo json_encode($returnInfo);
	
} catch (Exception $e) {
	// Lets assume that we are generating plain text
	returnError(1, $e->getMessage());
}
flush();
exit(0);