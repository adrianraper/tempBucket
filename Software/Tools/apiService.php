<?php
/**
 * Called from tools gateway
 */
require_once(dirname(__FILE__)."/../ResultsManager/web/amfphp/services/AbstractCouloirService.php");

require_once($GLOBALS['adodb_libs']."adodb-exceptions.inc.php");
require_once($GLOBALS['adodb_libs']."adodb.inc.php");

require_once(dirname(__FILE__) . "/../ResultsManager/web/amfphp/services/Firebase/JWT/JWT.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/amfphp/services/../core/shared/util/Authenticate.php");

require_once(dirname(__FILE__)."/../ResultsManager/web/amfphp/services/vo/com/clarityenglish/common/vo/Reportable.php");

require_once(dirname(__FILE__)."/../ResultsManager/web/amfphp/services/vo/com/clarityenglish/common/vo/manageable/Manageable.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/amfphp/services/vo/com/clarityenglish/common/vo/manageable/User.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/amfphp/services/vo/com/clarityenglish/common/vo/manageable/Group.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/amfphp/services/vo/com/clarityenglish/common/vo/session/SessionTrack.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/amfphp/services/vo/com/clarityenglish/dms/vo/account/Account.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/amfphp/services/vo/com/clarityenglish/dms/vo/account/Licence.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/amfphp/services/vo/com/clarityenglish/dms/vo/account/Token.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/amfphp/services/vo/com/clarityenglish/common/vo/content/Title.php");

require_once(dirname(__FILE__)."/../ResultsManager/web/amfphp/services/vo/com/clarityenglish/dms/vo/trigger/EmailAPI.php");

require_once(dirname(__FILE__)."/../ResultsManager/web/classes/CopyOps.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/classes/TemplateOps.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/classes/EmailOps.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/classes/ManageableOps.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/classes/SubscriptionCops.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/classes/AccountCops.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/classes/ContentOps.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/classes/MemoryCops.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/classes/LicenceCops.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/classes/LoginCops.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/classes/ProgressCops.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/classes/TestCops.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/classes/AuthenticationCops.php");

require_once($GLOBALS['common_dir'].'/encryptURL.php');

class apiService extends AbstractService {

	function __construct() {
		parent::__construct();

        AbstractService::$title = "rm";

        $this->manageableOps = new ManageableOps($this->db);
        $this->subscriptionCops = new SubscriptionCops($this->db);
        $this->accountCops = new AccountCops($this->db);
        $this->contentOps = new ContentOps($this->db);
        $this->loginCops = new LoginCops($this->db);
        $this->licenceCops = new LicenceCops($this->db);
        $this->progressCops = new ProgressCops($this->db);
        $this->testCops = new TestCops($this->db);
        $this->authenticationCops = new AuthenticationCops($this->db);
	}
    public function changeDB($dbHost) {
        $this->changeDbHost($dbHost);
        $this->manageableOps = new ManageableOps($this->db);
        $this->subscriptionCops = new SubscriptionCops($this->db);
        $this->accountCops = new AccountCops($this->db);
        $this->contentOps = new ContentOps($this->db);
        $this->loginCops = new LoginCops($this->db);
        $this->licenceCops = new LicenceCops($this->db);
        $this->progressCops = new ProgressCops($this->db);
        $this->testCops = new TestCops($this->db);
        $this->authenticationCops = new AuthenticationCops($this->db);
    }

    /*
     * This will try to find and verify this user. If successful it returns the user
     *  and limited group and account information.
     * It is NOT the same as login as that starts you in a particular title.
     *
     * For the user you get links to accessible programs and an authentication token
     * that can be passed back to the backend for progress or more detailed information.
     */
    public function signIn($email, $password) {
        $user = $this->getUser($email, $password);
        $account = $this->manageableOps->getAccountFromUser($user);
        $group = $this->manageableOps->getUsersGroups($user)[0];

        // Build links to programs this user CAN access
        $links = $this->getLinks($user, $account, $group);

        // Create an authentication token for this user
        $payload = array("userId" => $user->userID, "prefix" => $account->prefix, "rootId" => $account->id, "groupId" => $group->id);
        $token = $this->authenticationCops->createToken($payload);

        return array('user' => $user, 'links' => $links, 'account' => $account, 'group' => $group, 'authentication' => $token);

    }

    /*
     * This will look at all the titles in an account and build links to each that the user can access
    // Filter out any titles that this user can't access
    // 2. the licence is 'token' and this user has not already used the title
    // 3. the licence is full and this user has not already used the title
    // 4. the group is blocked from hidden content to the whole title
     */
    public function getLinks($user, $account, $group) {
        $dateStampNow = AbstractService::getNow();
        $dateNow = $dateStampNow->format('Y-m-d H:i:s');
        $links = array();

        $account = $this->accountCops->getBentoAccount($account->id);
        foreach ($account->titles as $title) {
            $status = 'available';
            $productDetails = $this->contentOps->getDetailsFromProductCode($title->productCode);

            // Just ignore Results Manager or any other admin tools
            if ($title->productCode == 2)
                continue;

            // 1. the title is expired - this is caught as an Exception in getBentoAccount above -
            // huh? you mean an expired title is not listed?
            if ($title->expiryDate < $dateNow)
                $status = 'expired';

            // For the next tests we need to know if this user already has a licence
            // What sort of architecture does this title use?
            // TODO Perhaps this should be a bigger call: getting number of licences, number used, number used by me
            // Which would be useful for other api calls too
            // [userHasLicence = boolean, licencesUsed = int, totalLicences = int, licenceType = int]
            $licenceDetails = $this->getLicenceUsage($title->productCode, $user->userID, $account->id, $productDetails['architectureVersion']);
            if (!$licenceDetails['userHasLicence']) {
                // 2. the licence is 'token' and this user does not already have a licence
                if ($title->licenceType == 'token')
                    // Just drop this title
                    continue;

                // 3. the licence is full and this user does not already have a licence
                switch ($title->licenceType) {
                    case Title::LICENCE_TYPE_SINGLE:
                    case Title::LICENCE_TYPE_I:
                    case Title::LICENCE_TYPE_LT:
                    case Title::LICENCE_TYPE_TT:
                        if ($licenceDetails['usedLicences'] >= $title->maxStudents)
                            $status = 'licenceFull';
                        break;
                }
            } else {
                $status = 'active';
            }

            // TODO should come from some config
            switch ($title->productCode) {
                case 63:
                    $productDetails['startingPoint'] = "https://dpt.clarityenglish.com";
                    $delimiter = "#";
                    break;
                case 68:
                    $productDetails['startingPoint'] = "https://tb.clarityenglish.com";
                    $delimiter = "#";
                    break;
                case 66:
                    $productDetails['startingPoint'] = "https://sss.clarityenglish.com";
                    $delimiter = "#";
                    break;
                case 72:
                case 73:
                    $productDetails['startingPoint'] = "https://rti.clarityenglish.com";
                    $delimiter = "#";
                    break;
                default:
                    $productDetails['startingPoint'] = "https://www.clarityenglish.com/Software/Tools/autoSignin.php";
                    $delimiter = "?";
                    break;
            }
            $token = $this->createApiToken($user->email, $account, $title->productCode);
            $params = ($token) ? $delimiter."apiToken=".$token : '';
            $links[] = array("productCode" => $title->productCode,
                "href" => $productDetails['startingPoint'].$params,
                "icon" => $productDetails['logoHref'],
                "status" => $status);
        }
        return $links;

    }
    /**
     * Get a valid user if you can
     * TODO Cope with any identifier - though you might not know the account
     *  IF you do not know the root you can get the loginOption, or just assume it is email
     */
    public function getUser($email, $password) {
        $stubUser = new User();
        $stubUser->email = $email;
        $user = $this->manageableOps->getUserByKey($stubUser, 0, User::LOGIN_BY_EMAIL);

        if ($user == false)
            // It is important to give no clue if the email or password was wrong. Just the combination.
            throw $this->copyOps->getExceptionForId("errorWrongPassword", array("loginKeyField" => 'email'));

        // TODO usertype, other blocks
        if (!$this->loginCops->verifyPassword($password, $user->password, $email)) {
            throw $this->copyOps->getExceptionForId("errorWrongPassword", array("loginOption" => User::LOGIN_BY_EMAIL, "loginKeyField" => 'email'));
        }

        // User validation
        $dateStampNow = AbstractService::getNow();
        $dateNow = $dateStampNow->format('Y-m-d H:i:s');
        if (!is_null($user->expiryDate) && $user->expiryDate < $dateNow)
            throw $this->copyOps->getExceptionForId("errorUserExpired", array("expiryDate" => $user->expiryDate));

        return $user;
    }
    /*
     * Login checks the user, account, hidden content, creates a session and secures a licence
     */
    public function login($login, $password, $productCode, $rootId = null, $apiToken = null) {
        // m#316 Catch no such user if apiToken in play
        try {
            return $this->loginCops->login($login, $password, $productCode, $rootId);
        } catch (Exception $e) {
            if ($e->getCode() == $this->copyOps->getCodeForId("errorNoSuchUser") && isset($apiToken)) {
                $payload = $getUserDetailsFromToken($apiToken);
                $user = $this->addApiUser($account, $login, $loginOption, $dbPassword, $productCode);
                if ($user)
                    return $this->loginCops->login($login, $password, $productCode, $rootId);
            } else {
                throw $e;
            }
        }
    }

    public function getLicenceUsageWrapper($token, $productCode) {
        $payload = $this->authenticationCops->getPayloadFromToken($token);
        return $this->getLicenceUsage($productCode, $payload->userId, $payload->rootId);
    }
    /*
     * Check to see if a user has a licence and could get one if they wanted to
     */
    public function getLicenceUsage($productCode, $userId, $rootId, $architectureVersion=null) {
        $version = ($architectureVersion) ? $architectureVersion : $this->contentOps->getDetailsFromProductCode($productCode)['architectureVersion'];
        $account = $this->accountCops->getBentoAccount($rootId);
        foreach ($account->titles as $title) {
            if ($title->productCode == $productCode) {
                $licence = new Licence();
                $licence->fromDatabaseObj($title);
                break;
            }
        }
        // Perhaps this account does not have this title...
        if (!isset($licence)) {
            $hasLicence = false;
            $usedLicences = 0;
        } else {
            if (version_compare($version, '4', '>=')) {
                // Check here to see if this user has a Couloir licence for this title
                $hasLicence = $this->licenceCops->getUserCouloirLicence($productCode, $userId);
                $usedLicences = $this->licenceCops->countUsedLicences($productCode, $rootId, $licence);

            } elseif (version_compare($version, '3', '>=')) {
                // Check here to see if this user has a Bento licence for this title
                // Bento can have 'old' or 'new' style licences
                $hasLicence = $this->licenceCops->getUserOldLicence($productCode, $userId, $account->useOldLicenceCount, $licence);
                $usedLicences = $this->licenceCops->countUsedOldLicences($productCode, $rootId, $account->useOldLicenceCount, $licence);

            } else {
                // Check here to see if this user has an Orchid licence for this title
                $hasLicence = $this->licenceCops->checkOrchidLicence($productCode, $userId, $licence);
                $usedLicences = $this->licenceCops->countOrchidLicences($productCode, $rootId, $licence);
            }
        }
        return array('userHasLicence' => $hasLicence,
                     'usedLicences' => $usedLicences,
                     'maxLicences' => $licence->maxStudents,
                     'licenceType' => $licence->licenceType);
    }

    /*
     * This returns the progress for a title.
     * This might be the current coverage % and average score.
     * It might include CEFR and Relative Numeric.
     * It might include links to a certficate.
     *
     */
    public function getResult($token, $productCode=null) {
        // Read the token to get the user
        $payload = $this->authenticationCops->getPayloadFromToken($token);
        if ($payload->userId) {
            switch ($productCode) {
                case 63:
                    // Is there a DPT result for this student?
                    $tests = $this->testCops->getCompletedTests($payload->userId);
                    if ($tests)
                        $result = $tests[0]->data['result'];
                    $result['date'] = $tests[0]->lastUpdateDateStamp;
                    return $result;
                    break;
                default:
            }
        }
    }

    // Checking if an email has already been used
    public function getEmailStatus($email) {
        return $this->manageableOps->getEmailStatus($email);
    }

    // Checking if a purchased token has already been used
    public function getTokenStatus($serial) {
        //$rc = $this->getAppVersion();
        return $this->subscriptionCops->getTokenStatus($serial);
    }
    public function getToken($serial) {
        return $this->subscriptionCops->getToken($serial);
    }
    /*
     * Generate tokens to be given to users for later activation
     *
     */
    public function generateTokens($quantity, $productCode, $rootId, $groupId, $duration, $productVersion, $expiryDate){
        $quantity = isset($quantity) ? $quantity : 1;
        $duration = isset($duration) ? $duration : 365;
        $productVersion = isset($productVersion) ? $productVersion : 'FV';
        if (!isset($expiryDate)) {
            $dateStampNow = AbstractService::getNow();
            $expiryDate = $dateStampNow->add(new DateInterval('P1Y'))->format('Y-m-d H:i:s');
        }
        return $this->subscriptionCops->generateTokens($quantity, $productCode, $rootId, $groupId, $duration, $productVersion, $expiryDate);
    }

    /*
     * Activate a token by creating or finding the user
     * then registering the token to them and allocating a licence.
     * Finish by calling signin for the [new] user.
     */
    public function activateToken($serial, $email, $name, $password) {

        // Decode the token
        $rc = $this->subscriptionCops->getTokenStatus($serial);
        switch ($rc['status']) {
            case 'used':
                throw new Exception("Token already used by another person", 108);
                break;
            case 'expired':
                throw new Exception("Token has expired", 108);
                break;
            case 'ok':
                $token = $this->subscriptionCops->getToken($serial);
                break;
            case 'invalid':
            default:
                throw new Exception("Invalid token", 108);
        }

        // If the email is not unique, assume that they are trying to add the token to that existing user's account
        $existingUsers = $this->manageableOps->getUsersByEmail($email);
        if (count($existingUsers) > 1) {
            throw new Exception("Email has aleady been used");
        } elseif (count($existingUsers) == 1) {
            // Have we got the right password for this user?
            $user = $existingUsers[0];
            $rc = $this->loginCops->verifyPassword($password, $user->password);
            if ($rc)
                $this->copyOps->getExceptionForId('errorWrongPassword');
            // TODO Is this user in the expected group/root?
        } else {
            // Add a new user first to the group/root specified in the token
            $user = $this->addUser($email, $name, $password, $token->rootId, $token->groupId);
        }

        // Finger the token
        $rc = $this->subscriptionCops->updateToken($token, $email, $user->userID);

        // Allocate the licence
        // TODO This does not check if this user ALREADY has a licence for this title
        // If they do, then activating token should add [duration] to the existing licence end date
        $session = new SessionTrack();
        $session->sessionId = 0;
        $session->userId = $user->userID;
        $session->rootId = $token->rootId;
        $session->productCode = $token->productCode;
        // TODO for non-Couloir titles too please
        $rc = $this->licenceCops->acquireCouloirLicenceSlot($session);

    }

    // Create a user from a token - this would be the call from Couloir self registration screen
    public function addUserFromToken($token, $loginObj) {
        $payload = $this->authenticationCops->getPayloadFromToken($token);
        //$productCode = isset($payload->productCode) ? $payload->productCode : null;
        $rootId = isset($payload->rootId) ? $payload->rootId : null;
        $groupId = isset($payload->groupId) ? $payload->groupId : null;
        if (!$rootId) {
            throw $this->copyOps->getExceptionForId("errorNoAccountFound");
        }

        $user = $this->loginCops->addUser($rootId, $groupId, $loginObj);

    }
    // Create a user from plain information - this would be the call from activateToken
    public function addUser($email, $name, $password, $rootId, $groupId) {
        // TODO This assumes loginOption is email and you also pass name
        $loginObj = Array();
        $loginObj["login"] = $email;
        $loginObj["name"] = $name;
        $loginObj["password"] = $password;
        return $this->loginCops->addUser($rootId, $groupId, $loginObj);
    }

    // Utility functions
    public function cleanInputs($input, $inputType='generic') {

        // General emptiness and type checks
        switch ($inputType) {
            case 'email':
            case 'token':
                if (is_null($input) || $input=='' || !is_string($input))
                    throw new Exception("Invalid input");
                break;
            case 'name':
                // name is allowed to be empty
                if (is_null($input) || !is_string($input))
                    throw new Exception("Invalid name");
                break;
            case 'date':
                if (is_null($input) || $input=='' || !strtotime($input))
                    throw new Exception("Invalid date");
                break;
            default:
                if (is_null($input) || $input=='')
                    throw new Exception("Invalid input");
        }
        // Specific pattern based ones
        if ($inputType == 'token') {
            // Check that only valid characters are in the pattern before we do much
            // Simply drop any groups that do not match
            // 7853-5602-0801-9
            $pattern = '/(?:[\d]{4}[- _.]{1})(?:[\d]{4}[- _.]{1})(?:[\d]{4}[- _.]{1})(?:[\d]{1})/i';
            $rc = preg_match_all($pattern, $input, $matches, PREG_PATTERN_ORDER);
            if ($rc === false || $rc == 0) {
                throw new Exception("Invalid token");
            } else {
                $input = implode('', $matches[0]);
            }
            // Now check that the token is built from valid parts
        }
        return $input;
    }

    private function createApiToken($email, $account, $productCode) {
        $prefix = $account->prefix;
        try {
            $key = $this->authenticationCops->getAccountApiKey($prefix);
        } catch (Exception $e) {
            if ($e->getCode() != $this->copyOps->getCodeForId("errorAccountNoApiToken"))
                throw $e;
            return false;
        }
        $payload = array("email" => $email, "prefix" => $prefix, "productCode" => $productCode);
        return $this->authenticationCops->createToken($payload, $key);
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