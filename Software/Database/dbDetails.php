<?php
class DBDetails {
	function DBDetails($dbHost) {
		switch ($dbHost) {
			// British Council Road to IELTS database
			case 100:
				$this->driver = "mssql_n"; 
				$this->host = "dock\SQLExpress";  
				$this->user = "AppUserRTI"; 
				$this->password = "BCMartin5532"; 
				$this->dbname  = "GlobalRoadToIELTS";
				break;
			// Network SQLite database
			case 101:
				$this->driver = "pdo_sqlite"; 
				$this->host = urlencode("../../../../Database/clarity.db"); 
				$this->host = urlencode("e:/Clarity/Database/clarity.db"); 
				$this->dbname  = "";
				$this->user = ""; 
				$this->password = ""; 
				
				break;
			// New SQLServer 2008 on rackspace
			case 11:
				$this->driver = "mssql_n"; 
				// Try to specify an instance - but if I type it wrong it picks up the only one anyway, so I don't know the format
				//$this->host = "67.192.58.54\MSSQL2008,1533";
				$this->host = "67.192.58.54,1533";
				$this->user = "AppUser";  
				$this->password = "Sunshine1787";  
				$this->dbname  = "rack80829"; 
				break;
			// SQLServer 2005 on Rackspace
			case 111:
				$this->driver = "mssql_n";  
				$this->host = "67.192.58.54,1433";
				$this->user = "AppUser";  
				$this->password = "Sunshine1787";  
				$this->dbname  = "rack80829"; 
				break;
			case 22:
				$this->driver = "mysql"; 
				$this->host = "localhost"; 
				$this->user = "AppUser"; 
				$this->password = "Sunshine1787"; 
				$this->dbname  = "hct-1";
				break;
			case 10:
			//default:
				$this->driver = "mssql_n";  
				$this->host = "CLARITYMAIN\SQLEXPRESS";  
				$this->user = "AppUser";  
				$this->password = "Sunshine1787";  
				$this->dbname  = "rack80829"; 
				//$this->dbname  = "Clarity"; 
				break; 
			// Adrian's local database
			case 2:
			default:
				$this->driver = "mssql_n";  
				$this->host = "dock\SQLExpress";
				$this->user = "AppUser";  
				$this->password = "Sunshine1787";  
				$this->dbname  = "rack80829"; 
				break; 
		}
		// Build the dsn based on a username or not
		$this->dsn = $this->driver."://";
		if ($this->user!="") {
			$this->dsn .= $this->user.":".$this->password."@";
		}
		$this->dsn .= $this->host;
		if ($this->dbname!="") {
			// for SQLite this only works with urlencode
			//$this->dsn .= urlencode("/").$this->dbname; 
			$this->dsn .= "/".$this->dbname; 
		}

		
		// This deals with a date bug in AdoDB MSSQL driver
		if ($this->driver=="mssql_n") {
			global $ADODB_mssql_mths;
			$ADODB_mssql_date_order = 'mdy'; 
			$ADODB_mssql_mths = array('JAN'=>1,'FEB'=>2,'MAR'=>3,'APR'=>4,'MAY'=>5,'JUN'=>6,'JUL'=>7,'AUG'=>8,'SEP'=>9,'OCT'=>10,'NOV'=>11,'DEC'=>12);
		}
		
		// Small optimization
		$ADODB_COUNTRECS = false;
	}
	function getDetails() {
		return $this->host."/".$this->dbname; 
	}
}

?>