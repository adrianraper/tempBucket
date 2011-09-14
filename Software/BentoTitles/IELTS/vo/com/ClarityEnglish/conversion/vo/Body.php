<?php

class Body extends Content{
	
	// Can I put the constructor into the base class too?
	function Body($xmlObj=null) {
		// The body, in an AP file, is one of the sections
		// The body, in a Bento file, contains all the sections
		if ($xmlObj) {
			// Dig out the paragraphs from this xml object and create them
			foreach ($xmlObj->children() as $child) {
				if ($child->getName()=='paragraph') {
					$this->addParagraph($child);
				}
				if ($child->getName()=='media') {
					$this->addMediaNode($child);
				}
			}
		}
	}

	function getClass() {
		return Exercise::EXERCISE_SECTION_BODY;
	}
}
?>
