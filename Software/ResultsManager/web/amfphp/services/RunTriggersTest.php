<?php
/*
 * This script is run manually for testing
 */

/*
 * Triggers include: 
 * email templates that need to be sent when something happens or becomes true
 * database updates that are fired when something happens
 */
// Warning - this script takes a long time to run, can you override the timeout without nasty consequences? 
// It actually takes about 15 minutes to send 318 emails out. Do I need to extend it that long?
// At 2 minutes it worked, so I suspect that it queues everything within the processing time.
ini_set('max_execution_time', 600); // 10 minutes

require_once(dirname(__FILE__)."/DMSService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");

// Don't get fooled by old session variables
if (isset($_SESSION['dbHost'])) unset($_SESSION['dbHost']);
if (isset($_REQUEST['dbHost'])) $_SESSION['dbHost']=$_REQUEST['dbHost'];

$dmsService = new DMSService();

// Session start done in DMSService
//session_start();

date_default_timezone_set('UTC');
if (!Authenticate::isAuthenticated()) {
	// TODO: Replace with text from literals
	// v3.0.6 This script may be run by CRON too, in which case skip authentication. How to tell?
	if (isset($_SERVER["SERVER_NAME"])) {
	//	echo "<h2>You are not logged in</h2>";
	//	exit(0);
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
function runTriggers($msgType, $triggerIDArray = null, $triggerDate = null, $frequency = "daily") {
	//echo "runTriggers"; 
	global $dmsService;
	global $newLine;
	
	// Pick up all triggers that are valid on the given date (usually this is going to be today)
	if (!$triggerDate) $triggerDate = time();
	
	// Do you want to default to daily triggers, or simply pull out all of them?
	//if (!$frequency) $frequency= "daily";
	
	// You may limit the triggers to those in an array of IDs
	// New, and a particular type.
	$triggers = $dmsService->triggerOps->getTriggers($msgType, $triggerIDArray, $triggerDate, $frequency);
	echo 'got '.count($triggers) .' '.$frequency.' triggers with type='.$msgType.$newLine;

	// Run the condition of each trigger against the database and pull back all objects that meet the condition
	foreach ($triggers as $trigger) {
		//echo 'trigger '.$trigger->name.$newLine;
		//continue;
		// This should go into triggerOps I think.
		// If you want to override the root for testing do it here, or from the URL
		// Also see EmailToAllActiveAccounts for startRootID and stopRootID
		if (isset($_REQUEST['rootID']) && $_REQUEST['rootID']>0) {
			$trigger->rootID=$_REQUEST['rootID'];
		} else {
			$trigger->rootID=10719;
			//$trigger->rootID=Array(5,7,28,163,10719,11091);
			//$trigger->rootID=Array();
		}
		$triggerResults = $dmsService->triggerOps->applyCondition($trigger, $triggerDate);
		echo 'got '.count($triggerResults) .' accounts for '.$trigger->name.$newLine;
		//AbstractService::$log->notice('got '.count($triggerResults) .' accounts for '.$trigger->name);
		
		// Now send all the matched objects to the executor with the templateID
		switch ($trigger->executor) {
			case "sql":
				// the results will be a recordset based on the condition
				if ($trigger->condition->update) {
					// This assumes that the select returns the keys to feed into the update
					// Do this so that you can log what the select returns
					//$roots = Array();
					foreach ($triggerResults as $record) {
						echo "root=".$record['F_RootID'].$newLine;
						//$roots[] = $record['F_RootID'];
					}
					$dmsService->triggerOps->updateDatabase($trigger->condition->update);
				}
				// and log it...
				break;
				
			case "email":
				//foreach ($triggerResults as $account) {
					// TODO: If you do it like this, you are calling emailOps->sendEmails multiple times, with extra overhead.
					// Should use emailAPI and make sure that that can cope with an array of emails before working out whether
					// to send or echo. And perhaps it could cope with start and stop rootIDs too.
					//$emailData = array("account" => $account, "expiryDate" => $trigger->condition->expiryDate);
					//$dmsService-> emailOps->sendOrEchoEmail($account, $emailData, $trigger->templateID);
				//}
				$emailArray = array();
				foreach ($triggerResults as $result) {
					// v3.6 You now get email addresses from T_AccountEmails.
					// So look up T_AccountEmails with the account root and the message type that we are trying to send
					// Then all matching emails will get this. 
					//echo 'getMessages for id='.$result->id.' and type='.$trigger->messageType.$newLine;
					$accountEmails = $dmsService->accountOps->getEmailsForMessageType($result->id, $trigger->messageType);
					//echo 'accountEmails='.count($accountEmails).'-'.implode(',',$accountEmails).$newLine;
					// If there is a reseller they are also 'ccd.
					$resellerEmail = array($dmsService->accountOps->getResellerEmail($result->resellerCode));
					//echo 'resellerEmail='.$resellerEmail.$newLine;
					
					// Pick out the first accountEmail for 'to' and merge all the rest as 'cc'
					$adminEmail = array_shift($accountEmails);
					//echo "admin=$adminEmail";
					$ccEmails = array_merge($accountEmails, $resellerEmail);
					
					$emailData = array("account" => $result, "expiryDate" => $trigger->condition->expiryDate, "template_dir" => $GLOBALS['smarty_template_dir']);
					$thisEmail = array("to" => $adminEmail, "cc" => $ccEmails, "data" => $emailData);
					$emailArray[] = $thisEmail;
				}
				// If the request variable 'send' is not defined then just print the emails to the screen, don't actually send anything.  
				// This is to prevent accidental sends when testing!
				if (isset($_REQUEST['send']) || !isset($_SERVER["SERVER_NAME"])) {
					// Send the emails
					$dmsService->emailOps->sendEmails("", $trigger->templateID, $emailArray);
				} else {
					// Or print on screen
					foreach($emailArray as $email) {
						if ($email["cc"]) {
							echo "<b>Email: ".$email["to"].", cc: ".implode(',',$email["cc"])."</b>".$newLine.$dmsService->emailOps->fetchEmail($trigger->templateID, $email["data"])."<hr/>";
						} else {
							echo "<b>Email: ".$email["to"]."</b>".$newLine.$dmsService->emailOps->fetchEmail($trigger->templateID, $email["data"])."<hr/>";
						}
					}
				}
				break;
				
			case "internalEmail":
				// If you want to send Clarity an email about an account use this. 
				if (isset($_REQUEST['send']) || !isset($_SERVER["SERVER_NAME"])) {
					// Arrange the accounts into a $emailArray ready to pass to sendEmails
					$emailArray = array();
					foreach ($triggerResults as $result) {
						// The email should go to the reseller (cc to Clarity)
						$resellerEmail = $dmsService->accountOps->getResellerEmail($result->resellerCode);
						$clarityEmail = 'sales@clarityenglish.com';
						$emailData = array("account" => $result, "expiryDate" => $trigger->condition->expiryDate, "template_dir" => $GLOBALS['smarty_template_dir']);
						$thisEmail = array("to" => $resellerEmail, "cc" => array($clarityEmail), "data" => $emailData);
						$emailArray[] = $thisEmail;
						echo $result->name.', '.$resellerEmail.$newLine;
					}
					// Send the emails
					$dmsService->emailOps->sendEmails("", $trigger->templateID, $emailArray);
					//echo "sent ".count($triggerResults)." email(s) for trigger ".$trigger->triggerID.$newLine;
				} else {
					foreach ($triggerResults as $result) {
						// The email should go to the reseller (cc to Clarity)
						$resellerEmail = $dmsService->accountOps->getResellerEmail($result->resellerCode);
						$emailData = array("account" => $result, "expiryDate" => $trigger->condition->expiryDate, "template_dir" => $GLOBALS['smarty_template_dir']);
						echo "<b>Email: ".$resellerEmail."</b>".$newLine.$dmsService->emailOps->fetchEmail($trigger->templateID, $emailData)."<hr/>";
					}
				}
				break;
				
			case "usageStats":
				
				$emailArray = array();
				if (isset($_REQUEST['send']) || !isset($_SERVER["SERVER_NAME"])) {
					// Only update T_DirectStart if you are actually inserting new records
					$dmsService->usageOps->clearDirectStartRecords();
				}
				foreach ($triggerResults as $account) {
					// This will write a record to the database, and tell us the securityString. Only do it if you are sending the email as well
					if (isset($_REQUEST['send']) || !isset($_SERVER["SERVER_NAME"])) {
						$securityString = $dmsService-> usageOps->insertDirectStartRecord($account);
					} else {
						$securityString = '123456789';
					}
					$accountEmails = $dmsService->accountOps->getEmailsForMessageType($account->id, $trigger->messageType);
					// Pick out the first accountEmail for 'to' and merge all the rest as 'cc'
					$adminEmail = array_shift($accountEmails);
					$ccEmails = $accountEmails;
					$emailData = array("account" => $account, "session" => $securityString);
					$thisEmail = array("to" => $adminEmail, "cc" => $ccEmails, "data" => $emailData);
					$emailArray[] = $thisEmail;
					echo $account->name.', '.$adminEmail.$newLine;
				}
				// This is to prevent accidental sends when testing!
				if (isset($_REQUEST['send']) || !isset($_SERVER["SERVER_NAME"])) {
					// Send the emails
					$dmsService->emailOps->sendEmails("", $trigger->templateID, $emailArray);
				} else {
					// Or print on screen
					foreach($emailArray as $email) {
						if ($email["cc"]) {
							echo "<b>Email: ".$email["to"].", cc: ".implode(',',$email["cc"])."</b>".$newLine.$dmsService->emailOps->fetchEmail($trigger->templateID, $email["data"])."<hr/>";
						} else {
							echo "<b>Email: ".$email["to"]."</b>".$newLine.$dmsService->emailOps->fetchEmail($trigger->templateID, $email["data"])."<hr/>";
						}
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
$testingTriggers .= "subscription reminders";
$testingTriggers .= "usage stats";
$testingTriggers .= "support";
$testingTriggers .= "quotations";
$testingTriggers .= "trial reminders";
//$testingTriggers .= "terms and conditions";
//$testingTriggers = "justThese";

// The use of F_Frequency doesn't make any sense at the moment. Everything is simply running on a daily basis.
// This is where I can elect to run weekly or monthly triggers
// Is today the first of the month?
// Currently nothing is sent out like this as usage stats moved to a daily check on each account
if (date("j")==1) {
	$testingTriggers .= "monthlyActions";
}
// Used for Early Warning system emails to Clarity team
// Is today Monday (considered first day of the week by Clarity for everyone - apologies to UAE)
if (date("w")==1) {
	$testingTriggers .= "weeklyActions";
}
if (stripos($testingTriggers, "weeklyActions")!==false) {
	$triggerList = null; // find all weekly ones
	$msgType = null; // Nothing useful to send
	runTriggers($msgType, $triggerList, null, "weekly");
}
if (stripos($testingTriggers, "monthlyActions")!==false) {
	$triggerList = null; // find all monthly ones
	$msgType = null; // Nothing useful to send
	runTriggers($msgType, $triggerList, null, "monthly");
}
// This is a test of data in the database, and what you do if it changes
if (stripos($testingTriggers, "terms and conditions")!==false) {
	$tandcTriggers = array(10); // terms and conditions
	$msgType = 0; // Internal action
	runTriggers($msgType, $tandcTriggers, null); // today
}
// This is the main use of triggers, to send out emails to each account
if (stripos($testingTriggers, "subscription reminders") !== false) {
	// Now this information is in the trigger table
	//$subscriptionTriggers = array(1, 6, 7, 8, 32, 33, 34, 36, 38, 39, 40, 41, 42); // account subscription reminders
	$subscriptionTriggers = null;
	$msgType = 1; // subscription reminders
	if (isset($_REQUEST['date'])) {
		runTriggers($msgType, $subscriptionTriggers, addDaysToTimestamp(time(), intval($_REQUEST['date']))); // 1=tomorrow, -1=yesterday
	} else {
		runTriggers($msgType, $subscriptionTriggers, addDaysToTimestamp(time(), 0)); // today
	}
}
if (stripos($testingTriggers, "usage stats") !== false) {
	$subscriptionTriggers = null;
	$msgType = 2; // usage stats
	if (isset($_REQUEST['date'])) {
		runTriggers($msgType, $subscriptionTriggers, addDaysToTimestamp(time(), intval($_REQUEST['date']))); // 1=tomorrow, -1=yesterday
	} else {
		runTriggers($msgType, $subscriptionTriggers, addDaysToTimestamp(time(), 0)); // today
	}
}
if (stripos($testingTriggers, "support") !== false) {
	$subscriptionTriggers = null;
	$msgType = 4; // Support
	if (isset($_REQUEST['date'])) {
		runTriggers($msgType, $subscriptionTriggers, addDaysToTimestamp(time(), intval($_REQUEST['date']))); // 1=tomorrow, -1=yesterday
	} else {
		runTriggers($msgType, $subscriptionTriggers, addDaysToTimestamp(time(), 0)); // today
	}
}
// This sends emails about an account to Clarity or the reseller
if (stripos($testingTriggers, "quotations")!==false) {
	//$internalTriggers = array(37); // internal reminder to create a quotation ready for renewal
	$internalTriggers = null; // internal reminder to create a quotation ready for renewal
	$msgType = 0; // subscription reminders
	if (isset($_REQUEST['date'])) {
		runTriggers($msgType, $internalTriggers, addDaysToTimestamp(time(), intval($_REQUEST['date']))); // 1=tomorrow, -1=yesterday
	} else {
		runTriggers($msgType, $internalTriggers, addDaysToTimestamp(time(), 0)); // today
	}
}
if (stripos($testingTriggers, "justThese")!==false) {
	$subscriptionTriggers = array(1); // account subscription reminders
	$msgType = null; // all
	if (isset($_REQUEST['date'])) {
		runTriggers($msgType, $subscriptionTriggers, addDaysToTimestamp(time(), intval($_REQUEST['date']))); // 1=tomorrow, -1=yesterday
	} else {
		runTriggers($msgType, $subscriptionTriggers, addDaysToTimestamp(time(), 0)); // today
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