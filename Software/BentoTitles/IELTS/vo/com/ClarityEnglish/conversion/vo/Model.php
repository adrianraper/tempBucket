<?php

class Model {
	
	protected $nodes;
	
	function __construct() {
		$xmlstr = <<<XML
<model>
<script id="model" type="application/xml">
	<questions>bottoms</questions>
</script>
</model>
XML;
		$this->nodes = new SimpleXMLElement($xmlstr);
		echo "constructing";
	}
	// Get ready for questions in the model
	function prepareQuestions() {
		// check to see if the questions node already exists
		echo 'prepare';
		if ($this->nodes->script->questions) {
			$this->nodes->script->addAttribute("big", "good");
			//echo $this->toString();
		} else {
			$stuff = $this->nodes->script->addChild('questions');
			$stuff->addAttribute('yes', 'no');
			//echo $stuff->asXML();
		}
	}
	// Adding a new node
	function addQuestion($xml) {
		//$this->nodes->addChild($xml);
		//$this->model->addAttribute(x,y);
	}
	// For output to xhtml
	function output() {
		// Just output whole model, but make sure it doesn't have xml special header
		return str_replace('<?xml version="1.0"?>','',$this->nodes->script->asXML());
	}
	// A utility function to describe the object
	function toString() {
		//$this->nodes->script->addAttribute("bug", "bad");
		echo "model to string";
		global $newline;
		return $newline.str_replace('<?xml version="1.0"?>','',$this->nodes->script->asXML());
	}
}
?>
