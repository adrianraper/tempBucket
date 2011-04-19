<?php
/*
 * This script will go through all the accounts finding those that are active and sending their 
 * admin users an email.
 * Used for warning about system downtime etc.
 */
// Warning - this script takes a long time to run, can you override the timeout without nasty consequences? 
ini_set('max_execution_time', 120); // 2 minutes

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
/*
function addUsageStats($account, $fromDate, $toDate) {
	global $dmsService;
	//$account->usageStats = $dmsService-> usageOps->getDMSSessionCounts($account->id, $fromDate, $toDate);
	$usageStats = $dmsService->usageOps->getDMSSessionCounts($account->id, $fromDate, $toDate);
	$plainStats = array();

	foreach ($usageStats as $statsRow) {
		$plainStats[$statsRow['productCode']] = $statsRow['sessionCount'];
	}
	foreach ($account->titles as $title) {
		if (isset($plainStats[$title->productCode])) {
			$title->usageStats = $plainStats[$title->productCode];
		}
	}
}
*/
function addFullActivityStats($account, $fromDate, $toDate) {
	
	global $dmsService;
	// First do a licence count on each title (you only get a result for LT licences)
	//$title->licencesUsed
	$dmsService->usageOps->getLicencesUsedForAccount($account);
	
	//addUsageStats($account, $fromDate, $toDate);
	// We also need to count of failed sessions - dates are currently set as the last month
	$dmsService->usageOps->getFailedSessionsForAccount($account, $fromDate, $toDate);
	
	// We also need to count of good sessions - dates are currently set as the last month
	$dmsService->usageOps->getSessionsForAccount($account, $fromDate, $toDate);
	
	// Then get number of users in RM (will always just be 1 admin for pure AA licences)
	$userCounts = $dmsService->usageOps->getDMSUserCounts($account->id);
	$plainCounts = array();
	foreach ($userCounts as $countsRow) {
		$plainCounts[$countsRow['userType']] = $countsRow['users'];
	}
	// save as part of the account
	$account->userCounts = array();
	foreach (array(0, 1, 2, 3, 4) as $userType) {
		if (isset($plainCounts[$userType])) {
			$account->userCounts[$userType] = $plainCounts[$userType];
		} else {
			$account->userCounts[$userType] = 0;
		}
	}
	
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
	$conditions['selfHost'] = false;
	$testingAccounts = null;
	//$testingAccounts = array(1,2,3,4,5,6,163,10715,11078,11811,13847);
	//$testingAccounts = array(163);
	//$testingAccounts = array(13847);
	//$sortOrder = array('name');
	//$sortOrder = array('expiryDate');
	$sortOrder = null;
	$accounts = $dmsService->accountOps->getAccounts($testingAccounts, $conditions, $sortOrder);
	$fromDate = date("Y-m-d", addDaysToTimestamp(time(), -30)).' 00:00:00';
	$toDate = date("Y-m-d").' 23:59:59';
	$fromDate = '2010-09-01 00:00:00';
	$toDate = '2010-09-30 23:59:59';
	//$fromDate = '2010-09-30 00:00:00';
	$oneMonthAgo = date("Y-m-d", addDaysToTimestamp(time(), -30)).' 00:00:00';
	
	if ($accounts) {
		// For Early Warning I want to display different stuff for each account
		// 	for accounts in their first month I want to know about any activity
		//	for AA accounts I would like to see recent failed logins
		//	for LT I would like to know if they are getting near to filling up their licence
		
		// So start by running through each account and getting all the statistics for it.
		foreach ($accounts as $account) {
			addFullActivityStats($account, $fromDate, $toDate);
		}
		
		// Next we will run a series of loops that check each account to see if it falls in a particular 
		// reporting category and layout those accounts that do. I think we will want to only include
		// each account in one category (even if it is valid for two). So the most important categories
		// are run first. This is mainly because a new account is likely to come up a lot in 'underused' categories.
		// BUT we certainly need to build the report with categories grouped... See below for a sorting method.
		
		// It would be good if the EWS report had sections that could be hidden/shown so 
		// that it is easy to look at a particular category.
		
		foreach ($accounts as $account) {
			// Category 1. Accounts that have been running for less than a month.
			// You have to measure this based on the RM licence start date.
			$newAccount = false;
			foreach ($account->titles as $title) {
				if ($title->productCode == 2) {
					// Whilst we are looking at the RM, lets save its start and expiry date as the account expiry date
					// to save future loops
					$account->expiryDate = $title->expiryDate;
					// Then we can check if this is a new account
					//echo $title->licenceStartDate.', '.$oneMonthAgo;
					if ($title->licenceStartDate > $oneMonthAgo) {
						$account->startDate = $title->licenceStartDate;
						$newAccount = true;
					}
					break 1;
				}
			}
			//echo "expiry for $account->id is $account->expiryDate";
			if ($newAccount) {
				$account->templateDetail = '1newAccount';
			
			// Category 2. Accounts that have failed logins due to licence full in the last month.
			} elseif ($account->failedSessionCount>3) {
				$account->templateDetail = '50failedSessionsAccount';			
			
			// Category 9a. LT general accounts
			} elseif ($account->licenceType==1) {
				$account->templateDetail = '90standardLTAccount';			
			
			// Category 9b. AA general accounts
			} elseif ($account->licenceType==2) {
				$account->templateDetail = '91standardAAAccount';			
			
			// Category 9b. CT general accounts
			} elseif ($account->licenceType==4) {
				$account->templateDetail = '92standardCTAccount';			
			
			// Everyone else
			} else {
				$account->templateDetail = '99standardAccount';			
			}
		}
		
		// At this point the accounts array is categorised, now we just need to sort it
		uasort($accounts, array("account", "compareTemplates"));
		// We also want to sort by expiry date.
		uasort($accounts, array("account", "compareExpiryDates"));
		
		// This is a good way if all accounts use one template. Or if we have a template built of header/footer and then other templates
		// An alternative is to turn the accounts into xml and then use xsl layout.
		// 100.tpl was simple table, 101 uses jQuery for an accordion
		echo $dmsService->templateOps->fetchTemplate("dms_reports/101", array("accounts" => $accounts));
	} else {
		echo "no active accounts found";
	}
	
}

exit(0);
?>

