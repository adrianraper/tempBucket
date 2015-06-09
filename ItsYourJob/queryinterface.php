<?php
session_start();
require_once("Variables.php");
require_once("libQuery.php");
$query['courseid'] = array();
$query = array(
	"method" => "GETGENERALSTATS",
	"userID" => "231498", //$_SESSION['USERID'],
	"rootid" => "10719", //$_SESSION['ROOTID'],
	"courseid" => "1001", //$_SESSION['startingPoint'],
	"userType" => "0",
	"databaseVersion" => "4"	
);
$buildXML = buildXML($query);
sendAndLoad($buildXML, $responseXML, "progress");
//echo $responseXML;
$xml = simplexml_load_string($responseXML);
$parser = xml_parser_create();
xml_set_element_handler($parser,"praseXML","stop");
xml_parse($parser,$responseXML);
xml_parser_free($parser);
$output = "progress=".$statusInfo['AVERAGE'];
if($_SESSION['PRACTICEID'] != ""){
	//$query['courseid'] = $_SESSION['PRACTICEID'];
	$query['courseid'] = "1249436487189";
	$buildXML = buildXML($query);
	sendAndLoad($buildXML, $responseXML, "progress");
	//echo $responseXML;
	$xml = simplexml_load_string($responseXML);
	$parser = xml_parser_create();
	xml_set_element_handler($parser,"praseXML","stop");
	xml_parse($parser,$responseXML);
	xml_parser_free($parser);
}
$output .= "&score=".$statusInfo['AVERAGE'];

$scormEndTime = time();
$spendTime = $scormEndTime - $_SESSION['SCORMSTARTTIME'];
$spendTimeString = date("H:i:s.00", $spendTime);
//$output .= "&spendTime=".$spendTimeString;
$output .= "&spendTime=".$_SESSION['SCORMSTARTTIME'];
//$output .= "&courseid=".$_SESSION['PRACTICEID'];
header("Access-Control-Allow-Origin: *");
echo $buildXML.$responseXML.$output;
function praseXML($parser, $element_name, $element_attrs){
	global $statusInfo;	// Saving user information
	global $errorInfo;	// Saving error information of database opration
	switch(strtoupper($element_name)) {
		case "STATS":
			$statusInfo = $element_attrs;
			break;
        case "ERR":
			$errorInfo = $element_attrs;
			break;
	}
}
?>