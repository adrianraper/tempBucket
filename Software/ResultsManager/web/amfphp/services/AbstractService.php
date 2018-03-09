<?php
/**
 * 
 */
require_once(dirname(__FILE__)."/../../config.php");
 
require_once($GLOBALS['adodb_libs']."adodb-exceptions.inc.php");
require_once($GLOBALS['adodb_libs']."adodb.inc.php");

require_once(dirname(__FILE__)."/../../classes/CopyOps.php");
require_once(dirname(__FILE__)."/../../classes/Session.php");
require_once(dirname(__FILE__)."/../../classes/AuthenticationOps.php");
require_once(dirname(__FILE__)."/../../classes/Log/Log.php");
//require_once(dirname(__FILE__)."/../../classes/Log/handlers/db.php");

require_once(dirname(__FILE__)."/vo/com/clarityenglish/bento/vo/Href.php");

class AbstractService {
	
	var $db;
	
	static $title;
	
	static $log;
	static $debugLog;
	// gh#448
	static $controlLog;
	static $dashboardLog;

	function __construct() {
		// This deals with a date bug in AdoDB MSSQL driver
		global $ADODB_mssql_mths;
		$ADODB_mssql_date_order = 'mdy'; 
		$ADODB_mssql_mths = array('JAN'=>1,'FEB'=>2,'MAR'=>3,'APR'=>4,'MAY'=>5,'JUN'=>6,'JUL'=>7,'AUG'=>8,'SEP'=>9,'OCT'=>10,'NOV'=>11,'DEC'=>12);
				
		// Small optimization
		$ADODB_COUNTRECS = false;
		
		// Persistant connections are faster, but on my setup (XP Pro SP2, SQL Server 2008 Express) this causes sporadic crashes.
		// Check on the production server to see if it works with that configuration.
		// gh#109 PHP 5.3 and Apache between them seem not to like persistent connections
		// 	we keep getting "mysql_pconnect(): MySQL server has gone away" error. So remove this and try it.
		//$this->db = ADONewConnection($GLOBALS['db']."?persist");
		try {
			$this->db = ADONewConnection($GLOBALS['db']);
		} catch (Exception $e) {
			throw new Exception("Sorry, failed to connect to the database. (".$e->getMessage().")");
		}
		
		// v3.6 UTF8 character mismatch between PHP and MySQL
		// gh#166 and allow for mysqlt as dbms too
		if (stristr($GLOBALS['dbms'], 'mysql'))
            $this->db->SetCharSet('utf8');
		
		$this->db->SetFetchMode(ADODB_FETCH_ASSOC);
		
		// Create the database logger and set the database
		// gh#857 Allow production to switch off logging
		/*
		 * Purpose of logging is:
		 * 
		 *  debugLog - purely for development and should be null in production unless emergency
		 *  controlLog - used to hold key information, such as user xxx deleted 1000 users in RM
		 *  log - for information you want to keep, but perhaps temporarily. Like performance or to track a bug fix for a month
		 */ 
		$conf = array();
		$conf['timeFormat'] = 'Y-m-d H:i:s';
		
		$logType = $debugLogType = $controlLogType = 'null';
		if (isset($GLOBALS['logType']))
			$logType = $GLOBALS['logType'];
		if (isset($GLOBALS['debugLogType']))
			$debugLogType = $GLOBALS['debugLogType'];
		if (isset($GLOBALS['controlLogType']))
			$controlLogType = $GLOBALS['controlLogType'];
        if (isset($GLOBALS['dashboardLogType']))
            $dashboardLogType = $GLOBALS['dashboardLogType'];

		if ($logType == 'file') {
			$logTarget = $GLOBALS['logs_dir'].'log.txt';
		} else if ($logType == 'db') {
			$logTarget = $this->db;
		} else {
			$logTarget = null;
		}
		AbstractService::$log = &Log::factory($logType, $logTarget, null, $conf);
		
		if ($debugLogType == 'file') {
			$debugLogTarget = $GLOBALS['logs_dir'].'debugLog.txt';
		} else if ($logType == 'db') {
			$debugLogTarget = $this->db;
		} else {
			$debugLogTarget = null;
		}
		AbstractService::$debugLog = &Log::factory($debugLogType, $debugLogTarget, null, $conf);
			
		if ($controlLogType == 'file') {
			$controlLogTarget = $GLOBALS['logs_dir'].'controlLog.txt';
		} else if ($controlLogType == 'db') {
			$controlLogTarget = $this->db;
		} else {
			$controlLogTarget = null;
		}
		AbstractService::$controlLog = &Log::factory($controlLogType, $controlLogTarget, null, $conf);

        if ($dashboardLogType == 'file') {
            $dashboardLogTarget = $GLOBALS['logs_dir'].'dashboard.log';
        } else if ($dashboardLogType == 'graylog') {
            $dashboardLogTarget = $GLOBALS['graylogEndpoint'];
        } else {
            $logTarget = null;
        }
        AbstractService::$dashboardLog = &Log::factory($dashboardLogType, $dashboardLogTarget, null, $conf);

        // Create the operation classes
		$this->copyOps = new CopyOps($this->db);

	}

	/**
	 * Sometimes you are told a dbHost after you have loaded config.php
	 * So let the database change
	 */
	public function changeDbHost($dbHost) {
		// gh#999 Skip out if no change
		if ($dbHost == $GLOBALS['dbHost'])
			return true;
			
		$dbDetails = new DBDetails($dbHost);
		$GLOBALS['dbms'] = $dbDetails->driver;
		$GLOBALS['db'] = $dbDetails->dsn;
		$GLOBALS['dbHost'] = $dbHost;
		
		// gh#109 PHP 5.3 and Apache between them seem not to like persistent connections
		// 	we keep getting "mysql_pconnect(): MySQL server has gone away" error. So remove this and try it.
		//$this->db = ADONewConnection($GLOBALS['db']."?persist");
		$this->db = ADONewConnection($GLOBALS['db']);
		
		// v3.6 UTF8 character mismatch between PHP and MySQL
		// gh#166 and allow for mysqlt as dbms too
		if (stristr($GLOBALS['dbms'],'mysql'))
            $this->db->SetCharSet('utf8');

		$this->db->SetFetchMode(ADODB_FETCH_ASSOC);
		// Only change db log type destinations
		if ($GLOBALS['logType'] == 'db')
		    AbstractService::$log->setTarget($this->db);
        if ($GLOBALS['debugLogType'] == 'db')
            AbstractService::$debugLog->setTarget($this->db);
        if ($GLOBALS['controlLogType'] == 'db')
            AbstractService::$controlLog->setTarget($this->db);
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
	
	/**
	 * Base method for serverside xhtml calls returns an error
	 */
	public function xhtmlLoad($href) {
		throw $this->copyOps->getExceptionForId("errorSecurity");
	}
	
	// Authentication & security
	public function beforeFilter($function_called) {
	    //return false;
		// These functions can be called without logging in
		// TODO. Too many are having to go in here - why aren't I validating my login?
		/*
		// gh#334
			$function_called == "xhtmlLoad" ||
			$function_called == "startSession" ||
			$function_called == "updateSession" ||
			$function_called == "stopSession" ||
			$function_called == "writeScore" ||
		*/
		if ($function_called == "login" || 
			$function_called == "logout" || 
			$function_called == "getCopy" ||
			$function_called == "getContent" ||
			$function_called == "getProgressData" ||
			$function_called == "getCoverage" || // This is just for IYJ progress
			$function_called == "getEveryonesCoverage" ||
			$function_called == "getEveryoneSummary" ||
			$function_called == "getAccountSettings" ||
			$function_called == "getIPMatch" ||
			$function_called == "updateUser" ||
			$function_called == "addUser" ||
            //$function_called == "updateLicence" || // gh#1299 I think should not be here
            //$function_called == "getInstanceID" || // gh#1299 I think should not be here
			//$function_called == "writeScore" || // gh#1223  // gh#1299 I think should not be here
			$function_called == "xhtmlLoad" || // gh#1223
			$function_called == "getCCBContent"
			) return true;
		
		// If the user isn't authenticated then fail
        if (!Authenticate::isAuthenticated()) {
            AbstractService::$debugLog->info('authenticate fail '.$function_called.' from '.Session::getSessionName().' sessionId='.session_id());
            // ctp#372
            //throw $this->copyOps->getExceptionForId("errorLostAuthentication");
            return false;
        } else {
            //AbstractService::$debugLog->info('authenticate ok '.$function_called.' from '.Session::getSessionName().' as '.(string)Authenticate::getAuthUser().' sessionId='.session_id());
        }
		
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

	/*
	 * For converting microsecond timestamps in UTC to local time
	 * TODO Add some protection in case we send a PHP timestamp to this (seconds not microseconds)
	 */
    public function timestampToLocalAnsiString($timestamp, $clientTimezoneOffset=null)     {
        $dateTime = new DateTime('@'.intval($timestamp/1000));
        if ($clientTimezoneOffset !== null && isset($clientTimezoneOffset->minutes)) {
            $offset = $clientTimezoneOffset->minutes;
            $negative = (boolean)$clientTimezoneOffset->negative;
            $clientDifference = new DateInterval('PT' . strval($offset) . 'M');
            if ($negative) {
                $localDateTime = $dateTime->add($clientDifference);
            } else {
                $localDateTime = $dateTime->sub($clientDifference);
            }
        } else {
            $localDateTime = $dateTime;
        }
        return $localDateTime->format('Y-m-d H:i:s');
    }
    /*
     * For converting microsecond timestamps in local time to utc
     */
    public function localTimestampToAnsiString($localTimestamp, $clientTimezoneOffset=null)     {
        $dateTime = new DateTime('@'.intval($localTimestamp/1000));
        if ($clientTimezoneOffset !== null && isset($clientTimezoneOffset->minutes)) {
            $offset = $clientTimezoneOffset->minutes;
            $negative = (boolean)$clientTimezoneOffset->negative;
            $clientDifference = new DateInterval('PT' . strval($offset) . 'M');
            if ($negative) {
                $utcDateTime = $dateTime->sub($clientDifference);
            } else {
                $utcDateTime = $dateTime->add($clientDifference);
            }
        } else {
            $utcDateTime = $dateTime;
        }
        return $utcDateTime->format('Y-m-d H:i:s');
    }

    /*
     * For converting unix timestamps (milliseconds since epoch) to strings for the database
     */
    public function timestampToAnsiString($timestamp) {
        return date("Y-m-d H:i:s", ($timestamp/1000));
    }
    public function ansiStringToTimestamp($date) {
        $dateTime = DateTime::createFromFormat('Y-m-d H:i:s', $date);
        return $dateTime->getTimestamp() * 1000;
    }
    /**
     * Utility to help with testing dates and times
     * TODO Should be in AbstractService?
     */
    public static function getNow() {
        $nowString = (isset($GLOBALS['fake_now'])) ? $GLOBALS['fake_now'] : 'now';
        return new DateTime($nowString, new DateTimeZone(TIMEZONE));
    }

}