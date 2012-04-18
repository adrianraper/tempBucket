<?php
// With Bento we will start licence control again, so reinstate this class
class LicenceOps {

	var $db;
	
	// We expect Bento to update the licence record every minute that the user is connected
	// This is the number of minutes after which a licence record can be removed
	const LICENCE_DELAY = 2;
	
	function LicenceOps($db) {
		$this->db = $db;
		$this->copyOps = new CopyOps($db);
	}
	
	/**
	 * Check that this user can get a licence slot right now 
	 */
	function getLicenceSlot($user, $rootID, $productCode, $licence, $ip = '') {
		// Whilst rootID might be a comma delimited list, you can treat
		// licence control as simply use the first one in the list
		if (stristr($rootID, ',')) {
			$rootArray = explode(',', $rootID);
			$singleRootID = $rootArray[0];
		} else {
			$singleRootID = $rootID;
		}
			
		// Some checks are independent of licence type
		$dateNow = date('Y-m-d 23:59:59');
		if ($licence->licenceStartDate > $dateNow)
			throw $this->copyOps->getExceptionForId("errorLicenceHasntStartedYet");
		
		if ($licence->expiryDate < $dateNow)
			throw $this->copyOps->getExceptionForId("errorLicenceExpired", array("expiryDate" => $licence->expiryDate));
		
		// Then licence slot checking is based on licence type
		switch ($licence->licenceType) {
			// Concurrent licences
			case Title::LICENCE_TYPE_AA:
			case Title::LICENCE_TYPE_CT:
				$aWhileAgo = time() - LicenceOps::LICENCE_DELAY * 60;
				$updateTime = date('Y-m-d H:i:s', $aWhileAgo);
				
				// First, always delete old licences for this product/root
				$sql = <<<EOD
				DELETE FROM T_Licences 
				WHERE F_ProductCode=? 
				AND F_RootID=?
				AND (F_LastUpdateTime<? OR F_LastUpdateTime is null) 
EOD;
				$bindingParams = array($productCode, $singleRootID, $updateTime);
				$rs = $this->db->Execute($sql, $bindingParams);
				// the sql call failed
				if (!$rs)
					throw $this->copyOps->getExceptionForId("errorCantClearLicences");
				
				// Then count how many are currently in use
				$bindingParams = array($productCode, $singleRootID);			
	
				$sql = <<<EOD
				SELECT COUNT(F_LicenceID) as i FROM T_Licences 
				WHERE F_ProductCode=?
				AND F_RootID=? 
EOD;
				$rs = $this->db->Execute($sql, $bindingParams);
				$usedLicences = $rs->FetchNextObj()->i;

				if ($usedLicences >= $licence->maxStudents) 
					throw $this->copyOps->getExceptionForId("errorLicenceFull");
				
				// Insert this user in the licence control table
				$dateNow = date('Y-m-d H:i:s');
				//$bindingParams = array($userIP, $dateNow, $dateNow, $rootID, $productCode, $userID);
				$userID = $user->userID; 
				$sql = <<<EOD
				INSERT INTO T_Licences (F_UserHost, F_StartTime, F_LastUpdateTime, F_RootID, F_ProductCode, F_UserID) VALUES
				('$ip', '$dateNow', '$dateNow', $singleRootID, $productCode, $userID)
EOD;
				$rs = $this->db->Execute($sql);
				// v6.5.4.8 adodb will get the identity ID (F_LicenceID) for us.
				// Except that it fails. Seems due to fact that with parameters, the insert is in a different scope to the identity scope call so fails. 
				// If I don't do it with parameters then it works. Seems safe since nothing is typed by the user.
				$licenceID = $this->db->Insert_ID();

				// Final error check
				if (!$licenceID)
					throw $this->copyOps->getExceptionForId("errorCantAllocateLicenceNumber");

				break;

			// TODO. What about single and individual licences?
			case Title::LICENCE_TYPE_SINGLE:
			case Title::LICENCE_TYPE_I:
			
			// Named licences
			case Title::LICENCE_TYPE_LT:
			case Title::LICENCE_TYPE_TT:
				// Only track learners
				if ($user->userType != User::USER_TYPE_STUDENT) {
					$licenceID = 0;
				} else {
					// Has this user got an existing licence we can use?
					$licenceID = $this->checkExistingLicence($user, $productCode, $licence);
					if ($licenceID) {
						$licence->id = $licenceID;
						
						// If so, update their use of it
						$rc = $this->updateLicence($licence);
					} else {
						// How many licences have been used?
						if ($this->countUsedLicences($rootID, $productCode, $licence) < $licence->maxStudents) {
							// Grab one
							$licenceID = $this->allocateNewLicence($user, $rootID, $productCode);
						} else {
							throw $this->copyOps->getExceptionForId("errorLicenceFull");
						}
					}
				}
				break;
		}
		
		return $licenceID;
	}
	/**
	 * 
	 * Does this user already have a licence for this product?
	 * @param User $user
	 * @param Number $productCode
	 * @param Licence $licence
	 */
	function checkExistingLicence($user, $productCode, $licence) {
		// Is there a record in T_LicenceControl for this user/product since the date?
		$sql = <<<EOD
			SELECT F_LicenceID as i FROM T_LicenceControl 
			WHERE F_ProductCode=?
			AND F_UserID=?
			AND F_LastUpdateTime>=?
EOD;
		$bindingParams = array($productCode, $user->userID, $licence->licenceControlStartDate);
		$rs = $this->db->Execute($sql, $bindingParams);
		// SQL error
		if (!$rs)
			throw $this->copyOps->getExceptionForId("errorReadingLicenceControlTable");
		
		switch ($rs->RecordCount()) {
			case 0:
				return false;
				break;
			default:
				// Valid login, return the id
				return $rs->FetchNextObj()->i;
		}
	}
	/**
	 * 
	 * Count the number of used licences for this root / product since the clearance date
	 * @param String $rootID
	 * @param Number $productCode
	 * @param Licence $licence
	 */
	function countUsedLicences($rootID, $productCode, $licence) {
		// Transferable tracking needs to invoke the T_User table as well to ignore records from users that don't exist anymore.
		if ($licence->licenceType == Title::LICENCE_TYPE_TT) {
			$sql = <<<EOD
				SELECT COUNT(DISTINCT(c.F_UserID)) AS licencesUsed 
				FROM T_LicenceControl c, T_User u
				WHERE c.F_ProductCode = ?
				AND c.F_UserID = u.F_UserID
				AND c.F_LastUpdateTime >= ?
EOD;
		} else {
			$sql = <<<EOD
				SELECT COUNT(DISTINCT(F_UserID)) AS licencesUsed FROM T_LicenceControl
				WHERE F_ProductCode = ?
				AND F_LastUpdateTime >= ?
EOD;
		}
		
		if (stristr($rootID,',')!==FALSE) {
			$sql.= " AND F_RootID in ($rootID)";
		} else if ($rootID=='*') {
			// check all roots in that case - just for special cases, usually self-hosting
		} else {
			$sql.= " AND F_RootID = $rootID";
		}
		$bindingParams = array($productCode, $licence->licenceControlStartDate);
		$rs = $this->db->Execute($sql, $bindingParams);
		
		if ($rs && $rs->RecordCount()>0) {
			$licencesUsed = (int)$rs->FetchNextObj()->licencesUsed;
		} else {
			throw $this->copyOps->getExceptionForId("errorReadingLicenceControlTable");
		}
				
		return $licencesUsed;
	}
	
	/**
	 * 
	 * Add a new record to the licence control table for this user/product
	 * @param User $user
	 * @param String $rootID
	 * @param Number $productCode
	 */
	function allocateNewLicence($user, $rootID, $productCode) {
		// Insert this user in the licence control table
		$dateNow = date('Y-m-d H:i:s');
		//$bindingParams = array($userIP, $dateNow, $dateNow, $rootID, $productCode, $userID);
		$sql = <<<EOD
		INSERT INTO T_LicenceControl (F_UserID, F_ProductCode, F_RootID, F_LastUpdateTime) VALUES
		($user->userID, $productCode, $rootID, '$dateNow')
EOD;
		$rs = $this->db->Execute($sql);
		$licenceID = $this->db->Insert_ID();

		// Final error check
		if (!$licenceID)
			throw $this->copyOps->getExceptionForId("errorCantAllocateLicenceNumber");
		
		return $licenceID;
	}
	
	/**
	 * 
	 * This function updates a licence record with a timestamp
	 * @param Number $id
	 * @param Licence $licence
	 */
	function updateLicence($licence) {
		$dateNow = date('Y-m-d H:i:s');

		// The licence slot checking is based on licence type
		switch ($licence->licenceType) {
			// Concurrent licences
			case Title::LICENCE_TYPE_AA:
			case Title::LICENCE_TYPE_CT:
				$licenceControlTable = 'T_Licences';
				break;
				
			// TODO. What about single and individual licences?
			case Title::LICENCE_TYPE_SINGLE:
			case Title::LICENCE_TYPE_I:
			
			// Named licences
			case Title::LICENCE_TYPE_LT:
			case Title::LICENCE_TYPE_TT:
				$licenceControlTable = 'T_LicenceControl';
				break;
				
			default:
				throw $this->copyOps->getExceptionForId("errorUnrecognisedLicenceType", array("licenceType" => $licence->licenceType));
		}
				
		// First need to confirm that this licence record exists
		$sql = <<<EOD
			SELECT * FROM $licenceControlTable
			WHERE F_LicenceID=?
EOD;
		$bindingParams = array($licence->id);
		$rs = $this->db->Execute($sql, $bindingParams);
		if (!$rs || $rs->RecordCount() != 1) 
			throw $this->copyOps->getExceptionForId("errorCantFindLicence", array("licenceID" => $licence->id));

		// Update the licence in the table
		$sql = <<<EOD
			UPDATE $licenceControlTable 
			SET F_LastUpdateTime=?
			WHERE F_LicenceID=?
EOD;
		$bindingParams = array($dateNow, $licence->id);
		$rs = $this->db->Execute($sql, $bindingParams);
		if (!$rs)
			throw $this->copyOps->getExceptionForId("errorCantUpdateLicence", array("licenceID" => $licence->id));
	}

	/**
	 * 
	 * This function closes this licence record
	 * @param Number $id
	 * @param Licence $licence
	 */
	function dropLicenceSlot($licence) {
		// The licence slot checking is based on licence type
		switch ($licence->licenceType) {
			
			// Concurrent licences
			case Title::LICENCE_TYPE_AA:
			case Title::LICENCE_TYPE_CT:
				
				// First need to confirm that this licence record exists
				$sql = <<<EOD
					SELECT * FROM T_Licences
					WHERE F_LicenceID=?
EOD;
				$bindingParams = array($licence->id);
				$rs = $this->db->Execute($sql, $bindingParams);
				if (!$rs || $rs->RecordCount() != 1)
					throw $this->copyOps->getExceptionForId("errorCantFindLicence", array("licenceID" => $licence->id));
					
				$sql = <<<EOD
					DELETE FROM T_Licences 
					WHERE F_LicenceID=?
EOD;
				$bindingParams = array($licence->id);
				$rs = $this->db->Execute($sql, $bindingParams);
				if (!$rs)
					throw $this->copyOps->getExceptionForId("errorCantDeleteLicence", array("licenceID" => $licence->id));
					
				break;
		
			// TODO. What about single and individual licences?
			case Title::LICENCE_TYPE_SINGLE:
			case Title::LICENCE_TYPE_I:
			
			// Named licences
			case Title::LICENCE_TYPE_LT:
			case Title::LICENCE_TYPE_TT:

				// Since you NEVER delete the T_LicenceControl records, just do an update
				$this->updateLicence($licence);
				break;
		}

	}
	
}