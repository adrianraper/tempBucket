<?php

	// New BCHK start page for links from AsiaPay portal.
	session_start();
	date_default_timezone_set('UTC');

	$name = $password = $extraParam = $licenceFile = $prefix = $version = '';
	$studentID = $email = $instanceID = $userID = '';
	$referrer = $ip = $server = $productCode = '';
	
	//$thisDomain = 'http://'.$_SERVER['HTTP_HOST'].'/';
	$thisDomain = 'http://dock.projectbench/';
	$commonDomain = 'http://dock.projectbench/';
	//$startFolder = "BritishCouncil/RoadToIELTS/";
	$configFile = 'config.xml';
	
	$swfName = 'IELTSApplication.swf';
	$webShare = '';
	$startControl = "$thisDomain$webShare/Software/ResultsManager/web/";
	
	$fileContents = file_get_contents($configFile);
	$configXML = simplexml_load_string($fileContents);
	$dbHost = (string) $configXML->dbHost[0];
	$prefix = (string) $configXML->prefix[0];
	$rootID = (string) $configXML->rootID[0];
	$groupID = (string) $configXML->groupID[0];
	$loginOption = (string) $configXML->loginOption[0];

	// Will we write out lots of log messages?
	$debugLog = true;
	$debugFile = 'BCHK-Start.log';

	// Decrypt the passed parameters	
	$name = $_GET['n'];
	$email = $_GET['e'];
	$encrypt = $_GET['d'];
	
	if ($debugLog) {
		error_log("starting BCHK-Start.php with $name", 3, $debugFile);
	}
	
	// Decrypt the passed parameters	
	$name = $_GET['n'];
	$email = $_GET['e'];
	$encrypt = $_GET['d'];
	
	$pattern = '/\(AT\)/';
	$replacement = '@';
	$email = preg_replace($pattern, $replacement, $email);
	$pattern = '/ /';
	$replacement = '+';
	$encrypt = preg_replace($pattern, $replacement, $encrypt);
	
	$passwordStr = $name."-&-".$email; 

	// Don't do any kind of decryption if the strings are empty
	if (strlen($name)==0 || strlen($email)==0 || strlen($encrypt)==0) {
		$validLink = false;
		//$logStr=$nowTime." n=".$ename."&e=".$emailat."&d=".$encrypt."\r\n";
	} else {
		// Do the decryption that is passed to you
		$fullDecrypt = decrypt3DES(buildPasswordHash($passwordStr), base64_decode(decodeCharacters($encrypt)));
		//echo $fullDecrypt;
	
		// See if the passed parameters match
		parse_str($fullDecrypt, $agre);
		//$calcEname = preg_replace($pattern, $replacement, $n);
		$calcName = $agre['n'];
		$calcEmail = $agre['e'];
		//echo "passed name=".$ename." calc name=".$calcEname;
		if ($calcEmail==$email && $calcName==$name) {
			// they match, so pick up the other parameters and convert for Road to IELTS use.
			$studentID = $agre['i'];
			$examDateStr = $agre['t'];
			// When PHP 5.3 running
			//$examDate = date_create($examDateStr);
			//$expiryDate = date_add($examDate,new DateInterval("P1M"));
			$examDate = strtotime($examDateStr);
			$expiryDate = mktime(0,0,0,date("m",$examDate),date("d",$examDate)+7,date("Y",$examDate));
			$expiryDateStr = date('Y-m-d 23:59:59', $expiryDate);
			$programVersion = $agre['m'];
			if ($programVersion=="Academic") {
				$productCode=52;
			} else {
				$productCode=53;
			}
			// Set a couple of defaults
			$validLink = true;
			
			// Whilst we are in transition mode, we need to check if this student ID already exists in old database. If yes, then need to pass
			// this URL directly through to the old system.
			$rootPath = dirname(__FILE__).'/../../';
			$dbPath= $rootPath.'Database/';
			$adodbPath= $rootPath.'Software/Common/';
			require_once($adodbPath."adodb5/adodb-exceptions.inc.php");
			require_once($adodbPath."adodb5/adodb.inc.php");
			require_once($dbPath."dbDetails.php");
			
			// make the database connection
			global $db;
			$oldDbHost = 101; // GlobalRoadToIELTS
			$dbDetails = new DBDetails($oldDbHost);
			$db = &ADONewConnection($dbDetails->dsn);
			if (!$db) die("Connection failed");
			//$db->debug = true;
			$ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;			
			$rs = $db->Execute("SELECT * FROM T_User WHERE F_StudentID=?",
									array($studentID));
			if ($rs && $rs->recordCount()>0) {
				$oldURL = $thisDomain."/BritishCouncil/HongKong/v1-BCHK-Start.php?".$_SERVER['QUERY_STRING'];
				header('Location: ' . $oldURL);
				exit;
			}
			
			// V2 We will be logging in using studentID as unique, but we don't really know that all BC centres will use unique
			// ids in the protal - so best to add the groupID to all studentIDs coming through this portal.
			$uniqueStudentID = $studentID.'-'.$groupID;
			
			// Use LoginGateway to get back this user, or add them with all their details
			$LoginAPI = array();
			$LoginAPI['method'] = 'getOrAddUser';
			$LoginAPI['studentID'] = $uniqueStudentID;
			$LoginAPI['name'] = $name;
			$LoginAPI['email'] = $email;
			$LoginAPI['dbHost'] = $dbHost;
			$LoginAPI['productCode'] = $productCode;
			$LoginAPI['expiryDate'] = $expiryDateStr;
			$LoginAPI['prefix'] = $prefix;
			$LoginAPI['rootID'] = $rootID;
			$LoginAPI['groupID'] = $groupID;
			$LoginAPI['loginOption'] = $loginOption;
	
			// Send this single LoginAPI
			$serializedObj = json_encode($LoginAPI);
			$targetURL = $commonDomain.'Software/ResultsManager/web/amfphp/services/LoginGateway.php';
			if ($debugLog) {
				error_log("to LoginGateway with $serializedObj", 3, $debugFile);
			}
			
			// Initialize the cURL session
			$ch = curl_init();
			
			// Setup the post variables
			$curlOptions = array(CURLOPT_HEADER => false,
								CURLOPT_FAILONERROR=>true,
								CURLOPT_FOLLOWLOCATION=>true,
								CURLOPT_RETURNTRANSFER => true,
								CURLOPT_POST => true,
								CURLOPT_POSTFIELDS => $serializedObj,
								CURLOPT_URL => $targetURL
			);
			curl_setopt_array($ch, $curlOptions);
			
			// Execute the cURL session
			$contents = curl_exec ($ch);
			if($contents === false){
				echo 'Curl error: ' . curl_error($ch);
				curl_close($ch);
			} else {
				curl_close($ch);
				// $contents is coming back with a utf-8 BOM in front of it, which invalidates it as JSON. Get rid of it.
				if (substr($contents,0,3)==b"\xEF\xBB\xBF") {
					$contents = substr($contents,3);
				}
				$returnInfo = json_decode($contents, true);

				if ($debugLog) {
					error_log("back from LoginGateway with $contents", 3, $debugFile);
				}

				// Expecting to get back an error or a user object
				if (isset($returnInfo['error'])){
					$errorCode = $returnInfo['error'];
					$errorMsg = $returnInfo['message'];
					//header( 'Location: '.$failurePage.'?'.$returnedInfo );
				} else {
					$errorCode = 0;
				}
				
			}
			
			switch($errorCode) {
				case '206':
				case '203':
				case '210':
					break;
				case '204':
					$failReason = "Wrong password";
					break;
				case '208':
					$failReason = "User expired";
					break;
				default:
					// If no error, then get user information
					if (isset($returnInfo['user'])) {
						$userID = $returnInfo['user']['userID'];
					} else {
						$errorCode = 1;
						$failReason = "Unknown reason";
					}
					break;
			}
			
		} else {
			$validLink = false;
			//$logStr = $nowTime." invalid name=".$ename." calcName=".$calcEname." email=".$email." calcEmail=".$calcEmail ."\r\n";
		}
	}
	//error_log($logStr, 3, "/tmp/Login.log");

function buildPasswordHash($str) {
	$pass0sha1 = sha1($str, true); // get 20 digit hash
	$password = base64_encode($pass0sha1); // nFXx CBo/ xe00 3MNw QbXK UwLf ECU= // This is 28 characters
	return sha1($password, true);
}
function encrypt3DES($key, $text){
	$td = mcrypt_module_open (MCRYPT_3DES, '', MCRYPT_MODE_CBC, '');
	$vector = mcrypt_encrypt(MCRYPT_3DES,$key,"\0\0\0\0\0\0\0\0",MCRYPT_MODE_ECB);
	mcrypt_generic_init ($td, $key, $vector);
	$encrypted = mcrypt_generic ($td, $text);
	mcrypt_generic_deinit($td);
	mcrypt_module_close($td);
	return $encrypted;
}
function decrypt3DES($key, $text){
	//$text = str_replace("\x0", "", $text);
	$td = mcrypt_module_open (MCRYPT_3DES, '', MCRYPT_MODE_CBC, '');
	$vector = mcrypt_encrypt(MCRYPT_3DES,$key,"\0\0\0\0\0\0\0\0",MCRYPT_MODE_ECB);
	mcrypt_generic_init ($td, $key, $vector);
	//$decrypted = rtrim(mdecrypt_generic ($td, $text),"\x0");
	$decrypted = mdecrypt_generic($td, $text);
	mcrypt_generic_deinit($td);
	mcrypt_module_close($td);
	return $decrypted;
}
function encodeCharacters ($rawText) {
	$pattern = '/\//';
	$replacement = '-';
	$temp = preg_replace($pattern, $replacement, $rawText);
	$pattern = '/=/';
	$replacement = '_';
	$temp = preg_replace($pattern, $replacement, $temp);
	return $temp;
}
function decodeCharacters ($rawText) {
	$pattern = '/-/';
	$replacement = '/';
	$temp = preg_replace($pattern, $replacement, $rawText);
	$pattern = '/_/';
	$replacement = '=';
	$temp = preg_replace($pattern, $replacement, $temp);
	return $temp;
}
?> 
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>Road to IELTS 2 from Clarity and the British Council</title>
	<link rel="shortcut icon" href="/Software/R2IV2.ico" type="image/x-icon" />
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="language" content="en" />
	<meta name="description" content="" />
	<meta name="keywords" content="" />

	<script type="text/javascript" language="JavaScript" src="/Software/Common/openwin.js"></script>
	<script type="text/javascript" language="JavaScript" src="/Software/Common/swfobject2.js"></script>
	<script type="text/javascript" language="JavaScript" src="/Software/Common/swffit.js"></script>
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
		
		function onLoad() {
			thisMovie("bento").focus();
		}
		// *********
		// *********
		var webShare = "<?php echo $webShare ?>";
		var startControl = "<?php echo $startControl ?>";
		var swfName = "<?php echo $swfName ?>";
		
		// v6.5.5.6 Allow resize screen mode
		var coordsWidth = "100%"; var coordsHeight = "100%"; 
		//var coordsWidth = "990"; var coordsHeight = "600"; 
		var coordsMinWidth = "990"; var coordsMaxWidth = "1200"; 
		var coordsMinHeight = "600"; var coordsMaxHeight = null;
		
		var sections = location.pathname.split("/");
		var userdatapath = sections.slice(0,sections.length-1).join("/");
		var argList="?browser=true&userDataPath=" + userdatapath + "&location=<?php echo $configFile ?>";
		argList+="&prefix=<?php echo $prefix ?>&productCode=<?php echo $productCode ?>";
		
		// see whether variables have come from command line or, preferentially, session variables
		if ("<?php echo $name ?>".length>0) {
			var jsUserName = "<?php echo $name ?>";
		} else {
			var jsUserName = swfobject.getQueryParamValue("username");
		}
		if ("<?php echo $password ?>".length>0) {
			var jsPassword = "<?php echo $password ?>";
		} else {
			var jsPassword = swfobject.getQueryParamValue("password");
		}
		if ("<?php echo $uniqueStudentID ?>".length>0) {
			var jsStudentID = "<?php echo $uniqueStudentID ?>";
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
			ip: "<?php echo $ip ?>"
		};
		var params = {
			id: "bento",
			name: "bento",
			quality: "high",
			allowfullscreen: "true",			
			salign: "tc",
			scale: "noscale"
		};
		var attr = {
			align: "middle",
			id: "bento",
			name: "bento"
		};
		var expressInstall = startControl + "expressInstall.swf";
		swfobject.embedSWF(startControl + swfName + argList, "bento", coordsWidth, coordsHeight, "10.2.0", expressInstall, flashvars, params, attr);
		swffit.fit('bento', coordsMinWidth, coordsMinHeight, coordsMaxWidth, coordsMaxHeight);
	</script>
</head>
<body onload="onLoad()">
<?php if ($validLink): ?> 
	<div style="text-align:center" id="bento">
		<p>This application requires Adobe's Flash player, running at least version 9.</p>
		<p>It seems your browser doesn't have this.</p>
		<p>Please download the latest Adobe Flash Player.</p>
		<p><a href="http://www.adobe.com/go/getflashplayer"><img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" border="0"/></a></p>
		<p>If you still get this message, then your browser is stopping the scripts on this page from running.</p>
	</div>
<noscript>
This application requires your browser to support javascript and to have Adobe's Flash player installed. <br/>
Your browser does not support scripting at the moment. If you are allowed, please use Internet Options from the menu<br/>
to switch this on and then refresh this page.</noscript>
<?php endif ?>
<?php if ($validLink==false): ?> 
<div id="invalidLink">
	This application can only be run from a <a href="http://www.britishcouncil.org">British Council website</a>.
</div>
<br/><?php echo $encrypt; ?>
<br/>
<?php endif ?>
</body>
</html>
