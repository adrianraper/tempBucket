<?php
	$thisDomain = 'http://'.$_SERVER['HTTP_HOST'].'/';
	$commonDomain = 'http://www.clarityenglish.com/';
	$startFolder = "BritishCouncil/LearnEnglish/MENA/";
	
	if (strpos($thisDomain, "dock")!==false) {
		$prefix = "BCLEMENA";
		$rootID = "14484";
		$groupID = "26317";
	} elseif (strpos($thisDomain, "192.168.8.82")!==false) {
		$prefix = "BCLEMENA";
		$rootID = "26082";
		$groupID = "48255";
	} else {
		$prefix = "BCLEMENA";
		$rootID = "33662";
		$groupID = "61607";
	}
	$dbHost = 2;

	date_default_timezone_set("UTC");
	
	// you can set the expiry date to a fixed one, or a period from now
	//$expiryDate = '2012-05-30';
	$expiryDate = strftime('%Y-%m-%d %H:%M:%S', strtotime("+1 months"));
	
	// Will we write out lots of log messages?
	$debugLog = true;
	$debugFile = "debug.log";
	
	// types of login $vars['LOGINOPTION']
	$searchType = 1; // name 
	$searchType = 2; // id
	$searchType = 4; // both
	$searchType = 8; // Email 
	$searchType = 64; // UserID 
?>
