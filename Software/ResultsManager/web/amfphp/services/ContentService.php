<?php
/**
 * For use with content utilities, such as conversion and item analysis
 */

require_once(dirname(__FILE__)."/../../config.php");
 
require_once($GLOBALS['adodb_libs']."adodb-exceptions.inc.php");
require_once($GLOBALS['adodb_libs']."adodb.inc.php");

require_once(dirname(__FILE__)."/vo/com/clarityenglish/bento/vo/progress/ScoreDetail.php");

// Common ops
require_once(dirname(__FILE__)."/../../classes/AuthenticationOps.php");
require_once(dirname(__FILE__)."/../../classes/CopyOps.php");

// Specific ops needed for content procedures
require_once(dirname(__FILE__)."/../../classes/TestOps.php");
require_once(dirname(__FILE__)."/../../classes/ItemAnalysisOps.php");
require_once(dirname(__FILE__)."/../../classes/ManageableOps.php");
require_once(dirname(__FILE__)."/../../classes/EmailOps.php");
require_once(dirname(__FILE__)."/../../classes/InternalQueryOps.php");

require_once(dirname(__FILE__)."/AbstractService.php");

class ContentService extends AbstractService {
	
	var $db;

	function __construct() {
		parent::__construct();
		
		// A unique ID to distinguish sessions between multiple Clarity applications
		Session::setSessionName("Content");
				
		// Set the product name and userID for logging
		AbstractService::$log->setProductName("CONTENT");

		// Set the title name for resources
		AbstractService::$title = "content";
		
		$this->internalQueryOps = new InternalQueryOps($this->db);
        $this->testOps = new TestOps($this->db);
        $this->itemAnalysisOps = new ItemAnalysisOps($this->db);

		// DMS has no restrictions on user/group access so disable manageable authentication
		AuthenticationOps::$useAuthentication = false;
		
	}

	/**
	 * This function should be called by the first call you make to this service to set the dbHost
	 * 
	 */
	private function initDbHost($dbHost) {
		if ($GLOBALS['dbHost'] != $dbHost) {
				
			// Set session variable so that next time config.php is called it will use this dbHost
			// Which should mean that you only need to pick up dbHost for the first call to a service
			// But it would be much better if I could pass dbHost direct to the service so it simply
			// did this check in the constructor.
			$_SESSION['dbHost'] = $dbHost;
			
			$this->changeDB($dbHost);
		}
	}
		
	public function changeDB($dbHost) {
		$this->changeDbHost($dbHost);
		
		$this->internalQueryOps->changeDB($this->db);
        $this->testOps->changeDB($this->db);
        $this->itemAnalysisOps->changeDB($this->db);
	}
	
}