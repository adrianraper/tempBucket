<?php
session_start();
date_default_timezone_set('UTC');
require_once("Variables.php");
require_once("libQuery.php");
$userInfo=array();
$errorInfo=array();
$noteInfo=array();
$accountInfo=array();
$licenceInfo=array();

function checkUser($email, $password){
	global $userInfo, $errorInfo, $noteInfo, $failReason, $demoversion;
    $instanceID = time();
	if( $email=="iyjguest"
		|| isset($_SESSION['PREFIX'])
		|| $_SESSION['LOGINTYPE'] == "school"
		|| $_SERVER['HTTP_HOST'] == "www.clarityenglish.com" ){
    // Using user name to login
		$buildXML = '<query method="emugetuser" '.
					'name="'.$email.
					'" password="'.$password.
		            '" instanceID="'.$instanceID.
					'" courseid="1001" productcode="1001'.
					'" loginOption="1" dbHost="2" databaseVersion="4" />';
	}else{
	// Using email address to login
		$buildXML = '<query method="emugetuser" '.
					'email="'.$email.
					'" password="'.$password.
		            '" instanceID="'.$instanceID.
					'" courseid="1001" productcode="1001'.
					'" loginOption="8" dbHost="2" databaseVersion="4" />';
	}
	sendAndLoad($buildXML, $responseXML, "progress");
    if(defined("DEBUG")){
       debug($buildXML."\r\n".$responseXML."\r\n", 3, "..\Debug\debug_iyj.log");
    }
	$xml = simplexml_load_string($responseXML);
	$parser = xml_parser_create();
	xml_set_element_handler($parser,"start","stop");
	xml_parse($parser,$responseXML);
	xml_parser_free($parser);

	$userID=0;
	if(isset($_SESSION['FAILREASON'])){
		unset($_SESSION['FAILREASON']);
	}
	$errorCode = $errorInfo['CODE'];
	switch($errorCode) {
		case '101':
		case '203':
		case '204':
		case '205':
		case '206':
		case '208':
		case '211':
			$_SESSION['FAILREASON'] = $errorCode;
			break;
		default:
			$_SESSION['USERID'] = $userInfo['USERID'];
			$_SESSION['ISADMIN'] = $userInfo['ISADMIN'];
			$_SESSION['SESSIONID'] = $userInfo['SESSIONID'];
			$_SESSION['ROOTID'] = $userInfo['ROOTID'];
			$_SESSION['EMAIL'] = $userInfo['EMAIL'];
			$_SESSION['USERTYPE'] = $userInfo['USERTYPE'];
			$_SESSION['USERNAME'] = $userInfo['USERNAME'];
			$_SESSION['STARTDATE'] = $userInfo['STARTDATE'];
			$_SESSION['EXPIRYDATE'] = $userInfo['EXPIRYDATE'];
			$_SESSION['FREQUENCY'] = $userInfo['FREQUENCY'];
	        if($_SESSION['USERNAME']=="iyjguest"){
                $_SESSION['LANGUAGECODE'] = $demoversion;
            }else{
                $_SESSION['LANGUAGECODE'] = $userInfo['LANGUAGECODE'];
            }
            $_SESSION['CONTACTMETHOD'] = $userInfo['CONTACTMETHOD'];
			$_SESSION['LICENCESTARTDATE'] = $userInfo['LICENCESTARTDATE'];
			$_SESSION['LICENCEEXPIRYDATE'] = $userInfo['LICENCEEXPIRYDATE'];
			if($userInfo['LICENCETYPE'] == "2" || $userInfo['LICENCETYPE'] == "4"){
				$_SESSION['LICENCETYPE'] = "concurrent";
			}else{
				$_SESSION['LICENCETYPE'] = "tracking";
			}
			$_SESSION['InstanceID'] = $instanceID; // Save the instance ID for double login checking
			$_SESSION['BOOKMARK'] = $userInfo['BOOKMARK'];
	}

	if($userInfo['USERID'] > 0){
		return true;
	}else{
		return false;
	}
}
function getRMSetting($rootID, $prefix){
	global $userInfo, $errorInfo, $noteInfo, $accountInfo, $failReason, $demoversion;
	$buildXML = '<query method="getRMSettings" '.
				'rootID="'.$rootID.
				'" prefix="'.$prefix.
				'" dateStamp="'.date("Y-m-d H:i:s").
				'" cacheVersion="'.time().
				'" zone="'.date_default_timezone_get().'" productcode="1001'.
				'" dbHost="2" databaseVersion="4" />';
	sendAndLoad($buildXML, $responseXML, "progress");
	if(defined("DEBUG")){
	   debug($buildXML."\r\n".$responseXML."\r\n", 3, "..\Debug\debug_iyj.log");
	}
	$xml = simplexml_load_string($responseXML);
	$parser = xml_parser_create();
	xml_set_element_handler($parser,"start","stop");
	xml_parse($parser,$responseXML);
	xml_parser_free($parser);

    if(isset($_SESSION['FAILREASON'])){
        unset($_SESSION['FAILREASON']);
    }
	$errorCode = $errorInfo['CODE'];
	switch($errorCode) {
		case '100':
		case '101':
		case '207':
		case '212':
		case '213':
		case '214':
			$_SESSION['FAILREASON'] = $errorCode;
			break;
		default:
	        if($_SESSION['USERNAME']=="iyjguest"){
                $_SESSION['LANGUAGECODE'] = $demoversion;
            }else{
                $_SESSION['LANGUAGECODE'] = $accountInfo['LANGUAGECODE'];
            }
			$_SESSION['ROOTID'] = $accountInfo['ROOTID'];
			$_SESSION['MAXSTUDENTS'] = $accountInfo['MAXSTUDENTS'];
			$_SESSION['LICENCESTARTDATE'] = $accountInfo['LICENCESTARTDATE'];
			$_SESSION['LICENCETYPE'] = $accountInfo['LICENCETYPE'];
	}

	if($accountInfo['ROOTID'] > 0){
		return true;
	}else{
		return false;
	}
}

function getLicenceSlot($rootID, $userID){
	global $userInfo, $errorInfo, $noteInfo, $failReason;
	$buildXML = '<query method="getLicenceSlot" '.
				'rootID="'.$rootID.
				'" userID="'.$userID.
				'" licenceStartDate="'.date("Y-m-d H:i:s", $_SESSION['LICENCESTARTDATE']).
				'" licences="'.$_SESSION['MAXSTUDENTS'].
				'" cacheVersion="'.time().
				'" licenceType="'.$_SESSION['LICENCETYPE'].
	            '" userType="'.$_SESSION['USERTYPE'].
				'" prefix="'.$_SESSION['PREFIX'].
				'" productcode="1001'.
				'" dbHost="2" databaseVersion="4" />';
	sendAndLoad($buildXML, $responseXML, "licence");
    if(defined("DEBUG")){
       debug($buildXML."\r\n".$responseXML."\r\n", 3, "..\Debug\debug_iyj.log");
    }
	$xml = simplexml_load_string($responseXML);
	$parser = xml_parser_create();
	xml_set_element_handler($parser,"start","stop");
	xml_parse($parser,$responseXML);
	xml_parser_free($parser);

    if(isset($_SESSION['FAILREASON'])){
        unset($_SESSION['FAILREASON']);
    }
	$errorCode = $errorInfo['CODE'];
	switch($errorCode) {
		case '101':
		case '201':
		case '211':
			$_SESSION['FAILREASON'] = $errorCode;
			$isSuccess = false;
			break;
		default:
			$_SESSION['LICENCEID'] = $licenceInfo['ID'];
			$_SESSION['HOST'] = $licenceInfo['HOST'];
			$isSuccess = true;
	}
	return $isSuccess;
}

/*
* This function is only for network version
*/
function addUser($username, $pwd){
   global $userInfo, $errorInfo;
    $instanceID = time();
    $buildXML = '<query method="REGISTERUSER" name="'.$username.'" password="'.$pwd.'" rootID="'.$_SESSION['ROOTID'].'" groupID="'.$_SESSION['GROUPID'].'" loginOption="1" dbHost="2" databaseVersion="4"/>';
    sendAndLoad($buildXML, $responseXML, "progress");
    if(defined("DEBUG")){
       debug($buildXML."\r\n".$responseXML."\r\n", 3, "..\Debug\debug_iyj.log");
    }
    $xml = simplexml_load_string($responseXML);
    $parser = xml_parser_create();
    xml_set_element_handler($parser,"start","stop");
    xml_parse($parser,$responseXML);
    xml_parser_free($parser);

    $userID=0;
    if(isset($_SESSION['FAILREASON'])){
        unset($_SESSION['FAILREASON']);
    }
    $errorCode = $errorInfo['CODE'];
    switch($errorCode) {
        case '101':
        case '205':
        case '206':
            $_SESSION['FAILREASON'] = $errorCode;
            break;
        default:
            $_SESSION['USERID'] = $userInfo['USERID'];
            $_SESSION['USERNAME'] = $userInfo['USERNAME'];
			$_SESSION['PASSWORD'] = $userInfo['PASSWORD'];
    }

    if($userInfo['USERID'] > 0){
        return true;
    }else{
        return false;
    }
}

/*
* Main progress start
*/
// This is the default licence type, it will be overwrite by licence type from getRMSettings
if($_SERVER['HTTP_HOST'] != "www.clarityenglish.com"){
	$licenceType = "5";
}
if($_SESSION['LOGINTYPE'] == "school"){
	$licenceType = "2";
}
$id = ($_POST['id'] == "") ? $_GET['id'] : $_POST['id'];
$pwd = ($_POST['pwd'] == "") ? $_GET['pwd'] : $_POST['pwd'];
$demoversion = ($_POST['langcode']=="") ? $_GET['langcode'] : $_POST['langcode'];
$submitType = $_POST['submit'];
if($id=="") $id = $_SESSION['id'];
if($pwd=="") $pwd = $_SESSION['PASSWORD'];
$id = htmlspecialchars($id);
$pwd = htmlspecialchars($pwd);

$_SESSION['FAILURE'] = "false";
if(!isset($_SESSION['PREFIX'])){
	if(checkUser($id, $pwd) == false){
		unset($errorInfo);
		$_SESSION['FAILURE'] = "true";
		if($_SERVER['HTTP_HOST'] != "www.clarityenglish.com"){
			header("Location: index.php");
		}else{
			header("Location: ../../area1/ItsYourJob/index.php");
		}
	}else{
		if(getRMSetting($_SESSION['ROOTID'], '') == false){
			unset($errorInfo);
			$_SESSION['FAILURE'] = "true";
			if($_SERVER['HTTP_HOST'] != "www.clarityenglish.com"){
				header("Location: index.php");
			}else{
				header("Location: ../../area1/ItsYourJob/index.php");
			}
		}else{
			if(getLicenceSlot($_SESSION['ROOTID'], $_SESSION['USERID']) == false){
				unset($errorInfo);
				$_SESSION['FAILURE'] = "true";
				if($_SERVER['HTTP_HOST'] != "www.clarityenglish.com"){
					header("Location: index.php");
				}else{
					header("Location: ../../area1/ItsYourJob/index.php");
				}
			}
		}
	}
}else{
	if($_SESSION['LICENCETYPE'] != "2"){
		if($submitType == "New user"){
			if( addUser($id, $pwd) == false){
				unset($errorInfo);
			   $_SESSION['FAILURE'] = "true";
			   header("Location: ../../area1/ItsYourJob/index.php?prefix=".$_SESSION['PREFIX']);
			}
		}
		if(checkUser($id, $pwd) == false){
			unset($errorInfo);
			$_SESSION['FAILURE'] = "true";
			header("Location: ../../area1/ItsYourJob/index.php?prefix=".$_SESSION['PREFIX']);
		}else{
			if(getLicenceSlot($_SESSION['ROOTID'], $_SESSION['USERID']) == false){
				unset($errorInfo);
				$_SESSION['FAILURE'] = "true";
				header("Location: ../../area1/ItsYourJob/index.php?prefix=".$_SESSION['PREFIX']);
			}
		}
	}else{
		debug($_SERVER['REQUEST_URL']."\r\n", 3, "..\Debug\debug_iyj.log");
		$_SESSION['USERID'] = "-1";
		$_SESSION['USERNAME'] = "student";
		if(getLicenceSlot($_SESSION['ROOTID'], $_SESSION['USERID']) == false){
			unset($errorInfo);
			$_SESSION['FAILURE'] = "true";
			header("Location: ../../area1/ItsYourJob/index.php?prefix=".$_SESSION['PREFIX']);
		}
	}
}
$_SESSION['id']=$id;
$_SESSION['PASSWORD']=$pwd;

if($_SESSION['LICENCETYPE'] == ""){
	$_SESSION['LICENCETYPE'] = $licenceType;
}

$courseid = $_SESSION['courseid'];
if($courseid == "") $courseid = 1;
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="images/favicon.ico" type="image/x-icon" />
<title>Clarity English | It's Your Job | Home</title>

<!--CSS General-->
<link rel="stylesheet" type="text/css" href="css/job_general.css" />
<!-- <script type="text/javascript" language="JavaScript" src="../Software/Common/swfobject2.js"></script> -->
<!--CSS Fancy pop up box-->
<link rel="stylesheet" type="text/css" href="css/fancybox.css" />

<!--[if gte IE 5]>
<style type="text/css">
div.menu_icon_demo_png {
	margin:0;
	padding:0;
	right: -21px;
	top: 11px;
	position: absolute;
	clear: both;
	width: 35px;
	height: 31px;
	background:none;
    filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='images/demo.png' ,sizingMethod='crop');
}

div.menu_icon_new_png {
	margin:0;
	padding:0;
	right: -21px;
	top: 11px;
	position: absolute;
	clear: both;
	width: 35px;
	height: 31px;
	background:none;
    filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='images/new.png' ,sizingMethod='crop');
}
</style>
<![endif]-->

<script type="text/javascript">
<!-- hide from non JavaScript Browsers
Image1= new Image(15,15);
Image1.src = "images/ajax-loading-small.gif";
//End Hiding -->
</script>

<!--[if IE]>
<script type="text/javascript" event="FSCommand(command,args)" for="myMP3Player">
eval(args);
</script>
<![endif]-->

<!--[if lt IE 7]>
<script defer type="text/javascript" src="script/pngfix.js"></script>
<![endif]-->

<!--Load banner first-->
<SCRIPT LANGUAGE="JavaScript">
<!-- hide from non JavaScript Browsers

Image1= new Image(956,131)
Image1.src = "images/bannar_demo.jpg"

// End Hiding -->
</SCRIPT>


<!--Load XML Data-->
<script type="text/javascript" src="libClient.js"></script>
<script type="text/javascript" src="script/popup.js"></script>
<script type="text/javascript" src="../Software/Common/swfobject2.js"></script>
<script type="text/javascript">
var isDemo = false;
var g_url = "<?php echo $domain.$startFolder.'mainAction.php'; ?>";
var g_cFolder = "<?php echo $domain.$startFolder; ?>";
var g_id = "<?php echo $id ?>";
if(g_id == "iyjguest"){
	isDemo = true;
}
var g_sessionid = "<?php echo session_id(); ?>";
var g_rootid = "<?php echo $_SESSION['ROOTID'] ?>";
var g_userid = "<?php echo $_SESSION['USERID'] ?>";
var g_isAdmin = "<?php echo $_SESSION['ISADMIN'] ?>";
var g_username = "<?php echo $_SESSION['USERNAME'] ?>";
g_username = (g_username == "") ? g_id : g_username;
var g_pwd = "<?php echo $_SESSION['PASSWORD'] ?>";
var g_contactMethod = "<?php echo $_SESSION['CONTACTMETHOD'] ?>";
var g_version = "<?php echo $_SESSION['LANGUAGECODE'] ?>";
var g_version1 = "<?php echo $demoversion ?>";
var g_frequency = "<?php echo $_SESSION['FREQUENCY'] ?>";
g_frequency = (g_frequency=="") ? 0 : g_frequency;
var g_licenceType = "<?php echo $_SESSION['LICENCETYPE'] ?>";
var g_domain = "<?php echo $_SERVER['HTTP_HOST'] ?>";
var g_bookmark = "<?php echo $_SESSION['BOOKMARK'] ?>";
if (g_bookmark == "" || g_bookmark == null) g_bookmark = "";
var g_prefix = "<?php echo $_SESSION['PREFIX']; ?>";

function updateLicence(){
	cmdRequest("updateLicence.php", "GET", null, false);
}
</script>
</head>
<body onload='javascript:setInterval("updateLicence()", 60000);'>

<div id="container"><!--header area-->
<div id="header_container"><?php include 'header.php'; ?></div>
<!--End of header area--> <!--Content Area-->
<div id="content_container"><!--Menu Tab Area-->
<div id="menu_tab_bar">
<div class="menu_tab"><a id="a_course" href="javascript:loadPage('My_Course')" class="current">My Course</a></div>
<div class="menu_tab"><a id="a_progress" href="javascript:loadPage('My_Progress')">My Progress</a></div>
<div class="menu_tab"><a id="a_account" href="javascript:loadPage('My_Account')">My Account</a></div>

</div>

<!--Welcome Area-->
<div id="welcome_bar">
	<span id="subscrib_period"></span>
    <span id="subscrib_version_NAme" style="display:none">North American English</span>
    <span id="subscrib_version_IntE" style="display:none">International English</span>
    <span id="subscrib_version_IndianE" style="display:none">Indian English</span>
</div>
<a href="popup_msg_warninglogin.htm" class="contact_explain_msg_iframe" style="display:none"></a>
<!--My course whole panel - DIV loading -->
<div id="My_mainPannel" style="margin:0;padding:0;"></div>

<!--End of My course whole panel - DIV loading -->

<div id="My_progressPannel" style="margin:0;padding:0;display:none">
<!--My progress whole panel - DIV loading -->
<div id="My_Progress">
<div id="progress_left_area">
<ul>
	<li>
	<div id="done_but" class="progress_current_but"><a href="#" onclick="javascript:onClickDone();return false;">
	<p class="menu_title">What have I done?</p>
	</a></div>
	</li>

	<li>
	<div id="compare_but"><a href="#" onclick="javascript:onClickCompare();return false;">
	<p class="menu_title">Compare yourself</p>
	</a></div>
	</li>
</ul>
</div>

<!--Progress Area-->
<div id="progress_right_area"><!--Demo only: What I have done--> <img id="done_box" src="images/progress2.jpg" class="progress_img" style="display: none" /> <!--End of Demo only: What I have done--> <!--Demo only: Compare yourself-->
<div id="compare_box" style="display: none;">
	<p id="progress_title">Compare yourself against other people.</p>
	<div id="compare_display"><a href="popup_msg_progress.htm" class="display_msg_iframe"></a></div>
	<ul id="progress_title_selector">
		<li>
		<p class="left">First choose where the others come from:</p>
		<p class="right"><select name="compareWhere" class="field_timing_control">
			<option value="Worldwide" selected="selected">Worldwide</option>
			<option value="Afganistan">Afghanistan</option>
			<option value="Albania">Albania</option>
			<option value="Algeria">Algeria</option>
			<option value="American Samoa">American Samoa</option>
			<option value="Andorra">Andorra</option>
			<option value="Angola">Angola</option>
			<option value="Anguilla">Anguilla</option>
			<option value="Antigua &amp; Barbuda">Antigua &amp; Barbuda</option>
			<option value="Argentina">Argentina</option>
			<option value="Armenia">Armenia</option>
			<option value="Aruba">Aruba</option>
			<option value="Australia">Australia</option>
			<option value="Austria">Austria</option>
			<option value="Azerbaijan">Azerbaijan</option>
			<option value="Bahamas">Bahamas</option>
			<option value="Bahrain">Bahrain</option>
			<option value="Bangladesh">Bangladesh</option>
			<option value="Barbados">Barbados</option>
			<option value="Belarus">Belarus</option>
			<option value="Belgium">Belgium</option>
			<option value="Belize">Belize</option>
			<option value="Benin">Benin</option>
			<option value="Bermuda">Bermuda</option>
			<option value="Bhutan">Bhutan</option>
			<option value="Bolivia">Bolivia</option>
			<option value="Bonaire">Bonaire</option>
			<option value="Bosnia &amp; Herzegovina">Bosnia &amp; Herzegovina</option>
			<option value="Botswana">Botswana</option>
			<option value="Brazil">Brazil</option>
			<option value="British Indian Ocean Ter">British Indian Ocean Ter</option>
			<option value="Brunei">Brunei</option>
			<option value="Bulgaria">Bulgaria</option>
			<option value="Burkina Faso">Burkina Faso</option>
			<option value="Burundi">Burundi</option>
			<option value="Cambodia">Cambodia</option>
			<option value="Cameroon">Cameroon</option>
			<option value="Canada">Canada</option>
			<option value="Canary Islands">Canary Islands</option>
			<option value="Cape Verde">Cape Verde</option>
			<option value="Cayman Islands">Cayman Islands</option>
			<option value="Central African Republic">Central African Republic</option>
			<option value="Chad">Chad</option>
			<option value="Channel Islands">Channel Islands</option>
			<option value="Chile">Chile</option>
			<option value="China">China</option>
			<option value="Christmas Island">Christmas Island</option>
			<option value="Cocos Island">Cocos Island</option>
			<option value="Colombia">Colombia</option>
			<option value="Comoros">Comoros</option>
			<option value="Congo">Congo</option>
			<option value="Cook Islands">Cook Islands</option>
			<option value="Costa Rica">Costa Rica</option>
			<option value="Cote DIvoire">Cote D'Ivoire</option>
			<option value="Croatia">Croatia</option>
			<option value="Cuba">Cuba</option>
			<option value="Curaco">Curacao</option>
			<option value="Cyprus">Cyprus</option>
			<option value="Czech Republic">Czech Republic</option>
			<option value="Denmark">Denmark</option>
			<option value="Djibouti">Djibouti</option>
			<option value="Dominica">Dominica</option>
			<option value="Dominican Republic">Dominican Republic</option>
			<option value="East Timor">East Timor</option>
			<option value="Ecuador">Ecuador</option>
			<option value="Egypt">Egypt</option>
			<option value="El Salvador">El Salvador</option>
			<option value="Equatorial Guinea">Equatorial Guinea</option>
			<option value="Eritrea">Eritrea</option>
			<option value="Estonia">Estonia</option>
			<option value="Ethiopia">Ethiopia</option>
			<option value="Falkland Islands">Falkland Islands</option>
			<option value="Faroe Islands">Faroe Islands</option>
			<option value="Fiji">Fiji</option>
			<option value="Finland">Finland</option>
			<option value="France">France</option>
			<option value="French Guiana">French Guiana</option>
			<option value="French Polynesia">French Polynesia</option>
			<option value="French Southern Ter">French Southern Ter</option>
			<option value="Gabon">Gabon</option>
			<option value="Gambia">Gambia</option>
			<option value="Georgia">Georgia</option>
			<option value="Germany">Germany</option>
			<option value="Ghana">Ghana</option>
			<option value="Gibraltar">Gibraltar</option>
			<option value="Great Britain">Great Britain</option>
			<option value="Greece">Greece</option>
			<option value="Greenland">Greenland</option>
			<option value="Grenada">Grenada</option>
			<option value="Guadeloupe">Guadeloupe</option>
			<option value="Guam">Guam</option>
			<option value="Guatemala">Guatemala</option>
			<option value="Guinea">Guinea</option>
			<option value="Guyana">Guyana</option>
			<option value="Haiti">Haiti</option>
			<option value="Hawaii">Hawaii</option>
			<option value="Honduras">Honduras</option>
			<option value="Hong Kong">Hong Kong</option>
			<option value="Hungary">Hungary</option>
			<option value="Iceland">Iceland</option>
			<option value="India">India</option>
			<option value="Indonesia">Indonesia</option>
			<option value="Iran">Iran</option>
			<option value="Iraq">Iraq</option>
			<option value="Ireland">Ireland</option>
			<option value="Isle of Man">Isle of Man</option>
			<option value="Israel">Israel</option>
			<option value="Italy">Italy</option>
			<option value="Jamaica">Jamaica</option>
			<option value="Japan">Japan</option>
			<option value="Jordan">Jordan</option>
			<option value="Kazakhstan">Kazakhstan</option>
			<option value="Kenya">Kenya</option>
			<option value="Kiribati">Kiribati</option>
			<option value="Korea North">Korea North</option>
			<option value="Korea Sout">Korea South</option>
			<option value="Kuwait">Kuwait</option>
			<option value="Kyrgyzstan">Kyrgyzstan</option>
			<option value="Laos">Laos</option>
			<option value="Latvia">Latvia</option>
			<option value="Lebanon">Lebanon</option>
			<option value="Lesotho">Lesotho</option>
			<option value="Liberia">Liberia</option>
			<option value="Libya">Libya</option>
			<option value="Liechtenstein">Liechtenstein</option>
			<option value="Lithuania">Lithuania</option>
			<option value="Luxembourg">Luxembourg</option>
			<option value="Macau">Macau</option>
			<option value="Macedonia">Macedonia</option>
			<option value="Madagascar">Madagascar</option>
			<option value="Malaysia">Malaysia</option>
			<option value="Malawi">Malawi</option>
			<option value="Maldives">Maldives</option>
			<option value="Mali">Mali</option>
			<option value="Malta">Malta</option>
			<option value="Marshall Islands">Marshall Islands</option>
			<option value="Martinique">Martinique</option>
			<option value="Mauritania">Mauritania</option>
			<option value="Mauritius">Mauritius</option>
			<option value="Mayotte">Mayotte</option>
			<option value="Mexico">Mexico</option>
			<option value="Midway Islands">Midway Islands</option>
			<option value="Moldova">Moldova</option>
			<option value="Monaco">Monaco</option>
			<option value="Mongolia">Mongolia</option>
			<option value="Montserrat">Montserrat</option>
			<option value="Morocco">Morocco</option>
			<option value="Mozambique">Mozambique</option>
			<option value="Myanmar">Myanmar</option>
			<option value="Nambia">Nambia</option>
			<option value="Nauru">Nauru</option>
			<option value="Nepal">Nepal</option>
			<option value="Netherland Antilles">Netherland Antilles</option>

			<option value="Netherlands">Netherlands (Holland, Europe)</option>
			<option value="Nevis">Nevis</option>
			<option value="New Caledonia">New Caledonia</option>
			<option value="New Zealand">New Zealand</option>
			<option value="Nicaragua">Nicaragua</option>
			<option value="Niger">Niger</option>
			<option value="Nigeria">Nigeria</option>
			<option value="Niue">Niue</option>
			<option value="Norfolk Island">Norfolk Island</option>
			<option value="Norway">Norway</option>
			<option value="Oman">Oman</option>
			<option value="Pakistan">Pakistan</option>
			<option value="Palau Island">Palau Island</option>
			<option value="Palestine">Palestine</option>
			<option value="Panama">Panama</option>
			<option value="Papua New Guinea">Papua New Guinea</option>
			<option value="Paraguay">Paraguay</option>
			<option value="Peru">Peru</option>
			<option value="Phillipines">Philippines</option>
			<option value="Pitcairn Island">Pitcairn Island</option>
			<option value="Poland">Poland</option>
			<option value="Portugal">Portugal</option>
			<option value="Puerto Rico">Puerto Rico</option>
			<option value="Qatar">Qatar</option>
			<option value="Republic of Montenegro">Republic of Montenegro</option>
			<option value="Republic of Serbia">Republic of Serbia</option>
			<option value="Reunion">Reunion</option>
			<option value="Romania">Romania</option>
			<option value="Russia">Russia</option>
			<option value="Rwanda">Rwanda</option>
			<option value="St Barthelemy">St Barthelemy</option>
			<option value="St Eustatius">St Eustatius</option>
			<option value="St Helena">St Helena</option>
			<option value="St Kitts-Nevis">St Kitts-Nevis</option>
			<option value="St Lucia">St Lucia</option>
			<option value="St Maarten">St Maarten</option>
			<option value="St Pierre &amp; Miquelon">St Pierre &amp; Miquelon</option>
			<option value="St Vincent &amp; Grenadines">St Vincent &amp; Grenadines</option>
			<option value="Saipan">Saipan</option>
			<option value="Samoa">Samoa</option>
			<option value="Samoa American">Samoa American</option>
			<option value="San Marino">San Marino</option>
			<option value="Sao Tome & Principe">Sao Tome &amp; Principe</option>
			<option value="Saudi Arabia">Saudi Arabia</option>
			<option value="Senegal">Senegal</option>
			<option value="Seychelles">Seychelles</option>
			<option value="Sierra Leone">Sierra Leone</option>
			<option value="Singapore">Singapore</option>
			<option value="Slovakia">Slovakia</option>
			<option value="Slovenia">Slovenia</option>
			<option value="Solomon Islands">Solomon Islands</option>
			<option value="Somalia">Somalia</option>
			<option value="South Africa">South Africa</option>
			<option value="Spain">Spain</option>
			<option value="Sri Lanka">Sri Lanka</option>
			<option value="Sudan">Sudan</option>
			<option value="Suriname">Suriname</option>
			<option value="Swaziland">Swaziland</option>
			<option value="Sweden">Sweden</option>
			<option value="Switzerland">Switzerland</option>
			<option value="Syria">Syria</option>
			<option value="Tahiti">Tahiti</option>
			<option value="Taiwan">Taiwan</option>
			<option value="Tajikistan">Tajikistan</option>
			<option value="Tanzania">Tanzania</option>
			<option value="Thailand">Thailand</option>
			<option value="Togo">Togo</option>
			<option value="Tokelau">Tokelau</option>
			<option value="Tonga">Tonga</option>
			<option value="Trinidad &amp; Tobago">Trinidad &amp; Tobago</option>
			<option value="Tunisia">Tunisia</option>
			<option value="Turkey">Turkey</option>
			<option value="Turkmenistan">Turkmenistan</option>
			<option value="Turks &amp; Caicos Is">Turks &amp; Caicos Is</option>
			<option value="Tuvalu">Tuvalu</option>
			<option value="Uganda">Uganda</option>
			<option value="Ukraine">Ukraine</option>
			<option value="United Arab Erimates">United Arab Emirates</option>
			<option value="United Kingdom">United Kingdom</option>
			<option value="United States of America">United States of America</option>
			<option value="Uraguay">Uruguay</option>
			<option value="Uzbekistan">Uzbekistan</option>
			<option value="Vanuatu">Vanuatu</option>
			<option value="Vatican City State">Vatican City State</option>
			<option value="Venezuela">Venezuela</option>
			<option value="Vietnam">Vietnam</option>
			<option value="Virgin Islands (Brit)">Virgin Islands (Brit)</option>
			<option value="Virgin Islands (USA)">Virgin Islands (USA)</option>
			<option value="Wake Island">Wake Island</option>
			<option value="Wallis &amp; Futana Is">Wallis &amp; Futana Is</option>
			<option value="Yemen">Yemen</option>
			<option value="Zaire">Zaire</option>
			<option value="Zambia">Zambia</option>
			<option value="Zimbabwe">Zimbabwe</option>
		</select></p>
		</li>

		<li>
		<p class="left">Then the time they have been working:</p>
		<p class="right"><select name="compareWhen" class="field_timing_control">
			<option value="0">Since I started</option>
			<option value="1">In the last week</option>
			<option value="2">In the last month</option>
			<option value="3">Forever</option>
		</select></p>
		</li>
	</ul>
	<img src="images/progress1.jpg" class="progress_img" />
</div>
<!--End of Demo only: Compare yourself-->
<div id="altContent" style="display: none">
<object type="application/x-shockwave-flash" data="http://<?php echo $_SERVER['HTTP_HOST'];?>/Software/ResultsManager/web/ProgressWidget.swf" id="pw" name="pw" width="745" height="540">
	<param name="wmode" value="transparent" />
	<param name="allowScriptAccess" value="sameDomain" />
	<param name="allowFullScreen" value="false" />
	<param name="movie" value="http://<?php echo $_SERVER['HTTP_HOST'];?>/Software/ResultsManager/web/ProgressWidget.swf?reload=<?php echo time(); ?>" />
	<param name="FlashVars" value="host=http://<?php echo $_SERVER['HTTP_HOST'];?>/Software/ResultsManager/web/&userID=<?php echo $_SESSION['USERID'] ?>&rootID=<?php echo $_SESSION['ROOTID'] ?>&productCode=1001" />
</object>
</div>
</div>

<p class="clear"></p>
</div>

</div>

</div>
<!--End of Content Area--> <!--Footer area-->
<div id="footer_container"><?php include 'footer.php'; ?></div>
<!--End of Footer area--></div>
<!--End of Container-->

<!--General jquery library: For Fancy box, programs left menu-->
<script type="text/javascript" src="script/jquery.js"></script>

<!--Fancy Popup Box-->
<script type="text/javascript" src="script/fancybox.js"></script>
<script type="text/javascript" src="script/fancybox_custom.js"></script>
<script type="text/javascript">
if(g_licenceType == "2" || g_licenceType == "4" || g_licenceType == "concurrent"
	|| g_username=="iyjguest" || g_domain=="www.clarityenglish.com"){
// Don't display the my account page.
	document.getElementById('a_account').parentNode.style.display = "none";
}
if(g_licenceType == "2"){
	document.getElementById('a_progress').parentNode.style.display = "none";
}
loadPage("My_Course");
</script>
</body>
</html>