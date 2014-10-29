<?php
class TestOps {

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
		return $data;
	}
	
	public function checkAnswers($attempts, $answers, $score = null) {
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
		
		if (!$score)
			$score = new Score();
			
		$numQuestions = $potentialScore = 0;
		$score->scoreCorrect = $score->scoreMissed = $score->scoreWrong = 0;
		//$weightedScore = 0;
		
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
	 * This method is called to insert a session record when a user starts a program
	 */
	function startSession($user, $rootID, $productCode, $dateNow = null) {
		// For teachers we will set rootID to -1 in the session record, so, are you a teacher?
		// Or more specifically are you NOT a student
		if (!$user->userType == 0)
			$rootID = -1;
		
		$dateStampNow = new DateTime('now', new DateTimeZone(TIMEZONE));
		$dateNow = $dateStampNow->format('Y-m-d H:i:s');
		$dateSoon = $dateStampNow->modify('+15 seconds')->format('Y-m-d H:i:s');
		
		$sql = <<<SQL
			INSERT INTO T_Session (F_UserID, F_StartDateStamp, F_EndDateStamp, F_Duration, F_RootID, F_ProductCode)
			VALUES (?, ?, ?, 15, ?, ?)
SQL;

		// We want to return the newly created F_SessionID (or the SQL error)
		$bindingParams = array($user->userID, $dateNow, $dateSoon, $rootID, $productCode);
		$rs = $this->db->Execute($sql, $bindingParams);
		if ($rs) {
			$sessionID = $this->db->Insert_ID();
			if ($sessionID) {
				return $sessionID;
			} else {
				// The database probably doesn't support the Insert_ID function
				throw $this->copyOps->getExceptionForId("errorCantFindAutoIncrementSessionId");
			}
		} else {
			throw $this->copyOps->getExceptionForId("errorDatabaseWriting");
		}
	}
	
	/**
	 * This function will create a starting point (course and unit) based on your test score
	 * 
	 * @param Score $score
	 */
	public function getDirectStart($score) {

		// raw score is out of 75
		if ($score->scoreCorrect < 7) {
			$course = '1189057932446';
			$unit = '1192013076011'; // Am, is, are
		} elseif ($score->scoreCorrect < 22) {
			$course = '1189060123431';
			$unit = '1192625080479'; // Simple present
		} elseif ($score->scoreCorrect < 40) {
			$course = '1195467488046';
			$unit = '1195467532331'; // The passive
		} elseif ($score->scoreCorrect < 60) {
			$course = '1190277377521';
			$unit = '1192625319203'; // Past continuous
		} else {
			$course = '1196935701119';
			$unit = '1196216926895'; // Reported speech
		}
			
		return '<startingPoint course="'.$course.'" unit="'.$unit.'" />';
	}
	
	/**
	 * This function calculates a student's CEF level based on their score
	 * 
	 * @param Score $score
	 */
	public function getCEFLevel($score) {
		
		if ($score->scoreCorrect < 4)
			return "A1";
		if ($score->scoreCorrect < 7)
			return "A2";
		if ($score->scoreCorrect < 22)
			return "B1";
		if ($score->scoreCorrect < 70)
			return "B2";	
		return "C1";
	}
	/**
	 * This function calculates a student's Clarity level based on their score
	 * 
	 * @param Score $score
	 */
	public function getLevel($score, $productCode) {
		
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