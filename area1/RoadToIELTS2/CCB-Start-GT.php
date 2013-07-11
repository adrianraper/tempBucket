<?php
	// Initialisation
	require_once '../startInit.php';
	
	// Picking up passed data
	require_once '../readPassedVariables.php';
	
	// For this product
	$productCode = 52; // RoadToIELTS 2
	$swfName = 'RoadToIELTS.swf';
	$webShare = '';
	$startControl = "$webShare/Software/BentoTitles/IELTS/bin-debug/";
	
	// Picking up IP and referrer for security checking
	require_once '../securityCheck.php';
	
	$locationFile = "config.xml";
	// For PLS, IE might strip HTTP_REFERER
	if (isset($_SESSION['Referer'])) {
		$referrer = $_SESSION['Referer'];
	}
	
	// There is a strange bug that squishes everything up if the page is empty apart from the swf
	echo "<p/>";
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>Road to IELTS from Clarity and the British Council</title>
	<link rel="shortcut icon" href="/Software/R2IV2.ico" type="image/x-icon" />
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
		var versionControl = "&version=1107";

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
