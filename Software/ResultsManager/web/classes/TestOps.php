<?php
class TestOps {

	/**
	 * This class helps with creating and marking tests.
	 * 
	 * TODO Could this all be in ContentOps?
	 * TODO encryption should be in a utility function
	 */
	var $db;
	
	function TestOps($db) {
		$this->db = $db;
		$this->copyOps = new CopyOps();
	}
	
	/**
	 * If you changed the db, you'll need to refresh it here
	 * Not a very neat function...
	 */
	function changeDB($db) {
		$this->db = $db;
	}

	// TODO The content folder should be picked up from the normal way we do this...
	public function getQuestions($exercise) {
	
		// Get the test definition
		$testTemplate = '../../'.$GLOBALS['data_dir'].'/TB6weeks/'.$exercise;
		if (!file_exists($testTemplate))
			throw new Exception($testTemplate." file not found from ".$GLOBALS['data_dir']);
		
		// initialise
		$data = new DOMDocument();
		$test = $data->appendChild($data->createElement('test'));
		$questions = $test->appendChild($data->createElement('questions'));
		$answers = $test->appendChild($data->createElement('config'));
		$debug = $test->appendChild($data->createElement('debug'));
		$answerData = '';
		$newQuestionId = $newBlockId = $newSourceId = 0;
		
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
				// If you are selecting some questions from this question bank
				if ($numberForGroup > 0) {
					$arrayIndexes = range(0, $numOfQbanks-1);
					$useThese = array_rand($arrayIndexes, $numberForGroup);
					for ($i = 0; $i < $numberForGroup; $i++) {
			            $groupQbanks->item($useThese[$i])->setAttribute('use', intval(1));
					}
				}
				
			} else {
				$base = floor($numberForGroup / $numOfQbanks);
				$extra = $numberForGroup % $numOfQbanks;
				foreach ($groupQbanks as $groupQbank) {
					$groupQbank->setAttribute('use', $base);
				}
				// If there are extra to allocate, randomly grab one more from some of the question banks
				if ($extra > 0) {
					$arrayIndexes = range(0, $numOfQbanks-1);
					$useThese = array_rand($arrayIndexes, $extra);
					for ($i = 0; $i < $numberForGroup; $i++) {
			            $groupQbanks->item($useThese[$i])->setAttribute('use', $base+1);
					}
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

			// gh#1170 The placementTest attribute shifts to being on the question tag, so switch all this selection round
			// gh#1030 Pick x questions at random from the bank
			// Get all the valid question nodes and pick x at random
			$query = '//xmlns:questions/*[@block][not(@placementTest) or @placementTest!="false"]';
			$modelNodes = $xmlXPath->query($query);
			$maxQuestions = $modelNodes->length;

			// How to alert if there weren't enough questions to satisfy the number we want? Unlikely, but...
			if ($maxQuestions < 1) {
				$debugNode = $data->createElement('lostQuestions', $numQuestionsToUse);
				$debug->appendChild($debugNode);
				continue;
			} else if ($maxQuestions < $numQuestionsToUse) {
				$debugNode = $data->createElement('lostQuestions', $numQuestionsToUse - $maxQuestions);
				$debug->appendChild($debugNode);
				$numQuestionsToUse = $maxQuestions;
			}
			if ($numQuestionsToUse == 1) {
				// Note that array_rand doesn't return an array if you have a single item
				$useThese = array(array_rand(range(0, $maxQuestions-1), $numQuestionsToUse));
			} else {
				$useThese = array_rand(range(0, $maxQuestions-1), $numQuestionsToUse);
			}

			for ($i = 0; $i < $numQuestionsToUse; $i++) {
				if ($modelNodes->item($useThese[$i])->getAttribute('placementTest') != 'false') {
					// Find the matching content for this question
					$questionId = $modelNodes->item($useThese[$i])->getAttribute('block');
					$contentQuery = '//xmlns:div[@class="question"][@id="' . $questionId . '"]';
					$questionContentNodes = $xmlXPath->query($contentQuery);
					if (!$questionContentNodes)
						continue;
					$questionContent = $questionContentNodes->item(0);

					// Generate new ids for the new document to ensure uniqueness
					$newQuestionId++;
					//$modelNodes->item($useThese[$i])->setAttribute('block', 'b' . $newQuestionId);
					$modelNodes->item($useThese[$i])->setAttribute('block', $newQuestionId);
					$questionContent->setAttribute('id', $newQuestionId);

					// Add the group attribute so that you can figure out complex marking later
					$modelNodes->item($useThese[$i])->setAttribute('scoreBand', $qbGroup);

					//$debugNode = $data->createElement('changingQId', $questionId);
					//$debugNode->setAttribute('newId', 'b'.$newQuestionId);
					//$debug->appendChild($debugNode);

					// MC or GF have different handling for source nodes
					$optionsQuery = "//xmlns:div[@class='question'][@id='" . 'b' . $newQuestionId . "']//xmlns:a";
					$options = $xmlXPath->query($optionsQuery);
					$debugNode = $data->createElement('findQuery', $optionsQuery);
					$debugNode->setAttribute('found', $options->length);
					foreach ($options as $option) {
						$existingId = $option->getAttribute('id');
						$newSourceId++;
						$option->setAttribute('id', 'q' . $newSourceId);

						$modelAnswerQuery = '//xmlns:questions/*[@block="' . 'b' . $newQuestionId . '"]/xmlns:answer';
						$modelAnswers = $xmlXPath->query($modelAnswerQuery);
						foreach ($modelAnswers as $modelAnswer) {
							if ($modelAnswer->getAttribute('source') == $existingId)
								$modelAnswer->setAttribute('source', 'q' . $newSourceId);
						}
					}

					$optionsQuery = "//xmlns:div[@class='question'][@id='" . 'b' . $newQuestionId . "']//xmlns:input";
					$options = $xmlXPath->query($optionsQuery);
					foreach ($options as $option) {
						//$existingId = $gfOption->getAttribute('id');
						$newSourceId++;
						$option->setAttribute('id', 'q' . $newSourceId);
						$modelNodes->item($useThese[$i])->setAttribute('source', 'q' . $newSourceId);
					}

					// Add the modified nodes to the new document
					$question = $data->importNode($questionContent, true);
					$questions->appendChild($question);
					$answerData .= $modelNodes->item($useThese[$i])->ownerDocument->saveXML($modelNodes->item($useThese[$i]));
				}
			}
		}
			
		// encrypt the answers as a CDATA string
		//$encryptedAnswers = $this->encodeSafeChars($answerData);
		$encryptedAnswers = $this->encodeSafeChars($this->encrypt($answerData));
		
		$answers->appendChild($data->createCDATASection($encryptedAnswers));
					 
		// Return the data
		return $data;
	}
	
	public function checkAnswers($attempts, $answers, $score = null) {
		/*
			<MultipleChoiceQuestion block="1">
		      <answer source="a1" correct="true"/>
		      <answer source="a2" correct="false"/>
		      <answer source="a3" correct="false"/>
		      <answer source="a4" correct="false"/>
		    </MultipleChoiceQuestion>
	        <GapFillQuestion source="q26" block="2">
		      <answer value="It's" correct="true"/>
		      <answer value="It is" correct="true"/>
		    </GapFillQuestion>
		    
		    <input class="MultipleChoiceQuestion" id="1" value="a1" />
		    <input class="GapFillQuestion" id="2" value="It's" />
		 */
		
		if (!$score)
			$score = new Score();
			
		$numQuestions = $potentialScore = 0;
		$score->scoreCorrect = $score->scoreMissed = $score->scoreWrong = 0;
		//$weightedScore = 0;
		
		//$answersXmlString = $this->decodeSafeChars($answers);
		$answersXmlString = $this->decrypt($this->decodeSafeChars($answers));
		$answersXml = simplexml_load_string('<answers>'.$answersXmlString.'</answers>');
		$numQuestions = $answersXml->MultipleChoiceQuestion->count() + $answersXml->GapFillQuestion->count();
        AbstractService::$debugLog->info("numQuestions=".$numQuestions);

		if ($numQuestions <= 0)
			return json_encode(array('error' => 'no questions'));
		
		$attemptsXml = simplexml_load_string('<attempts>'.$attempts.'</attempts>');
		$debug = '';

		foreach ($answersXml->MultipleChoiceQuestion as $mcq) {
			$qId = $mcq['block'];
			$scoreBand = $mcq['scoreBand'];
			$potentialScore = $this->scoreMultiplier($scoreBand);

            $thisQuestionAttempts = $attemptsXml->xpath("//input[@id='$qId']");
			// Has the user attempted to answer this question? 
			if ($thisQuestionAttempts && count($thisQuestionAttempts) > 0) {
				$attemptedAnswer = $thisQuestionAttempts[0]['value'];
				
				if ($mcq->xpath('//answer[@correct="true"][@source="'.$attemptedAnswer.'"]')) {
					$score->scoreCorrect += $potentialScore;
				} else {
					$score->scoreWrong += $potentialScore;
				}
			} else {
				$score->scoreMissed += $potentialScore;
			}
		}
		foreach ($answersXml->GapFillQuestion as $gfq) {
			$qId = $gfq['block'];
			$scoreBand = $gfq['scoreBand'];
			$potentialScore = $this->scoreMultiplier($scoreBand);

			$thisQuestionAttempts = $attemptsXml->xpath("//input[@id='$qId']");
			// Has the user attempted to answer this question? 
			if ($thisQuestionAttempts && count($thisQuestionAttempts) > 0) {
				$attemptedAnswer = $thisQuestionAttempts[0]['value'];
				
				// NOTE: This will fail if the correct answer has a double quote in it
				if ($gfq->xpath('//answer[@correct="true"][@value="'.$attemptedAnswer.'"]')) {
					$score->scoreCorrect += $potentialScore;
				} else {
					$score->scoreWrong += $potentialScore;
				}
			} else {
				$score->scoreMissed += $potentialScore;
			}
		}
		
		$score->score = round(100 * ($score->scoreCorrect / ($score->scoreCorrect + $score->scoreWrong + $score->scoreMissed)));
		return $score;
		
	}
	
	/**
	 * This function calculates a student's CEF level based on their score
	 * 
	 * @param Score $score
	 */
	public function getCEFLevel($score, $productCode = null) {
		
		if (!$productCode) $productCode = Session::get('productCode');
		switch ($productCode) {
			case 59:
				if ($score->scoreCorrect < 4)
					return "A1";
				if ($score->scoreCorrect < 7)
					return "A2";
				if ($score->scoreCorrect < 22)
					return "B1";
				if ($score->scoreCorrect < 70)
					return "B2";	
				return "C1";
				break;
			default:
				return "A1";
		}
	}
	/**
	 * This function calculates a student's Clarity level based on their score
	 * 
	 * @param Score $score
	 */
	public function getClarityLevel($score, $productCode = null) {
		
		if (!$productCode) $productCode = Session::get('productCode');
		switch ($productCode) {
			case 59:
				if ($score->scoreCorrect < 4)
					return "ELE";
				if ($score->scoreCorrect < 7)
					return "LI";
				if ($score->scoreCorrect < 22)
					return "INT";
				if ($score->scoreCorrect < 70)
					return "UI";	
				return "ADV";
				break;
			default:
				break;
		}
	}
	
	/**
	 * This function allows questions that are linked to a particular level to carry more weight
	 * @param string $scoreBand
	 */
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

	// gh#1170 Correction process for an editor to mark up questions
	public function correct1170Markup($exercise) {

		// Get the test definition
		$testTemplate = '../../'.$GLOBALS['data_dir'].'/TB6weeks/'.$exercise;
		if (!file_exists($testTemplate))
			throw new Exception($testTemplate." file not found from ".$GLOBALS['data_dir']);

		// initialise
		$data = new DOMDocument();
		$debug = $data->appendChild($data->createElement('debug'));

		$template = new DOMDocument();
		$template->load($testTemplate);
		$templateXPath = new DOMXpath($template);

		// Set the namespace so that xpath can work
		$templateXPath->registerNamespace('xmlns', 'http://www.w3.org/1999/xhtml');

		// Now pick the allocated x questions from each question bank
		$qbNodes = $templateXPath->query("//xmlns:questionBank");
		foreach ($qbNodes as $qb) {

			$questionBankFile = '../../'.$GLOBALS['data_dir'].'/TB6weeks/'.$qb->getAttribute('href');

			if (!file_exists($questionBankFile))
				throw new Exception($questionBankFile." file not found");

			$xml = new DOMDocument();
			$xml->load($questionBankFile);
			$xmlXPath = new DOMXpath($xml);

			// Set the namespace so that xpath can work
			$xmlXPath->registerNamespace('xmlns', 'http://www.w3.org/1999/xhtml');

			// Get all the question nodes that the editor has marked as being good for use in testing
			// Negate them so we know which ones we should ignore
			// Does this markup follow negative or positive settings?
			$query = "//xmlns:div[@class='question'][@placementTest='false']";
			$matchingNodes = $xmlXPath->query($query);
			$negativeMarkup = $matchingNodes->length > 0;

			$query = "//xmlns:div[@class='question']";
			$matchingNodes = $xmlXPath->query($query);
			$changeCount = 0;
			foreach ($matchingNodes as $matchingNode) {

				$isIndependent = $matchingNode->getAttribute('placementTest');
				if ($negativeMarkup) {
					// Look for any questions that are marked and mark their models
					if ($isIndependent == 'false') {
						// Find the matching answer model for this question
						$questionId = $matchingNode->getAttribute('id');
						$modelQuery = '//xmlns:questions/*[@block="' . $questionId . '"]';
						$questionModel = $xmlXPath->query($modelQuery)->item(0);
						if ($questionModel)
							$questionModel->setAttribute('placementTest', 'false');
						$changeCount++;
					}
				} else {
					if (!$isIndependent) {
						// Find the matching answer model for this question
						$questionId = $matchingNode->getAttribute('id');
						$modelQuery = '//xmlns:questions/*[@block="' . $questionId . '"]';
						$questionModel = $xmlXPath->query($modelQuery)->item(0);
						if ($questionModel)
							$questionModel->setAttribute('placementTest', 'false');
						$changeCount++;
					}
				}
				$matchingNode->removeAttribute('placementTest');
			}
			$debugNode = $data->createElement('file', $questionBankFile);
			$debugNode->setAttribute('changes', $changeCount);
			$debugNode->setAttribute('negativeMarkup', $negativeMarkup);
			$debug->appendChild($debugNode);

			// Save the modified file
			$xml->save($questionBankFile);
		}

		// Return the data
		return $data;
	}

}
