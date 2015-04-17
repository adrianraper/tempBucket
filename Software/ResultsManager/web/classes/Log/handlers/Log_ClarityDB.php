<?php
class Log_ClarityDB extends Log {
	
	var $db;

	var $_id;
	var $_name;
	var $_ident;
	var $_rootID;
	//var $_userID;
	var $_productName;
	var $_mask;

	function Log_ClarityDB($name, $ident = '', $conf = array(), $level = PEAR_LOG_DEBUG) {
		$this->_id = md5(microtime());
		$this->_name = $name;
		$this->_ident = $ident;
		$this->_mask = Log::UPTO($level);
		// gh#857
	    if (!empty($conf['timeFormat'])) {
            $this->_timeFormat = $conf['timeFormat'];
        }
	}
	
	// gh#857
	function setTarget($name) {
		$this->db = $name;
	}
	function setDB($value) {
		$this->setTarget($value);
	}
	
	function setRootID($rootID) {
		$this->_rootID = $rootID;
	}
	
	// gh#857
	function setUserID($userID) {
		$this->_userID = $userID;
	}
	
	function setProductName($productName) {
		$this->_productName = $productName;
	}
	
	function log($message, $priority = null) {
		//NetDebug::trace('log.write.userID='.$this->_userID);
		$dbObj = array();
		$dbObj['F_ProductName'] = $this->_productName;
		$dbObj['F_RootID'] = $this->_rootID;
		$dbObj['F_UserID'] = $this->_ident;
		// v3.5 This fails for MySQL
		//$dbObj['F_Date'] = "CURRENT_TIMESTAMP";
		// gh#815
		$dateStampNow = new DateTime('now', new DateTimeZone(TIMEZONE));
		$dbObj['F_Date'] = $dateStampNow->format($this->_timeFormat);
		$dbObj['F_Level'] = $priority;
		$dbObj['F_Message'] = $message;
		
		$this->db->AutoExecute("T_Log", $dbObj);
		
		return true;
	}
	
}
