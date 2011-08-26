<?php
	// always test to start a session before setting/getting session variables
	if (session_id()=="") {
		session_start();
	}
	
// *****
//
// You need to edit this file to match the maxFileSize with the server php.ini settings upload_max_filesize
// on your server. You also need to consider the server setting post_max_size setting - which should be larger
// than max_file_size so that you get errors reported correctly
//
	//$maxFileSize = 4 * 1024 * 1024;			// In MB
	$maxFileSize = (int)ini_get("upload_max_filesize") * 1024 * 1024;
//
// *****
	$fileType = $_SESSION['s_fileType'];	// file type(s)
// v6.4.2.7 If session variables fail, then let the user upload any file type
	if ($fileType=="" || $fileType==null) {
		$fileType="*.*";
	}
	$original = array("\"", ",");
	$final = array("", ", ");
	$showFileType = str_replace($original, $final, $fileType);
?>
<HTML>
<HEAD>
<TITLE>Upload file(s)</TITLE>
<style>
BODY {background-color:white;font-family:arial;font-size:12}
</style>
<SCRIPT LANGUAGE="JavaScript"> 
<!--
extArray = new Array(<?php echo $fileType; ?>);
function limitFileType(file) {
	var form = document.frmSend;
	allowSubmit = false;
	if (!file) return;
	while (file.indexOf("\\") != -1)
		file = file.slice(file.indexOf("\\") + 1);
		ext = file.slice(file.indexOf(".")).toLowerCase();
	for (var i=0; i<extArray.length; i++) {
		if (extArray[i] == ext) { allowSubmit = true; break; }
	}
	if (allowSubmit) {
		return true;
	} else {
		var extList="";
		for (var i=0; i<extArray.length; i++) {
			extList += "*" + extArray[i] + " ";
		}
		alert("For this upload you can only select files that\nend in:  " + extList + ". Please try again.");
		return false;
	}
}
function onSubmitForm() {
	var formDOMObj = document.frmSend;
	var notEmpty = false;
	if (formDOMObj.userfile.value!="") { notEmpty = true; }
	if (!notEmpty) {
		alert("Please click the browse button and pick a file.");
		return false;
	} else {
		if (!limitFileType(formDOMObj.userfile.value)) { return false; }
	}
	// ar v6.4.2.1 endNo was part of sequential uploading - now not present and causes IE errors
	/*
	if (formDOMObj.endNo.value!="") {
		var endNo = parseInt(formDOMObj.endNo.value);
		if (isNaN(endNo)) {
			alert("Unexpected error, please try to save your work then try again.");
			return false;
		} else {
			var f1 = formDOMObj.attach1.value;
			var a1 = f1.split(".");
			var s1 = a1[a1.length-2];
			var a2 = s1.split("_");
			var s2 = a2[a2.length-1];
			var startNo = parseInt(s2);
			var noOfFiles = endNo - startNo + 1;
			var suffixLen = a1[a1.length-1].length + a2[a2.length-1].length + 2;
			var prefix = f1.substring(0, f1.length - suffixLen);
			if (endNo<startNo) {
				alert("Unexpected error, please try to save your work then try again.");
				return false;
			}
		}
	}
	*/
	// v6.4.2.1 AR Try to stop the unload from calling any special closing functions as we are simply going to reopen
	//alert("set closing to " + closing);
	closing=false;
	return true;
}
function onFileEntered() {
	var formDOMObj = document.frmSend;
//	formDOMObj.endNo.disabled = false;
}
//-->
</SCRIPT>
</HEAD>
<BODY onLoad="closing=true;" onUnload="if (closing) window.opener.onCloseForm();">
<div style="border-bottom:#A91905 2px solid;font-size:16">Upload a file</div><div style="margin-left:20"><br>

<!-- The data encoding type, enctype, MUST be specified as below -->
<form name="frmSend" enctype="multipart/form-data" action="upload.php?check=1" method="POST" onSubmit="return onSubmitForm();">
    <!-- MAX_FILE_SIZE must precede the file input field -->
    <input type="hidden" name="MAX_FILE_SIZE" value="<?php echo $maxFileSize; ?>" />
    <!-- Name of input element determines name in $_FILES array -->
    File: <input name="userfile" type="file" size="40" />
    <!-- v6.4.2.1 Nicer to replace . with *. in the fileType list -->
    <br>File type(s) accepted: <?php echo $showFileType; ?>
    <br><input style="margin-top:4" type="submit" value="Upload">
    <br><br>Click Browse to search for a file, then click Upload<br>
    to send that file to your course.<br>
    The maximum size of the file is <?php echo ini_get("upload_max_filesize")."B" ?><br/>
</form>

</div>
</BODY>
</HTML>