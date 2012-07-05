<?php
session_start();
include_once "Variables.php";
$queryMethod = $_POST['method'];
if($queryMethod == ""){
	$queryMethod = $_GET['method'];
}

$dbHost= $locationInfo['dbHost'];

if ($queryMethod=="userLogin") {
	$property = array(); // This is an array for storing XML node property.
	$property['method'] = "getGlobalUser";
	// Process student ID
	$studentID= $_POST['studentID'];
	$_SESSION["candidateID"] = $studentID; // for email sending
	$loginID= $_POST['studentID'];
	$password = $_POST['userPassword'];
	// Check the password with hash of name, if it is the password of hash change to the edit page.
	$ctx = hash_init('sha1');
	hash_update($ctx, $studentID);
	$cPasswd = substr(hash_final($ctx), 0, 8);
	$cPasswd = strtoupper($cPasswd);
	$pattern = '/-/';
	$replacement = '';
	$sID = preg_replace($pattern, $replacement, $studentID);
	$programVersion = substr($sID, 0, 2);
	if($programVersion == '12'){
		$programVersion = 'A';
	}else{
		$programVersion = 'G';
	}
	$groupID = substr($sID, 2, 3);
	if(!is_numeric($groupID)){
		redirect($domain.$startFolder."login.php?login=failed&code=203");
	}
	//$studentID = substr($studentID, 5, 7);
	// If not hash of the name, do adminLogin progress
	$property['studentID'] = $studentID;
	$property['password'] = htmlspecialchars($password, ENT_QUOTES, 'UTF-8');
	$property['groupID'] = $groupID;
	$property['loginOption'] = "2";
	$property['dbHost'] = $dbHost;
	$property['databaseVersion'] = "2";
	$buildXML = buildXMLString("query", $property);
// echo $buildXML; exit(0);
	$postXML = urlencode($buildXML);
} else if ($queryMethod=="userLogin2") {
	$property = array();
	$property['method'] = "getGlobalUser";
	$studentID = $_POST['lID'];
	$password = $_POST['lpwd'];
	$property['studentID'] = $studentID;
	$property['password'] = htmlspecialchars($password, ENT_QUOTES, 'UTF-8');
	$property['loginOption'] = "2";
	$property['dbHost'] = $dbHost;
	$property['databaseVersion'] = "2";
	$buildXML = buildXMLString("query", $property);
	$postXML = urlencode($buildXML);
} else if ($queryMethod=="getUserDetail") {
	$property = array();
	$property['method'] = "getUserDetail";
	$property['studentID'] = $_POST['studentID'];
	if(!is_numeric($property['studentID'])){
		echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?><db><action errorCode='$errorCode'>No such id or you didn't input the email when you first login.</action></db>";
		exit;
	}
	$inputID = $_POST['inputID'];
	$property['loginOption'] = "2";
	$property['dbHost'] = $dbHost;
	$property['databaseVersion'] = "2";
	$buildXML = buildXMLString("query", $property);
	$postXML = urlencode($buildXML);
}else if ($queryMethod=="addNewUser") {
	$property = array();
	$property['method'] = "registerUser";
	$property['name'] = $_POST['learnerName'];
	$property['password'] = htmlspecialchars($_POST['password'], ENT_QUOTES, 'UTF-8');
	$property['studentID'] = $_POST['studentID'];
	$property['rootID'] = $_SESSION['rootID'];
	$property['groupID'] = $_SESSION['groupID'];
	$property['email'] = $_POST['email']; // conversion of @ and . characters
	$property['productCode'] = $_POST['programGroup'];
	$property['loginOption'] = "2"; // this is fixed, studentID login + doesn't have to be unique
	$property['dbHost'] = $dbHost;
	$property['databaseVersion'] = "2";
	// This is better done in the form
	$property['expiryDate'] = $_POST['expiryDate'];
	$buildXML = buildXMLString("query", $property);
	$postXML = urlencode($buildXML);
}
// echo $postXML; exit(0);
sendAndLoad($postXML, $contents);
// echo $contents; exit(0);
// Put the contents into an XML object and see what it says.
$xml = simplexml_load_string($contents);
$time = date('Y-m-d H:i:s', time());
//error_log("DateTime: ".$time."\nQuery:\n".$buildXML."\nReturn Message:\n".$contents."\n", 3, "/var/tmp/clarity/GRTI_error.log");
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

if ($queryMethod=="userLogin" ) {
	$userID=0;
	// First - was an error returned?
	$errorCode = $errorInfo['CODE'];
	// echo "error is $errorCode password should be $cPasswd";
	switch($errorCode) {
		case '206':
		case '203':
			if( $cPasswd == strtoupper($password) || $cPasswd == $password){
				$_SESSION['studentID']=$studentID;
				$_SESSION['loginID']=$loginID;
				$_SESSION['groupID']=$groupID;
				$_SESSION['programVersion'] = $programVersion;
				$_SESSION['rootID'] = $errorInfo['ROOTID'];
				redirect($domain.$startFolder."candidateDetails.php");
			} else {
				$errorCode= "204";
			}
			break;
		case '204':
			$failReason = "Wrong password";
			//echo "error code=".$errorCode;
			break;
		case '208':
			$failReason = "User expired";
			break;
		default:
			// If no error, then get user information
			$userID = $userInfo['USERID'];
			$rootID = $userInfo['ROOTID'];
			$groupID = $userInfo['GROUPID'];
			$userType = $userInfo['USERTYPE'];
			$email = $userInfo['EMAIL'];
			$studentID = $userInfo['STUDENTID'];
			$name = $userInfo['USERNAME'];
			$expiryDate = $userInfo['EXPIRYDATE'];
			$password = $userInfo['PASSWORD'];
			$country = $userInfo['COUNTRY'];
			$productCode = $userInfo['USERPROFILEOPTION'];
	}

	// If everything was fine, then let the person in and save their country and group in session variables
	if( $userID > 0){
		$_SESSION['rootID']=$rootID;
		$_SESSION['groupID']=$groupID;
		$_SESSION['country']=$country;
		$_SESSION['userEmail']=$email;
		$_SESSION['userName']=$name;
		$_SESSION['studentID']=$studentID;
		$_SESSION['password']=$password;
		$_SESSION['productCode']=$productCode;
		redirect($domain.$startFolder."RTIStart.php");
	} else {
		// otherwise prompt error for user
		// If error code is null and studentID is null, set error code 204
		if ( ($errorCode == "" || $errorCode == null) && ($studentID == "" || $studentID == null) ) 
			$errorCode= "204";
		//echo "redirect please";
		$url = $domain.$startFolder."login.php?login=failed&code=$errorCode&studentID=$studentID";
		header('Location:'.$url);
		exit(0);
	}
} else if( $queryMethod=="userLogin2"){
	$userID=0;
	// First - was an error returned?
	$errorCode = $errorInfo['CODE'];
	switch($errorCode) {
		case '206':
		case '203':
			$failReason = "No such user";
			break;
		case '204':
			$failReason = "Wrong password";
			//echo "error code=".$errorCode;
			break;
		case '208':
			$failReason = "User expired";
			break;
		default:
			// If no error, then
			// What information about the user do you need to know?
			$userID = $userInfo['USERID'];
			$rootID = $userInfo['ROOTID'];
			$groupID = $userInfo['GROUPID'];
			$userType = $userInfo['USERTYPE'];
			$email = $userInfo['EMAIL'];
			$studentID = $userInfo['STUDENTID'];
			$name = $userInfo['USERNAME'];
			$expiryDate = $userInfo['EXPIRYDATE'];
			$password = $userInfo['PASSWORD'];
			$country = $userInfo['COUNTRY'];
			$productCode = $userInfo['USERPROFILEOPTION'];
	}

	// If everything was fine, then let the person in and save their country and group in session variables
	if( $userID > 0){
		$_SESSION['rootID']=$rootID;
		$_SESSION['groupID']=$groupID;
		$_SESSION['country']=$country;
		$_SESSION['userEmail']=$email;
		$_SESSION['userName']=$name;
		$_SESSION['studentID']=$studentID;
		$_SESSION['password']=$password;
		$_SESSION['productCode']=$productCode;
		redirect($domain.$startFolder."RTIStart.php");
	} else {
		// If error code is null and studentID is null, set error code 204
		if ( ($errorCode == "" || $errorCode == null) && ($studentID == "" || $studentID == null) ) $errorCode= "204";
		redirect($domain.$startFolder."login.php?login=failed&code=$errorCode&username=$name");
	}
} else if ($queryMethod=="addNewUser") {
	// we are expecting this function to send back a success node, perhaps with a userID for reference.
	header("Content-Type: text/xml");
	$node = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><db>";
	echo $node;

	$userID=0;
	// First - was an error returned?
	$errorCode = $errorInfo['CODE'];
	switch($errorCode) {
		case '206':
		case '203':
		case '204':
			$failReason = "Duplicate details";
			break;
		default:
			// If no error, then
			// What information about the user do you need to know?
			$userName = $userInfo['NAME'];
			$userID = $userInfo['USERID'];
			$studentID = $userInfo['STUDENTID'];
			$password = $userInfo['PASSWORD'];
			$email = $userInfo['EMAIL'];
	}

	// If everything was fine, say this person is registered - then send an email
	if ($userID>0) {
		$password = htmlspecialchars($password, ENT_QUOTES, 'UTF-8');
		echo "<action userID='$userID' studentID='$studentID' password='$password'>Candidate has been successfully registered.</action>";
		$senderName = "Carl Rhymer, British Council"; //senders name
		$senderEmail = "no-reply@ieltspractice.com"; //senders e-mail adress
		// Comment out until we are ready to go live
		$to = $email; //recipient
		$subject = "Welcome to The Road to IELTS"; //subject
		$headers  = 'MIME-Version: 1.0' . "\r\n";
		$headers .= 'Content-type: text/html; charset=utf-8' . "\r\n";
		$headers .= "From: \"$senderName\" <$senderEmail>\r\n" .
					"Reply-To: $senderEmail \r\n";
		//$headers .= "cc: $adminEmail \r\n";

		$emailTemplate = "welcomeEmail.html";
		//$fh = fopen($emailTemplate, 'r');
		//$body = fread($fh, filesize($emailTemplate));
		$body = file_get_contents($emailTemplate);
		//fclose($fh);
		// Do some replacement on variables
		$patterns = array("{name}", "{id}", "{password}");
		$replacements   = array($name, $_SESSION["candidateID"], $password);
		$body = str_replace($patterns, $replacements, $body);

		$returnCode = mail( $to, $subject, $body, $headers );
		if ($returnCode==1) {
			echo("<mail>Email sent</mail>");
		} else {
			echo("<mail errorCode='100'>Email failed</mail>");
		}
	} else {
		// otherwise say no
		// If error code is null and studentID is null, set error code 204
		if ( ($errorCode == "" || $errorCode == null) && ($studentID == "" || $studentID == null) ) $errorCode= "204";
		echo "<action errorCode='$errorCode'>Learner could not be registered, because $failReason</action>";
	}
} else if ($queryMethod=="getUserDetail"){
	// we are expecting this function to send back a success node, perhaps with a userID for reference.
	header("Content-Type: text/xml");
	$node = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><db>";
	echo $node;

	$userID=0;
	// First - was an error returned?
	$errorCode = $errorInfo['CODE'];
	switch($errorCode) {
		case '206':
		case '203':
			$failReason = "No such user";
			break;
		case '204':
			$failReason = "Duplicate details";
			//echo "error code=".$errorCode;
			break;
		default:
			// If no error, then
			// What information about the user do you need to know?
			$userName = $userInfo['NAME'];
			$userID = $userInfo['USERID'];
			$studentID = $userInfo['STUDENTID'];
			$password = $userInfo['PASSWORD'];
			$email = $userInfo['EMAIL'];
	}
	if($userID > 0 && $email != ""){
		echo "<action userID='$userID' studentID='$studentID' email='$email' name='$userName' expiryDate='$expiryDate' programVersion='$programVersion'>Get Detail</action>";
		$senderName = "Carl Rhymer, British Council"; //senders name
		$senderEmail = "no-reply@ieltspractice.com"; //senders e-mail adress
		// Comment out until we are ready to go live
		$to = $email; //recipient
		$subject = "Welcome to The Road to IELTS"; //subject
		$headers  = 'MIME-Version: 1.0' . "\r\n";
		$headers .= 'Content-type: text/html; charset=utf-8' . "\r\n";
		$headers .= "From: \"$senderName\" <$senderEmail>\r\n" .
					"Reply-To: $senderEmail \r\n";
		$emailTemplate = "welcomeEmail.html";
		$body = file_get_contents($emailTemplate);
		// Do some replacement on variables
		$patterns = array("{name}", "{id}", "{password}");
		$replacements   = array($userName, $inputID, $password);
		$body = str_replace($patterns, $replacements, $body);

		$returnCode = mail( $to, $subject, $body, $headers );
		if ($returnCode==1) {
			echo("<mail>Email sent</mail>");
		} else {
			echo("<mail errorCode='100'>Email failed</mail>");
		}
	}else{
		echo "<action errorCode='$errorCode'>No such id or you didn't input the email when you first login.</action>";
	}
} else {
	echo "<action errorCode='$errorCode'>No such id</action>";
}
echo "</db>";

function redirect ($url) {
	header('Location: ' . $url);
	exit;
}
function sendAndLoad($postXML, &$contents) {
	global $domain;
	global $ipDomain;
	/**
		* Initialize the cURL session
		*/
	$ch = curl_init();
	//curl_setopt($ch, CURLOPT_HEADER, 1);
	curl_setopt($ch, CURLOPT_FAILONERROR, 1);
	/**
		* Set the URL of the page or file to download.
		*/
	$targetURL = "$ipDomain/Software/Common/Source/SQLServer/runProgressQuery.php";
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
	if($contents === false){
		echo 'Curl error: ' . curl_error($ch);
	}
	//echo $contents;
	/**
		* Close cURL session
		*/
	curl_close ($ch);
}
//Function to use at the start of an element
function start($parser, $element_name, $element_attrs){
	global $userInfo;
	global $errorInfo;
	switch(strtoupper($element_name)) {
		case "NOTE":
			break;
		case "USER":
			$userInfo = $element_attrs;
			break;
		case "ERR":
			$errorInfo = $element_attrs;
			break;
	}
}
//Function to use at the end of an element
function stop($parser,$element_name)  {
}

function buildXMLString($nodeName, $array, $content = NULL){
	$XMLString = "<".$nodeName." ";
	foreach($array as $key => $value){
		$XMLString .= $key."='".$value."' ";
	}
	if($content == NULL){
		$XMLString .= "/>";
	}else{
		$XMLString .= ">".$content."</".$nodeName.">";
	}
	return $XMLString;
}
?>
