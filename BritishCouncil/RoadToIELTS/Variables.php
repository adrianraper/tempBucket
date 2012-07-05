<?php
	$domain = "http://dock.projectbench/BritishCouncil";
	$ipDomain = "http://dock.projectbench/BritishCouncil";
	$adminFolder = "/Admin/";
	$startFolder = "/RoadToIELTS/";
	$licenceInfo = parse_ini_file("licence-A.txt");
	//$locationInfo = parse_ini_file("location-A.txt");
	$locationInfo = parse_setting_file("location-A.txt");
	
	function parse_setting_file($filename){
		$fileContent = file_get_contents($filename, true);
		
		$firstArray = explode("&", $fileContent);
		foreach($firstArray as $value){
			$tmpArray = explode("=", $value);
			$outArray[$tmpArray[0]] = $tmpArray[1];
		}
		return $outArray;
	}
?>
