<?php
/**
 * Called from amfphp gateway from Flex
 */
require_once(dirname(__FILE__)."/BentoService.php");

class ResultsManagerService extends BentoService {
	
	function __construct() {
		Session::setSessionName("ResultsManagerService");
		
		parent::__construct();
		
		// Set the title name for resources
		AbstractService::$title = "resultsmanager";
	}

    function generateCoverageReport($menuXml, $template) {

        // load the template

        // include any extra functions or styling

        // push the data into the template

        $dom = new DOMDocument("1.0", "UTF-8");

        return $dom;
    }

    /*
     * This takes the names of units that Moodle made from the SCORM object and converts to a full name that
     * can be found in the menu.xml.
     * TODO Are the Moodle names unique to each institution?
     */
    function convertUnitSCORMName($unitName) {
        switch (strtolower($unitName)) {
            case "am is are":
                return "am, is, are (to be)";
            case "i my me":
                return "i, my, me";
            case "will and going to":
                return "'will' and 'going to'";
            default:
                return strtolower($unitName);
        }
    }
	
}