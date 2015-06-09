<?php
// gh#1241 Tidy up a little
session_start();	// Enable session
require_once("Variables.php");

$frequency = $_SESSION['FREQUENCY'];
$licenceType = $_SESSION['LICENCETYPE'];
if($frequency == 1){ // Daily
	$fre = 1;
}else if($frequency == 7){ // Weekly
	$fre = 7;
}else{ // All at once
	$fre = 0;
}
$today = time();
if($_SESSION['id'] != "iyjguest"){
	$startDate = $_SESSION['STARTDATE'];
	if($startDate == "" || $licenceType == "5"){
		$startDate = $_SESSION['LICENCESTARTDATE'];
	}

	$expiryDate = $_SESSION['EXPIRYDATE'];
	if($expiryDate == "" || $licenceType == "5"){
		$expiryDate = $_SESSION['LICENCEEXPIRYDATE'];
	}
}else{
	$startDate = time();
	$expiryDate = time() + 3600 * 24 * 30;
}

$expiryDateStr = Date("jS F Y", $expiryDate);
// Get the content from XML File
$languageCode = $_SESSION['LANGUAGECODE'];
// gh#1241 Get content from config and database
$contentLocation=(isset($_SESSION['CONTENTLOCATION'])) ? $_SESSION['CONTENTLOCATION'] : 'ItsYourJob';
//error_log("content comes from".$contentFolder.$contentLocation."\r\n", 3, "../Debug/debug_iyj.log");
$EmuXML = simplexml_load_file($contentFolder.$contentLocation.'/Emu.xml');
/*
if ($languageCode == "NAMEN"){
} else if ($languageCode == "INDEN"){
    $EmuXML = simplexml_load_file('../Content/ItsYourJob-Indian/Emu.xml');
} else {
    $EmuXML = simplexml_load_file('../Content/ItsYourJob/Emu.xml');
}
*/
/*---------- Main progress ----------*/
if($fre == 7){
	$endDate = $startDate + ($fre - 1) * 24 *3600;
	foreach ($EmuXML->children() as $course_node){
		$startDateStr = Date("jS F Y", $startDate);
		$endDateStr = Date("jS F Y", $endDate);
		if( (($today-$startDate) >= 0 ) && ( ($today-$startDate) < $fre * 24 *3600) ){
			$course_node->addAttribute('current', "true");
		}
		$course_node->addAttribute('enableDate', $startDateStr);
		$course_node->addAttribute('endDate', $endDateStr);
		$course_node->addAttribute('disableDate', $expiryDateStr);
		$startDate = $startDate + $fre * 24 * 3600;
		$endDate = $startDate + ($fre - 1) * 24 *3600;
	}
} else {
	foreach ($EmuXML->children() as $course_node){
		$startDateStr = Date("jS F Y", $startDate);
		if( (($today-$startDate) >= 0 ) && (($today-$startDate) < $fre * 24 * 3600) ){
			$course_node->addAttribute('current', "true");
		}
		$course_node->addAttribute('enableDate', $startDateStr);
		$course_node->addAttribute('disableDate', $expiryDateStr);
		$startDate = $startDate + $fre * 24 * 3600;
	}
}

$response = $EmuXML->asXML();
// Tell the client that the output content type is XML format.
header("Content-Type: text/xml");
echo $response;
/*-----------------------------------*/
