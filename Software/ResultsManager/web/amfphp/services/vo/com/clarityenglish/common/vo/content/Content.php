<?php
require_once(dirname(__FILE__)."/../Reportable.php");

class Content extends Reportable {

	/*
	 * AMFPHP Custom Class mapping
	 */
	var $_explicitType = 'com.clarityenglish.common.vo.content.Content';
	
	var $name;
	// I am sure that caption should be the same as name, just like this because course.xml has name and menu.xml has caption.
	// Should standardise on 'name'.
	//var $caption;
	var $enabledFlag;
	
	function getSubContentIDObjects() {
		$subContent = array();
		
		foreach ($this->getChildren() as $c) {
			$subContent[] = $c->toIDObject();
			$subContent = array_merge($subContent, $c->getSubContentIDObjects());
		}
			
		return $subContent;
	}
	
	function getChildren() {
		throw new Exception("getChildren must be overridden by child classes");
	}
	
	static public function idObjectToUID($idObject) {
		$uid = $idObject['Title'];
		if ($idObject['Course']) $uid .= ".".$idObject['Course'];
		if ($idObject['Unit']) $uid .= ".".$idObject['Unit'];
		if ($idObject['Exercise']) $uid .= ".".$idObject['Exercise'];
		
		return $uid;
	}
	
}
?>
