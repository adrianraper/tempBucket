<?php
/**
 * Handles the different functions of login and user registration
 */
require_once(dirname(__FILE__)."/../../config.php");
 
require_once($GLOBALS['adodb_libs']."adodb-exceptions.inc.php");
require_once($GLOBALS['adodb_libs']."adodb.inc.php");

require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/Reportable.php");

require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/Manageable.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/User.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/Group.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/LoginAPI.php");

require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/trigger/EmailAPI.php");

require_once(dirname(__FILE__)."/../../classes/CopyOps.php");
require_once(dirname(__FILE__)."/../../classes/TemplateOps.php");
require_once(dirname(__FILE__)."/../../classes/EmailOps.php");
require_once(dirname(__FILE__)."/../../classes/ManageableOps.php");
require_once(dirname(__FILE__)."/AbstractService.php");

class LoginService extends AbstractService {
	
	var $db;

	function LoginService() {
		parent::_AbstractService();
		
		// A unique ID to distinguish sessions between multiple Clarity applications
		Session::setSessionName("LOGIN");
		
		// Set the product name and userID for logging
		AbstractService::$log->setProductName("LOGIN");
		
		$this->manageableOps = new ManageableOps($this->db);
		
		// DMS has no restrictions on user/group access so disable manageable authentication
		AuthenticationOps::$useAuthentication = false;
	}
	
	// Can you find this user?
	function getUser($loginDetails) {
		$stubUser = new User();
		$stubUser->studentID = $loginDetails->studentID;
		return $this->manageableOps->getUserByLearnerId($stubUser);
	}
	// Add this user
	function addUser($loginDetails) {
		$stubUser = new User();
		$stubUser->studentID = $loginDetails->studentID;
		
		// What kind of authentication needs to be set before this will work?
		$group = $this->manageableOps->getGroup($loginDetails->groupID);
		 
		return $this->manageableOps->addUser($stubUser, $group, $loginDetails->rootID);
	}
	
}
?>