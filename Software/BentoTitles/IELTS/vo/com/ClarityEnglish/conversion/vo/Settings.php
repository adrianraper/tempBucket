<?php

class Settings {
	
	protected $settings;
	
	function Settings($xmlObj=null) {
		// For now, just save the xml
		if ($xmlObj) {
			$this->settings = $xmlObj;
		}
	}
	function getClass() {
		return Exercise::EXERCISE_SECTION_SECTIONS;
	}
	// For output to xhtml
	function output() {
		return $this->settings->asXML();
	}
	// A utility function to describe the object
	function toString() {
		global $newline;
		return $newline.$this->settings->asXML();
	}
}
?>
