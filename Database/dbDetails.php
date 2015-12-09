<?php
class DBDetails {

	function __construct($dbHost) {
		switch ($dbHost) {
			// for performance testing
			case 248:
				$this->driver = "mysqli";
				$this->host = "claritylive.cjxpltmvwbov.ap-southeast-1.rds.amazonaws.com";
				$this->user = "clarity";
				$this->password = "clarity123";
				$this->dbname = "global_r2iv2";
				break;
			case 249:
				$this->driver = "mysqli";
				$this->host = "211.151.90.72";
				$this->user = "root";
				$this->password = "123456";
				$this->dbname = "copy_global_r2iv2";
				break;
			case 200:
				$this->driver = "mysqli";
				$this->host = "clarity-eu-db.c8s4j19sgnql.eu-west-1.rds.amazonaws.com";
				$this->user = "clarity";
				$this->password = "clarity123";
				$this->dbname = "rack80829";
				break;
			case 102:
				/*
				$this->driver = "mysql";
				$this->host = "claritylive.cjxpltmvwbov.ap-southeast-1.rds.amazonaws.com";
				$this->user = "clarity";
				$this->password = "clarity123";
				$this->dbname = "GlobalRoadToIELTS";
				*/
				$this->driver = "mysqli";
				$this->host = "localhost";
				$this->user = "clarity";
				$this->password = "clarity";
				$this->dbname = "global_r2iv2";
				break;
			case 101:
				$this->driver = "mysqli";
				$this->host = "claritylive.cjxpltmvwbov.ap-southeast-1.rds.amazonaws.com";
				$this->user = "clarity";
				$this->password = "clarity123";
				$this->dbname = "global_r2iv2";
				break;
			case 1000:
				$this->driver = "mysqli";
				$this->host = "localhost";
				$this->user = "root";
				$this->password = "Sunshine1787";
				$this->dbname = "GlobalRoadToIELTS";
				break;
			case 20:
				$this->driver = "mysqli";
				$this->host = "localhost";
				$this->user = "clarity";
				$this->password = "clarity";
				$this->dbname = "rack80829";
				break;
			/*
				$this->driver = "mysql";
				$this->host = "ClarityDevelop";
				$this->user = "root";
				$this->password = "Sunshine1787";
				$this->dbname = "rack80829";
				break;
			*/
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
			
			// For Dave's development environment
			case 5:
				$this->driver = "mysqli";
				$this->host = "dock.projectbench";
				$this->user = "clarity";
				$this->password = "clarity";
				$this->dbname = "rack80829";
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