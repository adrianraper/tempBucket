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

		// To mimic amfphp handling
		try {
			
			if (isset($_REQUEST['operation']))
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
						$attempts = isset($_REQUEST['answers']) ? $_REQUEST['answers'] : null;
						$answers = isset($_REQUEST['code']) ? $_REQUEST['code'] : null;
						$userDetails = isset($_REQUEST['user']) ? $_REQUEST['user'] : null;
						$returnData = $this->checkAnswers($attempts, $answers, $userDetails);
						break;
					
					default:
						throw new Exception('Unexpected operation requested');
						break;
				}
			
			echo $returnData;
			
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
	 * @param object $userDetails
	 */
	public function checkEmail($prefix, $userEmail) {
		
		//parse_str($userDetails, $tempUser);
		//$user = new User();
		//$user->email = $tempUser['userEmail'];
		$rootID = Session::get('rootID');
		
		$rc = $this->manageableOps->checkEmailInAccount($userEmail, $rootID);
		
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
	public function submitAnswers($attempts, $answers, $userDetails) {
		
		$score = $this->testOps->checkAnswers($attempts, $answers);
		
		// Is this an existing user, or do we need to register a new one 
		$rootID = Session::get('rootID');
		$loginOption = 128;
		parse_str($userDetails, $tempUser);
		$user = $this->manageableOps->getUserFromEmail($tempUser['userEmail']);
		if (!$user) {
			$user = new User();
			$user->email = $tempUser['userEmail'];
			$user->name = $tempUser['userName'];
			$group = new Group();
			$group->id = Session::get('groupID');
			// NOTE that this is going to fail because of authentication check on logged in user having rights on the group
			$rc = $this->manageableOps->addUser($user, $group, $rootID, $loginOption);
		}

		// Work out the TB6weeks settings for direct start and save for the user
		$directStart = $this->testOps->getDirectStart($score);
		$user->memory .= $directStart;
		$rc = $this->managableOps->updateUser($user);
		
		return json_encode(array('debug' => $debug, 'percentage' => $score->score, 'of' => $numQuestions, 'correct' => $score->scoreCorrect, 'skipped' => $score->scoreMissed, 'wrong' => $score->scoreWrong));
		
	}
	
	public function scoreMultiplier($scoreBand) {
		switch ($scoreBand) {
			case 'ELE':
				return 1;	
				break;
			case 'LI':
				return 2;	
				break;
			case 'INT':
				return 3;	
				break;
 			case 'UI':
				return 4;	
				break;
 			case 'ADV':
				return 5;	
				break;
			default:
				break;
		}
		return 0;
	}
	
}
// To mimic amfphp handling
$doIt = new TB6weeksService();
flush();
exit();