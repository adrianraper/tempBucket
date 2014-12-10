<?php
	$thisDomain = 'http://'.$_SERVER['HTTP_HOST'].'/';
	$commonDomain = 'http://dock.projectbench/';
	$startFolder = "BritishCouncil/LearnEnglish/Chile/UTalca/";
	
	$prefix = "TALCA";
	$rootID = "29130";
	$dbHost = 2;
	$language = "Spanish";

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
