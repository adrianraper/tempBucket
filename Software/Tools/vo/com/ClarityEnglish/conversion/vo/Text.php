<?php

class Text extends Content{
	   
	// It is no good having a static like this as it carries on between different exercises in a batch conversion
	//private static $nextID=1;
	protected $id;
	
	function __construct($xmlObj, $parent) {
		// Grab the id (and any other attributes) and then pass to the normal constructor
		if ($xmlObj) {
			$attr = $xmlObj->attributes();
			if (count($attr)>0) {
				foreach($attr as $a => $b) {
					switch ($a) {
						// The reading text doesn't have an id. But that might be best as we
						// want to treat it differently from other related texts
						case 'id':
						default:
							$this->$a = (string)$b;
					}
				}
			}			
		}
		// Some related texts will not have an id
		// Maybe they will always be 1 in that case?
		if (!$this->id) {
			//$this->id = (string)self::$nextID++;
			$this->id = 1;
		}			
		parent::__construct($xmlObj, $parent);
	}

	function output() {
		$buildText = parent::output();
		return $buildText;
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
		//return Exercise::EXERCISE_SECTION_RELATEDTEXT;
		if ($this->getID()==1) {
			return 'readingText';
		} else {
			return 'rt'.$this->getID();
		}
	}
}
