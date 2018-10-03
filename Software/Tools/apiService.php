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
require_once(dirname(__FILE__)."/../ResultsManager/web/amfphp/services/vo/com/clarityenglish/common/vo/tests/ScheduledTest.php");

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
require_once(dirname(__FILE__)."/../ResultsManager/web/classes/EmailOps.php");
require_once(dirname(__FILE__)."/../ResultsManager/web/classes/ApiCops.php");

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
        $this->emailOps = new EmailOps($this->db);
        $this->apiCops = new ApiCops($this->db);
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
        $this->apiCops = new ApiCops($this->db);
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
        $rootId = $this->manageableOps->getAccountIdFromUser($user);
        $account = $this->accountCops->getBentoAccount($rootId);
        $group = $this->manageableOps->getUsersGroups($user)[0];

        // Build links to programs this user CAN access
        $links = $this->getLinks($user, $account, $group);

        // Create an authentication token for this user
        $payload = array("userId" => $user->userID, "prefix" => $account->prefix, "rootId" => $account->id, "groupId" => $group->id);
        $token = $this->authenticationCops->createToken($payload);

        // What do you really want to return? Public views for objects
        // But do we want titles in an account or group at all?
        return array('user' => $user->publicView(), 'links' => $links, 'account' => $account->publicView(), 'group' => $group->publicView(), 'authentication' => $token);
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

        foreach ($account->titles as $title) {
            AbstractService::$debugLog->info("check title ".$title->productCode);
            $status = 'available';

            // Just ignore Results Manager or any other admin tools
            if ($title->productCode == 2)
                continue;

            // 1. the title is expired - this is caught as an Exception in getBentoAccount above -
            // huh? you mean an expired title is not listed?
            if ($title->expiryDate < $dateNow) {
                $status = 'expired';
            } else {
                // For the next tests we need to know if this user already has a licence or can get one
                // [userHasLicence = boolean, licencesUsed = int, totalLicences = int, licenceType = int]
                //AbstractService::$debugLog->info("check licence for ".$title->productCode);
                $licenceDetails = $this->getLicenceUsage($title, $user, $account);
                //AbstractService::$debugLog->info("got licence ".$licenceDetails['maxLicences']);
                if (!$licenceDetails['userHasLicence']) {
                    // 2. the licence is 'token' and this user does not already have a licence
                    if ($title->licenceType == Title::LICENCE_TYPE_TOKEN) {
                        $status = 'tokenRequired';

                    } else {
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
                    }
                } else {
                    $status = 'active';
                }
            }

            // TODO should come from some config
            $productDetails = array();
            switch ($title->productCode) {
                case 63:
                    // Additionally see if there is a scheduled test to be taken
                    $tests = $this->testCops->getTestsSecure($group, $title->productCode);
                    if (count($tests) > 0) {
                        $status = 'scheduledTest';
                    } else {
                        // If there is no test, then drop the link
                        continue 2;
                    }
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
            $token = $this->createApiToken($user->email, $account->prefix, $title->productCode);
            $params = ($token) ? $delimiter."apiToken=".$token : '';
            $links[] = array("productCode" => $title->productCode,
                "href" => $productDetails['startingPoint'].$params,
                "icon" => $title->logoHref,
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
    /**
     * Only to be called once you have authenticated the caller
     *  This will get user details and an authentication token so you can make further calls as if you were that user
     */
    public function getAuthenticatedUser($email) {
        $stubUser = new User();
        $stubUser->email = $email;
        $user = $this->manageableOps->getUserByKey($stubUser, 0, User::LOGIN_BY_EMAIL);

        if ($user == false)
            throw $this->copyOps->getExceptionForId("errorNoSuchUser", array("loginKeyField" => 'email'));

        // Create an authentication token for this user
        $rootId = $this->manageableOps->getAccountIdFromUser($user);
        $account = $this->accountCops->getBentoAccount($rootId);
        $group = $this->manageableOps->getUsersGroups($user)[0];
        $payload = array("userId" => $user->userID, "prefix" => $account->prefix, "rootId" => $account->id, "groupId" => $group->id);
        $token = $this->authenticationCops->createToken($payload);

        return array('user' => $user->publicView(), 'authentication' => $token);
    }
    public function authenticateClarity($password) {
        if ($password != 'Sunshine1787')
            throw new Exception('You are not authorised to call this api');
        $payload = array('prefix' => 'Clarity');
        return array('authentication' => $this->createJWT($payload, 'averysecretkey'));
    }

    /*
     * Login checks the user, account, hidden content, creates a session and secures a licence
     */
    public function login($login, $password, $productCode, $rootId = null, $apiToken = null, $platform = null) {
        // m#316 Catch no such user if apiToken in play
        try {
            return $this->loginCops->login($login, $password, $productCode, $rootId, $apiToken, $platform);
        } catch (Exception $e) {
            if ($e->getCode() == $this->copyOps->getCodeForId("errorNoSuchUser") && isset($apiToken)) {
                $payload = $getUserDetailsFromToken($apiToken);
                $user = $this->addApiUser($account, $login, $loginOption, $dbPassword, $productCode);
                if ($user)
                    return $this->loginCops->login($login, $password, $productCode, $rootId, $apiToken, $platform);
            } else {
                throw $e;
            }
        }
    }

    public function getLicenceUseFromToken($token, $productCode) {
        $payload = $this->authenticationCops->getPayloadFromToken($token);

        // You might send different information in the token
        // Sending a root means you just want licence count for the whole account
        // Sending a user means you want licence count for the whole account AND to know if this user has a licence
        $rootId = (isset($payload->rootId) && $payload->rootId > 0) ? $payload->rootId : null;

        if (!$rootId) {
            // Since you have validated the token, you can get the user directly
            $user = $this->manageableOps->getUserByIdNotAuthenticated($payload->userId);
            $rootId = $this->manageableOps->getAccountIdFromUser($user);
        } else {
            $user = null;
        }
        $account = $this->accountCops->getBentoAccount($rootId, $productCode);
        $title = $account->titles[0];

        return $this->getLicenceUsage($title, $user, $account);
    }
    /*
     * Check to see if a user has a licence or could get one if they wanted to
     */
    public function getLicenceUsage($title, $user, $account) {

        // Perhaps this account does not have this title...
        if (!isset($title)) {
            $hasLicence = false;
            $usedLicences = 0;
        } else {
            if (version_compare($title->architectureVersion, '4', '>=')) {
                // Check here to see if this user has a Couloir licence for this title
                $hasLicence = (is_null($user)) ? null : $this->licenceCops->getUserCouloirLicence($title->productCode, $user->userID);
                $usedLicences = $this->licenceCops->countUsedLicences($title->productCode, $account->id, $title);
                /*
                 * These calls are just too slow and of dubious interest
                } elseif (version_compare($title->architectureVersion, '3', '>=')) {
                    // Check here to see if this user has a Bento licence for this title
                    // Bento can have 'old' or 'new' style licences
                    $hasLicence = (is_null($user)) ? null : $this->licenceCops->getUserOldLicence($title->productCode, $user->userID, $account->useOldLicenceCount, $title);
                    $usedLicences = $this->licenceCops->countUsedOldLicences($title->productCode, $account->id, $account->useOldLicenceCount, $title);

                } else {
                    // Check here to see if this user has an Orchid licence for this title
                    $hasLicence = (is_null($user)) ? null : $this->licenceCops->checkOrchidLicence($title->productCode, $user->userID, $title);
                    $usedLicences = $this->licenceCops->countOrchidLicences($title->productCode, $account->id, $title);
                }
                */
            } else {
                $hasLicence = null;
                $usedLicences = null;
            }
        }
        return array('userHasLicence' => $hasLicence,
                     'usedLicences' => $usedLicences,
                     'maxLicences' => intval($title->maxStudents),
                     'licenceType' => intval($title->licenceType));
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
                    // Is there a DPT result(s) for this student?
                    // Whilst production is running on old DPT session handling
                    if ((strpos($_SERVER['SERVER_NAME'], 'www-staging.clarityenglish.com') !== false) ||
                        (strpos($_SERVER['SERVER_NAME'], 'www.clarityenglish.com') !== false)) {
                        $tests = $this->testCops->oldGetCompletedTests($payload->userId);
                    } else {
                        $tests = $this->testCops->getCompletedTests($payload->userId);
                    }
                    if ($tests && count($tests) > 0) {
                        $results = array();
                        foreach ($tests as $test) {
                            if (isset($test->data['result']))
                                $results[] = array('date' => $test->lastUpdateDateStamp, 'result' => $test->data['result']);
                        }
                    }
                    if (count($results) > 0)
                        return $results;

                    // OK, is there a failed attempt?
                    // Whilst production is running on old DPT session handling
                    if ((strpos($_SERVER['SERVER_NAME'], 'www-staging.clarityenglish.com') !== false) ||
                        (strpos($_SERVER['SERVER_NAME'], 'www.clarityenglish.com') !== false)) {
                        $tests = $this->testCops->oldGetFailedTests($payload->userId);
                    } else {
                        $tests = $this->testCops->getFailedTests($payload->userId);
                    }
                    if ($tests && count($tests) > 0) {
                        $results = array();
                        foreach ($tests as $test) {
                            $results[] = array('date' => $test->startDateStamp, 'status' => 'failed to complete');
                        }
                    }
                    return $results;
                    break;
                default:
            }
        }
    }
    /*
     * This returns any tests that a user is scheduled to take.
     */
    public function getScheduledTests($token, $productCode=null) {
        // Read the token to get the user and their group
        $payload = $this->authenticationCops->getPayloadFromToken($token);
        if (isset($payload->userId) && isset($payload->groupId)) {
            switch ($productCode) {
                case 63:
                default:
                    // Are there any scheduled tests for this user?
                    $group = $this->manageableOps->getGroup($payload->groupId);
                    // Since you have validated the token, you can get the user directly
                    $user = $this->manageableOps->getUserByIdNotAuthenticated($payload->userId);
                    $group->addManageables($user);
                    return $this->testCops->getTestsSecure($group, $productCode);
                    break;
            }
        }
    }

    // Checking if an email has already been used
    public function getEmailStatus($email) {
        return $this->manageableOps->getEmailStatus($email);
    }

    // Check if this looks like an email we can send to
    // And, perhaps, if it belongs to a user from a particular domain
    // This is a deep function checking the account and user, expected to be called rarely from something like forgot password api
    public function checkEmailValidity($email, $domainSigninUrl) {
        // use an RFC email pattern form regexr community for pattern matching
        // Note that in Staging this is not case insensitive, but locally it is
        $pattern = '~[a-z0-9!#$%&\'*+/=?^_`{|}\~-]+(?:\.[a-z0-9!#$%&\'*+/=?^_`{|}\~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?~i';
        if (!preg_match($pattern, $email))
            throw new Exception("We can't send to this email address.", 101);
        // get the user
        $users = $this->manageableOps->getUsersByEmail($email);
        if (count($users)!=1)
            throw new Exception("This email is linked to multiple accounts. Contact support@clarityenglish.com", 101);
        // match the account to the domain if you have one
        if (!is_null($domainSigninUrl)) {
            $user = $users[0];
            // get their account
            $account = $this->manageableOps->getAccountRootFromUser($user);

            // The domain and the account type must match, otherwise it is an error
            // So if you came from IP.com, your account must be from IP.com
            if ($this->accountCops->isAccountIP($account) && stristr($domainSigninUrl, "ieltspractice.com")) {
                return true;
            } elseif ($this->accountCops->isAccountIP($account) || stristr($domainSigninUrl, "ieltspractice.com")) {
                throw new Exception("This email is linked to ieltspractice.com", 101);
            } elseif ($this->accountCops->isAccountLM($account) && stristr($domainSigninUrl, "roadtoielts.com")) {
                return true;
            } elseif ($this->accountCops->isAccountLM($account) || stristr($domainSigninUrl, "roadtoielts.com")) {
                throw new Exception("This email is linked to roadtoielts.com", 101);
            }
        }
        return true;
    }

    // Checking if a purchased token has already been used
    public function getTokenStatus($serial) {
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
            throw new Exception("Email has already been used");
        } elseif (count($existingUsers) == 1) {
            // Have we got the right password for this user?
            $user = $existingUsers[0];
            $rc = $this->loginCops->verifyPassword($password, $user->password, $user->email);
            if (!$rc)
                throw $this->copyOps->getExceptionForId('errorWrongPassword', array('loginKeyField' => 'email'));
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
        // Use a fake session object to pass data to acquireLicenceSlot
        $session = new SessionTrack();
        $session->sessionId = 0;
        $session->userId = $user->userID;
        $session->rootId = $token->rootId;
        $session->productCode = $token->productCode;
        $licence = $this->accountCops->getLicenceDetails($token->rootId, $token->productCode);

        // TODO for non-Couloir titles too please
        $rc = $this->licenceCops->allocateTokenLicenceSlot($session, $licence, $token);

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

    // To count licences using old and new methods
    // Assume that if you are a Couloir productCode, and are most interested in counting
    // the old Bento version
    public function countLicences($rootId, $newProductCode) {
        $sessionCount = $bentoCount = $couloirCount = 0;
        $oldProductCode = $this->licenceCops->getOldProductCode($newProductCode);
        if ($oldProductCode)
            $oldLicence = $this->accountCops->getLicenceDetails($rootId, $oldProductCode);
        $newLicence = $this->accountCops->getLicenceDetails($rootId, $newProductCode);

        // Assuming you found an old licence
        if (isset($oldLicence) && $oldLicence) {
            if (($oldLicence->licenceType == Title::LICENCE_TYPE_TT) || ($oldLicence->licenceType == Title::LICENCE_TYPE_LT)) {
                $sessionCount = $this->licenceCops->countOrchidLicences($oldProductCode, $rootId, $oldLicence);
                $bentoCount = $this->licenceCops->countBentoLicences($oldProductCode, $rootId, $oldLicence);
            }
        }
        // Assuming you found a new licence
        if ($newLicence) {
            if (($newLicence->licenceType == Title::LICENCE_TYPE_TT) || ($newLicence->licenceType == Title::LICENCE_TYPE_LT)) {
                $couloirCount = $this->licenceCops->countUsedLicences($newProductCode, $rootId, $newLicence);
            }
        }
        return array("oldProductCode" => $oldProductCode, "newProductCode" => $newProductCode, "sessionCount" => $sessionCount, "bentoCount" => $bentoCount, "couloirCount" => $couloirCount, "licenceControlDate" => $oldLicence->licenceControlStartDate);
    }
    // To convert licences from Bento to Couloir so that a product update is smooth
    public function convertLicences($rootId, $newProductCode) {
        $oldProductCode = $this->licenceCops->getOldProductCode($newProductCode);
        if (!$oldProductCode)
            $oldProductCode = $newProductCode;

        // The old and new licence must both exist and be LT
        $oldLicence = $this->accountCops->getLicenceDetails($rootId, $oldProductCode);
        $newLicence = $this->accountCops->getLicenceDetails($rootId, $newProductCode);
        if ((($oldLicence->licenceType == Title::LICENCE_TYPE_TT) || ($oldLicence->licenceType == Title::LICENCE_TYPE_LT)) &&
            (($newLicence->licenceType == Title::LICENCE_TYPE_TT) || ($newLicence->licenceType == Title::LICENCE_TYPE_LT))) {
            $newLicence->findLicenceClearanceDate();
            return $this->licenceCops->convertSessionsIntoCouloirLicences($rootId, $oldProductCode, $newProductCode, $newLicence);
        }
        throw new Exception('Licence is AA so nothing to convert');
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

    private function createApiToken($email, $prefix, $productCode) {
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
    // This is for an apiToken that must include prefix and be signed by that account's private key
    public function readJWT($token) {
        $payload = $this->authenticationCops->getApiPayload($token);
        $key = (isset($payload->prefix)) ? $this->authenticationCops->getAccountApiKey($payload->prefix) : '0';
        $this->authenticationCops->validateApiToken($token, $key);

        return array("payload" => $this->authenticationCops->getPayloadFromToken($token, $key));
    }
    // This is to get payload from a general Clarity signed token
    public function getTokenPayload($token) {
        return array("payload" => $this->authenticationCops->getPayloadFromToken($token));
    }
    // Start the forgot password process. Send an email with a validated link.
    // Requires the email to match the domain for IP.com and LastMinute
    public function forgotPassword($email, $domainSigninUrl=null) {
        if (is_null($domainSigninUrl))
            $domainSigninUrl = 'https://www.clarityenglish.com/online';
        $rc = $this->getEmailStatus($email);
        if ($rc['status']!='used')
            return $rc;
        $rc = $this->checkEmailValidity($email, $domainSigninUrl);
        $dateStampNow = AbstractService::getNow();
        $shortly = $dateStampNow->add(new DateInterval('P1D'))->format('U');
        $payload = array("email" => $email, "signinUrl" => $domainSigninUrl, "exp" => intval($shortly));
        $jwt = $this->authenticationCops->createToken($payload);

        // Generate the email
        $emailData = array("link" => '/Software/Tools/resetPassword.php?token='.$jwt);
        $emailArray = array(array("to" => $email, "data" => $emailData));
        if (stristr($domainSigninUrl, "ieltspractice.com")) {
            $templateID = 'forgotPasswordIP';
        } elseif (stristr($domainSigninUrl, "roadtoielts.com")) {
            $templateID = 'forgotPasswordLM';
        } else {
            $templateID = 'forgotPasswordCE';
        }
        $errors = $this->emailOps->sendEmails("", $templateID, $emailArray);
        if ($errors == array()) {
            $rc = array('status' => 'sent');
        } else {
            throw new Exception("Trouble sending email");
        }
        return $rc;
    }
    public function changePassword($email, $password, $token) {
        // Check that the token is valid and get it's contents
        $payload = $this->authenticationCops->getPayloadFromToken($token);
        if ($email != $payload->email)
            throw new Exception("Invalid token");

        $existingUsers = $this->manageableOps->getUsersByEmail($email);
        if (count($existingUsers) > 1) {
            throw new Exception("Email is not unique.");
        } elseif (count($existingUsers) == 1) {
            // Have we got the right password for this user?
            $user = $existingUsers[0];
            $rc = $this->manageableOps->changePassword($user, $password);
        } else {
            throw new Exception("Email not registered.");
        }

        return array('name' => $user->name);
    }
    public function runTestingDataInitialisation($token) {
        $payload = $this->authenticationCops->getPayloadFromToken($token);
        $dbDetails = new DBDetails($GLOBALS['dbHost']);
        $rc = $this->apiCops->runTestingDataInitialisation();
        return ['database' => $dbDetails->getDetails(), 'rowsAffected' => $rc];
    }
    public function dbCheck() {
        $dbVersion = $this->authenticationCops->getDbVersion();
        $dbDetails = new DBDetails($GLOBALS['dbHost']);
        return ['database' => $dbDetails->getDetails(), 'version' => $dbVersion];
    }
}