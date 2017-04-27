<?php

class Model {
	
	//protected $model;
	protected $type;
    protected $questions = array();
    protected $feedback = array();
    protected $marking = null;

	protected $parent;
	function getParent() {
		return $this->parent;
	}
	function setParent($object) {
		$this->parent = $object;
	}
		
	function __construct($parent=null) {
		// Keep a reference back to the exercise we are part of
		if ($parent) {
			$this->setParent($parent);
			$this->type = $parent->getType();
		}
/*
		$xmlstr = <<<XML
<script id="model" type="application/json">
</script>
XML;
		$this->model = new SimpleXMLElement($xmlstr);
*/
		/*
		$this->model->addChild('settings');
		$this->model->settings->addChild('param');
		$this->model->settings->param->addAttribute('name', 'delayedMarking');
        */
	}
	
	// Get ready for questions in the model
	function prepareQuestions() {
		// check to see if the questions node already exists
		//if (!$this->model->questions) {
		//	$stuff = $this->model->addChild('questions');
		//}
		// For a drag and drop, the questions have their source as the drops and their answer source as the drags
		//echo "Model qbased=".$this->getParent()->isQuestionBased();
		if ($this->type == Exercise::EXERCISE_TYPE_DRAGANDDROP && !$this->getParent()->isQuestionBased()) {
			foreach ($this->getParent()->body->getFields() as $field) {
				// TODO You should be adding a ModelQuestion type here, not just an array
				$newQ = $this->model->questions->addChild("DragQuestion");
				$newQ->addAttribute('source','q'.$field->getID());
				$newQ->addAttribute('block','b'.$field->getID());
				foreach ($field->getAnswers() as $answer) {
					$newA = $newQ->addChild('answer');
					$matchingID = 'unknown';
					// This is the correct answer for the drop. 
					// We need to find the id of the drag that matches this and use that rather than duplicate the answer.
					$thisAnswerText = $answer->getAnswer();
					//echo "\ntry to match $thisAnswerText";
					if ($this->getParent()->noscroll) {
						foreach ($this->getParent()->noscroll->getFields() as $dragField) {
							//echo "\nlook at field ".$dragField->getID();
							foreach ($dragField->getAnswers() as $dragAnswer) {
								//echo "\ncompare $thisAnswerText and ".$dragAnswer->getAnswer();
								if ($dragAnswer->getAnswer()==$thisAnswerText) {
									$matchingID = $dragField->getID();
									//echo "match $matchingID so quit loops";
									continue 2;
								} else {
									//echo 'not match';
								}
							}
						}
					}
					//echo 'and add to the answer';
					$newA->addAttribute('source','a'.$matchingID);
					$newA->addAttribute('correct',$answer->isCorrect() ? 'true' : 'false');
				}
				//echo $newQ;
				// Is there any feedback to be added to the model related to this field?
				// NOTE: This code assumes that there is only one answer in the field 
				if (count($field->getAnswers()==1) && $this->getParent()->feedbacks) {
					foreach ($this->getParent()->feedbacks->getFeedbacks() as $feedback) {
						// Is this feedback for this field?
						if ($feedback->getID()==$field->getID()) {
							$newFB = $newA->addChild('feedback');	
							$newFB->addAttribute('source','fb'.$field->getID());
							break;
						}
					}
				}
			}
		} elseif ($this->type==Exercise::EXERCISE_TYPE_DRAGANDDROP && $this->getParent()->isQuestionBased()) {
			// Each question has its own fields
			foreach ($this->getParent()->body->getQuestions() as $question) {
				//$newQ = $this->model->questions->addChild("DragQuestion");
				$newQ = new ModelDragQuestion($this);

				//$newQ->addAttribute('source',$field->getID());
				// Whilst you can get the group from the field, you can also get it from the question
				// Ideally we would match to make sure they are the same
				//$newQ->addAttribute('group',$field->group);
                $newQ->addSource($question->getID());
				// TODO assume there is only one block per exercise
                $newQ->addBlock('b1');
                $newQ->addDraggables('#b1 .draggables');
				// Each field in the body lists the correct answer. You need to match these
				// against the answers in the fields in noscroll to get the answer source id
				foreach ($question->getFields() as $field) {
					// Only ever 1 answer per field
					foreach ($field->getAnswers() as $answer) {
						//$newA = $newQ->addChild('answer');
						$newA = new ModelAnswer();
						// Which drag does this match with?
						//echo "check drop field answer ".$answer->getAnswer().' ';
						foreach ($this->getParent()->noscroll->getFields() as $dragField) {
							foreach ($dragField->getAnswers() as $dragAnswer) {
								//echo "against ".$dragAnswer->getAnswer().' ';
								if ($answer->getAnswer()==$dragAnswer->getAnswer()) {
									$foundID=$dragField->getID();
									break 2;
								}
							}
						}
						if ($foundID) {
							$newA->addSource($foundID);
							$newA->addCorrect(($answer->isCorrect()) ? 'true' : 'false');
						}
						$newQ->addAnswer($newA);
					}
					//echo $newQ;
					// Is there any feedback to be added to the model related to this field?
					// NOTE: This code assumes that there is only one answer in the field 
					if (count($field->getAnswers()==1) && $this->getParent()->feedbacks) {
						foreach ($this->getParent()->feedbacks->getFeedbacks() as $feedback) {
							// Is this feedback for this field?
							if ($feedback->getID()==$field->getID()) {
								//$newFB = $newA->addChild('feedback');
								//$newFB->addAttribute('source','fb'.$field->getID());
                                $newQ->addFeedback($field->getID());
								break;
							}
						}
					}
				}
                $questions[] = $newQ;
            }
		// For a gapfill, the questions have their source as the gaps
		} elseif ($this->type==Exercise::EXERCISE_TYPE_GAPFILL && $this->getParent()->isQuestionBased()) {
			// Each question has its own fields
			foreach ($this->getParent()->body->getQuestions() as $question) {
				$newQ = $this->model->questions->addChild("GapFillQuestion");
				$newQ->addAttribute('source','q'.$question->getID());
				// Whilst you can get the group from the field, you can also get it from the question
				// Ideally we would match to make sure they are the same
				//$newQ->addAttribute('block','b'.$question->getID());
				foreach ($question->getFields() as $field) {
					// You can have multiple answers per field
					// they should all have the same group id
					$newQ->addAttribute('block','b'.$field->group);
					foreach ($field->getAnswers() as $answer) {
						$newA = $newQ->addChild('answer');
						//$newA->addAttribute('source','a'.$field->getID());
						$newA->addAttribute('value',$answer->getAnswer());
						$newA->addAttribute('correct',$answer->isCorrect() ? 'true' : 'false');
					}
					//echo $newQ;
					// Is there any feedback to be added to the model related to this field?
					// NOTE: This code assumes that there is only one answer in the field 
					if (count($field->getAnswers()==1) && $this->getParent()->feedbacks) {
						foreach ($this->getParent()->feedbacks->getFeedbacks() as $feedback) {
							// Is this feedback for this field?
							if ($feedback->getID()==$field->getID()) {
								$newFB = $newA->addChild('feedback');	
								$newFB->addAttribute('source','fb'.$field->getID());
								break;
							}
						}
					}
				}
			}
			
		} elseif ($this->type==Exercise::EXERCISE_TYPE_GAPFILL && !$this->getParent()->isQuestionBased()) {
			foreach ($this->getParent()->body->getFields() as $field) {
				
				$newQ = $this->model->questions->addChild("GapFillQuestion");
				$newQ->addAttribute('source','q'.$field->getID());
				$newQ->addAttribute('block','b'.$field->group);
				//$newQ->addAttribute('group',$field->group);
				foreach ($field->getAnswers() as $answer) {
					$newA = $newQ->addChild('answer');
					$newA->addAttribute('value',$answer->getAnswer());
					$newA->addAttribute('correct',$answer->isCorrect() ? 'true' : 'false');
				}
				//echo $newQ;
				// Is there any feedback to be added to the model related to this field?
				// NOTE: This code assumes that there is only one answer in the field 
				if (count($field->getAnswers()==1) && $this->getParent()->feedbacks) {
					foreach ($this->getParent()->feedbacks->getFeedbacks() as $feedback) {
						// Is this feedback for this field?
						if ($feedback->getID()==$field->getID()) {
							$newFB = $newA->addChild('feedback');	
							$newFB->addAttribute('source','fb'.$field->getID());
							break;
						}
					}
				}
			}
		// For a dropdown, the questions have their source as the gaps
		} elseif ($this->type==Exercise::EXERCISE_TYPE_DROPDOWN && !$this->getParent()->isQuestionBased()) {
			$generateID=1;
			foreach ($this->getParent()->body->getFields() as $field) {
				
				$newQ = $this->model->questions->addChild("DropDownQuestion");
				$newQ->addAttribute('source','q'.$field->getID());
				$newQ->addAttribute('block','b'.$field->group);
				foreach ($field->getAnswers() as $answer) {
					$newA = $newQ->addChild('answer');
					//$newA->addAttribute('value',$answer->getAnswer());
					$newA->addAttribute('source','a'.$generateID++);
					$newA->addAttribute('correct',$answer->isCorrect() ? 'true' : 'false');
				}
				//echo $newQ;
				// Is there any feedback to be added to the model related to this field?
				// NOTE: This code assumes that there is only one answer in the field 
				if (count($field->getAnswers()==1) && $this->getParent()->feedbacks) {
					foreach ($this->getParent()->feedbacks->getFeedbacks() as $feedback) {
						// Is this feedback for this field?
						if ($feedback->getID()==$field->getID()) {
							$newFB = $newA->addChild('feedback');	
							$newFB->addAttribute('source','fb'.$field->getID());
							break;
						}
					}
				}
			}
		} elseif ($this->type==Exercise::EXERCISE_TYPE_DROPDOWN && $this->getParent()->isQuestionBased()) {
			// Each question has its own fields
			$generateID=1;
			foreach ($this->getParent()->body->getQuestions() as $question) {
				$newQ = $this->model->questions->addChild("DropDownQuestion");
				// Whilst you can get the group from the field, you can also get it from the question
				// Ideally we would match to make sure they are the same
				//$newQ->addAttribute('group',$field->group);
				$newQ->addAttribute('source','q'.$question->getID());
				foreach ($question->getFields() as $field) {
					$newQ->addAttribute('block','b'.$field->group);
					foreach ($field->getAnswers() as $answer) {
						$newA = $newQ->addChild('answer');
						//$newA->addAttribute('source','a'.$field->getID());
						$newA->addAttribute('source','a'.$generateID++);
						$newA->addAttribute('correct',$answer->isCorrect() ? 'true' : 'false');
					}
					//echo $newQ;
					// Is there any feedback to be added to the model related to this field?
					// NOTE: This code assumes that there is only one answer in the field 
					if (count($field->getAnswers()==1) && $this->getParent()->feedbacks) {
						foreach ($this->getParent()->feedbacks->getFeedbacks() as $feedback) {
							// Is this feedback for this field?
							if ($feedback->getID()==$field->getID()) {
								$newFB = $newA->addChild('feedback');	
								$newFB->addAttribute('source','fb'.$field->getID());
								break;
							}
						}
					}
				}
			}
			
		// For a targetspotting, the questions have their source as the gaps
		} elseif ($this->type==Exercise::EXERCISE_TYPE_ERRORCORRECTION && !$this->getParent()->isQuestionBased()) {
			foreach ($this->getParent()->body->getFields() as $field) {
				
				$newQ = $this->model->questions->addChild("ErrorCorrectionQuestion");
				$newQ->addAttribute('source','q'.$field->getID());
				$newQ->addAttribute('block','b'.$field->group);
				foreach ($field->getAnswers() as $answer) {
					$newA = $newQ->addChild('answer');
					$newA->addAttribute('value',$answer->getAnswer());
					$newA->addAttribute('correct',$answer->isCorrect() ? 'true' : 'false');
					// Is there any feedback to be added to the model related to this answer?
				}
				//echo $newQ;
				// Is there any feedback to be added to the model related to this field?
				// NOTE: This code assumes that there is only one answer in the field 
				if (count($field->getAnswers()==1) && $this->getParent()->feedbacks) {
					foreach ($this->getParent()->feedbacks->getFeedbacks() as $feedback) {
						// Is this feedback for this field?
						if ($feedback->getID()==$field->getID()) {
							$newFB = $newA->addChild('feedback');	
							$newFB->addAttribute('source','fb'.$field->getID());
							break;
						}
					}
				}
			}
		} elseif ($this->type==Exercise::EXERCISE_TYPE_ERRORCORRECTION && $this->getParent()->isQuestionBased()) {
			// Each question has its own fields
			foreach ($this->getParent()->body->getQuestions() as $question) {
				$newQ = $this->model->questions->addChild("ErrorCorrectionQuestion");
				// Whilst you can get the group from the field, you can also get it from the question
				// Ideally we would match to make sure they are the same
				$newQ->addAttribute('source','q'.$question->getID());
				foreach ($question->getFields() as $field) {
					// You can have multiple answers per field
					// they should all have the same group id
					$newQ->addAttribute('block','b'.$field->group);
					foreach ($field->getAnswers() as $answer) {
						$newA = $newQ->addChild('answer');
						//$newA->addAttribute('source','a'.$field->getID());
						$newA->addAttribute('source',$answer->getAnswer());
						$newA->addAttribute('correct',$answer->isCorrect() ? 'true' : 'false');
					}
					//echo $newQ;
					// Is there any feedback to be added to the model related to this field?
					// NOTE: This code assumes that there is only one answer in the field 
					if (count($field->getAnswers()==1) && $this->getParent()->feedbacks) {
						foreach ($this->getParent()->feedbacks->getFeedbacks() as $feedback) {
							// Is this feedback for this field?
							if ($feedback->getID()==$field->getID()) {
								$newFB = $newA->addChild('feedback');	
								$newFB->addAttribute('source','fb'.$field->getID());
								break;
							}
						}
					}					
				}
			}
		// For a targetspotting, the questions have their source as the gaps
		} elseif ($this->type==Exercise::EXERCISE_TYPE_TARGETSPOTTING && !$this->getParent()->isQuestionBased()) {
			foreach ($this->getParent()->body->getFields() as $field) {
				
				$newQ = $this->model->questions->addChild("TargetSpottingQuestion");
				//$newQ->addAttribute('source','t'.$field->getID());
				$newQ->addAttribute('block','b'.$field->group);
				foreach ($field->getAnswers() as $answer) {
					$newA = $newQ->addChild('answer');
					$newA->addAttribute('source','t'.$field->getID());
					$newA->addAttribute('correct',$answer->isCorrect() ? 'true' : 'false');
				}
				//echo $newQ;
				// Is there any feedback to be added to the model related to this field?
				// NOTE: This code assumes that there is only one answer in the field 
				if (count($field->getAnswers()==1) && $this->getParent()->feedbacks) {
					foreach ($this->getParent()->feedbacks->getFeedbacks() as $feedback) {
						// Is this feedback for this field?
						if ($feedback->getID()==$field->getID()) {
							$newFB = $newA->addChild('feedback');	
							$newFB->addAttribute('source','fb'.$field->getID());
							break;
						}
					}
				}
			}
		} elseif ($this->type==Exercise::EXERCISE_TYPE_TARGETSPOTTING && $this->getParent()->isQuestionBased()) {
			// Each question has its own fields
			foreach ($this->getParent()->body->getQuestions() as $question) {
				$newQ = $this->model->questions->addChild("TargetSpottingQuestion");
				// Whilst you can get the group from the field, you can also get it from the question
				// Ideally we would match to make sure they are the same
				$newQ->addAttribute('source','t'.$question->getID());
				foreach ($question->getFields() as $field) {
					// You can have multiple answers per field
					// they should all have the same group id
					$newQ->addAttribute('block','b'.$field->group);
					foreach ($field->getAnswers() as $answer) {
						$newA = $newQ->addChild('answer');
						//$newA->addAttribute('source','a'.$field->getID());
						$newA->addAttribute('source',$answer->getAnswer());
						$newA->addAttribute('correct',$answer->isCorrect() ? 'true' : 'false');
					}
					//echo $newQ;
					// Is there any feedback to be added to the model related to this field?
					// NOTE: This code assumes that there is only one answer in the field 
					if (count($field->getAnswers()==1) && $this->getParent()->feedbacks) {
						foreach ($this->getParent()->feedbacks->getFeedbacks() as $feedback) {
							// Is this feedback for this field?
							if ($feedback->getID()==$field->getID()) {
								$newFB = $newA->addChild('feedback');	
								$newFB->addAttribute('source','fb'.$field->getID());
								break;
							}
						}
					}
				}
			}
		// For a multiple choice, the questions have their source as the gaps and blocks
		} elseif ($this->type==Exercise::EXERCISE_TYPE_MULTIPLECHOICE ||
					$this->type==Exercise::EXERCISE_TYPE_QUIZ) {
			// Each question has its own fields
			foreach ($this->getParent()->body->getQuestions() as $question) {
				$newQ = $this->model->questions->addChild("MultipleChoiceQuestion");
                // TODO assume there is only one block per exercise
				$newQ->addAttribute('block','q1');
				foreach ($question->getFields() as $field) {
				
					// Only ever 1 answer per field
					foreach ($field->getAnswers() as $answer) {
						$newA = $newQ->addChild('answer');
						$newA->addAttribute('source','a'.$field->getID());
						$newA->addAttribute('correct',$answer->isCorrect() ? 'true' : 'false');
					}
					//echo $newQ;
					// Is there any feedback to be added to the model related to this field?
					// NOTE: This code assumes that there is only one answer in the field 
					if (count($field->getAnswers()==1) && $this->getParent()->feedbacks) {
						foreach ($this->getParent()->feedbacks->getFeedbacks() as $feedback) {
							// Is this feedback for this field?
							if ($feedback->getID()==$field->getID()) {
								$newFB = $newA->addChild('feedback');	
								$newFB->addAttribute('source','fb'.$field->getID());
								break;
							}
						}
					}
				}
			}
		} 
	}
	// If there is score based feedback this will prep the model
	function prepareFeedback() {
        foreach ($this->getParent()->feedbacks->getFeedbacks() as $feedback) {
            $newFB = new ModelFeedback();
            $newFB->addTarget($feedback->getID());
            $this->feedback[] = $newFB;
        }
    }

	// For output to xhtml
	function output() {
        $buildText = '<script id="model" type="application/json">';
        $buildText .= json_encode($this);
        $buildText .= '</script>';
        return $buildText;

        /*
		$buildObj = array();
        $buildObj['marking'] = ($this->getParent()->settings->getSettingValue('marking', 'instant')) ? "instant" : "delayed";

		$buildObj['questions'] = array();
		foreach ($this->model->questions->children() as $question) {
		    // I guess a question should have an outputToCouloir formatter to do this
		    $question =
		    $qObj = array();
		    $qObj['id'] = 'xxxx';
		    $qObj['questionType'] = $question->questionType;
		    $qObj['source'] = '#'.$question['source'];
            $qObj['block'] = '#'.$question['block'];
            $qObj['draggables'] = '#'.$question['block'].' .draggables';
            $qObj['answers'] = array();
            $aObj = array();
            $aObj['source'] = '#'.$question->answer['source'];
            $aObj['correct'] = true;
            // If the answer has feedback, put that in the question
            if (isset($question->answer['feedback'])) {
                $qObj['feedback'] = $question->answer['feedback']['source'];
            }
            $qObj['answers'][] = $aObj;
            $buildObj['questions'][] = $qObj;
        }

        if ($this->model->feedback) {
            $buildObj['feedback'] = array();
            foreach ($this->model->feedback as $feedback) {
                $fObj = array();
                $fObj['target'] = '#fb0';
                $fObj['expr'] = true;
                $buildObj['feedback'][] = $fObj;
            }
        }
        */
	}
	// A utility function to describe the object
	function toString() {
		//$this->nodes->script->addAttribute("bug", "bad");
		//echo "model to string";
		global $newline;
		return $newline.str_replace('<?xml version="1.0"?'.'>','',$this->model->asXML());
	}
}
?>
