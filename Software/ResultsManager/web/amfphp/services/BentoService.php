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
require_once(dirname(__FILE__)."/vo/com/clarityenglish/bento/vo/progress/Score.php");

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
	 * It is based on the Orchid getRMSettings
	 * 
	 * @param config - an object containing the keys to get the account
	 * rootID, [prefix,] productCode
	 * dbHost
	 * 
	 * @return account - Account object - includes the ONE relevant title and any relevant licence attributes 
	 * @return config - Miscellaneous information, such as database version 
	 * @return error - Error object if required 
	 */
	function getAccountSettings($config) {
	
		// All errors are caught with an exception handler. This includes expected
		// errors such as terms and conditions not accepted yet
		// and unexpected errors such as no database connection.
		$errorObj = array("errorNumber" => 0);
		try {
			$account = $this->loginOps->getAccountSettings($config);

			// TODO. We will also need the top group ID for this account to help with hiddenContent
			
			// We also need some misc stuff.
			$configObj = array("databaseVersion" => $this->getDatabaseVersion());

		} catch (Exception $e) {
			$errorObj['errorNumber']=$e->getCode(); 
			$errorObj['errorContext']=$e->getMessage();
			return array("error" => $errorObj);
		}
		
		// Set some session variables that other calls will use
		Session::set('rootID', $account->id);
		Session::set('productCode', $config['productCode']);
				
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
			// Hack the name for now
			$user->fullName = $user->name;
			
			// TODO. I think I will mostly just send userID rather than need to keep it in session variables. Right?
			// Well, above I am using rootID and productCode from sessionVariables...
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
	 *  @param progressType. This object tells us what type of progress data to return
	 */
	function getProgressData($userID, $rootID, $productCode, $progressType, $menuXMLFile ) {
		
		$errorObj = array("errorNumber" => 0);
		
		// Before you get progress records, read the menu.xml
		// TODO. Possibly move this bit into contentOps?
		// This path is relative to the Bento application, not this script
		// TODO. Long term. It might be much quicker to always get everything as none of the calls should be expensive
		// if we keep the everyone summary coming from a computed table.
		if (stristr($menuXMLFile, 'http://')===FALSE) {
			$menuXMLFile = '../../'.$menuXMLFile;
		}
		$this->progressOps->getMenuXML($menuXMLFile);
		
		$progress = New Progress();
		// Each type of progress that we get goes back in data.
		$progress->type = $progressType;
		switch ($progressType) {
			case Progress::PROGRESS_MY_SUMMARY:
				$rs = $this->progressOps->getMySummary($userID, $productCode);
				$progress->dataProvider = $this->progressOps->mergeXMLAndDataSummary($rs);
				break;
			case Progress::PROGRESS_EVERYONE_SUMMARY:
				$rs = $this->progressOps->getEveryoneSummary($productCode);
				$progress->dataProvider = $this->progressOps->mergeXMLAndDataSummary($rs);
				break;
			case Progress::PROGRESS_MY_DETAILS:
				$rs = $this->progressOps->getMyDetails($userID, $productCode);
				$progress->dataProvider = $this->progressOps->mergeXMLAndDataDetail($rs);
				break;
				
			case Progress::PROGRESS_MY_BOOKMARK:
				// Pick up the last exercise done as a bookmark.
				$rs = $this->progressOps->getMyLastExercise($userID, $productCode);
				$progress->dataProvider = $this->progressOps->formatBookmark($rs);
				break;
		}
		//	a list of exercises with score, duration and startDate - including ones I haven't done for coverage reporting
		//	a summary at the course level for practiceZone scores for me and for everyone else
		//	a summary at the course level for time spent by me
		 
		return array("error" => $errorObj,
					"progress" => $progress
		);
	}
	/**
	 * 
	 * This service call will create a session record for this user in the database.
	 *  
	 *  @param userID, rootID, productCode - these are all self-explanatory
	 *  @param dateNow - used to get client time
	 */
	function startSession($userID, $rootID, $productCode, $dateNow) {
		
		$errorObj = array("errorNumber" => 0);
		
		try {
			// A successful session start will return a new ID
			$sessionID = $this->progressOps->startSession($userID, $rootID, $productCode, $dateNow);
			
		} catch (Exception $e) {
			$errorObj['errorNumber']=$e->getCode(); 
			$errorObj['errorContext']=$e->getMessage();
			return array("error" => $errorObj);
		}
		return array("error" => $errorObj,
					"sessionID" => $sessionID);
	}
	/**
	 * 
	 * This service call will close the open session record for this user in the database.
	 *  
	 *  @param sessionID - key to the table. If this is not available (perhaps to do with closing the browser?)
	 *  	maybe we can use $userID and $rootID from session variables
	 *  @param dateNow - used to get client time
	 */
	function updateSession($sessionID, $dateNow ) {
		
		$errorObj = array("errorNumber" => 0);
		
		try {
			// A successful session stop will not generate an error
			$rs = $this->progressOps->updateSession($sessionID, $dateNow);
			
		} catch (Exception $e) {
			$errorObj['errorNumber']=$e->getCode(); 
			$errorObj['errorContext']=$e->getMessage();
			return array("error" => $errorObj);
		}
		return array("error" => $errorObj);
	}
	/**
	 * 
	 * Currently stopping the session is just the same as updating it.
	 * Perhaps later we might want to set something to show we have 'correctly' exited.
	 *  
	 *  @param sessionID - key to the table. If this is not available (perhaps to do with closing the browser?)
	 *  	maybe we can use $userID and $rootID from session variables
	 *  @param dateNow - used to get client time
	 */
	function stopSession($sessionID, $dateNow ) {
		return $this->updateSession($sessionID, $dateNow);
	}
	/**
	 * 
	 * This service call will create a score record when a user has completed an exercise or activitiy
	 *  
	 *  @param userID, rootID, productCode - these are all self-explanatory
	 *  @param dateNow - used to get client time
	 */
	function writeScore($userID, $sessionID, $dateNow, $scoreObj) {
		
		// Manipulate the score object from Bento into PHP format
		// TODO Surely we shoud be trying to keep the format the same!
		$score = new Score();
		$score->setUID($scoreObj['UID']);
		
		$score->score = $scoreObj['correctPercent'];
		$score->scoreCorrect = $scoreObj['correctCount'];
		$score->scoreWrong = $scoreObj['incorrectCount'];
		$score->scoreMissed = $scoreObj['missedCount'];
		$score->duration = $scoreObj['duration'];
		
		$score->dateStamp = $dateNow;
		$score->sessionID = $sessionID;
		$score->userID = $userID;
		
		$errorObj = array("errorNumber" => 0);
		
		try {
			// Write the score record
			$this->progressOps->insertScore($score);
			
			// and update the session
			$this->progressOps->updateSession($sessionID, $dateNow);
			
		} catch (Exception $e) {
			$errorObj['errorNumber']=$e->getCode(); 
			$errorObj['errorContext']=$e->getMessage();
			return array("error" => $errorObj);
		}
		return array("error" => $errorObj);
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