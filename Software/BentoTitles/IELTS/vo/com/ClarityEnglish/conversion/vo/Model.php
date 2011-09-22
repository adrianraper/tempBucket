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
		if ($this->type==Exercise::EXERCISE_TYPE_DRAGANDDROP) {
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
		// For a gapfil, the questions have their source as the gaps
		} elseif ($this->type==Exercise::EXERCISE_TYPE_GAPFILL) {
			foreach ($this->getParent()->body->getFields() as $field) {
			//	<field mode="0" type="i:gap" group="1" id="1">
			//		<answer correct="true">chess</answer>
			//	</field>
			//	<GapQuestion source="1" group="1">
			//		<answer correct="true" value="xxxxx" />
			//		<answer correct="true" source="yyyyy" />
			//	</GapQuestion>
				
				$newQ = $this->model->questions->addChild("GapQuestion");
				$newQ->addAttribute('source',$field->getID());
				$newQ->addAttribute('group',$field->group);
				foreach ($field->getAnswers() as $answer) {
					$newA = $newQ->addChild('answer');
					$newA->addAttribute('value',$answer->getAnswer());
					$newA->addAttribute('correct',$answer->isCorrect() ? 'true' : 'false');
				}
				//echo $newQ;
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
