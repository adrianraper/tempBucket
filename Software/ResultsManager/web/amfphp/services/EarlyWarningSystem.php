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

function addDaysToTimestamp($timestamp, $days) {
	//return date("Y-m-d", $timestamp + ($days * 86400));
	return $timestamp + ($days * 86400);
}

// If you want to run specific triggers for specific days (for testing)
// you can put 'date=-1' in the URL
$testingTriggers = "";
$testingTriggers .= "Early warning system";
//$testingTriggers .= "terms and conditions";

if (stristr($testingTriggers, "Early warning system")) {
	// These are not sent through triggers but programmatically
	$conditions['active'] = true;
	$conditions['notLicenceType'] = 5;
	//$testingAccounts = array(163);
	$testingAccounts = null;
	//$sortOrder = array('name');
	$sortOrder = array('expiryDate');
	$accounts = $dmsService-> accountOps->getAccounts($testingAccounts, $conditions, $sortOrder);
	$toDate = date("Y-m-d").' 23:59:59';
	$fromDate = date("Y-m-d", addDaysToTimestamp(time(), -6)).' 00:00:00';
	//$fromDate = '2010-09-30 00:00:00';
	$oneMonthAgo = date("Y-m-d", addDaysToTimestamp(time(), -30)).' 00:00:00';
	
	if ($accounts) {
		// First of all, lets just get a list of accounts with a URL link to RM usage stats
		// Can we sort them based on RM expiry date rather than root?
		echo $dmsService-> templateOps->fetchTemplate("dms_reports/Start_URL_Report", array("accounts" => $accounts));
	} else {
		echo "no active accounts found";
	}
	
}

exit(0);
?>

