<?php

class LicenceOps {

	var $db;

	function LicenceOps($db) {
		$this->db = $db;
		
		$this->manageableOps = new ManageableOps($db);
		$this->copyOps = new CopyOps($db);
	}

	// v3.2 This function is deprecated
	function getLicences() {
		$sql = 	<<<EOD
				SELECT l.F_ProductCode, l.F_UserID
				FROM T_TitleLicences l
				WHERE F_RootID=?
				ORDER BY l.F_ProductCode;
EOD;

		$licencesRS = $this->db->Execute($sql, array(Session::get('rootID')));
		
		$licences = array();
		while ($licenceObj = $licencesRS->FetchNextObj()) {
			$productCode = $licenceObj->F_ProductCode;
			if ($licences[$productCode] == null)
				$licences[$productCode] = array();
			
			$licences[$productCode][] = (string)($licenceObj->F_UserID);
		}
		
		return $licences;
	}
	
	// v3.2 This function is deprecated
	function allocateLicences($userIdArray, $productCode) {
		// Check that the logged in user is allowed to access these users
		AuthenticationOps::authenticateUserIDs($userIdArray);
		
		// Check that adding these users doesn't exceed the licence limit.  Get the current number of allocated students and the maximum
		// allowed for this product and root.
		$sql = 	<<<EOD
				SELECT COUNT(*) CurrentStudents
				FROM T_TitleLicences l
				WHERE l.F_ProductCode=? AND l.F_RootID=?
EOD;
		
		$rs = $this->db->GetRow($sql, array($productCode, Session::get('rootID')));
		$currentStudents = $rs['CurrentStudents'];
		
		$sql = 	<<<EOD
				SELECT a.F_MaxStudents
				FROM T_Accounts a
				WHERE a.F_ProductCode=? AND a.F_RootID=?
EOD;
		
		$rs = $this->db->GetRow($sql , array($productCode, Session::get('rootID')));
		$maxStudents = $rs['F_MaxStudents'];
		
		if ($maxStudents != null && (sizeof($userIdArray) + $currentStudents) > $maxStudents) {
			$amount = sizeof($userIdArray) + $currentStudents - $maxStudents;
			
			// Return a subsituted error message from the literals
			$replaceObj = array("userCount" => $amount);
			throw new Exception($this->copyOps->getCopyForId("tooManyUsersToAllocate", $replaceObj));
		}
		
		$this->db->StartTrans();
		
		// First attempt to delete all existing licences as duplicates can cause errors and not sure if MSSQL has REPLACE
		$this->unallocateLicences($userIdArray, $productCode);
		
		foreach ($userIdArray as $userID) {
			$dbObj = array();
			$dbObj['F_UserID'] = $userID;
			$dbObj['F_ProductCode'] = $productCode;
			$dbObj['F_RootID'] = Session::get('rootID');
			$this->db->AutoExecute("T_TitleLicences", $dbObj, "INSERT");
		}
		
		$this->db->CompleteTrans();
		
		return true;
	}
	
	// v3.2 This function is deprecated
	function unallocateLicences($userIdArray, $productCode) {
		// Check that the logged in user is allowed to access these users
		AuthenticationOps::authenticateUserIDs($userIdArray);
		
		$this->db->StartTrans();
		
		foreach ($userIdArray as $userID) {
			$sql = 	<<<EOD
					DELETE FROM T_TitleLicences WHERE
					F_UserID=? AND
					F_ProductCode=? AND
					F_RootID=?
EOD;
			
			$this->db->Execute($sql, array($userID, $productCode, Session::get('rootID')));
		}
		
		$this->db->CompleteTrans();
		
		return true;
	}
	
	/**
	 * Dynamically generate a licence.ini file from the given account id and product code
	 */
	function generateLicenceFile($accountID, $productCode) {
		// Since this may not be included (if this is a RM install, for example) we can't create AccountOps or TemplateOps in the constructor.
		$accountOps = new AccountOps($this->db);
		$templateOps = new TemplateOps($this->db);
		
		// Get the account
		$accounts = $accountOps->getAccounts(array($accountID));
		$account = $accounts[0];

		// Get the title
		$title = $account->getTitleByProductCode($productCode);

		// Get the licence file from the template
		$licenceFileText = $templateOps->fetchTemplate("licences/licence_file", array("account" => $account, "title" => $title));

		// Generate the checksum,  Not quite sure if this is correct!
		$checksum = md5("claritylicencechecksum" + $licenceFileText);

		// Add it to the licence file
		$licenceFileText .= "\nCheckSum=$checksum";
		
		return $licenceFileText;
	}

}

?>
