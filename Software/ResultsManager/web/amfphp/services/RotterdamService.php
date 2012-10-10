<?php
/**
 * Called from amfphp gateway from Flex
 */
require_once(dirname(__FILE__)."/BentoService.php");
require_once(dirname(__FILE__)."/../../classes/CourseOps.php");
require_once(dirname(__FILE__)."/../../classes/MediaOps.php");

class RotterdamService extends BentoService {
	
	function __construct() {
		parent::__construct();
		
		// Set the title name for resources
		AbstractService::$title = "rotterdam";
		
		// If a user is logged in then get the content folder
		if (Session::is_set('userID')) {
			// Hard code the path for the moment
			//$this->accountFolder = "d:/ContentBench/CCB/".Session::get('dbContentLocation');
			$this->accountFolder = "D:/Projects/Clarity/ContentBench/CCB/".Session::get('dbContentLocation');
			$this->courseOps = new CourseOps($this->accountFolder);
			$this->mediaOps = new MediaOps($this->accountFolder);
			
			// If there is no content folder for this user then create one
			if (!is_dir($this->accountFolder)) $this->createAccountFolder();
		}
	}
	
	public function courseCreate($course) {
		// TODO: Only allow this if the logged in user has permission
		$this->courseOps->courseCreate($course);
	}
	
	public function courseSave($filename, $xml) {
		// TODO: Only allow this if the logged in user has permission
		$this->courseOps->courseSave($filename, $xml);
	}
	
	/**
	 * Create a blank account folder with all required directories and an empty course.xml (for now we're not sure there are any required directories)
	 */
	private function createAccountFolder() {
		// Create the account folder containing a default courses.xml
		mkdir($this->accountFolder);
		$courseXML = <<<XML
<?xml version="1.0" encoding="utf-8"?>
<bento xmlns="http://www.w3.org/1999/xhtml">
	<courses />
</bento>
XML;
		file_put_contents($this->accountFolder."/courses.xml", $courseXML, LOCK_EX);
		
		// Create a media folder containing a default meta.xml
		mkdir($this->accountFolder."/media");
		$mediaXML = <<<XML
<?xml version="1.0" encoding="utf-8"?>
<bento xmlns="http://www.w3.org/1999/xhtml">
	<files />
</bento>	
XML;
		file_put_contents($this->accountFolder."/media/media.xml", $mediaXML, LOCK_EX);
	}
	
}