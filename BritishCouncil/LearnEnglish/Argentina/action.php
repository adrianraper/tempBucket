<?php

/*
* You can test like this:
   http://dock.fixbench/BritishCouncil/LearnEnglish/Model/action.php?method=addNewUser&learnerName=Gustomer Horris&email=adrian@noodles.hk
*/

session_start();
error_log("line 1\n", 3, $debugFile);

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

// The purpose of this script is to create a user and send them to the LearnEnglish Level Test
	
// This is the method called after the candidate has typed in their details on the register screen
if ($queryMethod=="addNewUser") {

	// We know we are sent a name and email. 
	if (isset($_POST['learnerName'])) {
		$learnerName = $_POST['learnerName'];
	} else if (isset($_GET['learnerName'])) {
		$learnerName = $_GET['learnerName'];
	} else {
		$learnerName = "";
	}

	if (isset($_POST['learnerEmail'])) {
		$email = $_POST['learnerEmail'];
	} else if (isset($_GET['learnerEmail'])) {
		$email = $_GET['learnerEmail'];
	} else {
		$email = "";
	}

	if (isset($_POST['learnerLanguage'])) {
		$language = $_POST['learnerLanguage'];
	} else if (isset($_GET['learnerLanguage'])) {
		$language = $_GET['learnerLanguage'];
	} else {
		$language = "";
	}

	// We want to use studentID to be unique rather than email which might already exist, we don't care
	// Build a hash of the name and save as the ID
	$ctx = hash_init('sha1');
	hash_update($ctx, $learnerName);
	hash_update($ctx, time());
	$uniqueStudentID = substr(hash_final($ctx), 0, 32);	
	
	// Use LoginGateway to add this user.
	$LoginAPI = array();
	$LoginAPI['method'] = 'getOrAddUser';
	$LoginAPI['studentID'] = $uniqueStudentID;
	$LoginAPI['name'] = htmlspecialchars($learnerName, ENT_QUOTES, 'UTF-8');
	//$LoginAPI['email'] = $email;
	$LoginAPI['password'] = 'BCLELT';
	$LoginAPI['productCode'] = 46;
	$LoginAPI['subscriptionPeriod'] = '1m';
	$LoginAPI['country'] = 'Argentina';
	// No email required
	//$LoginAPI['emailTemplateID'] = 'BC-Chile-LearnEnglishLevelTest';
	$LoginAPI['prefix'] = $prefix;
	$LoginAPI['groupID'] = $groupID;
	$LoginAPI['adminPassword'] = 'clarity88';
	$LoginAPI['dbHost'] = $dbHost;
	$LoginAPI['loginOption'] = 2;

	// Send this single LoginAPI
	$serializedObj = json_encode($LoginAPI);
	$targetURL = $commonDomain.'Software/ResultsManager/web/amfphp/services/LoginGateway.php';
	if ($debugLog)
		error_log("to LoginGateway with $serializedObj\n", 3, $debugFile);
		
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
		$errorCode = 1;
		$failReason = curl_error($ch);
		curl_close($ch);
	} else {
		curl_close($ch);
		// $contents is coming back with a utf-8 BOM in front of it, which invalidates it as JSON. Get rid of it.
		if (substr($contents,0,3)==b"\xEF\xBB\xBF") {
			$contents = substr($contents,3);
		}
		//echo $contents;exit(0);
		$returnInfo = json_decode($contents, true);

		// Expecting to get back an error or a user object
		if (isset($returnInfo['error'])){
			$errorCode = $returnInfo['error'];
			$failReason = $returnInfo['message'];
			
			if ($debugLog)
				error_log("error from LoginGateway $errorCode, $failReason\n", 3, $debugFile);
				
		} elseif (isset($returnInfo['user'])){
			
			$userInfo = $returnInfo['user'];
			$username = $userInfo['name'];
			
			// We didn't have a prefix before getting this user details, so check that we have one now
			if (isset($returnInfo['account'])){
				$accountInfo = $returnInfo['account'];
				$_SESSION['Password'] = $userInfo['password'];
				$_SESSION['StudentID'] = $uniqueStudentID;
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
				error_log(date('Y-m-d')." start $prefix for userID=".$userInfo['userID']."\n", 3, $debugFile);
				
			$rc['redirect']=$thisDomain.$startFolder."Start-$language.php?prefix=$prefix";
			print json_encode($rc);
			exit();
		}
		
		// Errors handled at the end of the script
	}
	
}

$rc = array();
$rc['error']=$errorCode;
$rc['message']=$failReason;
print json_encode($rc);
exit();
	
