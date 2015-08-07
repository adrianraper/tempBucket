<?php
//header("Content-Type: text/xml");
$node = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><db>";

error_reporting(E_ALL);
ini_set('display_errors','on');
// v6.5.6.4 Needs to be moved before XMLQuery which uses dates
// v6.5.5.4 If you use server time, ensure it is UTC
date_default_timezone_set("UTC");
	
require_once(dirname(__FILE__)."/debugXMLQuery.php");
$adodbPath= "../..";
require_once($adodbPath."/adodb5/adodb-exceptions.inc.php");
require_once($adodbPath."/adodb5/adodb.inc.php");
require_once(dirname(__FILE__)."/dbPath.php");
require_once(dirname(__FILE__)."/dbFunctions.php");

	// read the passed XML
	$Query = new XMLQuery();
	$vars = $Query->vars;

	// ignore whatever is coming from actionscript
	//$vars['DBHOST']=1;
	// make the database connection
	global $db;
	$dbDetails = new DBDetails($vars['DBHOST']);
	//$dbDetails = new DBDetails(3); // To try out a specific database
	$vars['DBDRIVER']=$dbDetails->driver;
	
	$pattern = '/([a-zA-Z0-9]+):\/\/([a-zA-Z0-9]+):([a-zA-Z0-9]+)@([a-zA-Z0-9-_.]+)\/([a-zA-Z0-9]+)/';
	$replace = '\1://\2:********@\4/\5';
	echo preg_replace($pattern, $replace, $dbDetails->dsn);
	
	$db = &ADONewConnection($dbDetails->dsn);
	if (!$db) die("Connection failed");
	// Put this line on to see all sql calls before they are made
	$db->debug = true;
	
	// v3.6 UTF8 character mismatch between PHP and MySQL
	if ($dbDetails->driver == 'mysql') {
		$charSetRC = mysql_set_charset('utf8');
		//echo 'charSet='.$charSetRC;
	}
	// Fetch mode to use
	$ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
	
	// load the progress functions - all code is in this class now
	$functions = new FUNCTIONS();
	switch ( strtoupper($vars['METHOD']) ) {
	
		case 'REGISTER':
			//$node .= "<note>dbhost=".$dbDetails->host." dbname=".$dbDetails->dbname."</note>";
			//$rC = $Functions->isNotBlacklisted( $vars, $node );
			//if ($rC) {
			$rC = $functions->insertDetails( $vars, $node );
			//}
			break;
		case 'CHECKSERIALNUMBER':
			//$node .= "<note>dbhost=".$dbDetails->host." dbname=".$dbDetails->dbname."</note>";
			$rC = $functions->isNotBlacklisted($vars, $node);
			if ($rC)
				$rC = $functions->decodeSerialNumber($vars, $node);
			break;
		default:
			$node .= "<err>No method sent</err>";
	}
		
	$node .= "</db>";
	print($node);
	$db->Close();
