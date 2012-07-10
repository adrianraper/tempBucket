<?php
session_start();
include_once("v1_ORS_Variables.php");
include_once "v1_ORS_libQuery.php"; 

	$userName = $password = $extraParam = $licenceFile = $prefix = $version = '';
	$StudentID = $Email = '';
	$referrer = $ip = $server = $productCode = '';
	
// For BC Global and Hong Kong auto
$rootID=14030;

$ename = $_GET['n'];
$emailat = $_GET['e'];
$encrypt = $_GET['d'];

$pattern = '/\(AT\)/';
$replacement = '@';
$email = preg_replace($pattern, $replacement, $emailat);
$pattern = '/\+/';
$replacement = ' ';
$ename = preg_replace($pattern, $replacement, $ename);

$pattern = '/ /';
$replacement = '+';
$encrypt = preg_replace($pattern, $replacement, $encrypt);

$passwordStr = $ename."-&-".$email; 
$nowTime = date("D M j G:i:s T Y");
$stage = "1";
$logStr = ''; // initialise

// Don't do any kind of decryption if the strings are empty
if (strlen($ename)==0 || strlen($email)==0 || strlen($encrypt)==0) {
	$validLink = false;
	$logStr.=$nowTime." n=".$ename."&e=".$emailat."&d=".$encrypt."\r\n";
} else {
	// Do the decryption that is passed to you
	$fullDecrypt = decrypt3DES(buildPasswordHash($passwordStr), decodeCharacters($encrypt));
	//$fullDecrypt = decrypt3DES(buildPasswordHash($passwordStr), $encrypt);
	//echo $fullDecrypt;

	// See if the passed parameters match
	parse_str($fullDecrypt, $agre);
	//$calcEname = preg_replace($pattern, $replacement, $n);
	$calcEname = $agre['n'];
	$calcEmail = $agre['e'];
	//echo "passed name=".$ename." calc name=".$calcEname;
	if ($calcEmail==$email && $calcEname==$ename) {
		// they match, so pick up the other parameters and convert for Road to IELTS use.
		$id = $agre['i'];
		$examDateStr = $agre['t'];
		//$examDate = date_create($examDateStr);
		//$expiryDate = date_add($examDate,new DateInterval("P1M"));
		$examDate = strtotime($examDateStr);
		$expiryDate = mktime(0,0,0,date("m",$examDate),date("d",$examDate)+7,date("Y",$examDate));
		$expiryDateStr = date('Y-m-d', $expiryDate);
		$programVersion = $agre['m'];
		if ($programVersion=="Academic") {
			$programVersion="A";
			$productCode=12;
		} else {
			$programVersion="G";
			$productCode=13;
		}
		$city = $agre['tc'];
		$country = $agre['c'];
		// Set a couple of defaults
		$validLink = true;
		$stage = "1";
		$logStr .= "valid encryption string id=".$id." stage=".$stage." name=".$calcEname." examDate=".$examDateStr." expiryDate=".$expiryDateStr." programVersion=".$programVersion." email=".$email."\r\n";
		
		//=========Get user registration date========
		$method = "getRegDate";
		$buildXML = '<query method="'.$method.'" studentID="'.$id.'" dbHost="100"/>';
		// AR This is too much encoding for our common XMLQuery.php
		//$postXML = urlencode($buildXML);
		$postXML = $buildXML;
		sendAndLoad($postXML, $contents);
	
		// Put the contents into an XML object and see what it says.
		$xml = simplexml_load_string($contents);
		$parser=xml_parser_create();
	
		//Specify element handler
		xml_set_element_handler($parser,"start","stop");
		
		// Create classes to hold the result of the parsing
		$userInfo=array();
		$errorInfo=array();
		
		// Parse the XML string - but this doesn't actually create anything.
		xml_parse($parser,$contents);
		//Free the XML parser
		xml_parser_free($parser);		

		$userID=0;
		$regTime = time();
		// First - was an error returned?
		if (isset($errorInfo['CODE'])) {
			$errorCode = intval($errorInfo['CODE']);
		} else {
			$errorCode = 0;
		}
		switch($errorCode) {
			// This query simply returns a registration date and a userID matched on this studentID
			// It doesn't do any password or expiry date checking
			case 206:
			case 203:
			case 210:
				break;
			case 204:
				$failReason = "Wrong password";
				break;
			case 208:
				$failReason = "User expired";
				break;
			case 0;
				// If no error, then get user information
				if (isset($userInfo['USERID'])) {
					$userID = $userInfo['USERID'];
					$regDate = $userInfo['REGDATE'];
					$regTime = strtotime($regDate);
					$logStr .= "got userID $userID with regDate $regDate\r\n";
				} else {
					$logStr .= "getRegDate error $errorCode\r\n";
					$errorCode = 1;
					$failReason = "Unknown reason";
				}
				break;
			default:
				$failReason = "Unknown reason";
		}
		
		// Extend into 2012
		if($regTime >= $STAGETHREETIME4){
			$stage = "2";
		} else if( $regTime >= $STAGETWOTIME4 && $regTime < $STAGETHREETIME4){
			$stage = "1";
		} else if( $regTime >= $STAGEONETIME4 && $regTime < $STAGETWOTIME4){
			$stage = "3";
		} else if( $regTime >= $STAGETHREETIME3 && $regTime < $STAGEONETIME4){
			$stage = "2";
		} else if( $regTime >= $STAGETWOTIME3 && $regTime < $STAGETHREETIME3){
			$stage = "1";
		} else if( $regTime >= $STAGEONETIME3 && $regTime < $STAGETWOTIME3){
			$stage = "3";
		} else if( $regTime >= $STAGEFOURTIME2 && $regTime < $STAGEONETIME3){
			$stage = "2";
		} else if( $regTime >= $STAGETHREETIME2 && $regTime < $STAGEFOURTIME2){
			$stage = "1";
		} else if( $regTime >= $STAGETWOTIME2 && $regTime < $STAGETHREETIME2){
			$stage = "3";
		} else if( $regTime >= $STAGEONETIME2 && $regTime < $STAGETWOTIME2){
			$stage = "2";
		} else if( $regTime >= $STAGEFOURTIME && $regTime < $STAGEONETIME2){
			$stage = "1";
		} else if( $regTime >= $STAGETHREETIME && $regTime < $STAGEFOURTIME){
			$stage = "3";
		} else if( $regTime >= $STAGETWOTIME && $regTime < $STAGETHREETIME){
			$stage = "2";
		} else {
			$stage = "1";
		}
		// Set the name of the location file based on the stage/cycle
		//$locationFile = 'location-'.$programVersion.$stage.'.txt';
		$locationFile = 'location-'.$stage.'.txt';
		//=========End of get===================
		
	} else {
		$validLink = false;
		$logStr .= "invalid encryption string name=$ename calcName=$calcEname email=$email calcEmail=$calcEmail at $nowTime\r\n";
	}
}
if ($errorLog) {
	if (!$validLink || $errorCode>0) {
		error_log($logStr, 3, $errorLogFile);
	}
}
if ($debugLog) {
	error_log($logStr, 3, $debugLogFile);
}

function buildPasswordHash($str) {
	$pass0sha1 = sha1($str, true); // get 20 digit hash
	$password = base64_encode($pass0sha1); // nFXx CBo/ xe00 3MNw QbXK UwLf ECU= // This is 28 characters
	return sha1($password, true);
}
function encrypt3DES($key, $text){
	$iv_size = mcrypt_get_iv_size(MCRYPT_3DES, MCRYPT_MODE_ECB);
	$iv = mcrypt_create_iv($iv_size, MCRYPT_RAND);
	$encrypt = mcrypt_encrypt(MCRYPT_3DES, $key, $text, MCRYPT_MODE_ECB, $iv);
	$encrypt = trim(base64_encode($encrypt));
	return $encrypt;
}
function decrypt3DES($key, $text){
	$iv_size = mcrypt_get_iv_size(MCRYPT_3DES, MCRYPT_MODE_ECB);
	$iv = mcrypt_create_iv($iv_size, MCRYPT_RAND);
	$text =base64_decode($text);
	$encrypt = mcrypt_decrypt(MCRYPT_3DES, $key, $text, MCRYPT_MODE_ECB, $iv);
	$encrypt = trim($encrypt);
	return $encrypt;
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
	<title>Road to IELTS from Clarity and the British Council</title>
	<link rel="shortcut icon" href="<?php echo $commonDomain; ?>Software/RoadToIELTS.ico" type="image/x-icon">
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="language" content="en" />
	<meta name="description" content="" />
	<meta name="keywords" content="" />

	<script type="text/javascript" language="JavaScript" src="<?php echo $commonDomain; ?>Software/Common/swfobject2.js"></script>
	<script type="text/javascript" language="JavaScript" src="<?php echo $commonDomain; ?>Software/Common/openwin.js"></script>
	<script type="text/javascript">
		// ****
		// Change this variable along with the above fixed paths
		var webShare = "<?php echo $commonDomain; ?>";
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
		
		var startControl = webShare + "Software/Common/";
		var coordsWidth = 760; var coordsHeight = 640;
		var sections = location.pathname.split("/");
		// Special case because the udp is on a different domain than the swf, and we store the location files on that server too
		// in fact we point to a different folder on the other server, use variables
		//var userdatapath = sections.slice(0,sections.length-1).join("/");
		//var userdatapath = "<?php echo substr($commonDomain,0,-1); ?>" + sections.slice(0,sections.length-1).join("/");		
		var userdatapath = "<?php echo $commonDomain.$startFolder; ?>";
		var argList="?browser=true&userDataPath=" + userdatapath + "&location=<?php echo $locationFile ?>";
		//argList+="<?php if (file_exists(dirname(__FILE__).'/'.$licenceFile)) {echo '&licence='.$licenceFile;} ?>";
		argList+="&prefix=<?php echo $prefix ?>&productCode=<?php echo $productCode ?>";
		argList+="&action=autoRegister";

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
		if ("<?php echo $id ?>".length>0) {
			var jsStudentID = "<?php echo $id ?>";
		} else {
			var jsStudentID = swfobject.getQueryParamValue("studentID");
		}
		var flashvars = {
			username: jsUserName,
			password: jsPassword,
			studentID: jsStudentID,
			email: "<?php echo $email ?>",
			city: "<?php echo $city ?>",
			country: "<?php echo $country ?>",
			expiryDate: "<?php echo $expiryDate ?>",
			startingPoint: swfobject.getQueryParamValue("startingPoint"),
			course: swfobject.getQueryParamValue("course"),
			rootID: "<?php echo $rootID ?>",
			referrer: "<?php echo $referrer ?>",
			server: "<?php echo $server ?>",
			ip: "<?php echo $ip ?>"
		};
		//var flashvars = {};
		var params = {
			id: "orchid",
			name: "orchid",
			scale: "noScale"
		};
		var attr = {
			id: "orchid",
			name: "orchid"
		};
		var expressInstall = startControl + "expressInstall.swf";
		swfobject.embedSWF(startControl + "control.swf" + argList, "altContent", coordsWidth, coordsHeight, "9.0.28", expressInstall, flashvars, params, attr);
	</script>

<!--CSS pop up layout box-->
<link rel="stylesheet" type="text/css" href="../css/loadprogram.css" />

</head>
<body onload="onLoad()">

<?php if ($validLink): ?> 
	<div align="center" id="altContent">
		<p>This application requires Adobe's Flash player, running at least version 9.</p>
		<p>It seems your browser doesn't have this.</p>
		<p>Please download the latest Adobe Flash Player.</p>
		<p><a href="http://www.adobe.com/go/getflashplayer"><img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" border="0"/></a></p>
		<p>If you still get this message, then your browser is stopping the scripts on this page from running.</p>
	</div>
<NOSCRIPT>
This application requires your browser to support javascript and to have Adobe's Flash player installed. <br>
Your browser does not support scripting at the moment. If you are allowed, please use Internet Options from the menu<br>
to switch this on and then refresh this page.</NOSCRIPT>
<?php endif ?>
<?php if ($validLink==false): ?> 
<div id="invalidLink">
	<br>
	This application can only be run from a NEAA or British Council website. <br>
	<a href="http://ielts.etest.net.cn" alt="Register for IELTS">Please log in at the NEEA website</a>.<br/>
	<a href="http://ielts.etest.net.cn" alt="Register for IELTS">Please log in at the NEEA website</a>.
</div>
<br></br><?php echo $encrypt; ?>
<br></br><?php echo $fullDecrypt; ?>
<?php endif ?>
</BODY>
</HTML>
