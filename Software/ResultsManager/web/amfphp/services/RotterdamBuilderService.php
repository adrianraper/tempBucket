<?php
/**
 * Called from amfphp gateway from Flex
 */
require_once(dirname(__FILE__)."/RotterdamService.php");

class RotterdamBuilderService extends RotterdamService {
	
	function __construct() {
		parent::__construct();		
	}
	
	public function login($loginObj, $loginOption, $verified, $instanceID, $licence, $rootID = null, $productCode = null, $dbHost = null) {
		
		// gh#66 
		$allowedUserTypes = array(User::USER_TYPE_TEACHER,
								  User::USER_TYPE_ADMINISTRATOR,
								  User::USER_TYPE_AUTHOR);

		// gh#66 Builder treats all accounts as LT as teachers must login
		$licence->licenceType = Title::LICENCE_TYPE_LT;
		
		return parent::login($loginObj, $loginOption, $verified, $instanceID, $licence, $rootID, $productCode, $dbHost, $allowedUserTypes);
		
	}
		
}