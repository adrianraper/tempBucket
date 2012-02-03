<?php
/*
 * This is not really an AMFPHP service but its in this folder to maintain path integrity in all of the require_once calls.
 * Since there are no classes or methods here it does not represent a security risk.
 */

/*
 * The purpose of this script is to run regular queries used for support on the database
 *
 * You send it an XML like object in POST data (or would a name / value string make more sense?)
 * Return a confirmation code to the calling script
 */
//session_id($_GET['PHPSESSID']);

require_once(dirname(__FILE__)."/DMSService.php");

$dmsService = new DMSService();

// Done in config.php
date_default_timezone_set('UTC');

header('Content-Type: text/plain; charset=utf-8');

// Account information will come in JSON format
function loadAPIInformation() {
	global $dmsService;
	
	$postInformation = json_decode(file_get_contents("php://input"), true);	
	global $returnURL;
	
	// First check mandatory fields exist
	if (!isset($postInformation['method'])) {
		throw new Exception("No method has been sent");
	}
	if (!isset($postInformation['id'])) {
		throw new Exception("No id has been sent");
	}
	
	return $postInformation;
}	
function returnError($errCode, $data = null) {
	global $dmsService;
	global $apiInformation;
	$apiReturnInfo = array('error'=>$errCode);
	switch ($errCode) {
		case 1:
			$apiReturnInfo['message'] = 'Exception, '.$data;
			break;
		case 200:
			$apiReturnInfo['message'] = 'Email address already registered, '.$data;
			break;
		case 201:
			$apiReturnInfo['message'] = 'Email/password combination is not correct';
			break;
		case 202:
			$apiReturnInfo['message'] = 'OfferID is not valid, '.$data;
			break;
		case 203:
			$apiReturnInfo['message'] = 'Email/password matches multiple accounts';
			break;
		case 204:
			$apiReturnInfo['message'] = 'ResellerID is not valid, '.$data;
			break;
		case 205:
			$apiReturnInfo['message'] = 'Discount code has been used before, '.$data;
			break;
		case 206:
			$apiReturnInfo['message'] = 'Discount code is not valid, '.$data;
			break;
		case 207:
			// Maybe this isn't an error, but instead we would just add a new record?
			$apiReturnInfo['message'] = 'SubscriptionID is not valid, '.$data;
			break;
		case 100:
			$apiReturnInfo['message'] = 'No such studentID '.$data;
			break;
		default:
			$apiReturnInfo['message'] = 'Unknown error';
			break;
	}
	// Write out the error to the log (we probably don't know the orderRef, but if we do, include it)
	$logMessage = 'returnError '.$errCode.': '.$apiReturnInfo['message'];
	AbstractService::$debugLog->err($logMessage);

	$returnInfo = array_merge($apiReturnInfo);
	echo json_encode($returnInfo);
	exit(0);
}

/*
 * Action for the script
 */
// Load the passed data
try {
	// Read and validate the data
	$apiInformation = loadAPIInformation();
	//AbstractService::$log->notice("calling validate=".$apiInformation->resellerID);
	//echo "loaded API";

	if ($apiInformation['method']=='getGlobalR2IUser') {
		$rc = $dmsService->internalQueryOps->getGlobalR2IUser($apiInformation['id']);
	}
	if ($apiInformation['method']=='updateSessionsForDeletedUsers') {
		$rc = $dmsService->internalQueryOps->updateSessionsForDeletedUsers($apiInformation['rootID']);
	}
	if ($apiInformation['method']=='findEmail') {
		$rc = $dmsService->internalQueryOps->findEmail($apiInformation['email']);
	}
	if (isset($rc['errCode']) && intval($rc['errCode']) > 0) {
		returnError($rc['errCode'], $rc['data']);
	}
	
	// Send back success variables
	//$apiReturnInfo = array('user' => $user);
	// Also send back any variables that you were sent, but don't understand
	//$returnInfo = array_merge($apiReturnInfo);
	echo json_encode($rc);
	
} catch (Exception $e) {
	// Lets assume that we are generating plain text
	returnError(1, $e->getMessage());
}
flush();
exit(0)
?>