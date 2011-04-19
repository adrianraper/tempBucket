<?php
/*
 * This script is run manually for testing
 */

/*
 * Triggers include: 
 * email templates that need to be sent when something happens or becomes true
 * database updates that are fired when something happens
 */

require_once(dirname(__FILE__)."/DMSService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");

$dmsService = new DMSService();

session_start();
date_default_timezone_set('UTC');
if (!Authenticate::isAuthenticated()) {
	// TODO: Replace with text from literals
	// v3.0.6 This script may be run by CRON too, in which case skip authentication. How to tell?
	if (isset($_SERVER["SERVER_NAME"])) {
		echo "<h2>You are not logged in</h2>";
		exit(0);
	}
}

function addDaysToTimestamp($timestamp, $days) {
	//return date("Y-m-d", $timestamp + ($days * 86400));
	return $timestamp + ($days * 86400);
}

// Maybe I will want to be able to pass an array of triggers to this as well as getting all of them
function runTriggers($triggerIDArray = null, $triggerDate = null, $frequency = null) {
	//echo "runTriggers"; 
	global $dmsService;
	
	// Pick up all triggers that are valid on the given date (usually this is going to be today)
	if (!$triggerDate) $triggerDate = time();
	
	// Do you want to default to daily triggers, or simply pull out all of them?
	//if (!$frequency) $frequency= "daily";
	
	// You may limit the triggers to those in an array of IDs
	$triggers = $dmsService->triggerOps->getTriggers($triggerIDArray, $triggerDate, $frequency);
	//echo 'got '.count($triggers) .' triggers'."<br/>";

	// Run the condition of each trigger against the database and pull back all objects that meet the condition
	foreach ($triggers as $trigger) {
		echo 'trigger '.$trigger->name."<br/>";
		// This should go into triggerOps I think.
		// If you want to override the root for testing do it here, or from the URL
		// Also see EmailToAllActiveAccounts for startRootID and stopRootID
		if (isset($_REQUEST['rootID']) && $_REQUEST['rootID']>0) {
			$trigger->rootID=$_REQUEST['rootID'];
		//} else {
		//	$trigger->rootID=163;
		}
		$triggerResults = $dmsService->triggerOps->applyCondition($trigger, $triggerDate);
		echo 'got '.count($triggerResults) .' accounts for '.$trigger->name.'<br/>';
		
		// Now send all the matched objects to the executor with the templateID
		switch ($trigger->executor) {
			case "sql":
				// the results will be a recordset based on the condition
				if ($trigger->condition->update) {
					// This assumes that the select returns the keys to feed into the update
					// Do this so that you can log what the select returns
					//$roots = Array();
					foreach ($triggerResults as $record) {
						echo "root=".$record['F_RootID']."</br>";
						//$roots[] = $record['F_RootID'];
					}
					$dmsService->triggerOps->updateDatabase($trigger->condition->update);
				}
				// and log it...
				break;
				
			case "email":
				// If the request variable 'send' is not defined then just print the emails to the screen, don't actually send anything.  This is to
				// prevent accidental sends when testing!
				if (isset($_REQUEST['send']) || !isset($_SERVER["SERVER_NAME"])) {
					// Arrange the accounts into a $emailArray ready to pass to sendEmails
					// Clearly I am trying to abstract the emailOps from the details of accounts, but does this really do it?
					$emailArray = array();
					foreach ($triggerResults as $result) {
						//$emailArray[] = array("to" => $result->email, "data" => array("account" => $result, "opts" => $opts));
						// You can put the cc and bcc into each email template if you don't want every emailed trigger to get cc'd
						// Actually we want to use the admin account email as the main one, and perhaps cc the overall one if different
													//,"cc" => array("accounts@clarityenglish.com")
													//,"bcc" => array("andrew.stokes@clarityenglish.com")
						$accountEmail = $result->email;
						$adminEmail = $result->adminUser->email;
						if ($accountEmail != $adminEmail && $accountEmail && $accountEmail!= '') {
							$emailArray[] = array("to" => $adminEmail
													,"data" => array("account" => $result, "expiryDate" => $trigger->condition->expiryDate)
													,"cc" => array($accountEmail)
												);
						} else {
							$emailArray[] = array("to" => $adminEmail
													,"data" => array("account" => $result, "expiryDate" => $trigger->condition->expiryDate)
												);
						}
					}
					// Send the emails
					// We are currently not using the from field and simply sending everything from support.
					// This is wrong. We should get the 'from' from the template as well - which means do it in emailOps
					$dmsService->emailOps->sendEmails("", $trigger->templateID, $emailArray);
					//echo "sent ".count($triggerResults)." email(s) for trigger ".$trigger->triggerID."; ";
				} else {
					foreach ($triggerResults as $result) {
						$accountEmail = $result->email;
						$adminEmail = $result->adminUser->email;
						//echo "<b>".$result->email.":</b><br/><br/>".$dmsService-> emailOps->fetchEmail("expiry_reminder", array("account" => $result, "opts" => $opts))."<hr/>";
						//echo "<b>".$result->email.":</b><br/><br/>"."xxx"."<hr/>";
						if ($accountEmail != $adminEmail && $accountEmail && $accountEmail!= '') {
							//echo "<b>Email: ".$adminEmail.", cc: ".$accountEmail."</b><br/><br/>";
							echo "<b>Email: ".$adminEmail.", cc: ".$accountEmail."</b><br/><br/>".$dmsService-> emailOps->fetchEmail($trigger->templateID, array("account" => $result, "expiryDate" => $trigger->condition->expiryDate))."<hr/>";
						} else {
							//echo "<b>Email: ".$adminEmail."</b><br/><br/>";
							echo "<b>Email: ".$adminEmail."</b><br/><br/>".$dmsService->emailOps->fetchEmail($trigger->templateID, array("account" => $result, "expiryDate" => $trigger->condition->expiryDate))."<hr/>";
						}
					}
				}
				break;
				
			case "usageStats":
				// This means a more complex operation has to happen on each triggerResult
				$dmsService->usageOps->clearDirectStartRecords();
				
				foreach ($triggerResults as $account) {
					// This will write a record to the database, and tell us the securityString
					$securityString = $dmsService->usageOps->insertDirectStartRecord($account);
					// Then send an email. But why is this in usageOps - why not just here?
					//$dmsService->usageOps->sendDirectStartEmail($account, $trigger->templateID, $securityString);
					$accountEmail = $account->email;
					$adminEmail = $account->adminUser->email;
					// To allow for testing without sending out real emails
					if (isset($_REQUEST['send']) || !isset($_SERVER["SERVER_NAME"])) {
						if ($accountEmail != $adminEmail && $accountEmail && $accountEmail!= '') {
							$emailArray[] = array("to" => $adminEmail
													,"data" => array("account" => $account, "session" => $securityString)
													,"cc" => array($accountEmail)
													);
						} else {
							$emailArray[] = array("to" => $adminEmail
													,"data" => array("account" => $account, "session" => $securityString)
													);
						}
						$dmsService->emailOps->sendEmails("", $trigger->templateID, $emailArray);
					} else {
						if ($accountEmail != $adminEmail && $accountEmail && $accountEmail!= '') {
							echo "<b>Email: ".$adminEmail.", cc: ".$accountEmail."</b> $account->name, $account->id<br/><br/>";
						} else {
							echo "<b>Email: ".$adminEmail."</b> $account->name, $account->id<br/><br/>";
						}
						//echo $dmsService->emailOps->fetchEmail($trigger->templateID, array("account" => $account, "session" => $securityString))."<hr/>";
					}
				}
				break;
		}
	}
}

//session_start();
// Default is to run all the triggers for today
//runTriggers();

// If you want to run specific triggers for specific days (to catch up for days when this was not run for instance)
$testingTriggers = "";
//$testingTriggers .= "subscription reminders";
//$testingTriggers .= "trial reminders";
//$testingTriggers .= "terms and conditions";
//$testingTriggers = "justThese";

// The use of F_Frequency doesn't make any sense at the moment. Everything is simply running on a daily basis.
// This is where I can elect to run weekly or monthly triggers
// Is today the first of the month?
if (date("j")==1) {
	$testingTriggers .= "monthlyActions";
}
// Is today Monday (considered first day of the week by Clarity for everyone - apologies to UAE)
if (date("w")==1) {
	$testingTriggers .= "weeklyActions";
}

if (stristr($testingTriggers, "monthlyActions")) {
	$triggerList = null; // find all monthly ones
	runTriggers($triggerList, null, "monthly");
}
if (stristr($testingTriggers, "terms and conditions")) {
	$tandcTriggers = array(10); // terms and conditions
	runTriggers($tandcTriggers, null); // today
}
if (stristr($testingTriggers, "subscription reminders")) {
	$subscriptionTriggers = array(1, 6, 7, 8); // account subscription reminders
	if (isset($_REQUEST['date'])) {
		runTriggers($subscriptionTriggers, addDaysToTimestamp(time(), intval($_REQUEST['date']))); // 1=tomorrow, -1=yesterday
	} else {
		runTriggers($subscriptionTriggers, addDaysToTimestamp(time(), 0)); // today
	}
}
if (stristr($testingTriggers, "trial reminders")) {
	$trialTriggers = array(11, 12); // trial notices
	if (isset($_REQUEST['date'])) {
		runTriggers($trialTriggers, addDaysToTimestamp(time(), intval($_REQUEST['date']))); // 1=tomorrow, -1=yesterday
	} else {
		runTriggers($trialTriggers, addDaysToTimestamp(time(), 0)); // today
	}
}
if (stristr($testingTriggers, "justThese")) {
	$subscriptionTriggers = array(1); // account subscription reminders
	if (isset($_REQUEST['date'])) {
		runTriggers($subscriptionTriggers, addDaysToTimestamp(time(), intval($_REQUEST['date']))); // 1=tomorrow, -1=yesterday
	} else {
		runTriggers($subscriptionTriggers, addDaysToTimestamp(time(), 0)); // today
	}
}

/*
runTriggers($subscriptionTriggers, addDaysToTimestamp(time(), 0)); // for Friday
runTriggers($subscriptionTriggers, addDaysToTimestamp(time(), 1)); // Saturday
runTriggers($subscriptionTriggers, addDaysToTimestamp(time(), 2)); // and Sunday

runTriggers($subscriptionTriggers, addDaysToTimestamp(time(), -1)); // yesterday
runTriggers($subscriptionTriggers, addDaysToTimestamp(time(), -2));
runTriggers($subscriptionTriggers, addDaysToTimestamp(time(), -3));
runTriggers($subscriptionTriggers, addDaysToTimestamp(time(), -4));
runTriggers($subscriptionTriggers, addDaysToTimestamp(time(), -5));
runTriggers($subscriptionTriggers, addDaysToTimestamp(time(), -6));
runTriggers($subscriptionTriggers, addDaysToTimestamp(time(), -7));
runTriggers($subscriptionTriggers, addDaysToTimestamp(time(), -8));
runTriggers($subscriptionTriggers, addDaysToTimestamp(time(), -9));
runTriggers($subscriptionTriggers, addDaysToTimestamp(time(), -10));
runTriggers($subscriptionTriggers, addDaysToTimestamp(time(), -11));
runTriggers($subscriptionTriggers, addDaysToTimestamp(time(), -12));
runTriggers($subscriptionTriggers, addDaysToTimestamp(time(), -13));
runTriggers($subscriptionTriggers, addDaysToTimestamp(time(), -14));
runTriggers($subscriptionTriggers, addDaysToTimestamp(time(), -15));
runTriggers($subscriptionTriggers, addDaysToTimestamp(time(), -16));
runTriggers($subscriptionTriggers, addDaysToTimestamp(time(), -17));
runTriggers($subscriptionTriggers, addDaysToTimestamp(time(), -18));
runTriggers($subscriptionTriggers, addDaysToTimestamp(time(), -19));
runTriggers($subscriptionTriggers, addDaysToTimestamp(time(), -20));
*/
exit(0)
?>