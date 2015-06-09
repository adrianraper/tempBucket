<?php
session_start();
require_once("Variables.php");
require_once("libQuery.php");

if(updateSetting()){
	header("Content-Type: text/plain");
	echo "success";
}else{
	header("Content-Type: text/plain");
	echo "failed";
}

function updateSetting(){
	global $userInfo, $errorInfo, $failReason;
	$userid = $_SESSION['USERID'];
	$_SESSION['FREQUENCY'] = $_GET['time'];
	$_SESSION['CONTACTMETHOD'] = $_GET['method'];
	$_SESSION['PASSWORD'] = $_GET['pwd'];
	$_SESSION['LANGUAGECODE'] = $_GET['language'];
	$buildXML = '<query method="EMUUPDATEUSER" '.
				'userid="'.$userid.
				'" password="'.$_SESSION['PASSWORD'].
				'" frequency="'.$_SESSION['FREQUENCY'].
				'" contactMethod="'.$_SESSION['CONTACTMETHOD'].
				'" languageCode="'.$_SESSION['LANGUAGECODE'].
				'" dbHost="2" databaseVersion="5" />';

	sendAndLoad($buildXML, $contents, "progress");
	//error_log("query= $buildXML\r\n", 3, dirname(__FILE__)."\debug.txt");
	$xml = simplexml_load_string($contents);
	//error_log("result= $contents\r\n", 3, dirname(__FILE__)."\debug.txt");
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
		case '205':
			$failReason = "Update failed";
			break;
		default:
			$_SESSION['PASSWORD'] = $userInfo['PASSWORD'];
			$_POST['pwd'] = $userInfo['PASSWORD'];
			//error_log("pwd=".$_POST['pwd']."\r\n", 3, dirname(__FILE__)."\debug.txt");
			break;
	}

	if($errorCode > 0){
		return false;
	}else{
		return true;
	}
}