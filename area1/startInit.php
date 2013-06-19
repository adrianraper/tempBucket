<?php 

/*
 * Initialisation for all Start.php files in area1
 */
	if (isset($_GET['session']))
		session_id($_GET['session']);
	session_start();
	$currentSessionID = session_id();
	
	$username = $password = $extraParam = $licenceFile = $prefix = $version = '';
	$studentID = $email = $userID = $instanceID = '';
	$referrer = $ip = $server = $productCode = $accountName = '';

	$locationFile = "location.txt";
	$courseFile='course.xml';
	