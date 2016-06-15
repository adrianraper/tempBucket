<?php 

/*
 * Initialisation for all Start.php files in area1
 */
	date_default_timezone_set("UTC");
	
    // gh#1314 session id set after any passed parameters are decrypted in readPassedVariables.php
    
	$userName = $password = $extraParam = $licenceFile = $prefix = $version = '';
	$studentID = $email = $userID = $instanceID = '';
	$referrer = $ip = $server = $productCode = $accountName = '';
	$course = $startingPoint = $resize = '';

    $coordsMinWidth = $coordsMaxWidth = $coordsMinHeight = $coordsMaxHeight = 0;
    
	$locationFile = 'location.txt';
	$courseFile = 'course.xml';
	
	$server = $httpProtocol = '';
	$webShare = '';
	$swfName = 'control.swf';
	$startControl = '/Software/Common/';
	