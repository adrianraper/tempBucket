<?php
	$thisDomain = 'http://'.$_SERVER['HTTP_HOST'].'/';
	$commonDomain = 'http://'.$_SERVER['HTTP_HOST'].'/';
	$startFolder = 'area1/AccessUK/';
	/*$thisDomain = 'http://www.roadtoielts.com/';
	$commonDomain = 'http://www.roadtoielts.com/';*/
	$dbHost = 2;

	date_default_timezone_set("UTC");
	
	$groupID = 27122;
	$groupID = 26304; // for dock.projectbench
	
	// Will we write out lots of log messages?
	$debugLog = true;
	$debugFile = "York.log";
	
?>
