<?php
	session_start();
	unset($_SESSION['dbHost']);
	unset($_SESSION['UserName']);
	unset($_SESSION['Password']);
	
	$userName = $password = $extraParam = $licenceFile = $dbHost = '';	
	
	if (isset($_REQUEST['dbHost'])) $_SESSION['dbHost'] = $_REQUEST['dbHost'];
	
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
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>DMS - Clarity only</title>
	<link rel="shortcut icon" href="/Software/RM.ico" type="image/x-icon" />
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="language" content="en" />
	<meta name="description" content="" />
	<meta name="keywords" content="" />

	<script src="//ajax.googleapis.com/ajax/libs/swfobject/2.2/swfobject.js"></script>
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
			thisMovie("dms").focus();
		}
		// *********
		// *********
		
		var startControl = webShare + "/Software/BentoTitles/ResultsManager/bin-debug/";
		var argList = "?version=3.6.3.1";
		
		// see whether variables have come from command line or, preferentially, session variables
		var jsUserName = swfobject.getQueryParamValue("username");
		var jsPassword = swfobject.getQueryParamValue("password");
		var jsdbHost = swfobject.getQueryParamValue("dbHost");;
		var flashvars = {
			//host: startControl,
			username: jsUserName,
			password: jsPassword,
			rootID: swfobject.getQueryParamValue("rootID"),
			server: "<?php echo $server ?>",
			ip: "<?php echo $ip ?>",
			dbHost: jsdbHost
		};
		var params = {
			id: "dms",
			name: "dms",
			scale: "noScale"
		};
		var attr = {
			id: "dms",
			name: "dms"
		};
		var expressInstall = webShare + "/Software/Common/expressInstall.swf";
		flashvars.sessionid = "<?php echo session_id(); ?>";
		swfobject.embedSWF(startControl + "DMSApplication.swf" + argList, "altContent", "100%", "100%", "9.0.45", expressInstall, flashvars, params, attr);
	</script>
	<style type="text/css">
		html, body { height:100%; }
		body { 	margin-left: 4px; margin-top: 4px; }
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
