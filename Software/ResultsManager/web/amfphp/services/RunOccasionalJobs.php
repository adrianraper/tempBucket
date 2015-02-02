<?php
/*
 * This script is run by the cronjob on a daily basis, but triggers occasional events
 */

/*
 * Occasional jobs include 
 *   averaging scores per country
 */
set_time_limit(6000);

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

function runOccasionalJobs($period) {
	global $thisService;
	global $newLine;
	
	switch ($period) {
		case 'yearly':
		case 'weekly':
		case 'oneoff':
			break;
		case 'monthly':
			/*
			 * This averages all scores for a title in all countries and populates T_ScoreCache
			 */
			$productCodes = array(52,53);
			$from = new DateTime();
			// The default is to take the last year's data
			$fromDate = $from->sub(new DateInterval('P1Y'))->format('Y-m-d');
			$toDate = null;
			$rc = $thisService->dailyJobOps->averageCountryScores($productCodes, $fromDate, $toDate);
			$now = new DateTime();
			$today = $now->format('Y-m-d');
			echo "Added average scores to the cache $today $rc $newLine";
			break;
		default:
	}	
}

// Action
$oneoff = false;

// If you are running a one-off job, don't trigger the other regular actions
if ($oneoff) {
	runOccasionalJobs("oneoff");
} else {
	// Is today the first of the year?
	if (date("j")==1 && date("n")==1) {
		runOccasionalJobs("yearly");
	}
	// Is today the first of the month?
	if (date("j")==1) {
		runOccasionalJobs("monthly");
	}
	// Is today Monday (considered first day of the week by Clarity for everyone - apologies to UAE)
	if (date("w")==1) {
		runOccasionalJobs("weekly");
	}
}

flush();
exit(0);
