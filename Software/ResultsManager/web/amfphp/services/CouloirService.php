<?php
/**
 * Called from amfphp gateway from Flex
 */
require_once(dirname(__FILE__)."/AbstractCouloirService.php");
require_once(dirname(__FILE__)."/../../classes/CopyOps.php");
require_once(dirname(__FILE__)."/../../classes/TestCops.php");
require_once(dirname(__FILE__)."/../../classes/UsageCops.php");
require_once(dirname(__FILE__)."/../../classes/ManageableOps.php");
require_once(dirname(__FILE__)."/../../classes/EmailOps.php");
require_once(dirname(__FILE__)."/../../classes/ProgressCops.php");
require_once(dirname(__FILE__)."/../../classes/LoginCops.php");
require_once(dirname(__FILE__)."/../../classes/LicenceCops.php");
require_once(dirname(__FILE__)."/../../classes/AccountCops.php");
require_once(dirname(__FILE__)."/../../classes/MemoryCops.php");
require_once(dirname(__FILE__)."/../../classes/ContentOps.php");
require_once(dirname(__FILE__)."/../../classes/AuthenticationCops.php");

require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/Reportable.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/content/Content.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/content/Title.php");
require_once(dirname(__FILE__) . "/vo/com/clarityenglish/common/vo/content/Summary.php");

require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/account/Account.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/account/Licence.php");

require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/Manageable.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/User.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/Group.php");

require_once(dirname(__FILE__)."/vo/com/clarityenglish/bento/vo/progress/Score.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/bento/vo/progress/ScoreDetail.php");

require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/session/SessionTrack.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/tests/ScheduledTest.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/tests/DPTConstants.php");

require_once($GLOBALS['adodb_libs']."adodb-exceptions.inc.php");
require_once($GLOBALS['adodb_libs']."adodb.inc.php");
require_once(dirname(__FILE__) . "/Firebase/JWT/JWT.php");
require_once(dirname(__FILE__)."/../core/shared/util/Authenticate.php");


class CouloirService extends AbstractService {

    // The version of the app that called you
    private $appVersion;

	function __construct() {
		parent::__construct();
		
		// Set the title name for resources
        // TODO This should be obsolete - see m#232
        AbstractService::$title = "ctp";

        $this->testCops = new TestCops($this->db);
        $this->progressCops = new ProgressCops($this->db);
        $this->usageCops = new UsageCops($this->db);
        $this->manageableOps = new ManageableOps($this->db);
        $this->loginCops = new LoginCops($this->db);
        $this->licenceCops = new LicenceCops($this->db);
        $this->accountCops = new AccountCops($this->db);
        $this->contentOps = new ContentOps($this->db);
        $this->authenticationCops = new AuthenticationCops($this->db);
        $this->memoryCops = new MemoryCops($this->db);
        // m#11
        $this->emailOps = new EmailOps($this->db);
	}

    public function changeDB($dbHost) {
        $this->changeDbHost($dbHost);

        $this->testCops = new TestCops($this->db);
        $this->progressCops = new ProgressCops($this->db);
        $this->usageCops = new UsageCops($this->db);
        $this->manageableOps = new ManageableOps($this->db);
        $this->loginCops = new LoginCops($this->db);
        $this->licenceCops = new LicenceCops($this->db);
        $this->accountCops = new AccountCops($this->db);
        $this->contentOps = new ContentOps($this->db);
        $this->authenticationCops = new AuthenticationCops($this->db);
        $this->memoryCops = new MemoryCops($this->db);
        $this->emailOps = new EmailOps($this->db);
    }

    /*
     * Find an account that matches a prefix, IP or RU range.
     * sss#285 The ip is picked up by the server, not sent from client
     * sss#374 referrer has to come from app
     */
    public function getLoginConfig($productCode, $prefix, $referrer, $apiToken=null) {

        // Pick up the ip and ru, if any, of the client
        $ip = $this->accountCops->getIP();
        $ru = (is_null($referrer)) ? $this->accountCops->getRU() : $referrer;

        // Find the account, if one matches
        // m#271 Catch an exception when the prefix=account doesn't match ip or ru
        //  so that you can just let them sign-in with an existing account
        try {
            $account = $this->accountCops->getAccount($productCode, $prefix, $ip, $ru);
        } catch (Exception $e) {
            if ($e->getCode() == $this->copyOps->getCodeForId("errorIPDoesntMatch") ||
                $e->getCode() == $this->copyOps->getCodeForId("errorRUDoesntMatch")) {
                $account = false;
            } else {
                throw $e;
            }
        }

        // gh#315 If no account and you didn't throw an exception, just means we can't find it from partial parameters
        // gh#1561 For consistency we should still alert this with an exception
        // sss#152 Return default parameters so that the app can go to personal sign-in
        // sss#304
        if (!$account) {
            //throw $this->copyOps->getExceptionForId("errorNoAccountFound");
            $returnAccount = null;
            $loginOption = "email";
            $verified = true;
            $selfRegister = 0;
            $licenceType = "lt";

        } else {
            // gh#315 Can only cope with one title, and tablet login by IP might find an account with 2
            if (count($account->titles) > 1) {
                $account->titles = array(reset($account->titles));
            }

            // sss#224
            if ($account->titles[0]->loginModifier == Title::SIGNIN_BLOCKED
                && $account->titles[0]->licenceType == Title::LICENCE_TYPE_AA) {
                $loginOption = "none";
            } else {
                switch ($account->loginOption) {
                    case 2:
                        $loginOption = "id";
                        break;
                    case 1:
                        $loginOption = "name";
                        break;
                    case 128:
                    default:
                        $loginOption = "email";
                        break;
                }
            }
            // m#278 Don't force everything to be LT or AA - unless the app cares less about tt etc
            switch ($account->titles[0]->licenceType) {
                case Title::LICENCE_TYPE_SINGLE:
                case Title::LICENCE_TYPE_I:
                case Title::LICENCE_TYPE_LT:
                case Title::LICENCE_TYPE_TT:
                case Title::LICENCE_TYPE_TOKEN:
                    $licenceType = "lt";
                    break;
                case Title::LICENCE_TYPE_AA:
                case Title::LICENCE_TYPE_CT:
                case Title::LICENCE_TYPE_NETWORK:
                default:
                    $licenceType = "aa";
                    // sss#132 Most aa licences let you self-register
                    if ($account->titles[0]->loginModifier != Title::SIGNIN_BLOCKED) {
                        $account->selfRegister = 21; // Default bits for name, email and password
                    }
                    break;
            }
            // sss#177 For self register, send a token if it is allowed. The app can pass this to an all purpose webpage.
            if ($account->selfRegister > 0) {
                // Set an expiry time for the token 1 hour from now
                // TODO It would be neater to create a token that doesn't expire but can only be used one
                // Add a record to a table with an id and a date used (null initially).
                // When you come back to addUser for that id you fill in the date and then ban it to be used again.
                $utcDateTime = new DateTime();
                $utcTimestamp = intval($utcDateTime->format('U'));
                $aLittleLater = $utcTimestamp + (60 * 60);
                // Pass the productCode and rootId in the token just so they can be returned
                // sss#132 Send the required fields for the form to use
                $selfRegToken = $this->authenticationCops->createToken(["exp" => $aLittleLater, "fields" => $account->selfRegister, "productCode" => $productCode, "rootId" => $account->id]);
            }

            // sss#304 Format return object
            $selfRegister = $account->selfRegister;
            $verified = $account->verified;

            // m#558 Customised menu names
            $menuName = $this->accountCops->getMenuName($productCode, $account->titles[0]->productVersion);
            
            if (isset($account->id)) {
                $returnAccount = array("lang" => $account->titles[0]->languageCode,
                                "contentName" => $account->titles[0]->contentLocation,
                                "rootId" => intval($account->id),
                                "institutionName" => $account->name,
                                "menuFilename" => $menuName,
                                "version" => $account->titles[0]->productVersion);

                // m#316 Return expected payload of the apiToken in object
                if ($apiToken) {
                    // m#316 Never ask for password if using apiToken
                    $verified = false;
                    $payload = $this->authenticationCops->getApiPayload($apiToken);
                    $apiLogin = array();
                    if (isset($payload->login)) $apiLogin["login"] = $payload->login;
                    if (isset($payload->startNode)) $apiLogin["startNode"] = $payload->startNode;
                    if (isset($payload->enabledNode)) $apiLogin["enabledNode"] = $payload->enabledNode;
                }
            }
        }

        // sss#288 sss#304
        $config = array("loginOption" => $loginOption,
                        "verified" => ($verified) ? true : false,
                        "allowSelfRegistration" => ($selfRegister > 0) ? true : false,
                        "selfRegistrationToken" => ($selfRegister > 0) ? $selfRegToken : null,
                        "licenseType" => $licenceType,
                        "account" => $returnAccount);

        // m#316 Add authenticated apiLogin if created
        if (isset($apiLogin)) $config['apiLogin'] = $apiLogin;

        return $config;
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
                $user = $this->addApiUser($rootId, $login, $password, $apiToken);
                return $this->loginCops->login($login, $password, $productCode, $rootId, $apiToken, $platform);
            } else {
                throw $e;
            }
        }
    }

    // m#316 Add a user whose details came from a validated api token
    private function addApiUser($rootId, $login, $password, $token) {
        $payload = $this->authenticationCops->getApiPayload($token);
        $groupId = isset($payload->groupId) ? $payload->groupId : null;

        $loginObj = Array();
        $loginObj["login"] = $login;
        $loginObj["password"] = $password;
        return $this->loginCops->addUser($rootId, $groupId, $loginObj, $token);
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

        return $this->loginCops->addUser($rootId, $groupId, $loginObj);
    }

    public function updateActivity($token, $timestamp) {
        // Pick the session id from the token
        $session = $this->authenticationCops->getSession($token);

        // Convert to seconds from the timestamp sent by app
        $timestamp = intval($timestamp / 1000);
        $this->progressCops->updateCouloirSession($session, $timestamp);

        return [];
    }
    // This reports whether each session in the array can get a licence slot
    public function checkLicenceSlots($tokens) {
        $func = function($token) {
            // Simply, can this session get a licence or not?
            // sss#361 Any exception means you don't have a licence slot anymore
            try {
                // Pick the session id from the token
                $session = $this->authenticationCops->getSession($token);

                // gh#161 Delete all expired licences here to tidy up before grabbing each one
                // TODO This clears for product code and root id. It might be worth making sure
                // that you only do it once for each combination to save unnecessary calls.
                // Indeed it would seem more sensible to deleteExpiredLicenceSlots once only for all roots and productCodes
                // m#493
                //$this->licenceCops->deleteExpiredLicenceSlots($session);

                // sss#192 Check the instance id - does it still match the sign in one?
                if ($session->userId > 0) {
                    $instanceId = $this->loginCops->getInstanceId($session->userId, $session->productCode);
                    if ($session->sessionId != $instanceId) {
                        return ["hasLicenseSlot" => false];
                    }
                }

                // Note American spelling for app API
                return $this->licenceCops->checkCouloirLicenceSlot($session);

            } catch (Exception $e) {
                return ["hasLicenseSlot" => false];
            }
        };
        return array_map($func, $tokens);
    }

	// m#202
    public function releaseLicenceSlots($slots) {
        $func = function($slot) {

            if (isset($slot->token)) {
                $token = $slot->token;
            } else {
                return false;
            }
            // Timestamp from licence server is milliseconds
            if (isset($slot->timestamp)) {
                $timestamp = $slot->timestamp / 1000;
            } else {
                // php default timestamp is seconds
                $timestamp = time();
            }

            // Pick the session id from the token
            $session = $this->authenticationCops->getSession($token);
            try {
                $this->progressCops->updateCouloirSession($session, $timestamp);
                $this->licenceCops->releaseCouloirLicenceSlot($session, $timestamp);
                //$sid = $this->authenticationCops->getSessionId($token);
                //AbstractService::$debugLog->info("released licence for session " . $sid);
            } catch (Exception $e) {
            }
        };
        array_map($func, $slots);
        return [];
    }
    // Deprecated by the above
    public function releaseLicenceSlot($token, $timestamp) {
        // Pick the session id from the token
        $session = $this->authenticationCops->getSession($token);
        try {
            $timestamp = $timestamp / 1000;
            $this->progressCops->updateCouloirSession($session, $timestamp);
            $this->licenceCops->releaseCouloirLicenceSlot($session, $timestamp);
        } catch (Exception $e) {
        }
        return [];
    }

	// sss#228 Write to the user's memory
    public function memoryWrite($token, $key, $value) {
        // Pick the session from the token
        $session = $this->authenticationCops->getSession($token);

        $this->memoryCops->set($key, $value, $session->userId, $session->productCode);
        return array();
    }

    // m#454 write the test date into User until it is implemented in memory
    public function writeTestDate($token, $timestamp) {
        // Pick the session from the token
        $session = $this->authenticationCops->getSession($token);

        if (is_null($timestamp))
            return array();

        $user = $this->manageableOps->getUserByIdNotAuthenticated($session->userId);
        $user->birthday = AbstractService::timestampToAnsiString($timestamp);
        $rc = $this->manageableOps->updateMinorUserDetail($user);
        return array();
    }

    // Clear the memory for this user of this title
    public function memoryClear($token) {
        // Pick the session from the token
        $session = $this->authenticationCops->getSession($token);

        $this->memoryCops->forget($session->userId, $session->productCode);
        return array();
    }

	// Get details of all tests scheduled for this group
    public function getTests($group, $productCode) {
        return $this->testCops->getActiveTests($group->id, $productCode);
    }

    // Get details of the tests that this user can take part in, but without security details
    public function getTestsSecure($group, $productCode) {
	    return $this->testCops->getTestsSecure($group, $productCode);
    }

    // Create a session record that runs until the user signs-out (or is kicked out)
    public function startCouloirSession($user, $rootId, $productCode, $uid=null) {
        return $this->progressCops->startCouloirSession($user, $rootId, $productCode, $uid);
    }
    /*
    function getCouloirSession($sessionId) {
        $sql = <<<EOD
			SELECT * 
			FROM T_SessionTrack
			WHERE F_SessionID=?
EOD;
        $bindingParams = array($sessionId);
        $rs = $this->db->Execute($sql, $bindingParams);
        if ($rs && $rs->RecordCount() > 0) {
            $session = new SessionTrack($rs->FetchNextObj());
            return $session;
        } else {
            return false;
        }
    }
    */

    // Write the score from an exercise. This includes full details of each answer and anomalies
    public function scoreWrite($token, $scoreObj, $localTimestamp, $clientTimezoneOffset = null) {

        // Pick the session from the token
        $session = $this->authenticationCops->getSession($token);

        // Since you have validated the token, you can get the user directly
        $user = $this->manageableOps->getUserByIdNotAuthenticated($session->userId);
        if (!$user)
            throw new Exception("No such saved user");

        // ctp#337 Begin a transaction
        $this->db->StartTrans();

        // Manipulate the score object from Couloir into Bento format
        $score = new Score();
        $score->scoreCorrect = $scoreObj->exerciseScore->exerciseMark->correctCount;
        $score->scoreWrong = $scoreObj->exerciseScore->exerciseMark->incorrectCount;
        $score->scoreMissed = $scoreObj->exerciseScore->exerciseMark->missedCount;
        $totalQuestions = $score->scoreCorrect + $score->scoreWrong + $score->scoreMissed;
        if ($totalQuestions > 0) {
            $score->score = 100 * $score->scoreCorrect / ($totalQuestions);
        } else {
            $score->score = -1;
        }
        // sss#134 app sends milliseconds - database wants seconds
        // m#347 round this up in case of fractions
        $score->duration = ceil($scoreObj->exerciseScore->duration / 1000);

        $score->sessionID = $session->sessionId;
        $score->userID = $user->userID;

        // m#364 Change format of item id sent by app
        if (isset($scoreObj->uid) && version_compare($this->getAppVersion(), '2.0.0', '<')) {
            $score->setUID($scoreObj->uid);
        } else {
            $score->productCode = $session->productCode;
            $score->courseID = (isset($scoreObj->courseId)) ? $scoreObj->courseId : null;
            $score->unitID = (isset($scoreObj->unitId)) ? $scoreObj->unitId : null;
            $score->exerciseID = (isset($scoreObj->exerciseId)) ? $scoreObj->exerciseId : null;
        }
        // m#579 If an exercise is outside a course, we must fake it for the score table
        // So make the id digits after course zero
        if (is_null($score->courseID)) {
            $score->courseID = substr($score->exerciseID,0, -6).'000000';
        }
        if (is_null($score->unitID)) {
            $score->unitID = substr($score->exerciseID,0, -4).'0000';
        }

        // ctp#216 This was the time the app managed to send the score to the server
        // ctp#380 Save as UTC
        // ctp#383 Use the submit timestamp rather than sent timestamp
        $score->dateStamp = AbstractService::timestampToAnsiString($scoreObj->exerciseScore->submitTimestamp);

        // ctp#210
        // ctp#383 We might need to compare this exercise id against some constants later
        $tempExerciseID = $score->exerciseID;
        //$score->exerciseID = floatval($score->exerciseID);

        // Write the summary score record
        try {
            // ctp#282 Force score to be written for any usertype
            $this->progressCops->insertScore($score);

        } catch(Exception $e) {
            // gh#166 Catch duplicate record exceptions - and just ignore!!
            $this->db->FailTrans();
            $this->db->CompleteTrans();
            if ($e->getCode() != $this->copyOps->getCodeForId('errorDatabaseDuplicateRecord')) {
                throw $e;
            } else {
                // gh#460 If you find that this is a duplicate, just quit whole process, but with no error
                return [];
            }
        }

        // sss#17 Special section for writing score detail for tests
        if ($session->productCode == 63 || $session->productCode == 65) {
            // Write each score detail
            $scoreDetails = array();
            foreach ($scoreObj->exerciseScore->questionScores as $answer) {
                // Only write details that have been answered - if not attempted leave them out
                // dpt#469 Included presented but not attempted
                //if ($answer->answerTimestamp === null)
                //    continue;

                // Convert timestamp to our usual date format
                // ctp#380 Save UTC time
                $answer->answerTimestamp = (isset($answer->answerTimestamp)) ? AbstractService::timestampToAnsiString($answer->answerTimestamp) : null;
                $scoreDetails[] = new ScoreDetail($answer, $score);
            }
            if (count($scoreDetails) > 0) {
                try {
                    // ctp#282 Force score to be written for any usertype
                    $this->progressCops->insertScoreDetails($scoreDetails);
                } catch (Exception $e) {
                    // gh#166 Catch duplicate record exceptions - and just ignore!!
                    $this->db->FailTrans();
                    $this->db->CompleteTrans();
                    if ($e->getCode() != $this->copyOps->getCodeForId('errorDatabaseDuplicateRecord')) {
                        throw $e;
                    } else {
                        return [];
                    }
                }
            }

            // If this is the first score, make sure the session includes the testId and the start time
            // sss#17 testId is NOT sent in score
            $isDirty = false;
            //if (!$session->contentId) {
            //    $session->contentId = $scoreObj->testID;
            //    $isDirty = true;
            //}

            // ctp#261 The start datestamp is the local device time of first exercise submission
            // ctp#380 Save UTC time
            // ctp#383 Only update session datestamps if this is the first exercise after the test has started.
            // Currently this means the instructions exercise
            // sss#12 Now use duration to hold the test time, so reset it to 0 when you get the score write for the instructions exercise
            if ($tempExerciseID == DPTConstants::instructionsID) {
                //$session->startedDateStamp = $this->timestampToLocalAnsiString($scoreObj->exerciseScore->submitTimestamp, $clientTimezoneOffset);
                //$session->startedDateStamp = $this->timestampToAnsiString($scoreObj->exerciseScore->submitTimestamp);
                $session->duration = 0;
                $isDirty = true;
            }

            // TODO Why is this only for DPT and DE?
            if ($isDirty) {
                try {
                    $this->progressCops->updateCouloirSession($session);
                } catch (Exception $e) {
                    $this->db->FailTrans();
                    throw $e;
                }
            }
        }

        // Commit all the database inserts and updates
        $this->db->CompleteTrans();

        return [];
    }

    // sss#12 Only relevant for DPT, DE
    public function getResult($token, $mode = null) {
        $isDirty = false;

        // Get the session record
        $session = $this->authenticationCops->getSession($token);

        // For manual figuring out of a result, with more detail
        if ($mode=='debug')
            return $this->progressCops->getTestResult($session, $mode);

        // gh#151 Has the result already been calculated for this session?
        if (!$session->getResult() || $mode=='overwrite') {
            $session->setResult($this->progressCops->getTestResult($session, $mode));

            // ctp#261 Find the datestamp of the first real score in the test to update the session with
            // ctp#391 No need to change session record for start datestamp
            //$firstScore = $this->testOps->getFirstScore($sessionId);
            //$session->startedDateStamp = $firstScore->dateStamp;
            $isDirty = true;
        }

        // gh#151 Have we closed the session?
        // sss#17
        if ($session->status == SessionTrack::STATUS_OPEN || $mode=='overwrite') {
            // ctp#261 Get the time the last score was written for this session
            $lastScore = $this->testCops->getLastScore($session->sessionId);
            $session->lastUpdateDateStamp = $lastScore->dateStamp;
            $session->duration = strtotime($session->lastUpdateDateStamp) - strtotime($session->startDateStamp);
            $session->status = SessionTrack::STATUS_CLOSED;
            $isDirty = true;
        }

        // Update if something changed
        if ($isDirty)
            $this->progressCops->updateCouloirSession($session);

        // With manual rescoring we always want to show the result
        if ($mode=='overwrite')
            return $session->result;

        // ctp#173 Does the test administrator want the test takers to see a result?
        $testSchedule = $this->testCops->getTest($session->contentId);
        if (!$testSchedule->showResult)
            $session->result = array("level" => null, "showResult" => false);

        // gh#1523 Are there enough licences left to send back the result?
        $licencesObj = $this->usageCops->getTestsUsed($session->productCode, $session->rootId);
        if (intval($licencesObj['purchased']) - intval($licencesObj['used']) <= 0)
            $session->result = array("level" => null, "purchased" => $licencesObj['purchased'], "used" => $licencesObj['used']);

        // ctp#400 Do you want to send back a caption and link for the last screen?
        if (isset($testSchedule->followUp)) {
            $followUp = json_decode($testSchedule->followUp);
            foreach ($followUp as $k => $v)
                $session->result[$k] = $v;
        }

        return $session->result;
    }

    // Pick up all the sessions for a particular test or test taker
    public function getSessionsForTest($sessionId, $email, $testId) {
	    if ($testId)
            return $this->testCops->getSessionsForTest($testId);
        if ($email)
            return $this->testCops->getSessionsFromEmail($email);
        if ($sessionId) {
            $sessions = array();
            $session = $this->testCops->getTestSession($sessionId);
            if ($session)
                $sessions[] = $session;
            return $sessions;
        }
        return array();
    }

    // m#11 Generate a certificate (html and pdf)
    public function getCertificate($token, $courseInfo) {
        // Pick the session from the token
        $session = $this->authenticationCops->getSession($token);

        // Nothing needed for anonymous user
        if ($session->userId < 0)
            return array();

        // Nothing we can do if no courseId given
        if (!$courseInfo || !isset($courseInfo->id) || (isset($courseInfo->exercisesTotal) && $courseInfo->exercisesTotal<=0))
            throw $this->copyOps->getExceptionForId("errorUnknown");

        // Retrieve the score records for this user and this product
        $courseScore = $this->progressCops->getCourseProgress($session, $courseInfo->id);
        $courseScore->courseName = $courseInfo->name;
        $courseScore->exercisesTotal = $courseInfo->exercises;
        // Make sure that non-marked exercises don't turn this into null rather than 0
        $courseScore->averageScore = ($courseScore->averageScore) ? $courseScore->averageScore : 0;

        // m#322 Has the required coverage been hit? Set at 100% for everything for now
        // but could be based on different titles
        switch ($session->productCode) {
            default:
                if ($courseScore->exercisesDone < $courseScore->exercisesTotal)
                    throw $this->copyOps->getExceptionForId("certificateBlocked", array("caption" => $courseScore->courseName, "exercisesDone" => $courseScore->exercisesDone, "exercisesTotal" => $courseScore->exercisesTotal, "averageScore" => $courseScore->averageScore));
        }

        // m#322 Or do you want different certificates?
        $coverage = round(100 * $courseScore->exercisesDone / $courseScore->exercisesTotal);
        //if ($coverage < 60) {
        //    $certificateTemplate = $this->copyOps->getCopyForId("NoCertificateTemplate");
        //} elseif ($coverage < 90) {
        //    $certificateTemplate = $this->copyOps->getCopyForId("AlmostCertificateTemplate");
        //} else {
            $certificateTemplate = $this->copyOps->getCopyForId("CertificateTemplate");
        //}

        // Horrible hack for the moment
        $user = $this->manageableOps->getUserByIdNotAuthenticated($session->userId);

        // Get the metrics into a summary object
        $certificate = new Summary();
        $certificate->detail = $courseScore;
        $certificate->user = $user;
        $certificate->template = 'certificates/'.$certificateTemplate;
        $certificate->caption = $this->copyOps->getCopyForId("CertificateOfAchievement");

        // And put that into a token
        $certToken = $this->authenticationCops->createToken(["data" => $certificate]);

        // TODO where to hold these variables?
        // Use the domain this script is running in, but whitelist it
        $allowed_hosts = array('clarityenglish.com','dock.projectbench','claritydev');
        $phpHost = $_SERVER['HTTP_HOST'];
        $check = array_filter($allowed_hosts, function($value) use($phpHost) { return (stristr($phpHost, $value)!==FALSE); });
        if (!isset($_SERVER['HTTP_HOST']) || !$check) {
            throw $this->copyOps->getExceptionForId("errorBlockedDomain", array("domain" => $_SERVER['HTTP_HOST']));
        }
        // Create a url that is a dynamically created html certificate
        $scheme = ((!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') || $_SERVER['SERVER_PORT'] == 443) ? 'https://' : 'http://';
        $host = $phpHost;
        $path = '/Software/ResultsManager/web/amfphp/services/';
        $script = 'GenerateCertificate.php';
        $htmlCert = $scheme.$host.$path.$script.'?token='.$certToken;

        // #329 Create a url that is a dynamically created pdf from an html
        $scheme = 'https://';
        $host = 'pdf.clarityenglish.com';
        $path = '';
        $script = '';
        $pdfCert =  $scheme.$host.$path.$script.'?url='.$htmlCert;

        return array("pdfHtml" => $htmlCert, "pdfUrl" => $pdfCert);
    }

    // sss#17 Which exercises has the user completed?
    public function getCoverage($token) {
        // Pick the session from the token
        $session = $this->authenticationCops->getSession($token);

        // sss#244 Nothing needed for anonymous user
        if ($session->userId < 0)
            return array();

        // Retrieve the score records for this user and this product
        $exercises = $this->progressCops->getExercisesCompleted($session);

        // Format: list the exercises that have been completed, removes duplicates too
        $exercisesDone = array();
        // sss#341
        foreach ($exercises as $exercise) {
            if ($exercise['F_ExerciseID'] == 0)
                continue;
            $exercisesDone[$exercise['F_ExerciseID']] = true;
        }

        return $exercisesDone;
    }

    // sss#17 Which exercises has the user completed?, full details
    public function getScoreDetails($token) {
        // Pick the session  from the token
        $session = $this->authenticationCops->getSession($token);

        // m#328 Nothing needed for anonymous user
        if ($session->userId < 0)
            return array();

        // Retrieve the score records for this user and this product
        $exercises = $this->progressCops->getExercisesCompleted($session);

        // Format: detail each exercise that has been completed
        // sss#214 a score of -1 means it was not marked. The app wants this as null
        $exercisesDone = array();
        foreach ($exercises as $exercise) {
            // sss#341
            if ($exercise['F_ExerciseID'] == 0)
                continue;
            // sss#280 Formatting for client api
            $scorePercent = (intval($exercise['F_Score']) >= 0) ? intval($exercise['F_Score']) : null;
            $dateDone = new DateTime($exercise['F_DateStamp']);
            $dateDone = $dateDone->format('c');
            $exercisesDone[] = ['exerciseId' => $exercise['F_ExerciseID'],
                'scorePercent' => $scorePercent,
                'date' => $dateDone,
                'duration' => intval($exercise['F_Duration'])
            ];
        }
        return $exercisesDone;
    }
    // sss#17 For each unit that the user had worked on, summarise the progress
    // This is for the analysis report, time you have spent on each unit
    public function getAnalysis($token) {
        // Pick the session id from the token
        $session = $this->authenticationCops->getSession($token);

        // m#328 Nothing needed for anonymous user
        if ($session->userId < 0)
            return array();

        // Retrieve the score records for this user and this product
        // $session->productCode
        $nodes = $this->progressCops->getNodeProgress($session);

        // Format: detail each exercise that has been completed
        // m#317 Send back nodeId, not a specific unitId - currently can hardcode 'unit:'
        // What level of hierarchy are we grouping at for this title?
        $nodesDone = array();
        foreach ($nodes as $node)
            $nodesDone[$node['nodeId']] = intval($node['duration']);

        return $nodesDone;
    }
    // sss#17 For each unit that the user had worked on, summarise the progress
    // This is for the compare report, your average score in each unit against everyone else
    public function getUnitComparison($token, $mode) {
        // Pick the session from the token
        $session = $this->authenticationCops->getSession($token);

        // m#328 Nothing needed for anonymous user
        if ($session->userId < 0)
            return array();

        // Retrieve the score records for this user and this product
        $nodes = $this->progressCops->getNodeProgress($session);

        // Retrieve the summaries for everyone
        $everyone = $this->progressCops->getEveryoneNodeSummary($session->productCode);

        // Put the user and the everyone results in a similar format for merging
        // m#446 m#317 Send back nodeId
        $userNodes = array();
        foreach ($nodes as $node)
            $userNodes[$node['nodeId']] = ['averageScore' => $node['averageScore']];
        $everyoneUnits = array();
        foreach ($everyone as $unit)
            $everyoneUnits[$unit['nodeId']] = ['averageScore' => $unit['AverageScore']];

        // Format and merge: unit summaries. Drive by everyone as that contains ALL units
        $nodesDone = array();
        foreach ($everyoneUnits as $key => $value) {
            $userAverage = (isset($userNodes[$key])) ? $userNodes[$key]['averageScore'] : 0;
            $nodesDone[$key] = ['youPercent' => round(floatval($userAverage)),
                'worldPercent' => round(floatval($value['averageScore']))];
        }
        return $nodesDone;
    }

    // ctp#60 Literals file for DPT
    public function getTranslations($lang, $productCode) {
        $literals = $this->copyOps->getLiteralsFromFile($lang, $productCode);
        return $literals;
    }

    // Return a code for this user - typically this is the [first] group Id they are in
    public function getDefaultCode($userId) {
        $groupId = $this->manageableOps->getGroupIdForUserId($userId);

        return $groupId;
    }

    // ctp#428 Write a log message for a permanent record of login
    public function writeLog($msg) {
    }

    public function dbCheck() {
        $dbVersion = $this->authenticationCops->getDbVersion();
        $ddDetails = new DBDetails($GLOBALS['dbHost']);
        return ['database' => $ddDetails->getDetails(), 'version' => $dbVersion];
    }
}
