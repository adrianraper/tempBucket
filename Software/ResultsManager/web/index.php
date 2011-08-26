<?php
	session_start();
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>ResultsManager</title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="language" content="en" />
	<meta name="description" content="" />
	<meta name="keywords" content="" />

	<script src="js/swfobject.js" type="text/javascript"></script>
	<script type="text/javascript">
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
		
		var flashvars = {
			//host: "http://Claritydata/Clarity/Software/ResultsManager/", // THIS MUST INCLUDE THE TRAILING SLASH!
			username: swfobject.getQueryParamValue("username"),
			password: swfobject.getQueryParamValue("password"),
			//rootID: 163
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
		
		flashvars.sessionid = "<?php echo session_id(); ?>";
		
		swfobject.embedSWF("ResultsManager.swf", "altContent", "100%", "100%", "9.0.0", "expressInstall.swf", flashvars, params, attr);
	</script>
	<style>
		html, body { height:100%; }
		body { margin:0; }
	</style>
</head>
<body onload="onLoad()">
	<div id="altContent">
		<h1>ResultsManager</h1>
		<p>Alternative content</p>
		<p><a href="http://www.adobe.com/go/getflashplayer"><img
			src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif"
			alt="Get Adobe Flash player" /></a></p>
	</div>
</body>
</html>
