<?php
//include_once("getRootDir.php");

// always test to start a session before setting/getting session variables
if (session_id()=="") {
	session_start();
}

$fileType = $_SESSION['s_fileType'];
// AR v6.4.2.5 new version for relative paths - pass the full filename in the session variable from actionFunctions.php
//$uploaddir = $rootDir . $_SESSION['s_uploadPath'];
$uploaddir = $_SESSION['s_uploadPath'];

if (!file_exists($uploaddir)) {
	mkdir($uploaddir, 0777);
}
@chmod($uploaddir, 0777);

// requires PHP v4.1.0 onwards - before that use $HTTP_POST_FILES instead of $_FILES
$uploadfile = $uploaddir . "/" . basename($_FILES['userfile']['name']);
$fileSize = ceil($_FILES['userfile']['size']/1000);
$fileError = $_FILES['userfile']['error'];

//v6.4.2.1 if the filesize is bigger than post_max_size $_FILES is going to be empty
// It will have also emptied $_POST, so check to see if you have been passed a checkVar
// Info taken from user comments in php.net 'handling file uploads'
//if ($_GET['check']!=1) {
//	$fileError = UPLOAD_ERR_INI_SIZE;
//}

if (move_uploaded_file($_FILES['userfile']['tmp_name'], $uploadfile)) {
	$uploadedFilenames = "filename=".basename($uploadfile);
} else {
	$uploadedFilenames = "filename=";
}
?>
<HTML>
<HEAD>
<TITLE>Upload a file</TITLE>
<style>
BODY {background-color:white;font-family:arial;font-size:12}
</style>
<SCRIPT LANGUAGE="JavaScript"> 
<!--
var closing=false;

function finishUploadHandler_DoFSCommand(command, args) {
  if (command == "closeWindow") {
    window.close();
  }
}
//-->
</SCRIPT>
<SCRIPT LANGUAGE="VBScript">
// Catch FS Commands in IE, and pass them to the corresponding JavaScript function.
Sub finishUploadHandler_FSCommand(ByVal command, ByVal args)
    call finishUploadHandler_DoFSCommand(command, args)
End Sub
</SCRIPT>
</HEAD>
<BODY>
<?php
echo "<div style=\"border-bottom: #A91905 2px solid;font-size:16\">File uploaded</div>";
echo "<div style=\"margin-left:40\"><br>".basename($uploadfile)." ({$fileSize} kb)<br><br>";
// close button
echo "<!--url's used in the movie-->";
echo "<!--text used in the movie-->";
echo "<object classid=\"clsid:d27cdb6e-ae6d-11cf-96b8-444553540000\" codebase=\"http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=7,0,0,0\" ";
//echo "width=\"80\" height=\"22\" id=\"finishUploadHandler\" align=\"middle\">";
echo "width=\"2\" height=\"2\" id=\"finishUploadHandler\" align=\"middle\">";
echo "<param name=\"allowScriptAccess\" value=\"sameDomain\" />";
echo "<param name=\"movie\" value=\"../finishUploadHandler.swf?{$uploadedFilenames}\" />";
echo "<param name=\"quality\" value=\"high\" />";
echo "<param name=\"bgcolor\" value=\"#ffffff\" />";
echo "<embed src=\"../finishUploadHandler.swf?{$uploadedFilenames}\" swLiveConnect=\"true\" quality=\"high\" bgcolor=\"#ffffff\" width=\"2\" height=\"2\" name=\"finishUploadHandler\" align=\"middle\" allowScriptAccess=\"sameDomain\" type=\"application/x-shockwave-flash\" pluginspage=\"http://www.macromedia.com/go/getflashplayer\" />";
echo "</object>";
echo "<br>";
if ($fileError>0 || $fileSize==0){
	echo "Sorry, something has gone wrong uploading your file.";
	echo "<br>";
	if ($fileError==UPLOAD_ERR_INI_SIZE) {
		echo "The file is too big to upload to your server (where the limit is " .ini_get("upload_max_filesize") .")";
	} else if($fileError==UPLOAD_ERR_FORM_SIZE) {
		echo "The file is too big to upload from here";
	} else if($fileSize==0) {
		echo "The file is too big to upload to the server (where setting post_max_size=" .ini_get("post_max_size") .")";
	} else {
		echo "It is not too big, but something didn't work on the server.";
	}
}else if ($uploadedFilenames == "filename=") {
	echo "Sorry, something has gone wrong uploading your file.";
	echo "<br>";
	echo "Please close this window and try again. If it still fails";
	echo "<br>";
	echo "please ask your support team to check the permission";
	echo "<br>";
	echo "to upload files of this size or type to the server.";
} else {
	echo "Your file has been uploaded, you can now close this window.";
}
	echo "<br><br>";
	echo "If Author Plus stays locked after you close this window,";
	echo "<br>";
	echo "press the Esc key to release it.";
	echo "<br>";
echo "</div>";
?>
</BODY>
</HTML>