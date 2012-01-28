<?php

class LoginAPI {

	// I think this is only for AMFPHP - not needed here
	var $_explicitType = 'com.clarityenglish.common.vo.manageable.LoginAPI';
	
	var $method;
	var $name;
	var $studentID;
	var $email;
	var $userID;
	var $groupID;
	var $rootID;
	var $prefix;
	var $loginType;

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
		if (isset($info['userID'])) 
			$this->userID = $info['userID'];
		if (isset($info['groupID'])) 
			$this->rootID = $info['groupID'];
		if (isset($info['rootID'])) 
			$this->rootID = $info['rootID'];
		if (isset($info['prefix'])) 
			$this->prefix = $info['prefix'];
		if (isset($info['loginType'])) 
			$this->loginType = $info['loginType'];
	}
	
	public function toString() {
		$buildString = 'user details';
		if (isset($this->name))
			$buildString.= ', name '.$this->name;
		if (isset($this->studentID))
			$buildString.= ', studentID:'.$this->studentID;
		if (isset($this->email))
			$buildString.= ', email:'.$this->email;
		return 'API '.$buildString;
	}
}
?>
