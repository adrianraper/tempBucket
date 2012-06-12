<?php

	require_once("../../CSTDI/CSTDIvariables.php");

	if (isset($_GET['session'])) {
		session_id($_GET['session']);
	}
	session_start();
	$currentSessionID = session_id();
	
	$programFolder = 'BusinessWriting';
	$courseID = '51';
	$evaluationExerciseID = '52';
	$programLink = $domain.'area1/'.$programFolder.'/Start.php?prefix=CSTDI&session='.$currentSessionID;
	$evaluationLink = $programLink.'&startingPoint=ex:'.$evaluationExerciseID.'&course='.$courseID.'&session='.$currentSessionID;
	
	// Need to pass the referrer URL through
	// it is dangerous to send the whole referrer as you might get confused with parameters (specifically content)
	if (isset($_SERVER['HTTP_REFERER'])) {
		if (strpos($_SERVER['HTTP_REFERER'],'?')) {
			$referrer=substr($_SERVER['HTTP_REFERER'],0,strpos($_SERVER['HTTP_REFERER'],'?'));
		} else {
			$referrer = $_SERVER['HTTP_REFERER'];
		}
	} else {
		$referrer = "no referrer set";
	}
	$_SESSION['referrer'] = $referrer;
	
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>Business Writing</title>
	<link rel="shortcut icon" href="/Software/BW.ico" type="image/x-icon" />
	<link rel="stylesheet" type="text/css" href="../../HK/CSTDI/css/home.css" />
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="language" content="en" />
	<meta name="description" content="" />
	<meta name="keywords" content="" />
</head>
<body>
	<div id="container">
    	<div id="header_BW"></div>
        <div id="select_title">Please select an option.</div>
        <div id="content">
                <a href="<?php echo $programLink; ?>" target="_new" id="btn_bw_start"></a>
                <a href="<?php echo $evaluationLink; ?>" target="_new" id="btn_bw_eva"></a>
        </div>
        <div id="footer_BW"></div>
    </div>
</body>
</html>
