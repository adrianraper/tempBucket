<?php
/*
 * This is not really an AMFPHP service but its in this folder to maintain path integrity in all of the require_once calls.
 * Since there are no classes or methods here it does not represent a security risk.
 */
require_once(dirname(__FILE__)."/DMSService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");

session_start();

if (!Authenticate::isAuthenticated()) {
	// TODO: Replace with text from literals
	echo "<h2>You are not logged in</h2>";
	exit(0);
}

function addDaysToTimestamp($timestamp, $days) {
	return date("Y-m-d", $timestamp + ($days * 86400));
}

$dmsService = new DMSService();

// Since this will be the only place we ever access the log table for reading we might as well keep the code here
$sql = <<<EOD
SELECT u.F_UserName, l.F_ProductName, l.F_Message, l.F_Date
FROM T_Log l LEFT JOIN T_User u ON u.F_UserID = l.F_UserID
WHERE F_Date >= ?
EOD;

// Hardcoded to show logs from the last 10 days.  We can add date selectors into the HTML if required.
$logs = $dmsService->db->GetArray($sql, array(addDaysToTimestamp(time(), -10)));

echo $dmsService->templateOps->fetchTemplate("log_viewer/log_viewer", array("logs" => $logs));

exit(0);
?>