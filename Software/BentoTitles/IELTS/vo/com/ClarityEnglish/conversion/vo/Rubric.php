<?php

class Rubric {
	
	var $paragraphs = Array();
	
	function Rubric($xmlObj=null) {
		// A rubric (instruction/title) has a number of paragraphs - usually just one
		if ($xmlObj) {
			// Dig out the paragraphs from this xml object and create them
			foreach ($xmlObj->children() as $child) {
				if ($child->getName()=='paragraph') {
					$this->addParagraph($child);
				}
			}
		}
	}

	function addParagraph($xmlObj) {
		$this->paragraphs[] = new Paragraph($xmlObj, $this);
	}
	function getParagraphs() {
		return $this->paragraphs;
	}
	function getClass() {
		return Exercise::EXERCISE_SECTION_RUBRIC;
	}
	// Just for debugging
	function getText() {
		$buildText='';
		foreach ($this->getParagraphs() as $paragraph) {
			$buildText.=$paragraph->getText();
		}
		return $buildText;
	}
}
?>
