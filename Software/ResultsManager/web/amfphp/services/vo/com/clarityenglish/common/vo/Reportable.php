<?php
class Reportable {
	
	/*
	 * AMFPHP Custom Class mapping
	 */
	var $_explicitType = 'com.clarityenglish.common.vo.Reportable';
	
	// The ID of the Content or Manageable in the XML or database
	var $id;
	
	protected $parent;
	
	function setParent($parent) {
		$this->parent = $parent;
	}
	
	function getParent() {
		return $this->parent;
	}
	
	/**
	 * Return the id for the purposes of making an IDObject.  Usually this is just the ID, but since Titles actually use their
	 * productCode as an id (and php doesn't implement getter functions) make a method so we can override it in Title.
	 */
	function getIDForIDObject() {
		return $this->id;
	}
	
	/**
	 * Encode the reportable tree (this and all parents) into an associative array with each class mapped to its id.  For example:
	 * { Exercise: 23483, Unit: 1, Course: 1434, Title: 0 }
	 * 
	 * @return An object
	 */
	function toIDObject() {
		$reportable = $this;
		
		$reportableObj = array();
		do {
			$reportableObj[get_class($reportable)] = $reportable->getIDForIDObject();
			$reportable = $reportable->getParent();
		} while ($reportable);
		
		return $reportableObj;
	}
	
	/**
	 * html_entities/special_chars don't recognise &apos; as a valid entity so we need to explicitly encode it
	 */
	static function apos_encode($string) {
		// PHP 5.3
		$pattern = "/'/";
		$replacement = '&apos;';
		return preg_replace($pattern, $replacement, $string);
	}
	
	/**
	 * html_entities/special_chars don't recognise &apos; as a valid entity so we need to explicitly decode it
	 */
	static function apos_decode($string) {
		// PHP 5.3
		$pattern = "/&apos;/";
		$replacement = "'";
		return preg_replace($pattern, $replacement, $string);
	}
	
}
?>
