<?php
/**
 * Called from amfphp gateway from Flex
 */
require_once(dirname(__FILE__)."/BentoService.php");

class TenseBusterService extends BentoService {
	
	function __construct() {
		// gh#341 A unique ID to distinguish sessions between multiple Clarity applications
		Session::setSessionName("TenseBusterService");
		
		parent::__construct();
		
		// Set the title name for resources
		AbstractService::$title = "tensebuster";
	}
	
}