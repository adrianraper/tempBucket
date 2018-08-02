<?php
/**
 * Called from tools gateway
 */
require_once(dirname(__FILE__)."/../ResultsManager/web/amfphp/services/AbstractCouloirService.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/classes/CopyOps.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/classes/AuthenticationCops.php");

require_once(dirname(__FILE__)."/classes/ToolsOps.php");

require_once($GLOBALS['adodb_libs']."adodb-exceptions.inc.php");
require_once($GLOBALS['adodb_libs']."adodb.inc.php");
require_once(dirname(__FILE__) . "/../ResultsManager/web/amfphp/services/Firebase/JWT/JWT.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/amfphp/services/../core/shared/util/Authenticate.php");

class ToolsService extends AbstractService {

    // The version of the app that called you
    private $appVersion;

	function __construct() {
		parent::__construct();
		
        AbstractService::$title = "tools";

        $this->toolsOps = new ToolsOps($this->db);
        $this->authenticationCops = new AuthenticationCops($this->db);
	}
    public function changeDB($dbHost) {
        $this->changeDbHost($dbHost);
        $this->toolsOps = new ToolsOps($this->db);
        $this->authenticationCops = new AuthenticationCops($this->db);
    }

    public function getAppVersion() {
        return $this->appVersion;
    }
    public function setAppVersion($appVersion) {
        $this->appVersion = $appVersion;
    }

    public function createJWT($payload, $key) {
	    return array("token" => $this->authenticationCops->createToken($payload, $key));
    }
    public function dbCheck() {
        return ['database' => $GLOBALS['db']];
    }
}