<?php
require_once(dirname(__FILE__)."/../../../common/vo/Reportable.php");

class Account extends Reportable {

	var $_explicitType = 'com.clarityenglish.dms.vo.account.Account';
	
	var $name;
	var $prefix;
	var $email;
	var $tacStatus;
	var $accountStatus;
	// v3.0.5 Change status handling
	// var $approvalStatus;
	var $accountType;
	var $invoiceNumber;
	var $resellerCode;
	var $reference;
	var $logo;
	// v3.0.6 Self-hosting
	var $selfHost;
	// v3.0.6 Anonymous Access login through CE.com/shared
	var $loginOption;
	// v3.3 Security of self-hosting
	var $selfHostDomain;
	// v3.5 To allow flexibility of email system
	var $optOutEmails;
	var $optOutEmailDate;
	
	/**
	 * This is private since we get the real user object from the db in AccountOps for DMS (this is filled into $adminUser) and
	 * don't want the id passed back to the client.
	 */
	private $adminUserID;
	var $adminUser;
	
	var $titles = array();
	
	var $licenceAttributes = array();
	
	/*
	 * Concatenate the parameter array onto our current array
	 */
	function addTitles($t) {
		$this->titles = array_merge($t, $this->titles);
	}
	/*
	 * Need a function that will remove an array of titles from this account
	 * http://stackoverflow.com/questions/3573313/php-remove-object-from-array
	 */
	function removeTitles($tarray) {
		foreach($tarray as $t) {
			if (($key = array_search($t, $this->titles, true)) !== FALSE) {
				//echo "found and removed ".$t->productCode;
				unset($this->titles[$key]);
			}
		}
	}
	
	/**
	 * AccountOps can still get the private admin user id using this method
	 */
	function getAdminUserID() {
		return $this->adminUserID;
	}
	
	/**
	 * Search through the titles in this account and return the one with the given product code
	 */
	function getTitleByProductCode($productCode) {
		foreach ($this->titles as $title)
			if ($title->productCode == $productCode)
				return $title;
			
		return null;
	}
	
	/*
	 * Take the information out of $obj (generated by AdoDB FetchNextObject()) and set the attributes of this object based on it
	 *
	 * @param obj The object returned for the record by FetchNextObject()
	 */
	function fromDatabaseObj($obj, $db = null) {
		$this->id = $obj->F_RootID;
		$this->name = $obj->F_Name;
		$this->prefix = $obj->F_Prefix;
		// v3.6 Drop F_Email from AccountRoot
		//$this->email = $obj->F_Email;
		$this->tacStatus = $obj->F_TermsConditions;
		$this->accountStatus = $obj->F_AccountStatus;
		// v3.0.5 Change status handling
		//$this->approvalStatus = $obj->F_ApprovalStatus;
		$this->invoiceNumber = $obj->F_InvoiceNumber;
		$this->resellerCode = $obj->F_ResellerCode;
		$this->reference = $obj->F_Reference;
		$this->logo = $obj->F_Logo;
		$this->accountType = $obj->F_AccountType;
		// v3.0.6 Self-hosting
		// v3.6 AWS switch, data type is now tinyint, we want to treat it as boolean
		//$this->selfHost = $obj->F_SelfHost;
		$this->selfHost = ($obj->F_SelfHost==0) ? false : true;
		// v3.0.6 Anonymous Access login through CE.com/shared
		$this->loginOption = $obj->F_LoginOption;
		// v3.3 Security of self-hosting
		$this->selfHostDomain = $obj->F_SelfHostDomain;
		$this->adminUserID = $obj->F_AdminUserID;
		//NetDebug::trace("fromDatabaseObj with ".$obj->F_SelfHostDomain);
		// v3.5 To allow flexibility of email system
		// v3.6 AWS switch, data type is now tinyint, we want to treat it as boolean
		$this->optOutEmails = ($obj->F_OptOutEmails==0) ? false : true;
		$this->optOutEmailDate = ($this->optOutEmails) ? $obj->F_OptOutEmailDate : null;
	}
	
	/**
	 * Convert this object to an associative array ready to pass to AutoExecute.
	 */
	function toAssocArray() {
		$array = array();
		
		$array['F_Name'] = $this->name;
		$array['F_Prefix'] = $this->prefix;
		// v3.6 Drop F_Email from AccountRoot
		//$array['F_Email'] = $this->email;
		$array['F_TermsConditions'] = $this->tacStatus;
		$array['F_AccountStatus'] = $this->accountStatus;
		// v3.0.5 Change status handling
		//$array['F_ApprovalStatus'] = $this->approvalStatus;
		$array['F_InvoiceNumber'] = $this->invoiceNumber;
		$array['F_ResellerCode'] = $this->resellerCode;
		$array['F_Reference'] = $this->reference;
		$array['F_Logo'] = $this->logo;
		$array['F_AccountType'] = $this->accountType;
		// v3.0.6 Self-hosting
		$array['F_SelfHost'] = ($this->selfHost) ? 1 : 0;
		// v3.0.6 Anonymous Access login through CE.com/shared
		$array['F_LoginOption'] = $this->loginOption;
		// v3.3 Security of self-hosting
		$array['F_SelfHostDomain'] = $this->selfHostDomain;
		// v3.4 Multi-group users
		//if ($this->adminUser) $array['F_AdminUserID'] = $this->adminUser->id;
		if ($this->adminUser) $array['F_AdminUserID'] = $this->adminUser->userID;
		//NetDebug::trace("toAssocArray with ".$array['F_SelfHostDomain']);
		// v3.5 To allow flexibility of email system
		// But of course this code ignores false!
		//if ($this->optOutEmails) $array['F_OptOutEmails'] = $this->optOutEmails;
		if (isset($this->optOutEmails)) $array['F_OptOutEmails'] = ($this->optOutEmails) ? 1 : 0;
		if (isset($this->optOutEmails)) $array['F_OptOutEmailDate'] = $this->optOutEmailDate;
		
		return $array;
	}
	
	static function getSelectFields($db, $prefix = "a") {
		$fields = array("$prefix.F_RootID",
						"$prefix.F_Name",
						"$prefix.F_Prefix",
		// v3.6 Drop F_Email from AccountRoot
						//"$prefix.F_Email",
						"$prefix.F_TermsConditions",
						"$prefix.F_AccountStatus",
		// v3.0.5 Change status handling
						//"$prefix.F_ApprovalStatus",
						//"$prefix.F_SubscriptionStatus",
						"$prefix.F_InvoiceNumber",
						"$prefix.F_ResellerCode",
						"$prefix.F_AdminUserID",
						"$prefix.F_Reference",
		// v3.0.6 Self-hosting
						"$prefix.F_AccountType",
						"$prefix.F_SelfHost",
		// v3.0.6 Anonymous Access login through CE.com/shared
						"$prefix.F_LoginOption",
		// v3.3 Security of self-hosting
						"$prefix.F_SelfHostDomain",
		// v3.5 To allow flexibility of email system
						"$prefix.F_OptOutEmails",
						"$prefix.F_OptOutEmailDate",
						"$prefix.F_Logo");
		
		return implode(",", $fields);
	}

	// This is a comparison function used to sort an array of accounts based on their template
    static function compareTemplates($a, $b) {
        $al = strtolower($a->templateDetail);
        $bl = strtolower($b->templateDetail);
        if ($al == $bl) {
			// So the two templates are equal, so 
            return 0;
        }
        return ($al > $bl) ? +1 : -1;
    }
	// This is a comparison function used to sort an array of accounts based on the expiry date of their RM
	// which we are assuming is already saved as the account expiry date in the object (which it is in EWS)
    static function compareExpiryDates($a, $b) {
		if (!isset($a->expiryDate) || !isset($b->expiryDate)) return 0;
        if ($a->expiryDate == $b->expiryDate) {
			// So the dates are equal
            return 0;
        }
        return ($a->expiryDate > $b->expiryDate) ? +1 : -1;
    }
}
?>
