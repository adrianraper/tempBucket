<?php

class NoScroll extends Content{
	
	function __construct($xmlObj) {
		parent::__construct($xmlObj);
	}

	function getClass() {
		return Exercise::EXERCISE_SECTION_NOSCROLL;
	}
	
	// I want to override the Content method output
	function output() {
		// If I wanted to do parent first then more I would do this:
		// $built = parent::output();
		
		// Assume that the only content in NoScroll are drag fields
		$builder='';
		// So drop everything (except tabs) from the paragraphs, and first write out the spans
		foreach ($this->getParagraphs() as $paragraph) {
			$builder.=$paragraph->getPureText();
		}
		// <tab>[21]<tab>[30]<tab>[27]<tab>[22]
		// change <tab> to correct <tab/>
		$builder = str_replace('<tab>', '<tab/>', $builder);
		
		$pattern = '/([^\[]*)[\[]([\d]+)[\]]/is';
		$buildText='';
		if (preg_match_all($pattern, $builder, $matches, PREG_SET_ORDER)) {
			foreach ($matches as $m) {
				// read the fields to find the matching answer
				$answer='';
				foreach ($this->getFields() as $field) {
					if ($field->getID()==$m[2]) {
						$answers = $field->getAnswers();
						$answer = $answers[0]->getAnswer();
						continue;
					}
				}
				$buildText.=$m[1].'<span id="'.$m[2].'" draggable="true">'.$answer.'</span>';
			}
		}
		
		// Then add to the model
		
		
				
		foreach ($this->getMediaNodes() as $mediaNode) {
			$buildText.=$mediaNode->output();
		}
		
		// Whatever happens there are some characters I want to replace
		// non-breaking space special characters
		$buildText = preg_replace('/\xc2\xa0/', '&#160;', $buildText);
		
		return $buildText;
		
	}
}
?>
