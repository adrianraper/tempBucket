<?php
/*---------- Functions for database operator ----------*/
function sendAndLoad($postXML, &$contents, $type = "progress") {
	global $domain;
	/**
	 * Initialize the cURL session
	 */
	$ch = curl_init();
	//curl_setopt($ch, CURLOPT_HEADER, 1);
	curl_setopt($ch, CURLOPT_FAILONERROR, 1);
	/**
	 * Set the URL of the page or file to download.
	 */
	if($type == "licence"){
		$targetURL = $domain."/Software/Common/Source/SQLServer/runLicenceQuery.php";
	}else{
		$targetURL = $domain."/Software/Common/Source/SQLServer/runProgressQuery.php";
	}
	curl_setopt($ch, CURLOPT_URL, $targetURL);
	/**
	 * Ask cURL to return the contents in a variable
	 * instead of simply echoing them to the browser.
	 */
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	/**
	 * Setup the post variables
	 */
	curl_setopt($ch, CURLOPT_POST, 1);
	curl_setopt($ch, CURLOPT_POSTFIELDS, $postXML);
	/**
	 * Execute the cURL session
	 */
	$contents = curl_exec ($ch);
	/**
	 * Close cURL session
	 */
	curl_close ($ch);
}

function start($parser, $element_name, $element_attrs){
	global $userInfo;	// Saving user information
	global $errorInfo;	// Saving error information of database opration
	global $noteInfo;
	global $accountInfo;
	global $licenceInfo;
	global $instanceInfo;
	global $dbInfo;
	global $settingsInfo;
	switch(strtoupper($element_name)) {
		case "NOTE":
			$noteInfo = $element_attrs;
			break;
		case "ACCOUNT":
			$accountInfo = $element_attrs;
			break;
		case "USER":
			$userInfo = $element_attrs;
			break;
		case "LICENCE":
			$licenceInfo = $element_attrs;
			break;
        case "INSTANCE":
            $instanceInfo = $element_attrs;
            break;
        case "ERR":
			$errorInfo = $element_attrs;
			break;
		case "DATABASE":
			$dbInfo = $element_attrs;
			break;
		case "SETTINGS":
			$settingsInfo = $element_attrs;
			break;
		default:
	}
}

//Function to use at the end of an element
function stop($parser,$element_name)  {
	// Nothing need do now
}
/*-----------------------------------------------------*/

function startUser($username, $sid, $passwd, $loginOption){
	
}

/*
// Function for auto registration user from SCORM
function autoRegister($username, $sid, $prefix, $pCode){
	global $userInfo, $errorInfo;
	$instanceID = time();
	$queryParams = array(
		"method" => "addNewUser",
		"rootID" => $_SESSION['ROOTID'],
		"prefix" => $prefix,
		"groupID" => $_SESSION['GROUPID'],
		"name" => $username,
		"password" => "",
		"studentID" => $sid,
		"loginOption" => "2",
		"licenceType" => "",
		"productCode" => $pCode,
		"uniqueName" => "",
		"email" => "",
		"instanceID" => $instanceID,
		"registerMethod" => "autoRegister",
		"databaseVersion" => "6"
    );
    
    $buildXML = buildXML($queryParams);
    sendAndLoad($buildXML, $responseXML, "progress");
    if(defined("DEBUG")){
       error_log($buildXML."\r\n".$responseXML."\r\n", 3, "../Debug/debug_iyj.log");
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
*/
function buildXML($params){
	$ret = "<query";
	foreach($params as $k => $v){
		$ret .= " ".$k."='".$v."'";
	}
	$ret .="/>";
	return $ret;
}
