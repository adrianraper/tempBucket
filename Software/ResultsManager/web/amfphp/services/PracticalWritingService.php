<?php
/**
 * Called from amfphp gateway from Flex
 */
require_once(dirname(__FILE__)."/BentoService.php");

class PracticalWritingService extends BentoService {
	
	function __construct() {
		// gh#341 A unique ID to distinguish sessions between multiple Clarity applications
		Session::setSessionName("PracticalWritingService");
		
		parent::__construct();
		
		// Set the title name for resources
		AbstractService::$title = "practicalwriting";
	}

	// A fake function used to allow CouloirGateway to call this Bento service
	public function setAppVersion($data) {

    }
	
}