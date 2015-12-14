<?php
/*
 * This script will check the security code and log you into RM starting on the usage stats page.
 */
$amfServices = "/../../Software/ResultsManager/web/amfphp/services";
$area1 = "./";
require_once(dirname(__FILE__).$amfServices."/MinimalService.php");
session_start();
ob_start();
if (isset($_SESSION['Password'])) {
	unset($_SESSION['Password']);
}

$minimalService = new MinimalService();
$targetURL = $area1."Start.php?directStart=UsageStats";

function lookUpSecurityCode($securityCode) {
	global $minimalService;
	global $targetURL;
	
	$adminUser = new User();
	
	// What do we need from the database?
	$adminUser = $minimalService->checkDirectStartSecurityCode($securityCode);
	
	if ($adminUser) {
		// I don't want too much in session in case they logout and then someone else just starts RM
		// Equally I don't want the password in the URL
		//$_SESSION['UserName'] = $adminUser->name;
		// Can I set it for a short duration session time? Just a few seconds would be fine.
		$_SESSION['Password'] = $adminUser->password;
		$targetURL .= "&username={$adminUser->name}";
	}
	
	return $targetURL;
}

// Look up the security code you were sent and go to the success or failure page
// Actually failure will just take you to the login screen, seems reasonable
$targetPage = lookUpSecurityCode($_GET['session']);
// before using redirect, make sure that you haven't got anything in the output buffer
// clear out the output buffer
while (ob_get_status()) {
    ob_end_clean();
}
header("location: $targetPage");
exit(0);
?>