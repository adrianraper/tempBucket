<?php
/*
 * This is not really an AMFPHP service but its in this folder to maintain path integrity in all of the require_once calls.
 * Since there are no classes or methods here it does not represent a security risk.
 */

/*
 * The purpose of this script is to do something to accounts already in DMS
 */
require_once(dirname(__FILE__)."/DMSService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");

$dmsService = new DMSService();
session_start();
date_default_timezone_set('UTC');

// new function to ensure that we are running with the right dateformat
if (strpos($GLOBALS['db'],"mssql")!==false) {
	$sql = <<<EOD
			set dateformat ymd
EOD;
	$dmsService->db->Execute($sql);
}
echo "database is ".$GLOBALS['db']."<br/>";

if (!Authenticate::isAuthenticated()) {
	// v3.1 This script always requires authentication.
	//throw new Exception("You are not logged in.");
}

// Core function is to do something to selected account.
function updateAccount($account, $template=null) {
	global $dmsService;
	// use different files for different purposes to build the $account object
	//require_once(dirname(__FILE__)."accountUpdateAddTitles.php");
	accountUpdateChangeExpiryDate($account);
	//accountUpdateSwitchSSSV9($account, $template);
}

function accountUpdateChangeExpiryDate($account) {
	global $dmsService;
	foreach ($account->titles as $title) {
		$rootID = $account->id;
		// v3.3 Before you create the checksum, make sure that the expiry date has been altered to 23:59:59
		//$title-> expiryDate = substr($title->expiryDate, 0, 10).' 23:59:59';
		$title->expiryDate = '2011-12-31 23:59:59';
		$title->licenceStartDate = substr($title->licenceStartDate, 0, 10).' 00:00:00';
		
		$checkSum = $dmsService->accountOps->generateChecksumForTitle($title, $account);
		$productCode = $title-> productCode;
		$sql = 	<<<EOD
				UPDATE T_Accounts 
				SET F_Checksum = ?,
					F_ExpiryDate = ?,
					F_LicenceStartDate = ?
				WHERE F_RootID = ? 
				AND F_ProductCode=?
EOD;
		$dmsService->db->Execute($sql, array($checkSum, $title->expiryDate, $title->licenceStartDate, $rootID, $productCode));
		echo "&nbsp;&nbsp;&nbsp;$rootID {$title->name}, $productCode, $checkSum<br/>";
	}
}

function specificEmail($account, $templateID) {
	global $dmsService;
	// Check that the template exists
	if (!$dmsService->templateOps->checkTemplate('emails', $templateID)) {
		echo "This template doesn't exist. /emails/$templateID";
		return;
	}

	// CC email if it exists
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
						
	if (isset($_REQUEST['send']) || !isset($_SERVER["SERVER_NAME"])) {
		$dmsService->emailOps->sendEmails("", $templateID, array($emailArray));
		echo "<b>Email: ".$account->adminUser->email."</b><br/>";
	} else {
		//echo "<b>$account->id, email: ".$account->adminUser->email."</b><br/><br/>".$dmsService->emailOps->fetchEmail($templateID, array("account" => $account))."<hr/>";
		echo "<b>$account->id, $account->name, email: ".$account->adminUser->email."</b><br/><br/>";
	}
}

function accountUpdateSwitchSSSV9($account, $template) {
	global $dmsService;
	// Here I switch SSS to SSSV9. 
	//
	// Rules:
	// - Active accounts only
	// - Not distributors or individuals
	// - Not a whitelist of accounts that have requested a delay
	// - Also should have ignored self-hosting, but I didn't
	// Hong Kong Baptist University Library
	// Lingnan University Library
	// Universite Nancy 2 - Kangaroo
	// City of Bath College
	$whiteList = array(13208, 10537, 11660, 13216); 
	if (in_array($account->id, $whiteList)) {
		echo $account->name." has requested delayed switching<br/>";
		return false;
	}

	// What happens:
	// - If got SSS, add SSSV9 with all the same parameters
	// - Change SSS expiry date to May 11th 2011 (today)
	// - Generate an email to the customer telling them what happened

	// Before this script:
	//   You come into this script only for accounts that have the following conditions:
	//	$conditions['active'] = true;
	//	$conditions['notLicenceType'] = 5; // CE.com
	//	$conditions['accountType'] = 1; // Standard invoice (ignores trials, distributors etc)

	// First, make sure that the account DOESN'T already have SSSV9. If it does, assume that we manually sorted it out and leave alone.
	foreach ($account->titles as $title) {
		if ($title->productCode == 49) {
			// Leave this function immediately
			echo $account->name." already has SSSV9 so leave it alone<br/>";
			return false;
		}
	}
	
	// Find any existing SSS and copy the parameters
	$hasSSS=false;
	foreach ($account->titles as $title) {
		if ($title->productCode == 3) {
			$SSSV9title = new Title();
			$SSSV9title->productCode = 49;
			$SSSV9title->maxStudents = $title->maxStudents;
			$SSSV9title->maxAuthors = $title->maxAuthors;
			$SSSV9title->maxReporters = $title->maxReporters;
			$SSSV9title->maxTeachers = $title->maxTeachers;
			$SSSV9title->contentLocation = null;
			$SSSV9title->expiryDate = $title->expiryDate;
			$SSSV9title->licenceStartDate = $title->licenceStartDate;
			$SSSV9title->licenceType = $title->licenceType;
			$SSSV9title->languageCode = $title->languageCode;
			$account->titles[] = $SSSV9title;
			
			// And set the old SSS expiry date to today (make sure that this isn't copied by reference to the new title)
			$title->expiryDate = date('Y-m-d').' 23:59:59';
			$hasSSS=true;
			break;
		}
	}
	if (!$hasSSS) return false;
	//echo "$account->name<br/>";

	// I don't understand why, but if I don't set this session variable I get a warning
	Session::set('rootID', $account->id);

	// If you are not sending out an email, then don't actually update the database
	if (isset($_REQUEST['send']) || !isset($_SERVER["SERVER_NAME"])) {
		// This does far more than we really need - but is easy to call.
		$accounts = $dmsService-> updateAccounts(array($account));
	}

	// Then send the email (shows how clumsy this sort of include file is!)
	specificEmail($account, $template);
}

$purpose = "";
//$purpose .= "System";
//$purpose .= "SSSV9 Upgrade";
$purpose .= "change expiry dates";
if (stristr($purpose, "SSSV9 Upgrade")) {
	// These are not sent through triggers but programmatically
	$conditions['active'] = true; // When you combine 'active' with a product code, it is that product's expiry date that we check
	$conditions['notLicenceType'] = 5; // CE.com
	//$conditions['licenceType'] = 5; // CLS.com
	$conditions['accountType'] = 1; // Standard invoice (ignores trials, distributors etc)
	//$conditions['productCode'] = 3; // existing SSS. You can't do this as I want to test if SSSV9 is already there and this excludes it
	if (isset($_REQUEST['template'])) {
		$templateID = $_REQUEST['template'];
	} else {
		$templateID = 'switch_SSSV9_May2011';
	}
	// A list of roots just for testing
	$testingAccounts = null;
	//$testingAccounts = array(47,163,13847);

	$accounts = $dmsService->accountOps->getAccounts($testingAccounts, $conditions);
	//$accounts = $dmsService->accountOps->getAccounts(array(1), $conditions);
	if ($accounts) {
		//echo count($accounts)."<br/>";
		foreach ($accounts as $account) {
			// If you want to limit to particular roots for testing (very clumsy way of doing this, should be able to add to conditions)
			if (isset($_REQUEST['rootID']) && $_REQUEST['rootID'] > 0) {
				if ($account->id == $_REQUEST['rootID']) {
					updateAccount($account, $templateID);
					// Then break as you don't want anymore
					break;
				//} else {
					//echo "no match for $account->id against ".$_REQUEST['rootID']."<br/>";
				}
			// Or to do it in batches. First, just a start root
			} else if ((isset($_REQUEST['startRootID']) && $_REQUEST['startRootID'] > 0) &&
					!isset($_REQUEST['stopRootID'])){
				if ($account->id >= $_REQUEST['startRootID']) {
					updateAccount($account, $templateID);
				//} else {
					//echo "no match for $account->id against ".$_REQUEST['rootID']."<br/>";
				}
			// Next, just a stop root
			} else if ((isset($_REQUEST['stopRootID']) && $_REQUEST['stopRootID'] > 0) &&
					!isset($_REQUEST['startRootID'])){
				if ($account->id <= $_REQUEST['stopRootID']) {
					updateAccount($account, $templateID);
				//} else {
					//echo "no match for $account->id against ".$_REQUEST['rootID']."<br/>";
				}
			// Finally, both start and stop
			} else if ((isset($_REQUEST['stopRootID']) && $_REQUEST['stopRootID'] > 0) &&
					(isset($_REQUEST['startRootID']) && $_REQUEST['startRootID'] > 0)){
				if ($account->id >= $_REQUEST['startRootID'] &&
					$account->id <= $_REQUEST['stopRootID']) {
					updateAccount($account, $templateID);
				//} else {
					//echo "no match for $account->id against ".$_REQUEST['rootID']."<br/>";
				}
			} else {
				updateAccount($account, $templateID);
			}			
		}
	} else {
		echo "no accounts found";
	}
}
if (stristr($purpose, "change expiry dates")) {
	// These are not sent through triggers but programmatically
	//$conditions['active'] = true; // When you combine 'active' with a product code, it is that product's expiry date that we check
	$conditions['notLicenceType'] = 5; // CE.com
	//$conditions['licenceType'] = 5; // CLS.com
	$conditions['accountType'] = 1; // Standard invoice (ignores trials, distributors etc)
	// A list of roots just for testing
	$testingAccounts = null;
	//$testingAccounts = array(47,163,13847);
	$templateID=null;

	$accounts = $dmsService->accountOps->getAccounts($testingAccounts, $conditions);
	//$accounts = $dmsService->accountOps->getAccounts(array(1), $conditions);
	if ($accounts) {
		//echo count($accounts)."<br/>";
		foreach ($accounts as $account) {
			updateAccount($account, $templateID);
		}			
	} else {
		echo "no accounts found";
	}
}

exit(0);
?>