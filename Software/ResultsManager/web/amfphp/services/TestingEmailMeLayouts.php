<?php
/*
 * This script will go through all the triggers related to EMUs and for each work out what to do.
 * Typically a trigger will find all accounts running a particular EMU. 
 * Then we work out which users in this account are enabling the unit that this trigger relates to today.
 */

require_once(dirname(__FILE__)."/DMSService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");
require_once($GLOBALS['smarty_libs']."/Smarty.class.php");
$smarty = new Smarty();
$smarty->template_dir = $GLOBALS['smarty_template_dir'];
$smarty->compile_dir = $GLOBALS['smarty_compile_dir'];
$smarty->config_dir = $GLOBALS['smarty_config_dir'];
$smarty->cache_dir = $GLOBALS['smarty_cache_dir'];
$smarty->plugins_dir[] = $GLOBALS['smarty_plugins_dir'];
//$smarty->clear_compiled_tpl();
//$smarty->force_compile=true;
//echo "clear compiled templates";

$dmsService = new DMSService();
session_start();
//$thisUserName = ""; // Used for stopping caching in templates

// Account Ops usually filters out online subscriptions. This will filter them in...
// $GLOBALS['onlineSubs'] = true;

function addDaysToTimestamp($timestamp, $days) {
	//return date("Y-m-d", $timestamp + ($days * 86400));
	return $timestamp + ($days * 86400);
}

// Maybe I will want to be able to pass an array of triggers to this as well as getting all of them
function runTriggers($triggerIDArray = null, $triggerDate = null, $frequency = null) {
	//echo "runTriggers"; 
	global $dmsService;
	//global $thisUserName; // Used specifically for inserting dynamic names in cached templates.
	
	// Pick up all triggers that are valid on the given date (usually this is going to be today)
	if (!$triggerDate) $triggerDate = time();
	
	// You may limit the triggers to those in an array of IDs
	$triggers = $dmsService->triggerOps->getTriggers($triggerIDArray, $triggerDate, $frequency);
	//echo 'got '.count($triggers) .' triggers'."<br/>";

	// Run the condition of each trigger against the database and pull back all objects that meet the condition
	foreach ($triggers as $trigger) {
		echo "trigger $trigger->name - "; // ." and userStartDate={$trigger->condition->userStartDate}<br/>";
		// TESTING: Add more trigger conditions if you want a specific account or account type
		//$trigger->rootID = 13332;
		//$trigger->condition->licenceType = 5;
		//$trigger->condition->individuals = true;
		$accountResults = $dmsService->triggerOps->applyCondition($trigger, $triggerDate);
		
		// This block is ONLY if you are running an institutional account as an EMU and you want to send emails to students in that account.
		// Now we have all the accounts that are running this EMU 
		// How to get all the users out and match their start dates?
		// We need to know the condition for the trigger [$tigger->condition->userStartDate]
		$triggerResults = array();
		foreach ($accountResults as $account) {
		// If we knew that this was just running personal EMU program we could skip this and use account->adminUserID.
		//	$triggerResults = array_merge($triggerResults, $dmsService->triggerOps->usersInAccount($accountResults[0], $trigger));
			$triggerResults = array_merge($triggerResults, $dmsService->triggerOps->usersInAccount($account, $trigger));
		}
		//echo "got ".count($triggerResults)." users started on {$trigger->condition->userStartDate}<br/>";
		echo "got ".count($triggerResults)." users<br/>";
		
		// Now send all the matched objects to the executor with the templateID
		// Take out SQL code. Copy back from RunDMSTriggers if you need.
		switch ($trigger->executor) {
			case "email":
				// For testing purposes we certainly want to clear the cache
				//$dmsService->emailOps->clearCache($trigger->templateID);
				// For testing a specific template
				//$trigger->templateID = '2130';
				
				// If the request variable 'send' is not defined then just print the emails to the screen, don't actually send anything.  
				// This is to prevent accidental sends when testing!
				// Also check whether you are running from CRON, in which case don't worry about parameters, just send.
				if (isset($_REQUEST['send'])) {
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
						// I am specifically setting a global variable with the username so that 
						// I can cache the email template yet use an insert function to add in the name.
						// See insert.getUserName.php
						// NO, can do with a registered function
						//$thisUserName = $result->name;
						// If you want to use the Smarty cache, you have to send TRUE as the third parameter
						echo "<b>Email: ".$result->email." ".$result->userID."</b><br/><br/>".$dmsService->emailOps->fetchEmail($trigger->templateID, 
																											array("user" => $result, "licenceType" => $trigger->condition->licenceType), true)
																		."<hr/>";
					}
				}
				break;
		}
	}
}

// If you want to run specific triggers for specific days (for testing)
// you can put 'date=-1' in the URL
$testingTriggers = "";
//$testingTriggers .= "IYJ";
$testingTriggers .= "Reminders";
//$testingTriggers .= "terms and conditions";

if (stristr($testingTriggers, "IYJ")) {
	$emuTriggers = array(14,15,19,20,21,22,23,24,25,26); // IYJ Units 1 to 10
	//$emuTriggers = array(14, 15); // IYJ Unit 1
	if (isset($_REQUEST['date'])) {
		runTriggers($emuTriggers, addDaysToTimestamp(time(), intval($_REQUEST['date']))); // &date=1 is tomorrow, &date=-1 is yesterday
	} else {
		runTriggers($emuTriggers, addDaysToTimestamp(time(), 0)); // today
	}
}
if (stristr($testingTriggers, "Reminders")) {
	$emuTriggers = array(1,6,7,8,16,18); // Reminders for CE.com and CLS accounts
	if (isset($_REQUEST['date'])) {
		runTriggers($emuTriggers, addDaysToTimestamp(time(), intval($_REQUEST['date']))); // &date=1 is tomorrow, &date=-1 is yesterday
	} else {
		runTriggers($emuTriggers, addDaysToTimestamp(time(), 0)); // today
	}
}

exit(0);
?>