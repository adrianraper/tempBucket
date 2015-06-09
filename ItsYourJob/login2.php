<?php
session_start();
require_once("Variables.php");
require_once("libQuery.php");
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
       debug($buildXML."\r\n".$responseXML."\r\n", 3, "../Debug/debug_iyj.log");
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

if(isset($_POST['id']) && isset($_POST['pwd']) && checkUser($_POST['id'], $_POST['pwd'])) {
	echo 'yes';
}
else {
	echo $_SESSION['FAILREASON'];
}


?>
