<?php
/*
 * This script is run by the cronjob on an hourly basis.
 */

/*
 * Hourly jobs include
 *   imposing a saved hidden content pattern on a group and all its current subgroups
 *
 */
require_once(dirname(__FILE__)."/MinimalService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");

ini_set('max_execution_time', 300); // 5 minutes

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
function runHourlyJobs($triggerDate = null) {
	global $thisService;
	global $newLine;
	
	// Pick up all triggers that are valid on the given date (usually this is going to be today)
	if (!$triggerDate) $triggerDate = time();

	// For VUS, impose a saved pattern of hidden content on a group and it's subgroups
	$group = 100477;
    $group = 21560;
	$groups = $rc = $thisService->dailyJobOps->imposeHiddenContent($group);
	echo "Imposed hidden content on $groups. $newLine";
    $group = 100430;
    $groups = $rc = $thisService->dailyJobOps->imposeHiddenContent($group);
    echo "Imposed hidden content on $groups. $newLine";
    $group = 100431;
    $groups = $rc = $thisService->dailyJobOps->imposeHiddenContent($group);
    echo "Imposed hidden content on $groups. $newLine";

}

// Action
if (isset($_REQUEST['date'])) {
	runHourlyJobs(addDaysToTimestamp(time(), intval($_REQUEST['date']))); // 1=tomorrow, -1=yesterday
} else {
	runHourlyJobs();
}

flush();
exit(0);
