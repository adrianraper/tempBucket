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
			$this->courseOps = new CourseOps($this->db, $this->accountFolder);
			$this->mediaOps = new MediaOps($this->accountFolder);
		}
	}
	
	public function getContent() {
		// gh#81 Ignore Rotterdam when getting back Clarity content that you can use as widgets
		$productCodes = array(-54, -12, -13);
		return $this->contentOps->getContent($productCodes);
	}
	
}