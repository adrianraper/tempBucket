<?php
class DBDetails {
	function DBDetails($dbHost) {
		switch ($dbHost) {
			// British Council Road to IELTS database
			case 101:
				$this->driver = "mysql"; 
				$this->host = "claritylive.cjxpltmvwbov.ap-southeast-1.rds.amazonaws.com";  
				$this->user = "clarity"; 
				$this->password = "clarity123"; 
				$this->dbname  = "GlobalRoadToIELTS";
				break;
			case 300:
				$this->driver = "mysql"; 
				$this->host = "claritylive.cjxpltmvwbov.ap-southeast-1.rds.amazonaws.com"; 
				$this->user = "clarity"; 
				$this->password = "clarity123"; 
				$this->dbname  = "taiwanclarity";
				break;
			case 200:
				$this->driver = "mysql"; 
				$this->host = "claritylive.cjxpltmvwbov.ap-southeast-1.rds.amazonaws.com";  
				$this->user = "clarity"; 
				$this->password = "clarity123"; 
				$this->dbname  = "rack80829";
				break;
			case 301:
				$this->driver = "mysql"; 
				$this->host = "122.248.247.221";  
				$this->user = "root";
				$this->password = "bitnami"; 
				$this->dbname  = "taiwanclarity";
				break;				
			// Claritydevelop
			case 10:
				$this->driver = "mysql"; 
				$this->host = "ClarityDevelop"; 
				$this->user = "root"; 
				$this->password = "Sunshine1787"; 
				$this->dbname  = "rack80829";
				break;
			// Adrian's local database
			case 100:
				$this->driver = "mysql"; 
				$this->host = "localhost";  
				$this->user = "root"; 
				$this->password = "Sunshine1787"; 
				$this->dbname  = "GlobalRoadToIELTS";
				break;
			case 3:
				$this->driver = "mysql"; 
				$this->host = "localhost";  
				$this->user = "root"; 
				$this->password = "Sunshine1787"; 
				$this->dbname  = "taiwanclarity"; 
				break; 
			case 2:
			default:
				$this->driver = "mysql"; 
				$this->host = "localhost";  
				$this->user = "clarity"; 
				$this->password = "clarity"; 
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