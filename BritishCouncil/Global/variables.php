<?php
	$thisDomain = 'http://'.$_SERVER['HTTP_HOST'].'/';
	$commonDomain = 'http://'.$_SERVER['HTTP_HOST'].'/';
	$oldDomain = 'http://'.$_SERVER['HTTP_HOST'].'/';
	//$thisDomain = 'http://www.roadtoielts.com/';
	//$commonDomain = 'http://www.clarityenglish.com/';
	//$oldDomain = 'http://www.ieltspractice.com/';
	$startFolder = "BritishCouncil/Global/";

	$dbHost = 101;
	$oldDbHost = 100;
	
	// For loginGateway
	$adminPassword = 'clarity88';
	
	date_default_timezone_set("UTC");
	
	// Will we write out lots of log messages?
	$debugLog = true;
	$debugFile = "ORS_start.log";

?>
