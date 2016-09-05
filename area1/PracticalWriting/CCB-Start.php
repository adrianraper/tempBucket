<?php
	// Initialisation
	require_once '../startInit.php';
	
	// Picking up passed data
	require_once '../readPassedVariables.php';
	
	// Handling no prefix
	if (!$prefix) {
		header("location: /error/noPrefix.htm");
		exit;
	}
	
	// To make sure that anyone viewing the trial who is logged into any other Clarity program doesn't pick up the session variables
	if ($prefix=='PWTrial2015' || $prefix=='PWNTrial2015') {
		$userName = $password = $extraParam = $licenceFile = $version = '';
		$studentID = $email = $userID = $instanceID = '';
		$referrer = $ip = $server = $productCode = $accountName = '';
		$course = $startingPoint = $resize = '';
	}
		
	// For this product
	$productCode = 61;
	$swfName = 'PracticalWriting.swf';
	$startControl = '/Software/BentoTitles/PracticalWriting/bin-release/';
	$version = '1107';
	$coordsMinWidth = '990';
	$coordsMaxWidth = '1024';
	$coordsMinHeight = '860';
	$coordsMaxHeight = null;
	$locationFile = "config.xml";
	
	// Picking up IP and referrer for security checking
	require_once '../securityCheck.php';
	
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>Practical Writing from Clarity</title>
	<link rel="shortcut icon" href="/Software/PW.ico" type="image/x-icon" />
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="language" content="en" />
	<meta name="description" content="" />
	<meta name="keywords" content="" />

	<link rel="stylesheet" type="text/css" href="/Software/Common/ielts.css" />

	<script type="text/javascript" language="JavaScript" src="/Software/Common/jquery-1.7.1.min.js"></script>
	<script type="text/javascript" language="JavaScript" src="/Software/Common/openwin.js"></script>
	<script type="text/javascript" language="JavaScript" src="/Software/Common/swfobject2.js"></script>

	<script type="text/javascript" language="JavaScript" src="/Software/Common/ielts.js"></script>
	<?php require '../phpToJavascriptVars.php'; ?>
	<script type="text/javascript" language="JavaScript" src="/Software/Common/loadBento.js"></script>

	<!-- 
		Add any extra parameters to the flashvars array here 
	 -->
	<script type="text/javascript">
		swfobject.embedSWF(jsWebShare + jsStartControl + jsSwfName + argList, "altContent", "100%", "100%", "10.2.0", expressInstall, flashvars, params, attr);
	</script>
	
<!--CSS pop up layout box-->
<link rel="stylesheet" type="text/css" href="../../css/loadprogram.css" />
<style type="text/css">
	body {margin-left: 0px; margin-top: 0px; margin-right: 0px; margin-bottom: 0px}
</style>
</head>
<body onload="onLoad()">
<?php require_once '../bentoAltContent.php';?>
</body>
</html>
