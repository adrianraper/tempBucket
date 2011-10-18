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
	 * This call finds the relevant account, keyed on rootID or prefix.
	 * Additionally it gets configuration data for this title.
	 * @param config - an object containing the keys to get the account
	 * rootID, [prefix,] productCode
	 * dbHost
	 * @return account - Account object - includes the ONE relevant title 
	 * @return title - Title object 
	 * @return config - Miscellaneous information, such as database version 
	 * @return error - Error object if required 
	 */
	function getRMSettings($config) {
	
		$errorObj = array();
		
		// Send the passed data through to the SQL
		if (isset($config['productCode'])) {
			$productCode = $config['productCode'];
		} else {
			$errorObj['errorNumber']=100; // Need a generalised db error number
			$errorObj['errorDescription']='No productCode sent to getRMSettings';
		}
		// RootID is more important than prefix.
		if (isset($config['rootID'])) {
			$rootID = $config['rootID'];
			
		// TODO. At present getAccounts can only cope with rootID not prefix. That should be OK
		//} else if (isset($config['prefix'])) {
		//	$prefix = $config['prefix'];
		
		} else {
			$errorObj['errorNumber']=100; // Need a generalised db error number
			$errorObj['errorContext']='No rootID sent to getRMSettings';
		}
		
		// Query the database
		/*
		// Comment until DK has database setup
		// First get the record from T_AccountRoot and T_Accounts
		$conditions = array("productCode" => $productCode);
		$accounts = $this->accountOps->getAccounts(array($rootID), $conditions);
		// It would be an error to have more than one account
		$account = $accounts[0];
		
		// We also need some misc stuff (do we really?)
		//   databaseVersion
		//$configObj = $this->loginOps->getConfig();
		*/
		
		//*
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
		//*/
		
		// Misc
		$config = array("databaseVersion" => 7);
		
		return array("error" => $errorObj, 
					"config" => $config,
					"account" => $account);
	}
	// Allow several optional parameters to come from Flash
	// $productCode is deprecated
	function login($username, $password, $rootID = null, $dbHost=null, $productCode = null) {
		$allowedUserTypes = array(User::USER_TYPE_TEACHER,
								 User::USER_TYPE_ADMINISTRATOR,
								 User::USER_TYPE_AUTHOR,
								 User::USER_TYPE_LEARNER,
								 User::USER_TYPE_REPORTER);
								 
		$loginObj = $this->loginOps->login($username, $password, $allowedUserTypes, $rootID, $productCode);
		
		if ($loginObj) {	
			Session::set('rootID', $loginObj->F_RootID);
			
			// v3.5 Add dbHost if we want anything other than default.
			// Duh, can't do it here as you have already read dbDetails!
			if ($dbHost)
				Session::set('dbHost', $dbHost);

			// v3.4 I would like to send back (some) account root information as well (remember that accounts in RM means titles)
			// v3.6 Maybe it is better to do a separate getAccount call as I also want things like adminUser's email
			$accountRoot = $this->manageableOps->getAccountRoot($loginObj->F_RootID);
			//NetDebug::trace('accountRoot='.$accountRoot->prefix);

			// v3.5 Checking on data types. F_UserID is converted to string in LoggedInCommand
			// noStudents means don't display students, not number of students! So it is converted to boolean
			// v3.5 You really need to send this back as a user or account or title or something rather than all these variables.
			return array("userID" => (int)$loginObj->F_UserID,
						 "userType" => (int)$loginObj->F_UserType,
						 "languageCode" => $loginObj->F_LanguageCode,
						 "prefix" => $accountRoot->prefix,
						 "groupID" => (int)$loginObj->F_GroupID,
						 "userName" => $loginObj->F_UserName, // Do you need htmlspecialchars here for odd names? Or does amfphp handle it all?
						 "password" => $password,
						 "accountName" => $accountRoot->name,
						 "licenceType" => (int)$loginObj->F_LicenceType,
						 );
		} else {
			//NetDebug::trace('originalStartPage='.$_SESSION['originalStartpage'].'!');
			if (isset($_SESSION['dbHost'])) {
				NetDebug::trace('BentoService session.dbHost='.$_SESSION['dbHost']);
			} else {
				NetDebug::trace('BentoService session.dbHost not set');
			}
			NetDebug::trace('db used '.$GLOBALS['db']);
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
	
}

?>