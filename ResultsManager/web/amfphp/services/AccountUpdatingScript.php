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


if (!Authenticate::isAuthenticated()) {
	// v3.1 This script always requires authentication.
	//throw new Exception("You are not logged in.");
}

// Core function is to do something to all accounts.
function updateAccounts($accountIDArray = null, $conditions=null) {
	//echo "addAccountFromPaymentGateway"; 
	global $dmsService;
	
	echo "database is ".$GLOBALS['db']."<br/>";
	$accounts = $dmsService-> accountOps->getAccounts($accountIDArray, $conditions);
	foreach ($accounts as $account) {
		echo "$account->name<br/>";
		/*
		// Here I add accounts to a root
		// Add iRead as a new title with a mix of default settings and some taken from the first content title
		$RMtitle = new Title();
		$RMtitle->productCode = 47;
		$RMtitle->maxStudents = 9999;
		$RMtitle->maxAuthors = 0;
		$RMtitle->maxReporters = 0;
		$RMtitle->maxTeachers = 0;
		$RMtitle->contentLocation = null;
		$RMtitle->expiryDate = $account->titles[0]->expiryDate;
		$RMtitle->licenceStartDate = $account->titles[0]->licenceStartDate;
		$RMtitle->licenceType = $account->titles[0]->licenceType;
		$RMtitle->languageCode = 'EN';
		$account->titles[] = $RMtitle;
		// and add IYJ
		$RMtitle1 = new Title();
		$RMtitle1->productCode = 38;
		$RMtitle1->maxStudents = 9999;
		$RMtitle1->maxAuthors = 0;
		$RMtitle1->maxReporters = 0;
		$RMtitle1->maxTeachers = 0;
		$RMtitle1->contentLocation = null;
		$RMtitle1->expiryDate = $account->titles[0]->expiryDate;
		$RMtitle1->licenceStartDate = $account->titles[0]->licenceStartDate;
		$RMtitle1->licenceType = $account->titles[0]->licenceType;
		$RMtitle1->languageCode = 'EN';
		$account->titles[] = $RMtitle1;
		// and add IYJ
		$RMtitle2 = new Title();
		$RMtitle2->productCode = 1001;
		$RMtitle2->maxStudents = 9999;
		$RMtitle2->maxAuthors = 0;
		$RMtitle2->maxReporters = 0;
		$RMtitle2->maxTeachers = 0;
		$RMtitle2->contentLocation = null;
		$RMtitle2->expiryDate = $account->titles[0]->expiryDate;
		$RMtitle2->licenceStartDate = $account->titles[0]->licenceStartDate;
		$RMtitle2->licenceType = $account->titles[0]->licenceType;
		$RMtitle2->languageCode = 'EN';
		$account->titles[] = $RMtitle2;
		
		// I don't understand why, but if I don't set this session variable I get a warning
		Session::set('rootID', $account->id);
		
		// This does far more than we really need - but is easy to call.
		$accounts = $dmsService-> updateAccounts(array($account));
		*/
		/*
		// Here I want to add Results Manager to any active, institutional account that doesn't have it
		$hasRM = false;
		foreach ($account->titles as $title) {
			if ($title-> productCode == 2) {
				$hasRM = true;
				break;
			}
		}
		if (!$hasRM) {
			echo "add RM for $account->name, $account->prefix<br/>";
			// Add RM as a new title with a mix of default settings and some taken from the first content title
			$RMtitle = new Title();
			$RMtitle->productCode = 2;
			$RMtitle->maxStudents = 0;
			$RMtitle->maxAuthors = 0;
			$RMtitle->maxReporters = 0;
			$RMtitle->maxTeachers = 1;
			$RMtitle->contentLocation = null;
			$RMtitle->expiryDate = $account->titles[0]->expiryDate;
			$RMtitle->licenceStartDate = $account->titles[0]->licenceStartDate;
			$RMtitle->licenceType = $account->titles[0]->licenceType;
			$RMtitle->languageCode = 'EN';
			$account->titles[] = $RMtitle;
			
			// I don't understand why, but if I don't set this session variable I get a warning
			Session::set('rootID', $account->id);
			
			// This does far more than we really need - but is easy to call.
			$accounts = $dmsService->updateAccounts(array($account));
		}
		*/
		// This section changing expiry dates and licence start dates, then checksumming
		
		foreach ($account->titles as $title) {
			$rootID = $account->id;
			// v3.3 Before you create the checksum, make sure that the expiry date has been altered to 23:59:59
			$title-> expiryDate = substr($title->expiryDate, 0, 10).' 23:59:59';
			$title-> expiryDate = '2011-12-31 23:59:59';
			$title-> licenceStartDate = substr($title->licenceStartDate, 0, 10).' 00:00:00';
			
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
			echo "&nbsp;&nbsp;&nbsp;$title->name, $productCode, $checkSum<br/>";
		}
		*/
	}
}
// Note that 'active' in a condition means any account with a title that has an expiry date in the future.
// It has nothing to do with the accountStatus field
$conditions['active'] = true;
//$conditions['notLicenceType'] = 5;
$accounts = null;
$accounts = array(18);
updateAccounts($accounts, $conditions);

exit(0);
?>