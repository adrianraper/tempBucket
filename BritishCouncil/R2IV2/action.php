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
		$loginID= $_POST['loginID'];
	} else if (isset($_GET['loginID'])) {
		$loginID= $_GET['loginID'];
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
	
	// Build a hash of the loginID and save as a special password
	$ctx = hash_init('sha1');
	hash_update($ctx, $loginID);
	$hashPassword = substr(hash_final($ctx), 0, 8);
	$hashPassword = strtoupper($hashPassword);
	
	// Process the loginID to get the productCode, groupID and studentID
	$pattern = '/-/';
	$replacement = '';
	$parseID = preg_replace($pattern, $replacement, $loginID);
	$productCode = substr($parseID, 0, 2);
	if ($productCode == '52' || $productCode == '12'){
		$programVersion = 'AC';
	} else if ($productCode == '53' || $productCode == '13'){
		$programVersion = 'GT';
	} else {
		// Assume that you have always been called from ajax, so return errors don't do redirect from here
		// redirect($thisDomain.$startFolder."login.php?login=failed&error=201&message=product code&loginID=$loginID");
		$rc['error']=201;
		$rc['message']='invalid product code';
		print json_encode($rc);
		exit();
	}
	$groupID = substr($parseID, 2, 3);
	if(!is_numeric($groupID)){
		//redirect($thisDomain.$startFolder."login.php?login=failed&code=202&message=group id&loginID=$loginID");
		$rc['error']=202;
		$rc['message']='invalid group id';
		print json_encode($rc);
		exit();
	}
	
	$uniqueStudentID = $loginID;
	
	// Use LoginGateway to get back this user.
	$LoginAPI = array();
	$LoginAPI['method'] = 'getUser';
	$LoginAPI['studentID'] = $uniqueStudentID;
	$LoginAPI['groupID'] = $groupID;
	$LoginAPI['dbHost'] = $dbHost;
	$LoginAPI['loginOption'] = 2;

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

		if ($debugLog)
			error_log("back from LoginGateway with $contents\n", 3, $debugFile);

		// Expecting to get back an error or a user object
		if (isset($returnInfo['error'])){
				
			$errorCode = $returnInfo['error'];
			$failReason = $returnInfo['message'];
			
			if ($errorCode == 200) {
				// This is a new user, in which case the password they typed must match the hash of the id.
				if ($hashPassword == strtoupper($typedPassword)) {
					// The following is all decoded from the serial number, so save it
					$_SESSION['loginID'] = $loginID;
					$rc['redirect'] = $thisDomain.$startFolder."addUser.php";
					print json_encode($rc);
					exit();
				} else {
					if ($debugLog) {
						error_log(" Wrong password, should be $hashPassword but is $typedPassword\n", 3, $debugFile);
					}
					$errorCode = 209;
					$failReason = "Wrong hash password";
				}
			}

		} elseif (isset($returnInfo['user'])){
							
			$userInfo = $returnInfo['user'];
			if (isset($userInfo['expiryDate']))
				$expiryDate = $userInfo['expiryDate'];				
		
			// We didn't have a prefix before getting this user details, so check that we have one now
			if (isset($returnInfo['account'])){
				$accountInfo = $returnInfo['account'];
				$password = $userInfo['password'];
				$_SESSION['Password'] = $password;
				$_SESSION['StudentID'] = $uniqueStudentID;
				$prefix = $accountInfo['prefix'];
				
				// Check that the password matches and the user's account has not expired
				if ($password != htmlspecialchars($typedPassword, ENT_QUOTES, 'UTF-8')) {
					$errorCode = 204; // Wrong password
					if ($debugLog)
						error_log(" Wrong password typed, should be $password but is $typedPassword\n", 3, $debugFile);
						
				} else if (isset($expiryDate) && strtotime($expiryDate) < time()) {
					$errorCode = 206; 
					$failReason = 'Your account expired on ' + $expiryDate;
					if ($debugLog)
						error_log("User expired on $expiryDate\n", 3, $debugFile);
						
				} else {
					$errorCode = 0;
				}
			} else {
				$errorCode = 300; // No known account
			}
		} else {
			if ($debugLog)
				error_log("Got nothing\n", 3, $debugFile);
				
			$errorCode = 1;
		}
		
		// If you there are no errors, go to the program
		if ($errorCode == 0) {
			$rc['redirect']="$thisDomain/area1/RoadToIELTS2/Start-$programVersion.php?prefix=$prefix";
			print json_encode($rc);
			exit();
		}
			
		// Errors handled at the end of the script
	}
	
// This is the method called after the candidate has typed in their details on addUser screen
} else if ($queryMethod=="addNewUser") {

	// We know we are sent a loginID and a password
	if (isset($_POST['loginID'])) {
		$loginID= $_POST['loginID'];
	} else if (isset($_GET['loginID'])) {
		$loginID= $_GET['loginID'];
	} else {
		$loginID = "";
	}
	
	if (isset($_POST['password'])) {
		$password = $_POST['password'];
	} else if (isset($_GET['password'])) {
		$password = $_GET['password'];
	} else {
		$password = "";
	}
	
	if (isset($_POST['learnerName'])) {
		$learnerName = $_POST['learnerName'];
	} else if (isset($_GET['learnerName'])) {
		$learnerName = $_GET['learnerName'];
	} else {
		$learnerName = "";
	}

	if (isset($_POST['email'])) {
		$email = $_POST['email'];
	} else if (isset($_GET['email'])) {
		$email = $_GET['email'];
	} else {
		$email = "";
	}

	if (isset($_POST['expiryDate'])) {
		$expiryDate = $_POST['expiryDate'];
	} else if (isset($_GET['expiryDate'])) {
		$expiryDate = $_GET['expiryDate'];
	} else {
		$expiryDate = "";
	}

	// Process the loginID to get the productCode, groupID and studentID
	$pattern = '/-/';
	$replacement = '';
	$parseID = preg_replace($pattern, $replacement, $loginID);
	$productCode = substr($parseID, 0, 2);
	$groupID = substr($parseID, 2, 3);	
	$uniqueStudentID = $loginID;
	if ($productCode == '52' || $productCode == '12'){
		$programVersion = 'AC';
	} else if ($productCode == '53' || $productCode == '13'){
		$programVersion = 'GT';
	}
	
	// Use LoginGateway to add this user.
	$LoginAPI = array();
	$LoginAPI['method'] = 'getOrAddUser';
	$LoginAPI['studentID'] = $uniqueStudentID;
	$LoginAPI['name'] = htmlspecialchars($learnerName, ENT_QUOTES, 'UTF-8');
	$LoginAPI['password'] = htmlspecialchars($password, ENT_QUOTES, 'UTF-8');
	$LoginAPI['email'] = $email;
	$LoginAPI['groupID'] = $groupID;
	$LoginAPI['productCode'] = $productCode;
	if (!$expiryDate || $expiryDate=='') {
		$LoginAPI['subscriptionPeriod'] = '3m';
	} else {
		$LoginAPI['expiryDate'] = $expiryDate;
	}
	switch ($groupID) {
		// Hong Kong
		case '168':
			$template = 'Welcome-BCHK-user';
			break;
		default:
			$template = 'Welcome-BC-user';
			break;
	}
	$LoginAPI['emailTemplateID'] = $template;
	$LoginAPI['adminPassword'] = 'clarity88';
	$LoginAPI['dbHost'] = $dbHost;
	$LoginAPI['loginOption'] = 2;

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
				error_log("going to the program $programVersion for $prefix\n", 3, $debugFile);
				
			$rc['redirect']=$thisDomain."area1/RoadToIELTS2/Start-$programVersion.php?prefix=$prefix";
			print json_encode($rc);
			exit();
		}
		
		// Errors handled at the end of the script
	}
	
} else if ($queryMethod=="forgotPassword") {
	
	// We know we are sent a loginID and a password
	if (isset($_POST['loginID'])) {
		$loginID= $_POST['loginID'];
	} else if (isset($_GET['loginID'])) {
		$loginID= $_GET['loginID'];
	} else {
		$loginID = "";
	}
	
	// Process the loginID to get the productCode, groupID and studentID
	$pattern = '/-/';
	$replacement = '';
	$parseID = preg_replace($pattern, $replacement, $loginID);
	$groupID = substr($parseID, 2, 3);	
	$uniqueStudentID = $loginID;
	
	// Use LoginGateway to send an email to this user.
	$LoginAPI = array();
	$LoginAPI['method'] = 'forgotPassword';
	$LoginAPI['studentID'] = $uniqueStudentID;
	$LoginAPI['groupID'] = $groupID;
	$LoginAPI['dbHost'] = $dbHost;
	$LoginAPI['loginOption'] = 2;
	$LoginAPI['emailTemplateID'] = 'R2IV2-forgot-password';

	// Send this single LoginAPI
	$serializedObj = json_encode($LoginAPI);
	$targetURL = $commonDomain.'Software/ResultsManager/web/amfphp/services/LoginGateway.php';
	if ($debugLog)
		error_log("to LoginGateway with $serializedObj\n", 3, $debugFile);
	
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

		// Expecting to get back an error or a success (empty user) object
		if (isset($returnInfo['error'])){
			$errorCode = $returnInfo['error'];
			$failReason = $returnInfo['message'];
			
		} elseif (isset($returnInfo['user'])){
			if ($debugLog)
				error_log("got empty user\n", 3, $debugFile);
				
			$errorCode = 0;
			$failReason = 'Email sent';
			
		} else {
			$errorCode = 1;
		}
		
	}
	
	
}

$rc = array();
$rc['error']=$errorCode;
$rc['message']=$failReason;
print json_encode($rc);
exit();
	
