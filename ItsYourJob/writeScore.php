<?php
session_start();
require_once("Variables.php");
require_once("libQuery.php");

if(writeScore()){
	header("Content-Type: text/plain");
	echo "success";
}else{
	header("Content-Type: text/plain");
	echo "failed";
}

function writeScore(){
	global $userInfo, $errorInfo, $failReason;
	$userid = $_SESSION['USERID'];
	$sessionid = $_SESSION['SESSIONID'];
	$cousreid = $_GET['o'];
	$unitid = $_GET['u'];
	$itemid = $_GET['i'];
	$score = $_GET['s'];
	$correct = $_GET['c'];
	$wrong = $_GET['w'];
	$skipped = $_GET['m'];
	$duration = $_GET['d'];
	if($duration == "NaN"){
		$duration = "0";
		//error_log("\r\nWarning: The score's duration is error!", 3, "debug.txt");
	}
	// AR Added hard code of productCode since its fixed for IYJ
	$buildXML = '<query method="writeScore" '.
				'userid="'.$userid.
				'" courseid="'.$cousreid.
				'" unitid="'.$unitid.
				'" sessionid="'.$sessionid.
				'" itemid="'.$itemid.
				'" score="'.$score.
				'" correct="'.$correct.
				'" wrong="'.$wrong.
				'" skipped="'.$skipped.
				'" duration="'.$duration.
				'" productCode="'.'1001'.
				'" dbHost="2" databaseVersion="6" />';

//	error_log("writeScore= $buildXML\r\n", 3, "../Debug/debug_iyj.log");
	sendAndLoad($buildXML, $contents);
	//error_log("query= $buildXML\r\n", 3, dirname(__FILE__)."\debug.txt");
	$xml = simplexml_load_string($contents);
//	error_log("writeScore= $contents\r\n", 3, "../Debug/debug_iyj.log");
	$parser=xml_parser_create();
	xml_set_element_handler($parser,"start","stop");

	// Parse the XML string - but this doesn't actually create anything.
	xml_parse($parser,$contents);
	//Free the XML parser
	xml_parser_free($parser);

	$userID=0;
	$failReason = "";
	
	// First - was an error returned?
	$errorCode = $errorInfo['CODE'];
	switch($errorCode) {
		case '101':
			$failReason = "No query sent";
			break;
		case '206':
		case '203':
			$failReason = "No such user";
			break;
		case '204':
			$failReason = "Wrong password";
			//echo "error code=".$errorCode;
			break;
		case '208':
			$failReason = "User expired";
			break;
		case '211':
			$failReason = "User repeat";
			break;
		default:
			break;
	}

	if($userInfo['USERID'] > 0){
		return true;
	}else{
		return false;
	}
}
?>
