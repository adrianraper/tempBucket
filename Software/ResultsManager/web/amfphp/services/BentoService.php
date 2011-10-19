<?php
/**
 * Called from amfphp gateway from Flex
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

// v3.4 To allow the account root information to be passed back to RM
require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/account/Account.php");

require_once(dirname(__FILE__)."/../../classes/AuthenticationOps.php");
require_once(dirname(__FILE__)."/../../classes/LoginOps.php");
require_once(dirname(__FILE__)."/../../classes/CopyOps.php");
require_once(dirname(__FILE__)."/../../classes/ManageableOps.php");
require_once(dirname(__FILE__)."/../../classes/ContentOps.php");

// v3.6 What happens if I want to add in AccountOps so that I can pull back the account object?
// I already getContent - will that clash or duplicate?
require_once(dirname(__FILE__)."/../../classes/AccountOps.php");

require_once(dirname(__FILE__)."/AbstractService.php");

class BentoService extends AbstractService {
	
	var $db;

	function BentoService() {
		parent::_AbstractService();
		
		// A unique ID to distinguish sessions between multiple Clarity applications
		Session::setSessionName("Bento");
		
		// Set the product name for logging
		AbstractService::$log->setProductName("Bento");
		
		// Set the root id (if set)
		// I am now using is_set, but is that safe? If not set it might be an error. 
		if (Session::is_set('userID')) {
			AbstractService::$log->setIdent(Session::get('userID'));
		};
		if (Session::is_set('rootID')) {
			AbstractService::$log->setRootID(Session::get('rootID'));
		};
		
		// Create the operation classes
		$this->accountOps = new AccountOps($this->db);
		$this->loginOps = new LoginOps($this->db);
		$this->copyOps = new CopyOps($this->db);
		$this->manageableOps = new ManageableOps($this->db);
		$this->contentOps = new ContentOps($this->db);

	}
	/**
	 *
	 * This call finds the relevant account, keyed on rootID [or prefix].
	 * Additionally it gets configuration data for this title.
	 * @param config - an object containing the keys to get the account
	 * rootID, [prefix,] productCode
	 * dbHost
	 * @return account - Account object - includes the ONE relevant title and any relevant licence attributes 
	 * @return config - Miscellaneous information, such as database version 
	 * @return error - Error object if required 
	 */
	function getAccountSettings($config) {
	
		$errorObj = array("errorNumber" => 0);
		
		// Send the passed data through to the SQL
		if (isset($config['productCode'])) {
			$productCode = $config['productCode'];
		} else {
			$errorObj['errorNumber']=100; // Need a generalised db error number
			$errorObj['errorContext']='No productCode sent to getAccountSettings';
			// Can I throw an Exception that will be caught the moment I find an error?
			// Or just return here?
			return array("error" => $errorObj);
		}
		// RootID is more important than prefix.
		if (isset($config['rootID'])) {
			$rootID = $config['rootID'];
			
		// TODO. At present getAccounts can only cope with rootID not prefix. That should be OK
		//} else if (isset($config['prefix'])) {
		//	$prefix = $config['prefix'];
		
		} else {
			$errorObj['errorNumber']=100; // Need a generalised db error number
			$errorObj['errorContext']='No rootID sent to getAccountSettings';
			return array("error" => $errorObj);
		}
		
		// Query the database
		// First get the record from T_AccountRoot and T_Accounts
		$conditions = array("productCode" => $productCode);
		$accounts = $this->accountOps->getAccounts(array($rootID), $conditions);
		
		// It would be an error to have more or less than one account
		if (count($accounts)==1) {
			$account = $accounts[0];
		} else if (count($accounts)>1) {
			$errorObj['errorNumber']=100; 
			$errorObj['errorContext']="More than one account with rootID $rootID";
			return array("error" => $errorObj);
		} else {
			$errorObj['errorNumber']=100; 
			$errorObj['errorContext']="No account with rootID $rootID";
			return array("error" => $errorObj);
		}
		
		// It would also be an error to have more or less than one title in that account
		if (count($account->titles)>1) {
			$errorObj['errorNumber']=100;
			$errorObj['errorContext']="More than one title with productCode $productCode";
			return array("error" => $errorObj);
		} else if (count($accounts)==0) {
			$errorObj['errorNumber']=100; 
			$errorObj['errorContext']="No title with productCode $productCode in rootID $rootID";
			return array("error" => $errorObj);
		} 
		
		// Next get account licence details, which are not pulled in from getAccounts as DMS doesn't usually want them
		$account->addLicenceAttributes($this->accountOps->getAccountLicenceDetails($rootID, $productCode));

		// We also need some misc stuff.
		$configObj = array("databaseVersion" => $this->getDatabaseVersion());

		// Set some session variables that other calls will use
		Session::set('rootID', $rootID);
		Session::set('productCode', $productCode);
				
		/*
		// Comment until DK has database setup
		// Fake the database return for now
		
		// Title
		$title = new Title();
		$title->id = $productCode;
		$title->expiryDate = '2012-12-31 00:00:00';
		$title->licenceStartDate = '2011-01-01-00:00:00';
		$title->contentLocation = 'RoadToIELTS2-Academic';
		$title->licenceType = 1;
		
		// Account
		$account = new Account();
		$account->rootID = 163;
		$account->prefix = 'DEV';
		$account->name = 'Clarity DEV account';
		$account->tacStatus = 2;
		$account->accountStatus = 1;
		$account->loginOptions = 2;
		$account->verified = 'true';
		$account->selfRegister = 'false';
		$account->addTitles(array($title));
		
		// Misc
		$configObj = array("databaseVersion" => 7);
		*/
		
		return array("error" => $errorObj, 
					"config" => $configObj,
					"account" => $account);
	}
	// Rewritten from RM version
	// Assume that dbHost is handled in config.php
	// Assume, for now, that rootID and productCode were put into session variables by getAccountDetails
	// otherwise they need to be passed with every call.
	function startUser($username, $studentID, $email, $password, $loginOption, $instanceID) {
	
		$errorObj = array("errorNumber" => 0);
		
		$rootID = Session::get('rootID');
		$productCode = Session::get('productCode');
	
		$allowedUserTypes = array(User::USER_TYPE_TEACHER,
								 User::USER_TYPE_ADMINISTRATOR,
								 User::USER_TYPE_AUTHOR,
								 User::USER_TYPE_LEARNER,
								 User::USER_TYPE_REPORTER);
								 
		// First, confirm that the user details are correct
		// This might return an error object or a user object		 
		$userObj = $this->loginOps->getUser($username, $studentID, $email, $password, $loginOption, $allowedUserTypes, $rootID, $productCode);
		if (isset($userObj['errorNumber'])) {
			return array("error" => $userObj);
		} else {
			Session::set('userID', $userObj->F_UserID);
			$user = new User();
			$user->fromDatabaseObject($userObj);
		}
		
		// Then get the group that this user belongs to.
		// TODO. Do we want an entire hierarchy of groups here so we can do hiddenContent stuff? 
		$groupObj = $this->loginOps->getGroup($userID);
		// This might return an error object or a group object		 
		if (isset($groupObj['errorNumber'])) {
			return array("error" => $groupObj);
		} else {
			$group = new Group();
			$group->fromDatabaseObject($groupObj);
		}
		
		// Add the user into the group
		$group->addManageables(array($user));
				
		// Next we need to set the instance ID for the user
		$rc = $this->loginOps->setInstanceID($userID, $instanceID);
		if (!$rc) {
			$errorObj['errorNumber']=100; 
			$errorObj['errorContext']="Can't set the instance ID for the user $userID";
			return array("error" => $errorObj);
		}
		
		// General config information - though you don't know which course they are going to start yet
		$contentObj = $this->loginOps->getBookmark($userID, $productCode);
		// This might return an error object or a group object		 
		if (isset($contentObj['errorNumber'])) {
			return array("error" => $contentObj);
		} else {
			// TODO. What is a good format for sending back bookmark information?
			// For now I will just expect an array of courseIDs that this user has started so that
			// you can use them in licence control.
		}
		
		// Send this information back
		return array("error" => $errorObj,
					"group" => $groupObj,
					"content" => $contentObj);
		
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
	
	/**
	 * Get the current database version number
	 */
	function getDatabaseVersion() {
		
		$sql = <<< EOD
				SELECT MAX(F_VersionNumber) as versionNumber 
				FROM T_DatabaseVersion;
EOD;
		$rs = $this->db->Execute($sql);	
		if ($rs) 
			return $rs->FetchNextObj()->versionNumber;
			
		return 0;
	}
	
}

?>