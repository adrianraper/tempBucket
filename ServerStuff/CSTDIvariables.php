<?php

	$domain = "http://dock.fixbench/";
	//$domain = "http://claritymain/";
	//$domain = "http://claritydevelop/";
	//$domain = "http://www.ClarityEnglish.com/";
	$debugSettings = true;

	$dbHost = 2;
	$prefix = "CSTDI";
	$rootID = 14449;
	$groupID = 26271;
	$city = "Hong Kong";
	$country = "Hong Kong";
	$loginOption = 2;
	$subscriptionPeriod = "1y";
	
	function redirect ($url) {
		header('Location: ' . $url);
		exit;
	}

?>