<?php

class Rubric extends Content {
	
	function __construct() {
		parent::__construct();
	}
   
	function getClass() {
		return Exercise::EXERCISE_SECTION_RUBRIC;
	}
}
?>
