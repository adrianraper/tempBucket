<?php
class DBDetails {

	function __construct($dbHost) {
		switch ($dbHost) {
			// Archived databases
			case 200:
				$this->driver = "mysqli";
				$this->host = "clarity-eu-db-2017-06-21-05-09.c8s4j19sgnql.eu-west-1.rds.amazonaws.com";
				$this->user = "clarity";
				$this->password = "clarity123";
				$this->dbname = "rack80829";
				break;
            // BC Rackspace
			case 400:
				$this->driver = "mysqli";
				$this->host = "46.38.190.53";
				$this->user = "clarity";
				$this->password = "cl4r479@";
				$this->dbname = "clarity";
				break;
				
			// Different paths from RM code and Orchid code
			case 100:
				$this->driver = "pdo_sqlite"; 
				$this->dbname  = urlencode("../../../../../Database/clarity.db");
				//$this->dbname  = urlencode("../../../../Database/clarity.db");
				break;
			
			// For Item Analysis database (cropped copy of production)
			case 3:
				$this->driver = "mysqli";
				$this->host = "localhost";
				$this->user = "clarity";
				$this->password = "clarity";
				$this->dbname = "rackIAG";
				break;
					
			case 2:
			default:
				$this->driver = "mysqli";
				$this->host = "localhost";
				$this->user = "clarity";
				$this->password = "clarity";
				$this->dbname = "rack80829";
				break;
		}

		// Build the dsn based on a username or not
		$this->dsn = $this->driver."://";
		if (isset($this->user) && $this->user != "")
			$this->dsn .= $this->user.":".$this->password."@";

		if (isset($this->host) && $this->host != "")
			$this->dsn .= $this->host.'/';
			
		if (isset($this->dbname) && $this->dbname != "")
			$this->dsn .= $this->dbname;
		
		// Small optimization
		$ADODB_COUNTRECS = false;
	}

	public function getDetails() {
		$text = $this->driver."://";
		if (isset($this->user) && $this->user != "")
			$text .= $this->user.":********@";

		if (isset($this->host) && $this->host != "")
			$text .= $this->host.'/';
			
		if (isset($this->dbname) && $this->dbname != "")
			$text .= $this->dbname;
		
		return $text;
	}

}