<?php
if (session_id() == '') session_start();
require_once("../../ItsYourJob/Variables.php");
require_once("../../ItsYourJob/libQuery.php");

$testingPortalLogin = $_GET['testing'];
if ($testingPortalLogin) {
	$_SESSION['UserID'] = 27639;
	$_SESSION['Email'] = 'dandy@email';
	$_SESSION['UserName'] = 'dandelion';
	$_SESSION['StudentID'] = 'dandelion123';
	$_SESSION['Password'] = 'password';
	$_SESSION['PREFIX'] = 'Clarity';
}

if (!isset($_SESSION['PREFIX']))
	$_SESSION['PREFIX'] = ($_POST['prefix'] == "") ? $_GET['prefix'] : $_POST['prefix'];

if (isset($_GET['startingPoint'])){ // direct start parameter
	//$startingPoint = ($_GET['startingPoint']=="") ? $_GET["course"] : $_GET["startingPoint"];
	$tmps = explode("ex:", $_GET['startingPoint']);
	if($tmps[1] != null){
		$startingPoint = $tmps[1];
	}else{
		$tmps = explode("unit:", $_GET['startingPoint']);
		$startingPoint = $tmps[1];
	}
} else {
	$startingPoint = $_GET["course"];
}
$_SESSION['SCORM'] = $_GET['scorm'] ? $_GET['scorm'] : "";
$_SESSION['SID'] = $_GET['sid'] ? $_GET['sid'] : ""; // studentID
$_SESSION['PRACTICEID'] = $_GET['practice'] ? $_GET['practice'] : "";
//$domain = "http://".$_SERVER['HTTP_HOST'];
$userInfo=array();
$errorInfo=array();
$noteInfo=array();
$accountInfo=array();
$licenceInfo=array();
// gh#1241
$settingsInfo=array();

function getRMSetting($prefix){
	global $userInfo, $errorInfo, $noteInfo, $accountInfo, $failReason, $licenceInfo, $demoversion, $settingsInfo;
	$buildXML = '<query method="getRMSettings" prefix="'.$prefix.'" dateStamp="'.date("Y-m-d H:i:s").'" cacheVersion="'.time().
                     '" zone="'.date_default_timezone_get().'" productcode="1001" dbHost="2"/>';
	sendAndLoad($buildXML, $responseXML, "progress");
	if (defined("DEBUG"))
		error_log(trim($responseXML,"\r\n")."\r\n", 3, "../../Debug/debug_iyj.log");		
	$xml = simplexml_load_string($responseXML);
	$parser = xml_parser_create();
	xml_set_element_handler($parser,"start","stop");
	xml_parse($parser,$responseXML);
	xml_parser_free($parser);

    if (isset($_SESSION['FAILREASON']))
        unset($_SESSION['FAILREASON']);
		
	$errorCode = $errorInfo['CODE'];
	switch ($errorCode) {
		case '100':
		case '101':
		case '207':
		case '212':
		case '213':
		case '214':
			$_SESSION['FAILREASON'] = $errorCode;
			break;
		default:
			if (defined("DEBUG"))
				error_log('settingsInfo(loginOption)='.$settingsInfo['LOGINOPTION']."\r\n", 3, "../../Debug/debug_iyj.log");
	        $_SESSION['LANGUAGECODE'] = $accountInfo['LANGUAGECODE'];
			$_SESSION['ROOTID'] = $accountInfo['ROOTID'];
			$_SESSION['MAXSTUDENTS'] = $accountInfo['MAXSTUDENTS'];
			$_SESSION['GROUPID'] = $accountInfo['GROUPID'];
			$_SESSION['LICENCESTARTDATE'] = $accountInfo['LICENCESTARTDATE'];
			$_SESSION['LICENCETYPE'] = $accountInfo['LICENCETYPE'];
			$_SESSION['IPRANGE'] = $licenceInfo['IPRANGE'];
			$_SESSION['RURANGE'] = $licenceInfo['RURANGE'];
			// gh#1241 Content path from database
			$_SESSION['CONTENTLOCATION'] = $licenceInfo['CONTENTLOCATION'];
			// gh#1241 Login option from database
			$_SESSION['LOGINOPTION'] = $settingsInfo['LOGINOPTION'];
	}

	if ($accountInfo['ROOTID'] > 0){
		$rangeChecked = true;
		$ipChecked = true;
		// Add judgement of ip or referr limit
		if(isset($_SESSION['IPRANGE'])){
			// If account has ip range attribute
			$ipChecked = false;
			// For Akamai served files- a special header is attached.
			// Check the Akamai configuration to see which files this works for.
			/*
			if (isset($_SERVER['HTTP_TRUE_CLIENT_IP'])) {
				$clientIp=$_SERVER['HTTP_TRUE_CLIENT_IP'];
			} elseif (isset($_SERVER["HTTP_CLIENT_IP"])) {
				$clientIp = $_SERVER["HTTP_CLIENT_IP"];
			} else {
				$clientIp = $_SERVER["REMOTE_ADDR"];
			}
			*/
			
			// v6.5.6 Add support for HTTP_X_FORWARDED_FOR
			if (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
				// This might show a list of IPs. Assume/hope that EZProxy puts itself at the head of the list.
				//$ipList = explode(',',$_SERVER['HTTP_X_FORWARDED_FOR']);
				//$ip = $ipList[0];
				$clientIp=$_SERVER['HTTP_X_FORWARDED_FOR'];
			} elseif (isset($_SERVER['HTTP_TRUE_CLIENT_IP'])) {
				$clientIp=$_SERVER['HTTP_TRUE_CLIENT_IP'];
			} elseif (isset($_SERVER["HTTP_CLIENT_IP"])) {
				$clientIp = $_SERVER["HTTP_CLIENT_IP"];
			} else {
				$clientIp = $_SERVER["REMOTE_ADDR"];
			}
			 
			// Start ip range checking
			error_log("ItsYourJob checking ip $clientIp, allowed ip address is ".$_SESSION['IPRANGE'], 3, "../../Debug/debug_iyj.log");
			$targetIP = explode(",", $_SESSION['IPRANGE']);
			foreach($targetIP as $ip){
				if($clientIp == $ip){
					$ipChecked = true;
					break;
				}
		
				$targetBlocks = explode(".", $ip);
				$thisBlocks = explode(".", $clientIp);
				for($i=0;$i<count($thisBlocks);$i++){
					if($targetBlocks[$i]==$thisBlocks[$i]){
		
					} else if (stripos($targetBlocks[$i], "-") > 0){
						$target  = explode("-", $targetBlocks[$i]);
						$targetStart = (int) $target[0];
						$targetEnd = (int) $target[1];
						$thisDetail = (int) $thisBlocks[$i];
						if($targetStart <= $thisDetail && $thisDetail <= $targetEnd){
							$ipChecked = true;
							break;
						}
					} else {
						break;
					}
				}
			}
		}
		 
		if(isset($_SESSION['RURANGE'])){
			// If account has referr range attribute
			$rangeChecked = false;
			// it is dangerous to send the whole referrer as you might get confused with parameters (specifically content)
			if (isset($_SERVER['HTTP_REFERER'])) {
				if (strpos($_SERVER['HTTP_REFERER'],'?')) {
					$referrer=substr($_SERVER['HTTP_REFERER'],0,strpos($_SERVER['HTTP_REFERER'],'?'));
				} else {
					$referrer = $_SERVER['HTTP_REFERER'];
				}
			}
			 
			// Start referrer range checking
			error_log("ItsYourJob checking referrer $referrer, allowed referrer is ".$_SESSION['RURANGE'], 3, "../../Debug/debug_iyj.log");
			$targetRange = explode(",", $_SESSION['RURANGE']);
			foreach($targetRange as $range){
				if(strtolower($referrer) == strtolower($range)){
					$rangeChecked = true;
					break;
				}
				if(strpos(strtolower($referrer), strtolower($range))){
					$rangeChecked = true;
					break;
				}
			}
		}
		
		if(!$ipChecked && !$rangeChecked){
			$_SESSION['FAILURE'] = "true";
			$_SESSION['FAILREASON'] = '250';
			return false;
		} else {
			return true;
		}
	} else {
		return false;
	}
}

if (!empty($_SESSION['PREFIX'])){
	// gh#1241 You might be returning to this screen after checking login and finding a mistake.
	// If so, don't go off and do getRMSettings again as this clears errors
	if (!isset($_SESSION['FAILURE']) || $_SESSION['FAILURE'] == false) {
		if (getRMSetting($_SESSION['PREFIX']) == true) {
			if (isset($_SESSION['FAILREASON']))
				unset($_SESSION['FAILREASON']);
			if (isset($_SESSION['FAILURE']))
				unset($_SESSION['FAILURE']);
			if ($startingPoint != "" && $startingPoint != null)
				$_SESSION['startingPoint'] = $startingPoint;
			if ($_SESSION['LICENCETYPE'] == "2"){
				//adding prefix to the all redirect url link, fix added by sky at 01/08/2013
				header("Location: ../../ItsYourJob/login.php?prefix=".$_SESSION['PREFIX']);
			}
			// gh#1241 See if clarityenglish.com has already set session variables for the user
			if (isset($_SESSION['UserID'])) {
				error_log("I got a userID in session, so jump ahead with username=".$_SESSION['UserName']."\r\n", 3, "../../Debug/debug_iyj.log");
			
				$_POST['submit'] = "Start";
				header("Location: ../../ItsYourJob/login.php?prefix=".$_SESSION['PREFIX']);
				
			} else if (isset($_GET['username']) && ($_SESSION['LOGINOPTION'] == 1)){
				$_SESSION['id'] = $_GET['username'];
				$_SESSION['UserName'] = $_GET['username'];
				if (isset($_GET['password'])) {
					$_SESSION['PASSWORD'] = $_GET['password'];
					$_SESSION['Password'] = $_GET['password'];
					$_SESSION['pwd'] = $_GET['password'];
				}
				$_POST['submit'] = "Start";
				header("Location: ../../ItsYourJob/login.php?prefix=".$_SESSION['PREFIX']);
				
			} else if (isset($_GET['studentID']) && ($_SESSION['LOGINOPTION'] == 2)){
				$_SESSION['id'] = $_GET['studentID'];
				$_SESSION['StudentID'] = $_GET['studentID'];
				if (isset($_GET['password'])) {
					$_SESSION['PASSWORD'] = $_GET['password'];
					$_SESSION['Password'] = $_GET['password'];
					$_SESSION['pwd'] = $_GET['password'];
				}
				$_POST['submit'] = "Start";
				header("Location: ../../ItsYourJob/login.php?prefix=".$_SESSION['PREFIX']);
				
			} else if (isset($_GET['email'])){
				$_SESSION['id'] = $_GET['email'];
				$_SESSION['Email'] = $_GET['email'];
				if (isset($_GET['password'])) {
					$_SESSION['PASSWORD'] = $_GET['password'];
					$_SESSION['Password'] = $_GET['password'];
					$_SESSION['pwd'] = $_GET['password'];
				}
				$_POST['submit'] = "Start";
				header("Location: ../../ItsYourJob/login.php?prefix=".$_SESSION['PREFIX']);
			}
		} else {
			if (!isset($_SESSION['FAILURE'])) $_SESSION['FAILURE'] = "true";
			if (!isset($_SESSION['FAILREASON'])) $_SESSION['FAILREASON'] = "220";
		}
	}
}
if ($_SESSION['LOGINOPTION'] == 1) {
	$loginOptionFieldName = 'Name';
} else if ($_SESSION['LOGINOPTION'] == 2) {
	$loginOptionFieldName = 'ID';
} else {
	$loginOptionFieldName = 'Email';
}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="images/favicon.ico" type="image/x-icon" />
<title>Clarity English | It's Your Job | Home</title>

<!--CSS General-->
<link rel="stylesheet" type="text/css" href="css/job_general.css" />
<!--CSS Fancy pop up box-->
<link rel="stylesheet" type="text/css" href="css/fancybox.css" />

<script type="text/javascript">
<!-- hide from non JavaScript Browsers
Image1= new Image(956,130);
Image1.src = "images/bannar.jpg";

Image2= new Image(956,130);
Image2.src = "images/bannar_join.jpg";

Image3= new Image(956,130);
Image3.src = "images/bannar_choice.jpg";
	
Image4 = new Image(956,1);
Image4.src = "images/bannar_line.jpg";
	
Image5 = new Image(956,367);
Image5.src = "images/front_man_bg.jpg";

Image6 = new Image(81,24);
Image6.src = "images/btn_go.jpg";
//End Hiding -->
</script>
<!--General jquery library: For Fancy box, programs left menu-->
<script type="text/javascript" src="/Software/Common/jQuery/js/jquery-1.3.2.min.js"></script>
<script type="text/javascript" src="../../ItsYourJob/script/popup.js"></script>
<!--Fancy Popup Box-->
<script type="text/javascript" src="../../ItsYourJob/script/fancybox.js"></script>
<script type="text/javascript" src="../../ItsYourJob/script/fancybox_custom.js"></script>
<script type="text/javascript" src="../../ItsYourJob/libClient.js"></script>
<script type="text/javascript">
var username = "<?php echo ($_SESSION['USERNAME']=="" ? $_SESSION['id'] : $_SESSION['USERNAME']);?>";
var failure = "<?php echo $_SESSION['FAILURE'];?>";
var failReason = "<?php echo $_SESSION['FAILREASON'];?>";
var loginType = "<?php echo $_SESSION['LOGINTYPE'];?>";
var g_domain = "<?php echo $_SERVER['HTTP_HOST']; ?>";
var errmsg = new Array(
	    //'Name \"' + username + '\" is not in database, <br> please click \"NEW USER\" button.', //203
	    'This is the first time these details have been used. Please click New user to confirm.', //203
        'Sorry, these details or password are wrong, please try again.', // 204 and 206
        'Sorry, your account has expired.', //208
        'The licence can only run from a limited range of computers (IP address).' // 250
);
var accountErrorMsg = new Array(
		"Sorry, your account has expired. <br> Please contact your administrator for more information.", //207
		"Sorry, your account has not started yet. <br> Please contact your administrator for more information.", //212
		"Sorry, your account has not been activated yet. <br> Please contact your administrator for more information.", // 213
		"The licence has been altered or corrupted. <br> Please contact your administrator for more information.", //214
		"Sorry, we can't find this account. <br> Please check the URL you typed or ask your administrator." //other
		);
var licenceErrorMsg = new Array(
		"Sorry, the licence is full. <br> Please try again in a while once someone else has finished.", //201
		"Sorry, more than one student matches those details. Please ask your administrator for help." // 211
		);
</script>
</head>

<body>
<div id="container">
	<!--header area-->
	<div id="header_container">
    	<div id="bannar_before_login" class="ban_choice"></div>
        <div class="bannar_rainbow_line" id="welcome_line"></div>
    </div>
	<!--End of header area-->
    <!--Content Area-->
    <div id="home_container">
    	<div id="login_box">
       	  <h1>Please sign in.</h1>
       	  <form method="post" action="../../ItsYourJob/login.php" name="loginForm" id="loginForm">
       	    <div id="login_form">
                <div class="login_box_field">
                        <p class="login_title"><?php echo $loginOptionFieldName;?>:</p>
                        <input name="id" type="text" value="" class="login_field"/>
                        <div class="clear"></div>
                </div>
                   
                <div class="login_box_field">
                  <p class="login_title">Password:</p>
                      <input name="pwd" type="password" value="" class="login_field" />
                      <div class="clear"></div>
                </div>
            </div>
     
			<!-- gh#1241 I think this display section is redundant -->
	        <div id="login_welcome" style="display:none">
	            Welcome, <?php echo ($_SESSION['USERNAME']=="" ? $_SESSION['id'] : $_SESSION['USERNAME']) ?>.<br/>Click the Start button to begin your course.
	        </div> 
            <div id="login_btn_box">
              <input id="submitBtn" name="submitBtn" type="submit" value="Start" class="login_btn" />
              <input id="newBtn" name="submit" type="submit" value="New user" class="newuser_btn" style="display:none"/>
              <div id="errmsg" style="display:none;"></div>
            </div>
            </form>
        </div>
    </div>
	<!--End of Content Area-->
	<!--Footer area-->
	<div id="footer_container" style="position:relative; z-index:2">
   	   <!--<div style="width:332px; height:41px; background-color:#996600; position:absolute; top:-24px; right:50px; z-index:1; border:1px solid #000000">Pretty Sticker here!</div>-->
	   <?php include 'footer.php'; ?>
	</div>
  <!--End of Footer area-->
</div>
<!--End of Container-->
<script type="text/javascript">
document.loginForm.id.value = username;
if(failure=="true"){
    if(failReason == "201"){
    	document.getElementById('errmsg').innerHTML = licenceErrorMsg[0];
    }else if(failReason == "203"){
    	document.getElementById('errmsg').innerHTML = errmsg[0];
    	document.getElementById('newBtn').style.display = "block";
    }else if(failReason == "204" || failReason == "206"){
    	document.getElementById('errmsg').innerHTML = errmsg[1];
    }else if(failReason == "207"){
    	document.getElementById('errmsg').innerHTML = accountErrorMsg[0];
    }else if(failReason == "208"){
    	document.getElementById('errmsg').innerHTML = errmsg[2];
    }else if(failReason == "211"){
    	document.getElementById('errmsg').innerHTML = licenceErrorMsg[1];
    }else if(failReason == "212"){
    	document.getElementById('errmsg').innerHTML = accountErrorMsg[1];
    }else if(failReason == "213"){
    	document.getElementById('errmsg').innerHTML = accountErrorMsg[2];
    }else if(failReason == "214"){
    	document.getElementById('errmsg').innerHTML = accountErrorMsg[3];
    }else if(failReason == "250"){
    	document.getElementById('errmsg').innerHTML = errmsg[3];
    }else{
    	document.getElementById('errmsg').innerHTML = accountErrorMsg[4];
    }
    document.getElementById('errmsg').style.display = "block";
}else{
    document.getElementById('newBtn').style.display = "none";
}

if(username=="" || failure=="true"){
	document.getElementById('login_form').style.display = "block";
    document.getElementById('login_welcome').style.display = "none";
	// gh#1241 This destroys the very information we want in the session
    //cmdRequest("../../ItsYourJob/logout.php", "GET", null, false);
}else{
    document.getElementById('login_form').style.display = "none";
    document.getElementById('login_welcome').style.display = "block";
}
</script>
</body>
</html>
