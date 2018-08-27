<?php
/**
 * This script is a gateway for login functions
 * 
 * Used by external parties with minimal data returned.
 */

require_once(dirname(__FILE__)."/LoginService.php");

$loginService = new LoginService();
set_time_limit(300);
date_default_timezone_set('UTC');

function headerDateWithStatusCode($statusCode) {
    $utcDateTime = new DateTime();
    $utcTimestamp = $utcDateTime->format('U')*1000;
    header("Date: ".$utcTimestamp, false, $statusCode);
}

// API information will come in JSON format
function loadAPIInformation() {
	global $loginService;
	
	$inputData = file_get_contents("php://input");
    //AbstractService::$debugLog->info("inputData=$inputData");
    //$inputData = '{"method":"addUser","prefix":"Clarity","groupID":74548,"country":"Japan","loginOption":1,"subscriptionPeriod":"1month","adminPassword":"X1jsAD4rNksVcldXYJje","name":"why do you love me so","password":"ce787e0635","email":"341a730edc"}';
    //$inputData = '{"method": "updateUser","rootID": 10719,"groupID": 74544,"email":"adrian.10@vus.edu.vn",
    //                "adminPassword": "aff5WCqaHLzeW7mIZ0gj","name":"VUS Adrian 10", "studentID":"vus-1234-new"}';
	$postInformation = json_decode($inputData, true);
	if (!$postInformation)
        returnError(1, "Error decoding data: ".json_last_error().': '.$inputData);

	// We are expecting a method and parameters as an object
	// First check mandatory fields exist
	if (!isset($postInformation['method']))
        returnError(1, "No method has been sent");
	
	$apiInformation = new LoginAPI();
	$apiInformation->createFromSentFields($postInformation);
	return $apiInformation;
}
	
function returnError($errCode, $data = null) {
	global $loginService;
	global $apiInformation;

	switch ($errCode) {
		case 1:
            $msg = 'Exception, '.$data;
			break;
		case 210:
            $msg = 'Invalid group ID '.$data;
			break;
		case 200:
            $msg = 'No such user '.$data;
			break;
        case 207:
            $msg = 'User expired '.$data;
            break;
		case 250:
            $msg = 'You must send a password for the account '.$data;
			break;
		case 251:
            $msg = 'This is the wrong password for account '.$data;
			break;
		case 252:
            $msg = 'Group not found '.$data;
			break;
		case 253:
            $msg = 'Wrong password';
			break;
        case 254:
            $msg = 'Account not found '.$data;
            break;
        case 255:
            $msg = 'User already exists '.$data;
            break;
		default:
            $msg = 'Unknown error';
			break;
	}
    // Write out the error to the log
	AbstractService::$debugLog->err('returnError '.$errCode.': '.$msg);

    $apiReturnInfo = array("success"=>false, 'error'=>array("code"=>$errCode, "message"=>$msg));
	echo json_encode($apiReturnInfo);
	exit(0);
}
/*
 * Action for the script
 */
header('Content-type: application/json');
if ($_SERVER['REQUEST_METHOD'] === "OPTIONS") return;

// Load the passed data
try {
	// Read and validate the data
	// This will return an array of login requests
	$apiInformation = loadAPIInformation();

	// You might want a different dbHost which you have now got - so override the settings from config.php
	if ($GLOBALS['dbHost'] != $apiInformation->dbHost)
		$loginService->changeDb($apiInformation->dbHost);
	
	switch ($apiInformation->method) {
	    // This can move the user to a different group, and change their details
        case 'updateUser':
            $account = $loginService->getAccountFromRootID($apiInformation);
            // To cope with old style session
            Session::set('rootID', $account->id);
            $apiInformation->loginOption = $account->loginOption;

            // Authentication. You can only use this API if the account has the special licence attribute
            if (!isset($apiInformation->adminPassword)) {
                returnError(250, $account->name);
            } else {
                $licenceAttributes = $loginService->accountOps->getAccountLicenceDetails($account->id, null, 2);
                $dbPassword = '';
                foreach ($licenceAttributes as $attribute) {
                    if ($attribute["licenceKey"] == "APIpassword")
                        $dbPassword = $attribute["licenceValue"];
                }
                if ($apiInformation->adminPassword != $dbPassword)
                    returnError(251, $account->name);
            }

            if ($apiInformation->groupID) {
                $group = $loginService->manageableOps->getGroup($apiInformation->groupID);

                // Check that the found group is in the right account
                $groupRootId = $loginService->manageableOps->getRootIdForGroupId($group->id);
                if ($groupRootId != $account->id)
                    returnError(210, $group->name);
            }

            // Find the user if you can
            $user = $loginService->getUser($apiInformation);

            if ($user==false) {
                returnError(200, $apiInformation->studentID);

            } elseif ($user->expiryDate < date('Y-m-d H:m:s', time())) {
                returnError(207, $user->expiryDate);

            } else {
                // Do we need to move the user?
                if ($group)
                    $rc = $loginService->manageableOps->moveUsers(array($user), $group);

                // Do we need to update any details?
                if ((isset($apiInformation->email) && ($apiInformation->email != $user->email)) ||
                    (isset($apiInformation->name) && ($apiInformation->name != $user->name)) ||
                    (isset($apiInformation->password) && ($apiInformation->password != $user->password)) ||
                    (isset($apiInformation->studentID) && ($apiInformation->studentID != $user->studentID))) {
                    if (isset($apiInformation->email))
                        $user->email = $apiInformation->email;
                    if (isset($apiInformation->name))
                        $user->name = $apiInformation->name;
                    if (isset($apiInformation->studentID))
                        $user->studentID = $apiInformation->studentID;

                    $rc = $loginService->manageableOps->updateUsers(array($user), $account->id);
                }
            }
            break;

		case 'addUser':
		case 'addUserAutoGroup':

			// If you are using just a group to add user, need to get rootID now
			// Get the whole account info as well
			if (!$apiInformation->prefix && !$apiInformation->rootID) {
				$group = $loginService->getGroup($apiInformation);
				if (!$group)
					returnError(252, $apiInformation->groupID);
					
				$account = $loginService->getAccountFromGroup($group);
				if (!$account)
					returnError(253, $apiInformation->groupID);
					
				$apiInformation->rootID = $account->id;
				
			} else if (!$apiInformation->rootID) {
				$account = $loginService->getAccountFromPrefix($apiInformation);
				$apiInformation->rootID = $account->id;
				
			} else {
				$account = $loginService->getAccountFromRootID($apiInformation);
			}
			if (!$account)
                returnError(254, $apiInformation->rootID);

			// Authentication. You can only use this API if the account has the special licence attribute
			if (!isset($apiInformation->adminPassword)) {
				returnError(250, $account->name);
			} else {
			    $licenceAttributes = $loginService->accountOps->getAccountLicenceDetails($account->id, null, 2);
			    $dbPassword = '';
			    foreach ($licenceAttributes as $attribute) {
			        if ($attribute["licenceKey"] == "APIpassword")
			            $dbPassword = $attribute["licenceValue"];
                }
				if ($apiInformation->adminPassword != $dbPassword)
					returnError(251, $account->name);
			}

            // Find the user if you can
			$user = $loginService->getUser($apiInformation);
			
			if ($user==false) {
				if (!isset($group)) {
                    $group = $loginService->getGroup($apiInformation, $account);
                }
					
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

				// Check that the found group is in the right account
                $groupRootId = $loginService->manageableOps->getRootIdForGroupId($group->id);
				if ($groupRootId != $account->id)
                    returnError(210, $group->name);

				$user = $loginService->addUser($apiInformation, $group);
				//AbstractService::$debugLog->info("added new user ".$user->name." expire on ".$user->expiryDate);
				
				// If we want to send an email on adding a new user, do it here
				if ($apiInformation->emailTemplateID) {
					$loginService->subscriptionOps->sendUserEmail($user, $apiInformation);
					//AbstractService::$debugLog->info("queued email to ".$user->email.' using '.$apiInformation->emailTemplateID);
				}
			} else {
				// An error if you are trying to add a user
                returnError(255, $user->name);
			}
			
			break;
			
		default:
			returnError(1, 'Invalid method '.$apiInformation->method);
	}

	// Send back data.
	echo json_encode(array("success"=>"true", "details"=>array("userId"=>$user->userID, "groupName"=>$group->name)));
	
} catch (Exception $e) {
	returnError($e->getCode(), $e->getMessage());
}
flush();
exit(0);