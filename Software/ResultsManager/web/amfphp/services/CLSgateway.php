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
 * You send it a JSON object in POST data
 * 
 * Methods:
 * saveSubscriptionDetails
 * This is used when you have collected information about the purchase and purchaser and simply
 * want to save that data. It puts as much information as it can into the subscription table
 * and gives you back an id to that table.
 * mandatory input: name, email, offerID, resellerID
 * optional input: country, startDate, orderRef, discountCode, password, status (and anything else in subscription)
 * returns: subscriptionID
 * 
 *  udpateSubscriptionStatus
 *  This is used as you move through the purchase process to keep track of latest successful stage
 *  mandatory input: subscriptionID, status
 * returns: subscriptionID
 * 
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
	
	$inputData = file_get_contents("php://input");
	//$inputData = '{"method":"addSubscription","transactionTest":"false","name":"Momi Rahima","country":"Hong Kong","email":"mimi.rahima.24@clarityenglish.com","offerID":59,"languageCode":"EN","productVersion":"R2IHU","resellerID":21,"password":"sweetcustard","orderRef":"201300001","emailTemplateID":"ieltspractice_welcome","paymentMethod":"credit card","loginOption":128,"status":"initial"}';
	//$inputData = '{"method":"addSubscription","subscriptionID":1020,"emailTemplateID":"ieltspractice_welcome","paymentMethod":"credit card","loginOption":128}';
	//$inputData = '{"method":"saveSubscriptionDetails","email":"douglas.engelbert.24@clarityenglish.com","name":"Douglas Engelbert","country":"Hong Kong","languageCode":"EN","productVersion":"R2IHU","resellerID":21,"orderRef":"201200085","password":"sweetcustard","offerID":59,"status":"initial"}';
	//$inputData = '{"method":"updateSubscriptionStatus","subscriptionID":1040,"status":"paid"}';
	//$inputData = '{"method":"updateSubscription","subscriptionID":"3705","emailTemplateID":"ieltspractice_renew","paymentMethod":"paypal"}';
	$postInformation= json_decode($inputData, true);	
	if (!$postInformation) 
		// TODO. Ready for PHP 5.3
		//throw new Exception("Error decoding data: ".json_last_error().': '.$inputData);
		throw new Exception('Error decoding data: '.$inputData);
	
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
			
		if (!isset($postInformation['resellerID'])) 
			throw new Exception("No resellerID has been sent");
			
	}
			
	$api = new SubscriptionApi();
	$api->createFromSentFields($postInformation);
	// gh#1210
	if (isset($postInformation['prefix'])){
		$api->prefix = $postInformation['prefix'];
	}	
	
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
			$apiReturnInfo['message'] = 'Unknown error'.$data;
			break;
	}
	// Write out the error to the log (we probably don't know the orderRef, but if we do, include it)
	$logMessage = 'returnError '.$errCode.': '.$apiReturnInfo['message'];
	if (isset($apiInformation->subscription->orderRef)) {
		$logMessage.= ' orderRef='.$apiInformation->subscription->orderRef;
	}
	AbstractService::$debugLog->err($logMessage);
	
	$apiReturnInfo['dsn'] = $GLOBALS['db'];
	$apiReturnInfo['dbHost'] = $GLOBALS['dbHost'];

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
	if ($GLOBALS['dbHost'] != $apiInformation->dbHost)
		$dmsService->changeDb($apiInformation->dbHost);
		
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
				
			$apiReturnInfo = array('subscriptionID' => $apiInformation->subscription->id, 'status' => $apiInformation->subscription->status);
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
				if ($rs->RecordCount() == 1){
					$dbObj = $rs->FetchNextObj();
					$subscriptionData->fromDatabaseObj($dbObj);
				} else {
					returnError(1, 'No such subscription ID '.$apiInformation->subscription->id);
				}
								
				$apiInformation->subscription = $subscriptionData;
				
			// If we didn't, then assume that this is the first time CLS has been called for this
			// transaction, and write a subscription record
			} else {
				
				$apiInformation->subscription->id = $dmsService->subscriptionOps->saveSubscription($apiInformation);
			}

			// TODO. I think that this is all too much work for the gateway, it should be pushed to a CLSService
			$rc = $dmsService->subscriptionOps->validateAPIInformation($apiInformation);
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
				$dmsService->subscriptionOps->saveAccount($account, $apiInformation);
				
				// make the root of the changed account explicit in the log
				AbstractService::$log->setRootID($account->id);
				AbstractService::$log->notice("Created CLS subscription=".$account->name.", sub id=".$apiInformation->subscription->id.', for reseller='.$apiInformation->subscription->resellerID);
				
			} else {
				AbstractService::$debugLog->warning("skip saving account and subscription for ".$account->name);
			}
			$apiInformation->subscription->status = 'Account created';
			$apiInformation->subscription->rootID = $account->id;
			$dmsService->subscriptionOps->updateSubscriptionStatus($apiInformation);
				
			// If they want an email sent, do that
			if (isset($apiInformation->emailTemplateID) && $apiInformation->emailTemplateID!='') {
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
			
		case "updateSubscription":
			// If we received a subscription ID, then pick up data from the table using that as a key
			if ($apiInformation->subscription->id) {
				
				$subscriptionData = new Subscription();
				$sql = <<<EOD
				SELECT * FROM T_Subscription
				WHERE F_SubscriptionID = ?
EOD;
				$bindingParams = array($apiInformation->subscription->id);
				$rs = $dmsService->db->Execute($sql, $bindingParams);
				if ($rs->RecordCount() == 1){
					$dbObj = $rs->FetchNextObj();
					$subscriptionData->fromDatabaseObj($dbObj);
				} else {
					returnError(1, 'No such subscription ID '.$apiInformation->subscription->id);
				}
								
				$apiInformation->subscription = $subscriptionData;
				
			// If we didn't, it is an error
			} else {
				returnError(1, 'No subscription ID passed');
			}

			
			// get the account (this relies on the method name having 'update' in it !)
			$account = $dmsService->subscriptionOps->getAccountDetails($apiInformation);
			if (!$account)
				returnError(1, 'No account for '.$apiInformation->email);
			
			// Update the titles in this account
			$oldExpiryDate = $account->titles[0]->expiryDate;
			$dmsService->subscriptionOps->addTitlesToAccount($account, $apiInformation);
			$newExpiryDate = $account->titles[0]->expiryDate;
			
			// Then add or update the account (skip if just testing)
			if (!$apiInformation->transactionTest) {
				$dmsService->subscriptionOps->saveAccount($account, $apiInformation);
				
				// make the root of the changed account explicit in the log
				AbstractService::$log->setRootID($account->id);
				AbstractService::$log->notice("Renewed CLS subscription=".$account->name." until $newExpiryDate, sub id=".$apiInformation->subscription->id.', for reseller='.$apiInformation->subscription->resellerID);
				
			} else {
				AbstractService::$debugLog->warning("skip actually renewing for ".$account->name);
			}
			$apiInformation->subscription->status = 'Account updated';
			$apiInformation->subscription->rootID = $account->id;
			$dmsService->subscriptionOps->updateSubscriptionStatus($apiInformation);
				
			// If they want an email sent, do that
			if (isset($apiInformation->emailTemplateID) && $apiInformation->emailTemplateID!='') {
				$dmsService->subscriptionOps->sendEmail($account, $apiInformation);
				AbstractService::$debugLog->info("sent email to ".$account->adminUser->email.' using '.$apiInformation->emailTemplateID);
			}
		
			// TODO: Whilst we log the new account, we should also send our accounts team an email
			if (!$apiInformation->transactionTest) {
				$emailTemplateID = 'CLSgateway_accounts_notification';
				$dmsService->subscriptionOps->sendAccountsEmail($apiInformation, $emailTemplateID);
			}
					
			$apiReturnInfo = array('account' => $account,
								'subscriptionID' => $apiInformation->subscription->id, 
								'password' => $account->adminUser->password, 
								'orderRef' => $apiInformation->subscription->orderRef, 
								'CLSreference' => $account->invoiceNumber, 
								'emailSentTo' => $account->adminUser->email, 
								'prefix' => $account->prefix,
								'oldExpiryDate' => $oldExpiryDate, // two additional data get passed for displaying renew_step4_success page
								'newExpiryDate' => $newExpiryDate);
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