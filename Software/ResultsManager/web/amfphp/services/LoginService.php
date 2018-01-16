<?php
/**
 * Handles the different functions of login and user registration
 */
require_once(dirname(__FILE__)."/../../config.php");
 
require_once($GLOBALS['adodb_libs']."adodb-exceptions.inc.php");
require_once($GLOBALS['adodb_libs']."adodb.inc.php");

require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/Reportable.php");

require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/Manageable.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/User.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/Group.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/account/Account.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/content/Title.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/LoginAPI.php");

require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/trigger/EmailAPI.php");

require_once(dirname(__FILE__)."/../../classes/CopyOps.php");
require_once(dirname(__FILE__)."/../../classes/TemplateOps.php");
require_once(dirname(__FILE__)."/../../classes/EmailOps.php");
require_once(dirname(__FILE__)."/../../classes/ManageableOps.php");
require_once(dirname(__FILE__)."/../../classes/SubscriptionOps.php");
require_once(dirname(__FILE__)."/../../classes/AccountOps.php");
require_once(dirname(__FILE__)."/../../classes/ContentOps.php");
require_once(dirname(__FILE__)."/../../classes/MemoryOps.php");

require_once(dirname(__FILE__)."/AbstractService.php");

require_once($GLOBALS['common_dir'].'/encryptURL.php');

class LoginService extends AbstractService {
	
	var $db;

	function __construct() {
		parent::__construct();
		
		// A unique ID to distinguish sessions between multiple Clarity applications
		Session::setSessionName("LOGIN");
		
		// Set the product name and userID for logging
		AbstractService::$log->setProductName("LOGIN");
		AbstractService::$debugLog->setProductName("LOGIN");
		AbstractService::$controlLog->setProductName("LOGIN");

		// Set the title name for resources
		AbstractService::$title = "rm";
		
		$this->manageableOps = new ManageableOps($this->db);
		$this->subscriptionOps = new SubscriptionOps($this->db);
		$this->accountOps = new AccountOps($this->db);

		// DMS has no restrictions on user/group access so disable manageable authentication
		AuthenticationOps::$useAuthentication = false;
	}
	
	public function changeDB($dbHost) {
		$this->changeDbHost($dbHost);
		
		$this->manageableOps->changeDB($this->db);
		$this->subscriptionOps->changeDB($this->db);
		$this->accountOps->changeDB($this->db);
	}
	
	// Can you find this user?
	public function getUser($loginDetails) {

		if ($loginDetails->loginOption & User::LOGIN_BY_NAME ||
			$loginDetails->loginOption & User::LOGIN_BY_ID ||
			$loginDetails->loginOption & User::LOGIN_BY_EMAIL) {
			$stubUser = new User();
			// gh#653 correct object name
			if (isset($loginDetails->name)) $stubUser->name = $loginDetails->name;
			if (isset($loginDetails->studentID)) $stubUser->studentID = $loginDetails->studentID;
			if (isset($loginDetails->email)) $stubUser->email = $loginDetails->email;
		} else {
			return false;		
		}		

		// Are there any conditions that you should search with?
		// TODO. Need something like the conditions for getAccounts here so that it can scale
		if (isset($loginDetails->licenceType))
			return $this->manageableOps->getCLSUserByKey($stubUser, $loginDetails->loginOption);
			
		if (isset($loginDetails->rootID))
			return $this->manageableOps->getUserByKey($stubUser, $loginDetails->rootID, $loginDetails->loginOption);
			
		return $this->manageableOps->getUserByKey($stubUser, 0, $loginDetails->loginOption);
	}
	
	// Add this user
	public function addUser($loginDetails, $group) {
		//echo "LoginService addUser";
		$stubUser = new User();
		if ($loginDetails->studentID)
			$stubUser->studentID = $loginDetails->studentID;
		if ($loginDetails->name)
			$stubUser->name = $loginDetails->name;
		if ($loginDetails->email)
			$stubUser->email = $loginDetails->email;
		if ($loginDetails->password)
			$stubUser->password = $loginDetails->password;
		if ($loginDetails->productCode)
			$stubUser->userProfileOption = $loginDetails->productCode;
		if ($loginDetails->city)
			$stubUser->city = $loginDetails->city;
		if ($loginDetails->country)
			$stubUser->country = $loginDetails->country;
		if ($loginDetails->custom1)
			$stubUser->custom1 = $loginDetails->custom1;
		if ($loginDetails->custom2)
			$stubUser->custom2 = $loginDetails->custom2;
		if ($loginDetails->custom3)
			$stubUser->custom3 = $loginDetails->custom3;
		if ($loginDetails->custom4)
			$stubUser->custom4 = $loginDetails->custom4;
		if ($loginDetails->birthday)
			$stubUser->birthday = $loginDetails->birthday;
		// gh#163
		// If an explicit expiryDate is set, that is used
		if ($loginDetails->expiryDate) {
			$stubUser->expiryDate = $loginDetails->expiryDate;
		// if a period is set, calculate the expiryDate based on that
		} elseif ($loginDetails->subscriptionPeriod) {
			// parse the period
			$rc = sscanf($loginDetails->subscriptionPeriod, "%d%s", $periodValue, $periodUnit);
			if ($periodValue && $periodValue>0 && $periodUnit) {
				switch ($periodUnit) {
					case "y":
					case "year":
					case "years":
						// When you have php 5.3 you can use DateAdd properly
						$subscriptionSeconds = $periodValue * 31556926;
						break;
					case "m":
					case "month":
					case "months":
						$subscriptionSeconds = $periodValue * 2629744;
						break;
					case "w":
					case "week":
					case "weeks":
						$subscriptionSeconds = $periodValue * 604800;
						break;
					case "d":
					case "day":
					case "days":
						$subscriptionSeconds = $periodValue * 86400;
						break;
				}
				$stubUser->expiryDate = date('Y-m-d H:m:s', time() + $subscriptionSeconds);
			}
		}
			
		$stubUser->userType = User::USER_TYPE_STUDENT;
		$stubUser->registrationDate = date('Y-m-d H:i:s');
		if ($loginDetails->registerMethod) {
			$stubUser->registerMethod = $loginDetails->registerMethod;
		} else {
			$stubUser->registerMethod = "loginService";
		}
		
		// gh#164 pass loginOption to help with quick duplicate checking
		return $this->manageableOps->addUser($stubUser, $group, $loginDetails->rootID, $loginDetails->loginOption);
	}
	/**
	 * Return the group object given groupID or a user in that group
	 */
	public function getGroup($loginDetails, $account = null) {
		
		// First special case is that you know the groupID (based on a serial number for instance)
		// but you don't have any account information
		if ($loginDetails->groupID)
			return $this->manageableOps->getGroup($loginDetails->groupID);
		
		// AutoGroup. You might not know a userID at this point, just a group name.
		if (!$loginDetails->userID && $loginDetails->groupName && $loginDetails->rootID)
			return $this->manageableOps->getGroupByName($loginDetails->groupName, $loginDetails->rootID);

		// AutoGroup. If you failed to send group details, send back the top level group for the account
		if (!$loginDetails->userID) {
			if ($account) {
				return $this->manageableOps->getGroup($this->manageableOps->getGroupIdForUserId($account->adminUser->userID));
			} else {
				throw new Exception("Can't find a group without a groupID, userID or an account.");
			}
		}
			
		// The normal case is that you found the user, so get their group/account info from T_Membership
		// TODO. Surely the above will work this way as well and is safer.
		return $this->manageableOps->getGroup($this->manageableOps->getGroupIdForUserId($loginDetails->userID));
	}
	
	/**
	 * Add a group to a known account
	 */
	public function addGroup($loginDetails, $account) {
		
		// Get the top level group for the account as this is where we will create our new group
		$parentGroup = $this->manageableOps->getGroup($this->manageableOps->getGroupIdForUserId($account->adminUser->userID));
		
		// Build and add the group object
		$group = new Group();
		$group->name = $loginDetails->groupName;
		$group = $this->manageableOps->addGroup($group, $parentGroup);
		
		return $group;
				
	}
	/**
	 * Link a user to a group. As of now, we don't have a user in multiple groups.
	 * So this only works for teachers and we use the T_ExtraTeacherGroups table.
	 */
	public function linkUserToGroup($user, $group) {
		
		// First check to see if this user is already in this group
		foreach ($this->manageableOps->getUsersGroups($user) as $foundGroup) {
			if ($group->id == $foundGroup->id)
				return true;
		}
		
		// Not, so confirm that they are a teacher and use the ExtraTeacherGroups table
		if ($user->userType == User::USER_TYPE_TEACHER) {
			return $this->manageableOps->addTeacherToExtraGroup($user, $group);
		}
		
		return false;
	}
	
	public function getAccountFromGroup($group) {
		return $this->accountOps->getAccountFromGroup($group);
	}
	
	public function getAccountFromPrefix($loginDetails) {
		return $this->accountOps->getAccountFromPrefix($loginDetails->prefix);
	}
	
	public function getAccountFromRootID($loginDetails) {
		// Should only be one account returned
        $accounts = $this->accountOps->getAccounts(array($loginDetails->rootID));
		return array_shift($accounts);
	}
	
	public function getAccountFromUser($user) {
		return $this->accountOps->getAccountFromUser($user);
	}
	
	public function updateUserInformation($loginDetails, $user) {
		if (isset($loginDetails->name) && $user->name != $loginDetails->name) $user->name = $loginDetails->name;
		if (isset($loginDetails->email) && $user->email != $loginDetails->email) $user->email = $loginDetails->email;
		if (isset($loginDetails->expiryDate) && $user->expiryDate != $loginDetails->expiryDate) $user->expiryDate = $loginDetails->expiryDate;
		if (isset($loginDetails->country) && $user->country != $loginDetails->country) $user->country = $loginDetails->country;
		if (isset($loginDetails->city) && $user->city != $loginDetails->city) $user->city = $loginDetails->city;
		if (isset($loginDetails->birthday) && substr($user->birthday,0,10) != substr($loginDetails->birthday,0,10)) $user->birthday = $loginDetails->birthday;
		
		$usersArray[0] = $user;
		
		return $this->manageableOps->updateUsers($usersArray, $loginDetails->rootID);
	}
}