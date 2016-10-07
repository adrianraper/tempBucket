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

require_once(dirname(__FILE__)."/MinimalService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");

$thisService = new MinimalService();

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
	global $thisService;
	global $emailArray;
	global $newLine;
	$accountEmails = $thisService->accountOps->getEmailsForMessageType($account->id, $messageType);
	//echo 'accountEmails='.count($accountEmails).'-'.implode(',',$accountEmails).$newLine;
	// If there is a reseller they are also 'ccd.
	// Unless it is a service email, because that would deluge them. 
	// Actually most emails you send like this probably shouldn't go to the reseller as they are global
	//if ($messageType!=Trigger::TRIGGER_TYPE_SERVICE) {
	if ($addReseller) {
		$resellerEmail = array($thisService->accountOps->getResellerEmail($account->resellerCode));
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
$testingTriggers = "RM-welcome";
//$testingTriggers = "R2I announce email";
//$testingTriggers .= "Service";
//$testingTriggers .= "terms and conditions";
//$testingTriggers .= "TBV10 release";
//$testingTriggers .= "C-Builder upgrade";
//$testingTriggers .= "TBV10 released";

if (stristr($testingTriggers, "RM-welcome")) {
	// Email to all users in a group
	// Note, changed without testing that array is ok
	//$groupIds = array('80023','80024','80025','80026','80027','80028');
    $groupIds = array('21560');
    $alsoSubGroups = true;
	$templateID = 'user/LELT_welcome';
	$emailArray = $thisService->dailyJobOps->getEmailsForGroup($groupIds, null, $alsoSubGroups);
	if (isset($_REQUEST['send']) || !isset($_SERVER["SERVER_NAME"])) {
		// Send the emails
		$thisService->emailOps->sendEmails("", $templateID, $emailArray);
		echo "Queued ".count($emailArray)." emails for units starting $courseDate. $newLine";
			
	} else {
		// Or print a few of them on screen
		echo count($emailArray)." emails for group ".implode(',', $groupIds)." $newLine";
        $limit = 0;
		foreach ($emailArray as $email) {
            $limit++;
			echo "<b>Email: ".$email["to"]."</b>".$newLine.$thisService->emailOps->fetchEmail($templateID, $email["data"])."<hr/>";
			if ($limit > 20) break;
		}
	}
} else {
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
		$rootList = array(11210,13928,12037,11177,11282,11660,12740,13206,13208,13320,13512,13521,13660,13661,13687,13890,13900,14024,14126,14132,14143,14189,14276,14277,14278,14279,14280,14281,14282,14283,14284,14286,14287,14288,14290,14291,14292,14333,14453);
		if (isset($_REQUEST['template'])) {
			$templateID = $_REQUEST['template'];
		} else {
			$templateID = 'rti2_announce_3';
		}
		$messageType = Trigger::TRIGGER_TYPE_UPGRADE;
		
	} else if (stristr($testingTriggers, "TBV10 released")) {
		// These are not sent through triggers but programmatically
		$conditions['active'] = true;
		$conditions['accountType'] = 1; // Standard invoice (ignores trials, distributors etc)
		$conditions['productCode'] = '55'; // existing TB title
		$conditions['selfHost'] = 'false';
		$conditions['languageCode'] = 'EN';
		$conditions['notLicenceType'] = 5;
		$addReseller = false;
		//$rootList = array(163,38,10074,10732);
		//$rootList = null;
		// Include the root list here
//		$rootList = array(14276,14277,14278,14279,14280,14281,14282,14283,14284,14286,14287,14288,14290,14291,14292);
//		$rootList = array(11,22,31,38,10065,10074,10114,10186,10497,10528,10542,10825,10889,10933,11033,11104,11177,11190,11210,11585,11660,11726,11811,11831,12803,13205);
//		$rootList = array(13243,13249,13258,13320,13376,13449,13464,13465,13474,13492,13545,13546,13550,13551,13552,13579,13585,13644,13852,13869,13886,13915,13946,13949,13994);
//		$rootList = array(14366,14369,14407,14420,14435,14441,14442,14453,14457,14493,14511,14566,14590,14613,14614,14615,14671,14740,14742,14751,14759,14790,14795,14808,14991,15200,15314,15836);
		$rootList = array(16285,17369,17553,17780,18215,18444,18449,18507,18692,18833,18918,19007,19563,19677,19877,19965,19979,19994,20046,20191,20342,20453,20599,20895,21519,21524,23087,23090);
//		$rootList = array(14036,14037,14113,14210,14240,14248,14263,14268,14276,14277,14279,14280,14281,14282,14283,14284,14286,14287,14288,14290,14291,14292,14327,14364);
		if (isset($_REQUEST['template'])) {
			$templateID = $_REQUEST['template'];
		} else {
			$templateID = 'tbV10released';
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
		//$rootList = array(11726);
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
		
	} else if (stristr($testingTriggers, "C-Builder upgrade")) {
		// These are not sent through triggers but programmatically
		$conditions['active'] = true;
		$conditions['productCode'] = '54'; 
		$conditions['selfHost'] = 'false';
		$addReseller = false;
		$rootList = null;
		$rootList = array(163,38,10074,10732);
		//$rootList = array(14276,14277,14278,14279,14280,14281,14282,14283,14284,14286,14287,14288,14290,14291,14292);
		if (isset($_REQUEST['template'])) {
			$templateID = $_REQUEST['template'];
		} else {
			$templateID = 'ccbV880upgrade';
		}
		$messageType = Trigger::TRIGGER_TYPE_UPGRADE;
	}

	$accounts = $thisService->accountOps->getAccounts($rootList, $conditions);
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
			$thisService-> emailOps->sendEmails("", $templateID, $emailArray);
			echo "Trying to send ".count($emailArray)." emails";
		} else {
			// Or print on screen
			echo "Displaying ".count($emailArray)." emails";
			foreach($emailArray as $email) {
				/*
				echo "<b>".$email['data']['account']->name." to: ".$email["to"]."</b>".$newLine;
				*/
				if ($email["cc"]) {
					echo "<b>".$email['data']['account']->name." to: ".$email["to"].", cc: ".implode(',',$email["cc"])."</b>".$newLine.$thisService->emailOps->fetchEmail($templateID, $email["data"])."<hr/>";
				} else {
					echo "<b>".$email['data']['account']->name." to: ".$email["to"]."</b>".$newLine.$thisService->emailOps->fetchEmail($templateID, $email["data"])."<hr/>";
				}
			}
		}

	} else {
		echo "no accounts found";
	}
}
exit(0);
