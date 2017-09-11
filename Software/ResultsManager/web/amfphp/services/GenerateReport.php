<?php
/*
 * This is not really an AMFPHP service but its in this folder to maintain path integrity in all of the require_once calls.
 * Since there are no classes or methods here it does not represent a security risk.
 */

require_once(dirname(__FILE__)."/ClarityService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");

ini_set('max_execution_time', 300); // 5 minutes

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
		// gh#777, ctp#198
		if ($seconds == 0)
            return '-';
			//return sprintf("%s", 0);
			
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
	// ctp#388
	static function roundTimestamp($timestamp, $timeZone = null) {
	    if (strtotime($timestamp) !== FALSE)
	        return substr($timestamp, 0, strlen($timestamp)-3);
	    return '-';
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

// This has to moved before authentication check
$clarityService = new ClarityService();

/*
if (!Authenticate::isAuthenticated()) {
	// TODO: Replace with text from literals
	echo "<h2>You are not logged in</h2>";
	exit(0);
}
*/

$template = (isset($_REQUEST['template'])) ? $_REQUEST['template'] : "standard";
// ctp#376
if (isset($_REQUEST['reportType']))
    $reportType = $_REQUEST['reportType'];
$opts = json_decode(stripslashes((isset($_REQUEST['opts'])) ? $_REQUEST['opts'] : ""), true);
$onReportablesIDObjects = (isset($_REQUEST['onReportablesIDObjects'])) ? json_decode(stripslashes($_REQUEST['onReportablesIDObjects']), true) : array();
$forReportablesIDObjects = (isset($_REQUEST['forReportablesIDObjects'])) ? json_decode(stripslashes($_REQUEST['forReportablesIDObjects']), true) : array();
$onClass = (isset($_REQUEST['onClass'])) ? $_REQUEST['onClass'] : "";
$forClass = (isset($_REQUEST['forClass'])) ? $_REQUEST['forClass'] : "";

/**
 * This for testing and debugging reports
 *
$template = "export";
$opts = json_decode(stripslashes('{"timezoneOffset":-480, "includeInactiveUsers":true,"attempts":"all","detailedReport":true,"includeStudentID":false,
        "headers":{"forReportLabel":"Description","onReport":"Dynamic Placement Test","dateRange":"","onReportLabel":"Title(s)",
        "forReportDetail":"Full pilot"}}'), true);
$forReportablesIDObjects = json_decode(stripslashes('[{"Group":"35026"},{"ScheduledTest":"44"}]'), true);
$onReportablesIDObjects = json_decode(stripslashes('[{"Course":"63","Title":"63"}]'), true);
$onClass = "Title";
$forClass = "Group";
Session::set('rootID', 163);
*/

$forReportablesIDObjects = json_decode(stripslashes('[{"Group":"73399"}]'), true);
$template="CEFSummary";
$opts=json_decode(stripslashes('{"includeInactiveUsers":false,"includeStudentID":false,"headers":{"forReportDetail":"Jordan, Makani phase 2","forReportLabel":"Group(s)","onReport":"LearnEnglish Level Test","dateRange":"","onReportLabel":"Title(s)","attempts":"Last only"},"detailedReport":false,"attempts":"last"}'), true);
$onReportablesIDObjects=json_decode(stripslashes('[{"Title":"36","Course":"1242806791546"}]'), true);
$nocache="233557";
$forClass="Group";
$onClass="Title";

// Protect against directory traversal
// PHP 5.3
$pattern = '/..\//';
$replacement = '';
$template = preg_replace($pattern, $replacement, $template);

// Generate the report based on the options passed to the script
// v3.0.4 I need to pass the template in for special processing
// ctp#376 Get specific data for export and printable reports
// We should end up with $reportType = DPTSummary, $template = standard / export / printable
$reportType = (isset($reportType)) ? $reportType : ($template == "DPTSummary") ? "DPTSummary" : $template;
$reportDom = $clarityService->getReport($onReportablesIDObjects, $onClass, $forReportablesIDObjects, $forClass, $opts, $reportType);
// AR If I want to see the XML before it gets processed?
//$reportDom->formatOutput = true; 
header("Content-Type: text/xml; charset=utf-8"); echo $reportDom->saveXML(); exit(0);
//header("Content-Type: text/xml; charset=utf-8"); echo utf8_encode($reportDom->saveXML()); exit(0);
//header("Content-Type: text/xml; charset=utf-8"); echo htmlspecialchars($reportDom->saveXML(), ENT_COMPAT, 'UTF-8'); exit(0);

// At this point I could check to see if it is a BIG report. If so, I could warn, or I could switch views
// Add the warning in report.xsl as this is easiest, although perhaps a little late!
// It would be best with Excel export to not go through the html page. But equally I don't want to duplicate the above
// So can I just popout here? Can. There is a slight flash.
// Next, how can i export to csv instead of xml? Best to do do it xsl

// Add in the script name and request parameters as attributes. This is to allow you to build different views direct from the report (eg: print).
$reportDom->documentElement->setAttribute("scriptName", $_SERVER['SCRIPT_NAME']);
$reportDom->documentElement->setAttribute("onReportablesIDObjects", (isset($_REQUEST['onReportablesIDObjects'])) ? stripslashes($_REQUEST['onReportablesIDObjects']) : "");
$reportDom->documentElement->setAttribute("onClass", (isset($_REQUEST['onClass'])) ? $_REQUEST['onClass'] : "");
$reportDom->documentElement->setAttribute("forReportablesIDObjects", (isset($_REQUEST['forReportablesIDObjects'])) ? stripslashes($_REQUEST['forReportablesIDObjects']) : "");
$reportDom->documentElement->setAttribute("forClass", (isset($_REQUEST['forClass'])) ? $_REQUEST['forClass'] : "");
$reportDom->documentElement->setAttribute("opts", (isset($_REQUEST['opts'])) ? $_REQUEST['opts'] : "");

//echo var_dump($_REQUEST['opts']); exit(0);

// Put literals.xml into the report XML as a child of the document element so that the xsl can access the languages
// TODO Since I am using literals.xml for help strings, this might become a significant size. So maybe I can make a special section of literals
// just for reports?
$copyElement = $clarityService->copyOps->getCopyDOMForLanguage();
$reportDom->documentElement->appendChild($reportDom->importNode($copyElement, true));

// v3.4 To cope with the difference between 3 and 5 levels of the Clarity test, for now duplicate based on prefix
// No, that won't work as I don't know the prefix or root here. The only variable data I can pick up is courseID.
// So it will have to come as a new template for now. Set in ReportWindow.mxml
$xslDom = new DOMDocument();
$xslDom->load("../../reports/$template/report.xsl");

// gh#1505 Convert results held in json, will be called from xsl
function dptResultFormatter($result, $format) {
    $json = json_decode($result);
    if ($json == null)
        $format = null;
    switch ($format) {
        case 'CEFR':
        case 'CEF':
            if (isset($json->CEF)) {
                $formattedResult = $json->CEF;
            } elseif (isset($json->level)) {
                $formattedResult = $json->level;
            }
            // Then add the numeric sub-score
            if (isset($json->numeric))
                $formattedResult .= ' (dpt: '.$json->numeric.')';
            break;
        default:
            $formattedResult = $result;
    }
    return $formattedResult;
}
$proc = new XSLTProcessor();
$proc->registerPHPFunctions(array("XSLTFunctions::secondsToMinutes","XSLTFunctions::secondsToHours","dptResultFormatter","XSLTFunctions::roundTimestamp"));
$proc->importStylesheet($xslDom);
if ($template == "export") {
	header("Content-Type: text/csv; charset=\"utf-8\"");
	header("Content-Disposition: attachment; filename=\"export.csv\"");
}
echo $proc->transformToXML($reportDom);
flush();
exit();
