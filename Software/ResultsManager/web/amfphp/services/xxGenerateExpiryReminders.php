<?php
/*
 * This is not really an AMFPHP service but its in this folder to maintain path integrity in all of the require_once calls.
 * Since there are no classes or methods here it does not represent a security risk.
 */
require_once(dirname(__FILE__)."/DMSService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");

$dmsService = new DMSService();

function addDaysToTimestamp($timestamp, $days) {
	return date("Y-m-d", $timestamp + ($days * 86400));
}

function emailExpiredAccounts($days, $template, $opts = null) {
	global $dmsService;
	
	// Accounts expiring in $days time (note that $days can be negative!)
	//$accounts = $dmsService->accountOps->getAccounts(null, addDaysToTimestamp(time(), $days));
	$accountConditions = array();
	$accountConditions["expiryDate"] = addDaysToTimestamp(time(), $days);
	$accounts = $dmsService->accountOps->getAccounts(null, $accountConditions);
	
	// If the request variable 'send' is not defined then just print the emails to the screen, don't actually send anything.  This is to
	// prevent accidental sends when testing!
	if (isset($_REQUEST['send'])) {
		// Arrange the accounts into a $emailArray ready to pass to sendEmails
		$emailArray = array();
		foreach ($accounts as $account)
			$emailArray[] = array("to" => $account->email, "data" => array("account" => $account, "opts" => $opts));
			
		// Send the emails
		$dmsService->emailOps->sendEmails("", $template, $emailArray);
	} else {
		foreach ($accounts as $account)
			echo "<b>".$account->email.":</b><br/><br/>".$dmsService->emailOps->fetchEmail($template, array("account" => $account, "opts" => $opts))."<hr/>";
	}
	
}

session_start();

// Search for accounts that fall between certain expiry dates.  emailExpiredAccounts takes an optional parameter with which you can pass
// in a string - I have used this to pass in the expiry message, but you could just as well use different templates or take this from
// CopyOps or do whatever you like.
emailExpiredAccounts(30, "expiry_reminder", array("tagline" => "The following products will expire in one month:"));
emailExpiredAccounts(7, "expiry_reminder", array("tagline" => "The following products will expire in one week:"));
emailExpiredAccounts(0, "expiry_reminder", array("tagline" => "The following products expire today:"));
emailExpiredAccounts(-7, "expiry_reminder", array("tagline" => "The following products expired a week ago:"));

exit(0)
?>