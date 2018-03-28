<?php

// gh#1424 Set a longer max time, and then default for any normal call to 30 seconds
//ini_set('max_execution_time', 120); // 2 minutes
set_time_limit(30);

// gh#32 gh#1314
if (isset($_GET['PHPSESSID']) && ($_GET['PHPSESSID']!='')) {
    session_id($_GET['PHPSESSID']);
} elseif (isset($_COOKIE["PHPSESSID"]) && ($_COOKIE['PHPSESSID']!='')) {
    session_id($_COOKIE["PHPSESSID"]);
}

// I need to call session_start here as this is about the first thing in any page.
if (!isset($noSession)) session_start();

// Whilst this is done in amfphp globals, some scripts don't run through that
// gh#815 This doesn't seem to be reliable with new DateTime();
define('TIMEZONE', 'UTC');
date_default_timezone_set(TIMEZONE);
// gh#1230 To help with testing with particular dates as today - override in your debug gateway
unset($GLOBALS['fake_now']);

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
$GLOBALS['rmail_smtp_password'] = "Ce2015@smtp";

/* The 'from' field of auto-sent emails */
$GLOBALS['rmail_from'] = "ClarityEnglish <support@clarityenglish.com>";

$GLOBALS['data_dir'] = "../../../../ContentBench/Content";
$GLOBALS['ap_data_dir'] = "../../../../ContentBench/ap";
$GLOBALS['ccb_data_dir'] = "../../../../ContentBench/CCB";
$GLOBALS['common_dir'] = dirname(__FILE__)."/../../../Software/Common";
$RMFolders = "";

// gh#598
$GLOBALS['ccb_repository_dir'] = $GLOBALS['ccb_data_dir'];

// Can we just read dbDetails and use dbHost to point to different databases?
// If dbHost comes from session set in Start.php, then what about generateReport?
require_once($GLOBALS['common_dir'].'/../../Database/dbDetails.php');

if (isset($_SESSION['dbHost']) && $_SESSION['dbHost'] > 0) {
	$dbHost = intval($_SESSION['dbHost']);
} else {
	$dbHost=2; // Pick up default from dbDetails.
}
$dbDetails = new DBDetails($dbHost);
$GLOBALS['dbms'] = $dbDetails->driver;
$GLOBALS['db'] = $dbDetails->dsn;
$GLOBALS['dbHost'] = $dbHost;
			
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
// gh#857 Used for different types of logging in production or development
$GLOBALS['logType'] = 'file'; // or 'db' or 'null'
$GLOBALS['debugLogType'] = 'file';
$GLOBALS['controlLogType'] = 'file';
$GLOBALS['dashboardLogType'] = 'graylog';
$GLOBALS['logs_dir'] = $GLOBALS['common_dir'].'/logs/';
$GLOBALS['graylogEndpoint'] = 'https://logs.clarityenglish.com:12201/gelf';
