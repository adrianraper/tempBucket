<?php

// If the total manageables in the logged in account is more than this students will not be displayed and some function disabled (RM only)
$GLOBALS['max_manageables_for_student_display'] = 4000;

// This contains literals.xml (moved from content). Expect it to be the same folder as this config.php
//$GLOBALS['interface_dir'] = "./";
$GLOBALS['interface_dir'] = "/../";

// This contains any help files. Expect it to be /Software/ResultsManager/Help
$GLOBALS['help_dir'] = "./Help";

/* The temporary directory is used as a holding area for uploads before they are processed */
$GLOBALS['tmp_dir'] = "./tmp";

/* Configuration for RMail */

$GLOBALS['rmail_smtp_host'] = "127.0.0.1";
$GLOBALS['rmail_smtp_port'] = 25;
$GLOBALS['rmail_smtp_helo'] = "localhost";
$GLOBALS['rmail_smtp_auth'] = true;
$GLOBALS['rmail_smtp_username'] = "emailer";
$GLOBALS['rmail_smtp_password'] = "Rainbow8823";

/* The 'from' field of auto-sent emails */
$GLOBALS['rmail_from'] = "Clarity English <support@clarityenglish.com>";

if (isset($_SESSION['tw18Week'])) {
	/*	this if-block can be deleted after the tw 18 weeks project	*/
	$GLOBALS['dbms'] = 'mysql';
	$GLOBALS['db'] = $GLOBALS['dbms']."://root:gtr84lfvew@175.41.136.103/clarity";
	$GLOBALS['data_dir'] = "../../../Content";
	$GLOBALS['ap_data_dir'] = "../../../ap";
	$commonFolders = "/../../Common";
	$RMFolders = "";
	$GLOBALS['rmail_smtp_host'] = "67.192.58.54";
} else if(isset($_SESSION['ce'])) {
	/*	this if-block can be deleted after testing remoting access ce.com	*/
	$GLOBALS['dbms'] = 'mssql_n';
	$GLOBALS['db'] = $GLOBALS['dbms']."://AppUser:Sunshine1787@67.192.58.54,1533/rack80829";
	$GLOBALS['data_dir'] = "../../../Content";
	$GLOBALS['ap_data_dir'] = "../../../ap";
	$commonFolders = "/../../Common";
	$RMFolders = "";
	$GLOBALS['rmail_smtp_host'] = "67.192.58.54";
} else if(isset($_SESSION['hct'])) {
	/*	this if-block can be deleted after the HCT project	*/
	$GLOBALS['dbms'] = 'mysql';
	$GLOBALS['db'] = $GLOBALS['dbms']."://tch:Sunshine1787@194.170.60.76/clarity";
	$GLOBALS['data_dir'] = "../../../Content";
	$GLOBALS['ap_data_dir'] = "../../../ap";
	$commonFolders = "/../../Common";
	$RMFolders = "";
	$GLOBALS['rmail_smtp_host'] = "67.192.58.54";
} else {
	/* For different backend databases */
	$GLOBALS['dbms'] = 'mssql_n';
	//$GLOBALS['dbms'] = 'mysql';
	//$GLOBALS['dbms'] = 'pdo_sqlite';

	if (!isset($_SERVER["SERVER_NAME"])) {
		// command line mode
		$GLOBALS['db'] = $GLOBALS['dbms']."://AppUser:Sunshine1787@CLARITYMAIN\SQLEXPRESS/rack80829";
		$GLOBALS['data_dir'] = "../../../Content";
		$GLOBALS['ap_data_dir'] = "../../../ap";
		$commonFolders = "/../../Common";
		$RMFolders = "";
		// Need to overwrite for remote access email
		$GLOBALS['rmail_smtp_host'] = "67.192.58.54";
	} else {
	// v3.4 Change for different structure on my server
		if (strpos(strtolower($_SERVER["SERVER_NAME"]), "dock")>=0) {
			// Adrian's testing machine
			// Need to overwrite for remote access
			$GLOBALS['rmail_smtp_host'] = "67.192.58.54";
			
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
					//$GLOBALS['db'] = $GLOBALS['dbms']."://AppUser:Sunshine1787@67.192.58.54,1533/rack80829";
				} else {
					$GLOBALS['db'] = $GLOBALS['dbms']."://AppUser:Sunshine1787@localhost/hct-1";
				}
			}
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
			$GLOBALS['data_dir'] = "../../../Content";
			$GLOBALS['ap_data_dir'] = "../../../ap";
			//$commonFolders = "";
			$commonFolders = "/../../Common";
			$RMFolders = "";
		// network version
		} else if (strpos(strtolower($_SERVER["SERVER_NAME"]), "localhost")>=0) {
				$GLOBALS['dbms'] = 'pdo_sqlite';
				//$tmppath = urlencode("d:\Fixbench\Database\clarity.db");
				$tmppath = urlencode("../../../../../Database/clarity.db");
				$GLOBALS['db'] = $GLOBALS['dbms']."://$tmppath";
				$GLOBALS['data_dir'] = "../../../Content";
				$GLOBALS['ap_data_dir'] = "../../../ap";
				$commonFolders = "/../../Common";
				$RMFolders = "";
		} else {	
			// Production
			// Need to overwrite for remote access
			$GLOBALS['rmail_smtp_host'] = "67.192.58.54";
		
			$GLOBALS['db'] = $GLOBALS['dbms']."://AppUser:Sunshine1787@CLARITYMAIN\SQLEXPRESS/rack80829";
			// Just testing claritymain link to CE.com database
			$GLOBALS['db'] = $GLOBALS['dbms']."://AppUser:Sunshine1787@67.192.58.54,1533/rack80829";
			
		$GLOBALS['data_dir'] = "../../../Content";
		$GLOBALS['ap_data_dir'] = "../../../ap";
		$commonFolders = "/../../Common";
		$RMFolders = "";
		break;
	}
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
$GLOBALS['smarty_template_dir'] = $smartyRoot."/templates/";
$GLOBALS['smarty_compile_dir'] = $smartyRoot."/templates_c/";
$GLOBALS['smarty_config_dir'] = $smartyRoot."/configs/";
$GLOBALS['smarty_cache_dir'] = $smartyRoot."/cache/";
$GLOBALS['smarty_plugins_dir'] = $smartyRoot."/plugins/";

?>
