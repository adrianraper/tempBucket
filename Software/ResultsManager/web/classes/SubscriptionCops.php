<?php
//
// This class used to handle purchases of subscriptions by individuals
// TODO: Encrypt passwords
// TODO: Use https and/or certificates to validate resellers
// TODO: Write log records for all stages
// TODO: For updates, we are not altering $account->name or anything account details, just changing titles.
// TODO: For Emu, the licencedProducts (IYJ Practice Centre) need licenceAttributes, action=validatedLogin which we are not setting
//
// Add TB6weeks style subscriptions
//
class SubscriptionCops {

	var $db;
	
	private $dmsKey;

	function SubscriptionCops($db) {
		$this->db = $db;
		
		$this->copyOps = new CopyOps();
		$this->manageableOps = new ManageableOps($db);
		$this->accountCops = new AccountCops($db);
		$this->emailOps = new EmailOps($db);
		$this->templateOps = new TemplateOps($db);
		$this->memoryCops = new MemoryCops($db);
	}
	
	/**
	 * If you changed the db, you'll need to refresh it here
	 * Not a very neat function...
	 */
	function changeDB($db) {
		$this->db = $db;
		$this->manageableOps->changeDB($db);
		$this->accountCops->changeDB($db);
		$this->emailOps->changeDB($db);
		$this->templateOps->changeDB($db);
		$this->memoryCops->changeDB($db);
	}
	
	function validateApiInformation($apiInformation) {
		//AbstractService::$log->notice("validateAPIInformation: reseller=".$apiInformation->resellerID);
		// Check the reseller is valid
		$resellerID = $apiInformation->subscription->resellerID;
		if (!is_numeric($resellerID)) {
			returnError(1, "resellerID is invalid ".$resellerID);
		}
		$rc = $this->checkResellerID($resellerID);
		if ($rc===false) {
			returnError(204, $resellerID);
		} else {
			$apiInformation->resellerEmail = $rc;
		}
		
		// Next we need to check that the offerID is valid
		// Convert a single offerID into an array, then validate each item in the array
		$offerID = $apiInformation->subscription->offerID;
		//if (count(explode(',', $offerID)) > 1) {
			$offerID = explode(',', $offerID);
		//} else {
		//	$offerID = array($offerID);
		//}
		foreach($offerID as $oID) {
			if (!is_numeric($oID)) {
				returnError(1, "offerID is invalid ".$oID);
			}
			if (!$this->checkOfferID($oID)) {
				returnError(202, $oID);
			} else {
				//echo " with a good offer ";
			}
		}
		
		// If they have sent a password it implies that this is adding to an existing account.
		// TODO: Not a good test as they maybe are sending a desired password for a new account.
		// Why not have a method name instead? Yes
		if (stristr($apiInformation->method, 'update') !== false) {
			// So check the email/password combination. If success, we can keep going in update mode.
			// If fail, send back an error.
			$rc = $this->manageableOps->checkEmailPassword($apiInformation->subscription->email, $apiInformation->subscription->password, $apiInformation->licenceType);
			if ($rc == 0) {
				returnError(201, 'Password was wrong');
			} elseif ($rc==1) {
				//echo "this is an update for an existing email";
				// $apiInformation->updateAccount=true;
			} else {
				returnError(203);
			}
		} else {
			// We want to check that this email address is unique for a CLS account
			// If not unique, we send back an error
			if (!$this->manageableOps->checkUniqueEmail($apiInformation->subscription->email, $apiInformation->licenceType)) {
				returnError(200, $apiInformation->subscription->email);
			} else {
				//echo "this is a new email";
				// $apiInformation->updateAccount=false;
			}
		}

		// Check that a unique discount code has not been used already
		if (isset($apiInformation->subscription->discountCode) && $apiInformation->subscription->discountCode != '') {
			if (!$this->checkUniqueDiscountCode($apiInformation->subscription->discountCode)) {
				returnError(205, $apiInformation->subscription->discountCode);
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
		if (isset($apiInformation->subscription->id) && $apiInformation->subscription->id != '') {
			//echo 'Check subscription ID '.$apiInformation->subscriptionID;
			if (!$this->checkSubscriptionID($apiInformation->subscription->id)) {
				// Do you want to return an error, or just wipe the subscription ID so that we create a new one?
				//returnError(207, $apiInformation->subscriptionID);
				unset($apiInformation->subscription->id);
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
	// Check that this subscription records exists
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
	// Check that this subscription records exists
	function getSubscriptionRecord($id = 0) {
	
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
		if (stristr($apiInformation->method, 'update') !== false) {
			// gh#1210
			// Try to get the account from prefix if any. This can fixed the duplicate email address problem
			if (isset($apiInformation->prefix)){
				return $this->accountCops->getAccountFromPrefix($apiInformation->prefix);
			}
			if (!isset($apiInformation->email) && isset($apiInformation->subscription->email)){
				$apiInformation->email = $apiInformation->subscription->email;
			}
			return $this->accountCops->getAccountFromEmail($apiInformation->email);
			
		} else {
			// What information do you need to build a new account?
			$account = new Account();
			$account->name = $apiInformation->subscription->name;
			//echo 'building up '.$account->name;
			
			// Email comes from T_User and T_Reseller now
			//if (isset($apiInformation->resellerEmail))
			//	$account->email = $apiInformation->resellerEmail; //$apiInformation->email;
			
			$account->resellerCode = $apiInformation->subscription->resellerID;
			
			// No, the order ref is the reseller reference. We should save it, but generate our own invoice number
			//$account->note = 'Reseller ref='.$apiInformation->orderRef;
			//$account->invoiceNumber = $apiInformation->orderRef;			
			$account->invoiceNumber = $apiInformation->subscription->id;
			
			$account->tacStatus = $apiInformation->tacStatus;
			$account->accountType = $apiInformation->accountType;
			$account->selfHost = $apiInformation->selfHost;
			$account->loginOption = $apiInformation->loginOption;
			$account->accountStatus = $apiInformation->accountStatus;
			
			$account->prefix = $this->accountCops->getNextPrefix();

			// Adding the purchaser as the admin user
			$thisUser = new User();
			$thisUser->name = $account->name;
			$thisUser->email = $apiInformation->subscription->email;
			// If they sent a password, it means this is the one they want to use
			if (isset($apiInformation->subscription->password) && $apiInformation->subscription->password != '') {
				$thisUser->password = $apiInformation->subscription->password;
			} else {
				$thisUser->password = $this->generatePassword();
			}
			$thisUser->userType = User::USER_TYPE_STUDENT;
			if (isset($apiInformation->studentID)) {
				$thisUser->studentID = $apiInformation->studentID;
			}
			if (isset($apiInformation->subscription->country)) {
				$thisUser->country = $apiInformation->subscription->country;
			}
			if (isset($apiInformation->city)) {
				$thisUser->city = $apiInformation->city;
			}
			if (isset($apiInformation->subscription->contactMethod)) {
				$thisUser->contactMethod = $apiInformation->subscription->contactMethod;
			}
			if (isset($apiInformation->subscription->startDate)) {
				$thisUser->startDate = $apiInformation->subscription->startDate;
			} else {
				$thisUser->startDate = date('Y-m-d').' 00:00:00';
			}
			$thisUser->expiryDate = '';
			if (isset($apiInformation->subscription->birthday)) {
				$thisUser->birthday = $apiInformation->subscription->birthday;
			} 
			$account->adminUser = $thisUser;

			// m#281
            if (isset($apiInformation->subscription->registerMethod)) {
                $thisUser->registerMethod = $apiInformation->subscription->registerMethod;
            }

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
				if ($title->productCode == $newTitle->productCode) {
					// The newTitle.expiryDate is based on offer duration from today.
					// but the original subscription might have a few days left, so add them on
					$timeLeft = strtotime($title->expiryDate) - strtotime(date('Y-m-d 23:59:59'));
					// gh#272
					$daysLeft = max(round($timeLeft / 86400), 0);
					$newTitle->expiryDate = date('Y-m-d 23:59:59', strtotime('+'.$daysLeft.' days',strtotime($newTitle->expiryDate)));
					$account->removeTitles(array($title));
				}
			}
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
		$offerID = $apiInformation->subscription->offerID;
				
		//	SELECT pc.F_ProductCode as productCode, o.F_Duration as duration
		$sql = 	<<<EOD
			SELECT distinct(pc.F_ProductCode) as productCode, o.F_Duration as duration, o.F_OfferName as offerName
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
				// Not true, you could choose two offers with different durations. 
				// The following code will work for creating the titles, buy you end up with apiInformation->expiryDate JUST for the last offer
				// Expiring today plus duration.
				$apiInformation->subscription->startDate = date('Y-m-d').' 00:00:00';
				//$thisTitle->expiryDate = date_format((new DateTime()->modify('+'.$record->duration.' day'), 'Y-m-d');
				$expiryDate = strtotime('+'.$record->duration.' days');
				$apiInformation->subscription->expiryDate = date('Y-m-d', $expiryDate).' 23:59:59';
				
				// Again, this can only work if you are buying one offer at a time.
				$apiInformation->offerName = $record->offerName;
				
				$thisTitle = new Title();
				//var_dump($record);
				//echo 'ccc'.$record->productCode;
				$thisTitle->productCode = $record->productCode;
				//echo 'offer title name is '.$thisTitle->name.' from '.$thisTitle->productCode.'<br/>';
				$thisProduct = $this->accountCops->contentOps->getDetailsFromProductCode($thisTitle->productCode, $apiInformation->subscription->languageCode);
				$thisTitle->name = $thisProduct['name'];
				//echo 'offer title name is '.$thisTitle->name.' from '.$thisTitle->productCode.'<br/>';
				$thisTitle->licenceType = $apiInformation->licenceType;
				$thisTitle->maxStudents = $apiInformation->maxStudents;
				$thisTitle->maxTeachers = $apiInformation->maxTeachers;
				$thisTitle->maxReporters = $apiInformation->maxReporters;
				$thisTitle->maxAuthors = $apiInformation->maxAuthors;

				// Starting today
				$thisTitle->licenceStartDate = $apiInformation->subscription->startDate;
				$thisTitle->expiryDate = $apiInformation->subscription->expiryDate;
				//echo 'offer expiry date='.$thisTitle->expiryDate;
				
				// The language code you sent with api MIGHT be wrong for this product (EN for CSCS for instance)
				// getDetailsFromProductCode will have sent back the default if yours is not good, so use that
				$thisTitle->languageCode = $thisProduct['languageCode'];
				
				// gh#172
				$thisTitle->productVersion = $apiInformation->subscription->productVersion;
				
				// Not used yet, but passed correctly so accept
				$thisTitle->deliveryFrequency = $apiInformation->subscription->deliveryFrequency;
				$thisTitle->contactMethod = $apiInformation->subscription->contactMethod;

				$titles[] = $thisTitle;
				
				// Now, if this product is an emu, it might contain other products. This is recorded in the Emu.
				// So we need to use contentOps to read the emu and search for licencedProductCode in any item.			
				//if ($thisTitle->productCode>1000) {
				if ($thisTitle->productCode>1000) {
					//$licencedProductCodes = $dmsService->accountOps->contentOps->getLicencedProductCodes($thisTitle-> productCode);
					$licencedProductCodes = $this->accountCops->contentOps->getLicencedProductCodes($thisTitle->productCode);
					//echo "licenced product codes=".print_r($licencedProductCodes)."<br/>";
					foreach ($licencedProductCodes as $licencedProductCode) {
						//echo "add account for product ".$productCode."<br/>";
						// get the product details and turn into a 'title'
						$thisTitle = new Title();
						$thisTitle->productCode = $licencedProductCode;
						
						$thisProduct = $this->accountCops->contentOps->getDetailsFromProductCode($thisTitle->productCode, $apiInformation->subscription->languageCode);
						$thisTitle->name = $thisProduct['name'];
						//echo 'offer title name is '.$thisTitle->name.' from '.$thisTitle->productCode.'<br/>';
						$thisTitle->licenceType = $apiInformation->licenceType;
						$thisTitle->maxStudents = $apiInformation->maxStudents;
						$thisTitle->maxTeachers = $apiInformation->maxTeachers;
						$thisTitle->maxReporters = $apiInformation->maxReporters;
						$thisTitle->maxAuthors = $apiInformation->maxAuthors;

						$thisTitle->productVersion = $apiInformation->productVersion;  //added by Dicky, 11/01/2013
						
						// Starting today
						$thisTitle->licenceStartDate = $apiInformation->subscription->startDate;
						$thisTitle->expiryDate = $apiInformation->subscription->expiryDate;
						$thisTitle->languageCode = $apiInformation->subscription->languageCode;
						
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
		$adminEmail = $account->adminUser->email;
		$emailData = array("account" => $account, "api" => $apiInformation);
		$emailArray = array("to" => $adminEmail, "data" => $emailData);
						
		// Check that the template exists
		// All templates for CLS exist in the subfolder
		$templateID='CLS/'.$templateID;
		if (!$this->templateOps->checkTemplate('emails', $templateID)) {
			throw new Exception ("This template doesn't exist. /CLS/$templateID");
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
			$emailArray['attachments'] = array(new stringAttachment($attachment, 'iLearnIELTS_'.$dataObject->subscription->orderRef.'.txt')); 
						
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
	
	// Changed from $account to $user, since that is what we are sending from LoginGateway
	// For sending out email once the user is created
	public function sendUserEmail($user, $apiInformation, $send=true) {
		$templateID = $apiInformation->emailTemplateID;
		$userEmail = $user->email;
		$emailData = array("user" => $user, "api" => $apiInformation);
		$emailArray = array("to" => $userEmail, "data" => $emailData);
						
		// Check that the template exists
		// All templates for user emails exist in the preset subfolder
		$templateID = 'user/'.$templateID;
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
				$file = $GLOBALS['logs_dir'].$templateID.$dataObject->subscription->orderRef.'.txt';
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
	public function sendAccountsEmail($api, $templateID = null, $send = true) {
		$to = 'accounts@clarityenglish.com';
		$emailData = array("api" => $api);
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
	public function saveAccount($account, $apiInformation) {
	
		if (stristr($apiInformation->method, 'update') !== false) {
			//echo "try to upgrade the account<br/>";
			$this->accountCops->updateAccounts(array($account));
		} else {
			// For early testing, you might not want to actually add the account
			$this->accountCops->addAccount($account);
		}
	}

	// Write the subscription record to the database and any logs that you want
	public function saveSubscription($apiInformation) {

		$this->db->StartTrans();

		// If you have been passed subscriptionID, it should be the key to this table, otherwise make a new record
		$assocArray = $apiInformation->subscription->toAssocArray();
		if (isset($apiInformation->subscriptionID)) {
			$this->db->AutoExecute("T_Subscription", $assocArray, "UPDATE", "F_SubscriptionID=".$apiInformation->subscription->id);
		} else {
			$this->db->AutoExecute("T_Subscription", $assocArray, "INSERT");
			$apiInformation->subscription->id = $this->db->Insert_ID();
		}
		
		// TODO: Write a file log as well in case database errors
		$this->db->CompleteTrans();
		
		return $apiInformation->subscription->id;
	
	}
	// Update the status of the subscription record
	// Maybe I need a more general update, but for now just add rootID
	public function updateSubscriptionStatus($api) {

		// You must have been passed subscriptionID
		if (isset($api->subscription->id)) {
			
			// Not sure if you need to explicitly set null?
			if (isset($api->subscription->rootID)) {
				$rootID = $api->subscription->rootID;
			} else {
				$rootID = NULL;
			}
			$sql = <<<EOD
				   UPDATE T_Subscription
				   SET F_Status = ?, F_RootID = ?, F_DateStamp = ? 
				   WHERE F_SubscriptionID = ?
EOD;
			$rs = $this->db->Execute($sql, array($api->subscription->status, $rootID, date('Y-m-d H:i:s'), $api->subscription->id));
			
			if ($rs) 
				return true;
		}
		
		return false;				
	}

	/*
	 * These functions for registering using a purchased token
	 */
    public function getTokenStatus($serial) {
        $dateStampNow = AbstractService::getNow();
        $dateNow = $dateStampNow->format('Y-m-d H:i:s');

        $token = $this->getToken($serial);
        if (!$token)
            throw new exception("No such token");

        if ($token->activationDate)
            return array("status" => "used", "token" => $token);
        if ($token->expiryDate < $dateNow)
            return array("status" => "expired", "token" => $token);
        return array("status" => "ok", "token" => $token);
    }
    public function getToken($serial) {
        $sql = <<<EOD
                SELECT * 
                FROM T_Token
                WHERE F_Serial=?
EOD;
        $bindingParams = array($serial);
        $rs = $this->db->Execute($sql, $bindingParams);

        if ($rs->RecordCount() == 1) {
            return new Token($rs->FetchNextObj());
        }
    }
    public function updateToken($token, $email, $userId) {
        $dateStampNow = AbstractService::getNow();
        $dateNow = $dateStampNow->format('Y-m-d H:i:s');

        $token->activationMethod = 'api.activateToken';
        $sql = <<<EOD
                  UPDATE T_Token
                  SET F_Email = ?, F_UserID = ?, F_ActivationDate = ?, F_ActivationMethod = ?
                  WHERE F_TokenID = ?
EOD;
        $bindingParams = array($email, $userId, $dateNow, 'api.activateToken', $token->id);
        $rs = $this->db->Execute($sql, $bindingParams);
        if (!$rs)
            throw new Exception("Database error for token generation");

    }

    // Generate serial numbers for tokens and add to table
    public function generateTokens($quantity, $productCode, $rootId, $groupId, $duration, $productVersion, $expiryDate) {
        $dateStampNow = AbstractService::getNow();
        $dateNow = $dateStampNow->format('Y-m-d H:i:s');
        $serials = array();
        // First create a record in the database using an incrementing index to insure it does
        // not conflict with anyone else doing the same thing. Then update it with a unique serial number
        try {
            for ($i = 0; $i < $quantity; $i++) {
                $sql = <<<EOD
                  INSERT INTO `T_Token` (`F_RootID`,`F_GroupID`,`F_ExpiryDate`,`F_Duration`,`F_ProductCode`,`F_ProductVersion`, `F_CreateDate`)
                  VALUES (?,?,?,?,?,?,?)
EOD;
                $bindingParams = array($rootId, $groupId, $expiryDate, $duration, $productCode, $productVersion, $dateNow);
                $rs = $this->db->Execute($sql, $bindingParams);
                if (!$rs)
                    throw new Exception("Database error for token generation");
                $id = $this->db->Insert_ID();
                $serial = $this->generateUniqueSerial($id);
                $serials[] = $serial;
                $sql = <<<EOD
                  UPDATE T_Token
                  SET F_Serial = ?
                  WHERE F_TokenID = ?
EOD;
                $bindingParams = array($serial, $id);
                $rs = $this->db->Execute($sql, $bindingParams);
                if (!$rs)
                    throw new Exception("Database error for token generation");
            }
        } catch (Exception $e) {
            throw new Exception("Database error for token generation");
        }
        if ($rs) {
            //$serials = array_map(function($row) { return explode(',', $row)[0]; }, $rows);
            return $serials;
        } else {
            return false;
        }
    }

    // TODO generate a 12 digit homomorphism from the index number, epoch and add a checksum
    private function generateUniqueSerial($seq) {
        $epoch = (string) time();
        $a = substr($epoch, -9);
        $b = substr($this->zeroPad($seq, 3), -3);
        $c = $a.$b;
        $d = $this->shuffle($c, $seq);
        $e = $this->checksum($d);
        return $this->hyphenate($d.$e, 4);
    }
    private function zeroPad($int, $digits) {
        $str = (string) $int;
        while (strlen($str) < $digits) {
            $str = '0'.$str;
        }
        return $str;
    }
    private function shuffle($str, $mask) {
        $builder = array();
        for ($i=0; $i<strlen($str); $i++) {
            $x = substr($str, $i, 1);
            if ((2**(strlen($str)-$i-1)) & $mask) {
                array_unshift($builder, $x);
            } else {
                array_push($builder, $x);
            }
        }
        return implode('',$builder);
    }
    private function checksum($isbn) {
        //Calculate check digit
        $check = 0;
        for ($i = 0; $i < 12; $i += 2) {
            $check += substr($isbn, $i, 1);
        }
        for ($i = 1; $i < 12; $i += 2) {
            $check += 3 * substr($isbn, $i, 1);
        }
        $check = 10 - $check % 10;
        if ($check === 10) {
            return 0;
        }
        return $check;
    }
    private function hyphenate($str, $groupLength) {
        $builder = array();
        for ($i=0; $i<strlen($str); $i+=$groupLength) {
            $builder[] = substr($str, $i, $groupLength);
        }
		return implode('-', $builder);
    }

    /**
	 * TB6weeks
	 * This is to check if you have already subscribed to this product.
	 * 
	 * return: null or the 
	 */
	public function hasProductSubscription($user, $productCode) {
		
		$subscription = $this->memoryCops->get('subscription', $productCode, $user->userID);
		if (!$subscription)
			return false;
			
		// Is this subscription valid?
		return (isset($subscription['valid']) && $subscription['valid']);
	}
	
	/**
	 * Based on the user set in the session, change their subscription.
	 * 
	 * return: true|false
	 */
	public function changeProductSubscription($productCode, $level, $bookmark, $dateDiff) {
		
		$now = new DateTime();
		
		$newSubscription = array('startDate' => $now->format('Y-m-d'), 'frequency' => $dateDiff, 'valid' => true);
		$this->memoryCops->set('subscription', $newSubscription);
		$this->memoryCops->set('level', $level);
		
		// The bookmark (which controls direct start), is written to Tense Buster memory, not TB6weeks.
		switch ($productCode) {
			case 59;
				return $this->memoryCops->set('directStart', $bookmark, $this->relatedProducts($productCode));
				break;
			default:
		}
		
	}
	
	/**
	 * Remove a student's subscription to this title.
	 * If they have other subscriptions those will not be removed and the user is not deleted.
	 * 
	 * Perhaps unsubscribe means remove yourself from this subscription - so no more TB6weeks. But you still exist as a user.
	 * Whilst this will completely delete the user, it will only do it if they have a subscription to this product. NO.
	 * 
	 * 
	 */
	public function removeProductSubscription($user, $productCode) {
		// Check that this user has a subscription (valid or not)
		$subscription = $this->memoryCops->get('subscription');
		
		if (!$subscription) {
			$status = 'no subscription';
			
		} else {
			$this->memoryCops->forget($user->userID, $productCode);
			$this->memoryCops->forget($user->userID, $this->relatedProducts($productCode), 'directStart');
			$status = 'done';
					
			// Does this user have other subscriptions?
			$rs = $this->memoryCops->getAllKeys('subscription');
			if ($rs) {
				if ($rs->recordCount() > 0)
					$status = 'other records';
			}
		}
		return $status;
	}

	/**
	 * Get all users in an account who have a subscription
	 * 
	 */
	public function getSubscribedUsersInAccount($account, $productCode) {
		$users = array();
		
		$sql = <<<SQL
			SELECT u.*
			FROM T_User u, T_Membership m, T_Memory me
			WHERE me.F_ProductCode = ?
			AND me.F_Key = 'subscription'
			AND me.F_UserID = u.F_UserID
			AND u.F_UserID = m.F_UserID
			AND m.F_RootID = ?
SQL;
		$bindingParams = array($productCode, $account->id);
		$rs = $this->db->Execute($sql, $bindingParams);
		if ($rs->RecordCount() > 0) {
			while ($dbObj = $rs->FetchNextObj()) {
				$user = new User();
				$user->fromDatabaseObj($dbObj);
				$users[] = $user;
			}
		}
		return $users;		
	}
	
	/**
	 * This might be better as a db lookup?
	 * Calculates the starting point for a subscription on its nth week in a particular level
	 * 
	 */
	public function getDirectStart($level, $unitsAdded = 0, $productCode = null) {
		if (!$productCode) $productCode = Session::get('productCode');
		$relatedProductCode = $this->relatedProducts($productCode);
		
		switch ($relatedProductCode) {
			case 55:
				switch ($level) {
					case 'ELE':
						$course = '1189057932446';
						switch ($unitsAdded) {
							case 0:
								$unit = '1192013076011'; // Am, is, are
								break;
							case 1:
								$unit = '1192013076627';
								break;
							case 2:
								$unit = '1192013076406';
								break;
							case 3:
								$unit = '1192013076042';
								break;
							case 4:
								$unit = '1192013076442';
								break;
							case 5:
								$unit = '1192013076075';
								break;
							default:
								return null;
						}
						break;
					case 'LI':
						$course = '1189060123431';
						switch ($unitsAdded) {
							case 0:
								$unit = '1192625080479'; // Simple present
								break;
							case 1:
								$unit = '1192625080536';
								break;
							case 2:
								$unit = '1192625080519';
								break;
							case 3:
								$unit = '1192625080036';
								break;
							case 4:
								$unit = '1192625080950';
								break;
							case 5:
								$unit = '1192625080483';
								break;
							default:
								return null;
						}
						break;
					case 'INT':
						$course = '1195467488046';
						switch ($unitsAdded) {
							case 0:
								$unit = '1195467532331'; // The passive
								break;
							case 1:
								$unit = '1195467532329';
								break;
							case 2:
								$unit = '1192625080157';
								break;
							case 3:
								$unit = '1195467532343';
								break;
							case 4:
								$unit = '1195467532330';
								break;
							case 5:
								$unit = '1195467532328';
								break;
							default:
								return null;
						}
						break;
						
					case 'UI':
						$course = '1190277377521';
						switch ($unitsAdded) {
							case 0:
								$unit = '1192625319203'; // Past continuous
								break;
							case 1:
								$unit = '1192625319263';
								break;
							case 2:
								$unit = '1192625319990';
								break;
							case 3:
								$unit = '1192625319573';
								break;
							case 4:
								$unit = '1192625319744';
								break;
							case 5:
								$unit = '1193054443818';
								break;
							default:
								return null;
						}
						break;
						
					case 'ADV':
						$course = '1196935701119';
						switch ($unitsAdded) {
							case 0:
								$unit = '1196216926895'; // Reported speech
								break;
							case 1:
								$unit = '1196301393947';
								break;
							case 2:
								$unit = '1196649107233';
								break;
							case 3:
								$unit = '1196204720339';
								break;
							case 4:
								$unit = '1196293510373';
								break;
							case 5:
								$unit = '1196641272970';
								break;
							default:
								return null;
						}
						break;
				}
				break;
				
			default:
				break;
		}
		
		return $relatedProductCode.'.'.$course.'.'.$unit;
	}
	
	/**
	 * Related products for subscriptions
	 * 
	 */
	public function relatedProducts($productCode) {
		switch ($productCode) {
			case 59:
				return 55;
				break;
		}
		return null;
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
}
