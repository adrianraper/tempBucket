<?php 

/*
 * Initialisation for all Start.php files in area1
 */
	date_default_timezone_set("UTC");
    // gh#1458 If a portal is involved in running the start page, share a common session
    if (isset($_GET['PHPSESSID']) && ($_GET['PHPSESSID']!='')) {
        session_id($_GET['PHPSESSID']);
        // gh#1314 This can be removed once all start pages link to v27 Bento apps
    } elseif (isset($_GET['session'])) {
        session_id($_GET['session']);
    }
	session_start();
	$currentSessionID = session_id();
	
	$userName = $password = $extraParam = $licenceFile = $version = '';
	$studentID = $email = $userID = $instanceID = '';
	$referrer = $ip = $server = $productCode = $accountName = '';
	$course = $startingPoint = $resize = '';

	$locationFile = 'location.txt';
	$courseFile = 'course.xml';
	
	$server = $httpProtocol = '';
	$webShare = '';
	$swfName = 'control.swf';
	$startControl = '/Software/Common/';
	