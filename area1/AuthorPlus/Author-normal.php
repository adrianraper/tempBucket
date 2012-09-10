<?php
	//require_once('../../englishonline/productClass.php');
	session_start();
	$userName = $password = $extraParam = $licenceFile = $prefix = $version = $preview = '';
	$studentID = $Email = $userID = $instanceID = '';
	$referrer = $ip = $server = $productCode = '';
	
	// For this product
	$productCode = 1; // Author Plus
	
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
	
	// v6.5.5.6 For default accounts you no longer need to pass version as this is all read from the database
	// Different language versions share the same location file as &content is now a root and the languageCode from T_Accounts is used as the literals
	// You can still override this if you want in a specific location file
	// The language version might come from session variables or from the URL parameters
	/*
	if (isset($_SESSION['AuthorPlus'])) {
		$version = $_SESSION['AuthorPlus']->languageCode;
	} elseif (isset($_GET['version'])){
		$version = $_GET['version'];
	} elseif (isset($_GET['Version'])){
		$version = $_GET['Version'];
	} else {
		$version="";
	}
	switch ($version) {
		case "NAMEN":
			$locationFile = "location-NAmEN.txt";
			break;
		case "INDEN":
			$locationFile = "location-IndEN.txt";
			break;
		default:
			$locationFile = "location.txt";
	}
	//echo "&version=".$version."&location=".$locationFile;
	*/
	// But Author Plus overrides the above. I don't think it should due to complexity of session variables.
	// We will pass content to the control.swf instead.
	//$locationFile = "location.php";
	// Author Plus will use a dynamic location file to pick up content, which must be set here
	// So, if the content is already set as a session variable, just leave it alone
	$locationFile = "location-Author.txt";
	/*
	// The content path is relative to /area1/AuthorPlus
	$content = "../";
	if (isset($_SESSION['content'])) {
		$content .= $_SESSION['content'];
	// Or if we are passing a parameter, use that
	} else if (isset($_GET['content'])) {
		$content .= $_GET['content'];
	} else if (isset($_GET['Content'])) {
		$content .= $_GET['Content'];
	// Otherwise use the prefix that we have just figured out
	} else {
		$content .= "../ap/".$prefix;
	}
	*/
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
	// v6.5.5.6 Here are extra values that need to be picked up by PHP rather than swfobject.
	// Don't really understand why. Ah, it seems to be that swfobject doesn't like underscore in the parameter name
	//if (isset($_GET['s_preview'])) 
	//	$preview = $_GET['s_preview'];

	//echo "prefix=".$prefix."+udp=".$userdatapath."+content=".$content."+language=".$language."<br/>";
	if (isset($_SESSION['UserID'])) $userID = $_SESSION['UserID'];
	if (isset($_SESSION['UserName'])) $userName = $_SESSION['UserName']; 
	if (isset($_SESSION['Password'])) $password = $_SESSION['Password'];
	if (isset($_SESSION['StudentID'])) $studentID = $_SESSION['StudentID'];
	if (isset($_SESSION['Email'])) $Email = $_SESSION['Email'];
	if (isset($_SESSION['InstanceID'])) $instanceID = $_SESSION['InstanceID'];
	
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
	// Specifically send a licence file for this customer and override the location
	//$licenceFile = '&licence='.$prefix.'_licence.txt';
	//$licenceFile = '&licence=licence.txt';
	//$locationFile = 'location-SQLServer.txt';
	
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>Author Plus from Clarity</title>
	<link rel="shortcut icon" href="/Software/APT.ico" type="image/x-icon" />
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
			thisMovie("ap").focus();
		}
		// *********
		// *********
		var startControl = webShare + "/Software/AuthorPlusPro/";
		var coordsWidth = 760; var coordsHeight = 640;
		// You may have come via a mod_rewrite in which case the javascript.location will not be the rewrite destination
		if ("<?php echo $userdatapath ?>".length>0) {
			var userdatapath = "<?php echo $userdatapath ?>";
		} else {
			var sections = location.pathname.split("/");
			var userdatapath = sections.slice(0,sections.length-1).join("/");
		}
		var argList="?browser=true&userDataPath=" + userdatapath + "&location=<?php echo $locationFile ?>";
		argList+="<?php if (file_exists(dirname(__FILE__).'/'.$licenceFile)) {echo '&licence='.$licenceFile;} ?>";
		argList+="&prefix=<?php echo $prefix ?>&productCode=<?php echo $productCode ?>";
		argList+="<?php if (isset($language)) {echo '&language='.$language.'*';} ?>";
		argList+="<?php if (isset($content)) {echo '&content='.$content;} ?>";
		//argList+="&dbHost=2";
		
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
		if ("<?php echo $courseFile ?>".length>0) {
			var jscourseFile = "<?php echo $courseFile ?>";
		} else {
			var jscourseFile = swfobject.getQueryParamValue("courseFile");
		}
		if ("<?php echo $preview ?>".length>0) {
			var jsPreview = "<?php echo $preview ?>";
		} else {
			var jsPreview = swfobject.getQueryParamValue("preview");
		}
		var queryStringCourseID = swfobject.getQueryParamValue("courseid");
		var queryStringStartingPoint = swfobject.getQueryParamValue("exerciseid");
		// the rest can come from other kinds of integration
		if (queryStringCourseID == "") {
			queryStringCourseID = swfobject.getQueryParamValue("course");
		}
		if (queryStringStartingPoint == "") {
			queryStringStartingPoint = swfobject.getQueryParamValue("startingPoint");
		}
		var flashvars = {
			username: jsUserName,
			password: jsPassword,
			studentID: jsStudentID,
			userID: jsUserID,
			email: jsEmail,
			instanceID: jsInstanceID,
			startingPoint: queryStringStartingPoint,
			course: queryStringCourseID,
			courseFile: jscourseFile,
			action: swfobject.getQueryParamValue("action"),
			referrer: "<?php echo $referrer ?>",
			server: "<?php echo $server ?>",
			ip: "<?php echo $ip ?>"
		};
		if (jsPreview=="true") {
			flashvars.preview = "true";
		}
		var params = {
			id: "ap",
			name: "ap",
			scale: "noScale"
		};
		var attr = {
			id: "ap",
			name: "ap"
		};
		var expressInstall = "/Software/Common/expressInstall.swf";
		swfobject.embedSWF(startControl + "APControl.swf" + argList, "altContent", coordsWidth, coordsHeight, "9.0.0", expressInstall, flashvars, params, attr);

		var flashvars2 = {
			allowScriptAccess: "sameDomain"
		};
		var params2 = {
			id: "cfh",
			name: "cfh",
			scale: "noScale"
		};
		var attr2 = {
			id: "cfh",
			name: "cfh"
		};
		swfobject.embedSWF(startControl + "Software/closeFormHandler.swf", "closeFormHandler", "10", "10", "9.0.0", null, flashvars2, params2, attr2);
</script>
	
<style type="text/css">
html, body {
	margin: 0px 0px auto;
	text-align:center;
	height: 100%;
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
	<div id="closeFormHandler" />
<NOSCRIPT>
This application requires your browser to support javascript and to have Adobe's Flash player installed. <br>
Your browser does not support scripting at the moment. If you are allowed, please use Internet Options from the menu<br>
to switch this on and then refresh this page.</NOSCRIPT>
</body>
</html>
