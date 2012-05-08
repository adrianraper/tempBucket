<?php
header("Content-Type: text/xml");
$node = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><db>";

require_once(dirname(__FILE__)."/XMLQuery.php");
$adodbPath= "../..";
require_once($adodbPath."/adodb5/adodb-exceptions.inc.php");
require_once($adodbPath."/adodb5/adodb.inc.php");
require_once(dirname(__FILE__)."/dbPath.php");
require_once(dirname(__FILE__)."/dbFunctions.php");

	// read the passed XML
	$Query	= new XMLQuery();
	$vars		= $Query->vars;
	
	// make the database connection
	global $db;
	$dbDetails = new DBDetails($vars['DBHOST']);
	//print($dbDetails->dsn);
	$db = &ADONewConnection($dbDetails->dsn);
	if (!$db) die("Connection failed");
	//$db->debug = true;
	$ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
	
	// load the progress functions - all code is in this class now
	$Functions = new FUNCTIONS();
	switch ( strtoupper($vars['METHOD']) ) {
	
		case 'REGISTER':
			//$node .= "<note>dbhost=".$dbDetails->host." dbname=".$dbDetails->dbname."</note>";
			$rC = $Functions->isNotBlacklisted( $vars, $node );
			if ($rC) {
				$rC = $Functions->insertDetails( $vars, $node );
			}
			break;
		default:
			$node .= "<err>No method sent</err>";
	}
			
	$node .= "</db>";
	print($node);
	$db->Close();
?>
