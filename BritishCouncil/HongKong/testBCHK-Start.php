<?php
	session_start();
	date_default_timezone_set('UTC');

	$name = $password = $extraParam = $licenceFile = $prefix = $version = '';
	$studentID = $email = $instanceID = $userID = '';
	$referrer = $ip = $server = $productCode = '';
	
	//$thisDomain = 'http://'.$_SERVER['HTTP_HOST'].'/';
	$thisDomain = 'http://dock.projectbench/';
	$commonDomain = 'http://dock.projectbench/';
	$startFolder = "BritishCouncil/RoadToIELTS/";
	$configFile = 'config.xml';
	
	$swfName = 'IELTSApplication.swf';
	$webShare = '';
	$startControl = "$thisDomain$webShare/Software/ResultsManager/web/";
	
	$fileContents = file_get_contents($configFile);
	$configXML = simplexml_load_string($fileContents);
	$dbHost = (string) $configXML->dbHost[0];
	$prefix = (string) $configXML->prefix[0];
	$rootID = (string) $configXML->rootID[0];
	$groupID = (string) $configXML->groupID[0];
	$loginOption = (string) $configXML->loginOption[0];

	// Will we write out lots of log messages?
	$debugLog = true;
	
	// Decrypt the passed parameters	
	$name = $_GET['n'];
	$email = $_GET['e'];
	$encrypt = $_GET['d'];
	
	$pattern = '/\(AT\)/';
	$replacement = '@';
	$email = preg_replace($pattern, $replacement, $email);
	$pattern = '/ /';
	$replacement = '+';
	$encrypt = preg_replace($pattern, $replacement, $encrypt);
	
	$passwordStr = $name."-&-".$email; 

	// Don't do any kind of decryption if the strings are empty
	if (strlen($name)==0 || strlen($email)==0 || strlen($encrypt)==0) {
		$validLink = false;
		//$logStr=$nowTime." n=".$ename."&e=".$emailat."&d=".$encrypt."\r\n";
	} else {
		// Do the decryption that is passed to you
		$fullDecrypt = decrypt3DES(buildPasswordHash($passwordStr), base64_decode(decodeCharacters($encrypt)));
		//echo $fullDecrypt;
	
		// See if the passed parameters match
		parse_str($fullDecrypt, $agre);
		//$calcEname = preg_replace($pattern, $replacement, $n);
		$calcName = $agre['n'];
		$calcEmail = $agre['e'];
		//echo "passed name=".$ename." calc name=".$calcEname;
		if ($calcEmail==$email && $calcName==$name) {
			// they match, so pick up the other parameters and convert for Road to IELTS use.
			$studentID = $agre['i'];
			$examDateStr = $agre['t'];
			// When PHP 5.3 running
			//$examDate = date_create($examDateStr);
			//$expiryDate = date_add($examDate,new DateInterval("P1M"));
			$examDate = strtotime($examDateStr);
			$expiryDate = mktime(0,0,0,date("m",$examDate),date("d",$examDate)+7,date("Y",$examDate));
			$expiryDateStr = date('Y-m-d 23:59:59', $expiryDate);
			$programVersion = $agre['m'];
			if ($programVersion=="Academic") {
				$productCode=52;
			} else {
				$productCode=53;
			}
			// Set a couple of defaults
			$validLink = true;
			
			// V2 We will be logging in using studentID as unique, but we don't really know that all BC centres will use unique
			// ids in the protal - so best to add the groupID to all studentIDs coming through this portal.
			$uniqueStudentID = $studentID.'-'.$groupID;
			
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
			
			switch($errorCode) {
				case '206':
				case '203':
				case '210':
					break;
				case '204':
					$failReason = "Wrong password";
					break;
				case '208':
					$failReason = "User expired";
					break;
				default:
					// If no error, then get user information
					if (isset($returnInfo['user'])) {
						$userID = $returnInfo['user']['userID'];
					} else {
						$errorCode = 1;
						$failReason = "Unknown reason";
					}
					break;
			}
			
		} else {
			$validLink = false;
			//$logStr = $nowTime." invalid name=".$ename." calcName=".$calcEname." email=".$email." calcEmail=".$calcEmail ."\r\n";
		}
	}
	//error_log($logStr, 3, "/tmp/Login.log");

	echo $contents;
	if (isset($returnInfo['user'])) {
		echo " userID is ".$returnInfo['user']['userID'];
	}
	
	exit(0);

function buildPasswordHash($str) {
	$pass0sha1 = sha1($str, true); // get 20 digit hash
	$password = base64_encode($pass0sha1); // nFXx CBo/ xe00 3MNw QbXK UwLf ECU= // This is 28 characters
	return sha1($password, true);
}
function encrypt3DES($key, $text){
	$td = mcrypt_module_open (MCRYPT_3DES, '', MCRYPT_MODE_CBC, '');
	$vector = mcrypt_encrypt(MCRYPT_3DES,$key,"\0\0\0\0\0\0\0\0",MCRYPT_MODE_ECB);
	mcrypt_generic_init ($td, $key, $vector);
	$encrypted = mcrypt_generic ($td, $text);
	mcrypt_generic_deinit($td);
	mcrypt_module_close($td);
	return $encrypted;
}
function decrypt3DES($key, $text){
	//$text = str_replace("\x0", "", $text);
	$td = mcrypt_module_open (MCRYPT_3DES, '', MCRYPT_MODE_CBC, '');
	$vector = mcrypt_encrypt(MCRYPT_3DES,$key,"\0\0\0\0\0\0\0\0",MCRYPT_MODE_ECB);
	mcrypt_generic_init ($td, $key, $vector);
	//$decrypted = rtrim(mdecrypt_generic ($td, $text),"\x0");
	$decrypted = mdecrypt_generic($td, $text);
	mcrypt_generic_deinit($td);
	mcrypt_module_close($td);
	return $decrypted;
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
?> 
