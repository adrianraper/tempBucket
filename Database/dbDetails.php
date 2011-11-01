<?php
class DBDetails {
	function DBDetails($dbHost) {
		switch ($dbHost) {
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

		// Small optimization
		$ADODB_COUNTRECS = false;
	}
	function getDetails() {
		return $this->host."/".$this->dbname; 
	}
}

?>