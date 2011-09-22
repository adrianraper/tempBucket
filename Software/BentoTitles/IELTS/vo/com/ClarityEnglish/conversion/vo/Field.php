<?php
class Field {
	
	var $answers = Array();
	
	// An Arthur field node has attributes and value. It contains the answer and behaviour
	// What type of media is it?
	var $type;
	var $qualifier;
	// mode controls behaviour (such as hidden until after marking, or autorun)
	var $mode;
	// fields can be part of groups
	var $group;
	
	// for reference
	var $id;

	const FIELD_TYPE_DROP = 'drop';
	const FIELD_TYPE_DRAG = 'drag';
	const FIELD_TYPE_GAP = 'gap';
	
	protected $parent;
	function getParent() {
		return $this->parent;
	}
	function setParent($object) {
		$this->parent = $object;
	}
	
	function __construct($xmlObj=null, $parent=null) {
		// Keep a reference back to the paragraph/section we are part of
		if ($parent)
			$this->setParent($parent);
		
		//echo $xmlObj;
		if ($xmlObj) {
			// Dig out the text and settings from this xml
			$attr = $xmlObj->attributes();
			if (count($attr)>0) {
				foreach($attr as $a => $b) {
					switch ($a) {
						case 'id':
						case 'mode':
						case 'group':
							$this->$a = $b;
							break;
						case 'type':
							// First character is a subtype
							$this->qualifier = substr($b,0,1);
							// Then third onwards is the real type
							$this->type = substr($b,2);
						default:
					}
				}
			}
			// Then get the answers
			// Only php5.3! if ($xmlObj->count()>0) {
			foreach($xmlObj->children() as $node) {
				if (strtolower($node->getName())=='answer') {
					$this->addAnswer($node);
				}
			}
		}
	}
	function addAnswer($xmlObj) {
		$this->answers[] = new Answer($xmlObj, $this);
	}
	function getAnswers() {
		return $this->answers;
	}
	function getID(){
		return $this->id;
	}
	function getType(){
		return $this->type;
	}
	// Fields are not really output directly, they end up being merged into other sections
	// A utility function to describe the object
	function toString() {
		global $newline;
		$build=$newline.'<field ';
		// Loop through all (private and public) members of this class
		
		foreach (get_object_vars($this) as $a=>$b) {
			switch ($a) {
			  	case 'id':
			  	case 'type':
			  	case 'qualifier':
			  	case 'mode':
			  	case 'group':
			  		// Simple attributes
			  		if ($b)
			  			$build.="$a=$b ";
			  		break;
			}
		}
		$build.='>';
		foreach ($this->getAnswers() as $answer) {
			$build.=$answer->toString();
		}
		$build.=$newline.'</field>';
		return $build;
	}
}
?>
