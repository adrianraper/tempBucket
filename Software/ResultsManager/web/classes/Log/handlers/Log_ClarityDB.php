<?php

class Log_ClarityDB extends Log {
	
	var $db;

	var $_id;
	var $_name;
	var $_ident;
	var $_rootID;
	var $_userID;
	var $_productName;
	var $_mask;

	function Log_ClarityDB($db, $name, $ident = '', $conf = array(), $level = PEAR_LOG_DEBUG) {
		$this->_id = md5(microtime());
		$this->_name = $name;
		$this->_ident = $ident;
		$this->_mask = Log::UPTO($level);
	}
	
	function setDB($db) {
		$this->db = $db;
	}
	
	function setRootID($rootID) {
		$this->_rootID = $rootID;
	}
	
	function setUserID($userID) {
		//NetDebug::trace('log.setUserID='.$userID);
		$this->_userID = $userID;
	}
	// This was just used for debugging
	//function getDetails() {
	//	return $this->_userID."+".$this->_productName;
	//}
	
	function setProductName($productName) {
		$this->_productName = $productName;
	}
	
	function log($message, $priority = null) {
		//NetDebug::trace('log.write.userID='.$this->_userID);
		$dbObj = array();
		$dbObj['F_ProductName'] = $this->_productName;
		$dbObj['F_RootID'] = $this->_rootID;
		$dbObj['F_UserID'] = $this->_userID;
		// v3.5 This fails for MySQL
		//$dbObj['F_Date'] = "CURRENT_TIMESTAMP";
		$dbObj['F_Date'] = date('Y-m-d G:i:s');
		$dbObj['F_Level'] = $priority;
		$dbObj['F_Message'] = $message;
		
		$this->db->AutoExecute("T_Log", $dbObj);
		
		return true;
	}
	
}
?>
