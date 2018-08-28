<?php
/**
 * This is still called AbstractService though it is a version for Couloir
 */
require_once(dirname(__FILE__)."/../../config.php");
 
require_once($GLOBALS['adodb_libs']."adodb-exceptions.inc.php");
require_once($GLOBALS['adodb_libs']."adodb.inc.php");

require_once(dirname(__FILE__)."/../../classes/Session.php");
require_once(dirname(__FILE__)."/../../classes/AuthenticationOps.php");
require_once(dirname(__FILE__)."/../../classes/Log/Log.php");

class AbstractService {
	
	var $db;
	
	static $title;
	
	static $log;
	static $debugLog;
	// gh#448
	static $controlLog;

	function __construct() {

		// Small optimization
		$ADODB_COUNTRECS = false;
		
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
		
		// Create the operation classes
        // gh#390 CopyOps needs to do db access now
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
    public static function timestampToAnsiString($timestamp) {
        return date("Y-m-d H:i:s", ($timestamp/1000));
    }
    public static function ansiStringToTimestamp($date) {
        $dateTime = DateTime::createFromFormat('Y-m-d H:i:s', $date);
        return $dateTime->getTimestamp() * 1000;
    }
    /**
     * Utility to help with testing dates and times
     */
    public static function getNow() {
        $nowString = (isset($GLOBALS['fake_now'])) ? $GLOBALS['fake_now'] : 'now';
        return new DateTime($nowString, new DateTimeZone(TIMEZONE));
    }

}