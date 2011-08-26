<?php

// I need to call session_start here as this is about the first thing in any page.
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
/*
$GLOBALS['rmail_smtp_host'] = "127.0.0.1";
$GLOBALS['rmail_smtp_port'] = 25;
$GLOBALS['rmail_smtp_helo'] = "localhost";
$GLOBALS['rmail_smtp_auth'] = true;
$GLOBALS['rmail_smtp_username'] = "emailer";
$GLOBALS['rmail_smtp_password'] = "Rainbow8823";
*/
/* Shift to using Rackspace Email Apps */
// For some reason, claritydevelop doesn't like a string domain name for the host.
/*
//$GLOBALS['rmail_smtp_host'] = "98.129.185.2";
$GLOBALS['rmail_smtp_host'] = "secure.emailsrvr.com";
$GLOBALS['rmail_smtp_port'] = 587;
$GLOBALS['rmail_smtp_helo'] = "localhost";
$GLOBALS['rmail_smtp_auth'] = true;
$GLOBALS['rmail_smtp_username'] = "support@clarityenglish.com";
$GLOBALS['rmail_smtp_password'] = "Sunshine";
*/
// Try SendGrid stmp service. Seems to work nicely
//$GLOBALS['rmail_smtp_host'] = "174.36.32.204";
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
//$commonFolders = "";
$commonFolders = "/../../Common";
$RMFolders = "";

// Can we just read dbDetails and use dbHost to point to different databases?
require_once(dirname(__FILE__).$commonFolders.'/../../Database/dbDetails.php');
if (isset($_SESSION['dbHost']) && $_SESSION['dbHost'] > 0) {
	//echo 'session='.$_SESSION['dbHost'];
	$dbHost = intval($_SESSION['dbHost']);
} else {
	$dbHost=0; // Pick up default from dbDetails.
}
$dbDetails = new DBDetails($dbHost);
//$dbDetails = new DBDetails(100);
$GLOBALS['dbms'] = $dbDetails->driver;
$GLOBALS['db'] = $dbDetails->driver.'://'.$dbDetails->user.':'.$dbDetails->password.'@'.$dbDetails->host.'/'.$dbDetails->dbname;
if (!isset($_SERVER["SERVER_NAME"])) {
	// command line mode
	//$GLOBALS['db'] = $GLOBALS['dbms']."://AppUser:Sunshine1787@CLARITYMAIN\SQLEXPRESS/rack80829";
} else {
// v3.4 Change for different structure on my server
	// Need to overwrite for remote access
	//$GLOBALS['rmail_smtp_host'] = "67.192.58.54";
	if (strpos(strtolower($_SERVER["SERVER_NAME"]), "dock")>=0) {
		// Adrian's testing machine
	
		/*
		//if (stristr($_SERVER["REQUEST_URI"], 'RMtoCE')) {
		// you need to be careful using these as generateReport will NOT pick up the session and so will go to a different database for results
		if (isset($_SESSION['originalStartpage']) && stristr($_SESSION['originalStartpage'], 'RMtoCE')) {
			$GLOBALS['db'] = $GLOBALS['dbms']."://AppUser:Sunshine1787@67.192.58.54,1533/rack80829";
		} elseif (isset($_SESSION['originalStartpage']) && stristr($_SESSION['originalStartpage'], 'GlobalRoadToIELTS')) {
			$GLOBALS['db'] = $GLOBALS['dbms']."://AppUserRTI:BCMartin5532@67.192.58.54,1433/GlobalRoadToIELTS";
		} elseif (isset($_SESSION['originalStartpage']) && stristr($_SESSION['originalStartpage'], 'SHCCBackup')) {
			$GLOBALS['db'] = $GLOBALS['dbms']."://AppUser:Sunshine1787@67.192.58.54,1533/rack80829bak";
		} else {
			//$GLOBALS['db'] = $GLOBALS['dbms']."://AppUser:Sunshine1787@CLARITYMAIN\SQLEXPRESS/rack80831";
			// Try to switch to MySQL
			// v3.6.1 Couldn't you read from dbDetails.php?
			if ($GLOBALS['dbms'] == 'mssql_n') {
				$GLOBALS['db'] = $GLOBALS['dbms']."://AppUser:Sunshine1787@CLARITYMAIN\SQLEXPRESS/rack80829";
				$GLOBALS['db'] = $GLOBALS['dbms']."://AppUser:Sunshine1787@dock\SQLExpress/rack80829";
				//$GLOBALS['db'] = $GLOBALS['dbms']."://AppUserRTI:BCMartin5532@dock\SQLExpress/GlobalRoadToIELTS";
				//$GLOBALS['db'] = $GLOBALS['dbms']."://AppUser:Sunshine1787@67.192.58.54,1533/rack80829";
			} else if ($GLOBALS['dbms'] == 'mysql') {
				//$GLOBALS['db'] = $GLOBALS['dbms']."://AppUser:Sunshine1787@localhost/clarity";
				$GLOBALS['db'] = $GLOBALS['dbms']."://AppUser:Sunshine1787@localhost/clarity";
				$GLOBALS['db'] = $GLOBALS['dbms']."://clarity:clarity123@claritylive.cjxpltmvwbov.ap-southeast-1.rds.amazonaws.com/GlobalRoadToIELTS";
			} else {
				$GLOBALS['db'] = $GLOBALS['dbms']."://AppUser:Sunshine1787@localhost/clarity";
			}
		}
		*/
		//NetDebug::trace('forOnlineSubs='.$_SESSION['forOnlineSubs'].' startPage='.$_SESSION['originalStartpage']);
		// If we want to see accounts created for online subscriptions, or not
		if (isset($_SESSION['forOnlineSubs']) && $_SESSION['forOnlineSubs']='1') {
			$GLOBALS['onlineSubs'] = true;
		} else {
			$GLOBALS['onlineSubs'] = false;
		}

		// If you are running triggers from my machine but with the real database
		//$GLOBALS['db'] = $GLOBALS['dbms']."://AppUser:Sunshine1787@67.192.58.54,1533/rack80829";
		//$GLOBALS['db'] = $GLOBALS['dbms']."://AppUserRTI:BCMartin5532@67.192.58.54,1533/GlobalRoadToIELTS";
		// I use the same folders to make svn easier
		//NetDebug::trace('config db used '.$GLOBALS['db']);
	// network version
	} else if (strpos(strtolower($_SERVER["SERVER_NAME"]), "localhost")>=0) {
			$GLOBALS['dbms'] = 'pdo_sqlite';
			//$tmppath = urlencode("d:\Fixbench\Database\clarity.db");
			$tmppath = urlencode("../../../../../Database/clarity.db");
			$GLOBALS['db'] = $GLOBALS['dbms']."://$tmppath";
	} else {	
		// Production
		// Need to overwrite for remote access
		//$GLOBALS['rmail_smtp_host'] = "67.192.58.54";
	
		//$GLOBALS['db'] = $GLOBALS['dbms']."://AppUser:Sunshine1787@CLARITYMAIN\SQLEXPRESS/rack80829";
		// Just testing claritymain link to CE.com database
		//$GLOBALS['db'] = $GLOBALS['dbms']."://AppUser:Sunshine1787@67.192.58.54,1533/rack80829";
	}			
}
/* Directories for Smarty, rmail & adodb libraries.  If you want these in a different location for a particular setup override them in the host
   based settings below */
$GLOBALS['adodb_libs'] = dirname(__FILE__).$commonFolders."/adodb5/";
// I now want smarty and rmail to sit under RM/web folder since they are not likely to be used outside
// and this makes it easier for development.
// But adodb is now used throughout CE.com, so it can stay in Software/Common. And it doesn't change much.
$GLOBALS['rmail_libs'] = dirname(__FILE__).$RMFolders."/rmail/";
/* Configuration for Smarty */
$smartyRoot = dirname(__FILE__).$RMFolders."/smarty";
$GLOBALS['smarty_libs'] = $smartyRoot."/libs/";
// v3.6.2 Can I move this outside the RM folder?
$GLOBALS['smarty_template_dir'] = $smartyRoot."/templates/";
$GLOBALS['smarty_compile_dir'] = $smartyRoot."/templates_c/";
$GLOBALS['smarty_config_dir'] = $smartyRoot."/configs/";
$GLOBALS['smarty_cache_dir'] = $smartyRoot."/cache/";
$GLOBALS['smarty_plugins_dir'] = $smartyRoot."/plugins/";
// Used for logging
$GLOBALS['logs_dir'] = dirname(__FILE__).$commonFolders.'/logs/';
?>
