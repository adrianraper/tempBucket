<?php
	//==========Begin of Enviroment Setting==========
	/*
	// Now from Variables.php
	$domain = "http://www.ieltspractice.com/BritishCouncil";
	$commonDomain = "http://www.clarityenglish.com/";
	$adminFolder = "/Admin/";
	$startFolder = "/RoadToIELTS/";
	$licenceInfo = parse_ini_file("licence-A.txt");
	//$locationInfo = parse_ini_file("location-A.txt");
	$locationInfo = parse_setting_file("location-A.txt");
	
	$STAGEONETIME = strtotime("2009-07-01 00:00:00");
	$STAGETWOTIME = strtotime("2009-10-01 00:00:00");
	$STAGETHREETIME = strtotime("2010-01-01 00:00:00");
	$STAGEFOURTIME = strtotime("2010-04-01 00:00:00");
	$STAGEONETIME2 = strtotime("2010-07-01 00:00:00");
	// We need change the same rotation to card registration
	// Changed at 16/08/2010	
	$STAGETWOTIME2 = strtotime("2010-12-01 00:00:00");
	$STAGETHREETIME2 = strtotime("2011-03-01 00:00:00");
	$STAGEFOURTIME2 = strtotime("2011-06-01 00:00:00");
	*/ 
	//==========End of Enviroment Setting==========
	//==========Begin of function for post to server==========
	function redirect ($url) {
		header('Location: ' . $url);
		exit;
	}
	function sendAndLoad($postXML, &$contents) {
		global $domain;
		global $commonDomain;
		global $startFolder;
		/**
		* Initialize the cURL session
		*/
		$ch = curl_init();
		//curl_setopt($ch, CURLOPT_HEADER, 1);
		curl_setopt($ch, CURLOPT_FAILONERROR, 1); 
		/**
		* Set the URL of the page or file to download.
		*/
		$targetURL = $commonDomain."Software/Common/Source/SQLServer/runProgressQuery.php";
		curl_setopt($ch, CURLOPT_URL, $targetURL);
		/**
		* Ask cURL to return the contents in a variable
		* instead of simply echoing them to the browser.
		*/
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		/**
		* Setup the post variables
		*/
		curl_setopt($ch, CURLOPT_POST, 1);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $postXML);
		/**
		* Execute the cURL session
		*/
		$contents = curl_exec ($ch);
		//echo $contents;
		/**
		* Close cURL session
		*/
		curl_close ($ch);
	}
	//Function to use at the start of an element
	function start($parser, $element_name, $element_attrs){
		global $userInfo;
		global $errorInfo;
		switch(strtoupper($element_name)) {
			case "NOTE":
				break; 
			case "USER":
				$userInfo = $element_attrs;
				break;
			case "ERR":
				$errorInfo = $element_attrs;
				break; 
		}
	}
	//Function to use at the end of an element
	function stop($parser,$element_name)  {
	}
	/*
	// In Variables
	function parse_setting_file($filename){
		$fileContent = file_get_contents($filename, true);
		
		$firstArray = explode("&", $fileContent);
		foreach($firstArray as $value){
			$tmpArray = explode("=", $value);
			$outArray[$tmpArray[0]] = $tmpArray[1];
		}
		return $outArray;
	}
	*/
	//==========End of function for post to server==========
?>
