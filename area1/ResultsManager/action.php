<?php

/*
* You can test like this:
   http://dock.fixbench/BritishCouncil/LearnEnglish/Model/action.php?method=addNewUser&learnerName=Gustomer Horris&email=adrian@noodles.hk
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

// The purpose of this script is to create a user and send them to the LearnEnglish Level Test
	
// This is the method called after the candidate has typed in their details on the register screen
if ($queryMethod=="authenticateUser") {

	// We know we are sent a name and email. 
	if (isset($_POST['learnerName'])) {
		$learnerName = $_POST['learnerName'];
	} else if (isset($_GET['learnerName'])) {
		$learnerName = $_GET['learnerName'];
	} else {
		$learnerName = "";
	}

	if (isset($_POST['learnerPassword'])) {
        $learnerPassword = $_POST['learnerPassword'];
	} else if (isset($_GET['learnerPassword'])) {
        $learnerPassword = $_GET['learnerPassword'];
	} else {
        $learnerPassword = "";
	}

    if (isset($_POST['prefix'])) {
        $prefix = $_POST['prefix'];
    } else if (isset($_GET['prefix'])) {
        $prefix = $_GET['prefix'];
    } else {
        $prefix = "";
    }

    // Use BulkImportGateway to login this user.
	$LoginAPI = array();
	$LoginAPI['method'] = 'authenticateUser';
	$LoginAPI['name'] = htmlspecialchars($learnerName, ENT_QUOTES, 'UTF-8');
	$LoginAPI['password'] = htmlspecialchars($learnerPassword, ENT_QUOTES, 'UTF-8');
	$LoginAPI['prefix'] = $prefix;
    //$LoginAPI['rootID'] = 163;
	$LoginAPI['dbHost'] = $dbHost;
	$LoginAPI['loginOption'] = 1;

	// Send this single LoginAPI
	$serializedObj = json_encode($LoginAPI);
	$targetURL = $thisDomain.'Software/ResultsManager/web/amfphp/services/BulkImportGateway.php';
	if ($debugLog)
		error_log("to BulkImportGateway with $serializedObj\n", 3, $debugFile);
		
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
    if ($debugLog)
        error_log("back with $contents\n", 3, $debugFile);
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
				error_log("error from BulkImportGateway $errorCode, $failReason\n", 3, $debugFile);
				
		} elseif (isset($returnInfo['user'])){
			
			$userInfo = $returnInfo['user'];
			$username = $userInfo['name'];
            $userType = $userInfo['userType'];
            $userId = $userInfo['userID'];
			
			// Check if they are an administrator
			if ($userType != 2)
                $errorCode = 100;
		} else {
			$errorCode = 1;
		}
		
		// If there are no errors, go to the program
		if ($errorCode == 0) {
			if ($debugLog)
				error_log("going to the program with $prefix\n", 3, $debugFile);

			$rc['redirect']=$thisDomain.$startFolder."importDetails.php?prefix=$prefix&session=" . $returnInfo['sessionId'];
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
	
