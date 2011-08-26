<?php
require_once(dirname(__FILE__)."/../Reportable.php");

class Manageable extends Reportable {
	
	/*
	 * AMFPHP Custom Class mapping
	 */
	var $_explicitType = 'com.clarityenglish.common.vo.manageable.Manageable';
	
	var $name;
	var $custom1;
	var $custom2;
	var $custom3;
	var $custom4;
	
	/**
	 * Get all the ids of the subgroups below this level.  This is used when deleting manageables and overridden by concrete manageables.
	 */
	function getSubGroupIds() {
		return array();
	}
	
	/**
	 * Get all the ids of the users below this level.  This is used when deleting manageables and overridden by concrete manageables.
	 */
	function getSubUsersIds() {
		return array();
	}
	
	/**
	 * Serialize this manageable to an xml node.  Overridden by concrete classes.
	 */
	function toXMLNode() {
		return null;
	}

}
?>
