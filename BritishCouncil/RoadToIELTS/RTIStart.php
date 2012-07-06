<?php
session_start();
include_once("libQuery.php");
$rootID = $_SESSION['rootID'];
$validLink = true;
$ename=$_SESSION['userName'];
$id = $_SESSION['studentID'];
$email = $_SESSION['email'];
$expiryDateStr = $_SESSION['expiryDate'];
$productCode = $_SESSION['productCode'];
if($productCode == "13"){
	$programVersion = 'G';
}else{
	$programVersion = 'A';
}
$password=$_SESSION['password'];
if( $id == ''){
	$id = $_GET['studentID'];
}
if( $password == ''){
	$password = $_GET['password'];
}
$stage = "1";
try{
	//=========Get user registration date========
	$method = "getRegDate";
	$buildXML = '<query method="'.$method.'" studentID="'.$id.'" dbHost="100"/>';
	$postXML = urlencode($buildXML);
	sendAndLoad($postXML, $contents);

	// Put the contents into an XML object and see what it says.
	$xml = simplexml_load_string($contents);
	$parser=xml_parser_create();

	//Specify element handler
	xml_set_element_handler($parser,"start","stop");

	// Create classes to hold the result of the parsing
	$userInfo=array();
	$errorInfo=array();

	// Parse the XML string - but this doesn't actually create anything.
	xml_parse($parser,$contents);
	//Free the XML parser
	xml_parser_free($parser);

	$userID=0;
	$regTime = time();
	// First - was an error returned?
	$errorCode = $errorInfo['CODE'];
	switch($errorCode) {
		case '206':
		case '203':
		case '210':
			break;
		case '204':
			$failReason = "Wrong password";
			break;
		case '208':
			$failReason = "User expired";
			break;
		default:
			// If no error, then get user information
			$userID = $userInfo['USERID'];
			$regDate = $userInfo['REGDATE'];
			$regTime = strtotime($regDate);
	}

	if($regTime >= $STAGEFOURTIME2){
		$stage = "2";
	} else if( $regTime >= $STAGETHREETIME2 && $regTime < $STAGEFOURTIME2){
		$stage = "1";
	} else if( $regTime >= $STAGETWOTIME2 && $regTime < $STAGETHREETIME2){
		$stage = "3";
	} else if( $regTime >= $STAGEONETIME2 && $regTime < $STAGETWOTIME2){
		$stage = "2";
	} else if( $regTime >= $STAGEFOURTIME && $regTime < $STAGEONETIME2){
		$stage = "1";
	} else if( $regTime >= $STAGETHREETIME && $regTime < $STAGEFOURTIME){
		$stage = "3";
	} else if( $regTime >= $STAGETWOTIME && $regTime < $STAGETHREETIME){
		$stage = "2";
	} else {
		$stage = "1";
	}
} catch (Exception $e){
	//error_log("\nException: ".$e->getMessage(), 3, dirname(__FILE__)."/logs/debug.log");
}
?>
<HTML><head>
<meta http-equiv=Content-Type content="text/html; charset=UTF-8">
<link rel="shortcut icon" href="/BritishCouncil/Software/RoadToIELTS/RoadToIELTS.ico" type="image/x-icon">
<TITLE>Road to IELTS from Clarity and the British Council</TITLE>
<script language="JavaScript1.1" type="text/javascript">
<!-- 
// -----------------------------------------------------------------------------
// The folder that is the root of the Clarity installation
// -----------------------------------------------------------------------------
var webShare = "/BritishCouncil";
document.write('<script language="javascript" src="' + webShare + '/Software/Common/openwin.js"></script>');
document.write('<script language="JavaScript1.1" type="text/javascript" src="' + webShare + '/Software/Common/swfobject.js"></script>');
// -->
</script>
<script language="JavaScript1.1" type="text/javascript">
<!--
// Specific Author Plus functions
function APOStart_DoFSCommand(command, args) {
	if (command == "scrolltop") {
		scrollTo(0,0);
	}
	else if (command == "browserExit") {
		var xwinobj=null;
		xwinobj=window.opener;
		if (xwinobj!=null) {
			window.close();
		}
	}
}
// Functions used by regular Author Plus (focus only works in IE)
var isIE  = (navigator.appVersion.indexOf("MSIE") != -1) ? true : false;
var isWin = (navigator.appVersion.toLowerCase().indexOf("win") != -1) ? true : false;
function focusIt(){
	if (isIE && isWin) {
		document.APOStart.focus();
	}
}
// -->
</SCRIPT>
<SCRIPT LANGUAGE="VBScript">
<!--
// Catch the fscommand in ie with vbscript, and pass
// it on to JavaScript.
Sub APOStart_FSCommand(ByVal command, ByVal args)
    call APOStart_DoFSCommand(command, args)
end sub
//-->
</SCRIPT>
<style type="text/css">
<!--
body {
	margin-left: 4px;
	margin-top: 4px;
}
-->
</style>
</HEAD>
<BODY bgcolor="#FFFFFF" onLoad="focusIt();">
<div align="center"> 
	<? if ($validLink): ?> 
	<div id="flashcontent">
<br>
This application requires Adobe's Flash player, running at least version 8. <br>
It seems your browser doesn't have this at the moment. <br>
Please <a href="http://www.adobe.com/shockwave/download/download.cgi?P1_Prod_Version=ShockwaveFlash" alt="Download Flash">download</a> the latest Adobe Flash Player.
	</div>
<script language="JavaScript1.1" type="text/javascript">
	var coordsWidth = 760; var coordsHeight = 640;
	// If you want to use a magnified screen, these dimensions are to the right scale
	// Do note that occasionally line breaks will change fractionally which might cause odd effects.
	//var coordsWidth = 910; var coordsHeight = 605;
	//var coordsWidth = 1137; var coordsHeight = 756;
	
	var sections = location.pathname.split("/");
	var userdatapath = sections.slice(0,sections.length-1).join("/");
	var argList="?browser=true&userDataPath=" + userdatapath;
	argList+="&location=location-<? echo $programVersion.$stage ?>.txt";
	argList+="&licence=licence-<? echo $programVersion ?>.txt";
		var so = new SWFObject(webShare + '/Software/Common/control.swf' + argList, "APOStart", coordsWidth, "100%", "8", "#FFFFFF");
		so.addParam("salign", "t");
		so.addVariable("rootID", "<? echo $rootID ?>");
		so.addVariable("username", "<? echo $ename?>");
		so.addVariable("password", "<? echo $password?>");
		//so.addVariable("password", getQueryParamValue("password"));
		so.addVariable("studentID", "<? echo $id ?>");
		so.addVariable("email", "<? echo $email ?>");
		so.addVariable("expiryDate", "<? echo $expiryDateStr ?>");
		so.addVariable("country", "China");
		so.write("flashcontent");
</script>
	<?endif?>
	<? if ($validLink==false): ?> 
	<div id="invalidLink">
<br>
This application can only be run from the NEEA website. <br>
<a href="http://ielts.etest.net.cn" alt="Register for IELTS">Please log in at the NEEA website</a>.
	</div>
<br></br><? echo $encrypt; ?>
<br></br><? echo $fullDecrypt; ?>
	<?endif?>
</div>
</BODY>
</HTML>
