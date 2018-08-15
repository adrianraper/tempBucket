<?php

class Hints {
	// This holds multiple feedback items

	private $hints = Array();
	
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
	function addHint($hint) {
		$this->hints[] = $hint;
	}
	function getHints() {
		return $this->hints;
	}
	function hasHint() {
		return (count($this->getHints())>0);
	}
	// Feedbacks has to implement the same interface as Content
	function getSection() {
		return Exercise::EXERCISE_SECTION_HINT;
	}
	function output() {
		global $newline;
		$buildText = $newline;
		foreach($this->getHints() as $hint) {
			$buildText.= $hint->output();
		}
		return $buildText;
	}
	function toString() {
		$buildText = '';
		foreach($this->getHints() as $hint) {
			$buildText.= $hint->toString();
		}
		return $buildText;
	}
}
?>
