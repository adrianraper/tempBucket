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
	echo "runTriggers for ".date('Y-m-d', $triggerDate)."<br/>"; 
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
		// Remember that if you are testing with 163, that getAccounts is only looking for accountType=1 (standard invoice)
		$trigger->rootID = 13310;
		//$trigger->condition->licenceType = 5;
		//$trigger->condition->individuals = true;
		$triggerResults = $dmsService->triggerOps->applyCondition($trigger, $triggerDate);
		echo "got ".count($triggerResults)." accounts<br/>";
		
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
												,"data" => array("account" => $result, "expiryDate" => $trigger->condition->expiryDate)
												//,"cc" => array("accounts@clarityenglish.com")
												//,"bcc" => array("andrew.stokes@clarityenglish.com")
											);
						
					// Send the emails
					// If you want to use the Smarty cache, you have to send TRUE as the third parameter
					$dmsService->emailOps->sendEmails("", $trigger->templateID, $emailArray, true);
					//echo "sent ".count($triggerResults)." email(s) for trigger ".$trigger->triggerID."; ";
				} else {
					foreach ($triggerResults as $result) {
						echo "<b>Email: ".$result->email." - ($result->id)</b><br/><br/>".$dmsService->emailOps->fetchEmail($trigger->templateID, array("account" => $result, "expiryDate" => $trigger->condition->expiryDate))."<hr/>";
						//echo "<b>".$result->email.":</b><br/><br/>".$dmsService-> emailOps->fetchEmail("expiry_reminder", array("account" => $result, "opts" => $opts))."<hr/>";
						//echo "<b>".$result->email.":</b><br/><br/>"."xxx"."<hr/>";
					}
				}
				break;
		}
	}
}

function specificEmail($account, $licencedProductCodes) {
	global $dmsService;
	//var_dump($account->adminUser);
	// Triggers are not used to send emails as they are daily or hourly. We need immediate.
	// So just send the email from here.
	//echo "say that these are hidden ".var_dump($licencedProductCodes)."<br/>";
	$emailArray[] = array("to" => $account->adminUser->email
							,"data" => array("account" => $account, "hiddenProducts" => $licencedProductCodes)
							,"cc" => array("adrian.raper@clarityenglish.com")
						);
						
	// Send the emails
	//$templateID = 'IYJ_welcome_individual';
	$templateID = 'CLS_welcome';
	// If the request variable 'send' is not defined then just print the emails to the screen, don't actually send anything.  
	// This is to prevent accidental sends when testing!
	if (isset($_REQUEST['send'])) {
		$dmsService-> emailOps->sendEmails("", $templateID, $emailArray);
	} else {
		echo "<b>Email: ".$account->adminUser->email."</b><br/><br/>".$dmsService->emailOps->fetchEmail($templateID, array("account" => $account, 
																											"hiddenProducts" => $licencedProductCodes))."<hr/>";
	}
}
// If you want to run specific triggers for specific days (for testing)
// you can put 'date=-1' in the URL
$testingTriggers = "";
//$testingTriggers .= "IYJ";
$testingTriggers .= "Reminders";
//$testingTriggers .= "Welcome";
//$testingTriggers .= "terms and conditions";

if (stristr($testingTriggers, "IYJ")) {
	$triggers = array(14,15,19,20,21,22,23,24,25,26); // IYJ Units 1 to 10
	//$triggers = array(14, 15); // IYJ Unit 1
	if (isset($_REQUEST['date'])) {
		runTriggers($triggers, addDaysToTimestamp(time(), intval($_REQUEST['date']))); // &date=1 is tomorrow, &date=-1 is yesterday
	} else {
		runTriggers($triggers, addDaysToTimestamp(time(), 0)); // today
	}
}
if (stristr($testingTriggers, "Reminders")) {
	$triggers = array(1,6,7,8,16,18); // Reminders for CE.com and CLS accounts
	if (isset($_REQUEST['date'])) {
		runTriggers($triggers, addDaysToTimestamp(time(), intval($_REQUEST['date']))); // &date=1 is tomorrow, &date=-1 is yesterday
	} else {
		runTriggers($triggers, addDaysToTimestamp(time(), 0)); // today
	}
}
if (stristr($testingTriggers, "Welcome")) {
	// These are not sent through triggers but programmatically
	//$conditions = array('individuals' => true);
	$conditions['individuals'] = true;
	$accounts = $dmsService->accountOps->getAccounts(array(13372), $conditions);
	$hiddenProductCodes = array(38);
	if ($accounts) {
		foreach ($accounts as $account) {
			specificEmail($account, $hiddenProductCodes);
		}
	} else {
		echo "no account found";
	}
}

exit(0);
?>