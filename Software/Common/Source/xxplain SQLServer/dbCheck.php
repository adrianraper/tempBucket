<?php
header("Content-Type: text/xml");
$node = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><db>";

// v6.5.6.4 Needs to be moved before XMLQuery which uses dates
// v6.5.5.4 If you use server time, ensure it is UTC
date_default_timezone_set("UTC");
//echo "1"; exit();	
require_once(dirname(__FILE__)."/XMLQuery.php");
$adodbPath= "../..";
require_once($adodbPath."/adodb5/adodb-exceptions.inc.php");
require_once($adodbPath."/adodb5/adodb.inc.php");
require_once(dirname(__FILE__)."/dbPath.php");
require_once(dirname(__FILE__)."/dbProgress.php");
//echo "2";

	// read the passed XML
	$Query = new XMLQuery();
	$vars = $Query->vars;
	
	// make the database connection
	global $db;
	//$dbDetails = new DBDetails($vars['DBHOST']);
	if (isset($_REQUEST['dbHost'])) {
		$dbHost = intval($_REQUEST['dbHost']);
	} else {
		$dbHost = 2;
	}
	if (isset($_REQUEST['rootID'])) {
		$rootID = intval($_REQUEST['rootID']);
	} else {
		$rootID = 163;
	}
	$dbDetails = new DBDetails($dbHost);
	$vars['ROOTID'] = $rootID;
	// make the database connection
	$vars['DBDRIVER']=$dbDetails->driver;
	// You shouldn't display the full details, but what is it safe to display?
	//$node .="<note>".$dbDetails->dsn."</note>";
	$node .='<note>'.$dbDetails->driver.'://'.$dbDetails->user.':'.'********'.'@'.$dbDetails->host.'/'.$dbDetails->dbname.'</note>';
	$db = &ADONewConnection($dbDetails->dsn);
	if (!$db) die("Connection failed");
	//$db->debug = true;
	// v3.6 UTF8 character mismatch between PHP and MySQL
	if ($dbDetails->driver == 'mysql') {
		$charSetRC = mysql_set_charset('utf8');
	}
	$ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
	
	// load the progress functions - all code is in this class now
	$Progress	= new PROGRESS();

	if (!$db) {
		$node .= "<note>Cannot connect to database</note>";
	} else {
		$node .= "<note>Successfully connected to database</note>";
	}
		$rC = $Progress->checkDatabaseVersion($vars, $node);

		// new function to ensure that we are running with the right dateformat
		if (strpos($vars['DBDRIVER'],"mssql")!==false) {
			$sql = <<<EOD
					set dateformat ymd
EOD;
			$rs = $db->Execute($sql, array());
			if ($rs) {
				$node .= "<note>set dateformat to ymd</note>";
			}
			$rs->Close();
		}
		
		// check users
		$count = $Progress->countUserRecords($vars);
		if ($count > 0) {
			$node .= "<note>There are $count users</note>";
		} else {
		    $node .= "<note>Can't count any users</note>";
		}
		// then try writing to a table
		$vars['USERID'] = 1;
		$vars['SENTDATA'] = "scratch-pad test";
		$rC = $Progress->updateScratchPad( $vars  );
		if ($rC) {
			$node .= "<note>Text written to table successfully</note>";
		} else {
			$node .= "<note>Text cannot be written to table for default user</note>";
		}

	$node .= "</db>";
	print($node);
	$db->Close();
?>
