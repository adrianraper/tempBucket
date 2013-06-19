<?php
	// Initialisation
	require_once '../startInit.php';
	
	// Picking up passed data
	require_once '../readPassedVariables.php';
	
	// For this product
	$productCode = 9; // Tense Buster

	// v6.5.5.6 For default accounts you no longer need to pass version as this is all read from the database
	// Different language versions share the same location file as &content is now a root and the languageCode from T_Accounts is used as the literals
	// You can still override this if you want in a specific location file
	// The language version might come from session variables or from the URL parameters
	// v6.5.6.4 Not quite. If you login to CE.com, it picks up $_SESSION['TenseBuster']->languageCode so you CAN set location and courseFile here.
	// If you are not running from CE.com - then you MUST pass &version=INDEN or ZHO to pick it up properly
	if (session_is_registered('TenseBuster')) {
		$TenseBuster = $_SESSION['TenseBuster'];
		$version = $TenseBuster->languageCode;
	} elseif (isset($_GET['version'])){
		$version = $_GET['version'];
	} elseif (isset($_GET['Version'])){
		$version = $_GET['Version'];
	}

	// version controls the course File (for TB ZH)
	switch ($version) {
		case "INDEN":
			$locationFile = "location-IndEN.txt";
			$courseFile='course-INDEN.xml';
			break;
		case "ZH":
		case "ZHO":
			$locationFile = "location-ZH.txt";
			$courseFile='course-ZH.xml';
			break;			
		default:
	}
	
	// Picking up IP and referrer for security checking
	require_once '../securityCheck.php';
	
	// There is a strange bug that squishes everything up if the page is empty apart from the swf
	echo "<p/>";
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>Tense Buster from Clarity</title>
	<link rel="shortcut icon" href="/Software/TB.ico" type="image/x-icon" />
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="language" content="en" />
	<meta name="description" content="" />
	<meta name="keywords" content="" />

	<script type="text/javascript" language="JavaScript" src="/Software/Common/swfobject2.js"></script>
	<script type="text/javascript" language="JavaScript" src="/Software/Common/openwin.js"></script>
	<?php require '../phpToJavascriptVars.php'; ?>
	<script type="text/javascript" language="JavaScript" src="/Software/Common/loadOrchid.js"></script>

<!--CSS pop up layout box-->
<link rel="stylesheet" type="text/css" href="../../css/loadprogram.css" />
<style type="text/css">
	body {margin-left: 0px; margin-top: 0px; margin-right: 0px; margin-bottom: 0px}
</style>
</head>
<body onload="onLoad()">

<?php require_once '../resizeCSS.php';?>
<?php require_once '../orchidAltContent.php';?>

</body>
</html>
