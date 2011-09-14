<?php
//
// Common for all sections in an exercise
//
class Content{
	
	var $paragraphs = Array();
	var $mediaNodes = Array();
	
	function addMediaNode($xmlObj) {
		$this->mediaNodes[] = new MediaNode($xmlObj, $this);
	}
	function getMediaNodes() {
		return $this->mediaNodes;
	}
	function addParagraph($xmlObj) {
		$this->paragraphs[] = new Paragraph($xmlObj, $this);
	}
	function getParagraphs() {
		return $this->paragraphs;
	}
	//function getClass() {
		// This must always be overwritten in the specific section
	//}
	// Just for debugging
	function getText() {
		$buildText='';
		foreach ($this->getParagraphs() as $paragraph) {
			$buildText.=$paragraph->getText();
		}
		foreach ($this->getMediaNodes() as $mediaNode) {
			$buildText.=$mediaNode->toString();
		}
		return $buildText;
	}
}
?>
