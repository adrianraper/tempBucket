<?php
    // gh#1458 If a portal is involved in running the start page, share a common session
    if (isset($PHPSESSID) && ($PHPSESSID!='')) {
        session_id($PHPSESSID);
    } elseif (isset($_GET['PHPSESSID']) && ($_GET['PHPSESSID']!='')) {
        session_id($_GET['PHPSESSID']);

        // gh#1314 This can be removed once all start pages link to v27 Bento apps
    } elseif (isset($_GET['session'])) {
        session_id($_GET['session']);
    }
    session_start();
    $currentSessionID = session_id();
	unset($_SESSION['dbHost']);
	if (isset($_REQUEST['dbHost'])) $_SESSION['dbHost']=$_REQUEST['dbHost'];
	
	$userName = $password = $extraParam = $licenceFile = '';
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>Clarity Test Administration</title>
	<link rel="shortcut icon" href="/Software/DPT.ico" type="image/x-icon" />
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="language" content="en" />
	<meta name="description" content="" />
	<meta name="keywords" content="" />

	<script type="text/javascript" language="JavaScript" src="/Software/Common/swfobject2.js"></script>
	<script type="text/javascript">
		// ****
		// Change this variable along with the above fixed paths
		var webShare = "";
		// 
		// ****
		function thisMovie(movieName) {
			/*if (navigator.appName.indexOf("Microsoft") != -1) {
				return window[movieName];
			} else {
				return document[movieName];
			}*/
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
			thisMovie("rm").focus();
		}
		// *********
		// *********
		
		var startControl = webShare + "/Software/ResultsManager/web/";
		var argList = "?version=3.8.77"
		
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
        var jsSessionID = "<?php echo $currentSessionID; ?>";

		var flashvars = {
			host: startControl, // THIS MUST INCLUDE THE TRAILING SLASH!
			username: jsUserName,
			password: jsPassword,
			rootID: swfobject.getQueryParamValue("rootID"),
			directStart: swfobject.getQueryParamValue("directStart"),
			followUp: swfobject.getQueryParamValue("followUp"),
			sessionID: jsSessionID
		};
		var params = {
			id: "rm",
			name: "rm",
			scale: "noScale"
		};
		var attr = {
			id: "rm",
			name: "rm"
		};
		var expressInstall = webShare + "/Software/Common/expressInstall.swf";
		// gh#1314
		// flashvars.sessionid = "<?php echo session_id(); ?>";
		swfobject.embedSWF(startControl + "TestAdmin.swf" + argList, "altContent", "100%", "100%", "9.0.45", expressInstall, flashvars, params, attr);
	</script>
	<style type="text/css">
		html, body { height:100%; }
		body { 	margin: 0px}
	</style>
</head>
<body onload="onLoad()">
<!-- Note that if you put another <div> round this one, it seems to stop RM loading -->
	<div align="center" id="altContent">
		<p>This application requires Adobe's Flash player, running at least version 9.0.45.</p>
		<p>It seems your browser doesn't have this.</p>
		<p>Please download the latest Adobe Flash Player.</p>
		<p><a href="http://www.adobe.com/go/getflashplayer"><img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" border="0"/></a></p>
		<p>If you still get this message, then your browser is stopping the scripts on this page from running.</p>
	</div>
<noscript>
This application requires your browser to support javascript and to have Adobe's Flash player installed. <br/>
Your browser does not support scripting at the moment. If you are allowed, please use Internet Options from the menu <br/>
to switch this on and then refresh this page.</noscript>
</body>
</html>
