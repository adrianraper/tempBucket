<?php

class Settings {
	
	function Settings($xmlObj=null) {
		// For now, just save the xml
		if ($xmlObj) {
			$this->settings = $xmlObj;
		}
	}
	function getClass() {
		return Exercise::EXERCISE_SECTION_SECTIONS;
	}
	// Just for debugging
	function getText() {
		$buildText=$this->settings;
		return $buildText->asXML();
	}
}
?>
