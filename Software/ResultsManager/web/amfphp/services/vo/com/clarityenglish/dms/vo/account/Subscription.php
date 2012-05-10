<?php
class Subscription {

	/*
	 * AMFPHP Custom Class mapping
	 */
	var $_explicitType = 'com.clarityenglish.dms.vo.account.Subscription';

	// The id for the record in the subscription table
	public $id;
	
	// This data will be a subset of the ApiInformation class
	public $name;
	public $email;
	public $country;
	public $deliveryFrequency;
	public $contactMethod;
	public $languageCode;
	public $productCode;
	public $startDate;
	public $expiryDate;
	public $password;
	public $checksum;
	public $status;
	public $discountCode;
	public $rootID;
	public $offerID;
	public $resellerID;
	
	public function Subscription($id = null) {
		
		if ($id)
			$this->id = $id;
		
	}
	
	/**
	 * Take the information out of $obj (generated by AdoDB FetchNextObject()) and set the attributes of this object based on it
	 *
	 * @param obj The object returned for the record by FetchNextObject()
	 */
	function fromDatabaseObj($obj, $db = null) {
		
		$this->id = $obj->F_SubscriptionID;
		$this->name = $obj->F_FullName;
		$this->email = $obj->F_Email;
		$this->country = $obj->F_Country;
		$this->productCode = $obj->F_ProductCode;
		
		$this->password = $obj->F_Password;
		$this->status = $obj->F_Status;
		$this->discountCode = $obj->F_DiscountCode;
		$this->rootID = $obj->F_RootID;
		$this->offerID = $obj->F_OfferID;
		$this->resellerID = $obj->F_ResellerCode;
		$this->deliveryFrequency = $obj->F_DeliveryFrequency;
		$this->contactMethod = $obj->F_ContactMethod;
		$this->startDate = substr($obj->F_StartDate,0,10).' 00:00:00';
		$this->expiryDate = substr($obj->F_ExpiryDate,0,10).' 23:59:59';
		$this->languageCode = $obj->F_LanguageCode;
		$this->checksum = $obj->F_Checksum;
	}		
	/**
	 * Convert this object to an associative array ready to pass to AutoExecute.
	 */
	function toAssocArray() {
		$array = array();
		
		$array['F_FullName'] = $this->name;
		$array['F_Email'] = $this->email;
		$array['F_Country'] = $this->country;
		$array['F_ProductCode'] = $this->productCode;
		$array['F_Password'] = $this->password;
		$array['F_Status'] = $this->status;
		$array['F_DiscountCode'] = $this->discountCode;
		$array['F_RootID'] = $this->rootID;
		$array['F_OfferID'] = $this->offerID;
		$array['F_ResellerCode'] = $this->resellerID;
		$array['F_DeliveryFrequency'] = $this->deliveryFrequency;
		$array['F_ContactMethod'] = $this->contactMethod;
		$array['F_StartDate'] = $this->startDate;
		$array['F_ExpiryDate'] = $this->expiryDate;
		$array['F_LanguageCode'] = $this->languageCode;
		$array['F_Checksum'] = $this->checksum;

		return $array;
	}
	
	/**
	 * Create this object from an array of passed data. Most likely comes from an api
	 */
	public function createFromSentFields($info) {
		
		if (isset($info['subscriptionID'])) 
			$this->id = $info['subscriptionID'];
			
		if (isset($info['name']))
			$this->name = $info['name'];
		if (isset($info['email'])) 
			$this->email = $info['email'];
		if (isset($info['orderRef']))
			$this->orderRef = $info['orderRef'];
		if (isset($info['resellerID']))
			$this->resellerID = $info['resellerID'];
		if (isset($info['country']))
			$this->country = $info['country'];
		if (isset($info['languageCode'])) 
			$this->languageCode = $info['languageCode'];
		if (isset($info['contactMethod']))
			$this->contactMethod = $info['contactMethod'];
		if (isset($info['deliveryFrequency']))
			$this->deliveryFrequency = $info['deliveryFrequency'];
		if (isset($info['password']))
			$this->password = $info['password'];

		// Check the datatype. we want to end up with a comma delimmited list
		if (isset($info['offerID'])) {
			if (is_array($info['offerID'])) {
				$this->offerID = implode(",", $info['offerID']);
			} else {
				$this->offerID = $info['offerID'];
			}
		}	
		
		// You store the unique discount code in subscription, a general one is not saved
		if (isset($info['uniqueDiscountCode']))
			$this->discountCode = $info['uniqueDiscountCode'];
			
		// Possible aliases
		if (isset($info['status'])) { 
			$this->status = $info['status'];
		} elseif (isset($info['subscriptionStatus'])) {
			$this->status = $info['subscriptionStatus'];
		}
			
	}
}	
