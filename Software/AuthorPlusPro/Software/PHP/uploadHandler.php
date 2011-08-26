<?php
include_once("getRootDir.php");

if ($_GET['prog']=="NNW") {
	$uploaddir = $rootDir . $_GET['path'];
	if (!file_exists($uploaddir)) {
		mkdir($uploaddir, 0777);
	}
	@chmod($uploaddir, 0777);
	
	$uploadfile = $uploaddir . "/" . basename($_FILES['Filedata']['name']);
	move_uploaded_file($_FILES['Filedata']['tmp_name'], $uploadfile);
}
?>