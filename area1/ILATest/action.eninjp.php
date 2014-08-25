<?php
session_start();
require_once("Variables.eninjp.php");

// Create classes to hold the result of the parsing
$userInfo = array();
$errorInfo= array();

// Use exceptions to handle unexpected errors (like parameters not being passed)
try {
	if (isset($_POST['method'])) {
		$queryMethod = $_POST['method'];
	} else {
		throw new Exception("you have not passed the method");
	}
	
	// First of all see if we are coming here after registration and just to link to the start page
	if ($queryMethod=='startUser') {
		unset($_SESSION['UserName']);
		unset($_SESSION['Email']);
		unset($_SESSION['StudentID']);
		unset($_SESSION['Password']);
		$url = $domain.$startFolder.'Start.eninjp.php?prefix='.$prefix;
		if ($debugSettings)
			error_log("start url:\r\n$url\r\n", 3, "logs/debug.txt"); 
		redirect($url);
	
	// Main purpose of this page is to register a new user
	} else {
	
		if (isset($_POST['learnerName'])) {
			$name = htmlentities($_POST['learnerName'], ENT_QUOTES);
		} else {
			throw new Exception("you have not passed the name");
		}
		// Japan doesn't use an email
		/*
		if (isset($_POST['learnerEmail'])) {
			$email = htmlentities($_POST['learnerEmail'], ENT_QUOTES);
		} else {
			throw new Exception("you have not passed the email");
		}
		*/
		// We should simply attempt to register the user. This will soon complain if the unique field is not unique!
		// Japan doesn't use an email
		//	"loginOption" => "8",	// use email for user checking
		//	"email" =>$email,
		$attributes = array(
			"method" => $queryMethod,	// check the user first
			"dbHost" => $dbHost,
			"rootID" => $rootID,
			"groupID" => $groupID,
			"name" => $name,
			"password" => "",
			"loginOption" => "1",	// use name for user checking
			"productCode" => "36",	// ILA test
			"registerMethod" => "ILATest",
			"databaseVersion" => "5"
		);
			// "prefix" => $prefix,

		// Use XML to build a string, sendAndLoad it and parse the result
		$buildXML = buildXMLNodeStr("query", $attributes);
		//if ($debugSettings)
		//	error_log("Query XML is:\r\n$buildXML\r\n", 3, "logs/debug.txt"); 
		sendAndLoad($buildXML, $contents);
		if ($debugSettings)
			error_log("Query is:\r\n$contents\r\n", 3, "logs/debug.txt");
		$parser=xml_parser_create();
		xml_set_element_handler($parser, "start", "stop");
		
		// Parse the XML string - into preset arrays userInfo, errorInfo
		xml_parse($parser,$contents);
		xml_parser_free($parser);
		if (isset($errorInfo['CODE'])) {
			$errorCode = $errorInfo['CODE'];
		} else {
			$errorCode=null;
		}
		
		// We are calling registerUser. 0 error is good. Expecting duplicate email.
		if( $errorCode==0 || $errorCode==null ){
			header("Content-Type: text/xml");
			
			// If no error, then get user information sent back, although all we really need is userID to let us login
			$userID = $userInfo['USERID'];
			$name = htmlentities($userInfo['NAME'], ENT_QUOTES);
			// Japan doesn't use an email
			//$email = htmlentities($userInfo['EMAIL'], ENT_QUOTES);
			$_SESSION['UserID'] = $userID;
			header("Content-Type: text/xml");
			echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?><db>";
			// Japan doesn't use an email
			//echo "<action userID='$userID' name='$name' email='$email'>You have been successfully registered.</action>";
			echo "<action userID='$userID' name='$name' >You have been successfully registered.</action>";
			echo "</db>";
			
		} else {
			$errorCode = $errorInfo['CODE'];
			switch( $errorCode ) {
				// User with this email already exists
				// Japan doesn't use an email
				case '220':
				case '206':
					$failReason = "This name has already been used.";
					break;
				// This is an unknown reason from dbProgress.insertUser
				case '205':
					$failReason = "These details can't be used, not sure why.";
					break;
				default:
					$failReason = 'unknown reason';
			}
			header("Content-Type: text/xml");
			echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?><db>";
			echo "<action errorCode='$errorCode'>$failReason</action>";
			echo "</db>";
		}
	}
	
} catch (Exception $e) {
	header("Content-Type: text/xml");
	echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?><db>";
	echo "<action errorCode='100'>{$e->getMessage()}</action>";
	echo "</db>";
}

exit(0);
?>