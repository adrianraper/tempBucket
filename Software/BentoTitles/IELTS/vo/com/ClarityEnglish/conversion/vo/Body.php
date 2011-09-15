<?php

class Body extends Content{
	// The body, in an AP file, is one of the sections
	// The body, in a Bento file, contains all the sections
	
	function __construct($xmlObj) {
		parent::__construct($xmlObj);
	}
   
	// Can I put the constructor into the base class too?
	function getClass() {
		return Exercise::EXERCISE_SECTION_BODY;
	}
}
?>
