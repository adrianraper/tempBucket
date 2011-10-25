<?php
//
// This class used to handle purchases of subscriptions by individuals
// TODO: Encrypt passwords
// TODO: Use https and/or certificates to validate resellers
// TODO: Write log records for all stages
// TODO: For updates, we are not altering $account->name or anything account details, just changing titles.
// TODO: For Emu, the licencedProducts (IYJ Practice Centre) need licenceAttributes, action=validatedLogin which we are not setting
//
class SubscriptionOps {

	var $db;
	
	private $dmsKey;

	function SubscriptionOps($db) {
		$this->db = $db;
		
		$this->copyOps = new CopyOps();
		$this->manageableOps = new ManageableOps($db);
		$this->accountOps = new AccountOps($db);
		$this->emailOps = new EmailOps($db);
		$this->templateOps = new TemplateOps($db);
	}
	
	function validateApiInformation($apiInformation) {
		//AbstractService::$log->notice("validateAPIInformation: reseller=".$apiInformation->resellerID);
		// Check the reseller is valid
		if (!is_numeric($apiInformation->resellerID)) {
			returnError(1, "resellerID is invalid ".$apiInformation->resellerID);
		}
		$rc = $this->checkResellerID($apiInformation->resellerID);
		if ($rc===false) {
			returnError(204, $apiInformation->resellerID);
		} else {
			$apiInformation->resellerEmail = $rc;
		}
		
		// Next we need to check that the offerID is valid
		// Convert a single offerID into an array, then validate each item in the array
		if (!is_array($apiInformation->offerID)) {
			// Its not an array, but is it a comma delimited string?
			if (count(explode(',', $apiInformation->offerID)) > 1) {
				$apiInformation->offerID = explode(',', $apiInformation->offerID);
			} else {
				$apiInformation->offerID = array($apiInformation->offerID);
			}
		}
		foreach($apiInformation->offerID as $offerID) {
			if (!is_numeric($offerID)) {
				returnError(1, "offerID is invalid ".$offerID);
			}
			if (!$this->checkOfferID($offerID)) {
				returnError(202, $offerID);
			} else {
				//echo " with a good offer ";
			}
		}
		
		// If they have sent a password it implies that this is adding to an existing account.
		// TODO: Not a good test as they maybe are sending a desired password for a new account.
		// Why not have a method name instead? Yes
		//if (isset($apiInformation->password)) {
		if (stristr($apiInformation->method, 'update') !== false) {
			// So check the email/password combination. If success, we can keep going in update mode.
			// If fail, send back an error.
			$rc = $this->manageableOps->checkEmailPassword($apiInformation->email, $apiInformation->password, $apiInformation->licenceType);
			if ($rc == 0) {
				returnError(201);
			} elseif ($rc==1) {
				//echo "this is an update for an existing email";
				$apiInformation->updateAccount=true;
			} else {
				returnError(203);
			}
		} else {
			// If there is no password, then we want to check that this email address is unique for a CLS account
			// If not unique, we send back an error
			if (!$this->manageableOps->checkUniqueEmail($apiInformation->email, $apiInformation->licenceType)) {
				returnError(200, $apiInformation->email);
			} else {
				//echo "this is a new email";
				$apiInformation->updateAccount=false;
			}
		}

		// Check that a unique discount code has not been used already
		if (isset($apiInformation->uniqueDiscountCode) && $apiInformation->uniqueDiscountCode != '') {
			if (!$this->checkUniqueDiscountCode($apiInformation->uniqueDiscountCode)) {
				returnError(205, $apiInformation->uniqueDiscountCode);
			} else {
				//echo "this discount code is unique";
			}
		}
		
		// Check that a common discount code is valid (date, country, offer)
		// Since we are not trying to do anything with money in this code, this check is probably meaningless
		if (isset($apiInformation->discountCode) && $apiInformation->discountCode != '') {
			//if (!$this->checkDiscountCode($apiInformation->discountCode)) {
			//	returnError(206, $apiInformation->discountCode);
			//} else {
			//	//echo "this discount code is valid";
			//}
		}
		
		// Check that any subscriptionID passed is valid
		if (isset($apiInformation->subscriptionID) && $apiInformation->subscriptionID != '') {
			//echo 'Check subscription ID '.$apiInformation->subscriptionID;
			if (!$this->checkSubscriptionID($apiInformation->subscriptionID)) {
				// Do you want to return an error, or just wipe the subscription ID so that we create a new one?
				//returnError(207, $apiInformation->subscriptionID);
				unset($apiInformation->subscriptionID);
			} else {
				//echo "this discount code is valid";
			}
		}
		
		// All has passed so data seems valid
		return true;

	}

	/*
	 * Is this a valid offer ID?
	 */
	function checkOfferID($id = 0) {
		$startToday = date('Y-m-d').' 00:00:00';
		$endToday = date('Y-m-d').' 23:59:59';
		$sql = 	<<<EOD
			SELECT * 
			FROM T_Offer o
			WHERE o.F_OfferID = ?
			AND o.F_OfferStartDate <= '$endToday'
			AND ((o.F_OfferEndDate >= '$startToday') OR (o.F_OfferEndDate is null))
EOD;
		$rs = $this->db->Execute($sql, array($id));
		
		switch ($rs->RecordCount()) {
			case 1:
				// One matching record, all is well. Should we return the offer (as a vo)?
				return true;
				break;
			default:
				// No matches
				return false;
		}
	}
	/*
	 * Is this a valid reseller ID?
	 */
	function checkResellerID($id = 0) {
		$sql = 	<<<EOD
			SELECT F_Email as email
			FROM T_Reseller
			WHERE F_ResellerID = ?
EOD;
		$rs = $this->db->Execute($sql, array($id));
		if ($rs->RecordCount() == 1) {
			return $rs->FetchNextObj()->email;
		} else {
			return false;
		}
	
	}
	// Check that any unique discount code has not been used before
	function checkUniqueDiscountCode($discountCode) {
	
		$sql = 	<<<EOD
			SELECT * 
			FROM T_Subscription s
			WHERE s.F_DiscountCode = ?
EOD;
		$rs = $this->db->Execute($sql, array($discountCode));
		
		switch ($rs->RecordCount()) {
			case 0:
				// No matching records, so discount code is unique
				return true;
				break;
			default:
				// We have already used this code
				return false;
		}
	}
	// Check that any unique discount code has not been used before
	function checkSubscriptionID($id=0) {
	
		$sql = 	<<<EOD
			SELECT * 
			FROM T_Subscription s
			WHERE s.F_SubscriptionID = ?
EOD;
		$rs = $this->db->Execute($sql, array($id));
		
		switch ($rs->RecordCount()) {
			case 1:
				// 1 matching record, so all is well
				return true;
				break;
			default:
				// Nothing matches, so no such ID
				return false;
		}
	}
	
	// TODO: apiInformation should be a class. As a minimum it will stop you have to type all the array names.
	// This function gets the account that matches the info sent in the API (or creates a new one)
	public function getAccountDetails($apiInformation) {
		
		// Just pick up an existing account, or create a new one?
		if ($apiInformation->updateAccount) {
			return $this->accountOps->getAccountFromEmail($apiInformation->email);
		} else {
			// What information do you need to build a new account?
			$account = new Account();
			$account->name = $apiInformation->name;
			//echo 'building up '.$account->name;
			if (isset($apiInformation->resellerEmail))
				$account->email = $apiInformation->resellerEmail; //$apiInformation->email;
			$account->resellerCode = $apiInformation->resellerID;
			$account->name = $apiInformation->name;
			// No, the order ref is the reseller reference. We should save it, but generate our own invoice number
			//$account->note = 'Reseller ref='.$apiInformation->orderRef;
			//$account->invoiceNumber = $apiInformation->orderRef;			
			$account->invoiceNumber = time();
			
			$account->tacStatus = $apiInformation->tacStatus;
			$account->accountType = $apiInformation->accountType;
			$account->selfHost = $apiInformation->selfHost;
			$account->loginOption = $apiInformation->loginOption;
			$account->accountStatus = $apiInformation->accountStatus;
			
			$account->prefix = $this->accountOps->getNextPrefix();

			// Adding the purchaser as the admin user
			$thisUser = new User();
			$thisUser->name = $account->name;
			$thisUser->email = $apiInformation->email;
			// If they sent a password, it means this is the one they want to use
			if (isset($apiInformation->password) && $apiInformation->password != '') {
				$thisUser->password = $apiInformation->password;
			} else {
				$thisUser->password = $this->generatePassword();
			}
			$thisUser->userType = User::USER_TYPE_STUDENT;
			if (isset($apiInformation->studentID)) {
				$thisUser->studentID = $apiInformation->studentID;
			}
			if (isset($apiInformation->country)) {
				$thisUser->country = $apiInformation->country;
			}
			if (isset($apiInformation->city)) {
				$thisUser->city = $apiInformation->city;
			}
			if (isset($apiInformation->contactMethod)) {
				$thisUser->contactMethod = $apiInformation->contactMethod;
			}
			$thisUser->startDate = date('Y-m-d').' 00:00:00';
			$thisUser->expiryDate = '';
			$account->adminUser = $thisUser;
		
			// Should I add the account to the database now?
			// We don't know titles yet, so just keep the account object, no need to add to database yet. 
			// But must make sure that I know later whether to add/update the account
			//$this->accountOps->addAccount($account);
			
			return $account;
		}
	}
	
	// Work out what titles this offer will add to the account, and do it
	public function addTitlesToAccount($account, $apiInformation) {

		// First, what titles is the user buying with this offer? And what dates/numbers etc
		$offerTitles = $this->getTitlesFromOffer($apiInformation);
		//echo 'offer has '.count($offerTitles).' titles'.'<br/>';
		
		// Next, do any of these 'clash' with existing titles in the account
		foreach ($offerTitles as $newTitle) {
			//echo "offer title is ".$newTitle->productCode.'<br/>';
			foreach ($account->titles as $title) {
				//echo "Existing title is ".$title->productCode.' expiring on '.$title-> expiryDate.'<br/>';
				if ($title->productCode == $newTitle-> productCode) {
					//echo 'add same one but expiring on '.$newTitle-> expiryDate.'<br/>';
					// TODO: This is not a sensible renewal set of rules
					// Take the latest expiry date and the corresponding number of students
					if (!$newTitle->expiryDate > $title-> expiryDate) {
						// The new title doesn't extend the existing one, so just delete it?
						throw new Exception("Unexpected: the new title doesn't extend the old one.".$title->productCode);
					} else {
						// We have a matching title that somehow needs to be extended. But exactly how?
						// Dumb answer is just to remove old title and let it be added back with the new parameters.
						$account->removeTitles(array($title));
					}
				}
			}
			// No date clash, so add this title to the account
			$account->addTitles(array($newTitle));
		}
		
		return $account;
	}
	private function getTitlesFromOffer($apiInformation) {
		// An offerID links a package, price, currency and duration (days)
		// A package lists titles and/or courses (through package contents)
		// Expect offerID to be an array - and just pick up all packages within all the included offers
		// We could get distinct productCode?
		$titles = array();
		$offerID = implode(',',$apiInformation->offerID);
		
		//	SELECT pc.F_ProductCode as productCode, o.F_Duration as duration
		$sql = 	<<<EOD
			SELECT distinct(pc.F_ProductCode) as productCode, o.F_Duration as duration
			FROM T_Offer o, T_Package p, T_PackageContents pc
			WHERE o.F_PackageID=p.F_PackageID
			AND p.F_PackageID=pc.F_PackageID
			AND o.F_OfferID in ($offerID)
EOD;
		$rs = $this->db->Execute($sql);	
		//echo $sql."<br/>";
		//echo 'offer includes titles='.$rs->RecordCount()."<br/>";
		if ($rs->RecordCount() > 0) {
		
			while ($record = $rs->FetchNextObj()) {
				// Start and end date are common to all titles in an offer (but need to read duration from record)
				// Expiring today plus duration
				$apiInformation->startDate = date('Y-m-d').' 00:00:00';
				//$thisTitle->expiryDate = date_format((new DateTime()->modify('+'.$record->duration.' day'), 'Y-m-d');
				$expiryDate = strtotime('+'.$record->duration.' days');
				$apiInformation->expiryDate = date('Y-m-d', $expiryDate).' 23:59:59';
				
				$thisTitle = new Title();
				//var_dump($record);
				//echo 'ccc'.$record->productCode;
				$thisTitle->productCode = $record->productCode;
				//echo 'offer title name is '.$thisTitle->name.' from '.$thisTitle->productCode.'<br/>';
				$thisProduct = $this->accountOps->contentOps->getDetailsFromProductCode($thisTitle->productCode, $apiInformation->languageCode);
				$thisTitle->name = $thisProduct['name'];
				//echo 'offer title name is '.$thisTitle->name.' from '.$thisTitle->productCode.'<br/>';
				$thisTitle->licenceType = $apiInformation->licenceType;
				$thisTitle->maxStudents = $apiInformation->maxStudents;
				$thisTitle->maxTeachers = $apiInformation->maxTeachers;
				$thisTitle->maxReporters = $apiInformation->maxReporters;
				$thisTitle->maxAuthors = $apiInformation->maxAuthors;

				// Starting today
				$thisTitle->licenceStartDate = $apiInformation->startDate;
				$thisTitle->expiryDate = $apiInformation->expiryDate;
				//echo 'offer expiry date='.$thisTitle->expiryDate;
				
				// The language code you sent with api MIGHT be wrong for this product (EN for CSCS for instance)
				// getDetailsFromProductCode will have sent back the default if yours is not good, so use that
				//$thisTitle->languageCode = $apiInformation->languageCode;
				$thisTitle->languageCode = $thisProduct['languageCode'];
				//$thisTitle->deliveryFrequency = $apiInformation->deliveryFrequency;
				//$thisTitle->contactMethod = $apiInformation->contactMethod;

				$titles[] = $thisTitle;
				
				// Now, if this product is an emu, it might contain other products. This is recorded in the Emu.
				// So we need to use contentOps to read the emu and search for licencedProductCode in any item.			
				//if ($thisTitle->productCode>1000) {
				if ($thisTitle->productCode>1000) {
					//$licencedProductCodes = $dmsService->accountOps->contentOps->getLicencedProductCodes($thisTitle-> productCode);
					$licencedProductCodes = $this->accountOps->contentOps->getLicencedProductCodes($thisTitle->productCode);
					//echo "licenced product codes=".print_r($licencedProductCodes)."<br/>";
					foreach ($licencedProductCodes as $licencedProductCode) {
						//echo "add account for product ".$productCode."<br/>";
						// get the product details and turn into a 'title'
						$thisTitle = new Title();
						$thisTitle->productCode = $licencedProductCode;
						
						$thisProduct = $this->accountOps->contentOps->getDetailsFromProductCode($thisTitle->productCode, $apiInformation->languageCode);
						$thisTitle->name = $thisProduct['name'];
						//echo 'offer title name is '.$thisTitle->name.' from '.$thisTitle->productCode.'<br/>';
						$thisTitle->licenceType = $apiInformation->licenceType;
						$thisTitle->maxStudents = $apiInformation->maxStudents;
						$thisTitle->maxTeachers = $apiInformation->maxTeachers;
						$thisTitle->maxReporters = $apiInformation->maxReporters;
						$thisTitle->maxAuthors = $apiInformation->maxAuthors;

						// Starting today
						$thisTitle->licenceStartDate = $apiInformation->startDate;
						$thisTitle->expiryDate = $apiInformation->expiryDate;
						$thisTitle->languageCode = $apiInformation->languageCode;
						
						$titles[] = $thisTitle;
						
						// For these titles, we will be logging with userID, so set the action=validatedLogin
						// TODO: This fails as we don't know the account at this point?
						//$account->licenceAttributes[] = array('licenceKey' => 'action', 'licenceValue' => 'validatedLogin', 'productCode' => $licencedProductCode);
					}
				} else {
					// This array is only useful for reporting products you added in an email.
					// I don't think it is particularly useful at all since the parent product name is all you care to tell the user about.
					$licencedProductCodes = array();
				}	
			}
		}
		return $titles;		
	}
	// For sending out customer email once the account is created
	public function sendEmail($account, $apiInformation, $send=true) {
		// If the admin email is different from the account email, cc
		$templateID = $apiInformation->emailTemplateID;
		$accountEmail = $account->email;
		$adminEmail = $account->adminUser->email;
		$emailData = array("account" => $account, "api"=>$apiInformation);
		$emailArray = array("to" => $adminEmail, "data" => $emailData);
		if ($accountEmail != $adminEmail && $accountEmail && $accountEmail!= '') {
			$emailArray["cc"] = array($accountEmail);
		}
						
		// Check that the template exists
		// All templates for CLS exist in the subfolder
		$templateID='CLS/'.$templateID;
		if (!$this->templateOps->checkTemplate('emails', $templateID)) {
			throw new Exception ("This template doesn't exist. /emails/$templateID");
		}
		// For testing or real
		if ($send) {
			$this->emailOps->sendEmails("", $templateID, array($emailArray));
		} else {
			echo $emailText = $this->emailOps->fetchEmail($templateID, $emailData);
		}
		
	}
	// For sending out a supplier email as part of the account creation process
	// This should be as generic as possible
	public function sendSupplierEmail($to, $templateID, $dataObject, $attachment=null, $send=true) {
		$accountEmail = $to;
		$emailData = array("data" => $dataObject);
		$emailArray = array("to" => $to, "data" => $emailData);
		$emailArray["bcc"] = array('support@iLearnIELTS');
		if ($attachment) 
			// whilst this is still a tab delimited file, it seems simpler to call it txt rather than csv as Excel doesn't open it correctly
			// by default.
			$emailArray['attachments'] = array(new stringAttachment($attachment, 'iLearnIELTS_'.$dataObject->orderRef.'.txt')); 
						
		// Check that the template exists
		// All templates for CLS exist in the subfolder
		$templateID='CLS/'.$templateID;
		if (!$this->templateOps->checkTemplate('emails', $templateID)) {
			throw new Exception ("This template doesn't exist. /emails/$templateID");
		}
		// For testing or real
		if ($send) {
			$this->emailOps->sendEmails("", $templateID, array($emailArray));
		} else {
			echo $emailText = $this->emailOps->fetchEmail($templateID, $emailData);
		}	
	}
	// For creating temporary files (perhaps to be downloaded or sent as email attachments)
	// This should be as generic as possible
	//public function createFile($fileName, $dataObject, $templateID) {
	public function createCSV($dataObject, $templateID, $saveAsFile = false) {
						
		// Check that the template exists
		// All templates for CLS exist in the subfolder - even files
		$templateID='CLS/'.$templateID;
		if (!$this->templateOps->checkTemplate('emails', $templateID)) {
			throw new Exception ("This template doesn't exist. /emails/$templateID");
		}
		
		$fileData = array("data" => $dataObject);
		$fileText = $this->emailOps->fetchEmail($templateID, $fileData);
		//return $this->emailOps->fetchEmail($templateID, $fileData);
		
		// Write it out to the temporary folder. If this fails, keep going
		try {
			if ($saveAsFile) {
				//$file = dirname(__FILE__)."/../../../Common/logs/".$templateID.$dataObject->orderRef.'.txt';
				$file = $GLOBALS['logs_dir'].$templateID.$dataObject->orderRef.'.txt';
				if (file_exists($file))
					throw new Exception("File already exists");
					
				if (!$fp = fopen($file, "wb")) {
					throw new Exception("Can't create temporary file $file");
				} else {
					if (fwrite($fp, $fileText) === false) {
						throw new Exception("Can't write to temporary file $file");
					}
					fclose($fp);
				}
			}
			AbstractService::$debugLog->info('created file '.$file);
		} catch (Exception $e) {
			AbstractService::$debugLog->err($e->getMessage());
		}
		return $fileText;
	}

	// Send our accounts team an email notifiying of a new subscription
	public function sendAccountsEmail($dataObject, $templateID = null, $send = true) {
		$to = 'accounts@clarityenglish.com';
		$emailData = array("data" => $dataObject);
		$emailArray = array("to" => $to, "data" => $emailData);
		// Check that the template exists
		// All templates for CLS exist in the subfolder
		$templateID='CLS/'.$templateID;
		if (!$this->templateOps->checkTemplate('emails', $templateID)) {
			throw new Exception ("This template doesn't exist. /emails/$templateID");
		}
		// For testing or real
		if ($send) {
			$this->emailOps->sendEmails("", $templateID, array($emailArray));
		} else {
			echo $emailText = $this->emailOps->fetchEmail($templateID, $emailData);
		}	
	}

	// Save the account object you have built up
	public function saveAccount ($account, $apiInformation) {
	
		if ($apiInformation->updateAccount) {
			//echo "try to upgrade the account<br/>";
			$this->accountOps->updateAccounts(array($account));
		} else {
			//echo "try to add a new account<br/>";
			// For early testing, you might not want to actually add the account
			$this->accountOps->addAccount($account);
		}
	}

	// Write the subscription record to the database and any logs that you want
	public function saveSubscription($account, $apiInformation) {

		$this->db->StartTrans();

		// If you have been passed subscriptionID, it should be the key to this table, otherwise make a new record
		if (isset($apiInformation->subscriptionID)) {
			$this->db->AutoExecute("T_Subscription", $this->subscriptionToAssocArray($account, $apiInformation), "UPDATE", "F_SubscriptionID=".$apiInformation->subscriptionID);
		} else {
			$this->db->AutoExecute("T_Subscription", $this->subscriptionToAssocArray($account, $apiInformation), "INSERT");
			$apiInformation->subscriptionID = $this->db->Insert_ID();
		}
		
		// make the root of the changed account explicit in the log
		AbstractService::$log->setRootID($account->id);
		AbstractService::$log->notice("Created CLS subscription=".$account->name.", sub id=".$apiInformation->subscriptionID.', for reseller='.$apiInformation->resellerID);

		// TODO: Write a file log as well in case database errors
		$this->db->CompleteTrans();
	
	}

	// =========
	// Utility functions for this class
	// =========
	function returnError($errCode, $data='') {
		return array('errorCode'=>$errCode, 'data'=>$data);
	}
	/* 
	 * Generating passwords. Ref Jon Haworth, www.laughing-buddha.net
	 */
	private function generatePassword ($length = 8){

	  // start with a blank password
	  $password = "";

	  // define possible characters (drop some vowels to avoid real words) and any other confusing characters
	  $possible = "abcdefghjkmnpqrstvwxyz"; 
		
	  $i = 0; 
	  // add random characters to $password until $length is reached
	  while ($i < $length) { 

		// pick a random character from the possible ones
		$char = substr($possible, mt_rand(0, strlen($possible)-1), 1);
			
		// doesn't matter if it is duplicated
		//if (!strstr($password, $char)) { 
		  $password .= $char;
		  $i++;
		//}
	  }
	  return $password;
	}
	function subscriptionToAssocArray($account, $api) {
		$array = array();
		
		// What do we certainly know?
		$array['F_FullName'] = $account->name;
		$array['F_Email'] = $account->adminUser->email;
		$array['F_RootID'] = $account->id;
		$array['F_OfferID'] = implode(',',$api->offerID);
		$array['F_StartDate'] = $api->startDate;
		$array['F_ExpiryDate'] = $api->expiryDate;
		$array['F_Password'] = $account->adminUser->password;
		$array['F_Status'] = 'Account created';
		$array['F_LanguageCode'] = $api->languageCode;
		
		// What might we know?
		if (isset($api->uniqueDiscountCode)) {
			$array['F_DiscountCode'] = $api->uniqueDiscountCode;
		} else if (isset($api->discountCode)) {
			$array['F_DiscountCode'] = $api->discountCode;
		}
		if (isset($api->country)) 
			$array['F_Country'] = $api->country;
		
		return $array;
	}
}
?>