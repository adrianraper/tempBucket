<?php
$noSession = true;
require_once(dirname(__FILE__)."/../../config.php");

function outputPng($imagePath) {
	header('Content-Type: image/png');
	header('Content-Length:'.filesize($imagePath));
	readfile($imagePath);
	die();
}

if (!isset($_GET['uid'])) {
	echo "No uid given";
	return;
}

$uid = $_GET['uid'];
$thumbnailFolder = dirname(__FILE__)."/../../".$GLOBALS['data_dir']."/../Thumbnails/";

// Sanitise $uid to prevent directory traversal attacks by not allowing more than one consecutive dot or anything that isn't a number.
$uid = preg_replace("/\.{2,}|[^0-9.]*/", "", $uid);

// Split the uid into its component pieces, and only allow 4 or less
$segments = explode(".", $uid);
if (sizeof($segments) == 0 || sizeof($segments) > 4) {
	echo "Illegal uid";
	return;
}
/* 
 * uids are of the form 9, 9.1189057932446, 9.1189057932446.2 or 9.1189057932446.2.1192013075376
 * So the algorithm goes: replace . with / and stick .png on the end.  If the file exists then that's the one we are looking for otherwise pop a segment
 * off the end and have another go.  If we don't find any then use default.png
 */
while (sizeof($segments) > 0) {
	$imagePath = $thumbnailFolder.implode("/", $segments).".png";
	if (file_exists($imagePath)) {
		outputPng($imagePath);
	} else {
		array_pop($segments);
	}
}

outputPng($thumbnailFolder."/default.png");