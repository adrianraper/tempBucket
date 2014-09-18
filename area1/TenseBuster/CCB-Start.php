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
	
	$TBv10 = false;
	
	if (!isset($_GET['upgrade']) or $_GET['upgrade'] != 'false'){
		if ($_GET['upgrade'] == 'true') {
			require_once('../../db_login.php');
			$resultset = $db->Execute("SELECT a.F_ProductCode FROM T_AccountRoot ar Left Outer Join T_Accounts a on ar.F_RootID = a.F_RootID where ar.F_Prefix = ? and a.F_ProductCode = 55",array($prefix));
			if (!$resultset) {
				$errorMsg = $db->ErrorMsg();
			} else {
				if ($resultset->RecordCount()==1) {
						//header('Location: /area1/TenseBuster10/Start.php?'.$_SERVER['QUERY_STRING']);
						$TBv10 = true;
				}
			} 
			$resultset->Close();
			$db->Close();
		}else{ 
			switch($prefix) {
				//case 'clarity' :
				case 'DEMO' :
				//case 'DEV' :
				case 'ACL' :
				//case 'NEKO' :
				//case 'AAMC' :
				//case 'AAWC' :
				//case 'ADMC' :
				//case 'ADWC' :
				//case 'DMC' :
				//case 'DWC' :
				//case 'FMC' :
				//case 'FWC' :
				//case 'MZC' :
				//case 'RKM' :
				//case 'RKW' :
				//case 'RUC' :
				//case 'SJMC' :
				//case 'SJWC' :
				//case 'QCD' :
				case 'Trial' :
				case 'CLCVC' :
				//case 'INTERNAL' :
				//case 'ROBPA' :
					break;
		
				default:
					require_once('../../db_login.php');
					$resultset = $db->Execute("SELECT a.F_ProductCode FROM T_AccountRoot ar Left Outer Join T_Accounts a on ar.F_RootID = a.F_RootID where ar.F_Prefix = ? and a.F_ProductCode = 55",array($prefix));
					if (!$resultset) {
						$errorMsg = $db->ErrorMsg();
					} else {
						if ($resultset->RecordCount()==1) {
								//header('Location: http://www.clarityenglish.com/area1/TenseBuster10/Start.php?'.$_SERVER['QUERY_STRING']);
								$TBv10 = true;
						}
					} 
					$resultset->Close();
					$db->Close();
				
			}
		}
	}
	
	if($TBv10){
	
		// For this product
		$productCode = 55; // RoadToIELTS 2
		$swfName = 'TenseBuster.swf';
		$startControl = '/Software/BentoTitles/TenseBuster/bin-release/';
		$version = '1107';
		$coordsMinWidth = '990';
		$coordsMaxWidth = '990';
		$coordsMinHeight = '760';
		$coordsMaxHeight = '970';
		$locationFile = "config.xml";
		$courseFile = '';
	
	}else{
	
		// For this product
		$productCode = 9; // Tense Buster

		// v6.5.5.6 For default accounts you no longer need to pass version as this is all read from the database
		// Different language versions share the same location file as &content is now a root and the languageCode from T_Accounts is used as the literals
		// You can still override this if you want in a specific location file
		// The language version might come from session variables or from the URL parameters
		// v6.5.6.4 Not quite. If you login to CE.com, it picks up $_SESSION['TenseBuster']->languageCode so you CAN set location and courseFile here.
		// If you are not running from CE.com - then you MUST pass &version=INDEN or ZHO to pick it up properly
		if (isset($_SESSION['TenseBuster'])) {
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
	
	<?php if($TBv10){ ?>
	<link rel="stylesheet" type="text/css" href="/Software/Common/ielts.css" />

	<script type="text/javascript" language="JavaScript" src="/Software/Common/jquery-1.7.1.min.js"></script>
	<script type="text/javascript" language="JavaScript" src="/Software/Common/ielts.js"></script>	
	<script type="text/javascript" language="JavaScript" src="/Software/Common/loadBento.js"></script>
	<?php }else{ ?>
	
	<script type="text/javascript" language="JavaScript" src="/Software/Common/loadOrchid.js"></script>	
	<?php } ?>	
	
	<!-- 
		Add any extra parameters to the flashvars array here 
	 -->
	<script type="text/javascript">
	<?php if($TBv10){ ?>
		swfobject.embedSWF(jsWebShare + jsStartControl + jsSwfName + argList, "altContent", "100%", "100%", "10.2.0", expressInstall, flashvars, params, attr);
	<?php }else{ ?>
		swfobject.embedSWF(jsStartControl + jsSwfName + argList, "altContent", "100%", "100%", "9.0.28", expressInstall, flashvars, params, attr);
	<?php } ?>
	</script>
	
<!--CSS pop up layout box-->
<link rel="stylesheet" type="text/css" href="../../css/loadprogram.css" />
<style type="text/css">
	body {margin-left: 0px; margin-top: 0px; margin-right: 0px; margin-bottom: 0px}
</style>
</head>
<body onload="onLoad()">
<?php 
	if($TBv10){
		require_once '../bentoAltContent.php';
	}else{
		require_once '../orchidAltContent.php';
	}
?>
</body>
</html>
