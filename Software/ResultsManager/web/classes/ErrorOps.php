<?php

class ErrorOps {
	
	function ErrorOps() {
		
		$this->filename = dirname(__FILE__).$GLOBALS['interface_dir']."errorCodes.xml";

	}
	
	/**
	 * Read and return the XML literals document as a string
	 */
	function getErrorCodes() {
		// If the file doesn't exist return false
		if (!file_exists($this->filename))
			throw new Exception("errorCodes.xml not found");
		
		// Read the file
		$contents = file_get_contents($this->filename);
		
		// Return the file as a string to be converted to XML on the client
		return utf8_decode($contents);
	}
	
	/**
	 * Returns the error code associated with a string
	 */
	function getCode($name, $languageCode = 'EN') {
		
		if (!file_exists($this->filename))
			throw new Exception("errorCodes.xml not found");
				
		$doc = new DOMDocument();
		$doc->load($this->filename);
		
		$xpath = new DOMxpath($doc);
		$elements = $xpath->query("/errors/language[@code='".$languageCode."']//error[@const='".$name."']", $doc);
		
		// If no element was found return the generic one - 
		if ($elements->length == 0)
			return 100;
		
		// Otherwise get the textual content of the lit node
		$str = $elements->item(0)->textContent;
		
		return $str;
	}
	
}
