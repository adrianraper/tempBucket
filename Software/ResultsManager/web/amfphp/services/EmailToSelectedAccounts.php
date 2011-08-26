<?php
/*
 * This script will go through all the accounts finding those that match some conditions
 * and sends their admin users an email.
 * Used for notifying upgrades etc
 */

require_once(dirname(__FILE__)."/DMSService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");
require_once($GLOBALS['smarty_libs']."/Smarty.class.php");
$smarty = new Smarty();
$smarty->template_dir = $GLOBALS['smarty_template_dir'];
$smarty->compile_dir = $GLOBALS['smarty_compile_dir'];
$smarty->config_dir = $GLOBALS['smarty_config_dir'];
$smarty->cache_dir = $GLOBALS['smarty_cache_dir'];
$smarty->plugins_dir[] = $GLOBALS['smarty_plugins_dir'];

$dmsService = new DMSService();
session_start();
date_default_timezone_set('UTC');
function addDaysToTimestamp($timestamp, $days) {
	//return date("Y-m-d", $timestamp + ($days * 86400));
	return $timestamp + ($days * 86400);
}

function specificEmail($account, $templateID=null) {
	global $dmsService;
	// TODO: implement $dmsService->emailOps->sendOrEchoEmail
	// If the admin email is different from the account email, cc
	$accountEmail = $account->email;
	$adminEmail = $account->adminUser->email;
	if ($accountEmail != $adminEmail && $accountEmail && $accountEmail!= '') {
		$emailArray = array("to" => $adminEmail
								,"data" => array("account" => $account)
								,"cc" => array($accountEmail)
							);
	} else {
		$emailArray = array("to" => $adminEmail
								,"data" => array("account" => $account)
							);
	}
					
	// Check that the template exists
	if (!$dmsService->templateOps->checkTemplate('emails', $templateID)) {
		echo "This template doesn't exist. /emails/$templateID";
		exit(0);
	}
	
	if (isset($_REQUEST['send']) || !isset($_SERVER["SERVER_NAME"])) {
		$dmsService->emailOps->sendEmails("", $templateID, array($emailArray));
		echo "<b>{$account->id}, ".$account->adminUser->email."</b><br/>";
	} else {
		echo "<b>$account->id, email: ".$account->adminUser->email."</b><br/><br/>".$dmsService->emailOps->fetchEmail($templateID, array("account" => $account))."<hr/>";
		//echo "<b>$account->id, $account->name, email: ".$account->adminUser->email."</b><br/><br/>";
	}
	//echo "<b>Email: ".$account->adminUser->email." - ".$account->name."</b><br/><br/>";
	//echo "<b>Email: ".$account->email." - ".$account->name."</b><br/><br/>";
}

// If you want to run specific triggers for specific days (for testing)
// you can put 'date=-1' in the URL
$testingTriggers = "";
//$testingTriggers .= "System";
//$testingTriggers .= "SSSV9 Upgrade";
//$testingTriggers .= "SSSV9 switch email";
//$testingTriggers .= "SSSV9 switch mistake";
//$testingTriggers .= "Usage Stats apology";
$testingTriggers .= "Server Upgrade";
//$testingTriggers .= "terms and conditions";

//$templateID = 'system_maintenance_CE_Feb2011';
//$templateID = 'system_maintenance_CLS_Feb2011';

if (stristr($testingTriggers, "Server Upgrade")) {
	// These are not sent through triggers but programmatically
	$conditions['active'] = true;
	$conditions['selfHost'] = false;
	// I want trials and CLS as well - active is the only criteria
	if (isset($_REQUEST['template'])) {
		$templateID = $_REQUEST['template'];
	} else {
		$templateID = 'server_upgrade_July2011';
	}
	$rootList = array(163,5);
	$rootList = null;
	$accounts = $dmsService->accountOps->getAccounts($rootList, $conditions);
	//$accounts = $dmsService->accountOps->getAccounts(array(1), $conditions);
	if ($accounts) {
		echo "got ".count($accounts).' accounts<br/>';
		foreach ($accounts as $account) {
			specificEmail($account, $templateID);
		}
	} else {
		echo "no accounts found";
	}
}
if (stristr($testingTriggers, "Usage Stats apology")) {
	// These are not sent through triggers but programmatically
	$conditions['active'] = true;
	$conditions['selfHost'] = false;
	$conditions['notLicenceType'] = 5; // CE.com
	$conditions['accountType'] = 1; // Standard invoice (ignores trials, distributors etc)
	if (isset($_REQUEST['template'])) {
		$templateID = $_REQUEST['template'];
	} else {
		$templateID = 'usage_stats_email_mistake_June2011';
	}
	
	$accounts = $dmsService->accountOps->getAccounts(null, $conditions);
	//$accounts = $dmsService->accountOps->getAccounts(array(1), $conditions);
	if ($accounts) {
		echo "got ".count($accounts).' accounts';
		foreach ($accounts as $account) {
			specificEmail($account, $templateID);
		}
	} else {
		echo "no accounts found";
	}
}
if (stristr($testingTriggers, "SSSV9 Upgrade")) {
	// These are not sent through triggers but programmatically
	$conditions['active'] = true;
	//$conditions['notLicenceType'] = 5; // CE.com
	//$conditions['licenceType'] = 5; // CLS.com
	$conditions['accountType'] = 1; // Standard invoice (ignores trials, distributors etc)
	$conditions['productCode'] = 3; // existing SSS
	if (isset($_REQUEST['template'])) {
		$templateID = $_REQUEST['template'];
	} else {
		$templateID = 'upgrade_SSSV9_May2011';
	}
	
	$accounts = $dmsService->accountOps->getAccounts(null, $conditions);
	//$accounts = $dmsService->accountOps->getAccounts(array(1), $conditions);
	if ($accounts) {
		foreach ($accounts as $account) {
			// If you want to limit to particular roots for testing
			if (isset($_REQUEST['rootID']) && $_REQUEST['rootID'] > 0) {
				if ($account->id == $_REQUEST['rootID']) {
					specificEmail($account, $templateID);
				//} else {
					//echo "no match for $account->id against ".$_REQUEST['rootID']."<br/>";
				}
			// Or to do it in batches. First, just a start root
			} else if ((isset($_REQUEST['startRootID']) && $_REQUEST['startRootID'] > 0) &&
					!isset($_REQUEST['stopRootID'])){
				if ($account->id >= $_REQUEST['startRootID']) {
					specificEmail($account, $templateID);
				//} else {
					//echo "no match for $account->id against ".$_REQUEST['rootID']."<br/>";
				}
			// Next, just a stop root
			} else if ((isset($_REQUEST['stopRootID']) && $_REQUEST['stopRootID'] > 0) &&
					!isset($_REQUEST['startRootID'])){
				if ($account->id <= $_REQUEST['stopRootID']) {
					specificEmail($account, $templateID);
				//} else {
					//echo "no match for $account->id against ".$_REQUEST['rootID']."<br/>";
				}
			// Finally, both start and stop
			} else if ((isset($_REQUEST['stopRootID']) && $_REQUEST['stopRootID'] > 0) &&
					(isset($_REQUEST['startRootID']) && $_REQUEST['startRootID'] > 0)){
				if ($account->id >= $_REQUEST['startRootID'] &&
					$account->id <= $_REQUEST['stopRootID']) {
					specificEmail($account, $templateID);
				//} else {
					//echo "no match for $account->id against ".$_REQUEST['rootID']."<br/>";
				}
			} else {
				specificEmail($account, $templateID);
			}
		}
	} else {
		echo "no accounts found";
	}
}
if (stristr($testingTriggers, "SSSV9 switch email")) {
	$templateID = 'switch_SSSV9_May2011';
	$roots = array(47, 10133, 10186, 10533, 10715, 10732, 10790, 11033, 11041, 11072, 11079, 11104, 11107, 11189, 11191, 11210, 11282, 11585, 11636, 11662, 11726, 11826, 11831, 12037, 12048, 12374, 12740, 12803, 12883, 12950, 13012, 13105, 13186, 13206, 13254, 13258, 13266, 13268, 13299, 13300, 13302, 13320, 13323, 13376, 13434, 13463, 13464, 13473, 13521, 13544, 13545, 13546, 13570, 13585, 13644, 13649, 13667, 13671, 13682, 13685, 13700, 13709, 13716, 13824, 13832, 13836, 13852, 13865, 13926, 13930, 13932);
	$accounts = $dmsService->accountOps->getAccounts($roots, null);
	if ($accounts) {
		foreach ($accounts as $account) {
			specificEmail($account, $templateID);
		}
	}
}
if (stristr($testingTriggers, "SSSV9 switch mistake")) {
	$templateID = 'switch_mistake_SSSV9_May2011';
	$roots = array(47, 10133, 10186, 10533, 10715, 10732, 10790, 11033, 11041, 11072, 11079, 11104, 11107, 11189, 11191, 11210, 11282, 11585, 11636, 11662, 11726, 11826, 11831, 12037, 12048, 12374, 12740, 12803, 12883, 12950, 13012, 13105, 13186, 13206, 13254, 13258, 13266, 13268, 13299, 13300, 13302, 13320, 13323, 13376, 13434, 13463, 13464, 13473, 13521, 13544, 13545, 13546, 13570, 13585, 13644, 13649, 13667, 13671, 13682, 13685, 13700, 13709, 13716, 13824, 13832, 13836, 13852, 13865, 13926, 13930);
	//$roots = array(11662);
	// take out people who want SSS and SSSV9, L&T 13932, Lingnan 10537
	$accounts = $dmsService->accountOps->getAccounts($roots, null);
	if ($accounts) {
		foreach ($accounts as $account) {
			specificEmail($account, $templateID);
		}
	}
}

exit(0);
?>