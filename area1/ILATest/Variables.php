<?php
	require_once("../../Software/Common/lib/php/xml.func.cl.php");

	$domain = "http://www.clarityenglish.com/";
	//$domain = $_SERVER['HTTP_HOST'];
	$startFolder = "area1/ILATest/";
	
	// These settings are domain dependent
	$dbHost = "2";
	if (strpos($domain, "fixbench")!==false) {
		$prefix = "BCILA";
		$rootID = "13236";
		$groupID = "20292";
	} elseif (strpos($domain, "claritymain")!==false) {
		$prefix = "BCILA";
		$rootID = "13562";
		$groupID = "13736";
	} elseif (strpos($domain, "claritydevelop")!==false) {
		$prefix = "BCILA";
		$rootID = "13581";
		$groupID = "13729";
	} elseif (strpos($domain, "bcdev.org.uk")!==false) {
		$prefix = "BCILAEE";
		$rootID = "14028";
		$groupID = "22149";
	} else {
		$prefix = "BCILAEE";
		$rootID = "14079";
		$groupID = "22476";
	}

	$debugSettings = false;
	
	function parse_setting_file($filename){
		$fileContent = file_get_contents($filename, true);
		
		$firstArray = explode("&", $fileContent);
		foreach($firstArray as $value){
			$tmpArray = explode("=", $value);
			$outArray[$tmpArray[0]] = $tmpArray[1];
		}
		return $outArray;
	}

	function redirect ($url) {
		header('Location: ' . $url);
		exit;
	}

	function sendAndLoad($postXML, &$contents) {
		global $domain;
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
		$targetURL = $domain."Software/Common/Source/SQLServer/runProgressQuery.php";
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
?>