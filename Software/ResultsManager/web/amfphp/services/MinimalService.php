<?php
/**
 * Used when you don't need the full ClarityService
 */

require_once(dirname(__FILE__)."/../../config.php");
 
require_once($GLOBALS['adodb_libs']."adodb-exceptions.inc.php");
require_once($GLOBALS['adodb_libs']."adodb.inc.php");

require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/Reportable.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/content/Course.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/content/Title.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/content/Bookmark.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/Group.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/User.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/account/Subscription.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/trigger/Trigger.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/trigger/Condition.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/account/Account.php");

require_once(dirname(__FILE__)."/../../classes/AuthenticationOps.php");
require_once(dirname(__FILE__)."/../../classes/ManageableOps.php");

// v3.4 This is used for internal queries
require_once(dirname(__FILE__)."/../../classes/InternalQueryOps.php");

// v3.4 This is used for daily jobs
require_once(dirname(__FILE__)."/../../classes/DailyJobObs.php");

// Common ops
require_once(dirname(__FILE__)."/../../classes/ManageableOps.php");
require_once(dirname(__FILE__)."/../../classes/ContentOps.php");
require_once(dirname(__FILE__)."/../../classes/CopyOps.php");
require_once(dirname(__FILE__)."/../../classes/AccountOps.php");
require_once(dirname(__FILE__)."/../../classes/TemplateOps.php");
require_once(dirname(__FILE__)."/../../classes/EmailOps.php");
require_once(dirname(__FILE__)."/../../classes/CourseOps.php");
require_once(dirname(__FILE__)."/../../classes/TriggerOps.php");
require_once(dirname(__FILE__)."/../../classes/SubscriptionOps.php");
require_once(dirname(__FILE__)."/../../classes/MemoryOps.php");

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
		
		// v3.4 For internal queries
		$this->internalQueryOps = new InternalQueryOps($this->db);
		
		$this->manageableOps = new ManageableOps($this->db);
		$this->emailOps = new EmailOps($this->db);
		
		// gh#122 for daily jobs
		$this->dailyJobOps = new DailyJobObs($this->db);
		$this->courseOps = new CourseOps($this->db);
		$this->triggerOps = new TriggerOps($this->db);
		$this->subscriptionOps = new SubscriptionOps($this->db);
		$this->memoryOps = new MemoryOps($this->db);
		
		// DMS has no restrictions on user/group access so disable manageable authentication
		AuthenticationOps::$useAuthentication = false;
		
	}

	/**
	 * This function should be called by the first call you make to this service to set the dbHost
	 * 
	 */
	private function initDbHost($dbHost) {
		if ($GLOBALS['dbHost'] != $dbHost) {
				
			// Set session variable so that next time config.php is called it will use this dbHost
			// Which should mean that you only need to pick up dbHost for the first call to a service
			// But it would be much better if I could pass dbHost direct to the service so it simply
			// did this check in the constructor.
			$_SESSION['dbHost'] = $dbHost;
			
			$this->changeDB($dbHost);
		}
	}
		
	public function changeDB($dbHost) {
		$this->changeDbHost($dbHost);
		
		$this->manageableOps->changeDB($this->db);
		$this->emailOps->changeDB($this->db);
		$this->internalQueryOps->changeDB($this->db);
		$this->dailyJobOps->changeDB($this->db);
		$this->courseOps->changeDB($this->db);
		$this->triggerOps->changeDB($this->db);
		$this->subscriptionOps->changeDB($this->db);
		$this->memoryOps->changeDB($this->db);
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