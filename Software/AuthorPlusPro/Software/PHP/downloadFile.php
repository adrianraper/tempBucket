<HTML>
<HEAD>
<TITLE>Download</TITLE>
</HEAD>
<STYLE TYPE="text/css">
body {font-family: "Verdana", "Arial", "Helvetica", "sans-serif"; font-size: 10px; font-style: normal; line-height: 14px; font-weight: normal; font-variant: normal; color: #000066; text-decoration: none;}
</STYLE>
<BODY>
<?php
include_once("getRootDir.php");

$prog = $_GET['prog'];
$folderURL = $_GET['folderURL'];
$file = $_GET['file'];

// v6.4.2.6 include the user data path to help getRootDir
$udp = $_GET["userDataPath"];

// AR v6.4.2.6 The filename is already full and physical
//$file = getFullFileName($file, $udp);
//$file = $rootDir . $_GET['file'];

// What is the file, not the folder part?
$justFileName = basename($file);

// So build the URL- are we sure that addSlash is OK?
// v6.5.3 RL: we don't need the basefolder here, do we?
// AR yes, I think we do, because otherwise a relative path will be relative to the script
//$fileURL = $rootDir.$folderURL."/".$justFileName;
//$fileURL = addSlash($rootDir).addSlash($folderURL).$justFileName;
// V6.5.4.7 Needed for running on Windows Linux
$fileURL = addSlash($udp).addSlash($folderURL).$justFileName;

/*
echo "file=".$file."<br>";
echo "rootDir=".$rootDir."<br>";
echo "justFileName=".$justFileName."<br>";
echo "fileURL=".$fileURL."<br>";
echo "udp=".$udp."<br>";
echo "folderURL=".$folderURL."<br>";
*/
if ($prog=="NNW") {
	//if (file_exists($rootDir .$file )) {
	if (file_exists($file )) {
		/*header("Pragma: public");
		header("Expires: 0");
		header("Cache-Control: must-revalidate, post-check=0, pre-check=0");
		header("Cache-Control: private", false);
		header('Content-Type: application/zip'); // only consider zip files at the moment
		header("Content-Disposition: attachment; filename=\"".basename($file)."\";");
		header("Content-Transfer-Encoding: binary");
		header("Content-Length: ".@filesize($file));
		set_time_limit(0);
		@readfile($file);*/
		//$file = substr($file, strlen($rootDir));
		//v6.4.2.1 If you just leave file as is, then if the physical name and virtual name of the course folder
		// are different, you will get this wrong. You might need to extract the ZIP name and append to folderURL
		// Or you could do it with realpath, but that can have strange consequences on some servers.
		// But before going any further, see what happens with different names, maybe nowt
		echo "Your exercises are saved in a ZIP file that you can download, ready to be imported into another course.<br><br>";
		echo "<A HREF='{$fileURL}'><strong>Click here</strong></A>";
		echo " to let your browser download the file.";
		//echo "<br>{$fileURL}";
	} else {
		echo "Sorry, the ZIP file cannot be found.<br><br>";
		echo "root={$rootDir}, folder={$folderURL} and file={$justFileName}";
	}
}
?>
</BODY>
</HTML>