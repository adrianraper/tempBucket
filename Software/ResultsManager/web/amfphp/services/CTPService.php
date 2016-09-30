<?php
/**
 * Called from amfphp gateway from Flex
 */
require_once(dirname(__FILE__)."/BentoService.php");
require_once(dirname(__FILE__)."/../../classes/TestOps.php");
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
	}

	// Login checks the user, account and returns valid tests
	public function testLogin($email, $password, $productCode) {
        $rootID = null;

        // Check the user, which includes licence slot checking (though there currently is none)
        // ctp#80
        $login = $this->login(
            [ "email" => $email, "password" => $password ],
            User::LOGIN_BY_EMAIL + User::LOGIN_HASHED,
            true,
            microtime(true) * 10000, // instanceId - is this used for anything?
            new Licence(), null, $productCode, null, null, null
        );
        // Make sure you only pass back public/reasonable information about the user
        $user = $login['group']->manageables[0]->publicView();
        $rootID = $login['account']->id;

        // Get the tests that the user's group can take part in
        // There are some fake tests used for checking content
        /*
        if ($rootID==163 && preg_match('/(track\w+)(@ppt)/i', $user->email, $matches)) {
            $fakeTest = new ScheduledTest();
            $fakeTest->id = '1';
            $fakeTest->testId = '1';
            $fakeTest->startTimestamp = '2016-01-01';
            $fakeTest->endTimestamp = null;
            $fakeTest->contentName = $matches[1];
            $fakeTest->description = 'Testing track '.$matches[1];
            $tests[] = $fakeTest;
        } else {
        */
            // But remember that you DON'T pass the security access code back to the app
            $tests = $this->getTestsSecure($login['group'], $productCode);
        //}

        if ($tests) {
            // Create a T_TestSession record here. Fill in the TestId when I do first writeScore if not known now
            $testId = (count($tests) == 1) ? $tests[0]->testId : null;
            $sessionId = $this->startSession($user, $rootID, $productCode, $testId);
        } else {
            $sessionId = "xxxx";
        }

        return [
            "user" => $user,
            "sessionID" => (string)$sessionId,
            "tests" => $tests
        ];

    }

	// Get details of the tests scheduled for this group
    public function getTests($group, $productCode) {
        return $this->testOps->getTests($group->id, $productCode);
    }

    // Get details of the tests that this user can take part in, but without security details
    public function getTestsSecure($group, $productCode) {
        $tests = $this->testOps->getTests($group->id, $productCode);

        if (!$tests)
            return array();

        // Get a list of all scheduled tests that this user has completed (likely to be very small list)
        $completedTests = $this->testOps->getCompletedTests($group->manageables[0]->id);
        foreach ($tests as $key => $test) {

            // Remove any scheduled tests this user has already completed
            if ($completedTests)
                foreach ($completedTests as $completedTest)
                    if ($test->testId == $completedTest->testId) {
                        unset($tests[$key]);
                        break 2;
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
        return $tests;
    }

    // Create a session record that runs throughout the test
    public function startSession($user, $rootId, $productCode, $testId=null)     {
        return $this->progressOps->startTestSession($user, $rootId, $productCode, $testId);
    }

    public function scoreWrite($sessionId, $scoreObj, $localTimestamp, $clientTimezoneOffset) {
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

        // Write the summary score record
        $this->progressOps->insertScore($score, $user);

        // Write each score detail
        /*
        $scoreDetails = array();

        foreach ($scoreObj->exerciseScore->questionScores as $answer) {
            $scoreDetails[] = new ScoreDetail($answer, $clientTimezoneOffset);
        }
        $this->progressOps->insertScoreDetails($scoreDetails, $user);
        */

        // If this is the first score, make sure the session includes the testId
        if (!$session->testId) {
            $session->testId = $scoreObj->testID;
            $this->progressOps->updateTestSession($session);
        }

    }

    public function getTestResult($sessionId) {
        $session = $this->testOps->getTestSession($sessionId);

        //Session::set('userID', $session->userId);
        //$user = $this->manageableOps->getUserById($session->userId);

        return $this->progressOps->getTestResult($session);
    }

}