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
	 * Returns the error code number associated with a string
	 * Adrian is just testing this function; it should be getErrorNumber instead
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
		//$str = $elements->item(0)->textContent;
		$nodeAttributes = $elements->item(0)->attributes();
		$codeNum = $nodeAttributes['code'];
		
		return $codeNum;
	}
	/**
	 * Returns the error number based on the name
	 */
	function getErrorNumber($errorName) {
		switch ($errorName) {
			case 'no_such_user':
				return 200;
			default:
				return 100;
		}
		return 100;
	}
	
}
