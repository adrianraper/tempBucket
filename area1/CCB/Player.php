<?php
	// Initialisation
	require_once '../startInit.php';
	
	// Picking up passed data
	require_once '../readPassedVariables.php';
	
	// For this product
	$productCode = 54; // Rotterdam
	$swfName = 'Player.swf';
	$webShare = '';
	$startControl = "$webShare/Software/BentoTitles/RotterdamPlayer/bin-debug/";
	$locationFile = "configPlayer.xml";

	// Picking up IP and referrer for security checking
	require_once '../securityCheck.php';

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>Clarity Course Player</title>
	<link rel="shortcut icon" href="/Software/CCB.ico" type="image/x-icon" />
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="language" content="en" />
	<meta name="description" content="" />
	<meta name="keywords" content="" />

	<link rel="stylesheet" type="text/css" href="/Software/Common/ielts.css" />

	<script type="text/javascript" language="JavaScript" src="/Software/Common/jquery-1.7.1.min.js"></script>
	<script type="text/javascript" language="JavaScript" src="/Software/Common/openwin.js"></script>
	<?php require '../phpToJavascriptVars.php'; ?>
	<script type="text/javascript" language="JavaScript" src="/Software/Common/swfobject2.js"></script>

	<script type="text/javascript" language="JavaScript" src="/Software/Common/ielts.js"></script>

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
		var version = "1.0.0.371";

		// v6.5.5.6 Allow resize screen mode
		var coordsMinWidth = "990"; var coordsMaxWidth = "1200";
		var coordsMinHeight = "760"; var coordsMaxHeight = null;

		var sections = location.pathname.split("/");
		var userdatapath = sections.slice(0,sections.length-1).join("/");
		var argList="?configFile=<?php echo $locationFile ?>";
		argList+="&prefix=<?php echo $prefix ?>";
		argList+="&version=" + version;

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
			ip: "<?php echo $ip ?>",
			sessionid: "<?php echo $currentSessionID ?>"
		};
		// gh#371
		if (swfobject.getQueryParamValue("resize"))
			flashvars.resize = swfobject.getQueryParamValue("resize");
		
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
		var expressInstall = startControl + "expressInstall.swf";
		swfobject.embedSWF(startControl + swfName + argList, "altContent", coordsMinWidth, coordsMinHeight, "10.2.0", expressInstall, flashvars, params, attr);
	</script>
	
<!--CSS pop up layout box-->
<link rel="stylesheet" type="text/css" href="../../css/loadprogram.css" />
<style type="text/css">
	body { 	margin-left: 0px; margin-top: 0px; margin-right: 0px; margin-bottom: 0px}
</style>
</head>
<body onload="onLoad()">

<?php require_once '../resizeCSS.php';?>
<?php require_once '../orchidAltContent.php';?>

</body>
</html>
