<?php
	session_start();
	$userName = $password = $extraParam = $licenceFile = $prefix = $version = '';
	$studentID = $Email = $email = $userID = $instanceID = '';
	$referrer = $ip = $server = $productCode = '';

	// For this product
	$productCode = 52; // RoadToIELTS 2
	$swfName = 'RoadToIELTS.swf';
	$webShare = '';
	$startControl = "$webShare/Software/ResultsManager/web/";

	// If we do not know the prefix, the page shouldn't run.
	// The prefix might come from session variables or from the URL parameters
	// Read URL first in case session variables are lingering
	// allow case insensitive parameters
	if (isset($_GET['prefix'])) {
		$prefix = $_GET['prefix'];
	} elseif (isset($_GET['Prefix'])) {
		$prefix = $_GET['Prefix'];
	} elseif (isset($_SESSION['Prefix'])) {
		$prefix = $_SESSION['Prefix'];
	} else {
		// I think we should go to the page not found - otherwise you have no clue what is happening
		// This is NOT the correct way to generate a page not found error.
		//404 is not a suitable error message when sessions vars times out
		//header("location: /error/404_programs.htm");
		header("location: /error/session_timeout.htm");
		//header("HTTP/1.0 404 Not Found");
		//echo "page not found";
		//header("location: /index.php");
		exit;
	}

	$locationFile = "config.xml";
	if (isset($_SESSION['UserID'])) $userID = $_SESSION['UserID'];
	if (isset($_SESSION['UserName'])) $userName = rawurlencode($_SESSION['UserName']);
	if (isset($_SESSION['Password'])) $password = rawurlencode($_SESSION['Password']);
	if (isset($_SESSION['StudentID'])) $studentID = $_SESSION['StudentID'];
	if (isset($_SESSION['Email'])) $Email = $_SESSION['Email'];
	if (isset($_SESSION['InstanceID'])) $instanceID = $_SESSION['InstanceID'];

	$server = $_SERVER['HTTP_HOST'];
	// v6.5.6 Add support for HTTP_X_FORWARDED_FOR
	if (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
		// This might show a list of IPs. Assume/hope that EZProxy puts itself at the head of the list.
		$ipList = explode(',',$_SERVER['HTTP_X_FORWARDED_FOR']);
		$ip = $ipList[0];
		echo var_dump($ipList).'HTTP_X_FORWARDED_FOR='.$ip;
	} elseif (isset($_SERVER['HTTP_TRUE_CLIENT_IP'])) {
		$ip=$_SERVER['HTTP_TRUE_CLIENT_IP'];
		echo 'HTTP_TRUE_CLIENT_IP='.$ip;
	} elseif (isset($_SERVER["HTTP_CLIENT_IP"])) {
		$ip = $_SERVER["HTTP_CLIENT_IP"];
		echo 'HTTP_CLIENT_IP='.$ip;
	} else {
		$ip = $_SERVER["REMOTE_ADDR"];
		echo 'REMOTE_ADDR='.$ip;
	}
	// it is dangerous to send the whole referrer as you might get confused with parameters (specifically content)
	if (isset($_SERVER['HTTP_REFERER'])) {
		if (strpos($_SERVER['HTTP_REFERER'],'?')) {
			$referrer=substr($_SERVER['HTTP_REFERER'],0,strpos($_SERVER['HTTP_REFERER'],'?'));
		} else {
			$referrer = $_SERVER['HTTP_REFERER'];
		}
	}

