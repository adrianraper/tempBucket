<?php
    define("DEBUG", "TRUE");
	define('TIMEZONE', 'UTC');
	date_default_timezone_set(TIMEZONE);

	$domain = "http://".$_SERVER['HTTP_HOST'];
	//$adminFolder = "/Admin/";
	$startFolder = "/ItsYourJob/";
	// gh#1241 Configure a content base
	$contentFolder = "$domain/Content/";
	
	//$licenceInfo = parse_ini_file("licence-A.txt");
	//$locationInfo = parse_ini_file("location-A.txt");
	//$locationInfo = parse_setting_file("location-A.txt");
	//$_SESSION['rootID'] = '12878';
	//$_SESSION['groupID'] = '12878';
	//$_SESSION['productCode'] = '38'; #It's your Job product Code

	function parse_setting_file($filename){
		$fileContent = file_get_contents($filename, true);

		$firstArray = explode("&", $fileContent);
		foreach($firstArray as $value){
			$tmpArray = explode("=", $value);
			$outArray[$tmpArray[0]] = $tmpArray[1];
		}
		//foreach ($outArray as $k => $v) {
		//    echo "\$outArray[$k] => $v.\r\n";
		//}
		//echo $outArray[$key];
		return $outArray;
	}