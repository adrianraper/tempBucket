<?php
//$sessionID = $_GET['sessionID'];
//session_id($sessionID);
session_start();
require_once("Variables.php");
require_once("libQuery.php");
/*
 * Gobal arrays for the information store form db query results.
 */
$userInfo=array();
$errorInfo=array();
$noteInfo=array();
$accountInfo=array();
$licenceInfo=array();
$dbInfo=array();
$settingsInfo=array();

if (!isset($_SESSION['PREFIX']))
	$_SESSION['PREFIX'] = $_GET['prefix'];

# Customer authentication for HKIED SAO
if ($_SESSION['PREFIX']== 'HKIEDSAO') {
	$private_key = '5rnVKa9=85rnVsrigk$HGG#529=8LSAFRdlkf72-242vjr3';
	$myvalid_period = 600;
	$time_now = time();

	if($_GET["k"] == md5($_GET["mytimestamp"].$private_key)){
		if($time_now > $_GET["mytimestamp"]){
			if($_GET["mytimestamp"] > ($time_now - $myvalid_period)){
				//$_SESSION['Shared'] = true;
				$_POST['id'] = "HKIEDSAO_admin";
				$_POST['pwd'] = "56407014";
				//Authentication valid
				//Process to login your platform
			}else{
				//Key Expired
				//echo "Time Different: ".($time_now - $myvalid_period);
				$_SESSION['FAILURE'] = "true";
				$_SESSION['FAILREASON'] = "215";
				header("Location: https://edjobplus.ied.edu.hk/eng/itsyourjob_auth_fail.php");
			}
		}else{
			//Time Invalid
			$_SESSION['FAILURE'] = "true";
			$_SESSION['FAILREASON'] = "215";
			header("Location: https://edjobplus.ied.edu.hk/eng/itsyourjob_auth_fail.php");
		}
	}
	else{
		//Authentication fail
		$_SESSION['FAILURE'] = "true";
		$_SESSION['FAILREASON'] = "215";
		header("Location: https://edjobplus.ied.edu.hk/eng/itsyourjob_auth_fail.php");
	}

}
# End of customer authentication for HKIED SAO

/*
 * Functions define part
 */
function checkUser($id, $password){
	if ($id == '' || $id === null) {
		$_SESSION['FAILURE'] = "true";
		$_SESSION['FAILREASON'] = 204;
		return false;
	}

	global $userInfo, $errorInfo, $noteInfo, $failReason, $demoversion, $settingsInfo;
	$dbversion = isset($_SESSION['DATABASEVERSION']) ? $_SESSION['DATABASEVERSION'] : "6";
	$loginOption = isset($_SESSION['LOGINOPTION']) ? $_SESSION['LOGINOPTION'] : "1";
    if(defined("DEBUG"))
       error_log("check user loginOption=$loginOption"."\r\n", 3, "../Debug/debug_iyj.log");
    $instanceID = time();
    if ($_SESSION['SCORM'] == true){
		$buildXML = '<query method="emugetuser" '.
					'studentID="'.$id.
					'" prefix="'.$_SESSION['PREFIX'].
					'" password="'.$password.
		            '" instanceID="'.$instanceID.
					'" courseid="1001" productcode="1001'.
					'" loginOption="'.$loginOption.'" dbHost="2" databaseVersion="'.$dbversion.'"/>';
	} else if ($_SESSION['Shared'] == true) {
		// shared account - loginOption = 129
		$buildXML = '<query method="emugetuser" '.
					'name="'.$id.
					'" password="'.$password.
		            '" instanceID="'.$instanceID.
					'" courseid="1001" productcode="1001'.
					'" loginOption="129" dbHost="2" databaseVersion="'.$dbversion.'"/>';	
	} else if (isset($_SESSION['PREFIX'])){
		// gh#1241 Use database loginOption setting
		$buildXML = '<query method="emugetuser" ';
		if ($_SESSION['LOGINOPTION'] == 1) {
			$buildXML .= 'name="'.$id.'"';
		} else if ($_SESSION['LOGINOPTION'] == 2) {
			$buildXML .= 'studentID="'.$id.'"';
		} else {
			$buildXML .= 'email="'.$id.'"';
		}
		$buildXML .= ' prefix="'.$_SESSION['PREFIX'].
					'" password="'.$password.
		            '" instanceID="'.$instanceID.
					'" courseid="1001" productcode="1001'.
					'" loginOption="'.$loginOption.'" dbHost="2" databaseVersion="'.$dbversion.'"/>';
	} else if ($id=="iyjguest"
			|| $_SESSION['LOGINTYPE'] == "school"
			|| stripos($_SERVER['HTTP_HOST'],"clarityenglish.com")!==false 
			|| stripos($_SERVER['HTTP_HOST'],"nas.ca")!==false ){
		// Using user name to login
		$buildXML = '<query method="emugetuser" '.
					'name="'.$id.
					'" password="'.$password.
		            '" instanceID="'.$instanceID.
					'" courseid="1001" productcode="1001'.
					'" loginOption="1" dbHost="2" databaseVersion="'.$dbversion.'"/>';
	} else {
		// Using email address to login (because we don't have a prefix)
		$buildXML = '<query method="emugetuser" '.
					'email="'.$id.
					'" password="'.$password.
		            '" instanceID="'.$instanceID.
					'" courseid="1001" productcode="1001'.
					'" loginOption="8" dbHost="2" databaseVersion="'.$dbversion.'"/>';
	}
	sendAndLoad($buildXML, $responseXML, "progress");
    if(defined("DEBUG"))
       error_log($buildXML."\r\n".$responseXML."\r\n", 3, "../Debug/debug_iyj.log");
	$xml = simplexml_load_string($responseXML);
	$parser = xml_parser_create();
	xml_set_element_handler($parser,"start","stop");
	xml_parse($parser,$responseXML);
	xml_parser_free($parser);

	$userID=0;
	if (isset($_SESSION['FAILREASON']))
		unset($_SESSION['FAILREASON']);
		
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

	if ($userInfo['USERID'] > 0){
		return true;
	} else {
		return false;
	}
}
function getRMSetting($rootID, $prefix){
	if (defined("DEBUG"))
		error_log("Calling getRMSettings from login..."."\r\n", 3, "../Debug/debug_iyj.log");
	global $userInfo, $errorInfo, $noteInfo, $accountInfo, $licenceInfo, $failReason, $demoversion;
		$buildXML = '<query method="getRMSettings" '.
				'rootID="'.$rootID.
				'" prefix="'.$prefix.
				'" dateStamp="'.date("Y-m-d H:i:s").
				'" cacheVersion="'.time().
				'" zone="'.date_default_timezone_get().'" productcode="1001'.
				'" dbHost="2" />';
	sendAndLoad($buildXML, $responseXML, "progress");
	if (defined("DEBUG"))
		error_log($buildXML."\r\n".$responseXML."\r\n", 3, "../Debug/debug_iyj.log");
	$xml = simplexml_load_string($responseXML);
	$parser = xml_parser_create();
	xml_set_element_handler($parser,"start","stop");
	xml_parse($parser,$responseXML);
	xml_parser_free($parser);

    if (isset($_SESSION['FAILREASON']))
        unset($_SESSION['FAILREASON']);
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
			//added by sky to force check if the root ID is the same for the prefix and user
			if ($prefix != "" && $_SESSION['ROOTID'] != $accountInfo['ROOTID'])
				return false;
			//end of add
	        if ($_SESSION['USERNAME']=="iyjguest"){
                $_SESSION['LANGUAGECODE'] = $demoversion;
            } else {
                $_SESSION['LANGUAGECODE'] = $accountInfo['LANGUAGECODE'];
            }
			$_SESSION['ROOTID'] = $accountInfo['ROOTID'];
			$_SESSION['MAXSTUDENTS'] = $accountInfo['MAXSTUDENTS'];
			$_SESSION['LICENCESTARTDATE'] = strtotime($accountInfo['LICENCESTARTDATE']);
			$_SESSION['LICENCETYPE'] = $accountInfo['LICENCETYPE'];
			$_SESSION['DATABASEVERSION'] = $dbInfo['VERSION'];
			$_SESSION['IPRANGE'] = $licenceInfo['IPRANGE'];
			$_SESSION['RURANGE'] = $licenceInfo['RURANGE'];
	}

	if($accountInfo['ROOTID'] > 0){
		$rangeChecked = true;
		$ipChecked = true;
		// Add judgement of ip or referr limit
		if(isset($_SESSION['IPRANGE'])){
			// If account has ip range attribute
			$ipChecked = false;
			// For Akamai served files- a special header is attached.
			// Check the Akamai configuration to see which files this works for.
			if (isset($_SERVER['HTTP_TRUE_CLIENT_IP'])) {
				$clientIp=$_SERVER['HTTP_TRUE_CLIENT_IP'];
			} elseif (isset($_SERVER["HTTP_CLIENT_IP"])) {
				$clientIp = $_SERVER["HTTP_CLIENT_IP"];
			} else {
				$clientIp = $_SERVER["REMOTE_ADDR"];
			}
			 
			// Start ip range checking
			if(defined("DEBUG"))
			error_log("ItsYourJob checking ip $clientIp, allowed ip address is ".$_SESSION['IPRANGE'], 3, "../Debug/debug_iyj.log");
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
			error_log("current referer is ".$_SERVER['HTTP_REFERER']."\n", 3, "../Debug/debug_iyj.log");
				if (strpos($_SERVER['HTTP_REFERER'],'?')) {
					$referrer=substr($_SERVER['HTTP_REFERER'],0,strpos($_SERVER['HTTP_REFERER'],'?'));
				} else {
					$referrer = $_SERVER['HTTP_REFERER'];
				}
			}
			 
			// Start referrer range checking
			if(defined("DEBUG"))
			error_log("ItsYourJob checking referrer $referrer, allowed referrer is ".$_SESSION['RURANGE'], 3, "../Debug/debug_iyj.log");
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
		
		if(!$ipChecked || !$rangeChecked){
			$_SESSION['FAILURE'] = "true";
			$_SESSION['FAILREASON'] = '250';
			return false;
		} else {
			return true;
		}
	}else{
		return false;
	}
}

function getLicenceSlot($rootID, $userID){
	global $userInfo, $errorInfo, $noteInfo, $failReason;
	$dbversion = isset($_SESSION['DATABASEVERSION']) ? $_SESSION['DATABASEVERSION'] : "6";
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
				'" dbHost="2" databaseVersion="'.$dbversion.'"/>';
	sendAndLoad($buildXML, $responseXML, "licence");
    if(defined("DEBUG")){
       error_log($buildXML."\r\n".$responseXML."\r\n", 3, "../Debug/debug_iyj.log");
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
			if (isset($licenceInfo['ID'])) $_SESSION['LICENCEID'] = $licenceInfo['ID'];
			if (isset($licenceInfo['HOST'])) $_SESSION['HOST'] = $licenceInfo['HOST'];
			$isSuccess = true;
	}
	return $isSuccess;
}

/*
* This function is only for network version
* gh#1241 Should also work for accounts with self register set to true
*/
function addUser($id, $pwd){
    global $userInfo, $errorInfo;
    $dbversion = isset($_SESSION['DATABASEVERSION']) ? $_SESSION['DATABASEVERSION'] : "6";
    $instanceID = time();
    $buildXML = '<query method="REGISTERUSER" ';
	if ($_SESSION['LOGINOPTION'] == 1) {
		$buildXML .= 'name="'.$id.'"';
	} else if ($_SESSION['LOGINOPTION'] == 2) {
		$buildXML .= 'studentID="'.$id.'"';
	} else {
		$buildXML .= 'email="'.$id.'"';
	}
	$buildXML .= ' password="'.$pwd.'" rootID="'.$_SESSION['ROOTID'].'" groupID="'.$_SESSION['GROUPID'].'" loginOption="'.$_SESSION['LOGINOPTION'].'" dbHost="2" databaseVersion="'.$dbversion.'"/>';
    sendAndLoad($buildXML, $responseXML, "progress");
    if(defined("DEBUG"))
       error_log($buildXML."\r\n".$responseXML."\r\n", 3, "../Debug/debug_iyj.log");
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
if (!isset($_SESSION['PREFIX']))
	$_SESSION['PREFIX'] = ($_POST['prefix'] == "") ? $_GET['prefix'] : $_POST['prefix'];

// Added by RL for emergency CLS fix - start
//It is the cross domain issues of CLS that makes IYJ not working in CLS
$redirect = ($_POST['redirect'] == "") ? $_GET['redirect'] : $_POST['redirect'];
if ($redirect == "CLS") {
	//$_SESSION['PREFIX'] = ($_POST['prefix'] == "") ? $_GET['prefix'] : $_POST['prefix'];
	//$id = ($_POST['id'] == "") ? $_GET['id'] : $_POST['id'];
	//$pwd = ($_POST['pwd'] == "") ? $_GET['pwd'] : $_POST['pwd'];
	$_SESSION['LOGINTYPE'] = 'school';
	$_SESSION['UserName']=$_GET['id'];
	$_SESSION['Password']=$_GET['pwd'];
}
// Added by RL for emergency CLS fix - end

// This is the default licence type, it will be overwrite by licence type from getRMSettings
if(stripos($_SERVER['HTTP_HOST'],"clarityenglish.com")!==false){
	$licenceType = "5";
}

//These lines are used for IYJ online
	//$id = ($_POST['id'] == "") ? $_GET['id'] : $_POST['id'];
	//$pwd = ($_POST['pwd'] == "") ? $_GET['pwd'] : $_POST['pwd'];
//These lines are used for ce.com login
	//if($id=="") $id = $_SESSION['id'];
	//if($pwd=="") $pwd = $_SESSION['PASSWORD'];
	//if($_SESSION['LOGINTYPE'] == "school"){
		//$licenceType = "2";
	//}
//Can be regrouped as follow

if (isset($_SESSION['LOGINTYPE'])=="school") {
	$id = $_SESSION['id'];
	$pwd = $_SESSION['PASSWORD'];
	// What about AA licence?
	$licenceType = "2";
} else {
	// 05/04/2013 change the url to use base64 encoding for the id and password
	//$id = ($_POST['id'] == "") ? $_GET['id'] : $_POST['id'];
	//$pwd = ($_POST['pwd'] == "") ? $_GET['pwd'] : $_POST['pwd'];
	$id = ($_POST['id'] == "") ? (($_GET['id'] == "aXlqZ3Vlc3Q=") ? "iyjguest" : $_GET['id']) : $_POST['id'];
	$pwd = ($_POST['pwd'] == "") ? (($_GET['pwd'] == "aXlqZGVtbw==") ? "iyjdemo" : $_GET['pwd']) : $_POST['pwd'];
	//added by sky to solve Winhoe TW_NUTC login issue 18/7/2013
	if ($id == "" && isset($_SESSION['id'])) $id = $_SESSION['id'];
	if ($pwd == "" && isset($_SESSION['pwd'])) $pwd = $_SESSION['pwd'];
	if ($pwd == "" && isset($_SESSION['Password'])) $pwd = $_SESSION['Password'];

	// gh#1241 Pick up clarityenglish.com login details
	if ($_SESSION['LOGINOPTION'] == 1) {
		if ($id == "" && isset($_SESSION['UserName'])) $id = $_SESSION['UserName'];
		if (!isset($_SESSION['UserName']))
			$_SESSION['UserName'] = $id;
	} else if ($_SESSION['LOGINOPTION'] == 2) {
		if ($id == "" && isset($_SESSION['StudentID'])) $id = $_SESSION['StudentID'];
		if (!isset($_SESSION['StudentID']))
			$_SESSION['StudentID'] = $id;
	} else {
		if ($id == "" && isset($_SESSION['Email'])) $id = $_SESSION['Email'];
		if (!isset($_SESSION['Email']))
			$_SESSION['Email'] = $id;
	}

	if ($pwd == "" && isset($_SESSION['Password'])) $pwd = $_SESSION['Password'];
}

$demoversion = ($_POST['langcode']=="") ? $_GET['langcode'] : $_POST['langcode'];
$submitType = $_POST['submit'];
// Added by Adrian for emergency DEMO fix - start
$demoPrefix = ($_POST['demoPrefix'] == "") ? $_GET['demoPrefix'] : $_POST['demoPrefix'];
if ($demoPrefix=="DEMO") $_SESSION['prefix']='DEMO';
// Added by Adrian for emergency DEMO fix - end
if ($_SESSION['SCORM'] == true) {
	$sid = $_SESSION['SID'];
	$sid = htmlspecialchars($sid);
}
$id = htmlspecialchars($id);
$pwd = htmlspecialchars($pwd);

// gh#1241
if (!isset($_SESSION['Password']))
	$_SESSION['Password'] = $pwd;

$_SESSION['FAILURE'] = "false";
if (!isset($_SESSION['PREFIX'])){
	if (checkUser($id, $pwd) == false){
		unset($errorInfo);
		$_SESSION['FAILURE'] = "true";
		//error_log("The fail reason is ".$_SESSION['FAILREASON']."\r\n", 3, "../Debug/debug_iyj.log");
		header("Location: ../../area1/ItsYourJob/index.php");
	} else {
		if(getRMSetting($_SESSION['ROOTID'], '') == false){
			unset($errorInfo);
			$_SESSION['FAILURE'] = "true";
			header("Location: ../../area1/ItsYourJob/index.php");
		} else {
			if(getLicenceSlot($_SESSION['ROOTID'], $_SESSION['USERID']) == false){
				unset($errorInfo);
				$_SESSION['FAILURE'] = "true";
				header("Location: ../../area1/ItsYourJob/index.php");
			}
		}
	}
} else {
	if($_SESSION['LICENCETYPE'] != "2"){
		if($submitType == "New user"){
			if( addUser($id, $pwd) == false){
				unset($errorInfo);
				$_SESSION['FAILURE'] = "true";
				header("Location: ../../area1/ItsYourJob/index.php?prefix=".$_SESSION['PREFIX']);
			}
		}
		// if program is loaded from SCORM
		if($_SESSION['SCORM'] == true){
			if(checkUser($sid, $pwd) == false){
				// Todo: we need consider the case that user has already existed, but checkUser failed
				if(autoRegister($id, $sid, $_SESSION['PREFIX'], '1001') == false){
					unset($errorInfo);
					$_SESSION['FAILURE'] = "true";
					header("Location: ../../area1/ItsYourJob/index.php?prefix=".$_SESSION['PREFIX']);					
				}
			}
		} else if (checkUser($id, $pwd) == false){
			unset($errorInfo);
			$_SESSION['FAILURE'] = "true";
			if (defined('DEBUG')) error_log("The fail reason is ".$_SESSION['FAILREASON']."\r\n", 3, "../Debug/debug_iyj.log");
			header("Location: ../../area1/ItsYourJob/index.php?prefix=".$_SESSION['PREFIX']);
		} else if(getRMSetting("", $_SESSION['PREFIX']) == false){
			unset($errorInfo);
			$_SESSION['FAILURE'] = "true";
			header("Location: ../../area1/ItsYourJob/index.php");
		} else {
			if(getLicenceSlot($_SESSION['ROOTID'], $_SESSION['USERID']) == false){
				unset($errorInfo);
				$_SESSION['FAILURE'] = "true";
				header("Location: ../../area1/ItsYourJob/index.php?prefix=".$_SESSION['PREFIX']);
			}
		}
	} else {
		if(defined("DEBUG")) error_log($_SERVER['REQUEST_URL']."\r\n", 3, "../Debug/debug_iyj.log");
		$_SESSION['USERID'] = "-1";
		$_SESSION['USERNAME'] = "student";
		if(getLicenceSlot($_SESSION['ROOTID'], $_SESSION['USERID']) == false){
			unset($errorInfo);
			$_SESSION['FAILURE'] = "true";
			header("Location: ../../area1/ItsYourJob/index.php?prefix=".$_SESSION['PREFIX']);
		}else{
			//force to start a T_Session record by sky
			global $userInfo, $errorInfo, $noteInfo, $failReason;
			$dbversion = isset($_SESSION['DATABASEVERSION']) ? $_SESSION['DATABASEVERSION'] : "6";
			$buildXML = '<query method="startSession" '.
						'rootID="'.$_SESSION['ROOTID'].
						'" userID="'.$_SESSION['USERID'].
						'" courseName="It%27s%20Your%20Job%20Practice%20Centre'.
						'" courseID="1001'.
						'" cacheVersion="'.time().
						'" datestamp="'.date("Y-m-d H:i:s").
						'" userType="'.$_SESSION['USERTYPE'].
						'" duration="15'.
						'" productCode="1001'.
						'" databaseVersion="'.$dbversion.'"/>';
			sendAndLoad($buildXML, $responseXML, "progress");
		}
	}
}
$_SESSION['id']=$id;
$_SESSION['PASSWORD']=$pwd;

if($_SESSION['LICENCETYPE'] == "")
	$_SESSION['LICENCETYPE'] = $licenceType;

if (isset($_SESSION['courseid'])) $courseid = $_SESSION['courseid'];
if ($courseid == "") $courseid = 1;

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
var g_startingPoint = "<?php if (isset($_SESSION['startingPoint'])) echo $_SESSION['startingPoint']; ?>";
var g_referer = "<?php if (isset($_GET['from'])) echo $_GET['from']; ?>";
var isSCORM = "<?php echo $_SESSION['SCORM'];?>";
function updateLicence(){
	cmdRequest("updateLicence.php", "GET", null, false);
}
</script>
<script type="text/javascript">
var webShare = "..";
var startControl = webShare + "/Software/Common/";
var progressControl = webShare + "/Software/ResultsManager/web/";
var coordsWidth = 745; var coordsHeight = 540;

var flashvars = {
	host: "http://<?php echo $_SERVER['HTTP_HOST'];?>/Software/ResultsManager/web/",
	userID: "<?php echo $_SESSION['USERID'] ?>",
	rootID: "<?php echo $_SESSION['ROOTID'] ?>",
	productCode: "1001"
};
var params = {
	wmode: "transparent",
	allowScriptAccess: "sameDomain",
	allowFullScreen: "false",
	scale: "noScale"
};
var attr = {
	id: "pw",
	name: "pw"
};
var expressInstall = startControl + "expressInstall.swf";
//swfobject.embedSWF(progressControl + "ProgressWidget.swf", "altContent", coordsWidth, coordsHeight, "9.0.28", expressInstall, flashvars, params, attr);
</script>
</head>
<body onload='javascript:setInterval("updateLicence()", 60000);loadPage("My_Course");'>



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
<div id="progress_right_area">
<!--Demo only: What I have done-->
	<img id="done_box" src="" class="progress_img" style="display: none" />
<!--End of Demo only: What I have done-->
<!--Demo only: Compare yourself-->
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
	<img id="img_compare_box" src="" class="progress_img" />
</div>
<!--End of Demo only: Compare yourself-->
<div id="altContent" style="display: none">
<p>This application requires Adobe's Flash player, running at least version 9.</p>
<p>It seems your browser doesn't have this.</p>
<p>Please download the latest Adobe Flash Player.</p>
<p><a href="http://www.adobe.com/go/getflashplayer"><img src="images/get_flash_player.gif" alt="Get Adobe Flash player" border="0"/></a></p>
<p>If you still get this message, then your browser is stopping the scripts on this page from running.</p>
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
	|| g_username=="iyjguest" || stripos(g_domain,"clarityenglish.com")!==false){
// Don't display the my account page.
	document.getElementById('a_account').parentNode.style.display = "none";
}
if(g_licenceType == "2"){
	document.getElementById('a_progress').parentNode.style.display = "none";
}
//loadPage("My_Course");
</script>
</body>
</html>
