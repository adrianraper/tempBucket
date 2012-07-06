<?php

/*
* You can test like this:
   http://dock.projectbench/BritishCouncil/R2IV2/action.php?method=login&loginID=1217-0552-6018&userPassword=123
   http://dock.projectbench/BritishCouncil/R2IV2/action.php?method=addNewUser&loginID=1217-0552-6018&learnerName=Adrian early worm&password=1234&email=adrian@clarity.com.hk
*/

session_start();
require_once "variables.php";

if (isset($_POST['method'])) {
	$queryMethod = $_POST['method'];
} else if (isset($_GET['method'])) {
	$queryMethod = $_GET['method'];
} else {
	$queryMethod = "";
}

// Initialize variables
$errorCode = 0;
$failReason = '';
$rc = array();

// This script is called either by jQuery.ajax calls from a form or by the html submit method of the form.
// The only mandatory field is method, usually sent by POST but it could come from GET

// The purpose of this script is to login students in from various access methods to Road to IELTS.
// First time users will be registered.

// login is the first method used. We know the ID and password.
// We need to find out if this ID has already been registered, in which case is this the matching password?
// This is the method called after the candidate has typed in their details on addUser screen
if ($queryMethod=="getOrAddUser") {

	// We know we are sent a loginID and a password
	if (isset($_POST['email'])) {
		$email= $_POST['email'];
	} else if (isset($_GET['email'])) {
		$email= $_GET['email'];
	} else {
		$email = "";
	}
	
	// Use LoginGateway to add this user.
	$LoginAPI = array();
	$LoginAPI['method'] = 'getOrAddUser';
	$LoginAPI['name'] = $email;
	$LoginAPI['groupID'] = $groupID;
	$LoginAPI['adminPassword'] = 'clarity88';
	$LoginAPI['dbHost'] = $dbHost;
	$LoginAPI['loginOption'] = 1;

	// Send this single LoginAPI
	$serializedObj = json_encode($LoginAPI);
	$targetURL = $commonDomain.'Software/ResultsManager/web/amfphp/services/LoginGateway.php';
	if ($debugLog) {
		error_log("to LoginGateway with $serializedObj\n", 3, $debugFile);
	}
	// echo $targetURL.' '.$serializedObj; exit(0);
	
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
		curl_close($ch);
		$errorCode = 1;
		$failReason = curl_error($ch);
	} else {
		curl_close($ch);
		// $contents is coming back with a utf-8 BOM in front of it, which invalidates it as JSON. Get rid of it.
		if (substr($contents,0,3)==b"\xEF\xBB\xBF") {
			$contents = substr($contents,3);
		}
		//echo $contents;exit(0);
		$returnInfo = json_decode($contents, true);

		if ($debugLog)
			error_log("back from LoginGateway with $contents\n", 3, $debugFile);

		// Expecting to get back an error or a user object
		if (isset($returnInfo['error'])){
			$errorCode = $returnInfo['error'];
			$failReason = $returnInfo['message'];
			
		} elseif (isset($returnInfo['user'])){
			
			$userInfo = $returnInfo['user'];
			
			// We didn't have a prefix before getting this user details, so check that we have one now
			if (isset($returnInfo['account'])){
				$accountInfo = $returnInfo['account'];
				$_SESSION['UserName'] = $userInfo['name'];
				$_SESSION['Password'] = '';
				$prefix = $accountInfo['prefix'];
				$errorCode = 0;
			} else {
				$errorCode = 300; // No known account
			}
		} else {
			$errorCode = 1;
		}
		
		// If there are no errors, go to the program
		if ($errorCode == 0) {
			if ($debugLog)
				error_log("going to the program for $prefix\n", 3, $debugFile);
				
			$rc['redirect'] = $thisDomain."area1/AccessUK/Start.php?prefix=$prefix";
			print json_encode($rc);
			exit();
		}
		
		// Errors handled at the end of the script
	}
	
}

$rc['error']=$errorCode;
$rc['message']=$failReason;
print json_encode($rc);
exit();
	
