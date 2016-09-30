<?php
	// Initialisation
	require_once '../startInit.php';
	
	// Picking up passed data
	require_once '../readPassedVariables.php';
	
	// For this product
	$productCode = 39; // Clear Pronunciation
	
	// Picking up IP and referrer for security checking
	require_once '../securityCheck.php';

	// If you want to allow special behaviour for one account
	if ($prefix == 'CSTDI') {
		$courseFile = 'course-CSTDI.xml';
		if (isset($_SESSION['referrer'])) {
			$referrer = $_SESSION['referrer'];
			//echo "referrer is session set as $referrer";
		}
	}
	
	// There is a strange bug that squishes everything up if the page is empty apart from the swf
	echo "<p/>";
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>Clear Pronunciation 1: Sounds</title>
	<link rel="shortcut icon" href="/Software/CP.ico" type="image/x-icon" />
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
		swfobject.embedSWF(startControl + "control.swf" + argList, "altContent", "100%", "100%", "9.0.28", expressInstall, flashvars, params, attr);
	</script>
	
<!--CSS pop up layout box-->
<link rel="stylesheet" type="text/css" href="../../css/loadprogram.css" />
<style type="text/css">
	body { 	margin-left: 0px; margin-top: 0px; margin-right: 0px; margin-bottom: 0px}
</style>
</head>
<body onload="onLoad()">

<?php require_once '../resizeCSS.php';?>
<?php require_once '../orchidAltContent.php';?>

</body>
</html>