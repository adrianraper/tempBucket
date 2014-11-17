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
require_once(dirname(__FILE__)."/../../classes/SubscriptionOps.php");

require_once(dirname(__FILE__)."/AbstractService.php");

class TB6weeksService extends AbstractService {
	
	var $productCode = 59;
	var $dbHost = 2;
	var $dateDiff = '2 days';
	
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
		$this->subscriptionOps = new SubscriptionOps($this->db);
		//$this->memoryOps = new MemoryOps($this->db);

		// This is a back end service adding users, so doesn't use authentication
		AuthenticationOps::$useAuthentication = false;
		
		// for debugging if you only have one session
		//Session::set('productCode', 59);
		//Session::set('rootID', 163);
		//$_REQUEST['operation'] = "submitAnswers";
		//$_REQUEST['productCode'] = "59";
		//$_REQUEST['userEmail'] = "adrian@noodles.hk";
		//$_REQUEST['level'] = "UI";
		//$_REQUEST['answers'] = "UI";
		
		// To mimic amfphp handling
		try {
			
			AbstractService::$debugLog->info("try ".$_REQUEST['operation']);
			
			if (isset($_REQUEST['operation'])) {
				$productCode = isset($_REQUEST['productCode']) ? $_REQUEST['productCode'] : null;
				$level = isset($_REQUEST['level']) ? $_REQUEST['level'] : null;
				$prefix = isset($_REQUEST['prefix']) ? $_REQUEST['prefix'] : null;
				$exercise = isset($_REQUEST['exercise']) ? $_REQUEST['exercise'] : null;
				$attempts = isset($_REQUEST['answers']) ? $_REQUEST['answers'] : null;
				$answers = isset($_REQUEST['code']) ? $_REQUEST['code'] : null;
				$userDetails = isset($_REQUEST['user']) ? $_REQUEST['user'] : null;
				
				switch ($_REQUEST['operation']) {
					case 'changeLevel':
						$returnData = $this->changeLevel($userDetails, $level, $productCode);
						break;
					
					case 'unsubscribe':
						$returnData = $this->unsubscribe($userDetails, $productCode);
						break;
						
					case 'getQuestions':
					case 'checkEmail':
					case 'submitAnswers':
						if (!Session::get('groupID'))
							$rc = $this->checkAccount($prefix);

						if ($_REQUEST['operation'] == 'checkEmail') {
							$returnData = $this->checkEmail($prefix, $userEmail);

						} elseif ($_REQUEST['operation'] == 'getQuestions') { 
							$returnData = $this->getQuestions($exercise);
					
						} elseif ($_REQUEST['operation'] == 'submitAnswers') { 
							$returnData = $this->submitAnswers($attempts, $answers, $userDetails, $prefix);
						}
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
		$rc = $this->subscriptionOps->checkProductSubscription($userEmail, $rootId, $productCode);
		
		return json_encode($rc);

	}
	
	/**
	 * Unsubscribe a user. Means totally remove them.
	 * 
	 * @param string $userEmail
	 */
	public function unsubscribe($userEmail, $productCode) {
		
		$rc = $this->subscriptionOps->removeProductSubscription($userEmail, $productCode);
		AbstractService::$debugLog->info("unsubscribe: email=".$userEmail.' productCode='.$productCode);
		
		return json_encode($rc);

	}
	
	/**
	 * Change a user's level
	 * <level>INT</level><subscription startDate="2014-11-05" frequency="2 days" valid="true"/>
	 * 
	 * @param string $userEmail, $level
	 */
	public function changeLevel($userDetails, $level, $productCode) {
		
		// Get this user
		$user = $this->manageableOps->getOrAddUser($userDetails);
		if ($user) {
			AbstractService::$debugLog->info("user: id=".$user->userID." name=".$user->name.' email='.$user->email);
			parse_str($userDetails, $tempUser);
			if ($user->password == $tempUser['password']) {
				Session::set('userID', $user->userID);
				
				$account = $this->manageableOps->getAccountFromUser($user);
				$rc = $this->subscriptionOps->changeProductSubscription($user, $level, $productCode);
				
				if ($rc == 'success') {
					// TODO: encrytped please
					$startProgram = '/area1/TenseBuster10/Start.php?prefix='.$account->prefix.'&email='.$user->email.'&password='.$user->password.'&username='.$user->name;
					
					// Trigger a welcome email
					$templateID = 'user/TB6weeksWelcome';
					$emailData = array("user" => $user, "level" => $level, "programLink" => $startProgram, "dateDiff" => $this->dateDiff);
					$thisEmail = array("to" => $user->email, "data" => $emailData);
					$emailArray[] = $thisEmail;
					
					$this->emailOps->sendEmails("", $templateID, $emailArray);
					
					AbstractService::$debugLog->info("change level: email=".$user->email.' to='.$level);
				}
			} else {
				$rc = 'wrong password';
			}
			
		} else {
			$rc = "no such user";
		}
		return json_encode($rc);

	}
	
	/**
	 * See if the account the user is working in has a valid subscription to this title
	 * 
	 * @param String $prefix
	 */
	public function checkAccount($prefix) {
		
		if (!$prefix)
			throw new Exception('This test must be run from a nice link');

		$config = array('prefix' => $prefix, 'productCode' => $this->productCode, 'dbHost' => $this->dbHost);
		$account = $this->loginOps->getAccountSettings($config);
		
		// gh#315 If no account and you didn't throw an exception, just means we can't find it from partial parameters
		if (!$account)
			throw new Exception('Your account is not setup for TB6weeks');
			
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
	public function getQuestions($exercise) {
		
		$data = $this->testOps->getQuestions($exercise);
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
		$server = 'dock.projectbench';
		$startProgram = 'http://'.$server.'/area1/TenseBuster10/Start.php?prefix='.$prefix.'&email='.$user->email.'&password='.$user->password.'&username='.$user->name;
		
		// Trigger a welcome email
		$templateID = 'user/TB6weeksWelcome';
		$emailData = array("user" => $user, "level" => $ClarityLevel, "programLink" => $startProgram, "dateDiff" => $this->dateDiff, "server" => $server);
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

		if (!$prefix)
			throw new Exception('This test must be run from a nice link');
			
		$config = array('prefix' => $prefix, 'productCode' => $this->productCode, 'dbHost' => $this->dbHost);

		try {
			$rc = $this->checkAccount($config);
		} catch (Exception $e) {
		}
		if ($rc) {
			$data = $this->testOps->getQuestions($exercise);
		} else {
			throw new Exception('Your account is not setup for TB6weeks');
		}
