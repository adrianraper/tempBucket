<?php
/*
 * This script is run by the cronjob on a daily basis.
 */

/*
 * Daily jobs include 
 * archiving expired users from GlobalRoadToIELTS and global_r2iv2
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
	if (isset($_SERVER["SERVER_NAME"])) {
		echo "<h2>You are not logged in</h2>";
		exit(0);
	}
}
// Set up line breaks for whether this is outputting to html page or a text file
if (isset($_SERVER["SERVER_NAME"])) {
	$newLine = '<br/>';
} else {
	$newLine = "\n";
}

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

	// Archive expired users for Road to IELTS Last Minute
	// Need date as simple Y-m-d
	$expiryDate = date('Y-m-d', $triggerDate);

	// For the old database
	$database = 'GlobalRoadToIELTS';
	$usersMoved = $thisService->internalQueryOps->archiveExpiredUsers($expiryDate, $database);
	echo "Moved $usersMoved users from $database to expiry table. $newLine";
	
	// For the new database
	$database = 'global_r2iv2';
	$usersMoved = $thisService->internalQueryOps->archiveExpiredUsers($expiryDate, $database);
	echo "Moved $usersMoved users from $database to expiry table. $newLine";
	
	// Archive expired titles from accounts
	// We want to archive 1 month after expiry, so send in 1 month ago as the date
	$expiryDate = date('Y-m-d', addDaysToTimestamp($triggerDate, -31));
	$database = 'rack80829';
	$accountsMoved = $thisService->internalQueryOps->archiveExpiredAccounts($expiryDate, $database);
	echo "Moved $accountsMoved titles from $database to expiry table for $expiryDate. $newLine";
}

// Action
if (isset($_REQUEST['date'])) {
	runDailyJobs(addDaysToTimestamp(time(), intval($_REQUEST['date']))); // 1=tomorrow, -1=yesterday
} else {
	runDailyJobs();
}

flush();
exit(0);
