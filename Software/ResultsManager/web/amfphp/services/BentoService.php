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

require_once(dirname(__FILE__)."/vo/com/clarityenglish/bento/vo/progress/Progress.php");

// v3.4 To allow the account root information to be passed back to RM
require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/account/Account.php");

require_once(dirname(__FILE__)."/../../classes/AuthenticationOps.php");
require_once(dirname(__FILE__)."/../../classes/LoginOps.php");
require_once(dirname(__FILE__)."/../../classes/CopyOps.php");
require_once(dirname(__FILE__)."/../../classes/ManageableOps.php");
require_once(dirname(__FILE__)."/../../classes/ContentOps.php");
require_once(dirname(__FILE__)."/../../classes/ProgressOps.php");

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
		$this->progressOps = new ProgressOps($this->db);

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
	
		// All errors are caught with an exception handler. This includes expected
		// errors such as incorrect password, data errors such as no account
		// and unexpected errors such as no database connection.
		$errorObj = array("errorNumber" => 0);
		try {
			// Not sure where the following function should go - AccountOps or LoginOps
			// For now I will put it in LoginOps
			/*if (isset($config['rootID'])) 
				$rootID = $config['rootID'];
			if (isset($config['prefix'])) 
				$prefix = $config['prefix'];
			if (isset($config['productCode'])) 
				$productCode = $config['productCode'];*/
			$account = $this->loginOps->getAccountSettings($config);
						
			// We also need some misc stuff.
			$configObj = array("databaseVersion" => $this->getDatabaseVersion());

		} catch (Exception $e) {
			$errorObj['errorNumber']=$e->getCode(); 
			$errorObj['errorContext']=$e->getMessage();
			return array("error" => $errorObj);
		}
		
		// Set some session variables that other calls will use
		Session::set('rootID', $account->id);
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
	//function login($username, $studentID, $email, $password, $loginOption, $instanceID) {
	function login($loginObj, $loginOption, $instanceID) {
	
		// All errors are caught with an exception handler. This includes expected
		// errors such as incorrect password, data errors such as no account
		// and unexpected errors such as no database connection.
		$errorObj = array("errorNumber" => 0);
		try {
				
			$rootID = Session::get('rootID');
			$productCode = Session::get('productCode');
		
			$allowedUserTypes = array(User::USER_TYPE_TEACHER,
									 User::USER_TYPE_ADMINISTRATOR,
									 User::USER_TYPE_AUTHOR,
									 User::USER_TYPE_STUDENT,
									 User::USER_TYPE_REPORTER);
			// First, confirm that the user details are correct
			$userObj = $this->loginOps->loginBento($loginObj, $loginOption, $allowedUserTypes, $rootID, $productCode);
			$user = new User();
			$user->fromDatabaseObj($userObj);
			
			// TODO. I think I will mostly just send userID rather than need to keep it in session variables. Right?
			Session::set('userID', $userObj->F_UserID);
			Session::set('userType', $userObj->F_UserType);
			
			// That call also gave us the groupID
			// TODO. Do we want an entire hierarchy of groups here so we can do hiddenContent stuff? 
			$groupObj = $this->loginOps->getGroup($userObj->groupID);
			// This might return an error object or a group object		 
			$group = new Group();
			$group->fromDatabaseObj($groupObj);
			
			// Add the user into the group
			$group->addManageables(array($user));
					
			// Next we need to set the instance ID for the user in the database
			$rc = $this->loginOps->setInstanceID($user->userID, $instanceID);
			
			// Content information - though you don't know which course they are going to start yet
			// you can still send back hiddenContent information and bookmarks
			// TODO. RM currently keyed this on a session variable, so for now just use that with the groupID
			// although maybe we need the full is of parent groups in here too.
			Session::set('valid_groupIDs', array($group->id));
			$contentObj = $this->contentOps->getHiddenContent($productCode);
			
			// TODO. What is a good format for sending back bookmark information?
			// For now I will just expect an array of courseIDs that this user has started so that
			// you can use them in licence control.
			
		} catch (Exception $e) {
			$errorObj['errorNumber']=$e->getCode(); 
			$errorObj['errorContext']=$e->getMessage();
			return array("error" => $errorObj);
		}
		
		// Send this information back
		return array("error" => $errorObj,
					"group" => $group,
					"content" => $contentObj);
		
	}
	
	function logout() {
		$this->loginOps->logout();
	}
	
	/**
	 * 
	 * This service call will get progress data from the database, merge it with the menu.xml
	 * and build an object that can act as a data-provider for a chart (or charts).
	 * TODO. Check out authentication. I have added this to beforeFilter exceptions, though it shouldn't be.
	 *  
	 *  @param userID, rootID, productCode - these are all self-explanatory
	 *  @param progress. This object tells us what type of progress data to return
	 *  	loadMySummary:Boolean = false;
	 *		loadEveryoneSummary:Boolean = false;
	 *		loadMyDetails:Boolean = false;
	 */
	function getProgressData($userID, $rootID, $productCode, $progressType, $menuXMLFile ) {
		
		$errorObj = array("errorNumber" => 0);
		
		// Before you get progress records, read the menu.xml
		// TODO. Possibly move this bit into contentOps?
		// This path is relative to the Bento application, not this script
		$menuXMLFile = '../../'.$menuXMLFile;
		$this->progressOps->getMenuXML($menuXMLFile);
		
		$progress = New Progress();
		// Each type of progress that we get goes back in data.
		$progress->type = $progressType;
		if ($progressType == Progress::PROGRESS_MY_SUMMARY) {
			$rs = $this->progressOps->getMySummary($userID, $productCode);
			$progress->dataProvider = $this->progressOps->mergeXMLAndData($rs);
		}
		if ($progressType == Progress::PROGRESS_EVERYONE_SUMMARY) {
			$rs = $this->progressOps->getEveryoneSummary($productCode);
			$progress->dataProvider = $this->progressOps->mergeXMLAndData($rs);
		}
		//	a list of exercises with score, duration and startDate - including ones I haven't done for coverage reporting
		//	a summary at the course level for practiceZone scores for me and for everyone else
		//	a summary at the course level for time spent by me
		 
		return array("error" => $errorObj,
					"progress" => $progress);
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