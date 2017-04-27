<?php
	
	/*
    // gh#1314
	if (isset($_GET['session'])) {
		session_id($_GET['session']);
	}
	session_start();
	$currentSessionID = session_id();
	
	$userName = $password = $extraParam = $licenceFile = $prefix = $version = '';
	$studentID = $Email = $userID = $instanceID = '';
	$referrer = $ip = $server = $productCode = '';
	*/
    // Initialisation
	require_once '../startInit.php';
	
	// Picking up passed data
	require_once '../readPassedVariables.php';
	
	// For this product
	$productCode = 50; // Clear Pronunciation 2
	
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
		//404 is not a suitable error message when sessions vars times out
		//header("location: /error/404_programs.htm");
		$logStr = "from Start page Time=".date("D M j G:i:s T Y").", HTTP_HOST=".$_SERVER['HTTP_HOST'].", HTTP_X_FORWARDED_FOR=".$_SERVER['HTTP_X_FORWARDED_FOR'].", HTTP_CLIENT_IP=".$_SERVER["HTTP_CLIENT_IP"].", REMOTE_ADDR=".$_SERVER["REMOTE_ADDR"].", pc=".$productCode;
		error_log("$logStr\r\n", 3, "/tmp/session_vars.log");
		header("location: /error/session_timeout.htm");
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
	if (isset($_SESSION['ClearPronunciation2'])) {
		$version = $_SESSION['ClearPronunciation2']->languageCode;
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
	// If you want to allow special behaviour for one account
	if ($prefix == 'CSTDI') {
		$courseFile = 'course-CSTDI.xml';
		if (isset($_SESSION['referrer'])) {
			$referrer = $_SESSION['referrer'];
			//echo "referrer is session set as $referrer";
		}
	} else {
		$courseFile = 'course.xml';
	}
	$locationFile = "location.txt";
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
		$ipList = explode(',',$_SERVER['HTTP_X_FORWARDED_FOR']);
		$ip = $ipList[0];
	} elseif (isset($_SERVER['HTTP_TRUE_CLIENT_IP'])) {
		$ip=$_SERVER['HTTP_TRUE_CLIENT_IP'];
	} elseif (isset($_SERVER["HTTP_CLIENT_IP"])) {
		$ip = $_SERVER["HTTP_CLIENT_IP"];
	} else {
		$ip = $_SERVER["REMOTE_ADDR"];
	}
	// it is dangerous to send the whole referrer as you might get confused with parameters (specifically content)
	if ($referrer=='' && isset($_SERVER['HTTP_REFERER'])) {
		if (strpos($_SERVER['HTTP_REFERER'],'?')) {
			$referrer=substr($_SERVER['HTTP_REFERER'],0,strpos($_SERVER['HTTP_REFERER'],'?'));
		} else {
			$referrer = $_SERVER['HTTP_REFERER'];
		}
	}
?>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
	<title>Clear Pronunciation 2: Speech</title>
	<link rel="shortcut icon" href="/Software/CP2.ico" type="image/x-icon" />
    <meta name="robots" content="noindex">
    <meta name="Description" content="ClearPronunciation Speech from ClarityEnglish">
    <meta name="keywords" content="ESP, Pronunciation, ClarityEnglish">
    <!-- Bootstrap -->
    <link href="https://www.clarityenglish.com/bootstrap/css/bootstrap.min.css" rel="stylesheet">
    <!-- <link href="/bootstrap/css/mobile-max767.css" rel="stylesheet"> -->
    <!-- <link href="/bootstrap/css/tablet-768-1199.css" rel="stylesheet"> -->
    <link rel="stylesheet" type="text/css" href="../../css/loadprogram.css" />

    <!---Font style--->
     <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,300i,400,400i,600,600i,700,700i,800,800i" rel="stylesheet">
    
     <!---Google Analytics Tracking--->
	<script>
      (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
      (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
      m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
      })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');
    
      ga('create', 'UA-873320-20', 'auto');
      ga('send', 'pageview');
	  ga('send', 'event', {eventCategory: 'Error', eventAction: '404', eventLabel:'sky_source_page: ' + document.location.href + ' page: ' + document.location.pathname + document.location.search + ' ref: ' + document.referrer });
	  
      <!---_gaq.push(['_trackEvent', 'Error', '404', 'sky_source_page: ' + document.location.href + ' page: ' + document.location.pathname + document.location.search + ' ref: ' + document.referrer]);--->
	 (function() {
		var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
		ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
		var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
	  })();
	  
    </script>
    
  </head>
   <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="https://www.clarityenglish.com/bootstrap/js/bootstrap.min.js"></script>

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
		argList+="<?php if (file_exists(dirname(__FILE__).'/'.$licenceFile)) {echo '&licence='.$licenceFile;} ?>";
		argList+="&prefix=<?php echo $prefix ?>&productCode=<?php echo $productCode ?>";
		argList+="&cache=<?php echo time() ?>";
		
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
			courseFile: "<?php echo $courseFile ?>",
			referrer: "<?php echo $referrer ?>",
			server: "<?php echo $server ?>",
			ip: "<?php echo $ip ?>"
		};
		var params = {
			id: "orchid",
			name: "orchid",
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
		swfobject.embedSWF(startControl + "control.swf" + argList, "altContent", coordsWidth, coordsHeight, "9.0.28", expressInstall, flashvars, params, attr);
	</script>
<body onload="onLoad()">
    <div id="altContent"> 
        <nav class="navbar-default" id="main-nav">
            <div class="navbar-header">
              <a class="navbar-brand" href="/" onClick="ga('send', 'event', 'header', 'logo', 'click-home',0,{nonInteraction: true});"><img src="https://www.clarityenglish.com/images/logo_clarityenglish.png" width="132" height="24"/></a>
            </div>
        </nav>
        <div class="jumbotron error-jumbotron text-left">
            <p class="error-text-1">Blocked Flash Player</p>
            <p class="error-general-txt">This application needs Flash Player, and your browser is blocking it or doesn't have it.</p>
            <p class="error-general-txt">Please allow it to run, the following links show how to change your browser settings:</p>
            <ul class="error-general-txt">
            <li><a href="https://support.google.com/chrome/answer/3123708" target="_blank">Chrome settings</a></p> 
            <li><a href="https://helpx.adobe.com/flash-player/kb/enabling-flash-player-firefox.html" target="_blank">Firefox settings</a></p> 
            <li><a href="http://osxdaily.com/2013/12/18/enable-flash-plugin-specific-websites-safari-mac/" target="_blank">Safari settings</a></p> 
            <li><a href="https://helpx.adobe.com/flash-player/kb/flash-player-issues-windows-10-edge.html" target="_blank">Edge settings</a></p> 
            <li><a href="https://helpx.adobe.com/flash-player/kb/install-flash-player-windows.html" target="_blank">Internet Explorer settings</a></p> 
            </ul>
            <p class="error-general-txt">Or email us &mdash; support@clarityenglish.com</p>
        </div>
    </div>
<NOSCRIPT>
This application requires your browser to support javascript and to have Adobe's Flash player installed. <br>
Your browser does not support scripting at the moment. If you are allowed, please use settings or options<br>
to switch this on and then refresh this page.</NOSCRIPT>
</body>
</html>