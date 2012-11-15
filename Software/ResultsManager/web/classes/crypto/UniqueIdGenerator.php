<?php
require_once(dirname(__FILE__)."/../Session.php");

class UniqueIdGenerator {
	
	public static function getUniqId() {
		// Although this method would be best, it creates integers too large for the BIGINT column in the database 
		/*$uniqId = uniqid();
		
		// Get the user id if there is one
		if (Session::is_set('userID'))
			$uniqId .= Session::get('userID');
		
		return number_format(hexdec($uniqId), 0, '', '');*/
		
		// Use an epoch at the beginning of 2012 to save some digits
		$uniqId = microtime(true) - 1325376000;
		$uniqId = round($uniqId * 10000);
		
		// Add the user id
		if (Session::is_set('userID'))
			$uniqId .= Session::get('userID');
		
		// Add a single random digit (this helps a lot with collisions)
		$uniqId .= rand(0, 9);
		
		// Sleep for 1 microsecond.  This is no use for multi-threaded or distributed servers, but in practice it will help with requests in a single session
		usleep(1);
		
		return $uniqId;
	}
	
}