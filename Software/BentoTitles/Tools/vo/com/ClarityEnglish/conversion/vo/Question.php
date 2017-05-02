<?php

class Question extends Content{
	// A question is a small bit of body in a question based exercise
	
	private $id;
	
	// Add to the parent constructor by simply counting questions as they are added
	function __construct($qID, $xmlObj, $parent) {
		$this->id = $qID;
		parent::__construct($xmlObj, $parent);
	}
	function getID() {
		return $this->id;
	}
	function getSection() {
		// The section isn't really question - is it??
		return Exercise::EXERCISE_SECTION_BODY;
	}
	// Override the parent toString
	// A utility function to describe the object
	function toString() {
		global $newline;
		$build=$newline.'<'.$this->getSection().' id="'.$this->getID().'">';
		
		foreach ($this->getParagraphs() as $para) {
			if ($para)
	  			$build.=$para->toString();
		}
		foreach ($this->getFields() as $field) {
	  		$build.=$field->toString();
		}
		foreach ($this->getMediaNodes() as $mediaNode) {
	  		$build.=$mediaNode->toString();
		}
		
		$build.=$newline.'</'.$this->getSection().'>';	
		return $build;
	}
	
}
