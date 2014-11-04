<?php
/**
 * Used for TB6weeks
 * This is NOT called via amfphp, but aims to use the same classes
 * 
 */

require_once(dirname(__FILE__)."/../../config.php");
 
require_once($GLOBALS['adodb_libs']."adodb-exceptions.inc.php");
require_once($GLOBALS['adodb_libs']."adodb.inc.php");

require_once(dirname(__FILE__)."/vo/com/clarityenglish/dms/vo/account/Account.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/Reportable.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/content/Course.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/content/Title.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/Group.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/User.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/bento/vo/progress/Score.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/LoginAPI.php");

require_once(dirname(__FILE__)."/../../classes/AuthenticationOps.php");
require_once(dirname(__FILE__)."/../../classes/ManageableOps.php");

// Common ops
require_once(dirname(__FILE__)."/../../classes/ManageableOps.php");
require_once(dirname(__FILE__)."/../../classes/ContentOps.php");
require_once(dirname(__FILE__)."/../../classes/CopyOps.php");
require_once(dirname(__FILE__)."/../../classes/LoginOps.php");
require_once(dirname(__FILE__)."/../../classes/AccountOps.php");
require_once(dirname(__FILE__)."/../../classes/TemplateOps.php");
require_once(dirname(__FILE__)."/../../classes/EmailOps.php");
require_once(dirname(__FILE__)."/../../classes/CourseOps.php");
require_once(dirname(__FILE__)."/../../classes/TestOps.php");
require_once(dirname(__FILE__)."/../../classes/MemoryOps.php");
//require_once(dirname(__FILE__)."/../../classes/SubscriptionOps.php");

require_once(dirname(__FILE__)."/AbstractService.php");

class TB6weeksService extends AbstractService {
	
	var $db;

	function __construct() {
		parent::__construct();
		
		// A unique ID to distinguish sessions between multiple Clarity applications
		Session::setSessionName("TB6weeks");
				
		// Set the product name and userID for logging
		AbstractService::$log->setProductName("TB6WEEKS");

		// Set the title name for resources
		AbstractService::$title = "tb6weeks";
		
		$this->manageableOps = new ManageableOps($this->db);
		$this->emailOps = new EmailOps($this->db);
		$this->courseOps = new CourseOps($this->db);
		$this->loginOps = new LoginOps($this->db);
		$this->testOps = new TestOps($this->db);
		//$this->subscriptionOps = new SubscriptionOps($this->db);
		//$this->memoryOps = new MemoryOps($this->db);

		// This is a back end service adding users, so doesn't use authentication
		AuthenticationOps::$useAuthentication = false;
		
		// for debugging if you only have one session
		Session::set('productCode', 59);
		//Session::set('userID', 27639);
		
		// To mimic amfphp handling
		try {
			
			if (isset($_REQUEST['operation'])) {
				switch ($_REQUEST['operation']) {
					case 'checkEmail':
						$prefix = isset($_REQUEST['prefix']) ? $_REQUEST['prefix'] : null;
						$userEmail = isset($_REQUEST['userEmail']) ? $_REQUEST['userEmail'] : null;
						$returnData = $this->checkEmail($prefix, $userEmail);
						break;
					
					case 'getQuestions':
						$prefix = isset($_REQUEST['prefix']) ? $_REQUEST['prefix'] : null;
						$exercise = isset($_REQUEST['exercise']) ? $_REQUEST['exercise'] : null;
						$returnData = $this->getQuestions($prefix, $exercise);
						break;
					
					case 'submitAnswers':
						$prefix = isset($_REQUEST['prefix']) ? $_REQUEST['prefix'] : null;
						$attempts = isset($_REQUEST['answers']) ? $_REQUEST['answers'] : null;
						$answers = isset($_REQUEST['code']) ? $_REQUEST['code'] : null;
						$userDetails = isset($_REQUEST['user']) ? $_REQUEST['user'] : null;
						$returnData = $this->submitAnswers($attempts, $answers, $userDetails, $prefix);
						break;
					
					default:
						throw new Exception('Unexpected operation requested');
						break;
				}
			
				echo $returnData;
			}
			
		} catch (Exception $e) {
			$errorData = new DOMDocument();
			$errors = $errorData->appendChild($errorData->createElement('errors'));
			$error = $errors->appendChild($errorData->createElement('error'));
			$error->setAttribute('message', $e->getMessage());
			
			echo $errorData->saveXML();
			
		}
		flush();
		exit();
	}

	/**
	 * Check that the email is new or is registered in this account
	 * 
	 * @param string $prefix
	 * @param string $userEmail
	 */
	public function checkEmail($prefix, $userEmail) {
		
		//parse_str($userDetails, $tempUser);
		//$user = new User();
		//$user->email = $tempUser['userEmail'];
		$rootId = Session::get('rootID');
		$productCode = Session::get('productCode');
		
		AbstractService::$debugLog->info("check email session variables: rootId=".$rootId.' productCode='.$productCode);
		$rc = $this->manageableOps->checkProductSubscription($userEmail, $rootId, $productCode);
		
		return json_encode($rc);

	}
	
	/**
	 * See if the account the user is working in has a valid subscription to this title
	 * 
	 * @param String $prefix
	 */
	public function checkAccount($config) {
		
		$account = $this->loginOps->getAccountSettings($config);
		
		// gh#315 If no account and you didn't throw an exception, just means we can't find it from partial parameters
		if (!$account)
			return null;
			
		$group = $this->manageableOps->getGroup($this->manageableOps->getGroupIdForUserId($account->getAdminUserID()));
		
		// Set some session variables that other calls will use
		Session::set('rootID', $account->id);
		Session::set('productCode', $config['productCode']);		
		Session::set('groupID', $group->id);	
		
		return array("group" => $group,
					 "account" => $account);
		
	}
	
	/**
	 * Validate the account and send back a set of random questions
	 * 
	 * @param string $prefix
	 * @param string $exercise
	 */
	public function getQuestions($prefix, $exercise) {
		
		if (!$prefix)
			throw new Exception('This test must be run from a nice link');
			
		$productCode = 59;
		$dbHost = 2;
			
		$config = array('prefix' => $prefix, 'productCode' => $productCode, 'dbHost' => $dbHost);

		try {
			$rc = $this->checkAccount($config);
		} catch (Exception $e) {
		}
		if ($rc) {
			$data = $this->testOps->getQuestions($exercise);
		} else {
			throw new Exception('Your account is not setup for TB6weeks');
		}
		return $data->saveXML();

	}
	
	/**
	 * 
	 * This will mark the placement test and register the user for their subscription
	 * 
	 * @param pair/value string $answers
	 * @param encrypted string of xml $code
	 * @param pair/value string $userDetails
	 */
	public function submitAnswers($attempts, $answers, $userDetails, $prefix) {
		
		$rootId = Session::get('rootID');
		$score = $this->testOps->checkAnswers($attempts, $answers);
		//AbstractService::$debugLog->info("score: %=".$score->score." raw=".$score->scoreCoorect);
		
		// Is this an existing user, or do we need to register a new one?
		AbstractService::$debugLog->info("add user to root=$rootId");
		$user = $this->manageableOps->getOrAddUser($userDetails);
		AbstractService::$debugLog->info("user: id=".$user->userID." name=".$user->name.' email='.$user->email);
		Session::set('userID', $user->userID);
		
		// make sure the above user has set the Session::set('userID') before calling memoryOps
		$this->memoryOps = new MemoryOps($this->db);
		
		// Work out the TB6weeks settings for direct start and save for the user
		$CEFLevel = $this->testOps->getCEFLevel($score);
		$ClarityLevel = $this->testOps->getClarityLevel($score);
		$directStart = $this->testOps->getDirectStart($ClarityLevel);
		// The bookmark (which controls direct start), is written to Tense Buster memory, not TB6weeks.
		$tbProductCode = 55;
		$rc = $this->memoryOps->addToMemory('bookmark', $directStart, $tbProductCode);
		$rc = $this->memoryOps->addToMemory('CEF', $CEFLevel);
		$rc = $this->memoryOps->addToMemory('level', $ClarityLevel);
		$now = new DateTime();
		$rc = $this->memoryOps->addToMemory('subscription', $now->format('Y-m-d'));
		$rc = $this->memoryOps->writeMemory();
		
		// TODO: encrytped please
		$startProgram = '/area1/TenseBuster10/Start.php?prefix='.$prefix.'&email='.$user->email.'&password='.$user->password.'&username='.$user->name;
		
		// Trigger a welcome email
		$templateID = 'user/TB6weeksWelcome';
		$emailData = array("user" => $user, "level" => $ClarityLevel, "programLink" => $startProgram, "dateDiff" => '2 days');
		$thisEmail = array("to" => $user->email, "data" => $emailData);
		$emailArray[] = $thisEmail;
		
		$this->emailOps->sendEmails("", $templateID, $emailArray);
		//AbstractService::$debugLog->info("queued email to ".$user->email.' using '.$templateID);
		
		// Send back the CEF level and a direct start link (based on user details)
		$debug='';
		return json_encode(array('debug' => $debug, 'startProgram' => $startProgram, 'ClarityLevel' => $ClarityLevel, 'score' => $score->score, 'correct' => $score->scoreCorrect, 'skipped' => $score->scoreMissed, 'wrong' => $score->scoreWrong));
		
	}
	
}
// To mimic amfphp handling
$doIt = new TB6weeksService();
flush();
exit();