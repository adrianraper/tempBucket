<?php
/*
 * This is not really an AMFPHP service but its in this folder to maintain path integrity in all of the require_once calls.
 * Since there are no classes or methods here it does not represent a security risk.
 */

/*
 * The purpose of this script is to be the main API for CLS.com
 * Anybody can call this script to 
 *		add a new account and subscription
 *		update an existing account with a new subscription
 *
 * You send it an XML like object in POST data (or would a name / value string make more sense?)
 * It will a) check the validity of the name / email / password combination
 * Add a new account if necessary
 * Decode the offer to find out what titles to add and for what periods
 * Add / update the accounts and check sum them
 * Send an email to the customer using the, optional, passed templatedID
 * Return a confirmation code to the calling script
 */

require_once(dirname(__FILE__)."/DMSService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/account/ApiInformation.php");

$dmsService = new DMSService();
$nonApiInformation = array();

// Done in config.php
//session_start();
date_default_timezone_set('UTC');

header('Content-Type: text/plain; charset=utf-8');

if (!Authenticate::isAuthenticated()) {
	// v3.1 This script requires authentication of some sort so that it can only be run
	// by validated resellers. How? Can we insist you are called from a pre-specified https URL?
	// This is critical because this is a powerful script!
}

// Core function is to read the data from the API, check account and add titles

// Account information will come in JSON format
function loadAPIInformation() {
	global $dmsService;
	global $nonApiInformation;
	
	$postInformation= json_decode(file_get_contents("php://input"), true);	
	global $returnURL;
	
	// First check mandatory fields exist
	if (!isset($postInformation['method'])) {
		throw new Exception("No method has been sent");
	}
	if (!isset($postInformation['name'])) {
		throw new Exception("No name has been sent");
	}
	if (!isset($postInformation['email'])) {
		throw new Exception("No email has been sent");
	}
	if (!isset($postInformation['offerID'])) {
		throw new Exception("No offer has been sent");
	}
	if (!isset($postInformation['orderRef'])) {
		throw new Exception("No orderRef has been sent");
	}
	if (!isset($postInformation['resellerID'])) {
		throw new Exception("No resellerID has been sent");
	}
	$apiInformation = new ApiInformation();
	$apiInformation->createFromSentFields($postInformation);
	//echo $apiInformation->toString().'<br/>';
	// Rather than jam up the database, I will do this with files I think. Then need to clear them out regularly.
	AbstractService::$debugLog->info("loadAPIInformation=".$apiInformation->toString());
	
	// Can you pick up and save anything you weren't expecting so you can just return it back?
	$nonApiInformation = $apiInformation->unknownFields($postInformation);
	
	return $apiInformation;
	
}	
function returnError($errCode, $data = null) {
	global $dmsService;
	global $apiInformation;
	global $nonApiInformation;
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
		default:
			$apiReturnInfo['message'] = 'Unknown error';
			break;
	}
	// Write out the error to the log (we probably don't know the orderRef, but if we do, include it)
	$logMessage = 'returnError '.$errCode.': '.$apiReturnInfo['message'];
	if (isset($apiInformation->orderRef)) {
		$logMessage.= ' orderRef='.$apiInformation->orderRef;
	}
	AbstractService::$debugLog->err($logMessage);

	$returnInfo = array_merge($apiReturnInfo, $nonApiInformation);
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
	$rc = $dmsService->subscriptionOps->validateAPIInformation($apiInformation);
	if (isset($rc['errCode']) && parseInt($rc['errCode']) > 0) {
		returnError($rc['errCode'], $rc['data']);
	}
	//AbstractService::$log->notice("validateAPIInformation=".$apiInformation->sendEmail);
	// Check the account. This will either return an existing account, or will create a new object (without putting it in the database)
	$account = New Account();
	$account = $dmsService->subscriptionOps->getAccountDetails($apiInformation);
	//AbstractService::$debugLog->info("account created/found ".$account->name);
	//echo 'found existing account '.$account->name.' which has '.count($account->titles).' titles';

	// Add the titles to this account
	$dmsService->subscriptionOps->addTitlesToAccount($account, $apiInformation);

	// Then add or update the account and subscription records (allow to skip like emails for testing)
	if (!$apiInformation->transactionTest) {
		//AbstractService::$log->notice("call saveAccount for ".$account->adminUser->email);
		$dmsService->subscriptionOps->saveAccount($account, $apiInformation);
		//AbstractService::$log->notice("call saveSubscription for ".$apiInformation->orderRef);
		$dmsService->subscriptionOps->saveSubscription($account, $apiInformation);
	} else {
		AbstractService::$debugLog->warning("skip saving account and subscription for ".$account->name);
	}

	// If they want an email sent, do that
	if (!$apiInformation->transactionTest && (isset($apiInformation->emailTemplateID) && $apiInformation->emailTemplateID!='')) {
		//AbstractService::$log->notice("call sendEmail for ".$apiInformation->sendEmail);
		$dmsService->subscriptionOps->sendEmail($account, $apiInformation);
		AbstractService::$debugLog->info("sent email to ".$account->adminUser->email.' using '.$apiInformation->emailTemplateID);
	} else {
		AbstractService::$debugLog->warning("skip sending email to ".$account->adminUser->email);
	}

	// TODO: Whilst we log the new account, we should also send our accounts team an email
	if (!$apiInformation->transactionTest) {
		$emailTemplateID = 'CLSgateway_accounts_notification';
		$dmsService->subscriptionOps->sendAccountsEmail($apiInformation, $emailTemplateID);
	}
	
	// If there is any other processing for specific resellers/offers etc, do that here
	if (!$apiInformation->transactionTest) {
		switch ($apiInformation->resellerID) {
			// First case is iLearnIELTS triggers an email to DHL for package delivery
			case 27: 
				$to = 'iLearnIELTS@dhl.com';
				//$to = 'support@iLearnIELTS.com';
				$emailTemplateID = 'ilearnIELTS_DHL_notification';
				// How to create an Excel like attachment that includes the address details?
				// Smarty can surely create a file easily? Actually, rmail will turn a string into an attached file without me doing anything
				// Careful: Case sensitive
				$csvTemplateID = 'ilearnIELTS_DHL_csv';
				//$fileName = time().'.csv'; // A unique filename
				//echo "file is $fileName<br/>";
				//$attachment = $dmsService->subscriptionOps->createFile($fileName, $apiInformation, $csvTemplateID);
				$attachment = $dmsService->subscriptionOps->createCSV($apiInformation, $csvTemplateID, true);
				
				// Send the email with attachment
				//$dmsService->subscriptionOps->sendSupplierEmail($to, $emailTemplateID, $apiInformation, $attachment, $apiInformation->sendEmail);
				//AbstractService::$log->notice("call sendSupplierEmail for ".$to);
				$dmsService->subscriptionOps->sendSupplierEmail($to, $emailTemplateID, $apiInformation, $attachment);
				AbstractService::$debugLog->info("sent email to ".$to.' using '.$emailTemplateID);
				break;
				
			// For Edict, simply send them an email
			case 24:
				$to = 'info@edict.com.my';
				$emailTemplateID = 'Gateway_notification';
				$dmsService->subscriptionOps->sendSupplierEmail($to, $emailTemplateID, $apiInformation);
				AbstractService::$debugLog->info("sent email to ".$to.' using '.$emailTemplateID);
				break;
			default:
				break;
		}
	}
	
	// Send back success variables
	$apiReturnInfo = array('password' => $account->adminUser->password, 
						'orderRef' => $apiInformation->orderRef, 
						'CLSreference' => $account->invoiceNumber, 
						'emailSentTo' => $account->adminUser->email.', '.$account->email, 
						'subscriptionID' => $apiInformation->subscriptionID, 
						'prefix' => $account->prefix);
	// Also send back any variables that you were sent, but don't understand
	$returnInfo = array_merge($apiReturnInfo, $nonApiInformation);
	echo json_encode($returnInfo);
	
} catch (Exception $e) {
	// Lets assume that we are generating plain text
	returnError(1, $e->getMessage());
}
flush();
exit(0)
?>