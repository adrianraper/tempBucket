<?php
/*
 * This script will go through all the accounts finding those that match certain conditions
 * and send the appropriate users an email.
 * Used for warning about system downtime, title upgrades etc
 *
 * You can see the log of results in T_Log
 */

// Warning - this script takes a long time to run, can you override the timeout without nasty consequences? 
// This didn't seem to work on CE.com - I timed out after 30 seconds. However, the emails had all been triggered by then so it was fine.
ini_set('max_execution_time', 300); // 5 minutes

if (isset($_SESSION['dbHost'])) unset($_SESSION['dbHost']);

require_once(dirname(__FILE__)."/DMSService.php");
$dmsService = new DMSService();

// Set up line breaks for whether this is outputting to html page or a text file
if (isset($_SERVER["SERVER_NAME"])) {
	$newLine = '<br/>';
} else {
	$newLine = "\n";
}
function addDaysToTimestamp($timestamp, $days) {
	//return date("Y-m-d", $timestamp + ($days * 86400));
	return $timestamp + ($days * 86400);
}

function specificEmail($account, $messageType, $templateID, $addReseller = false) {
	global $dmsService;
	global $emailArray;
	global $newLine;
	$accountEmails = $dmsService->accountOps->getEmailsForMessageType($account->id, $messageType);
	//echo 'accountEmails='.count($accountEmails).'-'.implode(',',$accountEmails).$newLine;
	// If there is a reseller they are also 'ccd.
	// Unless it is a service email, because that would deluge them. 
	// Actually most emails you send like this probably shouldn't go to the reseller as they are global
	//if ($messageType!=Trigger::TRIGGER_TYPE_SERVICE) {
	if ($addReseller) {
		$resellerEmail = array($dmsService->accountOps->getResellerEmail($account->resellerCode));
	} else {
		$resellerEmail = array();
	}
	//echo 'resellerEmail='.implode(',',$resellerEmail).$newLine;
	
	// Pick out the first accountEmail for 'to' and merge all the rest as 'cc'
	$adminEmail = array_shift($accountEmails);
	//echo "admin=$adminEmail";
	$ccEmails = array_merge($accountEmails, $resellerEmail);
	
	$emailData = array("account" => $account);
	$thisEmail = array("to" => $adminEmail, "cc" => $ccEmails, "data" => $emailData);
	$emailArray[] = $thisEmail;
}

// If you want to run specific triggers for specific days (for testing)
// you can put 'date=-1' in the URL
$testingTriggers = "";
//$testingTriggers = "R2I announce email";
//$testingTriggers .= "Service";
//$testingTriggers .= "terms and conditions";
$testingTriggers .= "TBV10 release";

	if (stristr($testingTriggers, "Service")) {
		// These are not sent through triggers but programmatically
		$conditions['active'] = true;
		$conditions['notLicenceType'] = 5; 
		//$conditions['licenceType'] = 5; // CLS
		$conditions['accountType'] = 1; // Standard invoice
		$addReseller = true;
		$rootList = null;
		$rootList = array(7);
		if (isset($_REQUEST['template'])) {
			$templateID = $_REQUEST['template'];
		} else {
			$templateID = 'sub_reminder_change_August2011';
		}
		$messageType = Trigger::TRIGGER_TYPE_SERVICE;
		
	} else if (stristr($testingTriggers, "R2I announce email")) {
		// These are not sent through triggers but programmatically
		$conditions['active'] = true;
		$conditions['accountType'] = 1; // Standard invoice (ignores trials, distributors etc)
		$conditions['productCode'] = '52,53'; // existing RTI titles
		$conditions['reseller'] = '7'; // NAS=7;
		$conditions['selfHost'] = 'false';
		$addReseller = false;
		
		$rootList = null;
		$conditions['excludeRootIDs'] = 'true';
		$rootList = array(11210,13928,12037,11177,11282,12740,13206,13208,13320,13660,13661,13687,13890,13900,14024,14126,14132,14143,14276,14277,14278,14279,14280,14281,14282,14283,14284,14286,14287,14288,14290,14291,14292);
		if (isset($_REQUEST['template'])) {
			$templateID = $_REQUEST['template'];
		} else {
			$templateID = 'rti2_announce_3';
		}
		$messageType = Trigger::TRIGGER_TYPE_UPGRADE;
		
	} else if (stristr($testingTriggers, "TBV10 release")) {
		// These are not sent through triggers but programmatically
		$conditions['active'] = true;
		$conditions['accountType'] = 1; // Standard invoice (ignores trials, distributors etc)
		$conditions['productCode'] = '9'; // existing TB title
		$conditions['selfHost'] = 'false';
		$conditions['languageCode'] = 'EN';
		$conditions['notLicenceType'] = 5;
		$addReseller = false;
		//$rootList = array(163,38,10074,10732);
		//$rootList = null;
		// HCT colleges already upgraded
		$conditions['excludeRootIDs'] = 'true';
		$rootList = array(14276,14277,14278,14279,14280,14281,14282,14283,14284,14286,14287,14288,14290,14291,14292);
		if (isset($_REQUEST['template'])) {
			$templateID = $_REQUEST['template'];
		} else {
			$templateID = 'tbV10release';
		}
		$messageType = Trigger::TRIGGER_TYPE_UPGRADE;
	}

	$accounts = $dmsService->accountOps->getAccounts($rootList, $conditions);
	if ($accounts) {
		// Build up an array of emails that need to be sent
		$emailArray = array();
		foreach ($accounts as $account) {
			// If you want to limit to particular roots for testing
			if (isset($_REQUEST['rootID']) && $_REQUEST['rootID'] > 0) {
				if ($account->id == $_REQUEST['rootID']) {
					specificEmail($account, $messageType, $templateID, $addReseller);
				//} else {
					//echo "no match for $account->id against ".$_REQUEST['rootID']."<br/>";
				}
			// Or to do it in batches. First, just a start root
			} else if ((isset($_REQUEST['startRootID']) && $_REQUEST['startRootID'] > 0) &&
					!isset($_REQUEST['stopRootID'])){
				if ($account->id >= $_REQUEST['startRootID']) {
					specificEmail($account, $messageType, $templateID, $addReseller);
				//} else {
					//echo "no match for $account->id against ".$_REQUEST['rootID']."<br/>";
				}
			// Next, just a stop root
			} else if ((isset($_REQUEST['stopRootID']) && $_REQUEST['stopRootID'] > 0) &&
					!isset($_REQUEST['startRootID'])){
				if ($account->id <= $_REQUEST['stopRootID']) {
					specificEmail($account, $messageType, $templateID, $addReseller);
				//} else {
					//echo "no match for $account->id against ".$_REQUEST['rootID']."<br/>";
				}
			// Finally, both start and stop
			} else if ((isset($_REQUEST['stopRootID']) && $_REQUEST['stopRootID'] > 0) &&
					(isset($_REQUEST['startRootID']) && $_REQUEST['startRootID'] > 0)){
				if ($account->id >= $_REQUEST['startRootID'] &&
					$account->id <= $_REQUEST['stopRootID']) {
					specificEmail($account, $messageType, $templateID, $addReseller);
				//} else {
					//echo "no match for $account->id against ".$_REQUEST['rootID']."<br/>";
				}
			} else {
				specificEmail($account, $messageType, $templateID, $addReseller);
			}
		}
		// Then send them all
		// If the request variable 'send' is not defined then just print the emails to the screen, don't actually send anything.  
		// This is to prevent accidental sends when testing!
		// Debug the list of accounts you will send it to
		// foreach($emailArray as $email) {
		//	 echo "<b>".$email['data']['account']->name.'-'.$email['data']['account']->id.", email: ".$email['to']."</b><br/>";
		// }
		if (isset($_REQUEST['send']) || !isset($_SERVER["SERVER_NAME"])) {
			// Send the emails
			$dmsService-> emailOps->sendEmails("", $templateID, $emailArray);
			echo "Trying to send ".count($emailArray)." emails";
		} else {
			// Or print on screen
			echo "Displaying ".count($emailArray)." emails";
			foreach($emailArray as $email) {
				/*
				echo "<b>".$email['data']['account']->name." to: ".$email["to"]."</b>".$newLine;
				*/
				if ($email["cc"]) {
					echo "<b>".$email['data']['account']->name." to: ".$email["to"].", cc: ".implode(',',$email["cc"])."</b>".$newLine.$dmsService->emailOps->fetchEmail($templateID, $email["data"])."<hr/>";
				} else {
					echo "<b>".$email['data']['account']->name." to: ".$email["to"]."</b>".$newLine.$dmsService->emailOps->fetchEmail($templateID, $email["data"])."<hr/>";
				}
			}
		}

	} else {
		echo "no accounts found";
	}


exit(0);
?>