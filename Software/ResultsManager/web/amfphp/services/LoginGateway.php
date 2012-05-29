<?php
/**
 * This script is a gateway for login functions
 * 
 * TODO: Need to consider authentication as you use this to add to any old account.
 * At least you should pass the admin user password for the account.
 */

require_once(dirname(__FILE__)."/LoginService.php");

$loginService = new LoginService();

// API information will come in JSON format
function loadAPIInformation() {
	global $loginService;
	
	$inputData = file_get_contents("php://input");
	//$inputData = '{"method":"getOrAddUser","studentID":"1217-0552-6017","name":"Adrian Raper","email":"support@ieltspractice.com","city":"Hong Kong","dbHost":2,"productCode":52,"expiryDate":"2012-04-15 23:59:59","rootID":10943,"prefix":"BCHK","groupID":"170","loginOption":2,"userType":0}';
	//$inputData = '{"method":"getOrAddUser","studentID":"J0655013-170","name":"Vishna Vardhan Kompalli","email":"06.vishnu@gmail.com","dbHost":"2","productCode":52,"expiryDate":"2012-03-19 23:59:59","prefix":"BCHK","rootID":"10943","groupID":"170","loginOption":"2"}';
	//$inputData = '{"method":"getOrAddUser","studentID":"P10102928-170","name":"dandelion","email":"adrian@clarityenglish.com","dbHost":101,"productCode":52,"expiryDate":"2012-02-19 23:59:59","prefix":"TEST","rootID":"14028","groupID":"22153","loginOption":"2","emailTemplateID":"BCHK-welcome"}';
	//$inputData = '{"method":"getOrAddUser","studentID":"P10102928-170","name":"RAPER, Adrian","dbHost":2,"custom1":"Basic","custom2":"IMD","prefix":"CSTDI","loginOption":"8"}';
	//$inputData = '{"method":"getOrAddUser","dbHost":2,"prefix":"CSTDI","rootID":14449,"groupID":26271,"city":"Hong Kong","country":"Hong Kong","loginOption":2,"subscriptionPeriod":"1y","adminPassword":"57845612","studentID":"cstdi-1234","name":"RAPER, Adrian","custom1":"100","custom2":"21"}';
	//$inputData = '{"method":"getUser","email":"tandan_shiva@yahoo.com","licenceType":"5","dbHost":102,"loginOption":"8"}';
	//$inputData = '{"method":"getUser","email":"alongworth@stowe.co.uk","licenceType":5,"loginOption":128,"dbHost":20}';
	//$inputData = '{"method":"getUser","email":"alongworth@stowe.co.uk","loginOption":128,"dbHost":20}';
	//$inputData = '{"method":"getOrAddUserAutoGroup", "prefix":"Clarity", "groupName":"Winhoe autogroup 2", "name":"Kima 130","studentID":"winhoe 130", "teacherName":"jessie_teacher", "dbHost":2, "city":"Taichung", "country":"Taiwan", "loginOption":1}';
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
		case 250:
			$apiReturnInfo['message'] = 'You must send a password for the account '.$data;
			break;
		case 251:
			$apiReturnInfo['message'] = 'This is the wrong password for account '.$data;
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
				// Return the key information you used to search
				switch ($apiInformation->loginOption) {
					case 1:
						$key = $apiInformation->userName;
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
			
			// Also return account information for that user
			$apiInformation->userID = $user->id;
			$account = $loginService->getAccountFromGroup($loginService->getGroup($apiInformation));
			
			break;
			
		case 'getOrAddUser':
		case 'getOrAddUserAutoGroup':
			
			// If you are using just a group to add user, need to get rootID now
			// Get the whole account info as well
			if (!$apiInformation->prefix && !$apiInformation->rootID) {
				$account = $loginService->getAccountFromGroup($loginService->getGroup($apiInformation));
				$apiInformation->rootID = $account->id;
			} else if (!$apiInformation->rootID) {
				$account = $loginService->getAccountFromPrefix($apiInformation);
				$apiInformation->rootID = $account->id;
			} else {
				$account = $loginService->getAccountFromRootID($apiInformation);
			}
			
			// Authentication
			if (!isset($apiInformation->adminPassword)) {
				returnError(250, $account->name);
			} else {
				if ($apiInformation->adminPassword != $account->adminUser->password) 
					returnError(251, $account->name);
			}
			
			// Find the user if you can
			$user = $loginService->getUser($apiInformation);
			
			if ($user==false) {
				$group = $loginService->getGroup($apiInformation, $account);
				
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
					
				$user = $loginService->addUser($apiInformation, $group);
				AbstractService::$debugLog->info("added new user ".$user->name." expire on ".$user->expiryDate);
				
				// Autogroup. Check that the teacher exists, and that they are linked to this group 
				if ($apiInformation->method == "getOrAddUserAutoGroup") {
					// Clone some details from the original API and see if the teacher exists
					$teacherAPI = new LoginAPI();
					switch ($apiInformation->loginOption) {
						case 1:
							$teacherAPI->name = $apiInformation->teacherName;
							break;		
						case 2:
							$teacherAPI->studentID = $apiInformation->teacherID;
							break;
						case 128:
							$teacherAPI->email = $apiInformation->teacherEmail;
							break;
					}
					
					$teacherAPI->userType = User::USER_TYPE_TEACHER;
					$teacherAPI->loginOption = $apiInformation->loginOption;
					$teacherAPI->rootID = $apiInformation->rootID;
					$teacher = $loginService->getUser($teacherAPI);
					
					// The teacher must be linked to the group
					// TODO. For now, if the named teacher doesn't exist, just ignore it.
					if ($teacher) 
						$rc = $loginService->linkUserToGroup($teacher, $group);
					
				}
				// If we want to send an email on adding a new user, do it here
				if ($apiInformation->emailTemplateID) {
					$loginService->subscriptionOps->sendUserEmail($user, $apiInformation);
					AbstractService::$debugLog->info("sent email to ".$user->email.' using '.$apiInformation->emailTemplateID);
				}
			} else {
				AbstractService::$debugLog->info("returned existing user ".$user->name." expires on ".$user->expiryDate);
			}
			
			// TODO: Should also return account information to mirror getUser
			//$apiInformation->userID = $user->id;
			//$account = $loginService->getAccountFromGroup($loginService->getGroup($apiInformation));
			
			break;
			
		default:
			returnError(1, 'Invalid method '.$apiInformation->method);
	}

	// Send back data.
	// It might be better to only send back limited account data
	// BUG: No, I need lots of data for working out if titles are not expired etc
	if (!isset($account) || !$account) {
		$account = new Account();
	}
	$returnInfo = array('user' => $user, 'account' => $account); 
	
	echo json_encode($returnInfo);
	
} catch (Exception $e) {
	// Lets assume that we are generating plain text
	returnError(1, $e->getMessage());
}
flush();
exit(0);