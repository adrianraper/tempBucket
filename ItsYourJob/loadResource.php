<?php
session_start();	// Enable session
$unitID = intval($_GET["unitID"], 10);

$xmlDoc = new DOMDocument();
$languageCode = $_SESSION['LANGUAGECODE'];
if($languageCode == "NAMEN"){
    $xmlDoc->loadXML(file_get_contents('../Content/ItsYourJob-NAmerican/Emu.xml'));
}else if($languageCode == "INDEN"){
	$xmlDoc->loadXML(file_get_contents('../Content/ItsYourJob-Indian/Emu.xml'));
}else{
    $xmlDoc->loadXML(file_get_contents('../Content/ItsYourJob/Emu.xml'));
}
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
?>