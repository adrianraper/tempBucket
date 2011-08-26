<?php
// AR v6.4.2.5 use getRootDir with absolute and relative paths - working on Windows PHP and dreamhost PHP
// 3 ways to get to the relative folder from here - choose the third for relative and first two for absolute
// The pathFromHere will only be used if another path is not sent to the function - usually we know userDataPath which is what we want
$webShare = "";
$pathFromHere = $webShare."/area1/AuthorPlus";

$thisScript = dirname($_SERVER['PHP_SELF']);
$thisScript=str_replace("\\","/",$thisScript);
$thisScript2 = dirname(__FILE__);
$thisScript2=str_replace("\\","/",$thisScript2);

function removeSlash($folderName) {
	if (substr($folderName,-1)=="/" || substr($folderName,-1)=="\\") {
		$thisFolder = substr($folderName, 0, -1);
	} else {
		$thisFolder = $folderName;
	}
	return $thisFolder;
}
function addSlash($folderName) {
	$thisFolder = removeSlash($folderName)."/";
	return $thisFolder;
}
function getFullFolder($thisPath) {
	$thisFullPath = realpath($thisPath);
	// if realpath didn't work, then just keep the relative one
	//if ($thisFullPath.length==0) $thisFullPath = $thisPath;
	if (strlen($thisFullPath)==0) $thisFullPath = $thisPath;
	$thisFullPath = addSlash($thisFullPath); 
	return $thisFullPath;
}

// figure out the domain, used for absolute paths
$thisDomain = addSlash(substr($thisScript2, 0, strlen($thisScript2)-strlen($thisScript)));
//$thisDomain = substr($thisScript2, 0, strlen($thisScript2)-strlen($thisScript));
$rootDir = getFullFolder($pathFromHere);
//print "domain ".$thisDomain."  ";
//print "rootDir ".$rootDir."  ";
//print getFullFileName('../Content/AuthorPlus/Courses/1174987637859/menu.xml', '/Fixbench/AuthorPlus');

//function getFullFileName($fileName) {
function getFullFileName($fileName, $basePath) {
	//echo "getFullFileName fileName=$fileName basePath=$basePath full>";
	global $rootDir;
	global $thisDomain;
	// Use the passed base, or the one written into above - prefer to pass one
	if ($basePath=="" || $basePath==null) {
		$basePath = $rootDir;
	}
	// Make sure the basePath has a slash on the end
	$basePath=addSlash($basePath);
//print "basePath ".$basePath."  ";
	
	// Add the domain to the beginning of the base
	if (substr($basePath,0,1)=="/") {
		$fullBase = removeSlash($thisDomain).$basePath;
	} else {
		$fullBase = $thisDomain.$basePath;
	}
//print "fullBase ".$fullBase."  ";
	// Add the file/folder name to the end
	if (substr($fileName,0,1)=="/") $fullBase=removeSlash($fullBase);
	//print $fullBase.$fileName;
	$filePath = realpath($fullBase.$fileName);
	//if ($filePath.length==0) $filePath = $fullBase.$fileName;
	if (strlen($filePath)==0) $filePath = $fullBase.$fileName;
	return $filePath;
}

?>