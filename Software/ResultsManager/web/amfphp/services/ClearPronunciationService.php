<?php
/**
 * Called from amfphp gateway from Flex
 */
require_once(dirname(__FILE__)."/BentoService.php");

class ClearPronunciationService extends BentoService {
	
	function __construct() {
		// gh#341 A unique ID to distinguish sessions between multiple Clarity applications
		Session::setSessionName("ClearPronunciationService");
		
		parent::__construct();
		
		// Set the title name for resources
		AbstractService::$title = "clearpronunciation";
	}
	// I don't think this should be called, but is throwing errors at present
	public function courseSessionUpdate($courseId) {
		
	}
}