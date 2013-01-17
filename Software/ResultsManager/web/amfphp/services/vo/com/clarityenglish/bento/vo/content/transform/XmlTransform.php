<?php
abstract class XmlTransform {
	
	var $_explicitType = 'com.clarityenglish.bento.vo.content.transform.XmlTransform';
	
	const SET_ATTRIBUTES = "set_attributes";
	const SET_CHILDREN = "set_children";
	
	private $transforms = array();
	
	protected function setAttributes($xml, $values) {
		foreach ($values as $name => $value)
			$this->setAttribute($xml, $name, $value);
	}
	
	protected function setAttribute($xml, $name, $value) {
		if ($xml[$name]) {
			$xml[$name] = $value;
		} else {
			$xml->addAttribute($name, $value);
		}
	}
	
	protected function addChild($xml, $xmlString) {
		$dom = dom_import_simplexml($xml);
		$fragment = $dom->ownerDocument->createDocumentFragment();
		$fragment->appendXML($xmlString);
		
		$dom->appendChild($fragment);
	}
	
	public function reset() {
		$this->transforms = array();
	}
	
	public function getTransforms() {
		return $this->transforms;
	}
	
}