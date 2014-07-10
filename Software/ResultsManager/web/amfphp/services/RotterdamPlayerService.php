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

	// gh#954 Player will use this to update the session record for usage purposes
	public function courseSessionUpdate($courseId, $sessionId) {
		return $this->updateSession($sessionId, $courseId);
	}
	
}