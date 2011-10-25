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
	// Keep one item that holds all the feedback items. Use invented plural.
	public $feedbacks;
	public $texts;
	public $model;
	
	// Maybe key for layout
	private $questionBased;
	
	const EXERCISE_SECTION_RUBRIC = 'rubric';
	const EXERCISE_SECTION_TITLE = 'title';
	const EXERCISE_SECTION_BODY = 'body';
	const EXERCISE_SECTION_FEEDBACK = 'feedback';
	// Is question really a section?
	const EXERCISE_SECTION_QUESTION = 'question';
	const EXERCISE_SECTION_NOSCROLL = 'noscroll';
	const EXERCISE_SECTION_EXAMPLE = 'example';
	const EXERCISE_SECTION_RELATEDTEXT = 'texts';
	const EXERCISE_SECTION_SETTINGS = 'settings';
	const EXERCISE_SECTION_TEMPLATE = 'template';
	const EXERCISE_TYPE_DRAGANDDROP = 'draganddrop';
	const EXERCISE_TYPE_PRESENTATION = 'presentation';
	const EXERCISE_TYPE_GAPFILL = 'gapfill';
	const EXERCISE_TYPE_DROPDOWN = 'dropdown';
	const EXERCISE_TYPE_MULTIPLECHOICE = 'multiplechoice';
	const EXERCISE_TYPE_QUIZ = 'quiz';
	const EXERCISE_TYPE_TARGETSPOTTING = 'targetspotting';
	const EXERCISE_TYPE_ERRORCORRECTION = 'errorcorrection';
	
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
				// Can you use one exercise type for question and text based exercises?
				case 'draganddrop':
					$this->type = Exercise::EXERCISE_TYPE_DRAGANDDROP;
					$this->questionBased = true;
					break;
				case 'cloze':
					$this->type = Exercise::EXERCISE_TYPE_GAPFILL;
					$this->questionBased = false;
					break;
				case 'stopgap':
					$this->type = Exercise::EXERCISE_TYPE_GAPFILL;
					$this->questionBased = true;
					break;
				case 'analyze':
					$this->type = Exercise::EXERCISE_TYPE_MULTIPLECHOICE;
					$this->questionBased = true;
					break;
				// Then text based versions with standard names
				case 'dropdown':
				case 'presentation':
				case 'targetspotting':
				case 'errorcorrection':
					$this->type = strtolower($attr['type']);
					$this->questionBased = false;
					break;
				// Then question based versions with standard names
				case 'multiplechoice':
				case 'quiz':
				default;
					$this->type = strtolower($attr['type']);
					$this->questionBased = true;
			}
			$this->id = $attr['id'];

			// Dig out the sections and create them
			foreach ($xmlObj->children() as $child) {
				//echo 'Exercise+'.$child->getName() . "<br />";
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
			  		// Rarely there will be more than one related text (a reading text and a tip for instance)
			  		case Exercise::EXERCISE_SECTION_RELATEDTEXT:
			  			if (!$this->texts)
			  				$this->texts = array();
			  			$this->texts[] = new Text($child, $this);
			  			//echo "made new text ";
			  			break;
		  			// We are expecting many feedback sections from Arthur, but we actually want to merge them for Bento. No we don't, keep separate.
			  		case Exercise::EXERCISE_SECTION_FEEDBACK:
			  			//$this->feedback = new Feedback($child, $this);
			  			if (!$this->feedbacks) {
			  				$this->feedbacks = new Feedbacks($this);
			  			}
			  			$this->feedbacks->addFeedback(new Feedback($child, $this));
						//echo $child->getName() . " = " . $child->asXML() . "<br />";
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
		return (boolean) $this->questionBased;
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
		if ($this->feedbacks) {
			// Each feedback is a separate section
			foreach ($this->feedbacks->getFeedbacks() as $feedback) {
				//echo 'add fb to sections ';
				$sections[]=$feedback;
			}
		}
		if ($this->texts) {
			// Each text is a separate section
			foreach ($this->texts as $text) {
				$sections[]=$text;
			}
		}
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
		if ($this->example)
			$build.=$this->example->toString();
		$build.=$this->body->toString();
		if ($this->feedbacks)
			$build.=$this->feedbacks->toString();
		if ($this->texts) {
			foreach ($this->texts as $text) {
				$build.=$text->toString();
			}
		}
			
		$build.=$newline.'</exercise>';	
		return $build;
	}
	
}
?>
