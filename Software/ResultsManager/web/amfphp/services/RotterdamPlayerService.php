<?php
/**
 * Called from amfphp gateway from Flex
 */
require_once(dirname(__FILE__)."/RotterdamService.php");

class RotterdamPlayerService extends RotterdamService {
	
	function __construct() {
		parent::__construct();		
	}
	
}