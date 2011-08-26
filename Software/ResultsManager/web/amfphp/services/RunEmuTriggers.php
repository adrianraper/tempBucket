<?php
/*
 * This script will go through all the triggers related to EMUs and for each work out what to do.
 * Typically a trigger will find all accounts running a particular EMU. 
 * Then we work out which users in this account are enabling the unit that this trigger relates to today.
 */

require_once(dirname(__FILE__)."/DMSService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");

$dmsService = new DMSService();
session_start();

if (!Authenticate::isAuthenticated()) {
	// TODO: Replace with text from literals
	// v3.0.6 This script may be run by CRON too, in which case skip authentication. How to tell?
	if (isset($_SERVER["SERVER_NAME"])) {
		echo "<h2>You are not logged in</h2>";
		exit(0);
	}
	// Account Ops usually filters out online subscriptions. This will filter them in...
	$GLOBALS['onlineSubs'] = true;
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
	
	// You may limit the triggers to those in an array of IDs
	$triggers = $dmsService->triggerOps->getTriggers($triggerIDArray, $triggerDate, $frequency);
	//echo 'got '.count($triggers) .' triggers'."<br/>";

	// Run the condition of each trigger against the database and pull back all objects that meet the condition
	foreach ($triggers as $trigger) {
		//echo "trigger $trigger->name<br/>"; // ." and userStartDate={$trigger->condition->userStartDate}<br/>";
		// This should go into triggerOps I think.
		// This script is only going to be for individual accounts (this condition could be written into the trigger database as well)
		$trigger->condition->licenceType = 5;
		$accountResults = $dmsService->triggerOps->applyCondition($trigger, $triggerDate);
		
		// Now we have all the accounts that are running this EMU 
		// How to get all the users out and match their start dates?
		// We need to know the condition for the trigger [$tigger->condition->userStartDate]
		$triggerResults = array();
		foreach ($accountResults as $account) {
			$triggerResults = array_merge($triggerResults, $dmsService->triggerOps->usersInAccount($account, $trigger));
		}
		//echo "got ".count($triggerResults)." users started on {$trigger->condition->userStartDate}<br/>";
		
		// Now send all the matched objects to the executor with the templateID
		// Take out SQL code. Copy back from RunDMSTriggers if you need.
		switch ($trigger->executor) {
			case "email":
				// If the request variable 'send' is not defined then just print the emails to the screen, don't actually send anything.  
				// This is to prevent accidental sends when testing!
				// Also check whether you are running from CRON, in which case don't worry about parameters, just send.
				if (isset($_REQUEST['send']) || !isset($_SERVER["SERVER_NAME"])) {
					// Arrange the accounts into a $emailArray ready to pass to sendEmails
					// Clearly I am trying to abstract the emailOps from the details of accounts, but does this really do it?
					$emailArray = array();
					foreach ($triggerResults as $result)
						//$emailArray[] = array("to" => $result->email, "data" => array("account" => $result, "opts" => $opts));
						// You can put the cc and bcc into each email template if you don't want every emailed trigger to get cc'd
						$emailArray[] = array("to" => $result->email
												,"data" => array("user" => $result, "licenceType" => $trigger->condition->licenceType)
												//,"cc" => array("accounts@clarityenglish.com")
												//,"bcc" => array("andrew.stokes@clarityenglish.com")
											);
						
					// Send the emails
					// If you want to use the Smarty cache, you have to send TRUE as the third parameter
					$dmsService->emailOps->sendEmails("", $trigger->templateID, $emailArray, true);
					//echo "sent ".count($triggerResults)." email(s) for trigger ".$trigger->triggerID."; ";
				} else {
					foreach ($triggerResults as $result) {
						// If you want to use the Smarty cache, you have to send TRUE as the third parameter
						echo "<b>Email: ".$result->email."</b><br/><br/>".$dmsService->emailOps->fetchEmail($trigger->templateID, 
																											array("user" => $result, "licenceType" => $trigger->condition->licenceType),
																											true)
																		."<hr/>";
						//echo "<b>".$result->email.":</b><br/><br/>".$dmsService-> emailOps->fetchEmail("expiry_reminder", array("account" => $result, "opts" => $opts))."<hr/>";
						//echo "<b>".$result->email.":</b><br/><br/>"."xxx"."<hr/>";
					}
				}
				break;
		}
	}
}

// If you want to run specific triggers for specific days (for testing)
// you can put 'date=-1' in the URL
$testingTriggers = "";
$testingTriggers .= "Its Your Job";
//$testingTriggers .= "terms and conditions";

if (stristr($testingTriggers, "Its Your Job")) {
	$emuTriggers = array(14,15,19,20,21,22,23,24,25,26); // IYJ Units 1 to 10
	if (isset($_REQUEST['date'])) {
		runTriggers($emuTriggers, addDaysToTimestamp(time(), intval($_REQUEST['date']))); // &date=1 is tomorrow, &date=-1 is yesterday
	} else {
		runTriggers($emuTriggers, addDaysToTimestamp(time(), 0)); // today
	}
}

exit(0);
?>