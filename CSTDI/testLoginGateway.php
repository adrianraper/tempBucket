<?php

	header('Content-Type: text/html; charset=utf-8');
	// For testing Login API
	
	$commonDomain  = 'http://dock.fixbench/'; 

	$studentID = "cstdi-101";
	$name = "RAPER, Adrian 101";
	$email = "support@ieltspractice.com";
	$dbHost = 2;
	$prefix = "CSTDI";
	$rootID = 14449;
	$groupID = 26271;
	$custom1 = 'Basic';
	$custom2 = "IMD";
	$city = "Hong Kong";
	$country = "Hong Kong";
	$loginOption = 2;
	
	// Query the database to see if this user already exists
	// Use LoginGateway
	$LoginAPI = array();
	$LoginAPI['method'] = 'getOrAddUser';
	$LoginAPI['studentID'] = $studentID;
	$LoginAPI['name'] = $name;
	$LoginAPI['email'] = $email;
	$LoginAPI['dbHost'] = $dbHost;
	$LoginAPI['prefix'] = $prefix;
	$LoginAPI['rootID'] = $rootID;
	$LoginAPI['groupID'] = $groupID;
	$LoginAPI['city'] = $city;
	$LoginAPI['country'] = $country;
	$LoginAPI['loginOption'] = $loginOption;
	$LoginAPI['custom1'] = $custom1;
	$LoginAPI['custom2'] = $custom2;
			
	// Send this single LoginAPI
	$serializedObj = json_encode($LoginAPI);
	$targetURL = $commonDomain.'Software/ResultsManager/web/amfphp/services/LoginGateway.php';
	echo $serializedObj;

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