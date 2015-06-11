<?php
    //define('DEBUG', true);
	define('TIMEZONE', 'UTC');
	date_default_timezone_set(TIMEZONE);

	$domain = "http://".$_SERVER['HTTP_HOST'];
	//$adminFolder = "/Admin/";
	$startFolder = "/ItsYourJob/";
	// gh#1241 Configure a content base
	$contentFolder = "$domain/Content/";
	
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