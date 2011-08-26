<?php

class TemplateDefinition {

	/*
	 * AMFPHP Custom Class mapping
	 */
	var $_explicitType = 'com.clarityenglish.common.vo.email.TemplateDefinition';
	
	var $templateID;
	var $title;
	var $filename;
	var $description;
	
	function TemplateDefinition($templateID=null, $title = null, $filename = null, $description = null) {
		$this->templateID = $templateID;
		$this->title = $title;
		$this->filename = $filename;
		$this->description = $description;
	}
	
}

?>
