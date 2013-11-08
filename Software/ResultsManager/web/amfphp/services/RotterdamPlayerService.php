<?php
/**
 * Called from amfphp gateway from Flex
 */
require_once(dirname(__FILE__)."/RotterdamService.php");
require_once(dirname(__FILE__)."/../../classes/TemplateOps.php");
require_once(dirname(__FILE__)."/../../classes/EmailOps.php");

class RotterdamPlayerService extends RotterdamService {
	
	function __construct() {		
		// gh#341 A unique ID to distinguish sessions between multiple Clarity applications
		Session::setSessionName("RotterdamPlayer");
		
		parent::__construct();
	}

	// I don't think this should be called, but is throwing errors at present
	public function courseSessionUpdate($courseId) {
		
	}
	
}