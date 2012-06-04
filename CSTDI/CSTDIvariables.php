<?php

	$domain = "http://dock.projectbench/";
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
	$adminPassword = "57845612";
	
	function redirect ($url) {
		header('Location: ' . $url);
		exit;
	}

?>