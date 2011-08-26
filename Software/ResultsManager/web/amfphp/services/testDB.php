<?php

require_once(dirname(__FILE__)."/../../adodb5/adodb-exceptions.inc.php");
require_once(dirname(__FILE__)."/../../adodb5/adodb.inc.php");

require_once(dirname(__FILE__)."/../../config.php");

class TestDB {
	
	var $db;

	function TestDB() {
		// This deals with a date bug in AdoDB MSSQL driver
		global $ADODB_mssql_mths;
		$ADODB_mssql_date_order = 'mdy'; 
		$ADODB_mssql_mths = array('JAN'=>1,'FEB'=>2,'MAR'=>3,'APR'=>4,'MAY'=>5,'JUN'=>6,'JUL'=>7,'AUG'=>8,'SEP'=>9,'OCT'=>10,'NOV'=>11,'DEC'=>12);
		
		// Force all PHP function to work in UTC
		date_default_timezone_set("UTC");
		
		// Small optimization
		$ADODB_COUNTRECS = false;
		
		// Persistant connections are faster, but on my setup (XP Pro SP2, SQL Server 2008 Express) this causes sporadic crashes.
		// Check on the production server to see if it works with that configuration.
		//$this->db = &ADONewConnection($GLOBALS['db']."?persist");
		
		$this->db = &ADONewConnection($GLOBALS['db']);
		
		$this->db->SetFetchMode(ADODB_FETCH_ASSOC);
	}
	
	function test() {
		$sql = "SELECT COUNT(*) FROM T_Session WHERE F_StartDateStamp >= ?";
		return $this->db->Execute($sql, array('2007-12-31 00:00:00'));
	}
	
}

?>