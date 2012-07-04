<?php
/**
 * 
 */
require_once(dirname(__FILE__)."/../../config.php");
 
require_once($GLOBALS['adodb_libs']."adodb-exceptions.inc.php");
require_once($GLOBALS['adodb_libs']."adodb.inc.php");

require_once(dirname(__FILE__)."/../../classes/Session.php");
require_once(dirname(__FILE__)."/../../classes/AuthenticationOps.php");
require_once(dirname(__FILE__)."/../../classes/Log/Log.php");
require_once(dirname(__FILE__)."/../../classes/Log/handlers/Log_ClarityDB.php");

class AbstractService {
	
	var $db;
	
	static $title;
	
	static $log;
	static $debugLog;

	function __construct() {
		// This deals with a date bug in AdoDB MSSQL driver
		global $ADODB_mssql_mths;
		$ADODB_mssql_date_order = 'mdy'; 
		$ADODB_mssql_mths = array('JAN'=>1,'FEB'=>2,'MAR'=>3,'APR'=>4,'MAY'=>5,'JUN'=>6,'JUL'=>7,'AUG'=>8,'SEP'=>9,'OCT'=>10,'NOV'=>11,'DEC'=>12);
		
		// Force all PHP datetime functions to work in UTC
		// Wouldn't it make more sense to work in Asia/Hong_Kong since that is where the server is?
		//date_default_timezone_set("Asia/Hong_Kong");
		date_default_timezone_set("UTC");
		
		// Small optimization
		$ADODB_COUNTRECS = false;
		
		// Persistant connections are faster, but on my setup (XP Pro SP2, SQL Server 2008 Express) this causes sporadic crashes.
		// Check on the production server to see if it works with that configuration.
		$this->db = ADONewConnection($GLOBALS['db']."?persist");
		//$this->db = &ADONewConnection($GLOBALS['db']);
		
		// v3.6 UTF8 character mismatch between PHP and MySQL
		if ($GLOBALS['dbms'] == 'mysql') {
			$charSetRC = mysql_set_charset('utf8');
			//echo 'charSet='.$charSetRC;
		}
		
		$this->db->SetFetchMode(ADODB_FETCH_ASSOC);
		
		// Create the database logger and set the database
		AbstractService::$log = &Log::factory('ClarityDB');
		AbstractService::$log->setDB($this->db);
		
		// v3.3 And one for debug logging. I don't see why the above doesn't really seem to work through the factory.
		// How to make it write to the folder I want?
		// v3.4 Sometimes I want to use a file log in DMS. If I set it up here, does it mean overhead with every single call?
		// I don't think so, it only does opening etc when called to write.
		AbstractService::$debugLog = &Log::factory('file');
		AbstractService::$debugLog->setFileName($GLOBALS['logs_dir'].'debugLog.txt');
	}

	/**
	 * Sometimes you are told a dbHost after you have loaded config.php
	 * So let the database change
	 */
	public function changeDbHost($dbHost) {
		
		$dbDetails = new DBDetails($dbHost);
		$GLOBALS['dbms'] = $dbDetails->driver;
		$GLOBALS['db'] = $dbDetails->dsn;
		$GLOBALS['dbHost'] = $dbHost;
		
		$this->db = ADONewConnection($GLOBALS['db']."?persist");
		
		// v3.6 UTF8 character mismatch between PHP and MySQL
		if ($GLOBALS['dbms'] == 'mysql')
			$charSetRC = mysql_set_charset('utf8');
		
		$this->db->SetFetchMode(ADODB_FETCH_ASSOC);
		AbstractService::$log->setDB($this->db);
		
	}
	
	/**
	 * Gets the list of dictionaries asked for.  A dictionary is a map of data->label and is used (for example) for informing the client
	 * about simple and static table joins (e.g. reseller id -> reseller name).
	 *
	 * The concrete service must implement a protected getDictionary($dictionaryName) method for this to work.
	 */
	public function getDictionaries($dictionaryNames) {
		$dictionaries = array();
		
		foreach ($dictionaryNames as $dictionaryName)
			$dictionaries[$dictionaryName] = $this->getDictionary($dictionaryName);
		
		return $dictionaries;
	}
	
	// Authentication & security
	public function beforeFilter($function_called) {
		// These functions can be called without logging in
		// TODO. Too many are having to go in here - why aren't I validating my login?
		if ($function_called == "login" || 
			$function_called == "logout" || 
			$function_called == "getCopy" ||
			$function_called == "getContent" ||
			$function_called == "getProgressData" ||
			$function_called == "getCoverage" ||
			$function_called == "getEveryonesCoverage" ||
			$function_called == "getAccountSettings" ||
			$function_called == "startSession" ||
			$function_called == "updateSession" ||
			$function_called == "stopSession" ||
			$function_called == "updateUser" ||
			$function_called == "updateLicence" ||
			$function_called == "getInstanceID" ||
			$function_called == "writeScore" ||
			$function_called == "addUser" ||
			$function_called == "getCCBContent"
			) return true;
		
		// If the user isn't authenticated then fail
        if (!Authenticate::isAuthenticated()) return false;
		
		// Now check the user roles against the permissions for the method we are calling (if none are set then we succeed).
		$memberName = $function_called."Roles";
		if (isset($this->$memberName))
			return Authenticate::isUserInRole(join($this->$memberName, ","));
		
		// Otherwise return true
		return true;
	}
	
	// In the event that a transaction is left open something must have gone wrong.  Rollback any open transactions before finishing.
	public function afterFilter($function_called) {
		// The while loop makes sure that all nested transactions are shut.  However, this is a potential danger spot as it could get
		// caught in an infinite loop if something goes wrong with adbodb's counting.  Therefore limit this to 25 nested loops (which
		// is far far more than we would ever have anyway)
		
		$n = 0;
		while ($this->db->transCnt > 0 && $n < 25) {
			$this->db->FailTrans();
			$this->db->CompleteTrans();
			$n++;
		}
	}
	
}