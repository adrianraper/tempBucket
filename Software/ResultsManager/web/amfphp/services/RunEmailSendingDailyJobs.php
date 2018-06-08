<?php
/*
 * This script is run by the cronjob on a daily basis.
 */

/*
 * m#286 Daily jobs that send emails
 *   obsolete Rotterdam EmailMe
 *   Tb6weeks notifications
 *   DPT completed tests
 */

require_once(dirname(__FILE__)."/MinimalService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");

// Don't get fooled by old session variables
if (isset($_SESSION['dbHost'])) unset($_SESSION['dbHost']);
if (isset($_REQUEST['dbHost'])) $_SESSION['dbHost']=$_REQUEST['dbHost'];

$thisService = new MinimalService();
set_time_limit(300); // 5 mins of online processing

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
    set_time_limit(3600); // 1 hour of batch processing
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
    $now = new DateTime();
    echo "email sending script time " . $now->format("H:i:s") . "$newLine";
	*/
	// 7. Update TB6weeks bookmarks
	// a. Loop round all accounts that have productCode=59 (and are active)
	$productCode = 59;
	$trigger = new Trigger();
	$trigger->templateID = 'user/TB6weeksNewUnit';
	$trigger->parseCondition("method=getAccounts&active=true&productCode=$productCode");
	//$trigger->condition->customerType = '1'; // If we want to limit this to libraries
    if (isset($_REQUEST['rootID']) && $_REQUEST['rootID']>0) {
        $trigger->rootID = $_REQUEST['rootID'];
    }

    $triggerResults = $thisService->triggerOps->applyCondition($trigger, $triggerDate);
    echo "Check ".count($triggerResults)." TB6weeks accounts$newLine";
	foreach ($triggerResults as $account) {
		
		// b. For each user in this account, update their subscription, if they have one.
		$emailArray = $thisService->dailyJobOps->updateSubscriptionBookmarks($account, $productCode, $triggerDate);
		if (count($emailArray) > 0) {
            if (isset($_REQUEST['send']) || !isset($_SERVER["SERVER_NAME"])) {
                // Send the emails
                $thisService->emailOps->sendEmails("", $trigger->templateID, $emailArray);
                echo "TB6weeks account ".$account->prefix." sent ".count($emailArray)." emails$newLine";

            } else if (isset($_REQUEST['action']) && strtolower($_REQUEST['action'])=='summary') {
                // Or summarise on screen
                foreach($emailArray as $email) {
                    echo "<b>Email: ".$email["to"]."</b>$newLine";
                }
            } else {
                // Or print on screen
                foreach($emailArray as $email) {
                    echo "<b>Email: ".$email["to"]."</b>".$newLine.$thisService->emailOps->fetchEmail($trigger->templateID, $email["data"])."<hr/>";
                }
            }
		}
	}
    $now = new DateTime();
    echo "email sending script time " . $now->format("H:i:s") . "$newLine";

	// 10. List everyone who completed a test yesterday, to send the account manager an email
    // Get list of test completions ordered by account
    $dateNow = new DateTime("@$triggerDate");
    $shortTimeAgo = $dateNow->modify('-1day')->format('Y-m-d');
    $completedTests = $thisService->dailyJobOps->getCompletedTests($shortTimeAgo);
    $templateID = 'summaries/dptCompletedTests';

    $matchRootId = (isset($_REQUEST['rootID']) && $_REQUEST['rootID'] > 0) ? $_REQUEST['rootID'] : null;

    // Pull out the unique accounts
    $lastId = 0;
    $roots = array_unique(array_map(function($completedTest) {
                return $completedTest->rootId;
        }, $completedTests));

    // b. For each account, see if they want a summary email of completions
    foreach ($roots as $root) {
        if ($matchRootId && $root!=$matchRootId)
            continue;

        $account = $thisService->manageableOps->getAccountRoot($root);

        $requireSummaryEmail = $thisService->dailyJobOps->requireSummaryTestEmail($root);
        if ($requireSummaryEmail) {
            $adminUser = $thisService->manageableOps->getUserByIdNotAuthenticated($account->getAdminUserID());
            $emailData = array("user" => $adminUser,
                               "fromDate" => $shortTimeAgo,
                               "completedTests" => $thisService->dailyJobOps->collateTestEmails($root, $completedTests));
            $thisEmail = array("to" => $adminUser->email, "data" => $emailData);
            $emailArray[] = $thisEmail;
            if (isset($_REQUEST['send']) || !isset($_SERVER["SERVER_NAME"])) {
                // Send the emails
                $thisService->emailOps->sendEmails("", $templateID, $emailArray);
                echo "DPT results email to " . $account->name . "$newLine";

            } else {
                // Or print on screen
                echo $thisService->emailOps->fetchEmail($templateID, $thisEmail["data"]) . "<hr/>";
            }
        }
    }
}

// Action
$now = new DateTime();
echo "email sending script started at " . $now->format("Y-m-d H:i:s") . "$newLine";
if (isset($_REQUEST['date'])) {
	runDailyJobs(addDaysToTimestamp(time(), intval($_REQUEST['date']))); // 1=tomorrow, -1=yesterday
} else {
	runDailyJobs();
}
$now = new DateTime();
echo "email sending script ended at ... " . $now->format("H:i:s") . "$newLine";
flush();
exit(0);
