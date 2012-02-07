<?php
class DBDetails {
	
	function __construct($dbHost) {
		switch ($dbHost) {
			case 200:
				$this->driver = "mysql"; 
				$this->host = "claritylive.cjxpltmvwbov.ap-southeast-1.rds.amazonaws.com";  
				$this->user = "clarity"; 
				$this->password = "clarity123"; 
				$this->dbname = "GlobalRoadToIELTS";
				break;
			case 101:
				$this->driver = "mysql"; 
				$this->host = "localhost";  
				$this->user = "root"; 
				$this->password = "Sunshine1787"; 
				$this->dbname = "GlobalRoadToIELTS";
				break;
			case 100:
				$this->driver = "mysql"; 
				$this->host = "localhost";  
				$this->user = "clarity"; 
				$this->password = "clarity"; 
				$this->dbname = "global_r2iv2";
				break;
			case 2:
				$this->driver = "mysql"; 
				$this->host = "claritylive.cjxpltmvwbov.ap-southeast-1.rds.amazonaws.com";  
				$this->user = "clarity"; 
				$this->password = "clarity123"; 
				$this->dbname = "rack80829";
				break;				
			default:
				$this->driver = "mysql"; 
				$this->host = "localhost";  
				$this->user = "clarity"; 
				$this->password = "clarity"; 
				$this->dbname = "rack80829";
				break;
		}
		
		// Build the dsn based on a username or not
		$this->dsn = $this->driver."://";
		if ($this->user != "") {
			$this->dsn .= $this->user.":".$this->password."@";
		}
		
		$this->dsn .= $this->host;
		if ($this->dbname != "") {
			// for SQLite this only works with urlencode
			//$this->dsn .= urlencode("/").$this->dbname; 
			$this->dsn .= "/".$this->dbname; 
		}

		// Small optimization
		$ADODB_COUNTRECS = false;
	}
	
	public function getDetails() {
		return $this->host."/".$this->dbname; 
	}
	
}