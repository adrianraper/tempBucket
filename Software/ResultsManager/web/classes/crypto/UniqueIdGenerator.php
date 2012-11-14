<?php
require_once(dirname(__FILE__)."/../Session.php");

class UniqueIdGenerator {
	
	public static function getUniqId() {
		// Start with a uniqid()
		$uniqId = uniqid();
		
		// Get the user id if there is one
		if (Session::is_set('userID'))
			$uniqId .= Session::get('userID');
		
		return $uniqId;
	}
	
}