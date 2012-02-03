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

// v3.4.3 Remove as not used
//require_once(dirname(__FILE__)."/../../classes/LicenceOps.php");
require_once(dirname(__FILE__)."/../../classes/UsageOps.php");
require_once(dirname(__FILE__)."/../../classes/ReportOps.php");
require_once(dirname(__FILE__)."/../../classes/ImportXMLParser.php");
// v3.6 Required as usage ops can also send triggered emails.
// v3.6 Not any more, remove that to RunTriggers.php
//require_once(dirname(__FILE__)."/../../classes/EmailOps.php");
//require_once(dirname(__FILE__)."/../../classes/TemplateOps.php");
// for Clarity Course Builder by WZ
/*
require_once(dirname(__FILE__)."/../../classes/CCBOps.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/net/NetFile.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/content/Schedule.php");
*/
require_once(dirname(__FILE__)."/AbstractService.php");

class ClarityService extends AbstractService {
	
	var $db;

	function ClarityService() {
		parent::_AbstractService();
		
		// A unique ID to distinguish sessions between multiple Clarity applications
		Session::setSessionName("RM");
		
		// Set the product name for logging
		AbstractService::$log->setProductName("RM");
		
		// Set the root id (if set)
		// I am now using is_set, but is that safe? If not set it might be an error. 
		if (Session::is_set('userID')) {
			AbstractService::$log->setIdent(Session::get('userID'));
		};
		if (Session::is_set('rootID')) {
			AbstractService::$log->setRootID(Session::get('rootID'));
		};
		
		// Create the operation classes
		$this->loginOps = new LoginOps($this->db);
		$this->copyOps = new CopyOps($this->db);
		$this->manageableOps = new ManageableOps($this->db);
		$this->contentOps = new ContentOps($this->db);
		//$this->licenceOps = new LicenceOps($this->db);
		$this->usageOps = new UsageOps($this->db);
		$this->reportOps = new ReportOps($this->db);
		// CCB
		//$this->ccbOps = new CCBOps($this->db);

	}
	// Allow several optional parameters to come from Flash
	// $productCode is deprecated
	function login($username, $password, $rootID = null, $dbHost=null, $productCode = null) {
		$allowedUserTypes = array(User::USER_TYPE_TEACHER,
								 User::USER_TYPE_ADMINISTRATOR,
								 User::USER_TYPE_AUTHOR,
								 User::USER_TYPE_REPORTER);
								 
		$loginObj = $this->loginOps->login($username, $password, $allowedUserTypes, $rootID, 2);
		
		if ($loginObj) {	
			// RM specific setup values for this root
			if (isset($loginObj->F_LangaugeCode) && strlength($loginObj->F_LanguageCode)>0) {
				Session::set('languageCode', $loginObj->F_LanguageCode);
			} else {
				Session::set('languageCode', 'EN');
			}
			Session::set('rootID', $loginObj->F_RootID);
			Session::set('rootGroupID', $loginObj->F_GroupID);
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
			// and SciencesPo, and HSBC?
			if ((int)$loginObj->F_RootID == 13770 || (int)$loginObj->F_RootID == 14252 || 
				(int)$loginObj->F_RootID==11056) {
				Session::set('no_students', ($manageablesCount > 8000));
				//NetDebug::trace("for SciencesPo, users=$manageablesCount");
			} else {
				Session::set('no_students', ($manageablesCount > $GLOBALS['max_manageables_for_student_display']));
			}
			
			// v3.4 I would like to send back (some) account root information as well (remember that accounts in RM means titles)
			// v3.6 Maybe it is better to do a separate getAccount call as I also want things like adminUser's email
			$accountRoot = $this->manageableOps->getAccountRoot($loginObj->F_RootID);
			//NetDebug::trace('accountRoot='.$accountRoot->prefix);

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
			//NetDebug::trace('originalStartPage='.$_SESSION['originalStartpage'].'!');
			if (isset($_SESSION['dbHost'])) {
				NetDebug::trace('ClarityService session.dbHost='.$_SESSION['dbHost']);
			} else {
				NetDebug::trace('ClarityService session.dbHost not set');
			}
			NetDebug::trace('db used '.$GLOBALS['db']);
			// Invalid username/password
			return false;
		}
	}
	
	function logout() {
		$this->loginOps->logout();
	}
	
	function getLoginOpts() {
		return $this->loginOps->getLoginOpts();
	}
	
	function setLoginOpts($loginOption, $selfRegister, $passwordRequired) {
		return $this->loginOps->setLoginOpts($loginOption, $selfRegister, $passwordRequired);
	}
	// v3.6 For setting email options. It would be more sensible to put this in accountOps, but that is saved for DMS
	// so I will bundle with loginOpts, which is incorrectly bundled with loginOps!
	function getEmailOpts() {
		return $this->loginOps->getEmailOpts();
	}
	function setEmailOpts($emailOptionsArray) {
		return $this->loginOps->setEmailOpts($emailOptionsArray);
	}
	
	/**
	 * Get the copy XML document
	 */
	function getCopy() {
		return $this->copyOps->getCopy();
	}
	
	function getAllManageables() {
		return $this->manageableOps->getAllManageables();
	}
	
	function getContent() {
		return $this->contentOps->getContent();
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

	// v3.6.1 Allow moving and importing
	//function importManageables($groups, $users, $parentGroup) {
	function importManageables($groups, $users, $parentGroup, $moveExistingStudents=false) {
		//Throw new Exception("importManageables with moving=".$moveExistingStudents);
		// AR Special function for updating the names of lots of students keyed on studentID
		return $this->manageableOps->importManageables($groups, $users, $parentGroup, $moveExistingStudents);
		//return $this->manageableOps->updateManageableNames($groups);
	}

	// This call is not used anymore
	// 3.4 But it is still made! So remove any further calls.
	function getLicences() {
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
	function getExtraGroups($user) {
		// v3.4 Multi-group users
		//return $this->manageableOps->getExtraGroups($user->id);
		return $this->manageableOps->getExtraGroups($user->userID);
	}
	
	function setExtraGroups($user, $groupsArray) {
		return $this->manageableOps->setExtraGroups($user, $groupsArray);
	}
	
	function getUsageForTitle($title, $fromDate, $toDate) {
		return $this->usageOps->getUsageForTitle($title, $fromDate, $toDate);
	}
	// v3.0.4 Include the template as well
	function getReport($onReportableIDObjects, $onClass, $forReportableIDObjects, $forClass, $reportOpts, $template='standard') {
		// Since we are potentially passing a lot of reportables to this from the client pass IDs instead of VOs to save on transfer overhead
		return $this->reportOps->getReport($onReportableIDObjects, $onClass, $forReportableIDObjects, $forClass, $reportOpts, $template);
	}
	
	function getHiddenContent() {
		return $this->contentOps->getHiddenContent();
	}
	function getEditedContent($groupIDs) {
		return $this->contentOps->getEditedContent($groupIDs);
	}
	
	function setHiddenContent($contentIDObject, $groupID, $visible) {
		return $this->contentOps->setHiddenContent($contentIDObject, $groupID, $visible);
	}
	// v3.4 Editing Clarity Content
	function initEditedContent($toPath, $groupID) {
		return $this->contentOps->initEditedContent($toPath, $groupID);
	}
	// V3.5 Add another variable
	//function checkEditedContentExercise($fromPath, $toPath, $groupID, $UID, $caption) {		
	function checkEditedContentExercise($fromPath, $toPath, $groupID, $UID, $caption, $exerciseID) {		
		return $this->contentOps->checkEditedContentExercise($fromPath, $toPath, $groupID, $UID, $caption, $exerciseID);
	}
	function checkEditedContentFolder($toPath, $groupID) {		
		return $this->contentOps->checkEditedContentFolder($toPath, $groupID);
	}
	// This works for moving and inserting content (and probably deleting too)
	// v3.5 Send the title so I can reset related UIDs if necessary
	function moveContent($editedUID, $groupID, $relatedUID, $mode, $title) {
		return $this->contentOps->moveContent($editedUID, $groupID, $relatedUID, $mode, $title);
	}
	function insertContent($editedUID, $groupID, $relatedUID, $mode, $toPath) {
		return $this->contentOps->insertContent($editedUID, $groupID, $relatedUID, $mode, $toPath);
	}
	function copyContent($editedUID, $groupID, $relatedUID, $mode, $toPath) {
		return $this->contentOps->copyContent($editedUID, $groupID, $relatedUID, $mode, $toPath);
	}
	function resetContent($editedUID, $groupID) {
		return $this->contentOps->resetContent($editedUID, $groupID);
	}

}

?>