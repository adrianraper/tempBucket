<?php
/*
 * This script is run by the cronjob on a daily basis.
 */

/*
 * Daily jobs include 
 * archiving expired users from GlobalRoadToIELTS and global_r2iv2 - stopped 18 Dec 2012
 * archiving expired users from rack80829
 * archiving sent emails from T_PendingEmails
 */
set_time_limit(300);

require_once(dirname(__FILE__)."/MinimalService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");

// Don't get fooled by old session variables
if (isset($_SESSION['dbHost'])) unset($_SESSION['dbHost']);
if (isset($_REQUEST['dbHost'])) $_SESSION['dbHost']=$_REQUEST['dbHost'];

$thisService = new MinimalService();

date_default_timezone_set('UTC');
if (!Authenticate::isAuthenticated()) {
	// TODO: Replace with text from literals
	// v3.0.6 This script may be run by CRON too, in which case skip authentication. How to tell?
	/*
	if (isset($_SERVER["SERVER_NAME"])) {
		echo "<h2>You are not logged in</h2>";
		exit(0);
	}
	*/
}
// Set up line breaks for whether this is outputting to html page or a text file
if (isset($_SERVER["SERVER_NAME"])) {
	$newLine = '<br/>';
} else {
	$newLine = "\n";
}

// NOTE: Sometime convert all away from timestamps to DateTime objects
function addDaysToTimestamp($timestamp, $days) {
	//return date("Y-m-d", $timestamp + ($days * 86400));
	return $timestamp + ($days * 86400);
}

// Maybe I will want to be able to pass an array of triggers to this as well as getting all of them
function runDailyJobs($triggerDate = null) {
	global $thisService;
	global $newLine;
	
	// Pick up all triggers that are valid on the given date (usually this is going to be today)
	if (!$triggerDate) $triggerDate = time();

	// 1. Archive expired users for Road to IELTS Last Minute
	
	// Need date as simple Y-m-d
	$expiryDate = date('Y-m-d', $triggerDate);

	/*
	// For the Road to IELTS Last Minute accounts in the merged database
	$database = 'rack80829';
	$roots = array(100,101,167,168,169,170,171,14028,14030,14031);
	$usersMoved = $thisService->dailyJobOps->archiveExpiredUsers($expiryDate, $roots, $database);
	echo "Moved $usersMoved users from $database to expiry table. $newLine";
	*/
	/*
	// 2. Archive expired titles from accounts
	
	// We want to archive 1 month after expiry, so send in 1 month ago as the date
	$expiryDate = date('Y-m-d', addDaysToTimestamp($triggerDate, -31));
	$database = 'rack80829';
	$accountsMoved = $thisService->dailyJobOps->archiveExpiredAccounts($expiryDate, $database);
	echo "Moved $accountsMoved titles from $database to expiry table for $expiryDate. $newLine";	
	
	// 3. Archive older users from some roots

	// We want to archive users who took their test more than 3 months ago from LearnEnglish accounts
	$regDate = date('Y-m-d', addDaysToTimestamp($triggerDate, -92));
	$roots = array(13982,14084,16180,14987);
	$rc = $thisService->dailyJobOps->archiveOldUsers($roots,$regDate);
	echo "Archived $rc LearnEnglish level test users who registered before $regDate. $newLine";	
	
	*/
	// 4. EmailMe for Rotterdam
	/*
	// First task is to find units that start today, get all users in the groups the units are published for
	// and send out the email.
	// Date is UTC and this job runs at 16:00 UTC. So it should be based on units starting tomorrow.
	// This means that Vancouver students will see the email the day before the unit is available, so wording
	// in the email needs to include the date rather than 'now/today'.
	$courseDate = date('Y-m-d', addDaysToTimestamp($triggerDate, 1));
	$templateID = 'CCB/EmailMeUnitStart';
	$emailArray = $thisService->dailyJobOps->getEmailsForGroupUnitStart($courseDate);
	if (isset($_REQUEST['send']) || !isset($_SERVER["SERVER_NAME"])) {
		// Send the emails
		$thisService->emailOps->sendEmails("", $templateID, $emailArray);
		echo "Queued ".count($emailArray)." emails for units starting $courseDate. $newLine";
			
	} else {
		// Or print on screen
		echo count($emailArray)." emails for units starting $courseDate. $newLine";
		foreach($emailArray as $email) {
			echo "<b>Email: ".$email["to"]."</b>".$newLine.$thisService->emailOps->fetchEmail($templateID, $email["data"])."<hr/>";
		}
	}
	*/
	/*
	// Then repeat for courses that are published to start whenever a user first goes into them
	$templateID = 'EmailMeUserFirstStart';
	$emailArray = $thisService->dailyJobOps->getEmailsForUserFirstStart($expiryDate);
	if (isset($_REQUEST['send']) || !isset($_SERVER["SERVER_NAME"])) {
		// Send the emails
		$thisService->emailOps->sendEmails("", $trigger->templateID, $emailArray);
		echo "Sent ".count($emailArray)." emails for users starting $expiryDate. $newLine";
			
	} else {
		// Or print on screen
		foreach($emailArray as $email) {
			echo "<b>Email: ".$email["to"]."</b>".$newLine.$thisService->emailOps->fetchEmail($templateID, $email["data"])."<hr/>";
		}
	}
	*/
	/*
	// 5. Archive sent emails

	// Clean up the T_PendingEmails, remove everything that has been sent
	$database = 'rack80829';
	$rc = $thisService->dailyJobOps->archiveSentEmails($database);
	echo "Archived $rc sent emails. $newLine";

	// 6. Count the amount of CCB material and activity for each account

	// Grab the materials data from XML, session data from SQL and write summary to the db
	$database = 'rack80829';
	$rc = $thisService->dailyJobOps->monitorCBBActivity($database);
	echo "$rc accounts active yesterday. $newLine";	
	*/
	
	// 7. Update TB6weeks bookmarks 
	// a. Loop round all accounts that have productCode=59 (and are active)
	$productCode = 59;
	$trigger = new Trigger();
	$trigger->templateID = 'user/TB6weeksNewUnit';
	$trigger->parseCondition("method=getAccounts&accountType=1&active=true&productCode=$productCode");
	//$trigger->condition->customerType = '1'; // If we want to limit this to libraries
		
	$triggerResults = $thisService->triggerOps->applyCondition($trigger, $triggerDate);
	foreach ($triggerResults as $account) {
		
		// b. For each user in this account, update their subscription, if they have one.
		echo "check account ".$account->prefix."$newLine";
		$emailArray = $thisService->dailyJobOps->updateSubscriptionBookmarks($account, $productCode, $triggerDate);
		if (isset($_REQUEST['send']) || !isset($_SERVER["SERVER_NAME"])) {
			// Send the emails
			$thisService->emailOps->sendEmails("", $trigger->templateID, $emailArray);
			echo "Sent ".count($emailArray)." emails for users starting $expiryDate. $newLine";
				
		} else {
			// Or print on screen
			foreach($emailArray as $email) {
				echo "<b>Email: ".$email["to"]."</b>".$newLine.$thisService->emailOps->fetchEmail($trigger->templateID, $email["data"])."<hr/>";
			}
		}
	}
	
}

// Action
if (isset($_REQUEST['date'])) {
	runDailyJobs(addDaysToTimestamp(time(), intval($_REQUEST['date']))); // 1=tomorrow, -1=yesterday
} else {
	runDailyJobs();
}

flush();
exit(0);
