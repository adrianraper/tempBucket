<?php
	//$thisDomain = 'http://'.$_SERVER['HTTP_HOST'].'/';
	$thisDomain = 'http://dock.projectbench/';
	$commonDomain = 'http://dock.fixbench/';
	$startFolder = "BritishCouncil/RoadToIELTS/";
	// We need to know the dbHost that is used
	$locationInfo = parse_setting_file($commonDomain.$startFolder."location-1.txt");

	//echo $thisDomain.$startFolder;
	// Will we write out lots of log messages?
	$debugLog = false;

	// This controls the three month cycles of the three sets of units.
	$STAGEONETIME = strtotime("2009-03-20 00:00:00");
	$STAGETWOTIME = strtotime("2009-12-01 00:00:00");
	$STAGETHREETIME = strtotime("2010-03-01 00:00:00");
	$STAGEFOURTIME = strtotime("2010-06-01 00:00:00");
	$STAGEONETIME2 = strtotime("2010-09-01 00:00:00");
	$STAGETWOTIME2 = strtotime("2010-12-01 00:00:00");
	$STAGETHREETIME2 = strtotime("2011-03-01 00:00:00");
	$STAGEFOURTIME2 = strtotime("2011-06-01 00:00:00");
	//  Shouldn't really reference stage 4
	$STAGEONETIME3 = strtotime("2011-09-01 00:00:00");
	$STAGETWOTIME3 = strtotime("2011-12-01 00:00:00");
	$STAGETHREETIME3 = strtotime("2012-03-01 00:00:00");
	$STAGEONETIME4 = strtotime("2012-06-01 00:00:00");
	$STAGETWOTIME4 = strtotime("2012-09-01 00:00:00");
	$STAGETHREETIME4 = strtotime("2012-12-01 00:00:00");

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
