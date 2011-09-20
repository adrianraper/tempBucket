<?php
class Answer {
	
	// An Arthur answer node has attribute and value.
	var $correct;
	var $feedbackID;
	var $value;
	
	function Answer($xmlObj=null) {
		
		//echo $xmlObj;
		if ($xmlObj) {
			// Dig out the text and settings from this xml
			$attr = $xmlObj->attributes();
			if (count($attr)>0) {
				foreach($attr as $a => $b) {
					switch ($a) {
						case 'correct':
							if (strtolower($b)=='true') {
								$this->correct = true;
							} else {
								$this->correct = false;
							}
							break;
						case 'feedback':
							$this->$a = $b;
							break;
						default:
					}
				}
			}
			// Then set the actual answer
			$this->value = $xmlObj;
		}
	}
	function getAnswer(){
		return $this->value;
	}
	function isCorrect(){
		return $this->correct;
	}
	function getSpecificFeedback(){
		return $this->feedback;
	}
	// A utility function to describe the object
	function toString() {
		global $newline;
		$build=$newline.'<answer ';
		// Loop through all (private and public) members of this class
		foreach (get_object_vars($this) as $a=>$b) {
			switch ($a) {
			  	case 'correct':
			  		$build.='correct='.($b ? 'true' : 'false').' ';
			  		break;
			  	case 'feedbackID':
			  		// Simple attributes
			  		if ($b)
			  			$build.="$a=$b ";
			  		break;
			}
		}
		$build.='>';
		$build.=$this->getAnswer();
		$build.='</answer>';
		return $build;
	}}
?>
