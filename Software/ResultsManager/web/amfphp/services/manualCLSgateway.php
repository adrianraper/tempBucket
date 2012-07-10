<?php
/*
 * This script is a gateway for purchasing subscription functions
 * This manual version is for running to actually create accounts when the automatic version has failed.
 * See the different cases described for $inputData below and change as you need.
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
	
	//$inputData = file_get_contents("php://input");
	//$inputData = '{"method":"addSubscription","transactionTest":"false","name":"Mimi Rahima","email":"mimi.rahima.22@clarityenglish.com","offerID":59,"languageCode":"R2IHU","resellerID":21,"password":"sweetcustard","orderRef":"201200085","emailTemplateID":"ieltspractice_welcome","paymentMethod":"credit card","loginOption":128}';
	//$inputData = '{"method":"saveSubscriptionDetails","email":"douglas.engelbert.2@clarityenglish.com","name":"Douglas Engelbert","country":"Hong Kong","languageCode":"R2IHU","resellerID":21,"orderRef":"201200085","password":"sweetcustard","offerID":59,"status":"initial"}';
	//$inputData = '{"method":"updateSubscriptionStatus","subscriptionID":1034,"status":"paid"}';
	/**
	 * If you have the subscription ID from the table, you can use the following input. 
	 * EmailTemplateID, paymentMethod andloginOption all need to be sent, you are unlikely to need to change them.
	 */
	$inputData = '{"method":"addSubscription","subscriptionID":1758,"emailTemplateID":"ieltspractice_welcome","paymentMethod":"credit card","loginOption":128}';
	
	/**
	 * If you are creating an account from scratch, use the the following input. 
	 * EmailTemplateID, paymentMethod andloginOption all need to be sent, you are unlikely to need to change them.
	 */
	//$inputData = '{"method":"addSubscription","transactionTest":"false","name":"Mimi Rahima","email":"mimi.rahima.23@clarityenglish.com","offerID":59,"languageCode":"R2IHU","resellerID":21,"password":"sweetcustard","orderRef":"201200085","emailTemplateID":"ieltspractice_welcome","paymentMethod":"credit card","loginOption":128}';
	
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
	if (isset($apiInformation->subscription->orderRef)) {
		$logMessage.= ' orderRef='.$apiInformation->subscription->orderRef;
	}
	AbstractService::$debugLog->err($logMessage);

	$returnInfo = array_merge($apiReturnInfo, $nonApiInformation);
	echo json_encode($returnInfo);
	exit(0);
}

/*
 * Action for the script
 */
try {
	if (!Authenticate::isAuthenticated())
		throw new Exception("Please login to DMS first for authentication.");
		
	// Load the passed data
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
				$dmsService->subscriptionOps->saveAccount($account);
				
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