<?php 

/*
 * Initialisation for all Start.php files in area1
 */
	date_default_timezone_set("UTC");
	
	if (isset($_GET['session']))
		session_id($_GET['session']);
	session_start();
	$currentSessionID = session_id();
	
	$username = $password = $extraParam = $licenceFile = $prefix = $version = '';
	$studentID = $email = $userID = $instanceID = '';
	$referrer = $ip = $server = $productCode = $accountName = '';
	$course = $startingPoint = $resize = '';

	$locationFile = "location.txt";
	$courseFile='course.xml';
	