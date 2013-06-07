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

require_once(dirname(__FILE__)."/../../classes/xml/XmlUtils.php");

require_once(dirname(__FILE__)."/AbstractService.php");

class BentoService extends AbstractService {
	
	var $db;

	function __construct() {
		parent::__construct();
		
		if (get_class($this) == "BentoService")
			throw new Exception("Cannot use BentoService as a gateway; extend with a title specific child (e.g. IELTSService)");
		
		// gh#341
		if (!Session::getSessionName())
			Session::setSessionName("Bento");
			
		// Set the product name for logging
		AbstractService::$log->setProductName(Session::getSessionName());
		
		// Create the operation classes
		$this->accountOps = new AccountOps($this->db);
		$this->loginOps = new LoginOps($this->db);
		$this->manageableOps = new ManageableOps($this->db);
		$this->contentOps = new ContentOps($this->db);
		$this->progressOps = new ProgressOps($this->db);
		$this->licenceOps = new LicenceOps($this->db);
		
		// Set the root id (if set)
		// I am now using is_set, but is that safe? If not set it might be an error. 
		if (Session::is_set('userID')) {
			// AbstractService::$debugLog->notice("Bento-".Session::getSessionName()." service for userID=".Session::get('userID'));
			AbstractService::$log->setIdent(Session::get('userID'));
			$this->loginOps->setTimeZoneForUser(Session::get('userID')); // gh#156
		} else {
			// AbstractService::$debugLog->notice("Bento service for NO userID");
		}
		
		if (Session::is_set('rootID')) {
			AbstractService::$log->setRootID(Session::get('rootID'));
		}
	}
	
	/**
	 * Server-side XML loading, implementing transforms.
	 * TODO: Replace the hard-coded options with $bentoService (pointing to $this) and $href which should cover all cases.
	 */
	public function xhtmlLoad($href) {
		if ((strpos($href->currentDir, 'http') != 0) || // If the currentDir doesn't start with http then disallow
		    (substr($href->filename, -strlen('.xml')) != '.xml') || // If the filename doesn't end with .xml then disallow
		    (strpos($href->getUrl(), ".."))) // If there is any directory traversal in the full url then disallow
			return parent::xhtmlLoad($href);
		
		return XmlUtils::buildXml($href, $this->db, $this);
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
		// #353 This first call might change the dbHost that the session uses
		if (isset($config['dbHost']))
			$this->initDbHost($config['dbHost']);
		
		$account = $this->loginOps->getAccountSettings($config);
		
		// TODO. We will also need the top group ID for this account to help with hiddenContent
		// Actually hidden content might want the group that comes back from login rather than this one?
		// and for addUser
		$group = $this->manageableOps->getGroup($this->manageableOps->getGroupIdForUserId($account->getAdminUserID()));
		
		// We also need some misc stuff.
		$configObj = array("databaseVersion" => $this->getDatabaseVersion());
		
		// Set some session variables that other calls will use
		Session::set('rootID', $account->id);
		Session::set('productCode', $config['productCode']);		
		
		// TODO: Check with Adrian that this is ok
		$title = $account->getTitleByProductCode($config['productCode']);
		Session::set('dbContentLocation', $title->dbContentLocation);
		//issue:#11
		Session::set('languageCode', $title->languageCode);
		
		// TODO. Maybe it would be better to use another call to get this info again later, or pass it back from Bento
		// I would just prefer as little session data as possible.
		$licence = new Licence();
		$licence->fromDatabaseObj($account->titles[0]);
		//Session::set('licence', $licence);
		
		return array("config" => $configObj,
					 "licence" => $licence,
					 "group" => $group,
					 "account" => $account);
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
	
	// Rewritten from RM version
	// Assume that dbHost is handled in config.php
	// Assume, for now, that rootID and productCode were put into session variables by getAccountDetails
	// otherwise they need to be passed with every call.
	// #307 Pass rootID and productCode rather than get them from session vars
	// #503 rootID is now an array or rootIDs, although there will only be more than one if subRoots is set in the licence
	//function login($username, $studentID, $email, $password, $loginOption, $instanceID) {
	// gh#46 This first call might change the dbHost that the session uses
	// gh#66 RotterdamBuilder will send allowedUserTypes and change licence
	public function login($loginObj, $loginOption, $verified, $instanceID, $licence, $rootID = null, $productCode = null, $dbHost = null, $allowedUserTypes = null) {
		if ($dbHost)
			$this->initDbHost($dbHost);
		
		// gh#21 It is acceptable to pass a null rootID, so don't grab it from session
		// if (!$rootID) $rootID = array(Session::get('rootID'));
		// gh#176
		if ($productCode) {
			Session::set('productCode', $productCode);			
		}  else {
			$productCode = Session::get('productCode');
		}

		// gh#66
		if (!$allowedUserTypes) 
			$allowedUserTypes = array(User::USER_TYPE_TEACHER,
								  User::USER_TYPE_ADMINISTRATOR,
								  User::USER_TYPE_AUTHOR,
								  User::USER_TYPE_STUDENT,
								  User::USER_TYPE_REPORTER);
								 
		// No need to check names for anonymous licence
		// #341 or for network licence working in anonymous mode
		// #341 
		// gh#100 or for CT
		if ($licence->licenceType == Title::LICENCE_TYPE_AA || 
			($licence->licenceType == Title::LICENCE_TYPE_NETWORK && $loginObj == NULL) ||
			($licence->licenceType == Title::LICENCE_TYPE_CT && $loginObj == NULL) ||
			($loginOption & User::LOGIN_BY_ANONYMOUS && $loginObj == NULL)) {
			$userObj = $this->loginOps->anonymousUser($rootID);
			
		} else {
			// First, confirm that the user details are correct
			$userObj = $this->loginOps->loginBento($loginObj, $loginOption, $verified, $allowedUserTypes, $rootID, $productCode);
		}
		
		$user = new User();
		$user->fromDatabaseObj($userObj);
		// Hack the name for now
		$user->fullName = $user->name;
		
		// Set various session variables
		Session::set('valid_userIDs', array($userObj->F_UserID));
		Session::set('userID', $userObj->F_UserID);
		Session::set('userType', $userObj->F_UserType);
		Session::set('groupID', $userObj->groupID);	
		Session::set('groupIDs', array_merge(array($userObj->groupID), $this->manageableOps->getExtraGroups($userObj->F_UserID)));	
		
		// gh#21 As rootID will be -1 if you have not got an account yet, this will work.
		// #503 From login you now only have one rootID even if you started with an array
		// If that root has changed, you have to get a new licence object for this new root
		// To be clear: subRoots means that I use one prefix to get lots of subRoots.
		// my login looks for my ID in all those roots and finds it in one.
		// The licence checking is all now based on that one root.
		// groupedRoots means that I use my specific root to login. I pick up groupedRoots
		// and all those roots are counted when I check used licences. All roots in the group
		// have the same licence details, and I need to pass those roots to getLicenceSlot.
		// But getLicenceSlot doesn't cope with that. For now this is OK as no-one uses it.
		$newRootID = $userObj->rootID;
		
		if ($rootID != array($newRootID)) {
			// gh#39 Special case handling for BC LastMinute candidates using tablets. 
			// The productCode will be a list '52,53', but you can find which to use from T_User.F_UserProfileOption
			if ($userObj->F_UserProfileOption && stristr($productCode, $userObj->F_UserProfileOption))
				$productCode = $userObj->F_UserProfileOption;

			$newAccount = $this->loginOps->getAccountSettings(array('rootID' => $newRootID, 'productCode' => $productCode));
			
			// gh#39 If at this point you still have multiple accounts you need to select just one
			if (count($newAccount->titles) > 1) {

				// gh#39 gh#135 Need to go and check hiddenContent for this user to see if either title is completely blocked
				// Problem as it requires lots of duplication from HiddenContentTransform, and you have to do it for
				// both of the product codes...hmmm. Too bad, it will just have to be done.
				// Note that after filtering, we have lost the titles, BUT the index is not reset
				$newAccount->titles = array_filter($newAccount->titles, array($this, 'blockFilter'));
								
			}
			// If multiple titles still remain, just pick the first!
			$newAccount->titles = array(reset($newAccount->titles));
				
			// gh#39 If you had multiple codes, reduce to one
			if (stristr($productCode, ','))
				$productCode = $newAccount->titles[0]->productCode;
				
			// gh#135 make sure that productCode is now in session variables
			Session::set('productCode', $productCode);
				
			$licence = new Licence();
			$licence->fromDatabaseObj($newAccount->titles[0]);
			
		} 
		
		$rootID = $newRootID;
		Session::set('rootID', $rootID);
		
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
		
		// Get the group hierarchies for all groups this user is allowed to use
		$groupTrees = $this->manageableOps->getAllManageables(true);
		
		// gh#148 And I need this as a flat list of group IDs too
		$subGroupIds = array();
		foreach ($groupTrees as $m) {
			if (get_class($m) == "Group") {
				$subGroupIds[] = $m->id;
				$subGroupIds = array_merge($subGroupIds, $m->getSubGroupIds());
			}
		}
		Session::set('groupTreeIDs', $subGroupIds);	
		
		// #341 If this is a named user then
		if ($user->userID >= 1) {
			// Next we need to set the instance ID for the user in the database
			$rc = $this->loginOps->setInstanceID($user->userID, $instanceID, $productCode);
			
			// Content information - though you don't know which course they are going to start yet
			// you can still send back hiddenContent information and bookmarks
			// TODO. RM currently keyed this on a session variable, so for now just use that with the groupID
			// although maybe we need the full is of parent groups in here too.
			// gh#25 getHiddenContent is actually dealt with in getProgressData, not here
			Session::set('valid_groupIDs', array($group->id));
			//if ($user->userType == User::USER_TYPE_STUDENT)
			//	$contentObj = $this->contentOps->getHiddenContent($productCode);
			
		}
		// TODO. What is a good format for sending back bookmark information?
		// For now I will just expect an array of courseIDs that this user has started so that
		// you can use them in licence control.
		
		// Send this information back
		// #503 including the root that you really found the user in
		// gh#25 no content sent back
		$dataObj = array("group" => $group,
						 "groupTrees" => $groupTrees,
						 "licence" => $licence,
						 "rootID" => $rootID);
		
		// gh#21 include the account you found if the rootID changed based on the login
		if ($newAccount)
			$dataObj['account'] = $newAccount;
			
		return $dataObj;
	}
	
	protected function blockFilter($thisTitle) {
		$thisPC = $thisTitle->productCode;					
		$rs = $this->progressOps->getHiddenContent(Session::get('groupID'), $thisPC);
		
		// Just be really simplistic and see if there is a top level blocking record
		if (count($rs) > 0) {
			foreach ($rs as $record) {
				$fullUID = $record['UID'];
				$eF = $record['eF'];
				if ($fullUID == $thisPC && $eF == Content::CONTENT_DISABLED) {
					// This title is blocked, so remove it from the account								
					return false;
				}
			}
		}
		return true;
	}
	 	
	public function logout($licence, $sessionID = null) {
		// Clear the licence
		$rs = $this->licenceOps->dropLicenceSlot($licence);

		// Update the session record
		if ($sessionID)
			$this->updateSession($sessionID);
		
		// Clear php session and authentication
		$this->loginOps->logout();
		
		Session::clear();
	}
	
	/**
	 * This service call returns an associative array of Course_ID => course summary data for everyone and is used in progress compare
	 */
	public function getEveryoneSummary($productCode) {
		return $this->progressOps->getEveryoneSummary($productCode);
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
		$score = $this->progressOps->insertScore($score, $user);
		
		// and update the session
		$this->updateSession($sessionID);
		
		return $score;
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
	 * The program wants to register a new user. Expect a little information.
	 * Check for duplicates in this root and that the minimum login information is set.
	 */
	public function addUser($user, $loginOption, $rootID = NULL, $group) {
		if (!$rootID) $rootID = Session::get('rootID');
		
		// If you don't know a rootID, you can't get or add the user
		if (!$rootID) 
			throw $this->copyOps->getExceptionForId("errorNoSuchRootID", array("rootID" => NULL));
			
		// Does this user already exist? Check by the key information ($loginOption)
		// TODO. This switch should really go in getUserByKey
		$stubUser = new User();
		if ($loginOption & 1) {
			$stubUser->name = $user->name;
		} else if ($loginOption & 2) {
			$stubUser->studentID = $user->studentID;
		} else if ($loginOption & 128) {
			$stubUser->email = $user->email;
		}
		// #341 Only need to check user details within this root
		$stubUser = $this->manageableOps->getUserByKey($stubUser, $rootID);
		
		// Go ahead and add the user to the top level group
		if ($stubUser==false) {
			if (!$group) 
				throw $this->copyOps->getExceptionForId("errorNoSuchGroup", array("rootID" => $rootID));

			// Bento. Override authentication to let a user add themselves to the group
			AuthenticationOps::clearValidUsersAndGroups();
			AuthenticationOps::addValidGroupIDs(array($group->id));
			
			// Add any preset details to the user object
			$user->registerMethod = "selfRegister";
			$user->userType = User::USER_TYPE_STUDENT;
			$user->userProfileOption = 0;
			return $this->manageableOps->addUser($user, $group, $rootID);
		
		} else {
			
			// A user already exists with these details, so throw an error as we can't add the new one
			throw $this->copyOps->getExceptionForId("errorDuplicateUser", array("name" => $stubUser->name, "loginOption" => $loginOption));
		}

		return false;
	}
	
	/**
	 * Get the copy XML document
	 * gh#39 pass language code
	 */
	public function getCopy($code = null) {
		return $this->copyOps->getCopy($code);
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

	/**
	 * gh#119 Old versions of the swf will crash if they don't find this method. So use it as a way to tell them to upgrade
	 */
	public function getProgressData($user = null, $rootID = null, $productCode = null, $progressType = null, $menuXMLFile = null) {
		// gh#178 if you have an old iPad version you can't upgrade yet
		// 31 May 2013 - now you can upgrade, so force this...
		/*
		$rootID = Session::get('rootID');
		if (!array_search($rootID, array(14276,14277,14278,14279,14280,14281,14282,14283,14284,14285,14286,14287,14288,14289,14290,14291,14292)) === false) {
			require_once(dirname(__FILE__)."/../../classes/OldProgressOps.php");
			$this->oldProgressOps = new OldProgressOps($this->db);
			return $this->oldGetProgressData($user, $rootID, $productCode, $progressType, $menuXMLFile);
		} else {
			throw $this->copyOps->getExceptionForId("errorMustUpgradeApp");	
		}
		*/
		throw $this->copyOps->getExceptionForId("errorMustUpgradeApp");	
	}
	
	/**
	 * 
	 * This service call will get progress data from the database, merge it with the menu.xml
	 * and build an object that can act as a data-provider for a chart (or charts).
	 * TODO. Check out authentication. I have added this to beforeFilter exceptions, though it shouldn't be.
	 *  
	 *  #issue25. Need user type, so send whole object
	 *  @param userID, rootID, productCode - these are all self-explanatory
	 *  @param progressType. This object tells us what type of progress data to return
	 */
	public function oldGetProgressData($user, $rootID, $productCode, $progressType, $menuXMLFile) {
		// Before you get progress records, read the menu.xml
		// TODO. Possibly move this bit into contentOps?
		// This path is relative to the Bento application, not this script
		// TODO. Long term. It might be much quicker to always get everything as none of the calls should be expensive
		// if we keep the everyone summary coming from a computed table.
		
		// HCT hack.
		// If the passed menu file doesn't contain a correct version, add it in
		if (stristr($menuXMLFile, '-.xml')) {
			$menuXMLFile = preg_replace('/(\w+)-\.xml/i', '$1-FullVersion.xml', $menuXMLFile);
		}
		// and the passed user might just be an id, in which case build a temp User object
		if (!isset($user->userID)) {
			$userID = $user;
			$user = new User();
			$user->userID = $userID;
			$user->userType = 0;
		}
				
		if (stristr($menuXMLFile, 'http://') === FALSE) {
			$menuXMLFile = '../../'.$menuXMLFile;
		}
		
		$this->oldProgressOps->getMenuXML($menuXMLFile);
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
				$rs = $this->oldProgressOps->getEveryoneSummary($productCode);
				$progress->dataProvider = $this->oldProgressOps->mergeXMLAndDataSummary($rs);
				break;
				
			case Progress::PROGRESS_MY_DETAILS:
				// #341 No need for much of this if anonymous access
				if ($user->userID >= 1) {
					$rs = $this->oldProgressOps->getMyDetails($user->userID, $productCode);
				} else {
					$rs = array();
				}
				
				$progress->dataProvider = $this->oldProgressOps->mergeXMLAndDataDetail($rs);
				
				// #339 Hidden content
				// #issue25 only for students
				if ($user->userID >= 1 && $user->userType == User::USER_TYPE_STUDENT) {
					$groupID = $this->manageableOps->getGroupIdForUserId($user->userID);
					$rs = $this->oldProgressOps->getHiddenContent($groupID, $productCode);
					// If you found some hidden content records for this group, merge the enabledFlag into the menu.xml
					if (count($rs) > 0)
						$progress->dataProvider = $this->oldProgressOps->mergeXMLAndHiddenContent($rs);
						
				}
				break;
				
			case Progress::PROGRESS_MY_BOOKMARK:
				// Pick up the last exercise done as a bookmark.
				$rs = $this->oldProgressOps->getMyLastExercise($user->userID, $productCode);
				$progress->dataProvider = $this->oldProgressOps->formatBookmark($rs);
				break;
		}
			
		//	a list of exercises with score, duration and startDate - including ones I haven't done for coverage reporting
		//	a summary at the course level for practiceZone scores for me and for everyone else
		//	a summary at the course level for time spent by me
		return array("progress" => $progress);
	}
	
}