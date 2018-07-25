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
	if (isset($_SESSION['UserName'])) $userName = rawurlencode($_SESSION['UserName']);  
	if (isset($_SESSION['Password'])) $password = rawurlencode($_SESSION['Password']);
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>Results Manager from Clarity</title>
	<link rel="shortcut icon" href="/Software/RM.ico" type="image/x-icon" />
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
		var argList = "?version=3.8.85"
		
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
        var domain = window.location.protocol + '//' + window.location.hostname + (window.location.port ? ':' + window.location.port : '');
        console.log("you are running from " + domain);

		var flashvars = {
            host: domain + "/Software/ResultsManager/web/", // This is the backend URL,
			username: jsUserName,
			password: jsPassword,
			rootID: swfobject.getQueryParamValue("rootID"),
			directStart: swfobject.getQueryParamValue("directStart"),
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
		swfobject.embedSWF(startControl + "ResultsManager.swf" + argList, "altContent", "100%", "100%", "9.0.45", expressInstall, flashvars, params, attr);
	</script>
	<style type="text/css">
		html, body { height:100%; }
		body { 	margin: 0px}
	</style>
</head>
<body onload="onLoad()">
	<div align="center" id="altContent">
		<p>This application requires Adobe's Flash player, but your browser can't run it or doesn't have it.</p>
		<p>The most likely reason is that the browser is blocking Flash player.</p>
		<p>Please enable the latest Adobe Flash Player.<a href="https://www.adobe.com/go/getflashplayer"><img src="https://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" border="0"/></a></p>
	</div>
<noscript>
This application requires your browser to support javascript and to have Adobe's Flash player installed and not blocked.<br/>
But your browser does not support scripting. If you are allowed, please use Options from the settings menu to switch <br/>
this on and then refresh this page.</noscript>
</body>
</html>
