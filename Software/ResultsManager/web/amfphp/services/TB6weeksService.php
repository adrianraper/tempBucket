<?php
/**
 * Used for TB6weeks
 * This is NOT called via amfphp, but aims to use the same classes
 * 
 */

require_once(dirname(__FILE__)."/../../config.php");
 
require_once($GLOBALS['adodb_libs']."adodb-exceptions.inc.php");
require_once($GLOBALS['adodb_libs']."adodb.inc.php");

require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/Reportable.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/content/Course.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/Group.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/common/vo/manageable/User.php");
require_once(dirname(__FILE__)."/vo/com/clarityenglish/bento/vo/progress/Score.php");

require_once(dirname(__FILE__)."/../../classes/AuthenticationOps.php");
require_once(dirname(__FILE__)."/../../classes/ManageableOps.php");

// Common ops
require_once(dirname(__FILE__)."/../../classes/ManageableOps.php");
require_once(dirname(__FILE__)."/../../classes/ContentOps.php");
require_once(dirname(__FILE__)."/../../classes/CopyOps.php");
require_once(dirname(__FILE__)."/../../classes/AccountOps.php");
require_once(dirname(__FILE__)."/../../classes/TemplateOps.php");
require_once(dirname(__FILE__)."/../../classes/EmailOps.php");
require_once(dirname(__FILE__)."/../../classes/CourseOps.php");

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

		// To mimic amfphp handling
		if (isset($_REQUEST['operation']))
			switch ($_REQUEST['operation']) {
				case 'getQuestions':
					$exercise = isset($_REQUEST['exercise']) ? $_REQUEST['exercise'] : null;
					$returnData = $this->getQuestions($exercise);
					break;
				
				case 'checkAnswers':
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
			flush();
			exit();
	}

	public function getQuestions($exercise) {
		
		// Get the test definition
		$testTemplate = '../../'.$GLOBALS['data_dir'].'/TB6weeks/'.$exercise;

		// initialise
		$data = new DOMDocument();
		$test = $data->appendChild($data->createElement('test'));
		$questions = $test->appendChild($data->createElement('questions'));
		$answers = $test->appendChild($data->createElement('config'));
		$debug = $test->appendChild($data->createElement('debug'));
		$answerData = '';
		$newQuestionId = $newBlockId = $newSourceId = 0;
		
		if (!file_exists($testTemplate))
			throw new Exception($testTemplate." file not found");
		
		$template = new DOMDocument();
		$template->load($testTemplate);
        $templateXPath = new DOMXpath($template);
		
        // Set the namespace so that xpath can work
		$templateXPath->registerNamespace('xmlns', 'http://www.w3.org/1999/xhtml');

		// The test template might pick x questions directly from each question bank, or it might pick x from a group of question banks
		// If you are picking from a group, then it is assumed that the questions will be spread as equally as possible across the group.
		// So first work out how many questions (if any) to get from each question bank 
		$qbGroups = $templateXPath->query("//xmlns:questions/xmlns:group");
		foreach ($qbGroups as $qbGroup) {
			$groupName = $qbGroup->getAttribute('name');
			$numberForGroup = $qbGroup->getAttribute('use');
			$query = "//xmlns:questionBank[@group='$groupName']";
			$groupQbanks = $templateXPath->query($query);
			$numOfQbanks = $groupQbanks->length;
			
			if ($numberForGroup <= $numOfQbanks) {
				foreach ($groupQbanks as $groupQbank) {
					$groupQbank->setAttribute('use', 0);
				}
				$arrayIndexes = range(0, $numOfQbanks-1);
				$useThese = array_rand($arrayIndexes, $numberForGroup);
				for ($i = 0; $i < $numberForGroup; $i++) {
		            $groupQbanks->item($useThese[$i])->setAttribute('use', intval(1));
				}
				
			} else {
				$base = floor($numberForGroup / $numOfQbanks);
				$extra = $numberForGroup % $numOfQbanks;
				foreach ($groupQbanks as $groupQbank) {
					$groupQbank->setAttribute('use', $base);
				}
				$arrayIndexes = range(0, $numOfQbanks-1);
				$useThese = array_rand($arrayIndexes, $extra);
				for ($i = 0; $i < $numberForGroup; $i++) {
		            $groupQbanks->item($useThese[$i])->setAttribute('use', $base+1);
				}
				
			}
		}
		
		// Now pick the allocated x questions from each question bank
		$qbNodes = $templateXPath->query("//xmlns:questionBank");
		foreach ($qbNodes as $qb) {
	
			$questionBankFile = '../../'.$GLOBALS['data_dir'].'/TB6weeks/'.$qb->getAttribute('href');
			$qbGroup = $qb->getAttribute('group');
			$numQuestionsToUse = $qb->getAttribute('use');
			if ($numQuestionsToUse == '')
				$numQuestionsToUse = 5;
			if ($numQuestionsToUse == 0)
				continue;
			
			if (!file_exists($questionBankFile))
				throw new Exception($questionBankFile." file not found");
			
			$xml = new DOMDocument();
			$xml->load($questionBankFile);
	        $xmlXPath = new DOMXpath($xml);
	        
	        // Set the namespace so that xpath can work
			$xmlXPath->registerNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
			
			// Get all the question nodes and pick x at random
			$query = "//xmlns:div[@class='question']";
			$matchingNodes = $xmlXPath->query($query);
			$maxQuestions = $matchingNodes->length;
			if ($maxQuestions < 1)
				continue;
			$numQuestionsToUse = ($maxQuestions < $numQuestionsToUse) ? $maxQuestions : $numQuestionsToUse;			
			
			// gh#1030 Pick x questions at random from the bank
			if ($numQuestionsToUse == 1) {
				// Note that array_rand doesn't return an array if you have a single item
				$useThese = array(array_rand(range(0, $maxQuestions-1), $numQuestionsToUse));
			} else {
				$useThese = array_rand(range(0, $maxQuestions-1), $numQuestionsToUse);
			}
			for ($i = 0; $i < $numQuestionsToUse; $i++) {

	            // Find the matching answer model for this question
				$questionId = $matchingNodes->item($useThese[$i])->getAttribute('id');
				$modelQuery = '//xmlns:questions/*[@block="' . $questionId . '"]';
				$questionModel = $xmlXPath->query($modelQuery)->item(0);
				
				// Generate new ids for the new document to ensure uniqueness
				$newQuestionId++;
				$matchingNodes->item($useThese[$i])->setAttribute('id', 'b'.$newQuestionId);
				$questionModel->setAttribute('block', 'b'.$newQuestionId);
				
				// Add the group attribute so that you can figure out complex marking later
				$questionModel->setAttribute('scoreBand', $qbGroup);
				
				//$debugNode = $data->createElement('changingQId', $questionId);
				//$debugNode->setAttribute('newId', 'b'.$newQuestionId);
				//$debug->appendChild($debugNode);
				
				// MC or GF have different handling for source nodes
				$optionsQuery = "//xmlns:div[@class='question'][@id='" .'b'.$newQuestionId. "']//xmlns:a";
				$options = $xmlXPath->query($optionsQuery);
				$debugNode = $data->createElement('findQuery', $optionsQuery);
				$debugNode->setAttribute('found', $options->length);
				foreach ($options as $option) {
					$existingId = $option->getAttribute('id');
					$newSourceId++;
					$option->setAttribute('id', 'q'.$newSourceId);
					
					$modelAnswerQuery = '//xmlns:questions/*[@block="' . 'b'.$newQuestionId . '"]/xmlns:answer';
					$modelAnswers = $xmlXPath->query($modelAnswerQuery);
					foreach ($modelAnswers as $modelAnswer) {
						if ($modelAnswer->getAttribute('source') == $existingId)
							$modelAnswer->setAttribute('source', 'q'.$newSourceId);
					}
				}
				
				$optionsQuery = "//xmlns:div[@class='question'][@id='" .'b'.$newQuestionId. "']//xmlns:input";
				$options = $xmlXPath->query($optionsQuery);
				foreach ($options as $option) {
					//$existingId = $gfOption->getAttribute('id');
					$newSourceId++;
					$option->setAttribute('id', 'q'.$newSourceId);
					$questionModel->setAttribute('source', 'q'.$newSourceId);
				}
				
				// Add the modified nodes to the new document
	            $question = $data->importNode($matchingNodes->item($useThese[$i]), true);
	            $questions->appendChild($question);
	            $answerData .= $questionModel->ownerDocument->saveXML($questionModel); 
			}
		}
			
		// encrypt the answers as a CDATA string
		$encryptedAnswers = $this->encodeSafeChars($answerData);
		$encryptedAnswers = $this->encodeSafeChars($this->encrypt($answerData));
		
		$answers->appendChild($data->createCDATASection($encryptedAnswers));
					 
		// Return the data
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
	public function checkAnswers($attempts, $answers, $userDetails) {
		
		/*
			<MultipleChoiceQuestion block="q1">
		      <answer source="a1" correct="true"/>
		      <answer source="a2" correct="false"/>
		      <answer source="a3" correct="false"/>
		      <answer source="a4" correct="false"/>
		    </MultipleChoiceQuestion>
	        <GapFillQuestion source="q26" block="b1">
		      <answer value="It's" correct="true"/>
		      <answer value="It is" correct="true"/>
		    </GapFillQuestion>
		    
		    <input class="MultipleChoiceQuestion" id="q1" value="a1" />
		    <input class="GapFillQuestion" id="b1" value="It's" />
		 */
		
		$numQuestions = $potentialScore = 0;
		$score = new Score();
		$score->scoreCorrect = $score->scoreMissed = $score->scoreWrong = 0;
		
		$answersXmlString = $this->decodeSafeChars($answers);
		$answersXmlString = $this->decrypt($this->decodeSafeChars($answers));
		$answersXml = simplexml_load_string('<answers>'.$answersXmlString.'</answers>');
		$numQuestions = $answersXml->MultipleChoiceQuestion->count() + $answersXml->GapFillQuestion->count();
		
		if ($numQuestions <= 0)
			return json_encode(array('error' => 'no questions'));
		
		$attemptsXml = simplexml_load_string('<attempts>'.$attempts.'</attempts>');
		$debug = '';
		
		foreach ($answersXml->MultipleChoiceQuestion as $mcq) {
			$qId = $mcq['block'];
			$scoreBand = $mcq['scoreBand'];
			$potentialScore += $this->scoreMultiplier($scoreBand);
			
			$thisQuestionAttempts = $attemptsXml->xpath("//input[@id='$qId']");
			// Has the user attempted to answer this question? 
			if ($thisQuestionAttempts && count($thisQuestionAttempts) > 0) {
				$attemptedAnswer = $thisQuestionAttempts[0]['value'];
				
				if ($mcq->xpath('//answer[@correct="true"][@source="'.$attemptedAnswer.'"]')) {
					$score->scoreCorrect += $this->scoreMultiplier($scoreBand);
				} else {
					$score->scoreWrong++;
				}
			} else {
				$score->scoreSkipped++;
			}
		}
		foreach ($answersXml->GapFillQuestion as $gfq) {
			$qId = $gfq['block'];
			$scoreBand = $gfq['scoreBand'];
			$potentialScore += $this->scoreMultiplier($scoreBand);
			$thisQuestionAttempts = $attemptsXml->xpath("//input[@id='$qId']");
			// Has the user attempted to answer this question? 
			if ($thisQuestionAttempts && count($thisQuestionAttempts) > 0) {
				$attemptedAnswer = $thisQuestionAttempts[0]['value'];
				
				// NOTE: This will fail if the correct answer has a double quote in it
				if ($gfq->xpath('//answer[@correct="true"][@value="'.$attemptedAnswer.'"]')) {
					$score->scoreCorrect += $this->scoreMultiplier($scoreBand);
				} else {
					$score->scoreWrong++;
				}
			} else {
				$score->scoreSkipped++;
			}
		}
		
		$score->score = round(100 * ($score->scoreCorrect / $potentialScore));
		return json_encode(array('debug' => $debug, 'percentage' => $score->score, 'of' => $numQuestions, 'correct' => $score->scoreCorrect, 'skipped' => $score->scoreSkipped, 'wrong' => $score->scoreWrong));
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
	public function encrypt($data)	{
		$iv_size = mcrypt_get_iv_size(MCRYPT_RIJNDAEL_128, MCRYPT_MODE_CBC);
        $securekey = hash('sha256', 'ClarityLanguageConsultantsLtd', TRUE);
        $iv = mcrypt_create_iv($iv_size);
		return base64_encode($iv . mcrypt_encrypt(MCRYPT_RIJNDAEL_128, $securekey, $data, MCRYPT_MODE_CBC, $iv));
	}
	public function decrypt($data)	{
		$iv_size = mcrypt_get_iv_size(MCRYPT_RIJNDAEL_128, MCRYPT_MODE_CBC);
        $securekey = hash('sha256', 'ClarityLanguageConsultantsLtd', TRUE);
        $input = base64_decode($data);
        $iv = substr($input, 0, $iv_size);
        $cipher = substr($input, $iv_size);
		return trim(mcrypt_decrypt(MCRYPT_RIJNDAEL_128, $securekey, $cipher, MCRYPT_MODE_CBC, $iv));
	}
	function decodeSafeChars($text) {
		return strtr($text, '-_~', '+/=');
	}
	function encodeSafeChars($text) {
		return strtr($text, '+/=', '-_~');
	}
	
}
// To mimic amfphp handling
$doIt = new TB6weeksService();
flush();
exit();