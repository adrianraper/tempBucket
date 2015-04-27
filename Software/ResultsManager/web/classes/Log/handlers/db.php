<?php
class Log_db extends Log {
	
	var $db;

	var $_id;
	var $_db;
	var $_ident;
	var $_rootID;
	var $_productName;
	var $_mask;

	function Log_db($db, $ident = '', $conf = array(), $level = PEAR_LOG_DEBUG) {
		$this->_id = md5(microtime());
		$this->_db = $db;
		$this->_ident = $ident;
		$this->_mask = Log::UPTO($level);
		// gh#857
	    if (!empty($conf['timeFormat']))
            $this->_timeFormat = $conf['timeFormat'];
        $this->_productName = Session::getSessionName();
	}
	
	// gh#857
	function setTarget($db) {
		$this->db = $db;
	}
	
	function setRootID($rootID) {
		$this->_rootID = $rootID;
	}
	
	// gh#857
	//function setUserID($userID) {
	//	$this->_userID = $userID;
	//}
	
	function setProductName($productName) {
		$this->_productName = $productName;
	}
	
	function log($message, $priority = null) {
		$dbObj = array();
		$dbObj['F_ProductName'] = $this->_productName;
		$dbObj['F_RootID'] = $this->_rootID;
		$dbObj['F_UserID'] = $this->_ident;
		// gh#815
		$dateStampNow = new DateTime('now', new DateTimeZone(TIMEZONE));
		$dbObj['F_Date'] = $dateStampNow->format($this->_timeFormat);
		$dbObj['F_Level'] = $priority;
		$dbObj['F_Message'] = $message;
		
		$this->_db->AutoExecute("T_Log", $dbObj);
		
		return true;
	}
	
}
