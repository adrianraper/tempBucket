<?php

class NoScroll extends Content{
	
	// If I don't define this it automatically use the parent's
	//function __construct($xmlObj, $parent) {
	//	parent::__construct($xmlObj, $parent);
	//}

	function getSection() {
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
			if ($paragraph)
				$builder.=$paragraph->getPureText();
		}
		// <tab>[21]<tab>[30]<tab>[27]<tab>[22]
		// change <tab> to correct <tab/>
		// Or should we drop all tabs altogether and just use span floats?
		//$builder = str_replace('<tab>', '<tab/>', $builder);
		$builder = str_replace('<tab>', '', $builder);

		// Add container for the no scroll fields
        $this->getParent()->noScrollBlock = "b1";
        $buildText='<section class="draggables" id="'.$this->getParent()->noScrollBlock.'">';

        $pattern = '/([^\[]*)[\[]([\d]+)[\]]/is';
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
				$buildText.=$m[1].'<span id="a'.$m[2].'" draggable="true">'.$answer.'</span>';
			}
		}

		// And close the container
        $buildText .= '</section>';

        // Then add any media nodes
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
