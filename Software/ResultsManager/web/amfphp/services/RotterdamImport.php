<?php
if (isset($_GET['PHPSESSID'])) session_id($_GET['PHPSESSID']); // gh#32
if (isset($_GET['span'])) $span = $_GET['span'];

require_once(dirname(__FILE__)."/../../config.php");
require_once(dirname(__FILE__)."/../core/shared/util/Authenticate.php");
require_once(dirname(__FILE__)."/../../classes/Session.php");
require_once(dirname(__FILE__)."/../../classes/xml/XmlUtils.php");
require_once(dirname(__FILE__)."/RotterdamBuilderService.php");

$service = new RotterdamBuilderService();
$dir = $service->accountFolder.'/';
$menuDir = $service->accountFolder.'/'.$id.'/';

$uploadMaxFilesize = ini_get('upload_max_filesize');
$postMaxSize = ini_get('post_max_size');
$maxUnits = strtolower($uploadMaxFilesize[strlen($uploadMaxFilesize)-1]);
switch($maxUnits) {
	case 'g':
		$uploadMaxBytes = $uploadMaxFilesize*1024*1024*1024;
		break;
	case 'm':
		$uploadMaxBytes = $uploadMaxFilesize*1024*1024;
		break;
	case 'k':
		$uploadMaxBytes = $uploadMaxFilesize*1024;
		break;
	default:
		$uploadMaxBytes = $uploadMaxFilesize;
}

if (!Authenticate::isAuthenticated()) {
	// Fail if the user isn't authenticated
	AbstractService::$debugLog->info('in RotterdamUpload, session name is '.Session::getSessionName().' user is '.Authenticate::getAuthUser());
	echo json_encode(array("success" => false, "message" => $service->copyOps->getCopyForId("errorUploadNotAuthenticated")));
	exit(0);
}

if ($_FILES['Filedata']['size'] > $uploadMaxBytes) {
	echo json_encode(array("success" => false, "message" => $service->copyOps->getCopyForId("errorExceedMaxFileSize", array("sizeLimit" => $uploadMaxFilesize))));
	exit(0);
} else if (!isset($_FILES['Filedata']) || $_FILES['Filedata']['tmp_name'] == "") {
	echo json_encode(array("success" => false, "message" => $service->copyOps->getCopyForId("errorUploadNoPOST")));
	exit(0);
}

// Copy the zip archive and unpack it
	$originalName = $_FILES['Filedata']['name'];
	$size = $_FILES['Filedata']['size'];
	$finfo = finfo_open(FILEINFO_MIME_TYPE); // return mime type ala mimetype extension
	$mimeType = finfo_file($finfo, $_FILES['Filedata']['tmp_name']);
	finfo_close($finfo);

	// Create a folder to hold the unpacked archive
	$unpackFolder = $dir.'/import-'.getUniqueID;
	mkdir($unpackFolder);
	move_uploaded_file($_FILES['Filedata']['tmp_name'], $unpackFolder."/import.zip");	
	$zip = new ZipArchive();
	if ($zip->open($unpackFolder."/import.zip") === true) {
		$zip->extractTo($unpackFolder);
		$rc = $zip->close();
	}
	
// Read the courses.xml to get the course id
	$contents = file_get_contents($unpackFolder.'/courses.xml');
	$courseXml = simplexml_load_string($contents);
	$id = XmlUtils::xml_attribute($courseXml->courses->course[0], 'id', 'string');
	
// Open id/menu.xml
	$contents = file_get_contents($unpackFolder.'/'.$id.'/menu.xml');
	$menuXml = simplexml_load_string($contents);
	
// Grab all the unit nodes - for now ignore course attributes - and change their ids
	$units = $menuXml->head->script->menu->course->unit;
	foreach ($units as $unitNode) {
		$unitNode->addAttribute("id", getUniqueID);
	}
	
// Copy all the /media/* files into accountFolder/media
// Return the unit nodes as XML
	$result = array("success" => true, "xml" => $units->toXML());
	
	echo json_encode($result);
	
// [you could delete the zip archive and the unpacked folder]

		
} else {
	//echo "$rc open status ".$zip->getStatusString()."<br/>";
}  

	// Finally update media.xml with the a new file node
	$fileNode = $xml->files->addChild("file");
	$fileNode->addAttribute("id", $id);
	$fileNode->addAttribute("originalName", $originalName);
	$fileNode->addAttribute("filename", $filename);
	$fileNode->addAttribute("mimeType", $mimeType);
	$fileNode->addAttribute("size", $size);
	$fileNode->addAttribute("createdOn", $createdTimestamp);
	if (isset($thumbnail)) $fileNode->addAttribute("thumbnail", $thumbnail);
	
	$result = array("success" => true, "src" => $filename);
	
	// If we generated a thumbnail add it to the response
	if (isset($thumbnail)) $result["thumbnail"] = $thumbnail;
	
	echo json_encode($result);
});