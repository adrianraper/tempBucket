<?php
include_once("lib/php/webclient.func.cl.php");
include_once("lib/php/xml.func.cl.php");

$serlet = $_SERVER['HTTP_HOST']."/Software/Common/Source/SQLServer/runProgressQuery.php";

$attributes = array(
	"method" => "SCORMGetSummary",
	"studentID" => $_GET['sid'],
	"prefix" => $_GET['prefix'],
	"courseid" => $_GET['course'],
	"userType" => "0",
	"databaseVersion" => "4"	
);
/*
$attributes = array(
	"method" => "SCORMGetSummary",
	"studentID" => 'scormlearner',
	"prefix" => 'DEV',
	"courseid" => '1255000001100',
	"userType" => "0",
	"databaseVersion" => "4"	
);
*/
$sendXML = buildXMLNodeStr("query", $attributes);
sendAndLoad($serlet, $sendXML, $recieveXML);
$outArray = xmlToArray($recieveXML);

$progress = $outArray['SUMMARY']['TOTALSCORE'];
$spendTime = $outArray['SUMMARY']['TIMESPEND'];

if($_GET['practice']){
	$attributes['courseid'] = $_GET['practice'];
	$sendXML = buildXMLNodeStr("query", $attributes);
	sendAndLoad($serlet, $sendXML, $recieveXML);
	$outArray = xmlToArray($recieveXML);
	$spendTime += $outArray['SUMMARY']['TIMESPEND'];
	if (($outArray['SUMMARY']['TIMESPEND']) > 0){
		$progress += 100;
	}
	$score = "&score=".$outArray['SUMMARY']['TOTALSCORE'];
}else{
	$score = "&score=0";
}
$output = "progress=".$progress.$score;
$spendTimeString = gmdate("H:i:s.00", $spendTime);
$output .= "&spendTime=".$spendTimeString;

header("Access-Control-Allow-Origin: *");
echo $output;
?>