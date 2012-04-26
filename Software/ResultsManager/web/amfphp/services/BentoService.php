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
require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/account/Licence.php");

require_once(dirname(__FILE__)."/../../classes/AuthenticationOps.php");
require_once(dirname(__FILE__)."/../../classes/LoginOps.php");
require_once(dirname(__FILE__)."/../../classes/CopyOps.php");
require_once(dirname(__FILE__)."/../../classes/ManageableOps.php");
require_once(dirname(__FILE__)."/../../classes/ContentOps.php");
require_once(dirname(__FILE__)."/../../classes/ProgressOps.php");
require_once(dirname(__FILE__)."/../../classes/LicenceOps.php");

// v3.6 What happens if I want to add in AccountOps so that I can pull back the account object?
// I already getContent - will that clash or duplicate?
require_once(dirname(__FILE__)."/../../classes/AccountOps.php");

require_once(dirname(__FILE__)."/AbstractService.php");

class BentoService extends AbstractService {
	
	var $db;

	function __construct() {
		parent::__construct();
		
		if (get_class($this) == "BentoService")
			throw new Exception("Cannot use BentoService as a gateway; extend with a title specific child (e.g. IELTSService)");
		
		// A unique ID to distinguish sessions between multiple Clarity applications
		Session::setSessionName("Bento");
		
		// Set the product name for logging
		AbstractService::$log->setProductName("Bento");
		
		// Set the root id (if set)
		// I am now using is_set, but is that safe? If not set it might be an error. 
		if (Session::is_set('userID')) {
			AbstractService::$log->setIdent(Session::get('userID'));
		}
		
		if (Session::is_set('rootID')) {
			AbstractService::$log->setRootID(Session::get('rootID'));
		}
		
		// Create the operation classes
		$this->accountOps = new AccountOps($this->db);
		$this->loginOps = new LoginOps($this->db);
		$this->copyOps = new CopyOps($this->db);
		$this->manageableOps = new ManageableOps($this->db);
		$this->contentOps = new ContentOps($this->db);
		$this->progressOps = new ProgressOps($this->db);
		$this->licenceOps = new LicenceOps($this->db);
		$this->copyOps = new CopyOps($this->db);
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
	public function getAccountSettings($config) {
		/*if (isset($config->dbHost)) {
			$_SESSION['dbHost'] = $config->dbHost;
			configureGlobalDatabaseVars($config->dbHost);
		}*/
		
		$account = $this->loginOps->getAccountSettings($config);
		// TODO. We will also need the top group ID for this account to help with hiddenContent
		
		// We also need some misc stuff.
		$configObj = array("databaseVersion" => $this->getDatabaseVersion());
		
		// Set some session variables that other calls will use
		Session::set('rootID', $account->id);
		Session::set('productCode', $config['productCode']);
		
		// TODO. Maybe it would be better to use another call to get this info again later, or pass it back from Bento
		// I would just prefer as little session data as possible.
		$licence = new Licence();
		$licence->fromDatabaseObj($account->titles[0]);
		//Session::set('licence', $licence);
		
		return array("config" => $configObj,
					 "licence" => $licence,
					 "account" => $account);
	}
	
	// Rewritten from RM version
	// Assume that dbHost is handled in config.php
	// Assume, for now, that rootID and productCode were put into session variables by getAccountDetails
	// otherwise they need to be passed with every call.
	// #307 Pass rootID and productCode rather than get them from session vars
	//function login($username, $studentID, $email, $password, $loginOption, $instanceID) {
	public function login($loginObj, $loginOption, $instanceID, $licence, $rootID = null, $productCode = null) {
		if (!$rootID) $rootID = Session::get('rootID');
		if (!$productCode) $productCode = Session::get('productCode');

		$allowedUserTypes = array(User::USER_TYPE_TEACHER,
								  User::USER_TYPE_ADMINISTRATOR,
								  User::USER_TYPE_AUTHOR,
								  User::USER_TYPE_STUDENT,
								  User::USER_TYPE_REPORTER);
								 
		// No need to check names for anonymous licence
		if ($licence->licenceType == Title::LICENCE_TYPE_AA) {
			$userObj = $this->loginOps->anonymousUser($rootID);
		} else {
			// First, confirm that the user details are correct
			$userObj = $this->loginOps->loginBento($loginObj, $loginOption, $allowedUserTypes, $rootID, $productCode);
		}
		
		$user = new User();
		$user->fromDatabaseObj($userObj);
		// Hack the name for now
		$user->fullName = $user->name;
		
		// TODO. I think I will mostly just send userID rather than need to keep it in session variables. Right?
		// Well, above I am using rootID and productCode from sessionVariables...
		Session::set('valid_userIDs', array($userObj->F_UserID));
		Session::set('userID', $userObj->F_UserID);
		Session::set('userType', $userObj->F_UserType);
		
		// Check that you can give this user a licence
		// Use exception handling if there is NO available licence
		$ip = (isset($loginObj['ip'])) ? $loginObj['ip'] : '';
		$licenceID = $this->licenceOps->getLicenceSlot($user, $rootID, $productCode, $licence, $ip);
		$licence->id = $licenceID;
		
		// That call also gave us the groupID
		// TODO. Do we want an entire hierarchy of groups here so we can do hiddenContent stuff? 
		$group = $this->manageableOps->getGroup($userObj->groupID);
		
		// Add the user into the group
		$group->addManageables(array($user));
				
		// Next we need to set the instance ID for the user in the database
		$rc = $this->loginOps->setInstanceID($user->userID, $instanceID, $productCode);
		
		// Content information - though you don't know which course they are going to start yet
		// you can still send back hiddenContent information and bookmarks
		// TODO. RM currently keyed this on a session variable, so for now just use that with the groupID
		// although maybe we need the full is of parent groups in here too.
		Session::set('valid_groupIDs', array($group->id));
		$contentObj = $this->contentOps->getHiddenContent($productCode);
		
		// TODO. What is a good format for sending back bookmark information?
		// For now I will just expect an array of courseIDs that this user has started so that
		// you can use them in licence control.
		
		// Send this information back
		return array("group" => $group,
					 "licence" => $licence,
					 "content" => $contentObj);
	}
	
	public function logout($licence) {
		// Clear the licence
		$rs = $this->licenceOps->dropLicenceSlot($licence);

		// Clear session and authentication
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
	public function getProgressData($userID, $rootID, $productCode, $progressType, $menuXMLFile) {
		// Before you get progress records, read the menu.xml
		// TODO. Possibly move this bit into contentOps?
		// This path is relative to the Bento application, not this script
		// TODO. Long term. It might be much quicker to always get everything as none of the calls should be expensive
		// if we keep the everyone summary coming from a computed table.
		if (stristr($menuXMLFile, 'http://') === FALSE) {
			$menuXMLFile = '../../'.$menuXMLFile;
		}
		
		$this->progressOps->getMenuXML($menuXMLFile);
		
		$progress = new Progress();
		
		// Each type of progress that we get goes back in data.
		$progress->type = $progressType;
		switch ($progressType) {
			// MySummary data will now be calculated by ProgressProxy from the detail data
			/*
			case Progress::PROGRESS_MY_SUMMARY:
				$rs = $this->progressOps->getMySummary($userID, $productCode);
				$progress->dataProvider = $this->progressOps->mergeXMLAndDataSummary($rs);
				break;
			*/
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
		return array("progress" => $progress);
	}
	
	/**
	 * 
	 * This service call will create a session record for this user in the database.
	 *  
	 *  @param userID, rootID, productCode - these are all self-explanatory
	 *  @param dateNow - used to get client time
	 */
	public function startSession($user, $rootID, $productCode, $dateNow = null) {
		
		// A successful session start will return a new ID
		$sessionID = $this->progressOps->startSession($user, $rootID, $productCode, $dateNow);
		
		return array("sessionID" => $sessionID);
	}
	
	/**
	 * 
	 * This service call will close the open session record for this user in the database.
	 *  
	 *  @param sessionID - key to the table. If this is not available (perhaps to do with closing the browser?)
	 *  	maybe we can use $userID and $rootID from session variables
	 *  @param dateNow - used to get client time
	 */
	public function updateSession($sessionID, $dateNow = null) {
		// A successful session stop will not generate an error
		$this->progressOps->updateSession($sessionID, $dateNow);
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
	public function stopSession($sessionID, $dateNow) {
		return $this->updateSession($sessionID, $dateNow);
	}
	
	/**
	 * 
	 * This service call will update the licence record for this user in the database.
	 *  
	 *  @param Licence $licence - dummy object for the licence
	 */
	public function updateLicence($licence) {
		// A successful licence update will not generate an error
		$this->licenceOps->updateLicence($licence);
	}
	
	/**
	 * 
	 * This service call will get the instance ID from the user's record in the database.
	 *  
	 *  @param userID - these are all self-explanatory
	 */
	public function getInstanceID($userID, $productCode) {
		// #319 Instance ID per productCode
		$instanceID = $this->loginOps->getInstanceID($userID, $productCode);
		
		return array("instanceID" => $instanceID);
	}
	
	/**
	 * 
	 * This service call will create a score record when a user has completed an exercise or activitiy
	 *  
	 *  @param userID, rootID, productCode - these are all self-explanatory
	 *  @param dateNow - used to get client time
	 */
	public function writeScore($user, $sessionID, $dateNow, $scoreObj) {
		// Manipulate the score object from Bento into PHP format
		// TODO Surely we should be trying to keep the format and names the same!
		$score = new Score();
		$score->setUID($scoreObj['UID']);
		
		$score->scoreCorrect = $scoreObj['correctCount'];
		$score->scoreWrong = $scoreObj['incorrectCount'];
		$score->scoreMissed = $scoreObj['missedCount'];
		
		$totalQuestions = $score->scoreCorrect + $score->scoreWrong + $score->scoreMissed;
		if ($totalQuestions > 0) {
			$score->score = intval(100 * $score->scoreCorrect / $totalQuestions);
		} else {
			$score->score = -1;
		}
		
		$score->duration = $scoreObj['duration'];
		
		$score->dateStamp = $dateNow;
		$score->sessionID = $sessionID;
		$score->userID = $user->userID;
		
		// Write the score record
		$rc = $this->progressOps->insertScore($score, $user);
		
		// and update the session
		$this->updateSession($sessionID);
		
		return $rc;
	}

	/**
	 * The program wants to update the user's information.
	 * Expected for things like changing password
	 * TODO. If you send a password, then confirm that it matches the current one
	 * #307 pass rootID
	 */
	public function updateUser($userObj, $rootID = NULL, $password = NULL) {
		if (!$rootID) $rootID = Session::get('rootID');
		return $this->manageableOps->updateUsers(array($userObj), $rootID);
	}
	
	/**
	 * Get the copy XML document
	 */
	public function getCopy() {
		return $this->copyOps->getCopy();
	}
	
	/**
	 * Get the current database version number
	 */
	public function getDatabaseVersion() {
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