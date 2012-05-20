﻿<?php
session_start();

// Use exceptions to handle unexpected errors (like parameters not being passed)
try {

	$domain = 'http://'.$_SERVER['SERVER_NAME'].'/';
	$domain = 'http://www.ClarityEnglish.com/';
	$dbHost = 2;
	$startDate = '2012-05-01';
	
	// Use QueryGateway to run a query on the database
	$API = array();
	$API['method'] = 'getSubscriptions';
	
	// The first few data are fixed for CSTDI on CE.com
	$API['dbHost'] = $dbHost;
	$API['startDate'] = $startDate;
			
	// Send this single API
	$serializedObj = json_encode($API);
	$targetURL = $domain.'Software/ResultsManager/web/amfphp/services/internalQueries.php';
	// echo $serializedObj;

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

} catch (Exception $e) {
	header("Content-Type: text/xml");
	echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?><db>";
	echo "<action errorCode='100' errorMsg='{$e->getMessage()}' />";
	echo "</db>";
}

exit(0);
