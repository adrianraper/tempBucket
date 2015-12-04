<?php
/*
 * This is not really an AMFPHP service but its in this folder to maintain path integrity in all of the require_once calls.
 * Since there are no classes or methods here it does not represent a security risk.
 */
ini_set('max_execution_time', 300); // 5 minutes

require_once(dirname(__FILE__)."/ResultsManagerService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/bento/vo/content/transform/ProgressExerciseScoresTransform.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/bento/vo/content/transform/ProgressSummaryTransform.php");

class XSLTFunctions {
	static function secondsToMinutes($seconds) {
		if ($seconds == 0)
			return sprintf("%s", 0);
	}
}

$thisService = new ResultsManagerService();

/*
if (!Authenticate::isAuthenticated()) {
	echo "<h2>You are not logged in</h2>";
	exit(0);
}
*/

/*
 * Decode the encrypted data sent in the URL
 */
require_once(dirname(__FILE__).'/../../../../../area1/readPassedVariables.php');

// This gives us
/*
$studentID = '12345678';
$unitName = 'Am is are';
$teacherID = '987654321';
$rootID = 24568;
*/

//Data checking
if (!isset($studentID) || !isset($rootID) || !isset($prefix) || !isset($unitName)) {
    echo "Please pass studentID, rootID, prefix and unitName to this script";
    exit();
}

// First get the student
$stubUser = New User();
$stubUser->studentID = $studentID;
try {
    $student = $thisService->manageableOps->getUserByKey($stubUser, $rootID, User::LOGIN_BY_ID);
} catch (Exception $e) {
    if ($e->errorcode > 0) {
        echo $e->getMessage();
        exit();
    }
}
if (!$student) {
    echo "Sorry, no such student id";
    exit();
}
Session::set('userID', $student->userID);

// Next get the product from the unit name. Will we pick up the products that this root has and search all their menu.xmls?
// It would be great if we could instead get some kind of SCORM id that we could look up (such as mdl_scorm_scoes_data.datafromlms)
$fullUnitName = $thisService->convertUnitSCORMName($unitName);
$productCode = 55;
Session::set('productCode', 55);

$href = new href();
$href->type = 'menu_xhtml';
// each transform has to be an object
$href->transforms = array(new ProgressExerciseScoresTransform(), new ProgressSummaryTransform());
$href->currentDir = 'http://www.clarityenglish.com/Content/TenseBuster10-International';
$href->filename = 'menu-FullVersion.xml';
$href->serverSide = true;
$href->options = null;

// Get back the same menu.xml that the student gets - with <score> nodes that contain what the student has done
$menuXmlString = $thisService->xhtmlLoad($href);
//echo $menuXmlString; exit();
//AbstractService::$debugLog->info($menuXmlString);

$reportDom = new DOMDocument();
$reportDom->loadXML($menuXmlString);

// And add in the other data you want
$userNode = $reportDom->createElement("user", $student->fullName);
$userNode->setAttribute('name', $student->fullName);
$reportDom->documentElement->appendChild($userNode);
$unitNode = $reportDom->createElement("unit", $fullUnitName);
$reportDom->documentElement->appendChild($unitNode);
//AbstractService::$debugLog->info($reportDom->saveXML());

$xslDom = new DOMDocument();
$rc = $xslDom->load("../../reports/coverage/report.xsl");
$proc = new XSLTProcessor();
$proc->registerPHPFunctions(array("XSLTFunctions::secondsToMinutes"));
$proc->importStylesheet($xslDom);
echo $proc->transformToXML($reportDom);
flush();
exit();
