<?php

	require_once('../../Software/Common/encryptURL.php');
	
	session_start();
	$username = $password = $extraParam = $licenceFile = $prefix = $version = '';
	$studentID = $email = $userID = $instanceID = '';
	$referrer = $ip = $server = $productCode = $courseFile = $accountName = '';
	
	// For this product
	$productCode = 1; // Author Plus
	// gh#371 Is data passed encrypted in the URL?
	if (isset($_GET['data'])) {
		$crypt = new Crypt();
		$data = $crypt->decodeSafeChars($_GET['data']);
		parse_str($crypt->decrypt($data));
		
	} else {
		// change capitalisation of variables
		if (isset($_SESSION['UserID'])) $userID = $_SESSION['UserID']; 
		if (isset($_SESSION['UserName'])) $username = $_SESSION['UserName']; 
		if (isset($_SESSION['Password'])) $password = $_SESSION['Password'];
		if (isset($_SESSION['StudentID'])) $studentID = $_SESSION['StudentID'];
		if (isset($_SESSION['Email'])) $email = $_SESSION['Email'];
		if (isset($_SESSION['InstanceID'])) $instanceID = $_SESSION['InstanceID'];
		if (isset($_SESSION['AccountName'])) $accountName = $_SESSION['AccountName'];
			
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
		}
	}

	if (!$prefix) {
		$logStr = "from Start page Time=".date("D M j G:i:s T Y").", HTTP_HOST=".$_SERVER['HTTP_HOST'].", HTTP_X_FORWARDED_FOR=".$_SERVER['HTTP_X_FORWARDED_FOR'].", HTTP_CLIENT_IP=".$_SERVER["HTTP_CLIENT_IP"].", REMOTE_ADDR=".$_SERVER["REMOTE_ADDR"].", pc=".$productCode;
		error_log("$logStr\r\n", 3, "/tmp/session_vars.log");
		header("location: /error/session_timeout.htm");
		exit;
	}
	
	$locationFile = "location.txt";

	// Make sure we know where is the udp (mod rewrite doesn't change the start folder)
	if (isset($_GET['udp'])) {
		$userdatapath = $_GET['udp'];
	} else if (isset($_GET['UDP'])) {
		$userdatapath = $_GET['UDP'];
	} else {
		$userdatapath='';
	}
	if (isset($_GET['courseFile'])) {
		$courseFile = $_GET['courseFile'];
	} else {
		$courseFile = "course.xml";
	}
	
	$server = $_SERVER['HTTP_HOST'];
	// v6.5.6 Add support for HTTP_X_FORWARDED_FOR
	if (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
		// This might show a list of IPs. Assume/hope that EZProxy puts itself at the head of the list.
		// Not always it doesn't. So need to send the whole list to the licence checking algorithm. Better send as a list than an array.
		//$ipList = explode(',',$_SERVER['HTTP_X_FORWARDED_FOR']);
		//$ip = $ipList[0];
		$ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
	} elseif (isset($_SERVER['HTTP_TRUE_CLIENT_IP'])) {
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
	} else if (isset($_SESSION['Referer'])) {
		$referrer = $_SESSION['Referer'];
	}
	// There is a stange behaviour while resize not working if nothing is on the screen. Temp solution: make a empty div.
	echo "<p> </p>";	
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>Author Plus from Clarity</title>
	<link rel="shortcut icon" href="/Software/AP.ico" type="image/x-icon" />
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
		// v6.5.6.5 VideoPlayer
		function popUpVideoPlayer(mediaURL,n,w,h,tb,stb,l,mb,sb,rs,x,y) {
			alert("in videoPlayer javascript");
			var url = '/jwplayer/videoPlayer.html?url=' + mediaURL;
			openWindowForNNW(url,n,w,h,tb,stb,l,mb,sb,rs,x,y);
		}
		
		function onLoad() {
			thisMovie("orchid").focus();
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
		argList+="&prefix=<?php echo $prefix ?>&productCode=<?php echo $productCode ?>";
		argList+="&cache=<?php echo time() ?>";
		argList+="&accountName=<?php echo $accountName; ?>";
		
		// see whether variables have come from command line or, preferentially, session variables
		if ("<?php echo $username ?>".length>0) {
			var jsUserName = "<?php echo $username ?>";
		} else {
			var jsUserName = swfobject.getQueryParamValue("username");
		}
		if ("<?php echo $password ?>".length>0) {
			var jsPassword = "<?php echo $password ?>";
		} else {
			var jsPassword = swfobject.getQueryParamValue("password");
		}
		if ("<?php echo $studentID ?>".length>0) {
			var jsStudentID = "<?php echo $studentID ?>";
		} else {
			var jsStudentID = swfobject.getQueryParamValue("studentID");
		}
		if ("<?php echo $userID ?>".length>0) {
			var jsUserID = "<?php echo $userID ?>";
		} else {
			var jsUserID = swfobject.getQueryParamValue("userID");
		}
		if ("<?php echo $email ?>".length>0) {
			var jsEmail = "<?php echo $email ?>";
		} else {
			var jsEmail = swfobject.getQueryParamValue("email");
		}
		if ("<?php echo $instanceID ?>".length>0) {
			var jsInstanceID = "<?php echo $instanceID ?>";
		} else {
			var jsInstanceID = swfobject.getQueryParamValue("instanceID");
		}
		// the rest can come from other kinds of integration
		if ("<?php echo $course ?>".length>0) {
			var queryStringCourseID = "<?php echo $course ?>";
		} else {
			var queryStringCourseID = swfobject.getQueryParamValue("course");
		}
		if ("<?php echo $startingPoint ?>".length>0) {
			var queryStringStartingPoint = "<?php echo $startingPoint ?>";
		} else {
			var queryStringStartingPoint = swfobject.getQueryParamValue("startingPoint");
		}
		var queryStringPreview = swfobject.getQueryParamValue("s_preview");
		var queryStringCourseID = swfobject.getQueryParamValue("s_courseid");
		var queryStringStartingPoint = swfobject.getQueryParamValue("s_exerciseid");
		var flashvars = {
			username: jsUserName,
			password: jsPassword,
			studentID: jsStudentID,
			userID: jsUserID,
			email: jsEmail,
			instanceID: jsInstanceID,
			course: queryStringCourseID,
			startingPoint: queryStringStartingPoint,
			action: swfobject.getQueryParamValue("action"),
			referrer: "<?php echo $referrer ?>",
			server: "<?php echo $server ?>",
			ip: "<?php echo $ip ?>",
			courseFile: "<?php echo $courseFile ?>",
			licence: ""
		};
		if (queryStringPreview=="true") flashvars.preview = "true";					
		// v6.5.6 For preview from RM - overwrite any other conflicting parameters
		//if (swfobject.getQueryParamValue("s_preview")=='true') {
		if (swfobject.getQueryParamValue("preview")) {
			flashvars.preview = "true";
		}
			
		var params = {
			id: "orchid",
			name: "orchid",
			scale: "showall",
			menu: "false",
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
//		swfobject.embedSWF(startControl + "control.swf" + argList, "altContent", coordsWidth, coordsHeight, "9.0.28", expressInstall, flashvars, params, attr);
		swfobject.embedSWF(startControl + "control.swf" + argList, "altContent", "100%", "100%", "9.0.28", expressInstall, flashvars, params, attr);
	</script>

<!--CSS pop up layout box-->
<link rel="stylesheet" type="text/css" href="../../css/loadprogram.css" />
<style type="text/css">
	body { 	margin-left: 0px; margin-top: 0px; margin-right: 0px; margin-bottom: 0px}
</style>
</head>
<body onload="onLoad()">
<?php 
//2013 Mar 5 Vivying added 
//if it is resizing flag, disable the scollbar enabling in CSS by removing the div id
if (isset($_GET['resize'])) {
?> 
<div id="">
<?php 
}
else {
//otheriwse this id in CSS will enable the scrollbar
?> 	
<div id="load_program_original">
<?php 
}
?> 	
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
</div>

</body>
</html>
