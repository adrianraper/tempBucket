<?php

class CopyOps {
	
	var $db;
	
	function CopyOps($db = null) {
		$this->db = $db;
		
		// Protect against directory traversal. AR In what way?
		// Note that the working folder for CopyOps.php is shown as /amfphp/services
		// which gives the following filename (seems legal in the browser, but not from php command line mode)
		// copyOpsFile=../.././/literals.xml
		// Now it seems working folder when you are here is current=D:\fixbench\Software\ResultsManager\web\classes
		//$this->filename = "../../".$GLOBALS['interface_dir']."/literals.xml";
		// This is also fine in the browser, not in CMD
		//$this->filename = "../../".$GLOBALS['interface_dir']."literals.xml";
		// This fails everywhere
		//$this->filename = "../literals.xml";
		// Try this. It seems to work everywhere.
		// $this->filename = dirname(__FILE__)."/../literals.xml";
		// So pick it up from the config.php
		$this->filename = dirname(__FILE__).$GLOBALS['interface_dir']."literals.xml";
		
		//$this->filename = "../../".$GLOBALS['interface_dir']."/literals.xml";
		//NetDebug::trace("current=".dirname(__FILE__));
		//echo "interface_dir=".$GLOBALS['interface_dir']."<br/>";
		//echo "file=".$this->filename."<br/>";
		//echo "current=".dirname(__FILE__)."<br/>";

	}
	
	/**
	 * Read and return the XML literals document as a string
	 */
	function getCopy() {
		// If the file doesn't exist return false
		if (!file_exists($this->filename))
			throw new Exception("literals.xml not found");
		
		// Read the file
		$contents = file_get_contents($this->filename);
		
		// Return the file as a string to be converted to XML on the client
		return utf8_decode($contents);
	}
	
	/**
	 * Returns the copy as an array with indexes being each literal id, and values being the text
	 */
	function getCopyArray() {
		// AR added this check too. If the file doesn't exist return false
		if (!file_exists($this->filename))
			throw new Exception("literals.xml not found");
		
		$doc = new DOMDocument();
		$doc->load($this->filename);
		
		// provide a default
		if (!Session::is_set('languageCode')) Session::set('languageCode', 'EN');
		$xpath = new DOMxpath($doc);
		$elements = $xpath->query("/literals/language[@code='".Session::get('languageCode')."']//lit", $doc);
		
		$object = array();
		foreach ($elements as $element)
			$object[$element->getAttribute("name")] = $element->nodeValue;
		
		return $object;
	}
	
	function getCopyDOMForLanguage() {
		$doc = new DOMDocument();
		$doc->load($this->filename);
		
		$xpath = new DOMxpath($doc);
		
		$elements = $xpath->query("/literals/language[@code='".Session::get('languageCode')."']", $doc);
		
		return $elements->item(0);
	}
	
	/**
	 * This duplicates the functionality of getCopyForId in CopyProxy on the client.
	 */
	function getCopyForId($id, $replaceObj = null, $languageCode = null) {
		$doc = new DOMDocument();
		$doc->load($this->filename);
		
		$xpath = new DOMxpath($doc);
		
		// TODO: This needs to respect the language code once we've decided how it will work
		$elements = $xpath->query("/literals/language[@code='".(($languageCode) ? $languageCode : Session::get('languageCode'))."']//lit[@name='".$id."']", $doc);
		
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
	
}

?>
