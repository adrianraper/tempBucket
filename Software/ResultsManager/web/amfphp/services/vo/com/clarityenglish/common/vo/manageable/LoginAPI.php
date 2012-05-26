<?php

class LoginAPI {

	// I think this is only for AMFPHP - not needed here
	var $_explicitType = 'com.clarityenglish.common.vo.manageable.LoginAPI';
	
	var $method;
	var $name;
	var $studentID;
	var $password;
	var $email;
	var $userID;
	var $groupID;
	var $rootID;
	var $prefix;
	var $productCode;
	var $expiryDate;
	var $city;
	var $country;
	var $loginOption;
	var $dbHost;
	var $emailTemplateID;
	var $custom1;
	var $custom2;
	var $custom3;
	var $custom4;
	var $subscriptionPeriod;
	var $licenceType;
	// Winhoe.
	var $groupName;
	var $teacherName;
	var $teacherID;
	
	function LoginAPI() {
	}
	/*
	 * Parse the condition into an object
	 *
	*/
	function createFromSentFields($info) {
	
		// Mandatory fields
		if (isset($info['method']))
			$this->method = $info['method'];
			
		// Optional fields
		if (isset($info['name'])) 
			$this->name = $info['name'];
		if (isset($info['studentID'])) 
			$this->studentID = $info['studentID'];
		if (isset($info['email'])) 
			$this->email = $info['email'];
		if (isset($info['password'])) 
			$this->password = $info['password'];
		if (isset($info['userID'])) 
			$this->userID = $info['userID'];
		if (isset($info['groupID'])) 
			$this->groupID = $info['groupID'];
		if (isset($info['rootID'])) 
			$this->rootID = $info['rootID'];
		if (isset($info['prefix'])) 
			$this->prefix = $info['prefix'];
		if (isset($info['expiryDate'])) 
			$this->expiryDate = $info['expiryDate'];
		if (isset($info['productCode'])) 
			$this->productCode = $info['productCode'];
		if (isset($info['city'])) 
			$this->city = $info['city'];
		if (isset($info['country'])) 
			$this->country = $info['country'];
		if (isset($info['emailTemplateID'])) 
			$this->emailTemplateID = $info['emailTemplateID'];
		if (isset($info['custom1'])) 
			$this->custom1 = $info['custom1'];
		if (isset($info['custom2'])) 
			$this->custom2 = $info['custom2'];
		if (isset($info['custom3'])) 
			$this->custom3 = $info['custom3'];
		if (isset($info['custom4'])) 
			$this->custom4 = $info['custom4'];
		if (isset($info['subscriptionPeriod'])) 
			$this->subscriptionPeriod = $info['subscriptionPeriod'];
		if (isset($info['licenceType'])) 
			$this->licenceType = $info['licenceType'];
			
		// AutoGroup.
		if (isset($info['groupName'])) 
			$this->groupName = $info['groupName'];
		if (isset($info['teacherName'])) 
			$this->teacherName = $info['teacherName'];
		if (isset($info['teacherID'])) 
			$this->teacherID = $info['teacherID'];
			
		// Fields with defaults if not sent
		// TODO. This should not be sent, it should be read from the account
		// but perhaps account value can be overwritten if sent
		if (isset($info['loginOption'])) {
			$this->loginOption = $info['loginOption'];
		} else {
			$this->loginOption = 1;
		}
		if (isset($info['dbHost'])) {
			$this->dbHost = $info['dbHost'];
		} else {
			$this->dbHost = 0;
		}
	}
	
	public function toString() {
		$buildString = 'user details';
		if (isset($this->name))
			$buildString.= ', name '.$this->name;
		if (isset($this->studentID))
			$buildString.= ', studentID:'.$this->studentID;
		if (isset($this->email))
			$buildString.= ', email:'.$this->email;
		if (isset($this->rootID))
			$buildString.= ' in root:'.$this->rootID;
		if (isset($this->groupID))
			$buildString.= ', group:'.$this->groupID;
		return 'API '.$buildString;
	}
}
?>
