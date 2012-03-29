<?php

class ErrorOps {
	
	function ErrorOps() {
		
		$this->filename = dirname(__FILE__).$GLOBALS['interface_dir']."errorCodes.xml";
		//if (!file_exists($this->filename))
		//	throw new Exception($this->filename." not found");
		
	}
	
	/**
	 * Read and return the XML error codes document as a string
	 */
	function getCopy() {
		
		// Read the file
		$contents = file_get_contents($this->filename);
		
		// Return the file as a string to be converted to XML on the client
		return utf8_decode($contents);
	}
	
	/**
	 * Returns the error number based on the name
	 */
	function getErrorNumber($errorName) {
		switch ($errorName) {
			case 'no_such_user':
				return 200;
		}
		return null;
	}
	
}
