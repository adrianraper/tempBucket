<?php

class Hint extends Content{
	// In Arthur, each item of feedback has a section tag
	// In Bento, all feedback will be within one section, separated by feedback tags
	
	// Extend content as feedback does have an id
	protected $id;
	public $mode;
	
	function __construct($xmlObj, $parent) {
		// Grab the id (and any other attributes) and then pass to the normal constructor
		if ($xmlObj) {
			$attr = $xmlObj->attributes();
			if (count($attr)>0) {
				foreach($attr as $a => $b) {
					switch ($a) {
						case 'id':
							//$this->setID($b);
							//break;
						default:
							$this->$a = (string)$b;
					}
				}
			}			
		}
		parent::__construct($xmlObj, $parent);
	}
	
	//function setID($id) {
	//	if ($id)
	//		$this->id = (string)$id;
	//}
	function getID() {
		return $this->id;
	}
	// Each feedback is its own section
	function getSection() {
		//return Exercise::EXERCISE_SECTION_FEEDBACK;
		return 'hint'.$this->getID();
	}
    // I want to override the Content method output to wrap container round the feedback
    function output() {

        $buildText = '<script id="'.$this->getSection().'" type="text/x-handlebars-template">';
        $buildText .= '<div class="feedback mod-draggable">';
		$buildText .= '<div class="feedback-title">Hint</div>';
		$buildText .= '<div class="feedback-body">';
        $buildText .= parent::output();
        $buildText .= '</div></div></script>';

        return $buildText;
    }

}
