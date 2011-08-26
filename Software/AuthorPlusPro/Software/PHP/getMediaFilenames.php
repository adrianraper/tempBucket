<?php
include_once("getRootDir.php");

$prog = $_GET['prog'];
$path = $_GET['path'];
$fileType = $_GET['type'];
// AR v6.4.2.6 Add the udp
// v6.5.5.5 I am actually passing userDataPath
if (isset($_GET["udp"])) {
	$userdatapath = $_GET["udp"];
}
if (isset($_GET["userDataPath"])) {
	$userdatapath = $_GET["userDataPath"];
}
// v6.5.5.5 undefined variable
$x="";
if ($prog=="NNW") {
	header('Content-type: text/xml');
	$x .= "<fileList>";

	// form path (Media folder)
	$original = array("\\", "//");
	$final = array("/", "/");
	$path = str_replace($original, $final, $path);
	// v6.4.2.1 Pass full folder name from now on
	//$path = $rootDir.$path."/Media";
	// AR v6.4.2.6 Use the udp
	//$path = $rootDir.$path;
	$path = getFullFileName($path, $userdatapath);
	//print "<note>$path</note>";

	//create an extension mapping array
	switch(strtoupper($fileType)) {
	case "IMAGE" :
		$ext = array("jpg");
		break;
	case "AUDIO" :
		$ext = array("mp3", "fls");
		break;
	case "VIDEO" :
		$ext = array("flv", "swf");
		break;
	case "ZIP" :
		$ext = array("zip");
		break;
	default :
		$ext = array();
		break;
	}
	$l = sizeof($ext);
	
	if (file_exists($path)) {
		if ($handle = opendir($path)) {
			while (false !== ($file = readdir($handle))) {
				if (!is_dir($file)) {
					if ($l>0) {
						for ($i=0;$i<$l;$i++) {
							if (strstr($file, ".".$ext[$i])) {
								$x .= "<file>{$file}</file>";
							}
						}
					} else {
						$x .= "<file>{$file}</file>";
					}		
				}
			}
			closedir($handle);
		}
	}
	$x .= "</fileList>";
	print($x);
}

?>