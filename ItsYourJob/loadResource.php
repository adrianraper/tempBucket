<?php
// gh#1241 Tidy up a little
session_start();	// Enable session
require_once("Variables.php");

$unitID = intval($_GET["unitID"], 10);

$xmlDoc = new DOMDocument();
// gh#1241 Get content from config and database
//$languageCode = $_SESSION['LANGUAGECODE'];
$contentLocation=(isset($_SESSION['CONTENTLOCATION'])) ? $_SESSION['CONTENTLOCATION'] : 'ItsYourJob';
$EmuXMLFile = $contentFolder.$contentLocation.'/Emu.xml';
$xmlDoc->loadXML(file_get_contents($EmuXMLFile));
/*
if($languageCode == "NAMEN"){
    $xmlDoc->loadXML(file_get_contents('../Content/ItsYourJob-NAmerican/Emu.xml'));
}else if($languageCode == "INDEN"){
	$xmlDoc->loadXML(file_get_contents('../Content/ItsYourJob-Indian/Emu.xml'));
}else{
    $xmlDoc->loadXML(file_get_contents('../Content/ItsYourJob/Emu.xml'));
}
*/
$courseDoc = $xmlDoc->getElementsByTagName('course')->item($unitID-1);
$unitDocs = $courseDoc->getElementsByTagName('unit');
foreach($unitDocs as $unitDoc){
	if($unitDoc->getAttribute("type") == "resource"){
		$resourceDoc = $unitDoc;
		break;
	}
}

// Tell the client that the output content type is XML format.
header("Content-Type: text/xml");
echo $xmlDoc->saveXML($resourceDoc);