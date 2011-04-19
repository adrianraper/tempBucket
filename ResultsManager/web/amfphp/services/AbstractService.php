<?php
/**
 * -Database changes -
 * o Need to make the SQL Server database accessible through SQL authentication (see basecamp writeboard)
 * o Turn on auto_increment in t_groupstructures.F_GroupID (in SQL Server make it an identity column)
 * o Add T_Accounts
 * o Add T_Accountroot
 * o Add T_Titlelicences
 * o Add T_HiddenContent
 *
 * ... database changes too numerous to list here.  Check Basecamp for full descriptions of what has changed.
 */
require_once(dirname(__FILE__)."/../../config.php");
 
require_once($GLOBALS['adodb_libs']."adodb-exceptions.inc.php");
require_once($GLOBALS['adodb_libs']."adodb.inc.php");

// Can I remove all of these to more details services?
/*
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/Reportable.php");

require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/Manageable.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/User.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/Group.php");

require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/content/Content.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/content/Title.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/content/Course.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/content/Unit.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/content/Exercise.php");

require_once(dirname(__FILE__)."/../../classes/Session.php");
require_once(dirname(__FILE__)."/../../classes/LoginOps.php");
require_once(dirname(__FILE__)."/../../classes/CopyOps.php");
require_once(dirname(__FILE__)."/../../classes/ManageableOps.php");
require_once(dirname(__FILE__)."/../../classes/ContentOps.php");
require_once(dirname(__FILE__)."/../../classes/LicenceOps.php");
require_once(dirname(__FILE__)."/../../classes/UsageOps.php");
require_once(dirname(__FILE__)."/../../classes/ReportOps.php");
require_once(dirname(__FILE__)."/../../classes/ImportXMLParser.php");
*/
require_once(dirname(__FILE__)."/../../classes/Session.php");
require_once(dirname(__FILE__)."/../../classes/AuthenticationOps.php");
require_once(dirname(__FILE__)."/../../classes/Log/Log.php");
require_once(dirname(__FILE__)."/../../classes/Log/handlers/Log_ClarityDB.php");

class AbstractService {
	
	var $db;
	
	static $log;
	static $debugLog;

	function _AbstractService() {
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
		
		// Create the database logger and set the database
		AbstractService::$log = &Log::factory('ClarityDB');
		AbstractService::$log->setDB($this->db);
		
		// v3.3 And one for debug logging. I don't see why the above doesn't really seem to work through the factory.
		// How to make it write to the folder I want?
		//AbstractService::$debugLog = &Log::factory('file', 'debugLog.txt');
		
		// v3.2 To get rid of the need for CONVERT statements in some SQLServer instances
		//if ($GLOBALS['dbms'] == 'mssql_n') {
			// Not tested.
			//$sql = "set dateformat ymd";
			//$rc = $this->db->Execute($sql);
		//}

		// Set the user id in the logging system. Except that it is not a session variable yet.
		// So do this in DMSService instead.
		//if (Session::is_set('userID')) {
		//	AbstractService::$log->setUserID(Session::get('userID'));
		//};
	}
	
	/**
	 * Gets the list of dictionaries asked for.  A dictionary is a map of data->label and is used (for example) for informing the client
	 * about simple and static table joins (e.g. reseller id -> reseller name).
	 *
	 * The concrete service must implement a protected getDictionary($dictionaryName) method for this to work.
	 */
	function getDictionaries($dictionaryNames) {
		$dictionaries = array();
		
		foreach ($dictionaryNames as $dictionaryName)
			$dictionaries[$dictionaryName] = $this->getDictionary($dictionaryName);
		
		return $dictionaries;
	}
	
	// Authentication & security
	public function beforeFilter($function_called) {
		// These functions can be called without logging in
		if ($function_called == "login" || 
			$function_called == "logout" || 
			$function_called == "getCopy" ||
			$function_called == "getContent" ||
			$function_called == "getCoverage" ||
			$function_called == "getEveryonesCoverage"
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

?>