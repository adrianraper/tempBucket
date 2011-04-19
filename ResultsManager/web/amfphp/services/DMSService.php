<?php
/**
 */
require_once(dirname(__FILE__)."/../../config.php");
 
require_once($GLOBALS['adodb_libs']."adodb-exceptions.inc.php");
require_once($GLOBALS['adodb_libs']."adodb.inc.php");

require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/Reportable.php");

require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/Manageable.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/User.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/Group.php");

require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/content/Content.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/content/Title.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/content/Course.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/content/Unit.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/content/Exercise.php");

require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/account/Account.php");
// v3.1 Add for trigger processing
require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/trigger/Trigger.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/trigger/Condition.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/email/TemplateDefinition.php");

require_once(dirname(__FILE__)."/../../classes/AuthenticationOps.php");
require_once(dirname(__FILE__)."/../../classes/LoginOps.php");
require_once(dirname(__FILE__)."/../../classes/CopyOps.php");
require_once(dirname(__FILE__)."/../../classes/ManageableOps.php");
require_once(dirname(__FILE__)."/../../classes/ContentOps.php");
require_once(dirname(__FILE__)."/../../classes/LicenceOps.php");
require_once(dirname(__FILE__)."/../../classes/UsageOps.php");
require_once(dirname(__FILE__)."/../../classes/ReportOps.php");
require_once(dirname(__FILE__)."/../../classes/ImportXMLParser.php");

require_once(dirname(__FILE__)."/../../classes/AccountOps.php");
require_once(dirname(__FILE__)."/../../classes/TemplateOps.php");
require_once(dirname(__FILE__)."/../../classes/EmailOps.php");

// v3.1 New trigger module
require_once(dirname(__FILE__)."/../../classes/TriggerOps.php");

require_once(dirname(__FILE__)."/AbstractService.php");

class DMSService extends AbstractService {
	
	var $db;

	function DMSService() {
		parent::_AbstractService();
		
		// A unique ID to distinguish sessions between multiple Clarity applications
		Session::setSessionName("DMS");
		
		// Set the product name and userID for logging
		AbstractService::$log->setProductName("DMS");
		if (Session::is_set('userID')) {
			AbstractService::$log->setUserID(Session::get('userID'));
		};
		//NetDebug::trace('DMSservice.constructor.getDetails='.AbstractService::$log->getDetails());
		//NetDebug::trace('Abstract service.session.userID='.Session::get('userID'));
		
		// Create the operation classes
		$this->loginOps = new LoginOps($this->db);
		$this->copyOps = new CopyOps($this->db);
		
		$this->accountOps = new AccountOps($this->db);
		$this->templateOps = new TemplateOps($this->db);
		$this->emailOps = new EmailOps($this->db);
		$this->licenceOps = new LicenceOps($this->db);
		$this->manageableOps = new ManageableOps($this->db);
		
		// v3.1 New trigger module
		$this->triggerOps = new TriggerOps($this->db);
		// v3.2 For Reporting
		$this->usageOps = new UsageOps($this->db);
		
		// DMS has no restrictions on user/group access so disable manageable authentication
		AuthenticationOps::$useAuthentication = false;
		
	}
	
	function login($username, $password, $rootID = null) {
		// Only users of type USER_TYPE_DMS are allowed to login to DMS
		$loginObj = $this->loginOps->login($username, $password, array(User::USER_TYPE_DMS, User::USER_TYPE_DMS_VIEWER), $rootID);
		
		if ($loginObj) {
			// Set the identity and rootID for logging. Also see the above constructor
			AbstractService::$log->setIdent($loginObj->F_UserID);
			
			// DMS specific setup values for this root
			Session::set('languageCode', "EN");
			
			return array("userID" => (int)$loginObj->F_UserID,
						 "userType" => (int)$loginObj->F_UserType,
						 "languageCode" => "EN");
		} else {
			// Invalid username/password
			return false;
		}
	}
	
	function logout() {
		$this->loginOps->logout();
	}
	
	/**
	 * Get the copy XML document
	 */
	function getCopy() {
		return $this->copyOps->getCopy();
	}
	
	function getAccounts($accountIDArray = null, $conditions = null, $sortOrder = null) {
		// v3.6.1 You often fail to load DMS, so can I increase php script execution time just for this call?
		// Well, you can run this command here fine. But where will you set it back down to the default?
		if (!ini_get('safe_mode')) { 
			ini_set('max_execution_time', 60); // in seconds
		}
		return $this->accountOps->getAccounts($accountIDArray, $conditions, $sortOrder);
	}
	// v3.1 New function to delay picking up all the account details that are not essential for main list display
	function getAccountDetails($accountID) {
		return $this->accountOps->getAccountLicenceDetails($accountID);
	}
	
	var $addAccountRoles = array(User::USER_TYPE_DMS);
	// v3.1 AccountOps.addAccount doesn't expect a second parameter, adminUser is a part of account.
	function addAccount($account, $adminUser = null) {
		return $this->accountOps->addAccount($account, $adminUser);
	}
	
	var $updateAccountsRoles = array(User::USER_TYPE_DMS);
	function updateAccounts($accounts) {
		return $this->accountOps->updateAccounts($accounts);
	}
	
	var $deleteAccountsRoles = array(User::USER_TYPE_DMS);
	function deleteAccounts($accounts) {
		return $this->accountOps->deleteAccounts($accounts);
	}
	
	function getEmailTemplates() {
		return $this->templateOps->getTemplates("emails");
	}
	
	function getReportTemplates() {
		return $this->templateOps->getTemplates("dms_reports");
	}
	
	/*
	 * Copied from RM - not necessary
	 *
	function getAllManageables() {
		return $this->manageableOps->getAllManageables();
	}
	
	function getContent() {
		return $this->contentOps->getContent();
	}
	
	function addGroup($group, $parentGroup) {
		return $this->manageableOps->addGroup($group, $parentGroup);
	}
	
	function addUser($user, $parentGroup) {
		return $this->manageableOps->addUser($user, $parentGroup);
	}
	
	function updateGroups($groupsArray) {
		return $this->manageableOps->updateGroups($groupsArray);
	}
	
	function updateUsers($usersArray) {
		return $this->manageableOps->updateUsers($usersArray);
	}
	
	function moveManageables($manageables, $parentGroup) {
		return $this->manageableOps->moveManageables($manageables, $parentGroup);
	}
	
	function deleteManageables($manageablesArray) {
		return $this->manageableOps->deleteManageables($manageablesArray);
	}
	
	function importXMLFromUpload($parentGroup) {
		return $this->manageableOps->importXMLFromUpload($parentGroup);
	}
	
	function importManageables($groups, $users, $parentGroup) {
		return $this->manageableOps->importManageables($groups, $users, $parentGroup);
	}
	
	function getLicences() {
		return $this->licenceOps->getLicences();
	}
	
	function allocateLicences($userIdArray, $productCode) {
		return $this->licenceOps->allocateLicences($userIdArray, $productCode);
	}
	
	function unallocateLicences($userIdArray, $productCode) {
		return $this->licenceOps->unallocateLicences($userIdArray, $productCode);
	}
	
	function getExtraGroups($user) {
		return $this->manageableOps->getExtraGroups($user->id);
	}
	
	function setExtraGroups($user, $groupsArray) {
		return $this->manageableOps->setExtraGroups($user, $groupsArray);
	}
	
	function getUsageForTitle($title, $fromDate, $toDate) {
		return $this->usageOps->getUsageForTitle($title, $fromDate, $toDate);
	}
	
	function getReport($onReportableIDObjects, $onClass, $forReportableIDObjects, $forClass, $reportOpts) {
		// Since we are potentially passing a lot of reportables to this from the client pass IDs instead of VOs to save on transfer overhead
		return $this->reportOps->getReport($onReportableIDObjects, $onClass, $forReportableIDObjects, $forClass, $reportOpts);
	}
	
	function getHiddenContent() {
		return $this->contentOps->getHiddenContent();
	}
	
	function setHiddenContent($contentIDObjects, $groupIDArray, $visible) {
		return $this->contentOps->setHiddenContent($contentIDObjects, $groupIDArray, $visible);
	}*/
	
	// Get DMS dictionary
	protected function getDictionary($dictionaryName) {
		return $this->accountOps->getDictionary($dictionaryName);
	}
	
}

?>