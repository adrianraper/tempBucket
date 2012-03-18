<?php
class Licence {

	/*
	 * AMFPHP Custom Class mapping
	 */
	var $_explicitType = 'com.clarityenglish.dms.vo.account.Licence';

	// Create a class for the licence even though it only has ID at the moment
	
	var $id;
	
	function Licence($id) {
		
		$this->id = $id;
		
	}
	
}	
