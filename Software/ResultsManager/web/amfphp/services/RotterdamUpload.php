<?php
if ($_REQUEST['sessionid']) session_id($_REQUEST['sessionid']); // GH #32

require_once(dirname(__FILE__)."/../../config.php");
require_once(dirname(__FILE__)."/../core/shared/util/Authenticate.php");
require_once(dirname(__FILE__)."/../../classes/Session.php");
require_once(dirname(__FILE__)."/../../classes/xml/XmlUtils.php");
require_once(dirname(__FILE__)."/RotterdamService.php");

$service = new RotterdamService();

// Fail if the user isn't authenticated
if (!Authenticate::isAuthenticated()) {
	echo json_encode(array("success" => false, "message" => "Not authenticated"));
	exit(0);
}

// Fail if there is no uploaded file
if (!isset($_FILES['Filedata']) || $_FILES['Filedata']['tmp_name'] == "") {
	echo json_encode(array("success" => false, "message" => "No valid file was found in the POST"));
	exit(0);
}

// Copy the uploaded file and update media.xml
$mediaFolder = $service->mediaOps->mediaFolder;
XmlUtils::rewriteCourseXml($service->mediaOps->mediaFilename, function($xml) use($mediaFolder) {
	// Get some information about the uploaded file (original name, size and mimetype)
	$originalName = $_FILES['Filedata']['name'];
	$size = $_FILES['Filedata']['size'];
	$finfo = finfo_open(FILEINFO_MIME_TYPE); // return mime type ala mimetype extension
	$mimeType = finfo_file($finfo, $_FILES['Filedata']['tmp_name']);
	finfo_close($finfo);
	
	$id = uniqid();
	$createdTimestamp = time();
	
	// Generate a unique filename
	$filename = pathinfo($_FILES['Filedata']['name'], PATHINFO_FILENAME)."-".$createdTimestamp.".".pathinfo($_FILES['Filedata']['name'], PATHINFO_EXTENSION);
	
	// Move the file into the media directory
	move_uploaded_file($_FILES['Filedata']['tmp_name'], $mediaFolder."/".$filename);
	
	// Finally update media.xml with the a new file node
	$fileNode = $xml->files->addChild("file");
	$fileNode->addAttribute("id", $id);
	$fileNode->addAttribute("originalName", $originalName);
	$fileNode->addAttribute("filename", $filename);
	$fileNode->addAttribute("mimeType", $mimeType);
	$fileNode->addAttribute("size", $size);
	$fileNode->addAttribute("createdOn", $createdTimestamp);
	
	echo json_encode(array("success" => true, "filename" => $filename));
});