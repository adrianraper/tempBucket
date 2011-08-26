<?php
/*
 * This script will go through all applicable accounts and run some SQL on them
 */

require_once(dirname(__FILE__)."/DMSService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");

$dmsService = new DMSService();
session_start();

function addDaysToTimestamp($timestamp, $days) {
	//return date("Y-m-d", $timestamp + ($days * 86400));
	return $timestamp + ($days * 86400);
}

function addRMtoAccount($account) {
	global $dmsService;
	// use the details from the first title that they have as the basis
	$title = $account->titles[0];
	$dbObj = $title->toAssocArray();
	// Then change to be specific to RM
	$dbObj['F_ProductCode'] = 2;
	$dbObj['F_MaxStudents'] = 0;
	$dbObj['F_MaxAuthors'] = 0;
	$dbObj['F_MaxTeachers'] = 0;
	$dbObj['F_MaxReporters'] = 0;
	// Some fields just don't matter, like language code
	$dbObj['F_ContentLocation'] = null;
	$dbObj['F_LanguageCode'] = 'EN';
	// Others are not set in assocArray for some reason
	$dbObj['F_RootID'] = $account->id;

	return $dmsService->db->AutoExecute("T_Accounts", $dbObj, "INSERT");

}
// If you want to run specific triggers for specific days (for testing)
// you can put 'date=-1' in the URL
$testingTriggers = "";
$testingTriggers .= "Add RM to all accounts";
//$testingTriggers .= "terms and conditions";

// Now that even AA accounts will have RM for usage stats, we need to add it to all. But not individuals.
if (stristr($testingTriggers, "Add RM to all accounts")) {
	// These are not sent through triggers but programmatically
	$conditions = array();
	//$conditions['active'] = true;
	$conditions['notLicenceType'] = 5;
	//$testingAccounts = array(13836);
	$testingAccounts = null;
	$accounts = $dmsService-> accountOps->getAccounts($testingAccounts, $conditions);
	//$toDate = date("Y-m-d").' 23:59:59';
	//$fromDate = date("Y-m-d", addDaysToTimestamp(time(), -6)).' 00:00:00';
	//$fromDate = '2010-09-30 00:00:00';
	//$oneMonthAgo = date("Y-m-d", addDaysToTimestamp(time(), -30)).' 00:00:00';
	
	if ($accounts) {
		// I want to add RM to all accounts that don't have it
		
		// Need to add usage stats to each title in each account
		foreach ($accounts as $account) {
			// See if this is a new account (really this is only relevant for new accountRoot, but for now all dates are on accounts only)
			$newAccount=false;
			// Do some error checking for testing accounts that might be a bit odd, like not having any titles
			if (count($account->titles)<1)
				continue 1;
			foreach ($account->titles as $title) {
				if ($title->productCode == 2) {
					echo "RM already in {$account->name}<br/>";
					continue 2; // Found RM, so get out of looping for this account
				}
			}
			if (addRMtoAccount($account)) {
				echo "Added RM to {$account->name}<br/>";
			} else {
				echo "Failed to add RM to {$account->name}<br/>";
			};
			
		}
		// This is a good way if all accounts use one template. Or if we have a template built of header/footer and then other templates
		//echo $dmsService->templateOps->fetchTemplate("dms_reports/100", array("accounts" => $accounts));
	} else {
		echo "no active accounts found";
	}
	
}

exit(0);
?>

