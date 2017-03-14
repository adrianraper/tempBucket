<?php
class TestOps {

	/**
	 * This class helps with creating and marking tests.
	 *
     * Merge with TestOps as basically the same thing
	 */
	var $db;
	
	function TestOps($db) {
		$this->db = $db;
		$this->copyOps = new CopyOps();
        $this->manageableOps = new ManageableOps($db);
	}
	
	/**
	 * If you changed the db, you'll need to refresh it here
	 * Not a very neat function...
	 */
	function changeDB($db) {
		$this->db = $db;
	}

    /**
     * Return all tests that this group is scheduled to take
     *  - admin panel will want all
     *  - app will only want active ones, so add overcall
     */ 
	function getActiveTests($groupId, $productCode) {
		return $this->getTests($groupId, $productCode, true);
	}
    function getTests($groupId, $productCode, $justActive = false) {

        $dateStampNow = new DateTime('now', new DateTimeZone(TIMEZONE));
        $dateNow = $dateStampNow->format('Y-m-d H:i:s');

        // We also want any tests that parents of this group are scheduled to take as they will apply to us too
        $groupList = implode(',', $this->manageableOps->getGroupParents($groupId));

        $bindingParams = array($productCode);
        $sql = <<<SQL
			SELECT * FROM T_ScheduledTests 
			WHERE F_GroupID IN ($groupList)
			AND F_ProductCode=?
SQL;
        $rs = $this->db->Execute($sql, $bindingParams);
        //AbstractService::$debugLog->info("got ". $rs->RecordCount()." records for group " . $group->id);
        switch ($rs->RecordCount()) {
            case 0:
                // There are no records
                return false;
            default:
                $tests = array();
                while ($dbObj = $rs->FetchNextObj()) {
                    // Check that the test has not been deleted - only kept in the table for reporting purposes
                    if ($dbObj->F_Status >= ScheduledTest::STATUS_DELETED)
                        continue;
                        
                	// Set the status based on the start and close dates
                	if ($dbObj->F_CloseTime < $dateNow)
                		$dbObj->F_Status = ScheduledTest::STATUS_CLOSED;
                	if ($dateNow >= $dbObj->F_OpenTime && $dbObj->F_CloseTime >= $dateNow)
                		$dbObj->F_Status = ScheduledTest::STATUS_OPEN;
                	
                	// Filter out ones that are not valid to download or start
                	if ($justActive) {
	                    // Check that the test has been released and not yet closed
	                    if ($dbObj->F_Status == ScheduledTest::STATUS_CLOSED || $dbObj->F_Status == ScheduledTest::STATUS_PRERELEASE)
	                        continue;
                	}
                	$tests[] = new ScheduledTest($dbObj);
                }
        }
        return $tests;
    }
    // ctp#173
    function getTest($testId) {
        $bindingParams = array($testId);
        $sql = <<<SQL
			SELECT * FROM T_ScheduledTests 
			WHERE F_TestID=?
SQL;
        $rs = $this->db->Execute($sql, $bindingParams);
        switch ($rs->RecordCount()) {
            case 0:
                return false;
                break;
            case 1:
                $dbObj = $rs->FetchNextObj();
                $test = new ScheduledTest($dbObj);
                break;
            default:
                // Should be impossible
                return false;
        }
        return $test;
    }

    function addTest($test) {
        $dbObj = $test->toAssocArray();
        $this->db->AutoExecute("T_ScheduledTests", $dbObj, "INSERT");
    }
    function updateTest($test) {
        $dbObj = $test->toAssocArray();
        $this->db->AutoExecute("T_ScheduledTests", $dbObj, "UPDATE", 'F_TestID='.$test->testId);
    }
    function deleteTest($test) {
        $bindingParams = array($test->testId);
        $sql = <<<SQL
			DELETE FROM T_ScheduledTests WHERE F_TestID=?
SQL;
        $rc = $this->db->Execute($sql, $bindingParams);
    }

    // This will list all the scheduled tests a user has completed
    function getCompletedTests($userId) {
        $bindingParams = array($userId);
        $sql = <<<SQL
			SELECT * FROM T_TestSession
            WHERE F_UserID = ?
            AND F_CompletedDateStamp is not null 
SQL;
        $rs = $this->db->Execute($sql, $bindingParams);
        switch ($rs->RecordCount()) {
            case 0:
                // There are no records
                return false;
                break;
            default:
                $testSessions = array();
                while ($dbObj = $rs->FetchNextObj())
                    $testSessions[] = new TestSession($dbObj);
        }
        return $testSessions;
    }

    // This function should only be called by the Couloir Password Server
    public function getTestAccessCode($testId) {
        $bindingParams = array($testId);
        $sql = <<<SQL
			SELECT * FROM T_ScheduledTests 
			WHERE F_TestID=?
SQL;
        $rs = $this->db->Execute($sql, $bindingParams);
        switch ($rs->RecordCount()) {
            case 1:
                $test = new ScheduledTest($rs->FetchNextObj());
                return ($test->startType == "code") ? $test->startData : $test->groupId;
            default:
                return false;
        }
    }

    function getTestSession($sessionId) {
        $sql = <<<EOD
			SELECT * 
			FROM T_TestSession
			WHERE F_SessionID=?
EOD;
        $bindingParams = array($sessionId);
        $rs = $this->db->Execute($sql, $bindingParams);
        if ($rs && $rs->RecordCount() > 0) {
            $testSession = new TestSession();
            $testSession->fromDatabaseObj($rs->FetchNextObj());
            return $testSession;
        } else {
            return false;
        }
    }

    function getSessionsForTest($testId) {
	    $sessions = array();
        $sql = <<<EOD
			SELECT * 
			FROM T_TestSession
			WHERE F_TestID=?
            AND F_CompletedDateStamp is not null
EOD;
        $bindingParams = array($testId);
        $rs = $this->db->Execute($sql, $bindingParams);
        if ($rs && $rs->RecordCount() > 0)
            while ($dbObj = $rs->FetchNextObj()) {
                $testSession = new TestSession();
                $testSession->fromDatabaseObj($dbObj);
                $sessions[] = $testSession;
            }
	    return $sessions;
    }

    // ctp#261 Find the first real score written for this session (so not including requirements)
    public function getFirstScore($sessionId) {
	    // This works because the first 'exercise' in gauge is the instructions. You get a score
        // record for when you have finished reading that (submit), which is almost perfect for when you actually start.
        // It is (as of DPT launch) much quicker to read T_ScoreDetail than T_Score
        $gaugeUnitID = '2015063020001';
        $sql = <<<EOD
			SELECT * 
			FROM T_ScoreDetail
			WHERE F_SessionID=?
			AND F_UnitID=?
            ORDER BY F_DateStamp asc
            LIMIT 0,1
EOD;
        $bindingParams = array($sessionId, $gaugeUnitID);
        $rs = $this->db->Execute($sql, $bindingParams);
        if ($rs && $rs->RecordCount() > 0){
            $dbObj = $rs->FetchNextObj();
            $score = new ScoreDetail();
            $score->fromDatabaseObj($dbObj);
        } else {
            $score = null;
        }
        return $score;
    }

    // ctp#261 Find the last score written for this session
    // ctp#383
    public function getLastScore($sessionId) {
        // TODO make sure that it is not too time consuming to read T_Score like this as a very big table
        $sql = <<<EOD
			SELECT * 
			FROM T_Score
			WHERE F_SessionID=?
            ORDER BY F_DateStamp desc
            LIMIT 0,1
EOD;
        $bindingParams = array($sessionId);
        $rs = $this->db->Execute($sql, $bindingParams);
        if ($rs && $rs->RecordCount() > 0){
            $dbObj = $rs->FetchNextObj();
            $score = new ScoreDetail();
            $score->fromDatabaseObj($dbObj);
        } else {
            $score = null;
        }
        return $score;
    }

    // The rest of the class is related to Bento
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
                // TODO I think this check is obsolete since already filtered against this attribute...
				if ($modelNodes->item($useThese[$i])->getAttribute('placementTest') != 'false') {
					// Find the matching content for this question
					$questionId = $modelNodes->item($useThese[$i])->getAttribute('block');
					$contentQuery = '//xmlns:div[@class="question"][@id="' . $questionId . '"]';
					$questionContentNodes = $xmlXPath->query($contentQuery);
					if (!$questionContentNodes)
						continue;
					$questionContent = $questionContentNodes->item(0);

                    // If this is a gapfill, set the length of the input to roughly the length of the answer
                    $inputQuery = '//xmlns:div[@class="question"][@id="' . $questionId . '"]//xmlns:input';
                    $inputNodes = $xmlXPath->query($inputQuery);
                    if ($inputNodes) {
                        $inputTag = $inputNodes->item(0);
                        if ($inputTag) {
                            $answerQuery = '//xmlns:questions/*[@block="' . $questionId . '"]//xmlns:answer';
                            $answerNodes = $xmlXPath->query($answerQuery);
                            $maxAnswerSize = 0;
                            if ($answerNodes) {
                                foreach ($answerNodes as $answerNode) {
                                    $thisAnswerSize = strlen($answerNode->getAttribute('value'));
                                    $maxAnswerSize = ($thisAnswerSize > $maxAnswerSize) ? $thisAnswerSize : $maxAnswerSize;
                                }
                            }
                            // Reduce by 2 for a browser, but this is too short for iPad
                            // Switch to width rather than size?
                            //$inputTag->setAttribute('size', $maxAnswerSize);
                            // 4 is a reasonable smallest answer. It is a rather long in a browser but OK in iPad.
                            // But using width ends up doubled necessary width by the time you get to 10.
                            if ($maxAnswerSize <= 4) {
                                $useWidth = 4;
                            } else
                            if ($maxAnswerSize <= 10) {
                                $useWidth = $maxAnswerSize * 2 / 3;
                            } else {
                                $useWidth = $maxAnswerSize / 2;
                            }
                            $inputTag->setAttribute('style', 'width: '.$useWidth.'em;');
                        }
                    }

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
					//$debugNode = $data->createElement('findQuery', $optionsQuery);
					//$debugNode->setAttribute('found', $options->length);
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

    // TODO These should surely be in a utility class
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
