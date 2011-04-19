<?php
header('Content-type: text/xml');
include_once("getRootDir.php");

$post = file_get_contents("php://input");
$fileName = $_GET["file"];
$dir = $_GET["path"];
// for debugging
if (isset($_GET["post"]) && $post=="") $post = $_GET["post"];
// AR v6.4.2.6 Add the udp
$userdatapath = $_GET["udp"];

// if a folder has been passed, make sure that it exists
if ($dir<>"") {
	// AR v6.4.2.6 also pass udp to this as well
	$dir = getFullFileName($dir, $userdatapath);
	//print $dir;
	if (!file_exists($dir)) {
		@mkdir($dir, 0777);
		@chmod($dir, 0777);
	}
}

$fileName = getFullFileName($fileName, $userdatapath);
//echo $fileName;

// if file name and xml contents exist
// AR v6.4.2.5 You can't check to see if this is actually a file as it might not exist yet.
//if (is_file($fileName) && $post!="") {
if ($fileName!="" && $post!="") {

	//@chmod($physicalPath, 0777);

	$original = array("<CDATA>", "</CDATA>");
	$final = array("<![CDATA[", "]]>");
	$post = str_replace($original, $final, $post);
	
	$original = array("&amp;", "&apos;", "&quot;", "&lt;", "&gt;");
	$final = array("&", "'", '"', "<", ">");
	$post = str_replace($original, $final, $post);
	
	// adding header for UTF-8
	$post="\xEF\xBB\xBF".$post;
	
	// v6.4.2.5 Update code for error handling
	if (!$handle = fopen($fileName, 'wb')) {
		echo "<sR><sR save='error' /><note>cannot open for writing</note><file>$fileName</file></sR>";
	} else {
		//@fputs($f, $post);
		if (fwrite($handle, $post) === false) {
			echo "<sR><sR save='error' /><note>cannot write data</note><file>$fileName</file></sR>";
		} else {
			echo "<sR><sR save='success' /></sR>";
		}
		fclose($handle);
		unset($handle);
	}
} else if ($post!="") {
	echo "<sR><sR save='error' /><note>not a valid file</note><file>$fileName</file></sR>";
} else {
	echo "<sR><sR save='error' /><note>nothing to save</note><data>$post</data></sR>";
}
?>
