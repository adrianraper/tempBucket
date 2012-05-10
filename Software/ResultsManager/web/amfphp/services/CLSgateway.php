<?php
/*
 * This script is a gateway for purchasing subscription functions
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
require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/account/SubscriptionApi.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/account/Subscription.php");

$dmsService = new DMSService();
$nonApiInformation = array();

// Core function is to read the data from the API, check account and add titles

// Account information will come in JSON format
function loadAPIInformation() {
	global $dmsService;
	global $nonApiInformation;
	
	$postInformation= json_decode(file_get_contents("php://input"), true);	
	//$presetString = '{"method":"addSubscription","transactionTest":"false","name":"Mimi Rahima","email":"mimi.rahima@clarityenglish.com","offerID":59,"resellerID":21,"password":"sweetcustard","orderRef":"201100000042","emailTemplateID":"CLS_welcome"}';
	$presetString = '{"method":"saveSubscriptionDetails","email":"adrian.raper@clarityenglish.com","name":"Adrian\'s Raper","country":"Hong Kong","resellerID":24,"orderRef":"12345678","offerID":10,"status":"initial"}';
	//$presetString = '{"method":"updateSubscriptionStatus","subscriptionID":998,"status":"paid"}';
	$postInformation = json_decode($presetString, true);
	
	// We are expecting a method and parameters as an object
	// First check mandatory fields exist
	if (!isset($postInformation['method']))
		throw new Exception("No method has been sent");
		
	// If you send a subscriptionID, you can skip everything else
	if (!isset($postInformation['subscriptionID'])) {
	
		if (!isset($postInformation['name']))
			throw new Exception("No name has been sent");
			
		if (!isset($postInformation['email'])) 
			throw new Exception("No email has been sent");
			
		if (!isset($postInformation['offerID'])) 
			throw new Exception("No offer has been sent");
			
		if (!isset($postInformation['orderRef'])) 
			throw new Exception("No orderRef has been sent");
			
		if (!isset($postInformation['resellerID'])) 
			throw new Exception("No resellerID has been sent");
			
	}
			
	$api = new SubscriptionAPI();
	$api->createFromSentFields($postInformation);
	
	// Rather than jam up the database, I will do this with files I think. Then need to clear them out regularly.
	//AbstractService::$debugLog->info("loadAPIInformation=".$api->toString());
	
	// Can you pick up and save anything you weren't expecting so you can just return it back?
	$nonApiInformation = $api->unknownFields($postInformation);
	
	return $api;
	
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
	
	// You might want a different dbHost which you have now got - so override the settings from config.php
	$dbDetails = new DBDetails($apiInformation->dbHost);
	$GLOBALS['dbms'] = $dbDetails->driver;
	$GLOBALS['db'] = $dbDetails->driver.'://'.$dbDetails->user.':'.$dbDetails->password.'@'.$dbDetails->host.'/'.$dbDetails->dbname;
	
	switch ($apiInformation->method) {
		
		// Called to simply save a set of details in our table. Most likely to be called
		// before we send details to payment gateway to help us recover later.
		case "saveSubscriptionDetails":
			$apiInformation->subscription->id = $dmsService->subscriptionOps->saveSubscription($apiInformation);
			
			if (!$apiInformation->subscription->id)
				returnError(1, 'Subscription details not saved '.$apiInformation->toString());
			
			$apiReturnInfo = array('subscriptionID' => $apiInformation->subscription->id);
			break;
			
		case "updateSubscriptionStatus":
			$rc = $dmsService->subscriptionOps->updateSubscriptionStatus($apiInformation);
			
			if (!$rc)
				returnError(1, 'Subscription status not udpated '.$apiInformation->toString());
				
			$apiReturnInfo = array('subscriptionID' => $apiInformation->subscription->id);
			break;
			
		case "addSubscription":
			
			// If we received a subscription ID, then pick up data from the table using that as a key
			if ($apiInformation->subscription->id) {
				
				$subscriptionData = new Subscription();
				$sql = <<<EOD
				SELECT * FROM T_Subscription
				WHERE F_SubscriptionID = ?
EOD;
				$bindingParams = array($apiInformation->subscription->id);
				$rs = $dmsService->db->Execute($sql, $bindingParams);
				if ($rs->RecordCount() == 1)
					$subscriptionData->fromDatabaseObj($dbObj);
								
				$apiInformation->subscription = $subscriptionData;
			} 
			
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
		
			// Then add or update the account (skip if just testing)
			if (!$apiInformation->transactionTest) {
				$dmsService->subscriptionOps->saveAccount($account);
				
				// make the root of the changed account explicit in the log
				AbstractService::$log->setRootID($account->id);
				AbstractService::$log->notice("Created CLS subscription=".$account->name.", sub id=".$apiInformation->subscription->id.', for reseller='.$apiInformation->subscription->resellerID);
				
			} else {
				AbstractService::$debugLog->warning("skip saving account and subscription for ".$account->name);
			}
			$apiInformation->subscription->status = 'Account created';
			$dmsService->subscriptionOps->updateSubscriptionStatus($apiInformation);
				
			// If they want an email sent, do that
			if (isset($apiInformation->emailTemplateID) && $apiInformation->emailTemplateID!='') {
				//AbstractService::$log->notice("call sendEmail for ".$apiInformation->sendEmail);
				$dmsService->subscriptionOps->sendEmail($account, $apiInformation);
				AbstractService::$debugLog->info("sent email to ".$account->adminUser->email.' using '.$apiInformation->emailTemplateID);
			}
		
			// TODO: Whilst we log the new account, we should also send our accounts team an email
			if (!$apiInformation->transactionTest) {
				$emailTemplateID = 'CLSgateway_accounts_notification';
				$dmsService->subscriptionOps->sendAccountsEmail($apiInformation, $emailTemplateID);
			}
			
			// If there is any other processing for specific resellers/offers etc, do that here
			if (!$apiInformation->transactionTest) {
				switch ($apiInformation->subscription->resellerID) {
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
			// I would rather send back the account object, but the API is expecting individual bits
			// I could pass account as well and then phase out the others...
			$apiReturnInfo = array('account' => $account,
								'subscriptionID' => $apiInformation->subscription->id, 
								'password' => $account->adminUser->password, 
								'orderRef' => $apiInformation->subscription->orderRef, 
								'CLSreference' => $account->invoiceNumber, 
								'emailSentTo' => $account->adminUser->email, 
								'prefix' => $account->prefix);

			break;
		default:
			returnError(1, 'Invalid method '.$apiInformation->method);
						
	}
	// Also send back any variables that you were sent, but don't understand
	$returnInfo = array_merge($apiReturnInfo, $nonApiInformation);
	
	echo json_encode($returnInfo);
	
} catch (Exception $e) {
	// Lets assume that we are generating plain text
	returnError(1, $e->getMessage());
}
flush();
exit(0);