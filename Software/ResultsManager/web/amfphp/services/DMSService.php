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

// gh#125
require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/account/Account.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/account/Licence.php");

// v3.1 Add for trigger processing
require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/trigger/Trigger.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/trigger/Condition.php");
// v3.6 Added for direct sending via API
require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/trigger/EmailAPI.php");
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

// v3.4 This is used for internal queries
require_once(dirname(__FILE__)."/../../classes/InternalQueryOps.php");

// V4.3 New subscription classes
require_once(dirname(__FILE__)."/../../classes/SubscriptionOps.php");

// v3.1 New trigger module
require_once(dirname(__FILE__)."/../../classes/TriggerOps.php");

// gh#1067
require_once(dirname(__FILE__)."/../../classes/MemoryOps.php");

require_once(dirname(__FILE__)."/AbstractService.php");

class DMSService extends AbstractService {
	
	var $db;

	function __construct() {
		parent::__construct();
		
		// A unique ID to distinguish sessions between multiple Clarity applications
		Session::setSessionName("DMS");
		
		// Set the product name and userID for logging
		AbstractService::$log->setProductName("DMS");
		
		// Set the title name for resources (DMS shares resources with rm so use rm for this too)
		AbstractService::$title = "rm";
		
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
		//$this->licenceOps = new LicenceOps($this->db);
		$this->manageableOps = new ManageableOps($this->db);
		
		// v3.1 New trigger module
		$this->triggerOps = new TriggerOps($this->db);
		// v3.2 For Reporting
		$this->usageOps = new UsageOps($this->db);
		// v3.2 For shopping cart
		$this->subscriptionOps = new SubscriptionOps($this->db);
		
		// v3.4 For internal queries - how to use a different dbHost?
		$this->internalQueryOps = new InternalQueryOps($this->db);
		
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
			
			// Use AbstractService
			$this->changeDbHost($dbHost);
			
			// Just need to change the db for Ops that you use in the first call
			$this->loginOps->changeDB($this->db);
			$this->manageableOps->changeDB($this->db);
		}
	}
	
	public function login($username, $password, $rootID = null) {
		
		// #353 This first call might change the dbHost that the session uses
		if ($dbHost)
			$this->initDbHost($dbHost);

		// Only users of type USER_TYPE_DMS are allowed to login to DMS
		$loginObj = $this->loginOps->login($username, $password, array(User::USER_TYPE_DMS, User::USER_TYPE_DMS_VIEWER), $rootID);
		
		//NetDebug::trace('originalStartPage='.$_SESSION['originalStartpage'].'!');
		if (isset($_SESSION['dbHost'])) {
			NetDebug::trace('DMSService session.dbHost='.$_SESSION['dbHost']);
		} else {
			NetDebug::trace('DMSService session.dbHost not set');
		}
		// We don't want to tell anyone the password of the connection string
		$pattern = '/([a-zA-Z0-9]+):\/\/([a-zA-Z0-9]+):([a-zA-Z0-9]+)@([a-zA-Z0-9-_.]+)\/([a-zA-Z0-9]+)/';
		$replace = '\1://\2:********@\4/\5';
		$dbDetails = preg_replace($pattern, $replace, $GLOBALS['db']);
		NetDebug::trace('db used '.$dbDetails);
		
		if ($loginObj) {
			// Set the identity and rootID for logging. Also see the above constructor
			AbstractService::$log->setIdent($loginObj->F_UserID);
			
			// DMS specific setup values for this root
			Session::set('languageCode', "EN");
			
			return array("userID" => (int)$loginObj->F_UserID,
						 "userType" => (int)$loginObj->F_UserType,
						 "languageCode" => "EN",
						 "dbDetails" => $dbDetails);
		} else {
			// Invalid username/password
			return false;
		}
	}
	
	public function logout() {
		$this->loginOps->logout();
	}
	
	/**
	 * Get the copy XML document
	 */
	public function getCopy() {
		return $this->copyOps->getCopy();
	}
	
	public function getAccounts($accountIDArray = null, $conditions = null, $sortOrder = null) {
		// v3.6.1 You often fail to load DMS, so can I increase php script execution time just for this call?
		// Well, you can run this command here fine. But where will you set it back down to the default?
		// Oddly this seems to fail if we are running through a load balancer. It works directly on each individual IP/server
		//if (!ini_get('safe_mode')) { 
		//	ini_set('max_execution_time', 60); // in seconds
		//}
		set_time_limit(60);
		return $this->accountOps->getAccounts($accountIDArray, $conditions, $sortOrder);
	}
	
	// v3.1 New function to delay picking up all the account details that are not essential for main list display
	public function getAccountDetails($accountID) {
		return $this->accountOps->getAccountLicenceDetails($accountID);
	}
	
	var $addAccountRoles = array(User::USER_TYPE_DMS);
	// v3.1 AccountOps.addAccount doesn't expect a second parameter, adminUser is a part of account.
	public function addAccount($account, $adminUser = null) {
		return $this->accountOps->addAccount($account, $adminUser);
	}
	
	var $updateAccountsRoles = array(User::USER_TYPE_DMS);
	public function updateAccounts($accounts) {
		return $this->accountOps->updateAccounts($accounts);
	}
	
	var $deleteAccountsRoles = array(User::USER_TYPE_DMS);
	public function deleteAccounts($accounts) {
		return $this->accountOps->deleteAccounts($accounts);
	}
	
	public function getEmailTemplates() {
		return $this->templateOps->getTemplates("emails");
	}
	
	public function getReportTemplates() {
		return $this->templateOps->getTemplates("dms_reports");
	}
	
	// v3.4 For regular internal queries. Better to call direct and not clutter up here
	//function getGlobalR2IUser() {
	//	return $this->internalQueryOps->getGlobalR2IUser($id);
	//}
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

	/**
	 * Very specific function to return the first student in an account. Used for AA student passwords.
	 */
	public function getFirstStudentInAccount($rootID) {
		return array_shift($this->manageableOps->getAllLearners($rootID));
	}
}