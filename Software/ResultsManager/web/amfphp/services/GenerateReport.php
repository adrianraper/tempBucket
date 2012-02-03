<?php
/*
 * This is not really an AMFPHP service but its in this folder to maintain path integrity in all of the require_once calls.
 * Since there are no classes or methods here it does not represent a security risk.
 */
require_once(dirname(__FILE__)."/ClarityService.php");
//require_once(dirname(__FILE__)."/../core/shared/util/Authenticate.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");

class XSLTFunctions {
	// This is really secondsToMinutes($seconds).
	// I am going to change this so that we format the seconds into rounded minutes
	//static function secondsToMinutes($minutes) {
	//	return sprintf("%d:%02d", abs((int)$minutes / 60), abs((int)$minutes % 60));
	//}
	static function secondsToMinutes($seconds) {
		// simple minutes
		// sprintf can do the rounding itself, but apparently not terribly reliable
		//return sprintf("%d (%d=%f)", round((int)$seconds / 60), (int)$seconds / 60, (int)$seconds / 60);
		$minutes = round((int)$seconds / 60);
		if ($minutes == 0) {
			// using <1 screws up sorting, so how about using seconds if below 1 minute?
			//$minutes = "<1";
			$minutes = "0.5";
			return sprintf("%s", $minutes);
		} else {
			return sprintf("%d", $minutes);
		}
	}
	static function secondsToHours($seconds) {
		// simple hours
		// sprintf can do the rounding itself, but apparently not terribly reliable
		//return sprintf("%d (%d=%f)", round((int)$seconds / 60), (int)$seconds / 60, (int)$seconds / 60);
		// fractions? 
		$remainingMins = round(((int)$seconds % 3600) / 60);
		// v3.5 Bug. You can't round as >30 will give you an extra hour here + 3/4 from the fractions
		//$hours = round((int)$seconds / 3600);
		$hours = floor((int)$seconds / 3600);
		
		// Only do the following if you want fractions rather than integer minutes
		$wantFractions=false;
		if ($wantFractions) {
			switch($remainingMins) {
				case ($remainingMins<8):
					$fractionCode = 32;
					break;
				case ($remainingMins<23):
					//$fraction = "¼";
					$fractionCode = 188;
					break;
				case ($remainingMins<38):
					//$fraction = "½";
					$fractionCode = 189;
					break;
				case ($remainingMins<53):
					//$fraction = "¾";
					$fractionCode = 190;
					break;
				default:
					// This is almost an hour, so we will round up the floored hours
					$hours+=1;
					$fractionCode = 32;
			}
			$fraction = mb_convert_encoding('&#' . intval($fractionCode) . ';', 'UTF-8', 'HTML-ENTITIES');
			if ($hours==0) {
				// v3.5 Why do we pass 2 parameters here?
				//return sprintf("%s", $fraction, $remainingMins);
				return sprintf("%s", $fraction);
			} else {
				// v3.5 Why do we pass 3 parameters here?
				//return sprintf("%d%s", $hours, $fraction, $remainingMins);
				return sprintf("%d%s", $hours, $fraction);
			}
		} else {
			return sprintf("%d:%02d", $hours, $remainingMins);
		}
		//return sprintf("%d%s", round((int)$seconds / 3600), $fraction);
		//return sprintf("%d%s(%s)", $hours, $fraction, $remainingMins);
	}
}

// This will be called in config.php. If it was recalled here, it would generate a PHP warning and do nothing.
//session_start();

if (!Authenticate::isAuthenticated()) {
	// TODO: Replace with text from literals
	echo "<h2>You are not logged in</h2>";
	exit(0);
}

// AR To avoid php Notice warnings:
if (!isset($_REQUEST['template'])) $_REQUEST['template'] = "";
if (!isset($_REQUEST['opts'])) $_REQUEST['opts'] = "";
if (!isset($_REQUEST['onReportablesIDObjects'])) $_REQUEST['onReportablesIDObjects'] = "";
if (!isset($_REQUEST['forReportablesIDObjects'])) $_REQUEST['forReportablesIDObjects'] = "";
if (!isset($_REQUEST['onClass'])) $_REQUEST['onClass'] = "";
if (!isset($_REQUEST['forClass'])) $_REQUEST['forClass'] = "";

$onReportablesIDObjects = $_REQUEST['onReportablesIDObjects'] == "" ? array() : json_decode(stripslashes($_REQUEST['onReportablesIDObjects']), true);
$onClass = $_REQUEST['onClass'];
$forReportableIDObjects = $_REQUEST['forReportablesIDObjects'] == "" ? array() : json_decode(stripslashes($_REQUEST['forReportablesIDObjects']), true);
$forClass = $_REQUEST['forClass'];
$opts = json_decode(stripslashes($_REQUEST['opts']), true);
$template = $_REQUEST['template'] == "" ? "standard" : $_REQUEST['template'];

// Protect against directory traversal
$template = ereg_replace("../", "", $template);

$clarityService = new ClarityService();

// Generate the report based on the options passed to the script
// v3.0.4 I need to pass the template in for special processing
$reportDom = $clarityService->getReport($onReportablesIDObjects, $onClass, $forReportableIDObjects, $forClass, $opts, $template);
// AR If I want to see the XML before it gets processed?
//$reportDom->formatOutput = true; 
//header("Content-Type: text/xml; charset=utf-8"); echo $reportDom->saveXML(); exit(0);
//header("Content-Type: text/xml; charset=utf-8"); echo utf8_encode($reportDom->saveXML()); exit(0);
//header("Content-Type: text/xml; charset=utf-8"); echo htmlspecialchars($reportDom->saveXML(), ENT_COMPAT, 'UTF-8'); exit(0);

// At this point I could check to see if it is a BIG report. If so, I could warn, or I could switch views
// Add the warning in report.xsl as this is easiest, although perhaps a little late!
// It would be best with Excel export to not go through the html page. But equally I don't want to duplicate the above
// So can I just popout here? Can. There is a slight flash.
// Next, how can i export to csv instead of xml? Best to do do it xsl

// Add in the script name and request parameters as attributes. This is to allow you to build different views direct from the report (eg: print).
$reportDom->documentElement->setAttribute("scriptName", $_SERVER['SCRIPT_NAME']);
$reportDom->documentElement->setAttribute("onReportablesIDObjects", stripslashes($_REQUEST['onReportablesIDObjects']));
$reportDom->documentElement->setAttribute("onClass", $_REQUEST['onClass']);
$reportDom->documentElement->setAttribute("forReportablesIDObjects", stripslashes($_REQUEST['forReportablesIDObjects']));
$reportDom->documentElement->setAttribute("forClass", $_REQUEST['forClass']);
$reportDom->documentElement->setAttribute("opts", stripslashes($_REQUEST['opts']));

//echo var_dump($_REQUEST['opts']); exit(0);

// Put literals.xml into the report XML as a child of the document element so that the xsl can access the languages
// TODO Since I am using literals.xml for help strings, this might become a significant size. So maybe I can make a special section of literals
// just for reports?
$copyElement = $clarityService->copyOps->getCopyDOMForLanguage();
$reportDom->documentElement->appendChild($reportDom->importNode($copyElement, true));

// v3.4 To cope with the difference between 3 and 5 levels of the Clarity test, for now duplicate based on prefix
// No, that won't work as I don't know the prefix or root here. The only variable data I can pick up is courseID.
// So it will have to come as a new template for now.
$xslDom = new DOMDocument();
$xslDom->load("../../reports/$template/report.xsl");

$proc = new XSLTProcessor();
$proc->registerPHPFunctions(array("XSLTFunctions::secondsToMinutes","XSLTFunctions::secondsToHours"));
$proc->importStylesheet($xslDom);
if ($template == "export") {
	header("Content-Disposition: attachment; filename=\"export.csv\"");
}
echo $proc->transformToXML($reportDom);
flush();
exit();
?>