<?php

require_once(dirname(__FILE__)."/../../config.php");
require_once($GLOBALS['adodb_libs']."adodb-exceptions.inc.php");
require_once($GLOBALS['adodb_libs']."adodb.inc.php");
require_once(dirname(__FILE__)."/../../classes/Log/Log.php");
require_once(dirname(__FILE__)."/../../classes/Log/handlers/Log_ClarityDB.php");


$GLOBALS['db'] = "mysql://AppUser:Sunshine1787@localhost/rack80829_dbo";

session_start();

	// Force all PHP function to work in UTC
	date_default_timezone_set("UTC");
	
	// Small optimization
	$ADODB_COUNTRECS = false;
	
	// Persistant connections are faster, but on my setup (XP Pro SP2, SQL Server 2008 Express) this causes sporadic crashes.
	// Check on the production server to see if it works with that configuration.
	$db = &ADONewConnection($GLOBALS['db']."?persist");
	
	//$this->db = &ADONewConnection($GLOBALS['db']);
	
	$db->SetFetchMode(ADODB_FETCH_ASSOC);
	
	// Create the database logger and set the database
	$log = &Log::factory('ClarityDB');
	$log->setDB($db);
	
	$sql = "SELECT * FROM T_Accounts WHERE F_RootID=?";
	$resultObj = $db->GetRow($sql, array(163));
		
	var_dump($resultObj);

exit(0)
?>