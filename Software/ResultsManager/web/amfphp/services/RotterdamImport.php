<?php
if (isset($_GET['PHPSESSID'])) session_id($_GET['PHPSESSID']); // gh#32

require_once(dirname(__FILE__)."/../../config.php");
require_once(dirname(__FILE__)."/../core/shared/util/Authenticate.php");
require_once(dirname(__FILE__)."/../../classes/Session.php");
require_once(dirname(__FILE__)."/../../classes/xml/XmlUtils.php");
require_once(dirname(__FILE__)."/RotterdamBuilderService.php");

	$service = new RotterdamBuilderService();
	$dir = $service->accountFolder.'/';
	
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
	$finfo = finfo_open(FILEINFO_MIME_TYPE);
	$mimeType = finfo_file($finfo, $_FILES['Filedata']['tmp_name']);
	finfo_close($finfo);

	// Create a folder to hold the unpacked archive
	$unpackFolder = $dir.'import-'.UniqueIdGenerator::getUniqId();
	AbstractService::$debugLog->info("import: $originalName $size $mimeType unpack to $unpackFolder");
	mkdir($unpackFolder);
	move_uploaded_file($_FILES['Filedata']['tmp_name'], $unpackFolder."/import.zip");
	
	$zip = new ZipArchive();
	if ($zip->open($unpackFolder."/import.zip") === true) {
		$zip->extractTo($unpackFolder);
		$rc = $zip->close();
	} else {
		AbstractService::$debugLog->info("can't open $unpackFolder/import.zip");
		echo json_encode(array("success" => false, "message" => "can't open $unpackFolder/import.zip"));
		exit(0);
	}
	
	// Read the courses.xml to get the course id
	$contents = file_get_contents($unpackFolder.'/courses.xml');
	$courseXml = simplexml_load_string($contents);
	$id = XmlUtils::xml_attribute($courseXml->courses->course[0], 'id', 'string');
	
	// Open menu.xml
	$menuContents = file_get_contents($unpackFolder.'/'.$id.'/menu.xml');
	$menuXml = simplexml_load_string($menuContents);
	$menuXml->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
	
	// Grab all the unit nodes - for now ignore course attributes - ids get changed on import
	/*
	$units = $menuXml->xpath('//xmlns:unit');
	foreach ($units as $unitNode) {
		$unitNode['id'] = UniqueIdGenerator::getUniqId();
	}
	*/
	
	// Open the media.xml and copy the files from the original account to this one
	$mediaContents = file_get_contents($unpackFolder.'/media/media.xml');
	$mediaXml = simplexml_load_string($mediaContents);
	$mediaXml->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
	$originalPrefix = XmlUtils::xml_attribute($mediaXml->files, 'originalAccount', 'string');
	$currentPrefix = Session::get('dbContentLocation');
	
	if ($originalPrefix != $currentPrefix) {
		$originalFolder = $dir.'../'.$originalPrefix.'/media/';
		foreach ($mediaXml->xpath('//xmlns:file') as $fileNode) {
			$rc = copy($originalFolder.$fileNode['filename'], $dir.'media/'.$fileNode['filename']);
			AbstractService::$debugLog->info("import $rc copied from ".$originalFolder.$fileNode['filename']. " to ".$dir);
		}
	}
	
	// Return the menu.xml
	$result = array("success" => true, "xml" => $menuXml->asXML());
	echo json_encode($result);
	
	// [you could delete the zip archive and the unpacked folder]
