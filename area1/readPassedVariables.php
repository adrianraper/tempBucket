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
    }		

    // gh#1458 If a portal is involved in running the start page, share a common session
    if (isset($PHPSESSID) && ($PHPSESSID!='')) {
        session_id($PHPSESSID);
    } elseif (isset($_GET['PHPSESSID']) && ($_GET['PHPSESSID']!='')) {
        session_id($_GET['PHPSESSID']);
        
    // gh#1314 This can be removed once all start pages link to v27 Bento apps
    } elseif (isset($_GET['session'])) {
        session_id($_GET['session']);
    }
	session_start();
	$currentSessionID = session_id();
    
    if (isset($RUrange)) $_SESSION['Referer'] = $RUrange;
    
    // If you didn't specifically pass in data, use session variables if they are set
	if (!isset($_GET['data'])) {
        if (isset($_SESSION['UserID'])) $userID = $_SESSION['UserID']; 
        if (isset($_SESSION['UserName'])) $userName = $_SESSION['UserName']; 
        if (isset($_SESSION['Password'])) $password = $_SESSION['Password'];
        if (isset($_SESSION['StudentID'])) $studentID = $_SESSION['StudentID'];
        if (isset($_SESSION['Email'])) $email = $_SESSION['Email'];
        if (isset($_SESSION['InstanceID'])) $instanceID = $_SESSION['InstanceID'];
        if (isset($_SESSION['AccountName'])) $accountName = $_SESSION['AccountName'];
    }
    
    if ($prefix!='') {
        if (isset($_GET['prefix'])) {
            $prefix = $_GET['prefix'];
        } elseif (isset($_GET['Prefix'])) {
            $prefix = $_GET['Prefix'];
        } elseif (isset($_SESSION['Prefix'])) {
            $prefix = $_SESSION['Prefix'];
        }
    }
