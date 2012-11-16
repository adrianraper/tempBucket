<?php

	if (isset($_GET['session']))
		session_id($_GET['session']);
		
	session_start();
	$currentSessionID = session_id();
	
	$userName = $password = $extraParam = $licenceFile = $prefix = $version = '';
	$studentID = $Email = $email = $userID = $instanceID = '';
	$referrer = $ip = $server = $productCode = '';

	// For this product
	// $productCode = 52; // RoadToIELTS 2
	$swfName = 'RoadToIELTS.swf';
	$webShare = '';
	$startControl = "$webShare/Software/ResultsManager/web/";

	$locationFile = "tablet-config.xml";
	
	if (isset($_SESSION['UserID'])) $userID = $_SESSION['UserID'];
	if (isset($_SESSION['UserName'])) $userName = rawurlencode($_SESSION['UserName']);
	if (isset($_SESSION['Password'])) $password = rawurlencode($_SESSION['Password']);
	if (isset($_SESSION['StudentID'])) $studentID = $_SESSION['StudentID'];
	if (isset($_SESSION['Email'])) $Email = $_SESSION['Email'];
	if (isset($_SESSION['InstanceID'])) $instanceID = $_SESSION['InstanceID'];

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
	if (isset($_SERVER['HTTP_REFERER']) && isset($_SERVER['HTTP_REFERER']) != '') {
		if (strpos($_SERVER['HTTP_REFERER'],'?')) {
			$referrer=substr($_SERVER['HTTP_REFERER'],0,strpos($_SERVER['HTTP_REFERER'],'?'));
		} else {
			$referrer = $_SERVER['HTTP_REFERER'];
		}
	// For PLS, IE might strip HTTP_REFERER
	} elseif (isset($_SESSION['Referer'])) {
		$referrer = $_SESSION['Referer'];
	}

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>Road to IELTS from Clarity and the British Council</title>
	<link rel="shortcut icon" href="<?php echo $webShare ?>/Software/R2IV2.ico" type="image/x-icon" />
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="language" content="en" />
	<meta name="description" content="" />
	<meta name="keywords" content="" />

	<link rel="stylesheet" type="text/css" href="<?php echo $webShare ?>/Software/Common/ielts.css" />

	<script type="text/javascript" language="JavaScript" src="<?php echo $webShare ?>/Software/Common/jquery-1.7.1.min.js"></script>
	<script type="text/javascript" language="JavaScript" src="<?php echo $webShare ?>/Software/Common/openwin.js"></script>
	<script type="text/javascript" language="JavaScript" src="<?php echo $webShare ?>/Software/Common/swfobject2.js"></script>
	<script type="text/javascript" language="JavaScript" src="<?php echo $webShare ?>/Software/Common/SCORM_API_Wrapper.js"></script>

	<script type="text/javascript" language="JavaScript" src="<?php echo $webShare ?>/Software/Common/ielts.js"></script>

	<script type="text/javascript">
		// ****
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

		// *********
		// *********
		var webShare = "<?php echo $webShare ?>";
		var startControl = "<?php echo $startControl ?>";
		var swfName = "<?php echo $swfName ?>";
		var versionControl = "&version=1097";

		// v6.5.5.6 Allow resize screen mode
		var coordsMinWidth = "990"; var coordsMaxWidth = "1200";
		var coordsMinHeight = "760"; var coordsMaxHeight = null;

		//var sections = location.pathname.split("/");
		//var userdatapath = sections.slice(0,sections.length-1).join("/");
		//var argList="?browser=true&userDataPath=" + userdatapath + "&location=<?php echo $locationFile ?>";
		//argList+="&cache=<?php echo time() ?>";
		
		var argList="?configFile=<?php echo $locationFile ?>";
		argList+="&prefix=<?php echo $prefix ?>&productCode=<?php echo $productCode ?>";
		argList+=versionControl;

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
		// If you pass studentID in command line, that seems more important than a session variable
		var jsStudentID = swfobject.getQueryParamValue("studentID");
		if (jsStudentID.length<=0) {
			var jsStudentID = "<?php echo $studentID ?>";
		}
		if ("<?php echo $userID ?>".length>0) {
			var jsUserID = "<?php echo $userID ?>";
		} else {
			var jsUserID = swfobject.getQueryParamValue("userID");
		}
		if ("<?php echo $Email ?>".length>0) {
			var jsEmail = "<?php echo $Email ?>";
		} else {
			var jsEmail = swfobject.getQueryParamValue("email");
		}
		if ("<?php echo $instanceID ?>".length>0) {
			var jsInstanceID = "<?php echo $instanceID ?>";
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
			scorm: swfobject.getQueryParamValue("scorm"),
			startTime: "<?php $msec = microtime(true); echo round(($msec * 1000)); ?>",
			referrer: "<?php echo $referrer ?>",
			server: "<?php echo $server ?>",
			ip: "<?php echo $ip ?>"
		};
		var params = {
			id: "bento",
			name: "bento",
			quality: "high",
			allowfullscreen: "true",
			scale: "default",
			allowscriptaccess: "always"
		};
		var attr = {
			id: "bento",
			name: "bento"
		};
		var expressInstall = webShare + "/Software/Common/expressInstall.swf";
		swfobject.embedSWF(startControl + swfName + argList, "altContent", coordsMinWidth, coordsMinHeight, "10.2.0", expressInstall, flashvars, params, attr);
	</script>

</head>
<body style="background-color:#F9F9F9;">
	<div style="background-color:#F9F9F9;" align="center" id="altContent">
		<p>This application requires Adobe's Flash player, running at least version 10.2.</p>
		<p>It seems your browser doesn't have this.</p>
		<p>Please download the latest Adobe Flash Player.</p>
		<p><a href="http://www.adobe.com/go/getflashplayer"><img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" border="0"/></a></p>
		<p>If you still get this message after installation, then your browser is stopping the scripts on this page from running.</p>
	</div>
<NOSCRIPT style="font-family: Arial, Helvetica, sans-serif; font-size:12px; text-align:center;">
This application requires your browser to support javascript and to have Adobe's Flash player installed. <br>
Your browser does not support scripting at the moment. If you are allowed, please use Internet Options from the menu<br>
to switch this on and then refresh this page.</NOSCRIPT>
</body>
</html>
