<?php
/*
 * This script will go through all applicable accounts and run some SQL on them
 */

require_once(dirname(__FILE__)."/DMSService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");

// Don't get fooled by old session variables
if (isset($_SESSION['dbHost'])) unset($_SESSION['dbHost']);
if (isset($_REQUEST['dbHost'])) $_SESSION['dbHost']=$_REQUEST['dbHost'];

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
function changeExpiryDate($account, $extension = '+1 month', $limit = null) {
	global $dmsService;
	$dmsService->db->StartTrans();
	
	foreach ($account->titles as $title) {
		$dbObj = $title->toAssocArray();
		if ($limit) {
			if ($title->expiryDate > $limit)
				continue 1;
		}
		// have you passed an extension period or a fixed date?
		if (validateDate($extension)) {
			$newExpiry = new DateTime($extension);
			$title->expiryDate = $newExpiry->format('Y-m-d 23:59:59');
		} else {
			$newExpiry = new DateTime($title->expiryDate);
			$extensionPeriod = DateInterval::createFromDateString($extension);
			$title->expiryDate = $newExpiry->add($extensionPeriod)->format('Y-m-d 23:59:59');
		}
		
		// If you want to hardcode any other change to all accounts
		// $title->maxStudents = 4999;
		
		// Then update the checksum for the new licence info
		$title->checksum = $dmsService->accountOps->generateChecksumForTitle($title, $account);
		
		$sql = 	<<<EOD
			update T_Accounts
			set F_ExpiryDate = ?, F_MaxStudents = ?, F_Checksum = ?
			where F_RootID = ?
			and F_ProductCode = ?
EOD;
		$rs = $dmsService->db->Execute($sql, array($title->expiryDate, $title->maxStudents, $title->checksum, $account->id, $dbObj['F_ProductCode']));
		if (!$rs)
			throw new Exception('problem updating records');
	}
	
	$rc = $dmsService->db->CompleteTrans();
	return $rc;
}

function validateDate($date, $format = 'Y-m-d') {
    $d = DateTime::createFromFormat($format, $date);
    return $d && $d->format($format) == $date;
}
function seedCoursePermission($courseID) {
	global $dmsService;
	// Does this course already have a permission set?
	$sql = <<<SQL
		SELECT * FROM T_CoursePermission c
		WHERE c.F_CourseID = ?
SQL;
	$bindingParams = array($courseID);
	$rs = $dmsService->db->Execute($sql, $bindingParams);

	if ($rs->recordCount() == 0) {
		$sql = <<<SQL
			INSERT INTO T_CoursePermission (F_CourseID, F_Editable)
			VALUES (?, TRUE) 
SQL;
		$bindingParams = array($courseID);
		$rs = $dmsService->db->Execute($sql, $bindingParams);
	}		
}
function seedCourseRole($courseID, $userID, $rootID) {
	global $dmsService;
	// Does this course already have an owner?
	$sql = <<<SQL
		SELECT * FROM T_CourseRoles c
		WHERE c.F_CourseID = ?
		AND c.F_Role = 1
SQL;
	$bindingParams = array($courseID);
	$rs = $dmsService->db->Execute($sql, $bindingParams);

	if ($rs->recordCount() == 0) {
		// Set the account administrator as the owner
		$sql = <<<SQL
			INSERT INTO T_CourseRoles (F_CourseID, F_UserID, F_Role, F_DateStamp)
			VALUES (?, ?, 1, NOW()) 
SQL;
		$bindingParams = array($courseID, $userID);
		$rs = $dmsService->db->Execute($sql, $bindingParams);
		
		// And a default collaborator role for all teachers (since this is what all courses are set at now)
		$sql = <<<SQL
			INSERT INTO T_CourseRoles (F_CourseID, F_RootID, F_Role, F_DateStamp)
			VALUES (?, ?, 2, NOW()) 
SQL;
		$bindingParams = array($courseID, $rootID);
		$rs = $dmsService->db->Execute($sql, $bindingParams);
	}		
}
// If you want to run specific triggers for specific days (for testing)
// you can put 'date=-1' in the URL
$testingTriggers = "";
//$testingTriggers .= "Change expiry date";
//$testingTriggers .= "Add RM to all accounts";
//$testingTriggers .= "terms and conditions";
$testingTriggers .= "Seed permissions and privacy for CCB";

if (stristr($testingTriggers, "Seed permissions and privacy for CCB")) {
	$conditions = array();
	$conditions['productCode'] = 54;
	$testingAccounts = null;
	//$testingAccounts = array(10719);
	$accounts = $dmsService->accountOps->getAccounts($testingAccounts, $conditions);
	if ($accounts) {
		foreach ($accounts as $account) {
			// get the prefix and the admin userID
			$prefix = $account->prefix;
			$userID = $account->adminUser->id;
			$rootID = $account->id;
			
			// read courses.xml for the account and seed each courseID into the tables
			echo "seeding for account {$account->name}<br/>";
			$filename = '../../'.$GLOBALS['ccb_data_dir']."/".$prefix.'/courses.xml';
			$xml = simplexml_load_file($filename);
			foreach ($xml->courses->course as $course) {
				$courseID = (string)$course['id'];
				seedCoursePermission($courseID);
				seedCourseRole($courseID, $userID, $rootID);
				echo "&nbsp;&nbsp;&nbsp;&nbsp;course $courseID<br/>";
			}
		}
	}
}

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

// HCT often changes expiry dates a few times around renewal season - but not for the R2I titles
if (stristr($testingTriggers, "Change expiry date")) {
	// Extension can be a period or fixed date
	$extension = "+1 month";
	$extension = "2014-12-31"; // MUST be Y-m-d format, no need for time
	$limit = '2013-12-31 23:59:59';  // MUST be Y-m-d 23:59:59 format, otherwise 00:00:00 assumed
	$conditions = array();
	// HCT colleges
	// $testingAccounts = array(14276,14277,14278,14279,14280,14281,14282,14283,14284,14286,14287,14288,14290,14291,14292);
	// BC R2I Last Minute
	// $testingAccounts = array(100,167,168,169,170,14030,14031);
	// Others expiring Dec 31 2013
	// $testingAccounts = array(13744,14182,14326,14926);
	// Providence University Taiwan
	// $testingAccounts = array(14818);
	// BC LELT self hosted accounts
	$testingAccounts = array(1,14028,14029,14030,14031,14032);
	$accounts = $dmsService->accountOps->getAccounts($testingAccounts, $conditions);
	
	if ($accounts) {
		// Need to add usage stats to each title in each account
		foreach ($accounts as $account) {
			// Do some error checking for testing accounts that might be a bit odd, like not having any titles
			if (count($account->titles)<1)
				continue 1;
			if (changeExpiryDate($account, $extension, $limit)) {
				echo "Changed expiry date for {$account->name}<br/>";
			} else {
				echo "Failed to change expiry date for {$account->name}<br/>";
			}
		}
		
	} else {
		echo "no active accounts found";
	}
	
}

exit(0);
