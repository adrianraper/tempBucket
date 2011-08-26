<?php

class EmailAPI {

	// I think this is only for AMFPHP - not needed here
	var $_explicitType = 'com.clarityenglish.dms.vo.trigger.Trigger';
	
	var $method;
	var $to;
	var $cc;
	var $from;
	var $subject;
	var $data; // an array of variables to put into the template
	var $templateID;
	var $transactionTest;

	function EmailAPI() {
	}
	/*
	 * Parse the condition into an object
	 *
	*/
	function createFromSentFields($info) {
	
		// Mandatory fields
		if (isset($info['method']))
			$this->method = $info['method'];
		if (isset($info['to']))
			$this->to = $info['to'];
		if (isset($info['templateID']))
			$this->templateID = $info['templateID'];
			
		// Optional fields
		if (isset($info['from'])) 
			$this->from = $info['from'];
		if (isset($info['cc'])) 
			$this->cc = $info['cc'];
		if (isset($info['data'])) 
			$this->data = $info['data'];
		if (isset($info['subject'])) 
			$this->subject = $info['subject'];
		if (isset($info['transactionTest'])) 
			$this->transactionTest = $info['transactionTest'];
	}
	
	public function toString() {
		$buildString = 'to: '.$this->to.', '.$this->templateID;
		if (isset($this->from))
			$buildString.= ', from:'.$this->from;
		if (isset($this->cc))
			$buildString.= ', cc:'.$this->cc;
		if (isset($this->subject))
			$buildString.= ', subject:'.$this->subject;
		//if (isset($this->body))
		//	$buildString.= ', body:'.$this->body;
		return 'API: '.$buildString;
	}
}
?>
