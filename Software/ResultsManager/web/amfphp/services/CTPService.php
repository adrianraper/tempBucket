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
	
	function __construct() {
		// gh#341 A unique ID to distinguish sessions between multiple Clarity applications
		Session::setSessionName("CTPService");
		
		parent::__construct();
		
		// Set the title name for resources
		AbstractService::$title = "ctp";

        $this->testOps = new TestOps($this->db);
        $this->usageOps = new UsageOps($this->db);
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
            $sessionId = $this->startSession($user, $rootID, $productCode, $testId);
        } else {
            $sessionId = "xxxx";
        }
        // Just until menu.json.hbs works...
        //$tests[0]->menuFilename = 'menu.json';

        return array(
            "user" => $user,
            "sessionID" => (string)$sessionId,
            "tests" => $tests
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
        }
        return array_values($tests);
    }

    // Create a session record that runs throughout the test
    public function startSession($user, $rootId, $productCode, $testId=null)     {
        return $this->progressOps->startTestSession($user, $rootId, $productCode, $testId);
    }

    // Write the score from an exercise. This includes full details of each answer and anomalies
    public function scoreWrite($sessionId, $scoreObj, $localTimestamp, $clientTimezoneOffset) {
	    $error = false;

        $session = $this->testOps->getTestSession($sessionId);
        if (!$session)
            throw new Exception("No such saved session");

        // To avoid authentication, dummy use of session variables
        Session::set('userID', $session->userId);
        $user = $this->manageableOps->getUserById($session->userId);
        if (!$session)
            throw new Exception("No such saved user");

        // Manipulate the score object from Couloir into Bento format
        $score = new Score(null, $clientTimezoneOffset);
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
        $score->dateStamp = $this->timestampToAnsiString($localTimestamp);

        // cpt#210
        $score->exerciseID = 0;

        // Write the summary score record
        // gh#166 Catch duplicate record exceptions - and just ignore!!
        try {
            $this->progressOps->insertScore($score, $user);
        } catch(Exception $e) {
            if ($e->getCode() == $this->copyOps->getCodeForId('errorDatabaseDuplicateRecord')) {
                $error["code"] = $e->getCode();
                $error["message"] = $e->getMessage();
            } else {
                throw $e;
            }
        }

        // Write each score detail
        $scoreDetails = array();

        foreach ($scoreObj->exerciseScore->questionScores as $answer) {
            $answer->answerTimestamp = (isset($answer->answerTimestamp)) ? $this->timestampToAnsiString($answer->answerTimestamp) : null;
            $scoreDetails[] = new ScoreDetail($answer, $score, $clientTimezoneOffset);
        }
        if (count($scoreDetails) > 0)
            $this->progressOps->insertScoreDetails($scoreDetails, $user);

        // If this is the first score, make sure the session includes the testId and the start time
        $isDirty = false;
        if (!$session->testId) {
            $session->testId = $scoreObj->testID;
            $isDirty = true;
        }

        if (!$session->startedDateStamp) {
            $dateStampNow = new DateTime('now', new DateTimeZone(TIMEZONE));
            $dateNow = $dateStampNow->format('Y-m-d H:i:s');
            $session->startedDateStamp = $dateNow;
            $isDirty = true;
        }
        if ($isDirty)
            $this->progressOps->updateTestSession($session);

        return array("success" => ($error===false), "error" => $error);
    }

    public function getTestResult($sessionId) {
        $isDirty = false;

        // Get the session record
        $session = $this->testOps->getTestSession($sessionId);

        // gh#151 Has the result already been calculated for this session?
        if (!$session->result) {
            $session->result = $this->progressOps->getTestResult($session);
            $isDirty = true;
        }
        // gh#151 Have we closed the session?
        if (!$session->completedDateStamp)
            $isDirty = true;

        // Update if something changed
        if ($isDirty)
            $this->progressOps->updateTestSession($session, true);

        // gh#1523 Are there enough licences left to send back the result?
        // ctp#173
        $licencesObj = $this->usageOps->getTestsUsed($session->productCode, $session->rootId);
        if ($licencesObj['purchased'] - $licencesObj['scheduled'] >= 0)
            $session->result = array("level" => null);

        return $session->result;
    }
}