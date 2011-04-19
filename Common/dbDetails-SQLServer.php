<?php
class DBDetails {
	function DBDetails($dbHost) {
		switch ($dbHost) {
			// British Council Road to IELTS database
			case 100:
				$this->driver = "mssql_n"; 
				$this->host = "67.192.58.54,1433"; 
				$this->user = "AppUserRTI"; 
				$this->password = "BCMartin5532"; 
				$this->dbname  = "GlobalRoadToIELTS";
				break;
			// Testing in the office
			case 0:
				$this->driver = "mssql_n"; 
				$this->host = "CLARITYMAIN\SQLEXPRESS"; 
				$this->user = "AppUser"; 
				$this->password = "Sunshine1787"; 
				$this->dbname  = "Clarity";
				break;
			default:
				$this->driver = "mssql_n"; 
				$this->host = "67.192.58.54,1433"; 
				$this->user = "AppUser"; 
				$this->password = "Sunshine1787"; 
				$this->dbname  = "Clarity";
		}
		$this->dsn = $this->driver."://".$this->user.":".$this->password."@".$this->host."/".$this->dbname; 
		// This deals with a date bug in AdoDB MSSQL driver
		global $ADODB_mssql_mths;
		$ADODB_mssql_date_order = 'mdy'; 
		$ADODB_mssql_mths = array('JAN'=>1,'FEB'=>2,'MAR'=>3,'APR'=>4,'MAY'=>5,'JUN'=>6,'JUL'=>7,'AUG'=>8,'SEP'=>9,'OCT'=>10,'NOV'=>11,'DEC'=>12);
		
		// Force all PHP function to work in UTC
		date_default_timezone_set("UTC");
		
		// Small optimization
		$ADODB_COUNTRECS = false;
	}
	function getDetails() {
		return $this->host."/".$this->dbname; 
	}
}

?>