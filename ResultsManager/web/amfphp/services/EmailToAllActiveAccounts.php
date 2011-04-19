<?php
/*
 * This script will go through all the accounts finding those that are active and sending their 
 * admin users an email.
 * Used for warning about system downtime etc.
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

function specificEmail($account) {
	global $dmsService;
	// If the admin email is different from the account email, cc
	$emailArray = array("to" => $account->adminUser->email
							,"data" => array("account" => $account)
							,"bcc" => array("adrian.raper@clarityenglish.com")
						);
	if ($account->email != $account->adminUser->email) {
		array_splice($emailArray, 2 , 0, array("cc" => $account->email));
	}
						
	// Send the email
	if (isset($_REQUEST['template'])) {
		$templateID = $_REQUEST['template'];
	} else {
		$templateID = 'system_maintenance';
		//$templateID = 'system_maintenance_CE_Feb2011';
		//$templateID = 'system_maintenance_CLS_Feb2011';
	}
	// Check that the template exists
	if (!$dmsService-> templateOps->checkTemplate('emails', $templateID)) {
		echo "This template doesn't exist. /emails/$templateID";
		exit(0);
	}
	
	//$templateID = 'usageStats_announcement';
	if (isset($_REQUEST['send']) || !isset($_SERVER["SERVER_NAME"])) {
		$dmsService->emailOps->sendEmails("", $templateID, array($emailArray));
		echo "<b>Email: ".$account->adminUser->email."</b><br/>";
	} else {
		//echo "<b>$account->id, email: ".$account->adminUser->email."</b><br/><br/>".$dmsService->emailOps->fetchEmail($templateID, array("account" => $account))."<hr/>";
		echo "<b>$account->id, $account->name, email: ".$account->adminUser->email."</b><br/><br/>";
	}
	//echo "<b>Email: ".$account->adminUser->email." - ".$account->name."</b><br/><br/>";
	//echo "<b>Email: ".$account->email." - ".$account->name."</b><br/><br/>";
}

// If you want to run specific triggers for specific days (for testing)
// you can put 'date=-1' in the URL
$testingTriggers = "";
$testingTriggers .= "System";
//$testingTriggers .= "terms and conditions";

if (stristr($testingTriggers, "System")) {
	// These are not sent through triggers but programmatically
	$conditions['active'] = true;
	//$conditions['notLicenceType'] = 5;
	$conditions['licenceType'] = 5;
	//$conditions['accountType'] = 1; // Standard invoice
	$accounts = $dmsService->accountOps->getAccounts(null, $conditions);
	//$accounts = $dmsService->accountOps->getAccounts(array(1), $conditions);
	if ($accounts) {
		foreach ($accounts as $account) {
			// If you want to limit to particular roots for testing
			if (isset($_REQUEST['rootID']) && $_REQUEST['rootID'] > 0) {
				if ($account->id == $_REQUEST['rootID']) {
					specificEmail($account);
				//} else {
					//echo "no match for $account->id against ".$_REQUEST['rootID']."<br/>";
				}
			// Or to do it in batches. First, just a start root
			} else if ((isset($_REQUEST['startRootID']) && $_REQUEST['startRootID'] > 0) &&
					!isset($_REQUEST['stopRootID'])){
				if ($account->id >= $_REQUEST['startRootID']) {
					specificEmail($account);
				//} else {
					//echo "no match for $account->id against ".$_REQUEST['rootID']."<br/>";
				}
			// Next, just a stop root
			} else if ((isset($_REQUEST['stopRootID']) && $_REQUEST['stopRootID'] > 0) &&
					!isset($_REQUEST['startRootID'])){
				if ($account->id <= $_REQUEST['stopRootID']) {
					specificEmail($account);
				//} else {
					//echo "no match for $account->id against ".$_REQUEST['rootID']."<br/>";
				}
			// Finally, both start and stop
			} else if ((isset($_REQUEST['stopRootID']) && $_REQUEST['stopRootID'] > 0) &&
					(isset($_REQUEST['startRootID']) && $_REQUEST['startRootID'] > 0)){
				if ($account->id >= $_REQUEST['startRootID'] &&
					$account->id <= $_REQUEST['stopRootID']) {
					specificEmail($account);
				//} else {
					//echo "no match for $account->id against ".$_REQUEST['rootID']."<br/>";
				}
			} else {
				specificEmail($account);
			}
		}
	} else {
		echo "no account found";
	}
}

exit(0);
?>