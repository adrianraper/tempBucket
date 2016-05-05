<?php 

/*
 * Initialisation for all Start.php files in area1
 */
	date_default_timezone_set("UTC");
	// gh#1314 This can be removed once all start pages link to v27 Bento apps
	if (isset($_GET['session']))
		session_id($_GET['session']);
	session_start();
	$currentSessionID = session_id();
	
	$userName = $password = $extraParam = $licenceFile = $version = '';
	$studentID = $email = $userID = $instanceID = '';
	$referrer = $ip = $server = $productCode = $accountName = '';
	$course = $startingPoint = $resize = $navigation = '';

	$locationFile = 'location.txt';
	$courseFile = 'course.xml';
	
	$server = $httpProtocol = '';
	$webShare = '';
	$swfName = 'control.swf';
	$startControl = '/Software/Common/';
	