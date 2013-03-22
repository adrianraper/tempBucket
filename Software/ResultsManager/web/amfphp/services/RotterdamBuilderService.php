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
	
	public function xhtmlLoad($href) {
		$xhtml = parent::xhtmlLoad($href);
		
		// gh#142
		if ($href->type == Href::MENU_XHTML) {
			$courseId = $href->options["courseId"];
			
			$sql = <<<EOD
				SELECT F_UserID 
				FROM T_CourseConcurrency
				WHERE F_CourseID=?
				AND F_RootID=?
				AND F_UserID != ?
				AND F_Timestamp > DATE_SUB(NOW(), INTERVAL 1 MINUTE)
EOD;
			
			$results = $this->db->GetCol($sql, array($courseId, Session::get('rootID'), Session::get('userID')));
			
			if ($results[0] > 0)
				throw $this->copyOps->getExceptionForId("errorConcurrentCourseAccess");
			
			// Otherwise this is a successfuly login so update the timer (this is also done every minute triggered by the client)
			$this->courseSessionUpdate($href->options["courseId"]);
		}
		
		return $xhtml;
	}
	
	public function courseSessionUpdate($courseId) {
		$fields = array(
			"F_RootID" => Session::get('rootID'),
			"F_UserID" => Session::get('userID'),
			"F_CourseID" => (string)$courseId,
			"F_Timestamp" => "NOW()",
		);
		
		$this->db->Replace("T_CourseConcurrency", $fields, array("F_RootID", "F_UserID"));
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

	// gh#122
	public function sendWelcomeEmail($courseID, $groupID) {
		// This will send a welcome email to any student in this group for this course
		// (and subgroups that don't have their own publication data??)
		// TODO. Can I make this trigger a background process so I can get back quickly?
		return true;
	}
}