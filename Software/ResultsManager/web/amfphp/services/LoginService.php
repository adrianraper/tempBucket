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
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/LoginAPI.php");

require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/trigger/EmailAPI.php");

require_once(dirname(__FILE__)."/../../classes/CopyOps.php");
require_once(dirname(__FILE__)."/../../classes/TemplateOps.php");
require_once(dirname(__FILE__)."/../../classes/EmailOps.php");
require_once(dirname(__FILE__)."/../../classes/ManageableOps.php");
require_once(dirname(__FILE__)."/../../classes/SubscriptionOps.php");
require_once(dirname(__FILE__)."/../../classes/AccountOps.php");
require_once(dirname(__FILE__)."/../../classes/ContentOps.php");
require_once(dirname(__FILE__)."/AbstractService.php");

class LoginService extends AbstractService {
	
	var $db;

	function __construct() {
		parent::__construct();
		
		// A unique ID to distinguish sessions between multiple Clarity applications
		Session::setSessionName("LOGIN");
		
		// Set the product name and userID for logging
		AbstractService::$log->setProductName("LOGIN");
		
		$this->manageableOps = new ManageableOps($this->db);
		$this->subscriptionOps = new SubscriptionOps($this->db);
		
		// DMS has no restrictions on user/group access so disable manageable authentication
		AuthenticationOps::$useAuthentication = false;
	}
	
	// Can you find this user?
	public function getUser($loginDetails) {
		$stubUser = new User();
		// TODO: Add other login options
		if ($loginDetails->loginOption==2) {
			$stubUser->studentID = $loginDetails->studentID;
			$user = $this->manageableOps->getUserByLearnerId($stubUser);
		} else {
			$user = false;
		}
		return $user; 
	}
	
	// Add this user
	public function addUser($loginDetails) {
		//echo "LoginService addUser";
		$stubUser = new User();
		if ($loginDetails->studentID)
			$stubUser->studentID = $loginDetails->studentID;
		if ($loginDetails->name)
			$stubUser->name = $loginDetails->name;
		if ($loginDetails->email)
			$stubUser->email = $loginDetails->email;
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
		// If an explicit expiryDate is set, that is used
		if ($loginDetails->expiryDate) {
			$stubUser->expiryDate = $loginDetails->expiryDate;
		// if a period is set, calculate the expiryDate based on that
		} elseif ($loginDetails->subscriptionPeriod) {
			// parse the period
			sscanf($loginDetails->subscriptionPeriod, "%d%s", $periodValue, $periodUnit);
			if ($periodValue && $periodValue>0 && $periodUnit) {
				switch ($periodUnit) {
					case "y":
					case "year":
						// When you have php 5.3 you can use DateAdd properly
						$subscriptionSeconds = $periodValue * 31556926;
						break;
					case "m":
					case "month":
						$subscriptionSeconds = $periodValue * 2629744;
						break;
					case "w":
					case "week":
						$subscriptionSeconds = $periodValue * 604800;
						break;
					case "d":
					case "day":
						$subscriptionSeconds = $periodValue * 86400;
						break;
				}
				$stubUser->expiryDate = date('Y-m-d H:m:s', time() + $subscriptionSeconds);
			}
		}
			
		$stubUser->userType = User::USER_TYPE_STUDENT;
		$stubUser->registrationDate = date('Y-m-d H:i:s');
		$stubUser->registerMethod = "loginService";
		
		$group = $this->manageableOps->getGroup($loginDetails->groupID);
		 
		return $this->manageableOps->addUser($stubUser, $group, $loginDetails->rootID);
	}
	
}