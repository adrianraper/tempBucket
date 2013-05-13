<?php
/*
 * This script is run by the cronjob on a 1 minute basis.
 */
/*
 * The only job this runs is to send emails placed in the T_PendingEmails table 
 */
set_time_limit(59);
// How many emails will you send at once? 
$batchLoad = 10;

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

function sendPendingEmails() {
	global $thisService;
	global $newLine;
	global $batchLoad;
	
	// Read a few of the waiting emails
	// TODO. You could try to group them according to templateID
	$sql = <<<SQL
		SELECT p.* FROM T_PendingEmails p 
		WHERE p.F_SentTimestamp IS NULL
		AND (p.F_DelayUntil IS NULL OR p.F_DelayUntil < NOW())
		ORDER by p.F_RequestTimestamp ASC
		LIMIT ?
SQL;
	$rs = $thisService->db->Execute($sql, array($batchLoad));

	// Loop round the recordset of emails
	if ($rs->RecordCount() > 0) {
		while ($dbObj = $rs->FetchNextObj()) {
			$emailID = $dbObj->F_EmailID;
			$templateID = $dbObj->F_TemplateID;
			$to = $dbObj->F_To;
			$savedEmail = json_decode($dbObj->F_Data);
			$thisEmail = array("to" => $to, "data" => $savedEmail->data);
			if (isset($savedEmail->cc))
				$thisEmail['cc'] = $savedEmail->cc;
			if (isset($savedEmail->bcc))
				$thisEmail['bcc'] = $savedEmail->bcc;
			if (isset($savedEmail->attachments))
				$thisEmail['attachments'] = $savedEmail->attachments;
			
			if (isset($_REQUEST['send']) || !isset($_SERVER["SERVER_NAME"])) {
				// gh#226 This is the one place where we really want to send the email immediately
				$rc = $thisService->emailOps->sendEmails('', $templateID, array($thisEmail), true);
			} else {
				echo "<b>Email: ".$to."</b>".$newLine.$thisService->emailOps->fetchEmail($templateID, $savedEmail->data)."<hr/>";
				// fake response
				$rc = array();
			}
			// If the email appears to have been sent, update the timestamp in the table
			if ($rc == array()) {
				$sqlUpdate = <<<SQL
					UPDATE T_PendingEmails
					SET F_SentTimestamp = NOW() 
					WHERE F_EmailID = ?
SQL;
				$rc = $thisService->db->Execute($sqlUpdate, array($emailID));
			}
		}
		/*
		 * 
			$savedEmail = unserialize($dbObj->F_Data);
			$thisEmail = array("to" => $to, "data" => $savedEmail['data']);
			if (isset($savedEmail['cc']))
				$thisEmail['cc'] = $savedEmail['cc'];
			if (isset($savedEmail['bcc']))
				$thisEmail['bcc'] = $savedEmail['bcc'];
			if (isset($savedEmail['attachments']))
				$thisEmail['attachments'] = $savedEmail['attachments'];
		 */
	}
	echo "Sent ".$rs->RecordCount()." pending emails. $newLine";					
	
}

// Action
sendPendingEmails();

flush();
exit(0);
