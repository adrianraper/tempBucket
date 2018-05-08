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
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/content/Bookmark.php");
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

require_once($GLOBALS['common_dir'].'/encryptURL.php');

class xxTB6WeeksService extends AbstractService {
	
	// var $productCode = 59;
	var $dbHost = 2;
	var $server;
	var $dateDiff = '7 days';
	
	function __construct() {
		parent::__construct();
		
		$this->server = $_SERVER['HTTP_HOST'];
		
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
		$this->memoryOps = new MemoryOps($this->db);
		$this->accountOps = new AccountOps($this->db);
		
		// This is a back end service adding users, so doesn't use authentication
		AuthenticationOps::$useAuthentication = false;
		
		// for debugging if you only have one session
		//Session::set('productCode', 59);
		//Session::set('rootID', 163);
		//$_REQUEST['operation'] = "submitAnswers";
		//$_REQUEST['productCode'] = "59";
		//$_REQUEST['email'] = "adrian@noodles.hk";
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
				$userEmail = isset($_REQUEST['userEmail']) ? $_REQUEST['userEmail'] : null;
				if ($userDetails) {
					$stubUser = $this->parseUserDetails($userDetails);
				} elseif ($userEmail) {
					$stubUser = $this->parseUserEmail($userEmail);
				}
					
				switch ($_REQUEST['operation']) {
					case 'changeLevel':
						$returnData = $this->changeLevel($stubUser, $level, $productCode);
						break;
					
					case 'unsubscribe':
						$returnData = $this->unsubscribe($stubUser, $productCode);
						break;

					case 'correct1170Markup':
						$returnData = $this->correct1170Markup($exercise);
						break;

					case 'getQuestions':
						$rc = $this->checkAccount($prefix, $productCode);
						$returnData = ($rc) ? $this->getQuestions($exercise) : $rc;
						break;
						
					case 'isEmailValid':
					case 'submitAnswers':
						if (!Session::get('groupID'))
							$rc = $this->checkAccount($prefix, $productCode);

						if ($_REQUEST['operation'] == 'isEmailValid') {
							// First, if this email exists, is it a user in this account?
							// Note that a conflict (duplicate users with this email) will throw an exception here
							// Do NOT pass a rootId here as you want the email address to be unique across all roots
							// Note that if you pass null root, the session data will be used
							$user = $this->manageableOps->getUserByKey($stubUser, 0, User::LOGIN_BY_EMAIL);
							if (!$user) {
								$returnData = json_encode('new user');
								
							} else {
								// Is this user in this account?
								$rootId = Session::get('rootID');
								$usersRootId = $this->manageableOps->getRootIdForUserId($user->userID);
								if ($rootId != $usersRootId) {
									$returnData = json_encode("user in wrong account ($usersRootId) should be $rootId");
									
								} else {	
									// Finally, has this existing user already got a subscription that will be overwritten?
									$returnData = $this->checkSubscription($user);
								}
							}

						} elseif ($_REQUEST['operation'] == 'submitAnswers') { 
							$returnData = $this->submitAnswers($attempts, $answers, $stubUser, $prefix);
						}
						break;
					
					default:
						throw new Exception('Unexpected operation requested');
						break;
				}
			
				echo $returnData;
			}
			
		} catch (Exception $e) {
            // TODO Change isEmailValid to return xml as all the other functions do
            if ($_REQUEST['operation']=='isEmailValid') {
                echo json_encode($e->getMessage());
            } else {
                $errorData = new DOMDocument();
                $errors = $errorData->appendChild($errorData->createElement('errors'));
                $error = $errors->appendChild($errorData->createElement('error'));
                $error->setAttribute('message', $e->getMessage());

                echo $errorData->saveXML();
            }

		}
		flush();
		exit();
	}

	/**
	 * Check if the user has already subscribed to this product. The user must be in this root.
	 * 
	 * @param string $prefix
	 * @param string $user
	 */
	public function checkSubscription($user, $productCode = null) {

		if (!$productCode)
			$productCode = Session::get('productCode');
		
		AbstractService::$debugLog->info("check if user has subscribed to productCode=$productCode");
		$rc = $this->subscriptionOps->hasProductSubscription($user, $productCode);
		if ($rc)
			return json_encode('existing subscription');
		return json_encode('no subscription');

	}
	
	/**
	 * Unsubscribe a user. Remove their subscription records and then anonymise them as a user.
	 * 
	 * @param string $email
	 */
	public function unsubscribe($stubUser, $productCode) {
		
		// Get this user
		$users = $this->manageableOps->getUserFromEmail($stubUser->email);
		if ($users) {
			$user = $users[0];
			
			// Check the password
			if ($user->password == $stubUser->password) {
				$account = $this->manageableOps->getAccountFromUser($user);
				Session::set('userID', $user->userID);
				Session::set('productCode', $productCode);
				Session::set('rootID', $account->id);
				
				$rc = $this->subscriptionOps->removeProductSubscription($user, $productCode);
                if ($rc == 'done')
                    $this->manageableOps->anonymizeUser($user);
				
			} else {
				$rc = 'wrong password';
			}
			
		} else {
			$rc = "no such user";
		}
		return json_encode($rc);
				
	}
	
	/**
	 * Change a user's level. Only do this if they have a subscription already, though it doesn't need to still be valid.
	 * 
	 * 
	 * @param string $email, $level
	 */
	public function changeLevel($stubUser, $level, $productCode) {
		
		// Get this user
		$users = $this->manageableOps->getUserFromEmail($stubUser->email);
		if ($users) {
			$user = $users[0];
			AbstractService::$debugLog->info("change level for user: id=".$user->userID." name=".$user->name.' email='.$user->email);
			
			// Check the password
			if ($user->password == $stubUser->password) {
				$account = $this->manageableOps->getAccountFromUser($user);
				Session::set('userID', $user->userID);
				Session::set('productCode', $productCode);
				Session::set('rootID', $account->id);
				
				// Check that this user has already subscribed
				$this->memoryOps = new MemoryOps($this->db);
				if ($this->memoryOps->get('subscription')) {
					$bookmark = $this->subscriptionOps->getDirectStart($level, 0); // for week 0
					$rc = $this->subscriptionOps->changeProductSubscription($productCode, $level, $bookmark, $this->dateDiff);
					
					if ($rc == 'success') {

						// gh#1202 If the account is using an RUrange, pass that as well
						$licenceAttributes = $this->accountOps->getAccountLicenceDetails($account->id, null, $productCode);
						foreach ($licenceAttributes as $lA) {
							if ($lA['licenceKey'] == 'RUrange') {
								$ranges = explode(',', $lA['licenceValue']);
								$RUrange= $ranges[0];
								break;
							}
						}

                        $crypt = new Crypt();
                        $programBase = 'http://'.$this->server.'/area1/TenseBuster/Start.php';
                        $parameters = 'prefix='.$account->prefix.'&email='.$user->email.'&password='.$user->password.'&username='.$user->name;
						if ($RUrange)
							$parameters .= '&RUrange='.$RUrange;
						//AbstractService::$debugLog->info("change level email parameters=".$parameters);
                        $startProgram = "?data=".$crypt->encodeSafeChars($crypt->encrypt($parameters));
                        $parameters .= '&startingPoint=state:progress';
                        $startProgress = "?data=".$crypt->encodeSafeChars($crypt->encrypt($parameters));

						// Trigger a welcome email
						$templateID = 'user/TB6weeksNewUnit';
						$emailData = array("user" => $user, "level" => $level, "programBase" => $programBase, "startProgram" => $startProgram, "startProgress" => $startProgress, "dateDiff" => $this->dateDiff, "weekX" => 1, "server" => $this->server, "prefix" => $account->prefix);
						$thisEmail = array("to" => $user->email, "data" => $emailData);
						$emailArray[] = $thisEmail;
						
						$this->emailOps->sendEmails("", $templateID, $emailArray);
					}
				} else {
					$rc = 'no existing subscription';
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
	public function checkAccount($prefix, $productCode) {
		
		if (!$prefix)
			throw new Exception('This test must be run from a nice link');
		if (!$productCode)
			throw new Exception('No product code given');

		$config = array('prefix' => $prefix, 'productCode' => $productCode);
		$account = $this->loginOps->getAccountSettings($config);
		
		// gh#315 If no account and you didn't throw an exception, just means we can't find it from partial parameters
		if (!$account)
			throw new Exception('Your account is not setup for TB6weeks');

        // gh#1118
		$group = $this->manageableOps->getGroupForTB6weeks($account, $productCode);
		
		// Set some session variables that other calls will use
		Session::set('rootID', $account->id);
		Session::set('productCode', $config['productCode']);		
		Session::set('groupID', $group->id);	
		
		return true;
			
	}
	
	/**
	 * Send back a set of random questions based on a template that points at a set of question bank(s)
	 * 
	 * @param string $prefix
	 * @param string $exercise
	 */
	public function getQuestions($exercise) {
		
		$data = $this->testOps->getQuestions($exercise);
		return $data->saveXML();

	}

	/**
	 * Utility function to help an editor mark up a question bank
	 * The editor manually goes through each question adding placementTest="true" to any question that are
	 * good to use in testing.
	 * The editor adds this to the <div> that holds the English version of the question
	 * 	<div class="question" id="b3" placementTest="true">
	 * 		<div class="question-text">
	 * 			The bus <input id="q28"/> (leave) every ten minutes, so don't worry about being late.
	 * 		</div>
	 * 	</div>
	 * But we really need this attribute to go on the associated <GapFillQuestion> tag.
	 * This function will 'clean' the files the editor has marked up.
	 */
	public function correct1170Markup($exercise) {
		$data = $this->testOps->correct1170Markup($exercise);
		return $data->saveXML();
	}

	/**
	 *
	 * This will mark the placement test and register the user for their subscription.
	 * 
	 * @param pair/value string $answers
	 * @param encrypted string of xml $code
	 * @param pair/value string $userDetails
	 */
	public function submitAnswers($attempts, $answers, $stubUser, $prefix) {
		
		$rootId = Session::get('rootID');
		$groupId = Session::get('groupID');
		$productCode = Session::get('productCode');
		
		// Is this an existing user, or do we need to register a new one?
		$user = $this->manageableOps->getOrAddUser($stubUser, $rootId, $groupId);
		AbstractService::$debugLog->info("add/get user: id=".$user->userID." name=".$user->name.' email='.$user->email);
		Session::set('userID', $user->userID);
		
		$score = $this->testOps->checkAnswers($attempts, $answers);

		// Work out the TB6weeks settings for direct start and save for the user
		$CEFLevel = $this->testOps->getCEFLevel($score);
		$ClarityLevel = $this->testOps->getClarityLevel($score);
		$bookmark = $this->subscriptionOps->getDirectStart($ClarityLevel, 0);

		// reset our memory class now that we have the user details
		$this->memoryOps = new MemoryOps($this->db);
		$now = new DateTime();
		// TODO where to get the frequency from?
		$subscriptionMemory = array('startDate' => $now->format('Y-m-d'), 'frequency' => $this->dateDiff, 'valid' => true);
		$rc = $this->memoryOps->set('subscription', $subscriptionMemory);
		$rc = $this->memoryOps->set('CEF', $CEFLevel);
		$rc = $this->memoryOps->set('level', $ClarityLevel);
		
		// The bookmark (which controls direct start), is written to Tense Buster memory, not TB6weeks.
		$rc = $this->memoryOps->set('directStart', $bookmark, $this->subscriptionOps->relatedProducts($productCode));

		// gh#1202 If the account is using an RUrange, pass that as well
		$licenceAttributes = $this->accountOps->getAccountLicenceDetails($rootId, null, $productCode);
		foreach ($licenceAttributes as $lA) {
			if ($lA['licenceKey'] == 'RUrange') {
				$ranges = explode(',', $lA['licenceValue']);
				$RUrange= $ranges[0];
				break;
			}
		}

        $crypt = new Crypt();
        $programBase = 'http://'.$this->server.'/area1/TenseBuster/Start.php';
        $parameters = 'prefix='.$prefix.'&email='.$user->email.'&password='.$user->password.'&username='.$user->name;
		if ($RUrange)
			$parameters .= '&RUrange='.$RUrange;

		$startProgram = "?data=".$crypt->encodeSafeChars($crypt->encrypt($parameters));
        $parameters .= '&startingPoint=state:progress';
        $startProgress = "?data=".$crypt->encodeSafeChars($crypt->encrypt($parameters));

        // Trigger a welcome email
        $templateID = 'user/TB6weeksNewUnit';
        $emailData = array("user" => $user, "level" => $ClarityLevel, "programBase" => $programBase, "startProgram" => $startProgram, "startProgress" => $startProgress, "dateDiff" => $this->dateDiff, "weekX" => 1, "server" => $this->server, "prefix" => $prefix);
		$thisEmail = array("to" => $user->email, "data" => $emailData);
		$emailArray[] = $thisEmail;
		
		$this->emailOps->sendEmails("", $templateID, $emailArray);
		
		// Send back the CEF level and a direct start link (based on user details)
		$debug='';
		return json_encode(array('debug' => $debug, 'startProgram' => $startProgram, 'ClarityLevel' => $ClarityLevel, 'score' => $score->score, 'correct' => $score->scoreCorrect, 'skipped' => $score->scoreMissed, 'wrong' => $score->scoreWrong));
	}
	/**
	 * If you are given user details in a name value string turn into a User object
	 * userEmail=dandy%40email&userName=asfsadf&password=password&confirmPassword=password
	 */
	private function parseUserDetails($userDetails) {
		parse_str($userDetails, $tempUser);
		$stubUser = new User();
		if (isset($tempUser['userName']))
			$stubUser->name = $tempUser['userName'];
		if (isset($tempUser['userId']))
			$stubUser->studentID = $tempUser['userId'];
		if (isset($tempUser['userEmail']))
			$stubUser->email = $tempUser['userEmail'];
		if (isset($tempUser['password']))
			$stubUser->password = $tempUser['password'];
		return $stubUser;
	} 
	/**
	 * If you are given user details in a single string
	 * userEmail=dandy%40email
	 */
	private function parseUserEmail($userEmail) {
		$stubUser = new User();
		$stubUser->email = $userEmail;
		return $stubUser;
	} 
	
}
// To mimic amfphp handling
$doIt = new xxTB6WeeksService();
flush();
exit();
