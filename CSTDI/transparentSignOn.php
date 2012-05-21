<?php
session_start();
require_once("CSTDIvariables.php");

// Use exceptions to handle unexpected errors (like parameters not being passed)
try {
	// Main purpose of this page is to link to a Clarity program passing the learner details
	if (isset($_GET['dest'])) {
		$productCode = $_GET['dest'];
	} else {
		throw new Exception("you have not passed a target program");
	}

	if (isset($_POST['UserID'])) {
		$api['UserID'] = htmlentities($_POST['UserID'], ENT_QUOTES);
	} else {
		throw new Exception("you have not passed the UserID");
	}
	if (isset($_POST['FirstName'])) {
		$api['FirstName'] = htmlentities($_POST['FirstName'], ENT_QUOTES);
	} else {
		throw new Exception("you have not passed the FirstName");
	}
	if (isset($_POST['LastName'])) {
		$api['LastName'] = htmlentities($_POST['LastName'], ENT_QUOTES);
	} else {
		throw new Exception("you have not passed the LastName");
	}
	if (isset($_POST['SalCat'])) {
		$api['SalCat'] = $_POST['SalCat'];
	} else {
		throw new Exception("you have not passed the SalCat");
	}
	if (isset($_POST['DeptCode'])) {
		$api['DeptCode'] = $_POST['DeptCode'];
	} else {
		throw new Exception("you have not passed the DeptCode");
	}
	
	// format the data to send
	switch ($productCode) {
		case '10':
		case 'BW':
		case 'BusinessWriting':
			$programFolder = 'BusinessWriting';
			break;
		case '39':
		case 'CP1':
		case 'CP':
		case 'Sounds':
			$programFolder = 'ClearPronunciation';
			break;
		case '50':
		case 'CP2':
		case 'Speech':
			$programFolder = 'ClearPronunciation2';
			break;
		default:
			throw new Exception("The passed program name is not recognised.");
	}
	$studentID = $api['UserID'];
	$name = strtoupper($api['LastName']).', '.$api['FirstName'];
	$custom1 = $api['SalCat'];
	$custom2 = $api['DeptCode'];

	// Use LoginGateway to get or add this user's details
	$LoginAPI = array();
	$LoginAPI['method'] = 'getOrAddUser';
	
	// The first few data are fixed for CSTDI on CE.com
	$LoginAPI['dbHost'] = $dbHost;
	$LoginAPI['prefix'] = $prefix;
	$LoginAPI['rootID'] = $rootID;
	$LoginAPI['groupID'] = $groupID;
	$LoginAPI['city'] = $city;
	$LoginAPI['country'] = $country;
	$LoginAPI['loginOption'] = $loginOption;
	$LoginAPI['subscriptionPeriod'] = $subscriptionPeriod;
	
	// The following come from CLC Plus
	$LoginAPI['studentID'] = $studentID;
	$LoginAPI['name'] = $name;
	$LoginAPI['custom1'] = $custom1;
	$LoginAPI['custom2'] = $custom2;
			
	// Send this single LoginAPI
	$serializedObj = json_encode($LoginAPI);
	$targetURL = $domain.'Software/ResultsManager/web/amfphp/services/LoginGateway.php';
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
		//echo 'Curl error: ' . curl_error($ch);
		$errorCode = 1;
		$errorMsg = curl_error($ch);
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
	// echo $contents;
	if (isset($returnInfo['user'])) {
		// echo " userID is ".$returnInfo['user']['userID'];

		// It would be best to just send Clarity's userID in session, but that isn't picked up by Orchid
		// So use CSTDI UserID, which we know is now a registered user
		$_SESSION['StudentID'] = $studentID;
		//$targetURL = $domain.'area1/'.$programFolder.'/Start.php?prefix=CSTDI&units=bwnj';
		$targetURL = $domain.'area1/'.$programFolder.'/CSTDI-landing.php';

		// Display a landing page which has two links - one for the program and one for the evaluation
		redirect($targetURL);
	}

	if ($errorCode>0) {
		echo "Error: $errorCode, $errorMsg";
	}
	
} catch (Exception $e) {
	header("Content-Type: text/xml");
	echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?><db>";
	echo "<action errorCode='100' errorMsg='{$e->getMessage()}' />";
	echo "</db>";
}

exit(0);
?>