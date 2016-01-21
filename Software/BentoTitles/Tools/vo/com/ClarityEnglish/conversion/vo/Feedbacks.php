<?php

class Feedbacks {
	// This holds multiple feedback items

	private $feedbacks = Array();
	
	protected $parent;
	function getParent() {
		return $this->parent;
	}
	function setParent($object) {
		$this->parent = $object;
	}
	function __construct($parent=null) {
		if ($parent) 
			$this->setParent($parent);
	}
	function addFeedback($feedback) {
		$this->feedbacks[] = $feedback;
	}
	function getFeedbacks() {
		return $this->feedbacks;
	}
	function hasFeedback() {
		return (count($this->getFeedbacks())>0);
	}
	// Feedbacks has to implement the same interface as Content
	function getSection() {
		return Exercise::EXERCISE_SECTION_FEEDBACK;
	}
	function output() {
		global $newline;
		$buildText = $newline;
		foreach($this->getFeedbacks() as $feedback) {
			$buildText.= $feedback->output();
		}
		return $buildText;
	}
	function toString() {
		$buildText = '';
		foreach($this->getFeedbacks() as $feedback) {
			$buildText.= $feedback->toString();
		}
		return $buildText;
	}
}
?>
