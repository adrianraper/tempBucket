<?php
header("Content-Type: text/xml");
$node = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><db>";

define('TIMEZONE', 'UTC');
date_default_timezone_set(TIMEZONE);

require_once(dirname(__FILE__)."/XMLQuery.php");
$adodbPath= "../..";
require_once($adodbPath."/adodb5/adodb-exceptions.inc.php");
require_once($adodbPath."/adodb5/adodb.inc.php");
require_once(dirname(__FILE__)."/dbPath.php");
require_once(dirname(__FILE__)."/dbFunctions.php");

	// read the passed XML
	$Query = new XMLQuery();
	$vars = $Query->vars;
	
	// make the database connection
	global $db;
	$dbDetails = new DBDetails($vars['DBHOST']);
	$vars['DBDRIVER']=$dbDetails->driver;
	
	//echo $dbDetails->dsn;
	$db = ADONewConnection($dbDetails->dsn);

	if (!$db) die("Connection failed");
	// Put this line on to see all sql calls before they are made
	//$db->debug = true;
	
	// v3.6 UTF8 character mismatch between PHP and MySQL
	if ($dbDetails->driver == 'mysql') {
		$charSetRC = mysql_set_charset('utf8');
		//echo 'charSet='.$charSetRC;
	}
	
	// Fetch mode to use
	$ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
		
	// load the progress functions - all code is in this class now
	$functions = new FUNCTIONS();
	switch (strtoupper($vars['METHOD'])) {
	
		case 'REGISTERPROGRAM':
			$rC = $functions->isNotBlacklisted($vars, $node);
			if ($rC)
				$rC = $functions->decodeSerialNumber($vars, $node);
			if ($rC)
				$rC = $functions->insertDetails($vars, $node);
			if ($rC)
				$checksum = $functions->generateCheckSum($vars, $node);
			$node .= "<licence checksum='$checksum' />";
			break;
		case 'REGISTER':
			//$node .= "<note>dbhost=".$dbDetails->host." dbname=".$dbDetails->dbname."</note>";
			//$rC = $Functions->isNotBlacklisted( $vars, $node );
			$rC = $functions->insertDetails($vars, $node);
			if ($rC)
				$rC = $functions->generateSerialNumber($vars, $node);
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
