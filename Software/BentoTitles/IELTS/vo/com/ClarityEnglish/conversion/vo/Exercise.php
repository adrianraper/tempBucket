<?php
class Exercise {
	
	// The ID of the exercise
	var $id;
	var $type;
	
	// The components of an exercise (some are optional)
	var $settings;
	var $rubric;
	var $body;
	var $noscroll;
	var $example;
	var $readingText;
	
	const EXERCISE_SECTION_RUBRIC = 'rubric';
	const EXERCISE_SECTION_TITLE = 'title';
	const EXERCISE_SECTION_BODY = 'body';
	const EXERCISE_SECTION_NOSCROLL = 'noscroll';
	const EXERCISE_SECTION_EXAMPLE = 'example';
	const EXERCISE_SECTION_SETTINGS = 'settings';
	const EXERCISE_SECTION_TEMPLATE = 'template';
	
	function Exercise($xmlObj=null) {
		if ($xmlObj) {
			// Use the exercise attributes
			$attr = $xmlObj->attributes();
			$this->type = $attr['type'];
			$this->id = $attr['id'];

			// Dig out the sections and create them
			foreach ($xmlObj->children() as $child) {
				//echo $child->getName() . " = " . $child->asXML() . "<br />";
			  	switch (strtolower($child->getName())) {
			  		case Exercise::EXERCISE_SECTION_SETTINGS:
			  			// Just copy the settings for now
			  			$this->settings = new Settings($child);
			  			break;
			  		case Exercise::EXERCISE_SECTION_TITLE:
			  			$this->rubric = new Rubric($child);
			  			break;
			  		case Exercise::EXERCISE_SECTION_BODY:
			  			$this->body = new Body($child);
			  			break;
			  		case Exercise::EXERCISE_SECTION_NOSCROLL:
			  			$this->noscroll = new NoScroll($child);
			  			break;
			  		case Exercise::EXERCISE_SECTION_EXAMPLE:
			  			//$this->example = new Example($child);
			  			break;
			  		case Exercise::EXERCISE_SECTION_TEMPLATE:
			  			// I'm just going to drop template sections as of no value
			  			break;
			  	}
			}
		}
	}
	function getRubric(){
		return $this->rubric->getText();
	}
	function getSettings(){
		return $this->settings->getText();
	}
	function getSections(){
		$section = array();
		if ($this->body)
			$sections[]=$this->body;
		if ($this->noscroll)
			$sections[]=$this->noscroll;
		if ($this->example)
			$sections[]=$this->example;
		return $sections;
	}
	function getID() {
		return $this->id;
	}
	function getType() {
		return $this->type;
	}
	
	// Following functions are for the conversion
	function formatRubric() {
		return $this->rubric->toString();
	}
}
?>
