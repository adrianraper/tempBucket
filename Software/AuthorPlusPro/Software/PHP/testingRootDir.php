<?php

print_r($_SERVER['HTTP_HOST']);
print("<br>");
print_r($_SERVER['SERVER_NAME']);
print("<br>");

		$protocol = $_SERVER['HTTPS'] == 'on' ? 'https' : 'http';
		$host = $_SERVER['HTTP_HOST'];
		
		// This script is down 4 folders from the root I am looking for. It will always be thus.
		$allFolders = explode("/", dirname($_SERVER['PHP_SELF']));
		$throwAway = array_splice($allFolders, -4, 4);
		$rootFolders = implode($allFolders, "/");
		$myRoot = $protocol.'://'.$host.$rootFolders;
		
echo $myRoot;
print("<br>");
print("<br>");

// 3 ways to get to the relative folder from here - choose the third for relative and first two for absolute
$pathFromHere = "../../../../AuthorPlus";

$thisScript = dirname($_SERVER['PHP_SELF'])."/".$pathFromHere;
$thisScript=str_replace("\\","/",$thisScript);
print ("PHP_SELF: script $thisScript");
print("<br>");

$thisScript2 = dirname(__FILE__)."/".$pathFromHere;
$thisScript2=str_replace("\\","/",$thisScript2);
print ("__FILE__: script $thisScript2");
print("<br>");

//print(strlen($thisScript2) ." " .strlen($thisScript));
$myBase = substr($thisScript2, 0, strlen($thisScript2)-strlen($thisScript));
print ("domain: $myBase");
print("<br>");

//$rootDir1 = realpath2($thisScript);
//$rootDir2 = realpath2($thisScript2);
$rootDir3 = realpath2($pathFromHere);

// if realpath didn't work, then just keep the relative one
//if ($rootDir1.length==0) $rootDir1 = $thisScript;
//if ($rootDir2.length==0) $rootDir2 = $thisScript2;
if ($rootDir3.length==0) $rootDir3 = $pathFromHere;

//if (substr($rootDir1,-1)=="/" || substr($rootDir1,-1)=="\\") {
//	$rootDir1 = substr($rootDir1, 0, -1);
//}
//if (substr($rootDir2,-1)=="/" || substr($rootDir2,-1)=="\\") {
//	$rootDir2 = substr($rootDir2, 0, -1);
//}
if (substr($rootDir3,-1)=="/" || substr($rootDir3,-1)=="\\") {
	$rootDir3 = substr($rootDir3, 0, -1);
}

//$rootDir1.="/";
//$rootDir2.="/";
$rootDir3.="/";
//print(" rootDir 1 is $rootDir1");
//print("<br>");
//print(" rootDir 2 is $rootDir2");
//print("<br>");
print(" rootDir 3 is $rootDir3");
print("<br>");

$filePath = $_GET['path'];

// If the filename is relative, add the rootDir
if (substr($filePath,0,1)==".") {
//	$fileName1 = $rootDir1.$filePath;
//	print(" final path1 is $fileName1 ");
//	if (is_file($fileName1)) print(" - a valid file");
//	print("<br>");
//	$fileName2 = $rootDir2.$filePath;
//	print(" final path2 is $fileName2 ");
//	if (is_file($fileName2)) print(" - a valid file");
//	print("<br>");
	$fileName3 = $rootDir3.$filePath;
	print(" final path3 is $fileName3 ");
	if (is_file($fileName3)) print(" - a valid file");
	print("<br>");
	if(($fh = fopen($fileName3, "r")) === FALSE) {
		print (" - cannot open it");
	} else {
		print (" - opened fine");
		fclose($fh);
	}
} else {
	// Add the domain
	$fileName = realpath2($myBase.$filePath);
	if ($fileName.length==0) $fileName = $myBase.$filePath;
	print("absolute final path is $fileName ");
	if (is_file($fileName)) print(" - a valid file");
	if(($fh = fopen($fileName, "r")) === FALSE) {
		print (" - cannot open it");
	} else {
		print (" - opened fine");
		fclose($fh);
	}
print("<br>");
}

function realpath2($path) {
	//check if realpath is working
        if (strlen(realpath($path))>0) {
		print"using realpath ";
		print("<br>");
		return realpath($path);
	}
	print"not using realpath ";
	print("<br>");

	///if its not working use another method///
	$p=getenv("PATH_TRANSLATED");
	$p=str_replace("\\","/",$p);
	$p=str_replace(basename(getenv("PATH_INFO")),"",$p);
	if (substr($p,-1)=="/" || substr($p,-1)=="\\") {
		$p = substr($p, 0, -1);
	}
	$p.="/";
	if ($path==".") return $p;

	//now check for back directory//
	$p=$p.$path;
	
	$dirs=split("/",$p);
	foreach($dirs as $k => $v) {
		if ($v=="..") {
			$dirs[$k]="";
			$dirs[$k-2]="";
		}
	}
	$p="";
	foreach($dirs as $k => $v){
		if (strlen($v)>0) $p.=$v."/";
	}
	$p=substr($p,0,strlen($p)-1);
	//print $p;
	//print("<br>");

	if (is_dir($p)) return $p;
	if (is_file($p)) return $p;   

	return false;
} 
//$filePath = "../Content/AuthorPlus/Courses/1171273156451/Exercises/1172058840715.xml";
//$physicalPath = realpath2($filePath);
//print("physical file is {$physicalPath}");

?>