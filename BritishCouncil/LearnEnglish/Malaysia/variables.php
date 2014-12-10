<?php
	$thisDomain = 'http://'.$_SERVER['HTTP_HOST'].'/';
	$commonDomain = 'http://www.clarityenglish.com/';
	$startFolder = "BritishCouncil/LearnEnglish/Malaysia/";
	
	if (strpos($thisDomain, "dock")!==false) {
		$prefix = "BCLEMY";
		$rootID = "14484";
		$groupID = "26317";
	} elseif (strpos($thisDomain, "claritydevelop")!==false) {
		$prefix = "BCLEMY";
		$rootID = "14214";
		$groupID = "22733";
	} else {
		$prefix = "BCLEMY";
		$rootID = "14987";
		$groupID = "29247";
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
