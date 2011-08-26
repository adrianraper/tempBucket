<?php
/*
 * This is not really an AMFPHP service but its in this folder to maintain path integrity in all of the require_once calls.
 * Since there are no classes or methods here it does not represent a security risk.
 */

/*
 * This is an internal report used to check subscription reminders.
 * Take a start date (usually today) and cycle through each day for the next month.
 * See which accounts should be triggered on that day.
 */

require_once(dirname(__FILE__)."/DMSService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");

$dmsService = new DMSService();

session_start();

// No need to worry about authentication for this report
/*
if (!Authenticate::isAuthenticated()) {
	// TODO: Replace with text from literals
	// v3.0.6 This script may be run by CRON too, in which case skip authentication. How to tell?
	if (isset($_SERVER["SERVER_NAME"])) {
		echo "<h2>You are not logged in</h2>";
		exit(0);
	}
}
*/

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
		// This should go into triggerOps I think.
		
		// This is an internal report that wants to see all accounts, even those with optOutEmails
		$trigger->condition->optOutEmails = false;
		$triggerResults = $dmsService->triggerOps->applyCondition($trigger, $triggerDate);
		
		// Now send all the matched objects to the executor with the templateID
		switch ($trigger->executor) {
			case "email":
				if (count($triggerResults)>0) echo "&nbsp;&nbsp;$trigger->name<br/>";
				foreach ($triggerResults as $result) {
					echo "&nbsp;&nbsp;&nbsp;&nbsp;<b>$result->name</b> to $result->email (root=$result->id)";
					if ($result->optOutEmails) echo " - THIS EMAIL WILL NOT BE SENT, account is opt-out";
					echo "<br/>";
				}
				if (count($triggerResults)>0) echo "<hr/>";
			break;
		}	
	}
}

//session_start();
// Default is to run all the triggers for today
//runTriggers();

echo  <<<EOD
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>Clarity English - subscription reminder</title>
<style type="text/css">
{literal}
<!--
.style1 {font-family: Verdana, Arial, Helvetica, sans-serif;
font-size: 12px;}
.style2 {font-family: Verdana, Arial, Helvetica, sans-serif;
font-size: 11px;}
-->
{/literal}
</style>
</head>

<body class="style1">
EOD;

// If you want to run specific triggers for specific days (to catch up for days when this was not run for instance)
$testingTriggers = "";
$testingTriggers .= "subscription reminders";
//$testingTriggers .= "trial reminders";

if (stristr($testingTriggers, "subscription reminders")) {
	$subscriptionTriggers = array(1, 6, 7, 8); // account subscription reminders
	if (isset($_REQUEST['date'])) {
		$relativeStartDay = intval($_REQUEST['date']); // 1=tomorrow, -1=yesterday
	} else {
		$relativeStartDay = 0;
	}
	for ($i = 0; $i <= 30; $i++) {
		$forThisDate = addDaysToTimestamp(time(), $i + $relativeStartDay);
		echo date('d F, Y', $forThisDate).'<br/>';
		runTriggers($subscriptionTriggers, $forThisDate);
	}
}
echo  <<<EOD
</body>
</html>
EOD;
exit(0)
?>