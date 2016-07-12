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
        $this->progressOps = new ProgressOps($this->db);
	}

	// Login checks the user, account and returns valid tests
	public function testLogin($email, $password, $productCode) {
        $rootID = null;

        // Check the user, which includes licence slot checking (though there currently is none)
        $login = $this->login(
            [ "email" => $email, "password" => $password ],
            User::LOGIN_BY_EMAIL,
            true,
            microtime(true) * 10000, // instanceId - is this used for anything?
            new Licence(), null, $productCode, null, null, null
        );
        $user = $login['group']->manageables[0]->publicView();
        $rootID = $login['account']->id;

        // Get the tests that the user's group can take part in
        // But remember that you DON'T pass the security access code back to the app
        $tests = $this->getTestsSecure($login['group'], $productCode);

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
            // TODO This is, of course, the wrong way round at the moment!
            switch ($productCode) {
                case 63:
                    $test->contentName = "ila";
                    break;
                case 64:
                    $test->contentName = "ppt";
                    break;
            }
            $test->startData = null;
            $test->id = (string)$test->testId;

            $test->description = $test->caption;
            $test->startTimestamp = $test->openTime;
            $test->endTimestamp = $test->closeTime;
        }
        return $tests;
    }

    // Create a session record that runs throughout the test
    public function startSession($user, $rootId, $productCode, $testId=null)     {
        return $this->progressOps->startTestSession($user, $rootId, $productCode, $testId);
    }

    // Write a score record and many score detail records
    public function scoreWrite($user, $session, $scoreObj, $clientTimezoneOffset=null) {
        // If this is the first score, make sure the session includes the testDetailId
        $session->testId = ($session->testId) ? ($session->testId) : $scoreObj->testId;
        $this->progressOps->updateTestSession($session);

        // Manipulate the score object from Couloir into Bento format
        $score = new Score($scoreObj, $clientTimezoneOffset);
        $score->sessionID = $session->sessionId;
        $score->userID = $user->userID;

        // Write the score record
        $this->progressOps->insertScore($score, $user);

        // Write each score detail
        $scoreDetails = array();
        foreach ($scoreObj->answers as $answer) {
            $scoreDetails[] = new ScoreDetail($answer, $clientTimezoneOffset);
        }
        $this->progressOps->insertScoreDetail($scoreDetails, $user);
    }
}