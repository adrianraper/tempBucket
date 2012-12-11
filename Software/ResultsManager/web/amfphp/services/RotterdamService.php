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
			// Get the path from config.php, but it would be better to come from the application, set in config.xml
			$this->accountFolder = "../../".$GLOBALS['ccb_data_dir']."/".Session::get('dbContentLocation');
			$this->courseOps = new CourseOps($this->accountFolder);
			$this->mediaOps = new MediaOps($this->accountFolder);
			
			// If there is no content folder for this user then create one
			if (!is_dir($this->accountFolder))
				$this->createAccountFolder();
		}
	}
	
	public function getContent() {
		return $this->contentOps->getContent();
	}
	
	/**
	 * GH #84 - when loading Hrefs in Bento there is an option 'serverSide' boolean that can be set which pipes the XHTML_LOAD notification through
	 * this server-side method instead of loading it directly, giving the server a change to fiddle with the xml before returning it (or even constructing
	 * it completely on the fly).  For security reasons the allowed filenames MUST be specified in a switch, otherwise this could comprimise the server.
	 * 
	 * TODO: allow $options to be passed in order to configure this further
	 * TODO: all the confusion around XHTMLProxy vs ProgressProxy could potentially be fixed using this new system
	 */
	public function xhtmlLoad($filename) {
		switch ($filename) {
			case "courses.xml":
				return $this->courseOps->coursesLoad();
			default:
				throw $this->copyOps->getExceptionForId("errorSecurity");
		}
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