<?php

class CopyOps {
	
	var $db;
	
	private $xpath;
	
	function CopyOps($db = null) {
		$this->db = $db;
		
		// provide a default language in the session
		if (!Session::is_set('languageCode')) Session::set('languageCode', 'EN');
	}
	
	/**
	 * Literals are stored in resources/<language>/<title>.xml where language comes from the session (currently defaulting to EN) and the title is set
	 * in the concrete Service file (e.g. ClarityService, DMSService, IELTSService).
	 */
	private function getFilename() {
	    // issue:#20 add language code in one file
		//return dirname(__FILE__).$GLOBALS['interface_dir']."resources/".strtolower((Session::is_set('languageCode')) ? Session::get('languageCode') : "EN")."/".AbstractService::$title.".xml";
		return dirname(__FILE__).$GLOBALS['interface_dir']."resources/".AbstractService::$title.".xml";
	}
	
	private function getXPath() {
		if (!$this->xpath) {
			// AR added this check too. If the file doesn't exist return false
			if (!file_exists($this->getFilename()))
				throw new Exception($this->getFilename()." file not found");
			
			$doc = new DOMDocument();
			$doc->load($this->getFilename());
			
			$this->xpath = new DOMxpath($doc);
		}
		
		return $this->xpath;
	}
	
	/**
	 * Read and return the XML literals document as a string
	 */
	function getCopy() {
		// If the file doesn't exist return false
		if (!file_exists($this->getFilename()))
			throw new Exception($this->getFilename()." not found");
		
		// Read the file
		$contents = file_get_contents($this->getFilename());
		
		// Return the file as a string to be converted to XML on the client
		//issue:#20
		//return utf8_decode($contents);
		return $contents;
	}
	
	/**
	 * Returns the copy as an array with indexes being each literal id, and values being the text
	 */
	function getCopyArray() {
		$xpath = $this->getXPath();
		$elements = $xpath->query("/literals/language[@code='".Session::get('languageCode')."']//lit");
		
		$object = array();
		foreach ($elements as $element)
			$object[$element->getAttribute("name")] = $element->nodeValue;
		
		return $object;
	}
	
	function getCopyDOMForLanguage() {
		$xpath = $this->getXPath();
		
		$elements = $xpath->query("/literals/language[@code='".Session::get('languageCode')."']");
		
		return $elements->item(0);
	}
	
	/**
	 * This duplicates the functionality of getCopyForId in CopyProxy on the client.
	 */
	function getCopyForId($id, $replaceObj = null, $languageCode = null) {
		$xpath = $this->getXPath();
		
		// TODO: This needs to respect the language code once we've decided how it will work
		$elements = $xpath->query("/literals/language[@code='".(($languageCode) ? $languageCode : Session::get('languageCode'))."']//lit[@name='".$id."']");
		
		// If no element was found return the id
		if ($elements->length == 0)
			return $id;
		
		// Otherwise get the textual content of the lit node
		$str = $elements->item(0)->textContent;
		
		// Do the substitution if required
		if ($replaceObj) {
			foreach ($replaceObj as $searchString => $replaceString)
				$str = preg_replace("/\{".$searchString."\}/", $replaceString, $str);
		}
		
		return $str;
	}
	
	function getCodeForId($id, $languageCode = null) {
		$xpath = $this->getXPath();
		
		// TODO: This needs to respect the language code once we've decided how it will work
		$element = $xpath->evaluate("string(/literals/language[@code='".(($languageCode) ? $languageCode : Session::get('languageCode'))."']//lit[@name='".$id."']/@code)");
		
		// If no element was found, default to 1
		if (!$element) {
			return 1;
		} else {
			return $element;
		}
	}
	
	function getExceptionForId($id, $replaceObj = null, $languageCode = null) {
		$copy = $this->getCopyForId($id, $replaceObj, $languageCode);
		$code = $this->getCodeForId($id, $languageCode);
		return new Exception($copy, $code);
	}
	
}