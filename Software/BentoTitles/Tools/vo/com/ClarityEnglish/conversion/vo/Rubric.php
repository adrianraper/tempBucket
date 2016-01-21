<?php

class Rubric extends Content {
	
	// If I don't define this it automatically use the parent's
	//function __construct($xmlObj, $parent) {
	//	parent::__construct($xmlObj, $parent);
	//}
	   
	function getSection() {
		return Exercise::EXERCISE_SECTION_RUBRIC;
	}
}
?>
