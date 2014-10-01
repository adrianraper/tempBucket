<?php

class CopyOps {
	
	var $db;
	
	private $xpath;
	
	function CopyOps($db = null) {
		$this->db = $db;
		
		// provide a default language in the session
		if (!Session::is_set('language')) Session::set('language', 'EN');
	}
	
	/**
	 * Literals are stored in resources/<language>/<title>.xml where language comes from the session (currently defaulting to EN) and the title is set
	 * in the concrete Service file (e.g. ClarityService, DMSService, IELTSService).
	 */
	private function getFilename() {
	    return dirname(__FILE__).$GLOBALS['interface_dir']."resources/".AbstractService::$title.".xml";
	}

	private function getBaseFilename() {
	    return dirname(__FILE__).$GLOBALS['interface_dir']."resources/base.xml";
	}
	
	/**
     * gh#513 This is the only function to read the file(s), returns xml string
     * gh#1050 Base literals are taken from base.xml, and then nodes are overlaid from the specific literals file
     */
	protected function getXMLFromFile() {
		if (!file_exists($this->getFilename()))
			throw new Exception($this->getFilename()." file not found");
		
		$xml = new DOMDocument();
		$xml->load($this->getBaseFilename());
        $xmlXPath = new DOMXpath($xml);

        $overlay = new DOMDocument();
        $overlay->load($this->getFilename());
        $overlayXPath = new DOMXPath($overlay);

        // Go through the $overlay, replacing or creating elements in $xml
        /** @var \DOMNode $node */
        foreach ($overlay->getElementsByTagName("lit") as $node) {
            // For each literal construct its xpath
            $language = $node->parentNode->parentNode->attributes->getNamedItem('name')->nodeValue;
            $group = $node->parentNode->attributes->getNamedItem('name')->nodeValue;
            $literal = $node->attributes->getNamedItem('name')->nodeValue;
            $parentPath = "/literals/language[@name='$language']/group[@name='$group']";
            $literalPath = $parentPath."/lit[@name='$literal']";

            // Import the node into the original document
            $importedNode = $xml->importNode($node, true);

            // Now use the xpath to locate the matching node in the base
            $matchingNodes = $xmlXPath->query($literalPath);
            if ($matchingNodes->length == 0) {
                // The node doesn't exist so add it to the parent
                $xmlXPath->query($parentPath)->item(0)->appendChild($importedNode);
            } else {
                // The node exists, so replace it
                $oldNode = $matchingNodes->item(0);
                $oldNode->parentNode->replaceChild($importedNode, $oldNode);
            }
        }

		return $xml->saveXML();
	}
	
	protected function getXPath($code = null) {
		if (!$this->xpath) {
			
			$doc = new DOMDocument();
			$doc->loadXML($this->getXMLFromFile($code));
			
			$this->xpath = new DOMxpath($doc);
		}
		
		return $this->xpath;
	}
	
	/**
	 * Read and return the XML literals document as a string
	 * gh#39 pass language code
	 */
	public function getCopy($code = null) {
		// gh#39
		//if ($code) Session::set('languageCode', $code);
		if ($code) Session::set('language', $code);
		
		// gh#513
		return $this->getXMLFromFile($code);
	}
	
	/**
	 * Returns the copy as an array with indexes being each literal id, and values being the text
	 */
	function getCopyArray() {
		$xpath = $this->getXPath();
		$elements = $xpath->query("/literals/language[@code='".Session::get('language')."']//lit");
		
		$object = array();
		foreach ($elements as $element)
			$object[$element->getAttribute("name")] = $element->nodeValue;
		
		return $object;
	}
	
	function getCopyDOMForLanguage() {
		$xpath = $this->getXPath();
		
		$elements = $xpath->query("/literals/language[@code='".Session::get('language')."']");
		
		return $elements->item(0);
	}
	
	/**
	 * This duplicates the functionality of getCopyForId in CopyProxy on the client.
	 */
	function getCopyForId($id, $replaceObj = null, $languageCode = null) {
		$xpath = $this->getXPath();
		
		// TODO: This needs to respect the language code once we've decided how it will work
		$elements = $xpath->query("/literals/language[@code='".(($languageCode) ? $languageCode : Session::get('language'))."']//lit[@name='".$id."']");
		
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
		$element = $xpath->evaluate("string(/literals/language[@code='".(($languageCode) ? $languageCode : Session::get('language'))."']//lit[@name='".$id."']/@code)");
		
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