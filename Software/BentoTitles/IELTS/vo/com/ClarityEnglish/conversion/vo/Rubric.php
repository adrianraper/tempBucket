<?php

class Rubric extends Content {
	
	function __construct($xmlObj) {
		parent::__construct($xmlObj);
	}
   
	function getClass() {
		return Exercise::EXERCISE_SECTION_RUBRIC;
	}
}
?>
