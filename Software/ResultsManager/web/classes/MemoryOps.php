<?php
class MemoryOps {

	/**
	 * This class manages the user's memory. This is used for storing product specific information
	 * that needs to be retained between sessions.
	 * 
	 * Memories are first sorted by productCode
	 * <product code="59">
	 * and then either follow common nodes, or product specific ones
	 * 
	 * Common nodes:
	 *   <bookmark>
	 *   
	 * Specific nodes:
	 *   For TB6weeks
	 *     <CEF>B2</CEF>
	 *     <subscription startDate="2014-10-27" valid="true" />
	 */
	
	var $db;
	private $productCode;
	private $userId;
	private $memory; // as DOMDocument
	
	function MemoryOps($db) {
		$this->db = $db;
		$this->copyOps = new CopyOps();
		
		$this->productCode = Session::get('productCode');
		$this->userId = Session::get('userID');
		
		// NOTE: Is it safe or even a good idea to get this immediately?
		if (isset($this->userId) && isset($this->productCode))
			$this->memory = $this->getMemoryFromDb();
			
	}
	public function __destruct() {
		unset($this->memory);
	}
	
	/**
	 * If you changed the db, you'll need to refresh it here
	 * Not a very neat function...
	 */
	function changeDB($db) {
		$this->db = $db;
	}

	// NOTE: will you ever need to do this?
	function changeProductCode($productCode) { }
	
	// NOTE: Not sure if this should throw exceptions if user doesn't exist, or just not set the memory
	public function getMemoryFromDb($productCode = null) {
		$pc = ($productCode) ? $productCode : $this->productCode;
		
		$sql = <<<EOD
			SELECT u.*
			FROM T_User u
			WHERE u.F_UserID = ?
EOD;
		$rs = $this->db->Execute($sql, array($this->userId));
		$recordCount = $rs->RecordCount();
		switch ($recordCount) {
			case 0:
				throw new Exception("asking for memory of a user who doesn't exist");
				break;
				
			case 1:
				$dbObj = $rs->FetchNextObj();
				break;
				
			default:
				throw new Exception("asking for memory of many users at once");
				break;
		}
		// NOTE: The creation of memory should go somewhere neater...
		// If this user has no memory at all, create one!
		if (!isset($dbObj->F_Memory) || ($dbObj->F_Memory == '')) {
			$dbObj->F_Memory = '<memory />';
		}
		
		$xml = new DOMDocument();
		$xml->loadXML($dbObj->F_Memory);
		$xpath = new DOMXPath($xml);
		$xmlNodes = $xpath->query("//product[@code='$pc']");
		
		switch ($xmlNodes->length) {
			case 0:
				// If the user has no memory for this product, create one
				$newNode = $xml->createElement('product');
				$newNode->setAttribute('code', $pc);
				$xml->getElementsByTagName('memory')->item(0)->appendChild($newNode);
				AbstractService::$debugLog->info("created memory for pc=".$pc);
				return $xml;
				break;
			case 1:
				return $xml;
				break;
			default:
				throw new Exception('Memory has more than one node for product '.$pc);
		}
		return null;
	}
	
	// Not used...?
	public function getMemory($section, $productCode = null) {
		$pc = ($productCode) ? $productCode : $this->productCode;
		$xpath = new DOMXPath($this->memory);
		$xmlNodes = $xpath->query("//product[@code='$pc']/$section");
		if ($xmlNodes->length) 
			return null;
		return $xmlNodes;
	}
	
	// TODO: What happens if this user is running another Clarity program at the same time that also updates memory?
	public function writeMemory() {
		$sql = <<<EOD
			UPDATE T_User u
			SET u.F_Memory = ?
			WHERE u.F_UserID = ?
EOD;
		$rc = $this->db->Execute($sql, array($this->toString(), $this->userId));
		return $rc;
	}
	
	/**
	 * This is a function to handle specific memory setting within the class.
	 * It is called by any service that wants to write data to memory.
	 */
	public function addToMemory($section, $value, $productCode = null) {
		$pc = ($productCode) ? $productCode : $this->productCode;
		$doc = new DOMDocument();
		
		switch ($section) {
			// NOTE: the $value passed might be a simple value ('B2') or it might be a node <startingPoint course='123' unit='123' exercise='123' />
			case 'subscription':
				$newNode = $doc->loadXML('<'.$section.' startDate="'.$value.'" valid="true" frequency="2 days" />');
				$this->addElement($section, $doc->getElementsByTagName($section)->item(0), $pc);
				break;
				
			case 'bookmark':
			case 'CEF':
			case 'level':
			default:
				$newNode = $doc->loadXML('<'.$section.'>'.$value.'</'.$section.'>');
				$this->addElement($section, $doc->getElementsByTagName($section)->item(0), $pc);
				break;
		}
		AbstractService::$debugLog->info('after adding, $this->memory='.$this->toString());
	}
	
	/**
	 * Add a chunk of XML to the memory. This should merge with any existing XML
	 * 
	 * @param DOMNode $node
	 */
	public function addElement($section, $node, $productCode = null) {
		$mem = $this->getElement($section, $productCode);
		$pc = ($productCode) ? $productCode : $this->productCode;
		
		// This element does not exist, so add it
		if (!$mem) {
			AbstractService::$debugLog->info('new node '.$section.' in pc='.$pc);
			
			$xpath = new DOMXPath($this->memory);
			$xmlNodes = $xpath->query("//product[@code='$pc']");
			
			// If the user has no memory for this product, create one
			if ($xmlNodes->length == 0) {
				$newNode = $this->memory->createElement('product');
				$newNode->setAttribute('code', $pc);
				$this->memory->getElementsByTagName('memory')->item(0)->appendChild($newNode);
				AbstractService::$debugLog->info('need to add memory for pc='.$pc.' it is '.$this->toString());
				$xmlNodes = $xpath->query("//product[@code='$pc']");
			}
			
			$importedNode = $this->memory->importNode($node, true);
			$basenode = $xmlNodes->item(0);
			$basenode->appendChild($importedNode);
			
		// Otherwise replace it (what about merging??)
		} else { 
			AbstractService::$debugLog->info('replace node '.$section.' in pc='.$pc);
			$mem->parentNode->removeChild($mem);
			
			$pc = ($productCode) ? $productCode : $this->productCode;
			$xpath = new DOMXPath($this->memory);
			$xmlNodes = $xpath->query("//product[@code='$pc']");
			
			$importedNode = $this->memory->importNode($node, true);
			$basenode = $xmlNodes->item(0);
			$basenode->appendChild($importedNode);
		}
	}
	
	public function getElement($nodeName, $productCode = null) {
		$pc = ($productCode) ? $productCode : $this->productCode;
		if (!$this->memory)
			return null;
			
		$xpath = new DOMXPath($this->memory);
		$xmlNodes = $xpath->query("//product[@code='$pc']/$nodeName");
		
		if ($xmlNodes->length > 0)
			return $xmlNodes->item(0);
	}

	public function toString() {
		if (isset($this->memory))
			return $this->memory->saveXML();
		return '';
	}
}