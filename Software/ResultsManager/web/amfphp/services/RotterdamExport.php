<?php
/**
 * Errors from this script are displayed on a separate page as you can't get back
 * to C-Builder from the download. (Really??)
 * 
 */
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

$dir = $service->accountFolder.'/';
$menuDir = $service->accountFolder.'/'.$id.'/';

if (!Authenticate::isAuthenticated()) {
	// Fail if the user isn't authenticated - but you can't send back anything - need to display error on the server
	AbstractService::$debugLog->info('in RotterdamExport, session name is '.Session::getSessionName().' user is '.Authenticate::getAuthUser());
	redirect($service->copyOps->getCopyForId("errorUploadNotAuthenticated"));
}

$archiveName = 'export-'.$id.'.zip';

// Build the course stub
$stubCourseFilename = $service->accountFolder.'/stub-'.$id.'.xml';
$service->courseOps->createCourseStub($stubCourseFilename, $id);

// Get a list of the media files that are used in this course
$mediaXml = $service->courseOps->buildMediaXml($id, $prefix);

$zip = new ZipArchive();
if ($zip->open($dir.$archiveName, ZipArchive::CREATE) === true) {
	$rc = $zip->addFile($stubCourseFilename, 'courses.xml');
	$rc = $zip->addEmptyDir($id);
	if (file_exists($menuDir.'menu.xml')){
		$rc = $zip->addFile($menuDir.'menu.xml', $id.'/menu.xml');
	}
	if ($mediaXml) {
		$rc = $zip->addEmptyDir('media');
		$rc = $zip->addFromString('media/media.xml', $mediaXml);
	}
	
	$rc = $zip->setArchiveComment("Exported from Clarity's Course Builder");
	$rc = $zip->close();
		
} else {
	//echo "$rc open status ".$zip->getStatusString()."<br/>";
}  

header('Content-Type: application/zip');
header('Content-disposition: attachment; filename='.$archiveName);
header('Content-Length: '.filesize($dir.$archiveName));
readfile($dir.$archiveName);
die;

function redirect($msg) {
	$errorPage = "http://www.clarityenglish.com/error/500.htm";
	header("Location: $errorPage?msg=$msg");
	die();
}
