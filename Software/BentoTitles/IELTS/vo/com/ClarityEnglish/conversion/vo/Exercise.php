<?php
class Exercise {
	
	// The ID of the exercise
	private $id;
	private $type;
	
	// The components of an exercise (some are optional)
	public $settings;
	public $rubric;
	public $body;
	public $noscroll;
	public $example;
	public $readingText;
	public $model;
	
	// Maybe key for layout
	private $questionBased;
	
	const EXERCISE_SECTION_RUBRIC = 'rubric';
	const EXERCISE_SECTION_TITLE = 'title';
	const EXERCISE_SECTION_BODY = 'body';
	// Is question really a section?
	const EXERCISE_SECTION_QUESTION = 'question';
	const EXERCISE_SECTION_NOSCROLL = 'noscroll';
	const EXERCISE_SECTION_EXAMPLE = 'example';
	const EXERCISE_SECTION_SETTINGS = 'settings';
	const EXERCISE_SECTION_TEMPLATE = 'template';
	const EXERCISE_TYPE_DRAGANDDROP = 'draganddrop';
	const EXERCISE_TYPE_PRESENTATION = 'presentation';
	const EXERCISE_TYPE_GAPFILL = 'gapfill';
	const EXERCISE_TYPE_DROPDOWN = 'dropdown';
	const EXERCISE_TYPE_MULTIPLECHOICE = 'multiplechoice';
	
	function __construct($xmlObj=null) {
		if ($xmlObj) {
			// Use the exercise attributes
			$attr = $xmlObj->attributes();
			// Convert some of the Arthur names to Bento names
			switch (strtolower($attr['type'])) {
				case 'dragon':
					$this->type = Exercise::EXERCISE_TYPE_DRAGANDDROP;
					$this->questionBased = false;
					break;
				case 'cloze':
					$this->type = Exercise::EXERCISE_TYPE_GAPFILL;
					$this->questionBased = false;
					break;
				// Then text based versions with standard names
				case 'dropdown':
				case 'presentation':
					$this->type = strtolower($attr['type']);
					$this->questionBased = false;
					break;
				// Then question based versions with standard names
				case 'multiplechoice':
				default;
					$this->type = strtolower($attr['type']);
					$this->questionBased = true;
			}
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
			  			$this->rubric = new Rubric($child, $this);
			  			break;
			  		case Exercise::EXERCISE_SECTION_BODY:
			  			if ($this->questionBased) {
			  				$this->body = new QbBody($child, $this);
			  			} else {
			  				$this->body = new Body($child, $this);
			  			}
			  			break;
			  		case Exercise::EXERCISE_SECTION_NOSCROLL:
			  			$this->noscroll = new NoScroll($child, $this);
			  			break;
			  		case Exercise::EXERCISE_SECTION_EXAMPLE:
			  			//$this->example = new Example($child, $this);
			  			break;
			  		case Exercise::EXERCISE_SECTION_TEMPLATE:
			  			// I'm just going to drop template sections as of no value
			  			break;
			  	}
			}
			// Once you have all sections, you need to do some replacing of fields/answers
			$this->model = new Model($this);
			// Get the model ready
			$this->model->prepareQuestions();
			
		}
	}
	function getID() {
		return $this->id;
	}
	function getType() {
		return $this->type;
	}
	function isQuestionBased() {
		return $this->questionBased;
	}
	
	// Following functions are for the conversion
	function formatRubric() {
		//return $this->rubric->toString();
		return $this->rubric->output();
	}
	function getRubric(){
		//return $this->rubric->getText();
		return $this->rubric->output();
	}
	function getSettings(){
		//return $this->settings->getText();
		return $this->settings->output();
	}
	function getModel(){
		return $this->model->output();
	}
	function getSections(){
		$sections = array();
		if ($this->noscroll)
			$sections[]=$this->noscroll;
		if ($this->example)
			$sections[]=$this->example;
		if ($this->body)
			$sections[]=$this->body;
		return $sections;
	}
	
	// A utility function to describe the object
	function toString() {
		global $newline;
		$build=$newline.'<exercise ';
		// Loop through all (private and public) members of this class
		
		foreach (get_object_vars($this) as $a=>$b) {
			switch ($a) {
			  	case 'id':
			  	case 'type':
			  		// Simple attributes
			  		$build.=$a."=".$b." ";
			  		break;
			}
		}
		$build.='>';
		/*
		foreach (get_object_vars($this) as $a=>$b) {
			switch ($a) {
				// Objects
			  	case 'settings':
			  	case 'rubric':
			  	case 'body':
			  	case 'noscroll':
			  		$build.=$this->$a->toString();
			  		break;
			}
		}
		*/
		$build.=$this->settings->toString();
		$build.=$this->model->toString();
		$build.=$this->rubric->toString();
		if ($this->noscroll)
			$build.=$this->noscroll->toString();
		$build.=$this->body->toString();
		
		$build.=$newline.'</exercise>';	
		return $build;
	}
	
}
?>
