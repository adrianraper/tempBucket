<?php
/*
 * This script is a gateway for login functions
 */

require_once(dirname(__FILE__)."/LoginService.php");

// Shouldn't all the following be in LoginService?
// All done in TemplateOps
/*
require_once($GLOBALS['smarty_libs']."/Smarty.class.php");
$smarty = new Smarty();
$smarty->template_dir = $GLOBALS['smarty_template_dir'];
$smarty->compile_dir = $GLOBALS['smarty_compile_dir'];
$smarty->config_dir = $GLOBALS['smarty_config_dir'];
$smarty->cache_dir = $GLOBALS['smarty_cache_dir'];
$smarty->plugins_dir[] = $GLOBALS['smarty_plugins_dir'];
*/

$loginService = new LoginService();

// API information will come in JSON format
function loadAPIInformation() {
	global $loginService;
	
	$postInformation = json_decode(file_get_contents("php://input"), true);
	//$presetString = '{"method":"getOrAddUser","studentID":"1217-0552-6017","name":"Adrian Raper","email":"support@ieltspractice.com","city":"Hong Kong","dbHost":2,"productCode":52,"expiryDate":"2012-04-15 23:59:59","rootID":10943,"prefix":"BCHK","groupID":"170","loginOption":2,"userType":0}';
	//$presetString = '{"method":"getOrAddUser","studentID":"J0655013-170","name":"Vishna Vardhan Kompalli","email":"06.vishnu@gmail.com","dbHost":"2","productCode":52,"expiryDate":"2012-03-19 23:59:59","prefix":"BCHK","rootID":"10943","groupID":"170","loginOption":"2"}';
	//$presetString = '{"method":"getOrAddUser","studentID":"P10102928-170","name":"dandelion","email":"adrian@clarityenglish.com","dbHost":101,"productCode":52,"expiryDate":"2012-02-19 23:59:59","prefix":"TEST","rootID":"14028","groupID":"22153","loginOption":"2","emailTemplateID":"BCHK-welcome"}';
	//$presetString = '{"method":"getOrAddUser","studentID":"P10102928-170","name":"RAPER, Adrian","dbHost":2,"custom1":"Basic","custom2":"IMD","prefix":"CSTDI","loginOption":"8"}';
	//$presetString = '{"method":"getOrAddUser","studentID":"1217-0552-6019-170","name":"Adrian early bird","password":"G&amp;T;","email":"adrian@clarity.com.hk","groupID":"170","productCode":"52","subscriptionPeriod":"3months","emailTemplate":"Welcome-BCHK-user","dbHost":102,"loginOption":2}';
	//$presetString = '{"method":"getUser","studentID":"P10102920-170","groupID":"170","dbHost":102,"loginOption":"2"}';
	//$postInformation = json_decode($presetString, true);

	// We are expecting a method and parameters as an object
	// First check mandatory fields exist
	if (!isset($postInformation['method'])) {
		throw new Exception("No method has been sent");
	}
	$apiInformation = new LoginAPI();
	$apiInformation->createFromSentFields($postInformation);
	return $apiInformation;
}
	
function returnError($errCode, $data = null) {
	global $loginService;
	global $apiInformation;
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
	// This will return an array of login requests
	$apiInformation = loadAPIInformation();
	AbstractService::$debugLog->info("api=".$apiInformation->toString());
	//echo "loaded API";
	
	// You might want a different dbHost which you have now got - so override the settings from config.php
	$dbDetails = new DBDetails($apiInformation->dbHost);
	$GLOBALS['dbms'] = $dbDetails->driver;
	$GLOBALS['db'] = $dbDetails->driver.'://'.$dbDetails->user.':'.$dbDetails->password.'@'.$dbDetails->host.'/'.$dbDetails->dbname;
	
	switch ($apiInformation->method) {
		case 'getUser':
			
			// TODO: First validate the account that you are going to get from
			// This probably goes outside the switch, but you might skip it if you
			// don't know an account and are doing a global getUser.
			/*
			if ($apiInformation->rootID || $apiInformation->prefix) {
				$account = $loginService->getAccount($apiInformation);
				if ($account==false) {
					returnError(1, 'No such account');
				}
			}			
			*/
			$user = $loginService->getUser($apiInformation);
			
			if ($user==false) {
				returnError(200, $apiInformation->studentID);
			}
			
			// If you find a user you might want account information to be returned
			if (!$apiInformation->prefix && !$apiInformation->rootID)
				$account = $loginService->getAccountFromGroup($loginService->getGroup($apiInformation));
			
			break;
			
		case 'getOrAddUser':
			$user = $loginService->getUser($apiInformation);
			
			// If you are using just a group to add user, need to get rootID now
			if (!$apiInformation->prefix && !$apiInformation->rootID) {
				$account = $loginService->getAccountFromGroup($loginService->getGroup($apiInformation));
				$apiInformation->rootID = $account->id;
			} else if (!$apiInformation->rootID) {
				$account = $loginService->getAccountFromPrefix($apiInformation->prefix);
				$apiInformation->rootID = $account->id;
			}
			
			if ($user==false) {
				$group = $loginService->getGroup($apiInformation);
				if ($group==false)
					returnError(210, $apiInformation->groupID);
					
				$user = $loginService->addUser($apiInformation, $group);
				AbstractService::$debugLog->info("added new user ".$user->name." expire on ".$user->expiryDate);
				
				// If we want to send an email on adding a new user, do it here
				if ($apiInformation->emailTemplateID) {
					$loginService->subscriptionOps->sendUserEmail($user, $apiInformation);
					AbstractService::$debugLog->info("sent email to ".$user->email.' using '.$apiInformation->emailTemplateID);
				}
			} else {
				AbstractService::$debugLog->info("returned existing user ".$user->name." expires on ".$user->expiryDate);
			}
			
			break;
			
		default:
			returnError(1, 'Invalid method '.$apiInformation->method);
	}

	// Send back data.
	// It might be better to only send back limited account data
	if ($account) {
		$limitedAccount = new Account();
		$limitedAccount->prefix = $account->prefix;
		$limitedAccount->id = $account->id;
		$limitedAccount->name = $account->name;
	}
	$returnInfo = array('user' => $user, 'account' => $limitedAccount); 
	
	echo json_encode($returnInfo);
	
} catch (Exception $e) {
	// Lets assume that we are generating plain text
	returnError(1, $e->getMessage());
}
flush();
exit(0);