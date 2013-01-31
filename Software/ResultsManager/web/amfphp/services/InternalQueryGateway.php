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

ini_set('max_execution_time', 300); // 5 minutes

require_once(dirname(__FILE__)."/MinimalService.php");

$thisService = new MinimalService();

// Done in config.php
date_default_timezone_set('UTC');

header('Content-Type: text/plain; charset=utf-8');

// Account information will come in JSON format
function loadAPIInformation() {
	global $thisService;
	
	$inputData = file_get_contents("php://input");
	//$inputData = '{"method":"getSubscriptionRecords","startDate":"2012-05-01","dbHost":2}';
	//$inputData = '{"method":"mergeDatabases","dbHost":2}';
	//$inputData = '{"method":"archiveOldUsers","rootID":13982,"registrationDate":"-2 month","dbHost":2}';
	$inputData = '{"method":"emailMeByGroup","xdate":"2013-01-17","dbHost":2}';
	//$inputData = '{"method":"emailMeByUser","date":"2013-01-15","dbHost":2}';
	
	$postInformation= json_decode($inputData, true);	
	if (!$postInformation) 
		throw new Exception('Error decoding data: '.': '.$inputData);
		
	// First check mandatory fields exist
	if (!isset($postInformation['method'])) {
		throw new Exception("No method has been sent");
	}
	
	return $postInformation;
}	
function returnError($errCode, $data = null) {
	global $thisService;
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

	$apiReturnInfo['dsn'] = $GLOBALS['db'];
	$apiReturnInfo['dbHost'] = $GLOBALS['dbHost'];

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
	
	// You might want a different dbHost which you have now got - so override the settings from config.php
	if ($GLOBALS['dbHost'] != $apiInformation['dbHost'])
		$thisService->changeDB($apiInformation['dbHost']);
	
	switch ($apiInformation['method']) {
		case 'getGlobalR2IUser':
			$rc = $thisService->internalQueryOps->getUsersFromStudentID($apiInformation['id']);
			break;
		case 'updateSessionsForDeletedUsers':
			$rc = $thisService->internalQueryOps->updateSessionsForDeletedUsers($apiInformation['rootID']);
			break;
		case 'findEmail':
			$rc = $thisService->internalQueryOps->getUsersFromEmail($apiInformation['email']);
			break;
			
		case 'archiveOldUsers':
			if (!isset($apiInformation['rootID']))
				throw new Exception("No rootID has been sent");
			if (isset($apiInformation['registrationDate'])) {
				$regDate = strtotime($apiInformation['registrationDate']);
				if (!$regDate)
					throw new Exception("Invalid date");
			} else {
				$regDate = time();
			}
			$rc = $thisService->dailyJobOps->archiveOldUsers(array($apiInformation['rootID']),date('Y-m-d',$regDate));
			break;
			
		case 'getSubscriptionRecords':
			//echo 'startDate='.$apiInformation['startDate'];
			$rc['subscriptions'] = $thisService->internalQueryOps->getSubscriptions($apiInformation['startDate']);
			break;
			
		// The following is very specific to the one time we merged two databases
		case 'mergeDatabases':
			$rc = $thisService->internalQueryOps->mergeDatabases();
			break;
			
		// For testing EmailMe - normally run from RunDailyJobs
		case 'emailMeByGroup':
			$templateID = 'EmailMeUnitStart';
			if (isset($apiInformation['date'])) {
				$dateStamp = strtotime($apiInformation['date']);
				if (!$dateStamp)
					throw new Exception("Invalid date");
			} else {
				$dateStamp = time();
			}
			$date = date('Y-m-d', $dateStamp);
			$emailArray = $thisService->dailyJobOps->getEmailsForGroupUnitStart($date);
			if (count($emailArray) > 0) {
				if (isset($_REQUEST['send']) || !isset($_SERVER["SERVER_NAME"])) {
					// Send the emails
					$thisService->emailOps->sendEmails("", $templateID, $emailArray);
						
				} else {
					// Or print on screen
					$newLine = '<br/>';
					foreach($emailArray as $email) {
						echo "<b>Email: ".$email["to"]."</b>".$newLine.$thisService->emailOps->fetchEmail($templateID, $email["data"])."<hr/>";
					}
					
				}
				$rc['count'] = count($emailArray);
				$rc['date'] = $date;
				$rc['comment'] = 'sent emails to group users';
				
			} else {
				$rc = 0;
			}
			break;
			
		// For testing EmailMe - normally run from RunDailyJobs
		case 'emailMeByUser':
			$templateID = 'EmailMeUnitStart';
			if (isset($apiInformation['date'])) {
				$dateStamp = strtotime($apiInformation['date']);
				if (!$dateStamp)
					throw new Exception("Invalid date");
			} else {
				$dateStamp = time();
			}
			$date = date('Y-m-d', $dateStamp);
			$emailArray = $thisService->dailyJobOps->getEmailsForUserUnitStart($date);
			if (count($emailArray) > 0) {
				if (isset($_REQUEST['send']) || !isset($_SERVER["SERVER_NAME"])) {
					// Send the emails
					$thisService->emailOps->sendEmails("", $trigger->templateID, $emailArray);
						
				} else {
					// Or print on screen
					$newLine = '<br/>';
					foreach($emailArray as $email) {
						echo "<b>Email: ".$email["to"]."</b>".$newLine.$thisService->emailOps->fetchEmail($templateID, $email["data"])."<hr/>";
					}
					
				}
				$rc['count'] = count($emailArray);
				$rc['date'] = $date;
				$rc['comment'] = 'sent emails to individual users';
				
			} else {
				$rc = 0;
			}
			break;
			
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
exit(0);
