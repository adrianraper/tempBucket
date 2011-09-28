<?php

class Model {
	
	protected $model;
	protected $type;
	
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
			
		$xmlstr = <<<XML
<script id="model" type="application/xml">
</script>
XML;
		$this->model = new SimpleXMLElement($xmlstr);
	}
	// Get ready for questions in the model
	function prepareQuestions() {
		// check to see if the questions node already exists
		if (!$this->model->questions) {
			$stuff = $this->model->addChild('questions');
		}
		// For a drag and drop, the questions have their source as the drops and their answer source as the drags
		//echo "Model qbased=".$this->getParent()->isQuestionBased();
		if ($this->type==Exercise::EXERCISE_TYPE_DRAGANDDROP && !$this->getParent()->isQuestionBased()) {
			foreach ($this->getParent()->body->getFields() as $field) {
			//	<field mode="0" type="i:drop" group="1" id="1">
			//		<answer correct="true">chess</answer>
			//	</field>
			//	<DragQuestion source="1">
			//		<answer correct="true" source="a5" />
			//		<answer correct="true" source="a7" />
			//	</DragQuestion>
				
				$newQ = $this->model->questions->addChild("DragQuestion");
				$newQ->addAttribute('source',$field->getID());
				foreach ($field->getAnswers() as $answer) {
					$newA = $newQ->addChild('answer');
					$matchingID = 'unknown';
					// This is the correct answer for the drop. 
					// We need to find the id of the drag that matches this and use that rather than duplicate the answer.
					$thisAnswerText = $answer->getAnswer();
					//echo "\ntry to match $thisAnswerText";
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
					//echo 'and add to the answer';
					$newA->addAttribute('source',$matchingID);
					$newA->addAttribute('correct',$answer->isCorrect() ? 'true' : 'false');
				}
				//echo $newQ;
			}
		} elseif ($this->type==Exercise::EXERCISE_TYPE_DRAGANDDROP && $this->getParent()->isQuestionBased()) {
			// Each question has its own fields
			foreach ($this->getParent()->body->getQuestions() as $question) {
				$newQ = $this->model->questions->addChild("DragQuestion");
				//$newQ->addAttribute('source',$field->getID());
				// Whilst you can get the group from the field, you can also get it from the question
				// Ideally we would match to make sure they are the same
				//$newQ->addAttribute('group',$field->group);
				$newQ->addAttribute('group','q'.$question->getID());
				foreach ($question->getFields() as $field) {
				
			//	<field mode="0" type="i:target" group="1" id="1">
			//		<answer correct="false">golf</answer>
			//	</field>
			//	<MultipleChoiceQuestion block="q1">
			//		<answer correct="true" source="1" />
			//		<answer correct="false" source="2" />
			//	</MultipleChoiceQuestion>
					// Only ever 1 answer per field
					foreach ($field->getAnswers() as $answer) {
						$newA = $newQ->addChild('answer');
						$newA->addAttribute('source',$field->getID());
						$newA->addAttribute('correct',$answer->isCorrect() ? 'true' : 'false');
					}
					//echo $newQ;
				}
			}
		// For a gapfil, the questions have their source as the gaps
		} elseif ($this->type==Exercise::EXERCISE_TYPE_GAPFILL) {
			foreach ($this->getParent()->body->getFields() as $field) {
			//	<field mode="0" type="i:gap" group="1" id="1">
			//		<answer correct="true">chess</answer>
			//	</field>
			//	<GapFillQuestion source="1" group="1">
			//		<answer correct="true" value="xxxxx" />
			//		<answer correct="true" source="yyyyy" />
			//	</GapQuestion>
				
				$newQ = $this->model->questions->addChild("GapFillQuestion");
				$newQ->addAttribute('source',$field->getID());
				$newQ->addAttribute('group',$field->group);
				foreach ($field->getAnswers() as $answer) {
					$newA = $newQ->addChild('answer');
					$newA->addAttribute('value',$answer->getAnswer());
					$newA->addAttribute('correct',$answer->isCorrect() ? 'true' : 'false');
				}
				//echo $newQ;
			}
		// For a dropdown, the questions have their source as the gaps
		} elseif ($this->type==Exercise::EXERCISE_TYPE_DROPDOWN) {
			$generateID=1;
			foreach ($this->getParent()->body->getFields() as $field) {
			//	<field mode="0" type="i:dropdown" id="1">
			//		<answer correct="true">xxxxx</answer>
			//		<answer correct="false">yyyyy</answer>
			//		<answer correct="false">zzzzz</answer>
			//	</field>
			//	<DropdownQuestion source="1" group="1">
			//		<answer correct="true" source="2" />
			//		<answer correct="false" source="3" />
			//		<answer correct="false" source="4" />
			//	</DropdownQuestion>
				
				$newQ = $this->model->questions->addChild("DropdownQuestion");
				$newQ->addAttribute('source',$field->getID());
				$newQ->addAttribute('group',$field->group);
				foreach ($field->getAnswers() as $answer) {
					$newA = $newQ->addChild('answer');
					//$newA->addAttribute('value',$answer->getAnswer());
					$newA->addAttribute('source','o'.$generateID++);
					$newA->addAttribute('correct',$answer->isCorrect() ? 'true' : 'false');
				}
				//echo $newQ;
			}
		// For a targetspotting, the questions have their source as the gaps
		} elseif ($this->type==Exercise::EXERCISE_TYPE_TARGETSPOTTING) {
			foreach ($this->getParent()->body->getFields() as $field) {
			//	<field mode="0" type="i:target" id="1">
			//		<answer correct="true">xxxxx</answer>
			//	</field>
			//	<feedback id="1" mode="101">
			//		<paragraph ...>xxx</paragraph>
			//		<paragraph ...>xxx</paragraph>
			//	</feedback>
			//	<TargetSpottingQuestion>
			//		<answer correct="true" source="1" >
			//			<feedback id="fb1">
			//				<p ...>xxx</p>
			//				<p ...>xxx</p>
			//			</feedback>
			//		</answer>
			//	</TargetSpottingQuestion>
			// OR you could have the feedback as a section in the html body
			// I think the second option is better - keep text in the html body and references in the model.
			//	<TargetSpottingQuestion>
			//		<answer correct="true" source="1" >
			//			<feedback id="fb1" source="fb1" />
			//		</answer>
			//	</TargetSpottingQuestion>
			//	<section id="feedback">
			//		<feedback id="fb1">
			//			<p ...>xxx</p>
			//			<p ...>xxx</p>
			//		</feedback>
			//	</section>
				
				$newQ = $this->model->questions->addChild("TargetSpottingQuestion");
				foreach ($field->getAnswers() as $answer) {
					$newA = $newQ->addChild('answer');
					$newA->addAttribute('source',$field->getID());
					$newA->addAttribute('correct',$answer->isCorrect() ? 'true' : 'false');
					// Is there any feedback to be added to the model related to this answer?
					// NOTE: This code assumes that each answer has an ID that relates to a feedback ID
					/* 
					if ($answer->getID() && $this->getParent()->feedbacks) {
					if (method_exists($answer,'getID') && $this->getParent()->feedbacks) {
						foreach ($this->getParent()->feedbacks->getFeedbacks() as $feedback) {
							// Is this feedback for this field?
							if ($feedback->getID()==$field->getID()) {
								$newFB = $newA->addChild('feedback');	
								$newFB->addAttribute('source',$field->getID());
								break;
							}
						}
					}
					*/
				}
				//echo $newQ;
				// Is there any feedback to be added to the model related to this field?
				// NOTE: This code assumes that there is only one answer in the field 
				if (count($field->getAnswers()==1) && $this->getParent()->feedbacks) {
					foreach ($this->getParent()->feedbacks->getFeedbacks() as $feedback) {
						// Is this feedback for this field?
						if ($feedback->getID()==$field->getID()) {
							$newFB = $newA->addChild('feedback');	
							$newFB->addAttribute('source',$field->getID());
							break;
						}
					}
				}
			}
			// For a multiple choice, the questions have their source as the gaps and blocks
		} elseif ($this->type==Exercise::EXERCISE_TYPE_MULTIPLECHOICE) {
			// Each question has its own fields
			foreach ($this->getParent()->body->getQuestions() as $question) {
				$newQ = $this->model->questions->addChild("MultipleChoiceQuestion");
				//$newQ->addAttribute('source',$field->getID());
				// Whilst you can get the group from the field, you can also get it from the question
				// Ideally we would match to make sure they are the same
				//$newQ->addAttribute('group',$field->group);
				$newQ->addAttribute('group','q'.$question->getID());
				foreach ($question->getFields() as $field) {
				
			//	<field mode="0" type="i:target" group="1" id="1">
			//		<answer correct="false">golf</answer>
			//	</field>
			//	<MultipleChoiceQuestion block="q1">
			//		<answer correct="true" source="1" />
			//		<answer correct="false" source="2" />
			//	</MultipleChoiceQuestion>
					// Only ever 1 answer per field
					foreach ($field->getAnswers() as $answer) {
						$newA = $newQ->addChild('answer');
						$newA->addAttribute('source',$field->getID());
						$newA->addAttribute('correct',$answer->isCorrect() ? 'true' : 'false');
					}
					//echo $newQ;
				}
			}
		} 
	}
	// Adding a new node
	function addQuestion($xml) {
		//$this->model->addChild($xml);
		//$this->model->addAttribute(x,y);
	}
	// For output to xhtml
	function output() {
		// Just output whole model, but make sure it doesn't have xml special header
		return str_replace('<?xml version="1.0"?>','',$this->model->asXML());
	}
	// A utility function to describe the object
	function toString() {
		//$this->nodes->script->addAttribute("bug", "bad");
		//echo "model to string";
		global $newline;
		return $newline.str_replace('<?xml version="1.0"?>','',$this->model->asXML());
	}
}
?>
