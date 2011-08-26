<?php

class ApiInformation {

	var $_explicitType = 'com.clarityenglish.dms.vo.account.ApiInformation';
	
	var $method;
	var $name;
	var $email;
	var $invoiceNumber;
	var $resellerID;
	var $discountCode;
	var $uniqueDiscountCode;
	var $subscriptionID;
	
	// Not passed but created 
	var $updateAccount=false;
	var $startDate;
	var $expiryDate;

	// Set some defaults that you can overwrite later if you have specific info
	var $licenceType=5; // Individual account
	var $languageCode='EN'; // International English
	var $maxStudents=1;
	var $maxTeachers=0;
	var $maxReporters=0;
	var $maxAuthors = 0;
	var $tacStatus = 2;
	var $accountType = 1;
	var $selfHost = false;
	var $loginOption = 65;
	var $accountStatus = 2;
	var $transactionTest = false;
	
	// Set address details to blank as you can't easily do isset in the templates
	var $address1 = '';
	var $address2 = '';
	var $address3 = '';
	var $city = '';
	var $state = '';
	var $ZIP = '';
	var $country = '';
	var $phone = '';
	var $mobile = '';
	var $fullAddress;
	
	// Just for testing
	var $sendEmail = true;
	
	// Fields that are not currently used
	var $deliveryFrequency=1;
	
	function createFromSentFields($info) {
	
		// Mandatory fields
		if (isset($info['method']))
			$this->method = $info['method'];
		if (isset($info['name']))
			$this->name = $info['name'];
		if (isset($info['email'])) 
			$this->email = $info['email'];
		if (isset($info['offerID'])) 
			$this->offerID = $info['offerID'];
		if (isset($info['orderRef']))
			$this->orderRef = $info['orderRef'];
		if (isset($info['resellerID']))
			$this->resellerID = $info['resellerID'];
		
		// Optional fields
		if (isset($info['password']))
			$this->password = $info['password'];
		if (isset($info['country']))
			$this->country = $info['country'];
		if (isset($info['languageCode'])) 
			$this->languageCode = $info['languageCode'];
		if (isset($info['discountCode'])) 
			$this->discountCode = $info['discountCode'];
		if (isset($info['uniqueDiscountCode'])) 
			$this->uniqueDiscountCode = $info['uniqueDiscountCode'];
		if (isset($info['emailTemplateID'])) 
			$this->emailTemplateID = $info['emailTemplateID'];
		if (isset($info['subscriptionID'])) 
			$this->subscriptionID = $info['subscriptionID'];
			
		if (isset($info['studentID']))
			$this->studentID = $info['studentID'];
		if (isset($info['contactMethod']))
			$this->contactMethod = $info['contactMethod'];
		if (isset($info['deliveryFrequency']))
			$this->deliveryFrequency = $info['deliveryFrequency'];

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

		// To help an API user/reseller with testing
		if (isset($info['transactionTest']))
			$this->transactionTest = $info['transactionTest'];
		
		// Build a full address that is just used in the email templates
		$fullAddress = $this->address1;
		if (strlen($this->address2)>0) $fullAddress.='<br/>'.$this->address2;
		if (strlen($this->address3)>0) $fullAddress.='<br/>'.$this->address3;
		if (strlen($this->city)>0) $fullAddress.='<br/>'.$this->city;
		if (strlen($this->state)>0) $fullAddress.='<br/>'.$this->state;
		if (strlen($this->ZIP)>0) $fullAddress.='<br/>'.$this->ZIP;
		if (strlen($this->country) > 0) $fullAddress.= '<br/>'.$this->country;
		$this->fullAddress = $fullAddress;
		
		// Just for testing
		if (isset($info['sendEmail']))
			$this->sendEmail = $info['sendEmail'];
	}
	// Optional fields, no need to do anything right now
	//emailTemplateID
	//discountCode
	//password (maybe we need to decrypt this now)
	
	// This just saves anything that was passed that we weren't expecting
	public function unknownFields($postInformation) {
		$nonApiInformation = array();
		foreach ($postInformation as $k => $v) {
			//echo "now testing $k<br/>";
			if (!isset($this->$k)) {
				//echo "keep $k for mirror<br/>";
				$nonApiInformation[$k]=$v;
			}
		}
		return $nonApiInformation;
	}
	public function toString() {
		$buildString = $this->orderRef.', '.$this->name.', '.$this->email.', offer='.$this->offerID.', resellerID='.$this->resellerID;
		if (isset($this->transactionTest) && $this->transactionTest) {
			$buildString.= ', transactionTest='.$this->transactionTest;
		}
		return 'API: '.$buildString;
	}
}
?>
