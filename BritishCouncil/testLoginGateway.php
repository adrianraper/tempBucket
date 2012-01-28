<?php

	header('Content-Type: text/html; charset=utf-8');
	// For testing Email API
	
	$commonDomain  = 'http://dock.projectbench/'; 

	$studentID = "1217-0552-6016";
	$name = "Adrian Raper"; //senders name
	$email = "support@ieltspractice.com"; //senders e-mail adress
	$dbHost = 2;
	$productCode = 52;
	$expiryDateStr = '2012-04-15 23:59:59';
	$prefix = "BCHK";
	$groupID = "170";
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
	$LoginAPI['productCode'] = $productCode;
	$LoginAPI['expiryDate'] = $expiryDateStr;
	$LoginAPI['prefix'] = $prefix;
	$LoginAPI['groupID'] = $groupID;
	$LoginAPI['city'] = $city;
	$LoginAPI['country'] = $country;
	$LoginAPI['loginOption'] = $loginOption;
			
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