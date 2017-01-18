<?php
/**
 * Called from amfphp gateway from Flex
 */
require_once(dirname(__FILE__)."/BentoService.php");
require_once(dirname(__FILE__)."/../../classes/TestOps.php");
require_once(dirname(__FILE__)."/../../classes/UsageOps.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/tests/ScheduledTest.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/tests/TestSession.php");


class CTPService extends BentoService {

    // The version of the app that called you
    private $appVersion;

	function __construct() {
		// gh#341 A unique ID to distinguish sessions between multiple Clarity applications
		Session::setSessionName("CTPService");
		
		parent::__construct();
		
		// Set the title name for resources
		AbstractService::$title = "ctp";

        $this->testOps = new TestOps($this->db);
        $this->usageOps = new UsageOps($this->db);
	}

	public function getAppVersion() {
	    return $this->appVersion;
    }
    public function setAppVersion($appVersion) {
	    $this->appVersion = $appVersion;

    }
	// Login checks the user, account and returns valid tests
	public function testLogin($email, $password, $productCode) {
        $rootID = null;

        // Check the user, which includes licence slot checking (though there currently is none)
        // ctp#80
        $login = $this->login(
            array( "email" => $email, "password" => $password ),
            User::LOGIN_BY_EMAIL + User::LOGIN_HASHED,
            true,
            microtime(true) * 10000, // instanceId - is this used for anything?
            new Licence(), null, $productCode, null, null, null
        );
        // Make sure you only pass back public/reasonable information about the user
        $user = $login['group']->manageables[0]->publicView();
        $rootID = $login['account']->id;

        // Get the tests that the user's group can take part in
        // But remember that you DON'T pass the security access code back to the app
        $tests = $this->getTestsSecure($login['group'], $productCode);

        if ($tests) {
            // Create a T_TestSession record here. Fill in the TestId when I do first writeScore if not known now
            //$testId = (count($tests) == 1) ? $tests[0]->testId : null;
            // For now, the app will only work if max of one test is returned.
            // There is no test selection page so just drop everything except the first
            if (count($tests) > 1)
                $tests = array_slice($tests,0,1);
            $testId = $tests[0]->testId;
            $session = $this->startSession($user, $rootID, $productCode, $testId);
        } else {
            $session = new TestSession();
        }

        return array(
            "user" => $user,
            "session" => $session,
            "tests" => $tests,
            "sessionID" => (string) $session->sessionId
        );

    }

	// Get details of all tests scheduled for this group
    public function getTests($group, $productCode) {
        return $this->testOps->getActiveTests($group->id, $productCode);
    }

    // Get details of the tests that this user can take part in, but without security details
    public function getTestsSecure($group, $productCode) {
        $tests = $this->getTests($group, $productCode);

        if (!$tests)
            return array();

        // Get a list of all scheduled tests that this user has completed (likely to be very small list)
        $completedTests = $this->testOps->getCompletedTests($group->manageables[0]->id);
        foreach ($tests as $key => $test) {

            // Remove any scheduled tests this user has already completed
            // Let some emails repeat a test for testing purposes
            if ($completedTests && stripos($group->manageables[0]->email, '@dpt') === false) {
                foreach ($completedTests as $completedTest) {
                    if ($test->testId == $completedTest->testId) {
                        unset($tests[$key]);
                        continue 2;
                    }
                }
            }

            // Strip out any security information
            $test->startData = null;

            // Get names in sync
            $test->id = (string)$test->testId;
            switch ($productCode) {
                case 63:
                    $test->contentName = "ppt";
                    break;
                case 64:
                    $test->contentName = "lelt";
                    break;
            }
            $test->description = $test->caption;
            $test->startTimestamp = $this->ansiStringToTimestamp($test->openTime);
            $test->endTimestamp = $this->ansiStringToTimestamp($test->closeTime);
            $test->lang = strtolower($test->language);

            // ctp#311 If you are running locally, implying no encryption in content server, send back an empty code
            // Locally working will not work if you DO set an access code on a scheduled test
            if ($test->startType == 'timer' && stristr($_SERVER['SERVER_NAME'],'dock.projectbench') !== false)
                $test->groupId = '';

            // ctp#285 groupID needs to be a string
            // ctp#324 for app versions above x
            if (version_compare($this->getAppVersion(), '0.0.0', '>'))
                $test->groupId = (string)$test->groupId;
        }
        return array_values($tests);
    }

    // Create a session record that runs throughout the test
    public function startSession($user, $rootId, $productCode, $testId=null) {
        return $this->progressOps->startTestSession($user, $rootId, $productCode, $testId);
    }

    // Write the score from an exercise. This includes full details of each answer and anomalies
    public function scoreWrite($sessionId, $scoreObj, $localTimestamp, $clientTimezoneOffset = null) {

        $session = $this->testOps->getTestSession($sessionId);
        if (!$session)
            throw new Exception("No such saved session");

        // To avoid authentication, dummy use of session variables
        Session::set('userID', $session->userId);
        $user = $this->manageableOps->getUserById($session->userId);
        if (!$session)
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
        $score->duration = $scoreObj->exerciseScore->duration;

        $score->sessionID = $session->sessionId;
        $score->userID = $user->userID;
        $score->setUID($scoreObj->uid);
        // ctp#216 This was the time the app managed to send the score to the server
        $score->dateStamp = $this->timestampToLocalAnsiString($localTimestamp, $clientTimezoneOffset);

        // cpt#210
        $score->exerciseID = 0;

        // Write the summary score record
        try {
            // ctp#282 Force score to be written for any usertype
            $forceScoreWriting = true;
            $this->progressOps->insertScore($score, $user, $forceScoreWriting);

        } catch(Exception $e) {
            // gh#166 Catch duplicate record exceptions - and just ignore!!
            if ($e->getCode() != $this->copyOps->getCodeForId('errorDatabaseDuplicateRecord')) {
                $this->db->FailTrans();
                throw $e;
            }
        }

        // Write each score detail
        $scoreDetails = array();
        foreach ($scoreObj->exerciseScore->questionScores as $answer) {
            // Only write details that have been answered - if not attempted leave them out
            if ($answer->answerTimestamp === null)
                continue;

            // Convert timestamp to our usual date format
            $answer->answerTimestamp = (isset($answer->answerTimestamp)) ? $this->timestampToLocalAnsiString($answer->answerTimestamp, $clientTimezoneOffset) : null;
            $scoreDetails[] = new ScoreDetail($answer, $score);
        }
        if (count($scoreDetails) > 0) {
            try {
                // ctp#282 Force score to be written for any usertype
                $this->progressOps->insertScoreDetails($scoreDetails, $user, $forceScoreWriting);
            } catch (Exception $e) {
                // gh#166 Catch duplicate record exceptions - and just ignore!!
                if ($e->getCode() != $this->copyOps->getCodeForId('errorDatabaseDuplicateRecord')) {
                    $this->db->FailTrans();
                    throw $e;
                }
            }
        }

        // If this is the first score, make sure the session includes the testId and the start time
        $isDirty = false;
        if (!$session->testId) {
            $session->testId = $scoreObj->testID;
            $isDirty = true;
        }

        // ctp#261 The start datestamp is the local device time of first exercise submission
        if (!$session->startedDateStamp) {
            $session->startedDateStamp = $this->timestampToLocalAnsiString($scoreObj->exerciseScore->submitTimestamp, $clientTimezoneOffset);
            $isDirty = true;
        }

        if ($isDirty) {
            try {
                $this->progressOps->updateTestSession($session);
            } catch (Exception $e) {
                $this->db->FailTrans();
                throw $e;
            }
        }

        // Commit all the database inserts and updates
        $this->db->CompleteTrans();

        return array("success" => true);
    }

    public function getTestResult($sessionId, $mode = null) {
        $isDirty = false;

        // Get the session record
        $session = $this->testOps->getTestSession($sessionId);

        // gh#151 Has the result already been calculated for this session?
        if (!$session->result || $mode=='overwrite' || $mode=='debug') {
            $session->result = $this->progressOps->getTestResult($session, $mode);

            // ctp#261 Find the datestamp of the first real score in the test to update the session with
            $firstScoreDetail = $this->testOps->getFirstScore($sessionId);
            $session->startedDateStamp = $firstScoreDetail->dateStamp;
            $isDirty = true;
        }

        // gh#151 Have we closed the session?
        if (!$session->completedDateStamp) {
            // ctp#261 Get the last score written for this session
            $lastScoreDetail = $this->testOps->getLastScore($sessionId);
            $session->completedDateStamp = $lastScoreDetail->dateStamp;
            $isDirty = true;
        }

        // Update if something changed
        if ($isDirty)
            $this->progressOps->updateTestSession($session);

        // Debug mode (offline/batch rescoring) never hides result
        if ($mode=='debug')
            return $session->result;

        // ctp#173 Does the test administrator want the test takers to see a result?
        $testSchedule = $this->testOps->getTest($session->testId);
        if (!$testSchedule->showResult)
            $session->result = array("level" => null, "showResult" => false);

        // gh#1523 Are there enough licences left to send back the result?
        $licencesObj = $this->usageOps->getTestsUsed($session->productCode, $session->rootId);
        if (intval($licencesObj['purchased']) - intval($licencesObj['used']) <= 0)
            $session->result = array("level" => null, "purchased" => $licencesObj['purchased'], "used" => $licencesObj['used']);

        return $session->result;
    }

    // Pick up all the sessions for a particular test
    public function getSessionsForTest($testID) {
        return $this->testOps->getSessionsForTest($testID);
    }

    // ctp#60 Literals file for DPT
    public function getTranslations($lang) {
        $literals = $this->copyOps->getLiteralsFromFile($lang);
        return $literals;
    }
}