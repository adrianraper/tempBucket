<?php
/**
 * Called from amfphp gateway from Flex
 */
require_once(dirname(__FILE__)."/BentoService.php");

class IELTSService extends BentoService {
	
	function __construct() {
		// gh#341 A unique ID to distinguish sessions between multiple Clarity applications
		Session::setSessionName("IELTS");
		
		parent::__construct();
		
		// Set the title name for resources
		AbstractService::$title = "ielts";
	}
	
	// HCT hack.  If the passed menu file doesn't contain a correct version, add it in
	public function xhtmlLoad($href) {
		if ($href->type == Href::MENU_XHTML && stristr($href->filename, '-.xml'))
    		$href->filename = preg_replace('/(\w+)-\.xml/i', '$1-FullVersion.xml', $href->filename);
    	
    	return parent::xhtmlLoad($href);
	}
	
}