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
	
	// For this product
	$productCode = 1; // Author Plus
	
	// Make sure we know where is the udp (mod rewrite doesn't change the start folder)
	if (isset($_GET['udp'])) {
		$userdatapath = $_GET['udp'];
	} else if (isset($_GET['UDP'])) {
		$userdatapath = $_GET['UDP'];
	} else {
		$userdatapath='';
	}
	
	// Picking up IP and referrer for security checking
	require_once '../securityCheck.php';
	
	// There is a strange bug that squishes everything up if the page is empty apart from the swf
	echo "<p/>";
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>Author Plus from Clarity</title>
	<link rel="shortcut icon" href="/Software/AP.ico" type="image/x-icon" />
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="language" content="en" />
	<meta name="description" content="" />
	<meta name="keywords" content="" />

	<script type="text/javascript" language="JavaScript" src="/Software/Common/swfobject2.js"></script>
	<script type="text/javascript" language="JavaScript" src="/Software/Common/openwin.js"></script>
	<?php require '../phpToJavascriptVars.php'; ?>
	<script type="text/javascript" language="JavaScript" src="/Software/Common/loadOrchid.js"></script>

	<!-- 
		Add any extra parameters to the flashvars array here 
	 -->
	<script type="text/javascript">
		swfobject.embedSWF(jsStartControl + jsSwfName + argList, "altContent", "100%", "100%", "9.0.28", expressInstall, flashvars, params, attr);
	</script>
	
<!--CSS pop up layout box-->
<link rel="stylesheet" type="text/css" href="../../css/loadprogram.css" />
<style type="text/css">
	body {margin-left: 0px; margin-top: 0px; margin-right: 0px; margin-bottom: 0px}
</style>
</head>
<body onload="onLoad()">
<?php require_once '../orchidAltContent.php';?>
</body>
</html>
