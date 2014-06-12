<?php
/**
 * Called from amfphp gateway from Flex
 */
require_once(dirname(__FILE__)."/RotterdamService.php");

class RotterdamBuilderService extends RotterdamService {
	
	function __construct() {
		// gh#341 A unique ID to distinguish sessions between multiple Clarity applications
		Session::setSessionName("RotterdamBuilder");
		
		parent::__construct();

		// If a user is logged in then get the content folder
		if (Session::is_set('userID')) {
			
			// AbstractService::$log->info('accountFolder='.$this->accountFolder);
			
			// gh#338 This is a check that the account content folder has a good structure
			// Look for a media file (which implies the full folder structure exists)
			if (!file_exists($this->accountFolder."/media/media.xml")) {
				// If there is no content folder for this user then create one
				if (!is_dir($this->accountFolder)){
					$this->createAccountFolder();
				}
				if (!is_dir($this->accountFolder."/media")){
					$this->createMediaFolder();
				}
				$this->createMediaXML();
			}
			// Also look for a courses file in the account folder
			if (!file_exists($this->accountFolder."/courses.xml")) {
				$this->createCoursesXML();
			}
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
		// gh#91 You only need to consider concurrency if this user can edit the course
		if ($href->type == Href::MENU_XHTML && 
			($href->options['enabledFlag'] & Course::EF_OWNER || $href->options['enabledFlag'] & Course::EF_COLLABORATOR)) {
			$courseId = $href->options["courseId"];

			// gh#385, gh#815
			$datetimeStamp = new DateTime('now', new DateTimeZone(TIMEZONE));
			$datetimeStamp->sub(new DateInterval('PT1M'));
			$sql = <<<EOD
				SELECT F_UserID 
				FROM T_CourseConcurrency
				WHERE F_CourseID = ?
				AND F_UserID != ?
				AND F_Timestamp > ?;
EOD;
			$bindingParams = array($courseId, Session::get('userID'), $datetimeStamp->format('Y-m-d H:i:s'));
			$results = $this->db->GetCol($sql, $bindingParams);
			
			if ($results[0] > 0)
				throw $this->copyOps->getExceptionForId("errorConcurrentCourseAccess");
			
			// Otherwise this is a successfull login so update the timer (this is also done every minute triggered by the client)
			$this->courseSessionUpdate($href->options["courseId"]);
		}
		
		return $xhtml;
	}
	
	public function courseSessionUpdate($courseId) {
		$fields = array(
			"F_RootID" => Session::get('rootID'),
			"F_UserID" => Session::get('userID'),
			"F_CourseID" => (string)$courseId,
			"F_Timestamp" => date("Y-m-d H:i:s"),
		);
		
		$this->db->Replace("T_CourseConcurrency", $fields, array("F_UserID", "F_CourseID"), true);
	}
	
	public function courseCreate($course) {
		return $this->courseOps->courseCreate($course);
	}
	
	public function courseSave($filename, $xml) {
		return $this->courseOps->courseSave($filename, $xml);
	}
	
	public function courseDelete($course) {
		return $this->courseOps->courseDelete($course);
	}
	
	/**
	 * Create a blank account folder with all required directories and an empty course.xml (for now we're not sure there are any required directories)
	 */
	private function createAccountFolder() {
		// Create the account folder containing a default courses.xml
		// gh#65 - by only doing this if mkdir returns true we are effectively implementing concurrency locking (since if it returns false then someone else is doing
		// it, and the delay of half a second will be more than enough for it to complete).
		if (mkdir($this->accountFolder)) {
			$this->createCoursesXML();
		} else {
			usleep(500);
		}
	}

	// gh#339
	private function createMediaFolder() {
		// Create a media folder
		return mkdir($this->accountFolder."/media");
	}
	
	private function createMediaXML() {
		// Create a default meta.xml
		if (is_dir($this->accountFolder."/media")) {
			$mediaXML = <<<XML
<?xml version="1.0" encoding="utf-8"?>
<bento xmlns="http://www.w3.org/1999/xhtml">
	<files />
</bento>	
XML;
			file_put_contents($this->accountFolder."/media/media.xml", $mediaXML);
		}		
	}
	private function createCoursesXML() {
		$courseXML = <<<XML
<?xml version="1.0" encoding="utf-8"?>
<bento xmlns="http://www.w3.org/1999/xhtml">
	<courses />
</bento>
XML;
		file_put_contents($this->accountFolder."/courses.xml", $courseXML);
	}
	
	/**
	 * gh#930
	 * 
	 * This service call overwrites Bento and stops scores from Builder
	 *  
	 */
	public function writeScore($user, $sessionID, $dateNow, $scoreObj) {
		return new Score();
	}
	
	// gh#122
	public function sendWelcomeEmail($courseXML, $groupID) {
		// This will send a welcome email to any student in this group for this course
		// (and subgroups that don't have their own publication data??)
		return $this->courseOps->sendWelcomeEmail($courseXML, $groupID);
	}
}