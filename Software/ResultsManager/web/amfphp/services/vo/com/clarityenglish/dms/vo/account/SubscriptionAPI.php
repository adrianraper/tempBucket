<?php

class SubscriptionApi {

	var $_explicitType = 'com.clarityenglish.dms.vo.account.SubscriptionApi';
	
	public $method;
	public $subscription;
	
	public $transactionTest = false;

	// This data is part of the api, but will not be saved anywhere
	var $address1 = '';
	var $address2 = '';
	var $address3 = '';
	var $city = '';
	var $state = '';
	var $ZIP = '';
	var $phone = '';
	var $mobile = '';
	var $fullAddress;
	public $discountCode;
	public $paymentMethod;
	public $paymentRef;
	
	// The following are defaults used when creating an account
	public $invoiceNumber;
	var $licenceType = 5; // Individual account
	var $maxStudents = 1;
	var $maxTeachers = 0;
	var $maxReporters = 0;
	var $maxAuthors = 0;
	var $tacStatus = 2;
	var $accountType = 1;
	var $selfHost = false;
	var $loginOption = 1; // name?
	var $accountStatus = 2;
	
	// These are picked up when you are creating an account
	public $offerName; 
	public $resellerEmail = '';
	
	function SubscriptionApi() {
		
	}
	
	public function createFromSentFields($info) {
	
		// Mandatory fields
		if (isset($info['method']))
			$this->method = $info['method'];
			
		// Build a subscription object from the sent fields
		$this->subscription = new Subscription();
		$this->subscription->createFromSentFields($info);
		
		// Optional fields
		if (isset($info['emailTemplateID'])) 
			$this->emailTemplateID = $info['emailTemplateID'];
		if (isset($info['studentID']))
			$this->studentID = $info['studentID'];
		if (isset($info['discountCode'])) 
			$this->discountCode = $info['discountCode'];
		// It probably makes more sense to put start date here than in subscription since it is very specific
		// to the api call. It will be very rare as practically always just start the subscription now.
		//if (isset($info['startDate'])) 
		//	$this->startDate = $info['startDate'];

		if (isset($info['loginOption'])) 
			$this->loginOption = $info['loginOption'];
			
		// For iLearnIELTS we expect the following so we can build delivery details for DHL
		if (isset($info['address1']))
			$this->address1 = $info['address1'];
		if (isset($info['address2']))
			$this->address2 = $info['address2'];
		if (isset($info['address3']))
			$this->address2 = $info['address3'];
		if (isset($info['city']))
			$this->city = $info['city'];
		if (isset($info['state']))
			$this->state = $info['state'];
		if (isset($info['ZIP']))
			$this->ZIP = $info['ZIP'];
		if (isset($info['phone']))
			$this->phone = $info['phone'];
		if (isset($info['mobile']))
			$this->mobile = $info['mobile'];
		if (isset($info['paymentMethod']))
			$this->paymentMethod = $info['paymentMethod'];
		if (isset($info['paymentRef']))
			$this->paymentRef = $info['paymentRef'];

		// To help an API user/reseller with testing
		if (isset($info['transactionTest']))
			$this->transactionTest = ($info['transactionTest']=='true') ? true : false;
		if (isset($info['sendEmail']))
			$this->sendEmail = $info['sendEmail'];
		
		// Build a full address that is just used in the email templates
		$fullAddress = $this->address1;
		if (strlen($this->address2)>0) $fullAddress.='<br/>'.$this->address2;
		if (strlen($this->address3)>0) $fullAddress.='<br/>'.$this->address3;
		if (strlen($this->city)>0) $fullAddress.='<br/>'.$this->city;
		if (strlen($this->state)>0) $fullAddress.='<br/>'.$this->state;
		if (strlen($this->ZIP)>0) $fullAddress.='<br/>'.$this->ZIP;
		if (strlen($this->subscription->country) > 0) $fullAddress.= '<br/>'.$this->subscription->country;
		$this->fullAddress = $fullAddress;
		
		if (isset($info['dbHost'])) {
			$this->dbHost = $info['dbHost'];
		} else {
			$this->dbHost = 0;
		}
		
	}
	
	// This just saves anything that was passed that we weren't expecting
	public function unknownFields($postInformation) {
		$nonApiInformation = array();
		foreach ($postInformation as $k => $v) {
			//echo "now testing $k<br/>";
			if (!isset($this->$k) && !isset($this->subscription->$k)) {
				//echo "keep $k for mirror<br/>";
				$nonApiInformation[$k]=$v;
			}
		}
		return $nonApiInformation;
	}
	
	public function toString() {
		try {
			$buildString = $this->subscription->orderRef.', '.$this->subscription->name.', '.$this->subscription->email.', offer='.$this->subscription->offerID.', resellerID='.$this->subscription->resellerID;
			if (isset($this->transactionTest) && $this->transactionTest) {
				$buildString.= ', transactionTest='.$this->transactionTest;
			}
		} catch (Exception $e) {
			$buildString = 'not many details sent';
		}
		return 'API: '.$buildString;
	}
}

