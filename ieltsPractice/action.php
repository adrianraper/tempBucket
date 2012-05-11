<?php

/*
* You can test like this:
   http://dock.projectbench/ieltsPractice/action.php?method=login&loginID=mimi.rahima.6@clarityenglish.com&userPassword=sweetpotatoes
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

/*
	$programVersion = 'AC';
	$prefix = "clarity";
	$rc = array();
	$rc['redirect']="$thisDomain/area1/RoadToIELTS2/Start-$programVersion.php?prefix=$prefix";
	print json_encode($rc);
	exit();
*/
// This script is called either by jQuery.ajax calls from a form or by the html submit method of the form.
// The only mandatory field is method, usually sent by POST but it could come from GET

// The purpose of this script is to login students in from various access methods to Road to IELTS.
// First time users will be registered.

// login is the first method used. We know the ID and password.
// We need to find out if this ID has already been registered, in which case is this the matching password?
if ($queryMethod=="login") {
	
	// We know we are sent a loginID and a password
	if (isset($_POST['loginID'])) {
		$loginID = $_POST['loginID'];
	} else if (isset($_GET['loginID'])) {
		$loginID = $_GET['loginID'];
	} else {
		$loginID = "";
	}
	
	if (isset($_POST['userPassword'])) {
		$typedPassword = $_POST['userPassword'];
	} else if (isset($_GET['userPassword'])) {
		$typedPassword = $_GET['userPassword'];
	} else {
		$typedPassword = "";
	}
	
	// Use LoginGateway to get back this user.
	$LoginAPI = array();
	$LoginAPI['method'] = 'getUser';
	$LoginAPI['email'] = $loginID;
	$LoginAPI['loginOption'] = 8;

	// Send this single LoginAPI
	$serializedObj = json_encode($LoginAPI);
	$targetURL = $commonDomain.'Software/ResultsManager/web/amfphp/services/LoginGateway.php';
	if ($debugLog) {
		error_log("to LoginGateway with $serializedObj\n", 3, $debugFile);
	}
	//echo $targetURL.' '.$serializedObj; exit(0);
	
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
		// echo 'Curl error: ' . curl_error($ch);
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

		if ($debugLog) {
			error_log("back from LoginGateway with $contents\n", 3, $debugFile);
		}

		$errorCode = 0;
		
		// Expecting to get back an error or a user object
		if (isset($returnInfo['error'])) {
			$errorCode = $returnInfo['error'];
			$failReason = $returnInfo['message'];
			
		} elseif (isset($returnInfo['user'])) {
			
			$userInfo = $returnInfo['user'];
			if (isset($userInfo['expiryDate']))
				$expiryDate = $userInfo['expiryDate'];

			// Did they type the right password?
			if ($typedPassword != $userInfo['password']) {
				$errorCode = 204;
				$failReason = "Wrong password";
				
			// Has the account expired
			} elseif ($expiryDate <= date('Y-m-d').' 00:00:00') {
				$errorCode = 205;
				$failReason = "Your account has expired";
				
			}
				
		} else {
			
			$errorCode = 1;
			$failReason = "Unexpected data from gateway";
		}
		
		// If you there are no errors, go to the program
		if ($errorCode == 0) {
			print json_encode($returnInfo);
			exit();
		}
			
		// Errors handled at the end of the script
	}
	
// This is the method called after the candidate has typed in their details on candidateDetails screen
//} else if ($queryMethod=="addSubscription") {


} else if ($queryMethod=="checkUser") {
	// We know we are sent an email
	if (isset($_POST['email'])) {
		$email = $_POST['email'];
	} else if (isset($_GET['email'])) {
		$email = $_GET['email'];
	} else {
		$email = "";
	}
	
	// Use LoginGateway to get back this user.
	$LoginAPI = array();
	$LoginAPI['method'] = 'getUser';
	$LoginAPI['email'] = $email;
	$LoginAPI['loginOption'] = '8';
	$LoginAPI['licenceType'] = '5';
	//$LoginAPI['dbHost'] = '11';

	// Send this single LoginAPI
	$serializedObj = json_encode($LoginAPI);
	$targetURL = $commonDomain.'Software/ResultsManager/web/amfphp/services/LoginGateway.php';
	if ($debugLog) {
		error_log("to LoginGateway with $serializedObj\n", 3, $debugFile);
	}
	//echo $targetURL.' '.$serializedObj; exit(0);
	
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
		 //echo 'Curl error: ' . curl_error($ch);
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

		if ($debugLog) {
			error_log("back from LoginGateway with $contents\n", 3, $debugFile);
		}
		
		// Expecting to get back an error or a user object
		if (isset($returnInfo['error'])){
			$errorCode = $returnInfo['error'];
			$failReason = $returnInfo['message'];
			$rc = array();
			
			if ($errorCode == 200) {
				// This email is not used, then continues
				$rc['success']=false;

			} else {
				$rc['success']=true;

			}

		} else {
				$rc['success']=true;

		}
		print json_encode($rc);
		exit();
		
		// Errors handled at the end of the script
	}
}

$rc = array();
$rc['error']=$errorCode;
$rc['message']=$failReason;
print json_encode($rc);
exit();