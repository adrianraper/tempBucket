<?php 
/*
 * Picked up data passed to the start page in different ways
 */
	require_once(dirname(__FILE__).'/../Software/Common/encryptURL.php');

	// gh#371 Is data passed encrypted in the URL?
	if (isset($_GET['data'])) {
		$crypt = new Crypt();
		$data = $crypt->decodeSafeChars($_GET['data']);
		parse_str($crypt->decrypt($data));
		
	} else {
		// change capitalisation of variables
		if (isset($_SESSION['UserID'])) $userID = $_SESSION['UserID']; 
		if (isset($_SESSION['UserName'])) $userName = $_SESSION['UserName']; 
		if (isset($_SESSION['Password'])) $password = $_SESSION['Password'];
		if (isset($_SESSION['StudentID'])) $studentID = $_SESSION['StudentID'];
		if (isset($_SESSION['Email'])) $email = $_SESSION['Email'];
		if (isset($_SESSION['InstanceID'])) $instanceID = $_SESSION['InstanceID'];
		if (isset($_SESSION['AccountName'])) $accountName = $_SESSION['AccountName'];
			
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
		}
	}
