<?php

class Settings {
	
	protected $settings;
	
	function __construct($xmlObj=null) {
		// For now, just save the xml
		if ($xmlObj) {
			$this->settings = $xmlObj;
		}
	}
	function getSection() {
		return Exercise::EXERCISE_SECTION_SECTIONS;
	}
	function getSettings() {
		return $this->settings->settings;
	}
	function getSettingValue($settingName, $attribute) {
	    if (isset($this->settings->{$settingName}))
	        if (isset($this->settings->{$settingName}[$attribute]))
                return (string) $this->settings->{$settingName}[$attribute];
	    return false;
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
