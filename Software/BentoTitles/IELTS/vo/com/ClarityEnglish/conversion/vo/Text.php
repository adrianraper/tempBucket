<?php

class Text extends Content{
	   
	private static $nextID=1;
	protected $id;
	
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
							self::$nextID=intval($b)+1;
						default:
							$this->$a = (string)$b;
					}
				}
			}			
		}
		// Some related texts will not have an id
		if (!$this->id)
			$this->id = (string)self::$nextID;
			
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
		//return Exercise::EXERCISE_SECTION_RELATEDTEXT;
		return 'rt'.$this->getID();
	}
}
?>
