<?php
/*
 * This is not really an AMFPHP service but its in this folder to maintain path integrity in all of the require_once calls.
 * Since there are no classes or methods here it does not represent a security risk.
 */
require_once(dirname(__FILE__)."/DMSService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");

//session_start();

if (!Authenticate::isAuthenticated()) {
	// TODO: Replace with text from literals
	echo "<h2>You  are not logged in</h2>";
	exit(0);
}

if (!isset($_REQUEST['template']) || trim($_REQUEST['template']) == "") {
	echo "<h2>No template was specified</h2>";
	exit(0);
}
if (!isset($_REQUEST['accountIDArray'])) {
	$_REQUEST['accountIDArray']="";
}

$template = $_REQUEST['template'];
$accountIDArray = $_REQUEST['accountIDArray'] == "" ? array() : json_decode(stripslashes($_REQUEST['accountIDArray']), true);

// Protect against directory traversal
// PHP 5.3
$pattern = '/..\//';
$replacement = '';
$template = preg_replace($pattern, $replacement, $template);

$dmsService = new DMSService();

// What about conditions for selecting accounts?
//$conditions = array("active" => "true");
$conditions = array();

// Turn the ID array into an array of accounts
$accounts = $dmsService->getAccounts($accountIDArray, $conditions);

echo $dmsService->templateOps->fetchTemplate("dms_reports/".$template, array("accounts" => $accounts));

exit(0)
?>