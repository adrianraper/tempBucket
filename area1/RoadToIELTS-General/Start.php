<?php

	// First, a temporary fix to allow some libraries to run R2IV2 without changing their exproxy links
	if (isset($_GET['prefix'])) {
		$prefix = $_GET['prefix'];
		if (strtolower($prefix)=='mcl') {
			header("location: /area1/RoadToIELTS2/Start-GT.php?prefix=$prefix");
		}
	}
	
	//require_once('../../englishonline/productClass.php');
	session_start();
	$userName = $password = $extraParam = $licenceFile = $prefix = $version = '';
	$StudentID = $Email = '';
	$referrer = $ip = $server = $productCode = '';
	
	// For this product
	$productCode = 13; // RoadToIELTS General training
	
	// If we do not know the prefix, the page shouldn't run.
	// The prefix might come from session variables or from the URL parameters
	// Read URL first in case session variables are lingering
	// allow case insensitive parameters
	if (isset($_GET['prefix'])) {
		$prefix = $_GET['prefix'];
	} elseif (isset($_GET['Prefix'])) {
		$prefix = $_GET['Prefix'];
	} elseif (isset($_SESSION['Prefix'])) {
		$prefix = $_SESSION['Prefix'];
	} else {
		// I think we should go to the page not found - otherwise you have no clue what is happening
		// This is NOT the correct way to generate a page not found error.
		header("location: /error/404_programs.htm");
		//header("HTTP/1.0 404 Not Found");
		//echo "page not found";
		//header("location: /index.php");
		exit;
	}
	// v6.5.5.1 If the licence file exists, send a reference to it. Here we work out what the name would be.
	$licenceFile = $prefix."_licence.txt";
	
	// The language version might come from session variables or from the URL parameters
	if (isset($_SESSION['RoadToIELTS-GeneralTraining'])) {
		$version = $_SESSION['RoadToIELTS-GeneralTraining']->languageCode;
	} elseif (isset($_GET['version'])){
		$version = $_GET['version'];
	} elseif (isset($_GET['Version'])){
		$version = $_GET['Version'];
	} else {
		$version="";
	}
	switch ($version) {
		//case "NAMEN":
		//	$locationFile = "location-NAmEN.txt";
		//	break;
		//case "INDEN":
		//	$locationFile = "location-IndEN.txt";
		//	break;
		default:
			$locationFile = "location.txt";
	}
	//echo "&version=".$version."&location=".$locationFile;
	if (isset($_SESSION['UserName'])) $userName = $_SESSION['UserName']; 
	if (isset($_SESSION['Password'])) $password = $_SESSION['Password'];
	if (isset($_SESSION['StudentID'])) $StudentID = $_SESSION['StudentID'];
	if (isset($_SESSION['Email'])) $Email = $_SESSION['Email'];
	
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
	$referrer="";
	if (isset($_SERVER['HTTP_REFERER'])) {
		if (strpos($_SERVER['HTTP_REFERER'],'?')) {
			$referrer=substr($_SERVER['HTTP_REFERER'],0,strpos($_SERVER['HTTP_REFERER'],'?'));
		} else {
			$referrer = $_SERVER['HTTP_REFERER'];
		}
	}
	// Specifically send a licence file for this customer and override the location
	//$licenceFile = '&licence='.$prefix.'_licence.txt';
	//$licenceFile = '&licence=licence.txt';
	//$locationFile = 'location-SQLServer.txt';
	
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>Road to IELTS General Training from Clarity and the British Council</title>
	<link rel="shortcut icon" href="/Software/RoadToIELTS.ico" type="image/x-icon">
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="language" content="en" />
	<meta name="description" content="" />
	<meta name="keywords" content="" />

	<script type="text/javascript" language="JavaScript" src="/Software/Common/swfobject2.js"></script>
	<script type="text/javascript" language="JavaScript" src="/Software/Common/openwin.js"></script>
	<script type="text/javascript">
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
		// *********
		// *********
		
		var startControl = webShare + "/Software/Common/";
		var coordsWidth = 760; var coordsHeight = 640;
		var sections = location.pathname.split("/");
		var userdatapath = sections.slice(0,sections.length-1).join("/");
		var argList="?browser=true&userDataPath=" + userdatapath + "&location=<?php echo $locationFile ?>";
		argList+="<?php if (file_exists(dirname(__FILE__).'/'.$licenceFile)) {echo '&licence='.$licenceFile;} ?>";
		argList+="&prefix=<?php echo $prefix ?>&productCode=<?php echo $productCode ?>";

		// see whether variables have come from command line or, preferentially, session variables
		if ("<?php echo $userName ?>".length>0) {
			var jsUserName = "<?php echo $userName ?>";
		} else {
			var jsUserName = swfobject.getQueryParamValue("username");
		}
		if ("<?php echo $password ?>".length>0) {
			var jsPassword = "<?php echo $password ?>";
		} else {
			var jsPassword = swfobject.getQueryParamValue("password");
		}
		if ("<?php echo $StudentID ?>".length>0) {
			var jsStudentID = "<?php echo $StudentID ?>";
		} else {
			var jsStudentID = swfobject.getQueryParamValue("studentID");
		}
		if ("<?php echo $Email ?>".length>0) {
			var jsEmail = "<?php echo $Email ?>";
		} else {
			var jsEmail = swfobject.getQueryParamValue("email");
		}
		var flashvars = {
			username: jsUserName,
			password: jsPassword,
			studentID: jsStudentID,
			email: jsEmail,
			startingPoint: swfobject.getQueryParamValue("startingPoint"),
			course: swfobject.getQueryParamValue("course"),
			action: swfobject.getQueryParamValue("action"),
			referrer: "<?php echo $referrer ?>",
			server: "<?php echo $server ?>",
			ip: "<?php echo $ip ?>"
		};
		//var flashvars = {};
		var params = {
			id: "orchid",
			name: "orchid",
			scale: "noScale"
		};
		var attr = {
			id: "orchid",
			name: "orchid"
		};
		var expressInstall = startControl + "expressInstall.swf";
		swfobject.embedSWF(startControl + "control.swf" + argList, "altContent", coordsWidth, coordsHeight, "9.0.28", expressInstall, flashvars, params, attr);
	</script>
	
<style type="text/css">
body {
	margin:0px auto;
	padding-top:1px;
	text-align:center;
}
</style>
</head>
<body onload="onLoad()">
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