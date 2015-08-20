<?php
	$thisDomain = 'http://'.$_SERVER['HTTP_HOST'].'/';
	$commonDomain = 'http://www.clarityenglish.com/';
	$startFolder = "area1/ResultsManager/";
	
	$dbHost = 2;

	date_default_timezone_set("UTC");
	
	// Will we write out lots of log messages?
	$debugLog = true;
	$debugFile = "debug.log";
	
