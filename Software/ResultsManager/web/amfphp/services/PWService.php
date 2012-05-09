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

require_once(dirname(__FILE__)."/../../classes/AuthenticationOps.php");
require_once(dirname(__FILE__)."/../../classes/AccountOps.php");
require_once(dirname(__FILE__)."/../../classes/LoginOps.php");
require_once(dirname(__FILE__)."/../../classes/CopyOps.php");
require_once(dirname(__FILE__)."/../../classes/ContentOps.php");
require_once(dirname(__FILE__)."/../../classes/UsageOps.php");
require_once(dirname(__FILE__)."/../../classes/LicenceOps.php");
//require_once(dirname(__FILE__)."/../../classes/EmailOps.php");
//require_once(dirname(__FILE__)."/../../classes/TemplateOps.php");
require_once(dirname(__FILE__)."/../../classes/ManageableOps.php");

require_once(dirname(__FILE__)."/AbstractService.php");

class PWService extends AbstractService {
	
	var $db;

	function __construct() {
		parent::__construct();
		
		// A unique ID to distinguish sessions between multiple Clarity applications
		Session::setSessionName("PW");
		
		// Set the product name and userID for logging
		AbstractService::$log->setProductName("PW");
		if (Session::is_set('userID')) {
			AbstractService::$log->setUserID(Session::get('userID'));
			AbstractService::$log->setIdent(Session::get('userID'));
		};
		
		// Set the title name for resources
		AbstractService::$title = "rm";
		
		// Set the root id (if set)
		AbstractService::$log->setRootID(Session::get('rootID'));
		
		// Create the operation classes
		$this->loginOps = new LoginOps($this->db);
		$this->copyOps = new CopyOps($this->db);
		$this->contentOps = new ContentOps($this->db);
		$this->usageOps = new UsageOps($this->db);
		$this->accountOps = new AccountOps($this->db);

	}
	
	public function login($username, $password, $rootID = null, $productCode = null) {
		$allowedUserTypes = array(User::USER_TYPE_TEACHER,
								 User::USER_TYPE_ADMINISTRATOR,
								 User::USER_TYPE_AUTHOR,
								 User::USER_TYPE_STUDENT,
								 User::USER_TYPE_REPORTER);
								 
		$loginObj = $this->loginOps->login($username, $password, $allowedUserTypes, $rootID, $productCode);
		
		if ($loginObj) {			
			// RM specific setup values for this root
			if (isset($loginObj->F_LangaugeCode) && strlength($loginObj->F_LanguageCode)>0) {
				Session::set('languageCode', $loginObj->F_LanguageCode);
			} else {
				Session::set('languageCode', 'EN');
			}
			Session::set('rootID', $loginObj->F_RootID);
			Session::set('rootGroupID', $loginObj->F_GroupID);
			
			return array("userID" => (int)$loginObj->F_UserID,
						 "userType" => (int)$loginObj->F_UserType,
						 "languageCode" => $loginObj->F_LanguageCode,
						 "groupID" => $loginObj->F_GroupID,
						 "rootID" => $loginObj->F_RootID,
						 "startDate" => $loginObj->UserStartDate);
		} else {
			//NetDebug::trace('originalStartPage='.$_SESSION['originalStartpage'].'!');
			NetDebug::trace('db used '.$GLOBALS['db']);
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

	/**
	 * Get the content that this PW needs
	 */
	public function getContent($rootID, $productCode = null) {
		//NetDebug::trace('PW.getContent.productCode='.$productCode);
		//return array("productCode" => $productCode);
		// But maybe I don't want restricted content, instead looking for all content this account has access to
		// I can then filter it as necessary. I do this because of AP titles within the EMU.
		// It is also good because if one account doesn't have access to a title listed in the EMU for some reason, it won't appear here.
		//return $this->contentOps->getRestrictedContent($productCode);
		// But it is also very bad for accounts that include IYJ amongst many others. So use a $productCode list to filter by.
		// v3.2 I am getting problems with rootID and userID staying in session variables.
		// For ProgressWidget I am always going to be passing these as parameters, so don't use session. Or reset it?
		//if (!Session::is_set('rootID')) Session::set('rootID', $rootID);
		if (isset($rootID)) Session::set('rootID', $rootID);
		return $this->contentOps->getRestrictedContent($productCode);
	}
	
	/**
	 * Get the progress records for the passed reportables.
	 * Differentiate if you want AP and EMU records back separately
	 */
	public function getCoverage($reportable, $userID, $startDate = 0, $endDate = 0, $singleStyle = null) {
		//NetDebug::trace("PWService.userID= ".$userID);
		//NetDebug::trace("PWService.userDetails.rootID= ".$userDetails->rootID);
		//NetDebug::trace("PWService.userDetails.productCode= ".$userDetails->productCode);
		// Just need userID for this call. Pull it first from session if you logged in.
		// v3.2 I am getting problems with rootID and userID staying in session variables.
		// For ProgressWidget I am always going to be passing these as parameters, so don't use session. Or reorder?
		if (isset($userID)) {
			$myUserID = $userID;
			NetDebug::trace("PWService.use passed userID= ".$myUserID);
			Session::set('userID', $userID);
		} else if (Session::is_set('userID')) {
			$myUserID = Session::is_set('userID');
			NetDebug::trace("PWService.use session userID= ".$myUserID);
		} else {
			//NetDebug::trace("PWService. no userID");
			return Array();
		}
		//NetDebug::trace('PW.getContent.productCode='.$productCode);
		return $this->usageOps->getCoverage($reportable, $startDate, $endDate, $myUserID, $singleStyle);
	}
	
	/**
	 * Repeat for everybody.
	 * Include country if you want to filter.
	 */
	public function getEveryonesCoverage($reportable, $userID, $rootID=null, $country=null, $startDate=0, $endDate=0) {
		// Need userID (to exclude it) and then perhaps rootID and country if you want to filter by a limited set of others
		if (isset($userID)) {
			$myUserID = $userID;
		} else if (Session::is_set('userID')) {
			$myUserID = Session::is_set('userID');
		} else {
			return Array();
		}
		if (isset($rootID)) {
			$myRootID = $rootID;
		} else if (Session::is_set('rootID')) {
			$myRootID = Session::is_set('rootID');
		}
		//NetDebug::trace('PW.getContent.productCode='.$productCode);
		return $this->usageOps->getEveryonesCoverage($reportable, $startDate, $endDate, $myUserID, $myRootID, $country);
	}
	
}