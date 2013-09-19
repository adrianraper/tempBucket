<?php
if (isset($_GET['PHPSESSID'])) {
	session_id($_GET['PHPSESSID']); // gh#32
} else if ($_REQUEST['SESSIONID']) {
	session_id($_REQUEST['SESSIONID']); // fix for FileReference session bug (ticket #65)
}

require_once('./config.php');
require_once("./amfphp/core/shared/util/Authenticate.php");
require_once("./amfphp/services/ClarityService.php");


$service = new ClarityService();

if (!Authenticate::isAuthenticated()) {
	// Fail if the user isn't authenticated
	//echo json_encode(array("success" => false, "message" => $service->copyOps->getCopyForId("errorUploadNotAuthenticated")));
	echo "0";
	exit(0);
}

$userID = $_SESSION['userID'];
$rootID = $_SESSION['rootID'];
$groupID = $_SESSION['groupID'];

// The filename is determined by the logged in user id so each user can only have one upload at a time
$file = "./".$GLOBALS['tmp_dir']."/upload_".$userID;

// Delete the file if it exists
if (file_exists($file)) unlink($file);

// Move the temporary upload into place
move_uploaded_file($_FILES['Filedata']['tmp_name'], $file);

// Return success
echo "1";
flush();