<?php
class MediaNode {
	
	// An Arthur media node has attributes, no value
	// What type of media is it?
	private $type;
	private $qualifier;
	
	// Where is it?
	private $filename;
	private $location;

	// mode controls behaviour (such as hidden until after marking, or autorun)
	private $mode;
	 
	// w, y, width and height might be used as is unless this ruins floats
	private $x;
	private $y;
	private $width;
	private $height;
	private $stretch;
	
	// for reference
	private $id;

	protected $parent;
	
	function getParent() {
		return $this->parent;
	}
	function setParent($object) {
		$this->parent = $object;
	}
	
	function MediaNode($xmlObj=null, $parent=null) {
		// Keep a reference back to the section we are part of
		$this->setParent($parent);
		
		//echo $xmlObj;
		if ($xmlObj) {
			// Dig out the text and settings from this xml
			$attr = $xmlObj->attributes();
			if (count($attr)>0) {
				foreach($attr as $a => $b) {
					switch ($a) {
						case 'id':
						case 'x':
						case 'y':
						case 'width':
						case 'height':
						case 'stretch':
						case 'location':
						case 'mode':
						case 'filename':
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
		}
	}
	
	function getID(){
		return $this->id;
	}
	// A utility function to describe the object
	function toString() {
		global $newline;
		$build=$newline.'<media ';
		// Loop through all (private and public) members of this class
		
		foreach (get_object_vars($this) as $a=>$b) {
			switch ($a) {
				case 'id':
				case 'x':
				case 'y':
				case 'width':
				case 'height':
				case 'stretch':
				case 'location':
				case 'mode':
				case 'filename':
				case 'type':
				case 'qualifier':
			  		// Simple attributes
			  		if ($b)
			  			$build.="$a=$b ";
			  		break;
			}
		}
		$build.='/>';
		return $build;
	}
	// This function turns the object into a string to go into the xhtml file.
	function output() {
		$build='';
		switch ($this->type) {
			case 'picture':
			case 'image':
				$build.= '<img '; 
				break;
			default:
				$build.= '<media ';
		}
		// Then based on the x and y we will position it somehow
		if ($this->x>=500 && $this->y<=100) {
			$build.= 'class="rightFloat" ';
		} else {	
			$build.= 'class="leftFloat" ';
		}
		// Location is merged into filename
		// TODO. We want to use symbolic folder names that can be evaluated at runtime.
		//if ($this->location=='shared') {
			$build.="src=\"../Media/$this->filename\" ";
		//}
		// Other attributes that just get copied
		$build.="height=\"$this->height\" width=\"$this->width\" mode=\"$this->mode\" id=\"$this->id\" ";
		
		$build.=' />';
		return $build;
	}
}
?>
