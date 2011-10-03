<?php

class QbBody {
	// This is a question based body.
	// It just holds each question, which we treat as a Content object
	// It also needs to hold its own mediaNodes

	private $questions = Array();
	private $mediaNodes = Array();
	
	protected $parent;
	function getParent() {
		return $this->parent;
	}
	function setParent($object) {
		//echo "set parent for ";
		$this->parent = $object;
	}
	function __construct($xmlObj=null, $parent=null) {
		if ($parent) 
			$this->setParent($parent);
			
		if ($xmlObj) {
			// Go through the object picking out question nodes and making a Question (::Content) object for each
			foreach ($xmlObj->children() as $child) {
				//echo $child->getName();
				if (strtolower($child->getName())=='question') {
					$this->addQuestion($child);
				}
				// For field nodes, add them to the relevant Question
				// Note that this will only work if the question has already been created
				if ($child->getName()=='field') {
					// Which question does this field relate to?
					$qID = $child['group'];
					$this->addField($qID, $child);
				}
				
				// Also go through the mediaNodes, those that are question based should be added to the relevant Question
				if ($child->getName()=='media') {
					// Which question does this field relate to?
					$qbMedia = substr($child['type'],0,1)=='q' ? true : false;
					if ($qbMedia) {
						$qID = $child['id'];
						$this->addQbMediaNode($qID, $child);
					} else {
						// Those that are common to the exercise can stay in here.
						$this->addMediaNode($child);
					}
				}
			}
		}
	}
	function addQuestion($xmlObj) {
		// We need to let the question know which number it is as we add it
		// We link the Content to the Exercise rather than to the question (I think!)
		$this->questions[] = new Question(count($this->questions)+1,$xmlObj, $this->getParent());
	}
	function getQuestions() {
		return $this->questions;
	}
	function addField($qID, $xmlObj) {
		foreach($this->questions as $question) {
			if ($question->getID()==$qID) {
				$question->addField($xmlObj);
			}
		}
	}
	function getFields($qID) {
		foreach($this->questions as $question) {
			if ($question->getID()==$qID) {
				return $question->getFields();
			}
		}
	}
	function addQbMediaNode($qID, $xmlObj) {
		foreach($this->questions as $question) {
			if ($question->getID()==$qID) {
				$question->addMediaNode($xmlObj);
			}
		}
	}
	function addMediaNode($xmlObj) {
		$this->mediaNodes[] = new MediaNode($xmlObj, $this);
	}
	
	// QbBody has to implement the same interface as Body
	function getSection() {
		return Exercise::EXERCISE_SECTION_BODY;
	}
	function output() {
		global $newline;
		//echo "output qbBody";
		$buildText = '';
		// Also output the common mediaNodes. These are likely to be first.
		foreach($this->mediaNodes as $mediaNode) {
			$buildText.=$mediaNode->output();
		}
		// Here we output the common stuff
		$buildText .= $newline.'<ol id="questionList">';
		// Then for each question
		foreach($this->getQuestions() as $question) {
			$buildText.= $question->output();
		}
		$buildText .= '</ol>';
		return $buildText;
	}
	function toString() {
		$buildText = '';
		foreach($this->questions as $question) {
			$buildText.= $question->toString();
		}
		// Also write the common mediaNodes
		foreach($this->mediaNodes as $mediaNode) {
			$buildText.=$mediaNode->toString();
		}
		return $buildText;
	}
}
?>
