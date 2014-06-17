<?php
if (isset($_GET['PHPSESSID'])) session_id($_GET['PHPSESSID']); // gh#32
if (isset($_POST['id'])) {
	$id = $_POST['id'];
} else {
	redirect('no course id for export');
}
if (isset($_POST['prefix'])) {
	$prefix = $_POST['prefix'];
} else {
	redirect('no prefix for export');
}

require_once(dirname(__FILE__)."/../../config.php");
require_once(dirname(__FILE__)."/../core/shared/util/Authenticate.php");
require_once(dirname(__FILE__)."/../../classes/Session.php");
require_once(dirname(__FILE__)."/RotterdamBuilderService.php");

$service = new RotterdamBuilderService();

$dir = $service->accountFolder."/";

if (!Authenticate::isAuthenticated()) {
	// Fail if the user isn't authenticated - but you can't send back anything - need to display error on the server
	AbstractService::$debugLog->info('in RotterdamExport, session name is '.Session::getSessionName().' user is '.Authenticate::getAuthUser());
	redirect($service->copyOps->getCopyForId("errorUploadNotAuthenticated"));
}

$zip = new ZipArchive();
// This will add files to an existing archive. Not what we want.
if ($zip->open($dir.'export.zip', ZipArchive::CREATE) === true) {
	$rc = $zip->addFile($dir.'courses.xml', 'courses.xml');
	//echo "$rc addFile status ".$zip->getStatusString()."<br/>";
	$rc = $zip->addEmptyDir('media');
	//echo "$rc addEmptyDir status ".$zip->getStatusString()."<br/>";
	$rc = $zip->addFile($dir.'media/media.xml', 'media/media.xml');
	//echo "$rc addFile status ".$zip->getStatusString()."<br/>";
	$rc = $zip->setArchiveComment('Made this day in 2014');
	//echo "$rc setArchiveComment status ".$zip->getStatusString()."<br/>";
	$rc = $zip->close();
	//echo "$rc close status ".$zip->getStatusString()."<br/>";
		
} else {
	//echo "$rc open status ".$zip->getStatusString()."<br/>";
}  

header('Content-Type: application/zip');
header('Content-disposition: attachment; filename=export.zip');
header('Content-Length: ' . filesize($dir.'export.zip'));
readfile($dir.'export.zip');
die;

function redirect($msg) {
	$errorPage = "http://www.clarityenglish.com/error/500.htm";
	header("Location: $errorPage?msg=$msg");
	die();
}
