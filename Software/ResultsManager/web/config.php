<?php
// debug mode, will write log, please delete it during release version.
define("DEBUG", "TRUE");
function writelog($level, $message) {
	if (defined("DEBUG")) {
		$logmsg = "[".$level.": ".date("y/m/d H:i:s")."] ".$message."\r\n";
		$logfile = "c:/var/log/ccb/log".date("ymd").".txt";
		$fp = fopen($logfile, "a");
		fwrite($fp, $logmsg);
		fclose($fp);
	}
}

// I need to call session_start here as this is about the first thing in any page.
// Move into abstract service so you can use our Session class to register a handler
session_start();

// If the total manageables in the logged in account is more than this students will not be displayed and some function disabled (RM only)
$GLOBALS['max_manageables_for_student_display'] = 5000;

// This contains literals.xml (moved from content). Expect it to be the same folder as this config.php
//$GLOBALS['interface_dir'] = "./";
$GLOBALS['interface_dir'] = "/../";

// This contains any help files. Expect it to be /Software/ResultsManager/Help
$GLOBALS['help_dir'] = "./Help";

/* The temporary directory is used as a holding area for uploads before they are processed */
$GLOBALS['tmp_dir'] = "./tmp";

/* Configuration for RMail */
// Try SendGrid stmp service. Seems to work nicely
$GLOBALS['rmail_smtp_host'] = "smtp.sendgrid.net";
$GLOBALS['rmail_smtp_port'] = 25;
$GLOBALS['rmail_smtp_helo'] = "localhost";
$GLOBALS['rmail_smtp_auth'] = true;
$GLOBALS['rmail_smtp_username'] = "adrian.raper@clarityenglish.com";
$GLOBALS['rmail_smtp_password'] = "Sunshine";

/* The 'from' field of auto-sent emails */
$GLOBALS['rmail_from'] = "Clarity English <support@clarityenglish.com>";

$GLOBALS['data_dir'] = "../../../Content";
$GLOBALS['ap_data_dir'] = "../../../ap";
$GLOBALS['common_dir'] = dirname(__FILE__)."/../../../Software/Common";
$RMFolders = "";
// Can we just read dbDetails and use dbHost to point to different databases?
// If dbHost comes from session set in Start.php, then what about generateReport?
require_once($GLOBALS['common_dir'].'/../../Database/dbDetails.php');
if (isset($_SESSION['dbHost']) && $_SESSION['dbHost'] > 0) {
	$dbHost = intval($_SESSION['dbHost']);
} else {
	$dbHost = 101; // Default for R2IV2 local
	$dbHost = 2; // Default for rack80829
	$dbHost = 30; // Default for network version
}
$dbDetails = new DBDetails($dbHost);
$GLOBALS['dbms'] = $dbDetails->driver;
$GLOBALS['db'] = $dbDetails->dsn;
			
/* Directories for Smarty, rmail & adodb libraries.  If you want these in a different location for a particular setup override them in the host
   based settings below */
$GLOBALS['adodb_libs'] = $GLOBALS['common_dir']."/adodb5/";
// I now want smarty and rmail to sit under RM/web folder since they are not likely to be used outside
// and this makes it easier for development.
// But adodb is now used throughout CE.com, so it can stay in Software/Common. And it doesn't change much.
$GLOBALS['rmail_libs'] = dirname(__FILE__).$RMFolders."/rmail/";
/* Configuration for Smarty */
$smartyRoot = dirname(__FILE__).$RMFolders."/smarty";
$GLOBALS['smarty_libs'] = $smartyRoot."/libs/";
$GLOBALS['smarty_template_dir'] = $smartyRoot."/templates/";
$GLOBALS['smarty_compile_dir'] = $smartyRoot."/templates_c/";
$GLOBALS['smarty_config_dir'] = $smartyRoot."/configs/";
$GLOBALS['smarty_cache_dir'] = $smartyRoot."/cache/";
$GLOBALS['smarty_plugins_dir'] = $smartyRoot."/plugins/";
// Used for logging
$GLOBALS['logs_dir'] = $GLOBALS['common_dir'].'/logs/';