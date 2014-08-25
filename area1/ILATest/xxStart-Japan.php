<?php
session_start();
if( !preg_match("/Registration-Japan.php/", $_SERVER["HTTP_REFERER"]) ) {
	header("location: Registration-Japan.php");
}
//error_log("Referer is: ".$_SERVER["HTTP_REFERER"]."\r\n", 3, "logs/debug.txt");

$userName = $password = $extraParam = $licenceFile = $prefix = $version = '';
$studentID = $Email = $userID = $instanceID = '';
$referrer = $ip = $server = $productCode = '';
	
// For this product
$productCode = 36; // ILATest
$prefix = 'BCILA'; // ILATest
$prefix = 'Clarity'; // for local testing
$locationFile = "location-ILATest-Japanese.txt";
// v6.5.5.1 If the licence file exists, send a reference to it. Here we work out what the name would be.
$licenceFile = $prefix."_licence.txt";

if (isset($_POST['UserID'])) $userID = $_POST['UserID']; 
//if (isset($_SESSION['UserName'])) $userName = $_SESSION['UserName'];
if (isset($_POST['UserName'])) $userName = htmlentities($_POST['UserName'], ENT_QUOTES);
if (isset($_SESSION['InstanceID'])) $instanceID = $_SESSION['InstanceID'];
if (isset($_SESSION['Password'])) $password = $_SESSION['Password'];

$server=$_SERVER['HTTP_HOST'];
// For Akamai served files- a special header is attached. Check the Akamai configuration to see which files this works for.
if (isset($_SERVER['HTTP_TRUE_CLIENT_IP'])) {
	$ip=$_SERVER['HTTP_TRUE_CLIENT_IP'];
} elseif (isset($_SERVER["HTTP_CLIENT_IP"])) {
	$ip = $_SERVER["HTTP_CLIENT_IP"];
} else {
	$ip = $_SERVER["REMOTE_ADDR"];
}
// it is dangerous to send the whole referrer as you might get confused with parameters (specifically content)
if (isset($_SERVER['HTTP_REFERER'])) {
	if (strpos($_SERVER['HTTP_REFERER'],'?')) {
		$referrer=substr($_SERVER['HTTP_REFERER'],0,strpos($_SERVER['HTTP_REFERER'],'?'));
	} else {
		$referrer = $_SERVER['HTTP_REFERER'];
	}
}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>ILA Level Check from The British Council</title>
	<link rel="shortcut icon" href="/Software/AP.ico" type="image/x-icon" />
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="language" content="en" />
	<meta name="description" content="" />
	<meta name="keywords" content="" />

	<script type="text/javascript" language="JavaScript" src="/Software/Common/swfobject2.js"></script>
	<script type="text/javascript" language="JavaScript" src="/Software/Common/openwin.js"></script>
	<script language="JavaScript" type="text/javascript">
		// ****
		// Change this variable along with the above fixed paths
		var webShare = "";
		// 
		// ****
		function thisMovie(movieName) {
			if (window.document[movieName]) {
				return window.document[movieName];
			}
			if (navigator.appName.indexOf("Microsoft Internet") == -1) {
				if (document.embeds && document.embeds[movieName])
					return document.embeds[movieName];
			} else { // if (navigator.appName.indexOf("Microsoft Internet")!=-1)
				return document.getElementById(movieName);
			}
		}
		
		function onLoad() {
			thisMovie("orchid").focus();
		}

		function onUnload() {
			window.location = "Registration-Japan.php";
		}
		// *********
		// *********
		// Running scale, width and height with swfobject is off
		// If I set both to 100%, then IE shows a very small image, FF shows nothing (but the app is running)
		// If I set a specific height, then it doesn't matter what I put for width
		var startControl = webShare + "/Software/Common/";
		// v6.5.5.6 Allow resize screen mode
		if (swfobject.getQueryParamValue("resize")=="true") {;
			var coordsWidth = "100%"; var coordsHeight = "100%";
		} else {
			var coordsWidth = 760; var coordsHeight = 640;
		}
		var sections = location.pathname.split("/");
		var userdatapath = sections.slice(0,sections.length-1).join("/");
		var argList="?browser=true&userDataPath=" + userdatapath + "&location=<?php echo $locationFile ?>";
		argList+="<?php if (file_exists(dirname(__FILE__).'/'.$licenceFile)) {echo '&licence='.$licenceFile;} ?>";
		argList+="&prefix=<?php echo $prefix ?>&productCode=<?php echo $productCode ?>";
		
		// see whether variables have come from command line or, preferentially, session variables
		if ("<?php if (isset($userName)) echo $userName ?>".length>0) {
			var jsUserName = "<?php if (isset($userName)) echo $userName ?>";
		} else {
			var jsUserName = swfobject.getQueryParamValue("username");
		}
		if ("<?php if (isset($password)) echo $password ?>".length>0) {
			var jsPassword = "<?php if (isset($password)) echo $password ?>";
		} else {
			var jsPassword = swfobject.getQueryParamValue("password");
		}
		if ("<?php if (isset($studentID)) echo $studentID ?>".length>0) {
			var jsStudentID = "<?php if (isset($studentID)) echo $studentID ?>";
		} else {
			var jsStudentID = swfobject.getQueryParamValue("studentID");
		}
		if ("<?php if (isset($userID)) echo $userID ?>".length>0) {
			var jsUserID = "<?php if (isset($userID)) echo $userID ?>";
		} else {
			var jsUserID = swfobject.getQueryParamValue("userID");
		}
		if ("<?php if (isset($Email)) echo $Email ?>".length>0) {
			var jsEmail = "<?php if (isset($Email)) echo $Email ?>";
		} else {
			var jsEmail = swfobject.getQueryParamValue("email");
		}
		if ("<?php if (isset($instanceID)) echo $instanceID ?>".length>0) {
			var jsInstanceID = "<?php if (isset($instanceID)) echo $instanceID ?>";
		} else {
			var jsInstanceID = swfobject.getQueryParamValue("instanceID");
		}
		var flashvars = {
			username: jsUserName,
			password: jsPassword,
			studentID: jsStudentID,
			userID: jsUserID,
			email: jsEmail,
			instanceID: jsInstanceID,
			startingPoint: swfobject.getQueryParamValue("startingPoint"),
			course: swfobject.getQueryParamValue("course"),
			action: swfobject.getQueryParamValue("action"),
			referrer: "<?php echo $referrer ?>",
			server: "<?php echo $server ?>",
			ip: "<?php echo $ip ?>"
		};
		if (swfobject.getQueryParamValue("sessionID")) {
			flashvars.sessionID = swfobject.getQueryParamValue("sessionID");
		}
		var params = {
			id: "orchid",
			name: "orchid",
			allowfullscreen: "true"
		};
		// v6.5.5.6 Allow resize screen mode
		if (swfobject.getQueryParamValue("resize")=="true") {
			params.scale="showall";
		} else {
			params.scale="noScale";
		}
		var attr = {
			id: "orchid",
			name: "orchid"
		};
		var expressInstall = startControl + "expressInstall.swf";
		swfobject.embedSWF(startControl + "control.swf" + argList, "altContent", coordsWidth, coordsHeight, "9.0.28", expressInstall, flashvars, params, attr);
	</script>
<style type="text/css">
html, body {
	margin: 0px 0px auto;
	text-align:center;
	height: 100%;
}
</style>
</head>
<body onload="onLoad()" onunload="onUnload()">
	<div align="center" id="altContent">
		<p>This application requires Adobe's Flash player, running at least version 9.</p>
		<p>It seems your browser doesn't have this.</p>
		<p>Please download the latest Adobe Flash Player.</p>
		<p><a href="http://www.adobe.com/go/getflashplayer"><img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" border="0"/></a></p>
		<p>If you still get this message, then your browser is stopping the scripts on this page from running.</p>
	</div>
<NOSCRIPT>
This application requires your browser to support javascript and to have Adobe's Flash player installed. <br>
Your browser does not support scripting at the moment. If you are allowed, please use Internet Options from the menu<br>
to switch this on and then refresh this page.</NOSCRIPT>
</body>
</html>
