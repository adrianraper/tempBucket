﻿<?php
/*
 * This script will send an email based on passed parameters only.
 */

require_once(dirname(__FILE__)."/EmailService.php");

$emailService = new EmailService();

// Try overriding the defaults to see if I can send email from Rackspace
// Yes this does work. If I change the password I get AUTH command failed: 5.7.8 Error: authentication failed: UGFzc3dvcmQ6
// Put this up into config.php.

// API information will come in JSON format
// What happens if I want to send an array of emails? And what if I use EmailAPI to prepare them?
function loadAPIInformation() {
	global $emailService;
	
	$inputData = file_get_contents("php://input");
	$inputData = '[{"method":"sendEmail", "from":"adrian.raper@clarityenglish.com", "to":"adrian@noodles.hk", "templateID":"GlobalR2I-registration", "data":{"name":"Adrian&apos;s Raper bean", "password":"1234"}, "transactionTest":false}]';

	$postInformation= json_decode($inputData, true);
	//echo $postInformation; exit();
	
	if (!$postInformation) 
		// TODO. Ready for PHP 5.3
		//throw new Exception("Error decoding data: ".json_last_error().': '.$inputData);
		throw new Exception('Error decoding data: '.': '.$inputData);	
	
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
	foreach ($apiInformation as $emailItem) {
		switch ($emailItem->method) {
			case "sendEmail":
				$rc = $emailService->emailOps->sendDirectEmail($emailItem);
				break;
				
			default:
				returnError(1, 'Invalid method '.$apiInformation->method);
		}
	}
	
	// Send back success variables.
	$returnInfo = array('success' => true, 'count' => count($apiInformation)); 
	echo json_encode($returnInfo);
	
} catch (Exception $e) {
	// Lets assume that we are generating plain text
	returnError(1, $e->getMessage());
}
flush();
exit(0);
