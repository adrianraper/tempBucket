<?php

	session_start();
	$currentSessionID = session_id();

	include_once "variables.php";

	// New Global start page for links from ORS
	// Use this when ready to start live

	$name = $password = $extraParam = $licenceFile = $prefix = $version = '';
	$studentID = $email = $instanceID = $userID = '';
	$referrer = $ip = $server = $productCode = '';

	$configFile = 'config.xml';

	$fileContents = file_get_contents($configFile);
	$configXML = simplexml_load_string($fileContents);
	$dbHost = (string) $configXML->dbHost[0];
	$prefix = (string) $configXML->prefix[0];
	$rootID = (string) $configXML->rootID[0];
	$groupID = (string) $configXML->groupID[0];
	$loginOption = (string) $configXML->loginOption[0];
	// For ORS, country comes from the encrypted string, plus testCentre
	// $country = (string) $configXML->country[0];
	$emailTemplate = "ORS-welcome";

	// Decrypt the passed parameters
	$name = $_GET['n'];
	$email = $_GET['e'];
	$encrypt = $_GET['d'];

	if ($debugLog) {
		error_log("starting Start.php with $name\n", 3, $debugFile);
	}

	$pattern = '/\(AT\)/';
	$replacement = '@';
	$email = preg_replace($pattern, $replacement, $email);
	$pattern = '/\+/';
	$replacement = ' ';
	$name = preg_replace($pattern, $replacement, $name);
	$pattern = '/ /';
	$replacement = '+';
	$encrypt = preg_replace($pattern, $replacement, $encrypt);

	$name = urldecode($name);
	$passwordStr = $name."-&-".$email;
	// To cope with double encryption during 302 redirect

	// Don't do any kind of decryption if the strings are empty
	if (strlen($name)==0 || strlen($email)==0 || strlen($encrypt)==0) {
		$validLink = false;
		//$logStr=$nowTime." n=".$ename."&e=".$emailat."&d=".$encrypt."\r\n";
	} else {
		// Do the decryption that is passed to you
		$fullDecrypt = decrypt3DES(buildPasswordHash($passwordStr), decodeCharacters($encrypt));

		// See if the passed parameters match
		parse_str($fullDecrypt, $agre);
		//$calcEname = preg_replace($pattern, $replacement, $n);
		$calcName = $agre['n'];
		$calcEmail = $agre['e'];
		//echo "passed name=".$ename." calc name=".$calcEname;
		if ($calcEmail==$email && $calcName==$name) {
			// they match, so pick up the other parameters and convert for Road to IELTS use.
			//$text = "i=".$ID."&m=".$TestModule."&t=".$ExamDate."&n=".$Name."&e=".$Email."&tc=".$Test_Centre."&c=".$Country;
			$testCentre = $agre['tc'];
			$country = $agre['c'];
			if ($country == "Malayise") $country = "Malaysia";
			if ($country == "philippines") $country = "Philippines";
			if (strpos($country, 'Russia') !== false) $country = "Russia";
			if (strpos($country, 'Moscow') !== false) $country = "Russia";
			$studentID = $agre['i'];
			$examDateStr = $agre['t'];
			// When PHP 5.3 running
			//$examDate = date_create($examDateStr);
			//$expiryDate = date_add($examDate,new DateInterval("P1M"));
			$examDate = strtotime($examDateStr);
			$expiryDate = mktime(0,0,0,date("m",$examDate),date("d",$examDate)+7,date("Y",$examDate));
			$expiryDateStr = date('Y-m-d 23:59:59', $expiryDate);

			// Check if this is more than 3 months away, if it is, set 3 month as expiry

			$programVersion = $agre['m'];
			//if ($programVersion=="Academic") {
			if (strpos($programVersion, 'Academic') !== false) { //edited by Sky to handle UKVI case which $agre['m'] is "IELTS for UKVI(Academic)"
				$programVersion = 'AC';
				$productCode=52;
			} else {
				$programVersion = 'GT';
				$productCode=53;
			}
			// Set a couple of defaults
			$validLink = true;
			$uniqueStudentID = $studentID;

			// Use LoginGateway to get back this user, or add them with all their details
			$LoginAPI = array();
			$LoginAPI['method'] = 'getOrAddUser';
			$LoginAPI['studentID'] = $uniqueStudentID;
			$LoginAPI['name'] = $name;
			$LoginAPI['email'] = $email;
			$LoginAPI['dbHost'] = $dbHost;
			$LoginAPI['productCode'] = $productCode;
			$LoginAPI['expiryDate'] = $expiryDateStr;
			$LoginAPI['prefix'] = $prefix;
			$LoginAPI['rootID'] = $rootID;
			$LoginAPI['groupID'] = $groupID;
			$LoginAPI['loginOption'] = $loginOption;
			$LoginAPI['emailTemplateID'] = $emailTemplate;
			$LoginAPI['country'] = $country;
			$LoginAPI['city'] = $testCentre;
			$LoginAPI['adminPassword'] = $adminPassword;
			$LoginAPI['registerMethod'] = 'ORS-portal';
			$LoginAPI['birthday'] = $examDateStr . " 00:00:00";
			// Send this single LoginAPI
			$serializedObj = json_encode($LoginAPI);
			$targetURL = $commonDomain.'Software/ResultsManager/web/amfphp/services/LoginGateway.php';
			if ($debugLog) {
				//error_log("to LoginGateway with $serializedObj\n", 3, $debugFile);
				error_log("to LoginGateway with $name-$email-$country\n", 3, $debugFile);
			}

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
				if ($debugLog) {
					error_log("back from $targetURL with curl_error($ch)\n", 3, $debugFile);
				}
				curl_close($ch);
				$errorCode = 1;
			} else {
				curl_close($ch);
				// $contents is coming back with a utf-8 BOM in front of it, which invalidates it as JSON. Get rid of it.
				if (substr($contents,0,3)==b"\xEF\xBB\xBF") {
					$contents = substr($contents,3);
				}
				$returnInfo = json_decode($contents, true);

				if ($debugLog) {
					error_log("back from LoginGateway with userID=".$returnInfo['user']['userID']."\n", 3, $debugFile);
				}

				// Expecting to get back an error or a user object
				if (isset($returnInfo['error'])){
					$errorCode = $returnInfo['error'];
					$errorMsg = $returnInfo['message'];
					//header( 'Location: '.$failurePage.'?'.$returnedInfo );
				} else {
					$errorCode = 0;
				}

			}

			// TODO: What to do with failure? Should have an error page to use.
			// I can't see any of these codes being sent back...
			switch($errorCode) {
				case 1:
					$failReason = $errorMsg;
					$validLink = false;
					break;
				case '206':
				case '203':
				case '210':
					$failReason = "Invalid details sent to loginGateway";
					$validLink = false;
					break;
				case '204':
					$validLink = false;
					$failReason = "Wrong password";
					break;
				case '208':
					$validLink = false;
					$failReason = "User expired";
					break;
				default:
					// If no error, then get user information
					if (isset($returnInfo['user'])) {
						$userID = $returnInfo['user']['userID'];

						$_SESSION['StudentID'] = $uniqueStudentID;
						$_SESSION['Password'] = $returnInfo['user']['password'];
						$_SESSION['Email'] = $returnInfo['user']['email'];
						// TODO. We are passing studentID as parameter as well as session as Safari sometimes screws up sessions
						// But now we need to send password too as ORS/NEEA don't use passwords but tablet login must.
						// So we need to encrypt the parameter string here and decrypt on the next page.
						$args = "prefix=$prefix&session=$currentSessionID&studentID=$uniqueStudentID&password=".$returnInfo['user']['password'].'&padding=00000000000000000000000000';

						$key = '123457980123457890';
						$key = sha1($key, true); // get 20 digit hash
						$key = base64_encode($key); // nFXx CBo/ xe00 3MNw QbXK UwLf ECU= // This is 28 characters

						$iv_size = mcrypt_get_iv_size(MCRYPT_RIJNDAEL_256, MCRYPT_MODE_ECB);
						$iv = mcrypt_create_iv($iv_size, MCRYPT_RAND);
					if (strlen($key)%8 != 0 || strlen($key) == 0) $key .= str_repeat("\0", (8-strlen($key)%8)); //pad with "\0" bytes to make sure the key will have valid size by sky on 09012017
						$encryptedArgs = mcrypt_encrypt(MCRYPT_RIJNDAEL_256, $key, $args, MCRYPT_MODE_ECB, $iv);
						$passedArgs = base64_encode($encryptedArgs);

						$newURL = $thisDomain.'area1/RoadToIELTS2/Start-'.$programVersion.'.php?data='.$passedArgs;
						header('Location: ' . $newURL);
						flush();
						exit();
					} else {
						$errorCode = 1;
						$failReason = "Unknown reason";
					}
					break;
			}

		} else {
			$validLink = false;
			$failReason = "Please contact support@roadtoielts.com as the link to Road to IELTS for your login is failing. n=$name";
			//$logStr = $nowTime." invalid name=".$ename." calcName=".$calcEname." email=".$email." calcEmail=".$calcEmail ."\r\n";
		}
	}
	//error_log($logStr, 3, "/tmp/Login.log");

	$newURL = $thisDomain.'error.htm?msg='.$failReason;
	header('Location: ' . $newURL);
	//echo $failReason;
	flush();
	exit();

function buildPasswordHash($str) {
	$pass0sha1 = sha1($str, true); // get 20 digit hash
	$password = base64_encode($pass0sha1); // nFXx CBo/ xe00 3MNw QbXK UwLf ECU= // This is 28 characters
	return sha1($password, true);
}
function encrypt3DES($key, $text){
	$iv_size = mcrypt_get_iv_size(MCRYPT_3DES, MCRYPT_MODE_ECB);
	$iv = mcrypt_create_iv($iv_size, MCRYPT_RAND);
	if (strlen($key)%8 != 0 || strlen($key) == 0) $key .= str_repeat("\0", (8-strlen($key)%8)); //pad with "\0" bytes to make sure the key will have valid size by sky on 09012017
	$encrypt = mcrypt_encrypt(MCRYPT_3DES, $key, $text, MCRYPT_MODE_ECB, $iv);
	$encrypt = trim(base64_encode($encrypt));
	return $encrypt;
}
function decrypt3DES($key, $text){
	$iv_size = mcrypt_get_iv_size(MCRYPT_3DES, MCRYPT_MODE_ECB);
	$iv = mcrypt_create_iv($iv_size, MCRYPT_RAND);
	$text =base64_decode($text);
	if (strlen($key)%8 != 0 || strlen($key) == 0) $key .= str_repeat("\0", (8-strlen($key)%8)); //pad with "\0" bytes to make sure the key will have valid size by sky on 09012017
	$encrypt = mcrypt_decrypt(MCRYPT_3DES, $key, $text, MCRYPT_MODE_ECB, $iv);
	$encrypt = trim($encrypt);
	return $encrypt;
}
function encodeCharacters ($rawText) {
	$pattern = '/\//';
	$replacement = '-';
	$temp = preg_replace($pattern, $replacement, $rawText);
	$pattern = '/=/';
	$replacement = '_';
	$temp = preg_replace($pattern, $replacement, $temp);
	return $temp;
}
function decodeCharacters ($rawText) {
	$pattern = '/-/';
	$replacement = '/';
	$temp = preg_replace($pattern, $replacement, $rawText);
	$pattern = '/_/';
	$replacement = '=';
	$temp = preg_replace($pattern, $replacement, $temp);
	return $temp;
}
