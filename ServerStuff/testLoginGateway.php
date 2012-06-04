<?php

	header('Content-Type: text/html; charset=utf-8');
	// For testing Login API
	
	$clarityDomain  = 'http://p4.clarityenglish.com/';
	//$clarityDomain  = 'http://claritydevelop/';
	//$clarityDomain  = 'http://dock.projectbench/';

	// Mandatory fields to pass
	$name = "Kima 133";
	$prefix = "WHC";
	$loginOption = 1; // This is for name based login. 2=studentID login.
	$adminPassword = "xetfisthis";

	// Optional field if you want to put the user into a particular group.
	// If the group doesn't exist it will be created at the top level in the account.
	$groupName = "Winhoe autogroup 3";
	
	// Optional fields if you want to link a teacher to this group
	// If this teacher doesn't exist, there will be no error
	// If the student already exists, no attempt will be made to link this teacher to the student's group
	$teacherName = "Wendy";
	
	// Optional information about the student
	$email = "xxx";
	$studentID = "xxx";
	$country = "xxx";
	$city = "xxx";
	
	// Query the database to see if this user already exists
	// Use LoginGateway
	$LoginAPI = array();
	$LoginAPI['method'] = 'getOrAddUserAutoGroup';
	$LoginAPI['name'] = $name;
	$LoginAPI['prefix'] = $prefix;
	$LoginAPI['loginOption'] = $loginOption;
	$LoginAPI['adminPassword'] = $adminPassword;
	$LoginAPI['groupName'] = $groupName;
	$LoginAPI['teacherName'] = $teacherName;
	$LoginAPI['email'] = $email;
	$LoginAPI['studentID'] = $studentID;
	$LoginAPI['city'] = $city;
	$LoginAPI['country'] = $country;
			
	// Send this single LoginAPI
	$serializedObj = json_encode($LoginAPI);
	$targetURL = $clarityDomain.'Software/ResultsManager/web/amfphp/services/LoginGateway.php';
	//echo $serializedObj;

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
		echo 'Curl error: ' . curl_error($ch);
		curl_close($ch);
	} else {
		curl_close($ch);
		// $contents is coming back with a utf-8 BOM in front of it, which invalidates it as JSON. Get rid of it.
		if (substr($contents,0,3)==b"\xEF\xBB\xBF") {
			$contents = substr($contents,3);
		}
		$returnInfo = json_decode($contents, true);

		// Expecting to get back an error or a user object
		if (isset($returnInfo['error'])){
			$errorCode = $returnInfo['error'];
			$errorMsg = $returnInfo['message'];
			//header( 'Location: '.$failurePage.'?'.$returnedInfo );
		} else {
			$errorCode = 0;
		}
	}
	echo $contents;
	if (isset($returnInfo['user'])) {
		echo " userID is ".$returnInfo['user']['userID'];
	}
	
	exit(0);

?>