<?php
header("Content-Type: text/xml");
$node = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><db>";

require_once(dirname(__FILE__)."/debugXMLQuery.php");
$adodbPath= "../../../Common";
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
	$Functions	= new FUNCTIONS();
	
	switch ( strtoupper($vars['PURPOSE']) ) {
	
		// v6.5.5.3 For CE.com account
		case 'GETLICENCEDETAILS':
			$rC = $Functions->getLicenceDetails( $vars, $node );
			break;
		case 'GETDATABASEVERSION':
			$node .= "<note>dbhost=".$dbDetails->host." dbname=".$dbDetails->dbname."</note>";
			$rC = $Functions->checkDatabaseVersion( $vars, $node );
			break;
		case 'GETDECRYPTKEY':
			$rC = $Functions->getDecryptKey( $vars, $node );
			break;
		case 'CHECKLOGIN':
			$rC = $Functions->checkLogin( $vars, $node );
			break;
		case 'CHECKMGS':
			$rC = $Functions->checkMGS( $vars, $node );
			break;
		default:
			$node .= "<err code='101'>No method sent</err>";
			break;
	}
	
	$node .= "</db>";
	print($node);
	$db->Close();

?>
