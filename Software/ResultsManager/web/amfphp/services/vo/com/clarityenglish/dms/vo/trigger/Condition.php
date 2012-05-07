<?php

class Condition {

	/*
	 * AMFPHP Custom Class mapping
	 */
	var $_explicitType = 'com.clarityenglish.dms.vo.trigger.Condition';
	
	var $method;
	var $expiryDate;
	var $registrationDate;
	var $timeStamp;
	var $select;
	var $update;
	var $accountType;
	var $accountStatus;
	var $notAccountStatus;
	var $licenceType;
	var $notLicenceType;
	// v3.1 EMU
	var $deliveryFrequency;
	var $contactMethod;
	var $productCode;
	var $userStartDate;
	var $active;
	// v3.4.3
	var $selfHost;
	// v3.5 For subscription reminders
	var $startDate;
	var $startDay;
	
	function Condition($conditionString, $timeStamp = null ) {
		$this->timeStamp = $timeStamp;
		$this->parseCondition($conditionString);
		//return $this;
	}
	
	/*
	 * Parse the condition into an object
	 * Examples: method=getAccounts&expiryDate={now}+30d&accountType=trial 
	*/
	function parseCondition($conditionString, $timeStamp = null ) {
		//echo $conditionString."<br/>";
		// Note that parse_str turns + into a space.
		parse_str(str_replace("+","%2B",$conditionString), $conditionArray);
		//print_r($conditionArray);
		if (isset($conditionArray['method'])) 
			//echo "got a method<br/>";
			$this->method = $conditionArray['method'];
		if (isset($conditionArray['expiryDate'])) 
			$this->expiryDate = $this->evaluateDateVariables($conditionArray['expiryDate']);
		if (isset($conditionArray['startDate'])) 
			$this->startDate = $this->evaluateDateVariables($conditionArray['startDate']);
		if (isset($conditionArray['startDay'])) 
			$this->startDay = $this->evaluateDateVariables($conditionArray['startDay']);
		if (isset($conditionArray['registrationDate'])) 
			$this->registrationDate = $this->evaluateDateVariables($conditionArray['registrationDate']);
		// Must be a clever PHP way to do this...
		if (isset($conditionArray['accountType'])) 
			$this->accountType = $conditionArray['accountType'];
		if (isset($conditionArray['accountStatus'])) 
			$this->accountStatus = $conditionArray['accountStatus'];
		if (isset($conditionArray['notAccountStatus'])) 
			$this->notAccountStatus = $conditionArray['notAccountStatus'];
		if (isset($conditionArray['licenceType'])) 
			$this->licenceType = $conditionArray['licenceType'];
		if (isset($conditionArray['notLicenceType'])) 
			$this->notLicenceType = $conditionArray['notLicenceType'];
		if (isset($conditionArray['productCode'])) 
			$this->productCode = $conditionArray['productCode'];
		if (isset($conditionArray['notProductCode'])) 
			$this->notProductCode = $conditionArray['notProductCode'];
		if (isset($conditionArray['contactMethod'])) 
			$this->contactMethod = $conditionArray['contactMethod'];
		if (isset($conditionArray['deliveryFrequency'])) 
			$this->deliveryFrequency = $conditionArray['deliveryFrequency'];
		// Note that a userStartDate that references frequency NEEDS the following condition to be evaluated after the above one
		// the order in the condition in the db doesn't matter - just this code.
		// But actually we will normally read deliveryFrequency from the account table, so do this evaluation in usersInAccount too
		if (isset($conditionArray['userStartDate'])) 
			$this->userStartDate = $this->evaluateDateVariables($conditionArray['userStartDate']);
		if (isset($conditionArray['select'])) 
			$this->select = $conditionArray['select'];
		if (isset($conditionArray['update'])) 
			$this->update = $conditionArray['update'];
		if (isset($conditionArray['active'])) 
			$this->active = $conditionArray['active'];
		// v3.4.3
		if (isset($conditionArray['selfHost'])) 
			$this->selfHost = $conditionArray['selfHost'];
	}
	/*
	 * Build a query string from the condition - is this just for debugging?
	 * Examples: method=getAccounts?expiryDate={now}+30d 
	*/
	function toString() {
		// Must be a clever PHP way to do this...
		$result = "?method=".$this->method;
		if ($this->expiryDate)
			$result .= "&expiryDate=".$this->expiryDate;
		if ($this->startDate)
			$result .= "&startDate=".$this->startDate;
		if ($this->registrationDate)
			$result .= "&registrationDate=".$this->registrationDate;
		if ($this->select)
			$result .= "&select=".$this->select;
		if ($this->update)
			$result .= "&update=".$this->update;
		if ($this->active)
			$result .= "&active=".$this->active;
		if ($this->selfHost)
			$result .= "&selfHost=".$this->selfHost;
		return $result;
	}
	/*
	 * use preset variables to evaluate the condition
	*/
	function evaluateDateVariables($expr) {
		// Note that parse_str turns + into a space, so turn it back
		$base = str_replace("%2B","+",$expr);
		//echo "base=".$base."<br/>";
		// for dates
		// expecting {reference}, +/-, number, unit 
		// eg {now}+3d or {now}-1y
		// Can I have fractions of a number? {now}-1.5m?
		//sscanf($base, "{%[a-z]}%d%s", $reference, $number, $unit);
		sscanf($base, "{%[a-z]}%f%s", $reference, $number, $unit);
		//echo "ref=$reference number=$number unit=$unit<br/>";
		switch ($reference) {
			case "yearend":
				$baseTimeStamp = mktime(0, 0, 0, 12, 31, date("Y")+1);
				break;
			// v3.5 If you want to get any date that matches today's day part.
			// But this probably doesn't happen here.
			case "day":
				// Sometimes you will have passed a triggerDate, which is used instead of now
				if ($this->timeStamp) {
					$built = date('d',$this->timeStamp);
				} else {
					$built = date('d');
				}
				// You don't want to do anything else with this
				return $built;
				break;
			case "now":
			default:
				// In case DateTime is too experimental
				//$baseTimeStamp = new DateTime();
				// Sometimes you will have passed a triggerDate, which is used instead of now
				if ($this->timeStamp) {
					$baseTimeStamp = $this->timeStamp;
				} else {
					$baseTimeStamp = time();
				}
				break;
		}
		switch ($unit) {
			case "h":
				// In case date_add is too experimental
				//$built = date('Y-m-d', date_add($baseTimeStamp, new DateInterval("P$numberD")));
				$built = date('Y-m-d', $baseTimeStamp + ($number * 3600)); // seconds in an hour
				break;
			case "d":
				//$built = date('Y-m-d', date_add($baseTimeStamp, new DateInterval("P$numberD")));
				$built = date('Y-m-d', $baseTimeStamp + ($number * 86400)); // seconds in a day
				break;
			case "w":
				$built = date('Y-m-d', $baseTimeStamp + ($number * 604800)); // seconds in a week - on average
				break;
			case "m":
				//$built = date('Y-m-d', date_add($baseTimeStamp, new DateInterval("P$numberM")));
				$built = date('Y-m-d', $baseTimeStamp + ($number * 2629744)); // seconds in a month - on average
				break;
			case "y":
				//$built = date('Y-m-d', date_add($baseTimeStamp, new DateInterval("P$numberM")));
				$built = date('Y-m-d', $baseTimeStamp + ($number * 31556926)); // seconds in a year - on average
				break;
			case "f": // delivery frequency unit for emus. It is the number of days.
				// The trouble is that we don't know the delivery frequency until we read the account record.
				// But I think I should be able to make a query that includes it...
				if (isset($this->deliveryFrequency)) {
					$built = date('Y-m-d', $baseTimeStamp + ($number * intval($this->deliveryFrequency) * 86400)); // multiples of the f days
				} else {
					$built = $expr; // leave the calculation until later
				}
				break;
			default:
				$built = date('Y-m-d', $baseTimeStamp);
		}
		//echo "becomes=$built<br/>";
		return $built;
	}
}

?>
