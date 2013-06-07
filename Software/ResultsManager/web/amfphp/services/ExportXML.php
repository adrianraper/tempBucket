<?php
/*
 * This is not really an AMFPHP service but its in this folder to maintain path integrity in all of the require_once calls.
 * Since there are no classes or methods here it does not represent a security risk.
 */

require_once(dirname(__FILE__)."/ClarityService.php");
require_once(dirname(__FILE__)."/../core/shared/util/Authenticate.php");

$clarityService = new ClarityService();
if (!Authenticate::isAuthenticated()) {
	// TODO: Replace with text from literals
	echo "<h2>You are not logged in</h2>";
	exit(0);
}

if (!isset($_REQUEST['groupIDs']) || !isset($_REQUEST['userIDs'])) exit();

$rootID = Session::get('rootID');

$groupIDArray = $_REQUEST['groupIDs'] == "" ? array() : explode(",", $_REQUEST['groupIDs']);
$userIDArray = $_REQUEST['userIDs'] == "" ? array() : explode(",", $_REQUEST['userIDs']);
$archive = (isset($_REQUEST['archive']) && $_REQUEST['archive'] == "true");

try {
	$xmlString = $clarityService->manageableOps->exportXMLFromIDs($groupIDArray, $userIDArray);
} catch (Exception $e) {
	//echo $e;
	
	// TODO: Replace with text from literals
	echo "<h2>You do not have permission to export these manageables</h2>";
	exit(0);
}

if ($archive) {
	// If we are archiving data we need to retrieve the actual manageables so get them here
	$manageables = $clarityService->manageableOps->getManageables($groupIDArray);
	
	if ($_REQUEST['userIDs'] != "")
		$manageables = array_merge($manageables, $clarityService->manageableOps->getUsersById($userIDArray));
	
	$clarityService->manageableOps->deleteManageables($manageables);
}

header("Content-Type: application/xml; charset=\"utf-8\"");
header("Content-Disposition: attachment; filename=\"export.xml\"");
header("Content-Length: ".strlen($xmlString));

echo $xmlString;

flush();

// This makes sure that Internet Explorer doesn't keep the window open
exit();
?>