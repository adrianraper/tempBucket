<?php
/**
 * Called from amfphp gateway from Flex
 */
require_once(dirname(__FILE__)."/RotterdamService.php");

class RotterdamBuilderService extends RotterdamService {
	
	function __construct() {
		parent::__construct();
		
		// If a user is logged in then get the content folder
		if (Session::is_set('userID')) {
			// If there is no content folder for this user then create one
			if (!is_dir($this->accountFolder))
				$this->createAccountFolder();
		}
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
	
	public function courseCreate($course) {
		// TODO: Only allow this if the logged in user has permission
		return $this->courseOps->courseCreate($course);
	}
	
	public function courseSave($filename, $xml) {
		// TODO: Only allow this if the logged in user has permission
		return $this->courseOps->courseSave($filename, $xml);
	}
	
	public function courseDelete($course) {
		// TODO: Only allow this if the logged in user has permission
		return $this->courseOps->courseDelete($course);
	}
	
	/**
	 * Create a blank account folder with all required directories and an empty course.xml (for now we're not sure there are any required directories)
	 */
	private function createAccountFolder() {
		// Create the account folder containing a default courses.xml
		// GH #65 - by only doing this if mkdir returns true we are effectively implementing concurrency locking (since if it returns false then someone else is doing
		// it, and the delay of half a second will be more than enough for it to complete).
		if (mkdir($this->accountFolder)) {
			$courseXML = <<<XML
<?xml version="1.0" encoding="utf-8"?>
<bento xmlns="http://www.w3.org/1999/xhtml">
	<courses />
</bento>
XML;
			file_put_contents($this->accountFolder."/courses.xml", $courseXML);
			
			// Create a media folder containing a default meta.xml
			mkdir($this->accountFolder."/media");
			$mediaXML = <<<XML
<?xml version="1.0" encoding="utf-8"?>
<bento xmlns="http://www.w3.org/1999/xhtml">
	<files />
</bento>	
XML;
			file_put_contents($this->accountFolder."/media/media.xml", $mediaXML);
		} else {
			usleep(500);
		}
	}
		
}