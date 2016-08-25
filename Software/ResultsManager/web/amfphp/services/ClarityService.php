<?php
/**
 * -Database changes -
 * o Need to make the SQL Server database accessible through SQL authentication (see basecamp writeboard)
 * o Turn on auto_increment in t_groupstructures.F_GroupID (in SQL Server make it an identity column)
 * o Add T_Accounts
 * o Add T_Accountroot
 * o Add T_Titlelicences
 * o Add T_HiddenContent
 *
 * ... database changes too numerous to list here.  Check Basecamp for full descriptions of what has changed.
 */

require_once(dirname(__FILE__)."/../../config.php");
 
require_once($GLOBALS['adodb_libs']."adodb-exceptions.inc.php");
require_once($GLOBALS['adodb_libs']."adodb.inc.php");

// gh#1275
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/LoginAPI.php");

require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/Reportable.php");

require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/Manageable.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/User.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/Group.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/tests/ScheduledTest.php");

require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/content/Content.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/content/Title.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/content/Course.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/content/Unit.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/content/Exercise.php");
// gh#1487
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/email/TemplateDefinition.php");
// v3.4 To allow the account root information to be passed back to RM
// gh#125
require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/account/Account.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/account/Licence.php");

require_once(dirname(__FILE__)."/../../classes/AuthenticationOps.php");
require_once(dirname(__FILE__)."/../../classes/LoginOps.php");
require_once(dirname(__FILE__)."/../../classes/CopyOps.php");
require_once(dirname(__FILE__)."/../../classes/ManageableOps.php");
require_once(dirname(__FILE__)."/../../classes/ContentOps.php");
require_once(dirname(__FILE__)."/../../classes/TestOps.php");
require_once(dirname(__FILE__)."/../../classes/DailyJobObs.php"); // TODO Correct spelling!!
require_once(dirname(__FILE__)."/../../classes/CourseOps.php"); //
require_once(dirname(__FILE__)."/../../classes/SubscriptionOps.php"); //
require_once(dirname(__FILE__)."/../../classes/MemoryOps.php"); //

// v3.6 What happens if I want to add in AccountOps so that I can pull back the account object?
// I already getContent - will that clash or duplicate?
require_once(dirname(__FILE__)."/../../classes/AccountOps.php");

require_once(dirname(__FILE__)."/../../classes/LicenceOps.php");
require_once(dirname(__FILE__)."/../../classes/UsageOps.php");
require_once(dirname(__FILE__)."/../../classes/ReportOps.php");
require_once(dirname(__FILE__)."/../../classes/ImportXMLParser.php");
// v3.6 Required as usage ops can also send triggered emails.
// v3.6 Not any more, remove that to RunTriggers.php
// gh#769 required to send notification emails to account managers
require_once(dirname(__FILE__)."/../../classes/EmailOps.php");
require_once(dirname(__FILE__)."/../../classes/TemplateOps.php");

require_once(dirname(__FILE__)."/AbstractService.php");

class ClarityService extends AbstractService {
	
	var $db;

	function __construct() {
		parent::__construct();
		
		// A unique ID to distinguish sessions between multiple Clarity applications
		Session::setSessionName("RM");
		
		// Set the product name for logging
		AbstractService::$log->setProductName("RM");
		AbstractService::$debugLog->setProductName("RM");
		AbstractService::$controlLog->setProductName("RM");
		
		// Set the title name for resources
		AbstractService::$title = "rm";
		
		// Set the root id (if set)
		// I am now using is_set, but is that safe? If not set it might be an error. 
		if (Session::is_set('userID')) {
			AbstractService::$log->setIdent(Session::get('userID'));
			AbstractService::$debugLog->setIdent(Session::get('userID'));
			AbstractService::$controlLog->setIdent(Session::get('userID'));
		};
		if (Session::is_set('rootID')) {
			AbstractService::$log->setRootID(Session::get('rootID'));
			AbstractService::$debugLog->setRootID(Session::get('rootID'));
			AbstractService::$controlLog->setRootID(Session::get('rootID'));
		};
		
		// Create the operation classes
		$this->loginOps = new LoginOps($this->db);
		$this->copyOps = new CopyOps($this->db);
		$this->manageableOps = new ManageableOps($this->db);
		$this->contentOps = new ContentOps($this->db);
		//$this->licenceOps = new LicenceOps($this->db);
		$this->usageOps = new UsageOps($this->db);
		$this->reportOps = new ReportOps($this->db);
        // gh#1275
        $this->accountOps = new AccountOps($this->db);
        // gh#1487
        $this->testOps = new TestOps($this->db);
        $this->dailyJobOps = new DailyJobObs($this->db);
        $this->emailOps = new EmailOps($this->db);
        
	}
	public function changeDB($dbHost) {
		$this->initDbHost($dbHost);
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

    // Allow several optional parameters to come from Flash
	// $productCode is deprecated
	public function login($username, $password, $rootID = null, $dbHost=null, $productCode = null) {
		
		// #353 This first call might change the dbHost that the session uses
		if ($dbHost)
			$this->initDbHost($dbHost);
		
		// gh#1118 Allow super user to login
		$allowedUserTypes = array(User::USER_TYPE_TEACHER,
								 User::USER_TYPE_ADMINISTRATOR,
								 User::USER_TYPE_AUTHOR,
								 User::USER_TYPE_REPORTER,
								 User::USER_TYPE_DMS,
								 User::USER_TYPE_DMS_VIEWER);

		$loginObj = $this->loginOps->login($username, $password, $allowedUserTypes, $rootID, 2);
		
		if ($loginObj) {
			// gh#1424 Clearing this causes problems for bulkImport
			//AuthenticationOps::clearValidUsersAndGroups();
			
			// RM specific setup values for this root
			if (isset($loginObj->F_LangaugeCode) && strlength($loginObj->F_LanguageCode)>0) {
				Session::set('languageCode', $loginObj->F_LanguageCode);
			} else {
				Session::set('languageCode', 'EN');
			}
            // gh#1275
            //AbstractService::$debugLog->info("try to set session userid=" . $loginObj->F_UserID);
            Session::set('userID', $loginObj->F_UserID);

            Session::set('rootID', $loginObj->F_RootID);
            // gh#671 This is actually the current user's group, not the top group
			//Session::set('rootGroupID', $loginObj->F_GroupID);
			Session::set('groupIDs', array_merge(array($loginObj->F_GroupID), $this->manageableOps->getExtraGroups($loginObj->F_UserID)));
			Session::set('max'.User::USER_TYPE_TEACHER, $loginObj->F_MaxTeachers);
			Session::set('max'.User::USER_TYPE_AUTHOR, $loginObj->F_MaxAuthors);
			Session::set('max'.User::USER_TYPE_REPORTER, $loginObj->F_MaxReporters);
			// v3.5 I also need to know the usertype for AP privacy
			Session::set('userType', (int)$loginObj->F_UserType);
			
			// v3.5 Add dbHost if we want anything other than default.
			// Duh, can't do it here as you have already read dbDetails!
			if ($dbHost)
				Session::set('dbHost', $dbHost);

			// On login RM needs to count the total number of manageables in this account to determine whether or not we display students or not.
			// This is ridiculous. At least we should be doing a quick SQL call to get the numbers. This check is doing everything.
			// v3.0.4 Are we saving at least the list of groups so that when we do this a second time to really get them it doesn't take so long?
			//$manageables = $this->manageableOps->getManageables(Session::get('groupIDs'), false, true);
			//$manageablesCount = AuthenticationOps::countAuthenticatedUsers() + AuthenticationOps::countAuthenticatedGroups();
			$manageablesCount = $this->manageableOps->countUsersInGroup(Session::get('groupIDs'));
			
			// v3.5 Special (temporary) change for Taihung University (18000 accounts) for Kima.
			// and SciencesPo (updated for 2013/14/15/16)
			// added BCJPILA. 
			// added TW_CUTE 2014 11 05 
			// added ELS 2015/08/17
			// added BCVIETNAM
			if ((int)$loginObj->F_RootID == 14781 || (int)$loginObj->F_RootID == 19278 || (int)$loginObj->F_RootID == 26155 || 
				(int)$loginObj->F_RootID == 13982 || (int)$loginObj->F_RootID == 13754 || (int)$loginObj->F_RootID == 22743
				|| (int)$loginObj->F_RootID == 32366 || (int)$loginObj->F_RootID == 35886  || (int)$loginObj->F_RootID == 163) {
				Session::set('no_students', ($manageablesCount > 22000));
			} else {
				Session::set('no_students', ($manageablesCount > $GLOBALS['max_manageables_for_student_display']));
			}

			// v3.4 I would like to send back (some) account root information as well (remember that accounts in RM means titles)
			// v3.6 Maybe it is better to do a separate getAccount call as I also want things like adminUser's email
			$accountRoot = $this->manageableOps->getAccountRoot($loginObj->F_RootID);

            // gh#671
            Session::set('rootGroupID', $this->manageableOps->getGroupIdForUserId($accountRoot->getAdminUserID()));

			// gh#769
			if ((int)$accountRoot->accountType == 5)
				Session::set('distributorTrial', true);

			// gh#1275
			Session::set('loginOption', $accountRoot->loginOption);

			// v3.4 Get some more information about the user (and their group/parent groups)
			// Keep this in session so that reports can use it for editedContent
			$parentGroups = array_reverse($this->manageableOps->getGroupParents($loginObj->F_GroupID));
			Session::set('parentGroupIDs', $parentGroups);

			// v3.5 Checking on data types. F_UserID is converted to string in LoggedInCommand
			// noStudents means don't display students, not number of students! So it is converted to boolean
			// v3.5 You really need to send this back as a user or account or title or something rather than all these variables.
			return array("userID" => (int)$loginObj->F_UserID,
						 "userType" => (int)$loginObj->F_UserType,
						 "languageCode" => $loginObj->F_LanguageCode,
						 "noStudents" => Session::get('no_students'),
						 "manageablesCount" => (int)$manageablesCount,
						 "prefix" => $accountRoot->prefix,
						 "groupID" => (int)$loginObj->F_GroupID,
						 "parentGroups" => $parentGroups,
						 // Just a temporary way of doing things!
						 // v3.4.0 Use the capitalisation from the database rather than what they type
						 //"userName" => $username, // Do you need htmlspecialchars here for odd names? Or does amfphp handle it all?
						 "userName" => $loginObj->F_UserName, // Do you need htmlspecialchars here for odd names? Or does amfphp handle it all?
						 "password" => $password,
						 // v3.5.1 Send back the account name for display purposes
						 "accountName" => $accountRoot->name,
						 // v3.5 And max numbers of user types
						 "maxTeachers" => (int)$loginObj->F_MaxTeachers,
						 "maxReporters" => (int)$loginObj->F_MaxReporters,
						 "maxAuthors" => (int)$loginObj->F_MaxAuthors,
						 // v3.6 And the licence type of RM
						 "licenceType" => (int)$loginObj->F_LicenceType,
						 );
		} else {
            AbstractService::$debugLog->info("failed to login");
			// Invalid username/password
			return false;
		}
	}
	
	public function logout() {
		$this->loginOps->logout();
	}
	
	public function getLoginOpts() {
		return $this->loginOps->getLoginOpts();
	}
	
	public function setLoginOpts($loginOption, $selfRegister, $passwordRequired) {
		return $this->loginOps->setLoginOpts($loginOption, $selfRegister, $passwordRequired);
	}
	
	// v3.6 For setting email options. It would be more sensible to put this in accountOps, but that is saved for DMS
	// so I will bundle with loginOpts, which is incorrectly bundled with loginOps!
	public function getEmailOpts() {
		return $this->loginOps->getEmailOpts();
	}
	
	public function setEmailOpts($emailOptionsArray) {
		return $this->loginOps->setEmailOpts($emailOptionsArray);
	}
	
	/**
	 * Get the copy XML document
	 */
	public function getCopy() {
		return $this->copyOps->getCopy();
	}
	
	public function getAllManageables() {
		// gh#1424 Can be a very long call
		$rc = set_time_limit(120);
        if (!$rc)
            AbstractService::$debugLog->info("Could not set the time limit");
        
        // gh#1424 Different call if you want everything for the top level group
        // Actually, it might make no difference to use new code for all calls
		// There is some wastage if you are a teacher for one small group in a big account - but I think insignificant
		// gh#671 No. The new method does NOT pick up for extra teacher groups. So revert back if you are not at the root
        $groupIds = Session::get('groupIDs');
        if (Session::get('rootGroupID') == $groupIds[0]) {
			//AbstractService::$debugLog->info("New code as root group=".Session::get('rootGroupID')." and top group=".$groupIds[0]);
			return $this->manageableOps->getAllManageablesFromRoot();
        } else {
			//AbstractService::$debugLog->info("Going with the old method as root group=".Session::get('rootGroupID')." and top group=".$groupIds[0]);
			return $this->manageableOps->getAllManageables();
        }
    }
	
	public function getContent($productCodes = null) {
		return $this->contentOps->getContent($productCodes);
	}
	
	// CCB
	/*
	function getCCBContent($prefix, $userID, $groupID) {
		return $this->ccbOps->getCCBContent($prefix, $userID, $groupID);
	}

	function setCCBContent($prefix, $setData) {
		return $this->ccbOps->setCCBContent($prefix, $setData);
	}

	function deleteCCBContent($prefix, $setData) {
		return $this->ccbOps->deleteCCBContent($prefix, $setData);
	}

	function getMediaFiles($path, $type) {
		return $this->ccbOps->getMediaFiles($path, $type);
	}

	function getCourseSchedule($groupID){
		return $this->ccbOps->getCourseSchedule($groupID);
	}
	
	function setCourseSchedule($course, $schedule){
		return $this->ccbOps->setCourseSchedule($course, $schedule);
	}
	
	function removeCourseSchedule($schedule){
		return $this->ccbOps->removeCourseSchedule($schedule);
	}
	*/
	public function addGroup($group, $parentGroup) {
		return $this->manageableOps->addGroup($group, $parentGroup);
	}
	
	public function addUser($user, $parentGroup) {
		// gh#769 record source of registration
		$today = new DateTime();
		if (!isset($user->registrationDate))  $user->registrationDate = $today->format('Y-m-d H:i:s');
		if (!isset($user->registerMethod)) $user->registerMethod = 'RM';
		
		return $this->manageableOps->addUser($user, $parentGroup);
	}
	
	public function updateGroups($groupsArray) {
		return $this->manageableOps->updateGroups($groupsArray);
	}
	
	public function updateUsers($usersArray) {
		return $this->manageableOps->updateUsers($usersArray);
	}
	
	public function moveManageables($manageables, $parentGroup) {
		return $this->manageableOps->moveManageables($manageables, $parentGroup);
	}
	
	public function deleteManageables($manageablesArray) {
		return $this->manageableOps->deleteManageables($manageablesArray);
	}
	
	public function importXMLFromUpload($parentGroup) {
		return $this->manageableOps->importXMLFromUpload($parentGroup);
	}

	// v3.6.1 Allow moving and importing
	//function importManageables($groups, $users, $parentGroup) {
	public function importManageables($groups, $users, $parentGroup, $moveExistingStudents) {
		//Throw new Exception("importManageables with moving=".$moveExistingStudents);
		// AR Special function for updating the names of lots of students keyed on studentID
		return $this->manageableOps->importManageables($groups, $users, $parentGroup, $moveExistingStudents);
		//return $this->manageableOps->updateManageableNames($groups);
	}

	// This call is not used anymore
	// 3.4 But it is still made! So remove any further calls.
	public function getLicences() {
		//return $this->licenceOps->getLicences();
		return Array();
	}
	
	// This call is not used anymore
	/*
	function allocateLicences($userIdArray, $productCode) {
		return $this->licenceOps->allocateLicences($userIdArray, $productCode);
	}
	
	// This call is not used anymore
	function unallocateLicences($userIdArray, $productCode) {
		return $this->licenceOps->unallocateLicences($userIdArray, $productCode);
	}
	*/
	public function getExtraGroups($user) {
		// v3.4 Multi-group users
		//return $this->manageableOps->getExtraGroups($user->id);
		return $this->manageableOps->getExtraGroups($user->userID);
	}
	
	public function setExtraGroups($user, $groupsArray) {
		return $this->manageableOps->setExtraGroups($user, $groupsArray);
	}

	// gh#1487
	public function getTests($group, $productCode) {
		return $this->testOps->getTests($group->id, $productCode);
	}
	public function addTest($test) {
		$this->testOps->addTest($test);		
		return $this->testOps->getTests($test->groupId, $test->productCode);
	}
	public function updateTest($test) {
		$this->testOps->updateTest($test);
		//AbstractService::$debugLog->info("return testdetails for group ".$test->groupId);
		return $this->testOps->getTests($test->groupId, $test->productCode);
	}
	public function deleteTest($test) {
		$this->testOps->deleteTest($test);
		return $this->testOps->getTests($test->groupId, $test->productCode);
	}
	public function getUsageForTest($pc) {
		return $this->usageOps->getTestsUsed($pc);
	}
	
	public function getUsageForTitle($title, $fromDate, $toDate) {
		return $this->usageOps->getUsageForTitle($title, $fromDate, $toDate);
	}
	
	public function getFixedUsageForTitle($title, $fromDate, $toDate) {
	    return $this->usageOps->getFixedUsageForTitle($title, $fromDate, $toDate);
	}
	
	// v3.0.4 Include the template as well
	public function getReport($onReportableIDObjects, $onClass, $forReportableIDObjects, $forClass, $reportOpts, $template='standard') {
		// Since we are potentially passing a lot of reportables to this from the client pass IDs instead of VOs to save on transfer overhead
		// gh#1470 Special reports are built in a one-off way
		if (strtolower($template) == 'licence') {
			return $this->reportOps->generateSpecialReport($onReportableIDObjects, $onClass, $forReportableIDObjects, $forClass, $reportOpts, $template);
		} else {
			return $this->reportOps->getReport($onReportableIDObjects, $onClass, $forReportableIDObjects, $forClass, $reportOpts, $template);
		}
	}
	
	public function getHiddenContent() {
		return $this->contentOps->getHiddenContent();
	}
	
	public function getEditedContent($groupIDs) {
		return $this->contentOps->getEditedContent($groupIDs);
	}
	
	public function setHiddenContent($contentIDObject, $groupID, $visible) {
		return $this->contentOps->setHiddenContent($contentIDObject, $groupID, $visible);
	}
	
	// v3.4 Editing Clarity Content
	public function initEditedContent($toPath, $groupID) {
		return $this->contentOps->initEditedContent($toPath, $groupID);
	}
	
	// V3.5 Add another variable
	//function checkEditedContentExercise($fromPath, $toPath, $groupID, $UID, $caption) {		
	public function checkEditedContentExercise($fromPath, $toPath, $groupID, $UID, $caption, $exerciseID) {		
		return $this->contentOps->checkEditedContentExercise($fromPath, $toPath, $groupID, $UID, $caption, $exerciseID);
	}
	
	public function checkEditedContentFolder($toPath, $groupID) {		
		return $this->contentOps->checkEditedContentFolder($toPath, $groupID);
	}
	
	// This works for moving and inserting content (and probably deleting too)
	// v3.5 Send the title so I can reset related UIDs if necessary
	public function moveContent($editedUID, $groupID, $relatedUID, $mode, $title) {
		return $this->contentOps->moveContent($editedUID, $groupID, $relatedUID, $mode, $title);
	}
	
	public function insertContent($editedUID, $groupID, $relatedUID, $mode, $toPath) {
		return $this->contentOps->insertContent($editedUID, $groupID, $relatedUID, $mode, $toPath);
	}
	
	public function copyContent($editedUID, $groupID, $relatedUID, $mode, $toPath) {
		return $this->contentOps->copyContent($editedUID, $groupID, $relatedUID, $mode, $toPath);
	}
	
	public function resetContent($editedUID, $groupID) {
		return $this->contentOps->resetContent($editedUID, $groupID);
	}

    // gh#1275
    public function getRootIDFromPrefix($loginDetails) {
        return $this->accountOps->getRootIDFromPrefix($loginDetails->prefix);
    }

}