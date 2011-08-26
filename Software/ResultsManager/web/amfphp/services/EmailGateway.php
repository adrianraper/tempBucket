<?php
/*
 * This script will send an email based on passed parameters only.
 */

require_once(dirname(__FILE__)."/EmailService.php");

// Shouldn't all the following be in EmailService?
require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/trigger/EmailAPI.php");
require_once($GLOBALS['smarty_libs']."/Smarty.class.php");
$smarty = new Smarty();
$smarty->template_dir = $GLOBALS['smarty_template_dir'];
$smarty->compile_dir = $GLOBALS['smarty_compile_dir'];
$smarty->config_dir = $GLOBALS['smarty_config_dir'];
$smarty->cache_dir = $GLOBALS['smarty_cache_dir'];
$smarty->plugins_dir[] = $GLOBALS['smarty_plugins_dir'];

$emailService = new EmailService();
session_start();
date_default_timezone_set('UTC');

// Try overriding the defaults to see if I can send email from Rackspace
// Yes this does work. If I change the password I get AUTH command failed: 5.7.8 Error: authentication failed: UGFzc3dvcmQ6
// Put this up into config.php.

// API information will come in JSON format
// What happens if I want to send an array of emails? And what if I use EmailAPI to prepare them?
function loadAPIInformation() {
	global $emailService;
	//global $nonApiInformation;
	//What's this?
	//global $returnURL;
	
	$postInformation = json_decode(file_get_contents("php://input"), true);	
	// We are expecting an array of emails
	$emailArray = array();
	foreach ($postInformation as $emailItem) {
	
		// First check mandatory fields exist
		// TODO: Rather than throw an exception, it might be nicer to have an error item for each email in the array
		if (!isset($emailItem['method'])) {
			throw new Exception("No method has been sent");
		}
		if (!isset($emailItem['to'])) {
			throw new Exception("No to has been sent");
		}
		if (!isset($emailItem['templateID'])) {
			throw new Exception("No templateID has been sent");
		}
		$apiInformation = new EmailAPI();
		$apiInformation->createFromSentFields($emailItem);
		$emailArray[] = $apiInformation;
	}	
	//return $apiInformation;
	return $emailArray;
}	
function returnError($errCode, $data = null) {
	global $emailService;
	global $apiInformation;
	$apiReturnInfo = array('error'=>$errCode);
	switch ($errCode) {
		case 1:
			$apiReturnInfo['message'] = 'Exception, '.$data;
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

	echo json_encode($apiReturnInfo);
	exit(0);
}
/*
 * Action for the script
 */
// Load the passed data
try {
	// Read and validate the data
	// This will return an array of emails
	$apiInformation = loadAPIInformation();
	//AbstractService::$log->notice("calling validate=".$apiInformation->resellerID);
	//echo "loaded API";
	$rc = $emailService->emailOps->sendDirectEmails($apiInformation);

	// Send back success variables.
	$returnInfo = array('success' => true, 'count' => count($apiInformation)); 
	echo json_encode($returnInfo);
	
} catch (Exception $e) {
	// Lets assume that we are generating plain text
	returnError(1, $e->getMessage());
}
flush();
exit(0);
?>