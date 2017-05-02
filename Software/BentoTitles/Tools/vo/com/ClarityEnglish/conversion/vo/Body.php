<?php

class Body extends Content{
	// The body, in an AP file and in this model, is one of the sections
	// The body, in a Bento XML file, contains all the sections
	
	function getSection() {
		return Exercise::EXERCISE_SECTION_BODY;
	}
}
