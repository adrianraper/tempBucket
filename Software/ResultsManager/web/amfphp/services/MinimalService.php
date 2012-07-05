<?php
/**
 * Used when you don't need the full ClarityService
 */

require_once(dirname(__FILE__)."/../../config.php");
 
require_once($GLOBALS['adodb_libs']."adodb-exceptions.inc.php");
require_once($GLOBALS['adodb_libs']."adodb.inc.php");

require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/Reportable.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/Group.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/User.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/account/Subscription.php");

require_once(dirname(__FILE__)."/../../classes/AuthenticationOps.php");
require_once(dirname(__FILE__)."/../../classes/ManageableOps.php");

// v3.4 This is used for internal queries
require_once(dirname(__FILE__)."/../../classes/InternalQueryOps.php");
require_once(dirname(__FILE__)."/../../classes/CopyOps.php");

require_once(dirname(__FILE__)."/AbstractService.php");

class MinimalService extends AbstractService {
	
	var $db;

	function __construct() {
		parent::__construct();
		
		// A unique ID to distinguish sessions between multiple Clarity applications
		Session::setSessionName("Minimal");
				
		// Set the product name and userID for logging
		AbstractService::$log->setProductName("MINIMAL");

		// Set the title name for resources
		AbstractService::$title = "rm";
		
		// v3.4 For internal queries - how to use a different dbHost?
		$this->internalQueryOps = new InternalQueryOps($this->db);
		$this->manageableOps = new ManageableOps($this->db);
		
		// DMS has no restrictions on user/group access so disable manageable authentication
		AuthenticationOps::$useAuthentication = false;
		
	}
	
	public function checkDirectStartSecurityCode($securityCode) {
		// This looks up the securityCode in the database. If found it returns the related details.
		global $db;
		// Update to stop changing the security codes every month - just do it once
		//		AND F_ValidUntilDate>=?
		//$bindingParams = array($securityCode, date('Y-m-d'));
		$sql = 	<<<EOD
				SELECT *
				FROM T_DirectStart
				WHERE F_SecureString = ?
EOD;
		$bindingParams = array($securityCode);
		//echo $sql;
		//print_r($bindingParams);
		$rs = $this->db->Execute($sql, $bindingParams);		
		//echo $rs->RecordCount();
		switch ($rs->RecordCount()) {
			case 0:
				return false;
				break;
			case 1:
			default:
				// More than one matching security code? Hmm, just take the first.
		}
		$info = $rs->FetchNextObj();
		$relatedUser = new User();
		$relatedUser->name = $info->F_UserName;
		$relatedUser->password = $info->F_Password;
		$relatedUser->email = $info->F_Email;

		return $relatedUser;
	}
	
}