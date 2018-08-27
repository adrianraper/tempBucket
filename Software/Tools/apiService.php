<?php
/**
 * Called from tools gateway
 */
require_once(dirname(__FILE__)."/../ResultsManager/web/amfphp/services/AbstractCouloirService.php");
// This can move to standard AuthenticationCops once production is up to date
require_once(dirname(__FILE__)."/classes/AuthenticationCops.php");
require_once(dirname(__FILE__)."/classes/ToolsOps.php");

require_once($GLOBALS['adodb_libs']."adodb-exceptions.inc.php");
require_once($GLOBALS['adodb_libs']."adodb.inc.php");

require_once(dirname(__FILE__) . "/../ResultsManager/web/amfphp/services/Firebase/JWT/JWT.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/amfphp/services/../core/shared/util/Authenticate.php");

require_once(dirname(__FILE__)."/../ResultsManager/web/amfphp/services/vo/com/clarityenglish/common/vo/Reportable.php");

require_once(dirname(__FILE__)."/../ResultsManager/web/amfphp/services/vo/com/clarityenglish/common/vo/manageable/Manageable.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/amfphp/services/vo/com/clarityenglish/common/vo/manageable/User.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/amfphp/services/vo/com/clarityenglish/common/vo/manageable/Group.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/amfphp/services/vo/com/clarityenglish/dms/vo/account/Account.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/amfphp/services/vo/com/clarityenglish/common/vo/content/Title.php");

require_once(dirname(__FILE__)."/../ResultsManager/web/amfphp/services/vo/com/clarityenglish/dms/vo/trigger/EmailAPI.php");

require_once(dirname(__FILE__)."/../ResultsManager/web/classes/TemplateOps.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/classes/EmailOps.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/classes/ManageableOps.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/classes/SubscriptionOps.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/classes/AccountOps.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/classes/ContentOps.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/classes/MemoryOps.php");

require_once($GLOBALS['common_dir'].'/encryptURL.php');

class apiService extends AbstractService {

    // The version of the app that called you
    private $appVersion;

	function __construct() {
		parent::__construct();

        AbstractService::$title = "rm";

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
    public function readJWT($token) {
        $payload = $this->authenticationCops->getApiPayload($token);
        $key = (isset($payload->prefix)) ? $this->authenticationCops->getAccountApiKey($payload->prefix) : '0';
        $this->authenticationCops->validateApiToken($token, $key);

        return array("payload" => $this->authenticationCops->getPayloadFromToken($token, $key));
    }
    public function dbCheck() {
        return ['database' => $GLOBALS['db']];
    }
}