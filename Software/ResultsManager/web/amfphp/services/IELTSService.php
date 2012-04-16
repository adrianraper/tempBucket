<?php
/**
 * Called from amfphp gateway from Flex
 */
require_once(dirname(__FILE__)."/BentoService.php");

class IELTSService extends BentoService {
	
	function __construct() {
		parent::__construct();
		
		// Set the title name for resources
		AbstractService::$title = "ielts";
	}
	
}