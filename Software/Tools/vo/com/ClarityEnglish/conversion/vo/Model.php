<?php

class Model {
	
	//protected $model;
	protected $type;
    protected $questions = array();
    protected $feedback = array();
    protected $marking = null;
    var $newline = "\n";

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
		if ($this->type == "presentation")
			$this->marking = null;
		else
			$this->marking = ($this->getParent()->settings->getSettingValue('marking', 'instant')) ? "instant" : "delayed";
	}

    // Group based feedback is one per question, not one per field
    function isGroupBased() {
	    return $this->getParent()->settings->getSettingValue('feedback', 'groupBased');
    }
    function hasReadingText() {
        return $this->getParent()->settings->getSettingValue('feedback', 'groupBased');
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
                $newQ = new ModelDragQuestion($this);
                $newQ->addSource($field->getID());
                $newQ->addBlock('1');
                $newQ->addDraggables('#b1 .draggables');
                foreach ($field->getAnswers() as $answer) {
                    //$newA = $newQ->addChild('answer');
                    $newA = new ModelAnswer();
                    // Which drag does this match with?
                    //echo "check drop field answer ".$answer->getAnswer().' ';
                    foreach ($this->getParent()->noscroll->getFields() as $dragField) {
                        foreach ($dragField->getAnswers() as $dragAnswer) {
                            if ($answer->getAnswer()==$dragAnswer->getAnswer()) {
                                $foundID=$dragField->getID();
                                break 2;
                            }
                        }
                    }
                    if ($foundID) {
                        $newA->addSource($foundID);
                        // sss#6
                        $newA->addCorrect(($answer->isCorrect()) ? true : false);
                    }
                    $newQ->addAnswer($newA);
                }
				if (count($field->getAnswers())==1 && $this->getParent()->feedbacks) {
					foreach ($this->getParent()->feedbacks->getFeedbacks() as $feedback) {
						// Is this feedback for this field?
                        if ($feedback->getID()==$field->getID()) {
                            $newQ->addFeedback($field->getID());
                            break;
                        }
					}
				}
				
            $this->questions[] = $newQ;
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
                $newQ->addBlock('1');
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
                            // sss#6
							$newA->addCorrect(($answer->isCorrect()) ? true : false);
						}
						$newQ->addAnswer($newA);
					}
					//echo $newQ;
					// Is there any feedback to be added to the model related to this field?
					// NOTE: This code assumes that there is only one answer in the field 
					if (count($field->getAnswers())==1 && $this->getParent()->feedbacks) {
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
                $this->questions[] = $newQ;
            }
		// For a gapfill, the questions have their source as the gaps
		} elseif ($this->type==Exercise::EXERCISE_TYPE_GAPFILL && $this->getParent()->isQuestionBased()) {
			// Each question has its own fields
			foreach ($this->getParent()->body->getQuestions() as $question) {
                $newQ = new ModelGapfillQuestion($this);
                $newQ->addSource($question->getID());
                $newQ->addBlock('1');
				foreach ($question->getFields() as $field) {
					// You can have multiple answers per field
					// they should all have the same group id
					//$newQ->addAttribute('block','b'.$field->group);
					foreach ($field->getAnswers() as $answer) {
                        $newA = new ModelAnswer();
                        $newA->addValue($answer->getAnswer());
                        $newA->addCorrect($answer->isCorrect() ? true : false);
                        $newQ->addAnswer($newA);
					}
                    if (count($field->getAnswers()==1) && $this->getParent()->feedbacks) {
                        foreach ($this->getParent()->feedbacks->getFeedbacks() as $feedback) {
                            // Is this feedback for this field?
                            if ($feedback->getID()==$field->getID()) {
                                $newQ->addFeedback($field->getID());
                                break;
                            }
                        }
                    }
				}
                $this->questions[] = $newQ;
			}
			
		} elseif ($this->type==Exercise::EXERCISE_TYPE_GAPFILL && !$this->getParent()->isQuestionBased()) {
			foreach ($this->getParent()->body->getFields() as $field) {

                $newQ = new ModelGapfillQuestion($this);
                $newQ->addSource($field->getID());
                $newQ->addBlock('1');
				//$newQ->addAttribute('group',$field->group);
				foreach ($field->getAnswers() as $answer) {
                    $newA = new ModelAnswer();
                    $newA->addValue($answer->getAnswer());
                    $newA->addCorrect($answer->isCorrect() ? true : false);
                    $newQ->addAnswer($newA);
				}
				if (count($field->getAnswers()==1) && $this->getParent()->feedbacks) {
					foreach ($this->getParent()->feedbacks->getFeedbacks() as $feedback) {
						// Is this feedback for this field?
                        if ($feedback->getID() == $field->getID()) {
                            $newQ->addFeedback($field->getID());
                            break;
                        }
					}
				}
                $this->questions[] = $newQ;
			}


		// For a dropdown, the questions have their source as the gaps
		} elseif ($this->type==Exercise::EXERCISE_TYPE_DROPDOWN && !$this->getParent()->isQuestionBased()) {
            foreach ($this->getParent()->body->getFields() as $field) {
                $newQ = new ModelDropdownQuestion($this);
                $newQ->addBlock('1');
				$newQ->addSource($field->getID());
                $answers = $field->getAnswers();
                for ($j = 0; $j < count($answers); $j++) {
                    $newA = new ModelAnswer();
                    $newA->addSourceNthChild($field->getID(), $j + 1, 'option');
                    // sss#6
                    $newA->addCorrect($answers[$j]->isCorrect() ? true : false);
                    $newQ->addAnswer($newA);
                }

                if (!$this->isGroupBased() && $this->getParent()->feedbacks) {
                    foreach ($this->getParent()->feedbacks->getFeedbacks() as $feedback) {
                        // Is this feedback for this field?
                        if ($feedback->getID() == $field->getID()) {
                            $newQ->addFeedback($field->getID());
                            break;
                        }
                    }
                }
				$this->questions[] = $newQ;
            }
            if ($this->isGroupBased() && $this->getParent()->feedbacks) {
                foreach ($this->getParent()->feedbacks->getFeedbacks() as $feedback) {
                    // Is this feedback for this field?
                    if ($feedback->getID()==$field->getID()) {
                        $newQ->addFeedback($field->getID());
                        break;
                    }
                }
            }

            

		} elseif ($this->type==Exercise::EXERCISE_TYPE_DROPDOWN && $this->getParent()->isQuestionBased()) {
			// Each question has its own fields
			$generateID=1;
			foreach ($this->getParent()->body->getQuestions() as $question) {
                $newQ = new ModelDropdownQuestion($this);
                $newQ->addBlock($question->getID(), 'q');
                $fields = $question->getFields();
                for ($i=0; $i < count($fields); $i++) {
                    $answers = $fields[$i]->getAnswers();
                    for ($j=0; $j < count($answers); $j++) {
                        $newA = new ModelAnswer();
                        $newA->addSourceNthChild($question->getID(), $j + 1, 'option');
                        // sss#6
                        $newA->addCorrect($answers[$j]->isCorrect() ? true : false);
                        $newQ->addAnswer($newA);
                    }

                    if (!$this->isGroupBased() && $this->getParent()->feedbacks) {
                        foreach ($this->getParent()->feedbacks->getFeedbacks() as $feedback) {
                            // Is this feedback for this field?
                            if ($feedback->getID()==$fields[$i]->getID()) {
                                $newQ->addFeedback($fields[$i]->getID());
                                break;
                            }
                        }
                    }
				}
                if ($this->isGroupBased() && $this->getParent()->feedbacks) {
                    foreach ($this->getParent()->feedbacks->getFeedbacks() as $feedback) {
                        // Is this feedback for this field?
                        if ($feedback->getID()==$question->getID()) {
                            $newQ->addFeedback($question->getID());
                            break;
                        }
                    }
                }

                $this->questions[] = $newQ;
			}
			
		//
		} elseif ($this->type==Exercise::EXERCISE_TYPE_ERRORCORRECTION && !$this->getParent()->isQuestionBased()) {
            foreach ($this->getParent()->body->getFields() as $field) {

                $newQ = new ModelErrorCorrectionQuestion($this);
                $newQ->addSource($field->getID());
                $newQ->addBlock('1');
                foreach ($field->getAnswers() as $answer) {
                    $newA = new ModelAnswer();
                    $newA->addValue($answer->getAnswer());
                    $newA->addCorrect($answer->isCorrect() ? true : false);
                    $newQ->addAnswer($newA);
                }
                if ($this->getParent()->feedbacks) {
                    foreach ($this->getParent()->feedbacks->getFeedbacks() as $feedback) {
                        // Is this feedback for this field?
                        if ($feedback->getID() == $field->getID()) {
                            $newQ->addFeedback($field->getID());
                            break;
                        }
                    }
                }
                $this->questions[] = $newQ;
            }

		} elseif ($this->type==Exercise::EXERCISE_TYPE_ERRORCORRECTION && $this->getParent()->isQuestionBased()) {
			// Each question has its own fields
            foreach ($this->getParent()->body->getQuestions() as $question) {
                $newQ = new ModelErrorCorrectionQuestion($this);
                $newQ->addSource($question->getID());
                $newQ->addBlock('1');
                foreach ($question->getFields() as $field) {
                    // You can have multiple answers per field
                    // they should all have the same group id
                    //$newQ->addAttribute('block','b'.$field->group);
                    foreach ($field->getAnswers() as $answer) {
                        $newA = new ModelAnswer();
                        $newA->addValue($answer->getAnswer());
                        $newA->addCorrect($answer->isCorrect() ? true : false);
                        $newQ->addAnswer($newA);
                    }
                    if (count($field->getAnswers()==1) && $this->getParent()->feedbacks) {
                        foreach ($this->getParent()->feedbacks->getFeedbacks() as $feedback) {
                            // Is this feedback for this field?
                            if ($feedback->getID()==$field->getID()) {
                                $newQ->addFeedback($field->getID());
                                break;
                            }
                        }
                    }
                }
                $this->questions[] = $newQ;
            }

		// For a targetspotting, the questions have their source as the gaps
		} elseif ($this->type==Exercise::EXERCISE_TYPE_TARGETSPOTTING || $this->type==Exercise::EXERCISE_TYPE_PROOFREADING && !$this->getParent()->isQuestionBased()) {	
		        
		/*  {
				"questionType": "TargetSpottingQuestion",
				"id": "incorrect-catch-all",
				"showClickMarker": true,
				"allowMultipleAnswers": true,
				"answers": [
				  {
					"source": ".target-incorrect-area",
					"correct": false
				  }
				]
			},	
		*/	
			
			$newQ = new ModelTargetSpottingQuestion($this);
			$newQ->addMarker();
			$newQ->addMultipleAnswers();
            $newA = new ModelAnswer();
            $newA->addSource('.target-incorrect-area');
            $newA->addCorrect(false);		
			$newQ->addAnswer($newA);
			$this->questions[] = $newQ;
			
			
			foreach ($this->getParent()->body->getFields() as $field) {
                $newQ = new ModelTargetSpottingQuestion($this);
				$newQ->addBlock($field->group);
				foreach ($field->getAnswers() as $answer) {
                    $newA = new ModelAnswer();
                    $newA->addSource($field->getID(), 'q');
                    // sss#6
                    $newA->addCorrect($answer->isCorrect() ? true : false);
				}
                $newQ->addAnswer($newA);
				//echo $newQ;
				// Is there any feedback to be added to the model related to this field?
				// NOTE: This code assumes that there is only one answer in the field 
				if (count($field->getAnswers()==1) && $this->getParent()->feedbacks) {
					foreach ($this->getParent()->feedbacks->getFeedbacks() as $feedback) {
						// Is this feedback for this field?
						if ($feedback->getID()==$field->getID()) {
                            $newQ->addFeedback($field->getID());
							break;
						}
					}
				}
                $this->questions[] = $newQ;
			}

		} elseif ($this->type==Exercise::EXERCISE_TYPE_TARGETSPOTTING && $this->getParent()->isQuestionBased()) {
			// Each question has its own fields
			foreach ($this->getParent()->body->getQuestions() as $question) {
                $newQ = new ModelTargetSpottingQuestion($this);
                $newQ->addBlock($question->getID(), 'q');
				$newQ->addSource($question->getID());
                foreach ($question->getFields() as $field) {
					foreach ($field->getAnswers() as $answer) {
                        $newA = new ModelAnswer();
                        $newA->addSource($answer->getAnswer());
                        // sss#6
                        $newA->addCorrect($answer->isCorrect() ? true : false);
					}
                    $newQ->addAnswer($newA);
					//echo $newQ;
					// Is there any feedback to be added to the model related to this field?
					// NOTE: This code assumes that there is only one answer in the field 
					if (count($field->getAnswers()==1) && $this->getParent()->feedbacks) {
						foreach ($this->getParent()->feedbacks->getFeedbacks() as $feedback) {
							// Is this feedback for this field?
							if ($feedback->getID() == $field->getID()) {
                                $newQ->addFeedback($field->getID());
								break;
							}
						}
					}
				}
                $this->questions[] = $newQ;
			}
		// For a multiple choice, the questions have their source as the gaps and blocks
		} elseif ($this->type==Exercise::EXERCISE_TYPE_MULTIPLECHOICE ||
				  $this->type==Exercise::EXERCISE_TYPE_QUIZ) {

			// Each question has its own fields
			foreach ($this->getParent()->body->getQuestions() as $question) {
                $newQ = new ModelMultipleChoiceQuestion($this);
                //$newQ->addSource($question->getID());
                // TODO assume there is only one block per exercise
                $newQ->addBlock($question->getID(), 'q');
				//foreach ($question->getFields() as $field) {
                $fields = $question->getFields();
                for ($i=0; $i < count($fields); $i++) {
				
					// Each answer becomes a nth selector
                    $answers = $fields[$i]->getAnswers();
                    $newA = new ModelAnswer();
                    $newA->addSourceNthChild($question->getID(), $i+1);
                    // sss#6
                    $newA->addCorrect($answers[0]->isCorrect() ? true : false);
                    $newQ->addAnswer($newA);

					// Is there any feedback to be added to the model related to this field?
					// NOTE: This code assumes that there is only one answer in the field 
					if (count($answers)==1 && !$this->isGroupBased() && $this->getParent()->feedbacks) {
						foreach ($this->getParent()->feedbacks->getFeedbacks() as $feedback) {
							// Is this feedback for this field?
							if ($feedback->getID()==$fields[$i]->getID()) {
                                $newQ->addFeedback($fields[$i]->getID());
								break;
							}
						}
					}
				}
                if (count($answers)==1 && $this->isGroupBased() && $this->getParent()->feedbacks) {
                    foreach ($this->getParent()->feedbacks->getFeedbacks() as $feedback) {
                        // Is this feedback for this field?
                        if ($feedback->getID()==$question->getID()) {
                            $newQ->addFeedback($question->getID());
                            break;
                        }
                    }
                }

                $this->questions[] = $newQ;
			}
		} 
	}
	// If there is score based feedback this will prep the model
	function prepareFeedback() {
        foreach ($this->getParent()->feedbacks->getFeedbacks() as $feedback) {
            $newFB = new ModelFeedback();
            $newFB->addTarget($feedback->getID());
            // sss#6
            $newFB->addExpr("true");
            $this->feedback[] = $newFB;
        }
    }

	// For output to html
    // sss#1
	function output() {
        $buildText = '<script id="model" type="application/json">'."$this->newline".'{';
        $sections = array();
        if (isset($this->marking))
            $sections[] = '"marking":'.json_encode($this->marking, JSON_PRETTY_PRINT);
        if (count($this->questions) > 0)
            $sections[] = '"questions":'.json_encode($this->questions, JSON_PRETTY_PRINT);
        if (count($this->feedback) > 0)
            $sections[] = '"feedback":'.json_encode($this->feedback, JSON_PRETTY_PRINT);
        $buildText .= implode(",$this->newline", $sections);
        $buildText .= '}'."$this->newline".'    </script>';
        return $buildText;
	}

	// A utility function to describe the object
	function toString() {
		return $this->newline.str_replace('<?xml version="1.0"?'.'>','',$this->model->asXML());
	}
}
