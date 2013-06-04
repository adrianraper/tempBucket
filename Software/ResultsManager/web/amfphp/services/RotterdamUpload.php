<?php
if (isset($_GET['PHPSESSID'])) session_id($_GET['PHPSESSID']); // gh#32
if (isset($_GET['span'])) $span = $_GET['span'];

require_once(dirname(__FILE__)."/../../config.php");
require_once(dirname(__FILE__)."/../core/shared/util/Authenticate.php");
require_once(dirname(__FILE__)."/../../classes/Session.php");
require_once(dirname(__FILE__)."/../../classes/xml/XmlUtils.php");
require_once(dirname(__FILE__)."/RotterdamBuilderService.php");

$service = new RotterdamService();
$MAXIMUM_FILESIZE = 1024*1024*5;

// Fail if the user isn't authenticated
if (!Authenticate::isAuthenticated()) {
	echo json_encode(array("success" => false, "message" => $service->copyOps->getCopyForId("errorUploadNotAuthenticated")));
	exit(0);
}

//else if: Fail if there is no uploaded file//
if ($_FILES['Filedata']['size'] > $MAXIMUM_FILESIZE) {
	echo json_encode(array("success" => false, "message" => $service->copyOps->getCopyForId("errorExceedMaxFileSize")));
	exit(0);
} else if (!isset($_FILES['Filedata']) || $_FILES['Filedata']['tmp_name'] == "") {
	echo json_encode(array("success" => false, "message" => $service->copyOps->getCopyForId("errorUploadNoPOST")));
	exit(0);
}

// Copy the uploaded file and update media.xml
$mediaFolder = $service->mediaOps->mediaFolder;

XmlUtils::rewriteXml($service->mediaOps->mediaFilename, function($xml) use($mediaFolder, $span) {
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

	switch ($mimeType) {
		case "image/gif":
		case "image/jpeg":
		case "image/png":
			// gh#104 - if this is an image then resize it to width 450 (for now)
			$image = new Imagick($mediaFolder."/".$filename);
			// gh#312
			//$image->scaleimage(547, 0);
			if ($span == 1) {
				if ($image->getimagewidth() > 328) {
					$image->scaleimage(328, 0);
				}
			} else if ($span == 2) {			
				if ($image->getimagewidth() > 674) {
					$image->scaleimage(674, 0);
				}
			} else if ($span == 3) {
				if ($image->getimagewidth() > 1020) {
					$image->scaleimage(1020, 0);
				}
			}
			$image->writeimage();
			$image->destroy();
			break;
		case "application/pdf":
			// gh#105 - if this is a pdf then generate a thumbnail of the first page with height 30 (for now)
			AbstractService::$debugLog->info("you are here4.1");
			$pdfThumbnailImage = new Imagick($mediaFolder."/".$filename."[0]");
				AbstractService::$debugLog->info("you are here4");
			$pdfThumbnailImage->setImageFormat("jpg");
			$pdfThumbnailImage->scaleimage(100, 0);
			$thumbnail = $filename."-thumb.jpg";
			$pdfThumbnailImage->writeimage($mediaFolder."/".$thumbnail);
			$pdfThumbnailImage->destroy();
			break;
	}

	// Get the image size by re-opening it (for some reason getImageLength doesn't work after a resize) gh#157
	if ($image) {
		$image = new Imagick($mediaFolder."/".$filename);
		$size = $image->getImageLength();
		$image->destroy();
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