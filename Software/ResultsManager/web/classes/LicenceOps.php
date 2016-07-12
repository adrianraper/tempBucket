<?php
// With Bento we will start licence control again, so reinstate this class
class LicenceOps {

	var $db;
	
	// We expect Bento to update the licence record every minute that the user is connected
	// This is the number of minutes after which a licence record can be removed
	// gh#815, gh#900, gh#1342
	const LICENCE_DELAY = 2; // production = 2
    const HIBERNATE_DELAY = 15; // production = 2

	function LicenceOps($db) {
		$this->db = $db;
		$this->copyOps = new CopyOps();
	}
	
	/**
	 * If you changed the db, you'll need to refresh it here
	 * Not a very neat function...
	 */
	function changeDB($db) {
		$this->db = $db;
	}
	
	/**
	 * Check that this user can get a licence slot right now
	 */
	function getLicenceSlot($user, $rootID, $productCode, $licence, $ip = '') {
		// Whilst rootID might be a comma delimited list, you can treat
		// licence control as simply use the first one in the list
		// TODO. This will stop groupedRoots from working!
		if (stristr($rootID, ',')) {
			$rootArray = explode(',', $rootID);
			$singleRootID = $rootArray[0];
		} else {
			$singleRootID = $rootID;
		}
			
		// Some checks are independent of licence type
		// gh#815
		//$dateNow = date('Y-m-d 23:59:59');
		$dateStampNow = new DateTime('now', new DateTimeZone(TIMEZONE));
		$dateNow = $dateStampNow->format('Y-m-d 23:59:59');
        $aShortWhileAgo = $dateStampNow->modify('-'.(LicenceOps::LICENCE_DELAY * 60).' secs')->format('Y-m-d H:i:s');
        $aLongerWhileAgo = $dateStampNow->modify('-'.(LicenceOps::HIBERNATE_DELAY * 60).' secs')->format('Y-m-d H:i:s');

		if ($licence->licenceStartDate > $dateNow)
			throw $this->copyOps->getExceptionForId("errorLicenceHasntStartedYet");
		
		if ($licence->expiryDate < $dateNow) {
			// Write a record to the failure table
			$this->failLicenceSlot($user, $singleRootID, $productCode, $licence, $ip, $this->copyOps->getCodeForId("errorLicenceExpired"));
			
			throw $this->copyOps->getExceptionForId("errorLicenceExpired", array("expiryDate" => $licence->expiryDate));
		}
		
		// Then licence slot checking is based on licence type
		switch ($licence->licenceType) {
			case Title::LICENCE_TYPE_AA:
			case Title::LICENCE_TYPE_CT:
			case Title::LICENCE_TYPE_NETWORK:
				// Only check on learners. AA licence doesn't have teachers, but a CT licence will
				if ($user->userType != User::USER_TYPE_STUDENT) {
					$licenceID = 0;
					
				} else {
                    // gh#1342 Reorder so that first check is to see if there is a free licence you can use
                    $usedLicences = $this->countCurrentLicences($productCode, $singleRootID);
                    //AbstractService::$debugLog->info('licences in use='.$usedLicences);
                    if ($usedLicences >= $licence->maxStudents) {

                        // Then, if not, delete the ones that are not hibernating and check again
                        $sql = <<<EOD
                            DELETE FROM T_Licences
                            WHERE F_ProductCode=?
                            AND F_RootID=?
                            AND NOT F_Hibernating
                            AND (F_LastUpdateTime<? OR F_LastUpdateTime is null)
EOD;
                        $bindingParams = array($productCode, $singleRootID, $aShortWhileAgo);
                        $rs = $this->db->Execute($sql, $bindingParams);
                        if (!$rs) {
                            // Write a record to the failure table
                            $this->failLicenceSlot($user, $singleRootID, $productCode, $licence, $ip, $this->copyOps->getCodeForId("errorCantClearLicences"));

                            throw $this->copyOps->getExceptionForId("errorCantClearLicences");
                        }
                        $usedLicences = $this->countCurrentLicences($productCode, $singleRootID);
                        //AbstractService::$debugLog->info('after clearing closed ones, licences in use='.$usedLicences);

                        if ($usedLicences >= $licence->maxStudents) {
                            // gh#1342 Then a longer time for those that ARE hibernating
                            $sql = <<<EOD
                                DELETE FROM T_Licences
                                WHERE F_ProductCode=?
                                AND F_RootID=?
                                AND F_Hibernating
                                AND (F_LastUpdateTime<? OR F_LastUpdateTime is null)
EOD;
                            $bindingParams = array($productCode, $singleRootID, $aLongerWhileAgo);
                            $rs = $this->db->Execute($sql, $bindingParams);
                            if (!$rs) {
                                // Write a record to the failure table
                                $this->failLicenceSlot($user, $singleRootID, $productCode, $licence, $ip, $this->copyOps->getCodeForId("errorCantClearLicences"));

                                throw $this->copyOps->getExceptionForId("errorCantClearLicences");
                            }
                            $usedLicences = $this->countCurrentLicences($productCode, $singleRootID);
                            //AbstractService::$debugLog->info('after clearing hibernating ones (since '.$aLongerWhileAgo.' ), licences in use='.$usedLicences);

                            if ($usedLicences >= $licence->maxStudents) {
                                // You really can't get a space
                                $this->failLicenceSlot($user, $singleRootID, $productCode, $licence, $ip, $this->copyOps->getCodeForId("errorConcurrentLicenceFull"));

                                throw $this->copyOps->getExceptionForId("errorConcurrentLicenceFull");
                            }
                        }
                    }

					// Insert this user in the licence control table
					$dateStampNow = new DateTime('now', new DateTimeZone(TIMEZONE));
					$dateNow = $dateStampNow->format('Y-m-d H:i:s');
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
				}
				break;

			// Currently treated as tracking types.
			case Title::LICENCE_TYPE_SINGLE:
			case Title::LICENCE_TYPE_I:
			case Title::LICENCE_TYPE_LT:
			case Title::LICENCE_TYPE_TT:
				// Only track learners
				if ($user->userType != User::USER_TYPE_STUDENT) {
					$licenceID = 0;
					
				} else {
                    // gh#1496 Clarity Tests never block you from signing in due to licence issues
                    if (Session::getSessionName() == "CTPService") {
                        $licenceID = $user->userID;
                    } else {
                        // Has this user got an existing licence we can use?
                        $existingUser = $this->checkExistingLicence($user, $productCode, $licence);
                        if ($existingUser) {
                            $licenceID = $user->userID;

                            // If so, update their use of it
                            // Deprecated as the session record is effectively the last licence use
                            //$rc = $this->updateLicence($licence);
                        } else {
                            // How many licences have been used?
                            $licenceCount = $this->countUsedLicences($singleRootID, $productCode, $licence);
                            if ($licenceCount < $licence->maxStudents) {
                                // Grab one
                                // Deprecated as the session record is effectively the last licence use
                                //$licenceID = $this->allocateNewLicence($user, $rootID, $productCode);
                                $licenceID = $user->userID;
                            } else {
                                // Write a record to the failure table
                                $this->failLicenceSlot($user, $singleRootID, $productCode, $licence, $ip, $this->copyOps->getCodeForId("errorTrackingLicenceFull"));

                                throw $this->copyOps->getExceptionForId("errorTrackingLicenceFull");
                            }
                        }
                    }
				}
				break;
			default:
				// Write a record to the failure table
				$this->failLicenceSlot($user, $singleRootID, $productCode, $licence, $ip, $this->copyOps->getCodeForId("errorInvalidLicenceType"));
				
				throw $this->copyOps->getExceptionForId("errorInvalidLicenceType");
		}
		
		return $licenceID;
	}
    /**
     * Count how many licences are currently in use
     */
    private function countCurrentLicences($productCode, $rootId)
    {
        $sql = <<<EOD
            SELECT COUNT(F_LicenceID) as i FROM T_Licences
        	WHERE F_ProductCode=?
		    AND F_RootID=?
EOD;
        $bindingParams = array($productCode, $rootId);
        $rs = $this->db->Execute($sql, $bindingParams);
        return $rs->FetchNextObj()->i;
    }

	/**
	 * 
	 * Does this user already have a licence for this product?
	 * Change to use T_Session for tracking licence use
	 * @param User $user
	 * @param Number $productCode
	 * @param Licence $licence
	 */
	function checkExistingLicence($user, $productCode, $licence) {
		// Is there a record in T_Session for this user/product since the date?
		// v6.6.4 change to counting based on F_StartDateStamp to avoid problems in F_EndDateStamp
		// gh#125 Need exactly the same conditions here as with countUsedLicences
		$sql = <<<EOD
			SELECT * FROM T_Session s
			WHERE s.F_UserID = ?
			AND s.F_StartDateStamp >= ?
			AND s.F_Duration > 15
EOD;

		// gh#1211 And the other old and new combinations
		$oldProductCode = $this->getOldProductCode($productCode);
		if ($oldProductCode) {
			$sql.= " AND s.F_ProductCode IN (?, $oldProductCode)";
		} else {
			$sql.= " AND s.F_ProductCode = ?";
		}			
		$bindingParams = array($user->userID, $licence->licenceControlStartDate, $productCode);
		$rs = $this->db->Execute($sql, $bindingParams);
		
		// SQL error
		if (!$rs)
			throw $this->copyOps->getExceptionForId("errorReadingLicenceControlTable");
		
		switch ($rs->RecordCount()) {
			case 0:
				return false;
				break;
			default:
				// Valid login, return the last session ID
				// Simply return that they have used a licence already
				// return $rs->FetchNextObj()->F_SessionID;
				return true;
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
		// v6.6.4 change to counting based on F_StartDateStamp to avoid problems in F_EndDateStamp
		if ($licence->licenceType == Title::LICENCE_TYPE_TT) {
			$sql = <<<EOD
				SELECT COUNT(DISTINCT(s.F_UserID)) AS licencesUsed 
				FROM T_Session s, T_User u
				WHERE s.F_UserID = u.F_UserID
				AND s.F_StartDateStamp >= ?
				AND s.F_Duration > 15
EOD;
		} else {
			// gh#604 Teacher records in session will now include root, so ignore them here
			// gh#1228 But that ignores deleted/archived users, so revert
			$sql = <<<EOD
				SELECT COUNT(DISTINCT(s.F_UserID)) AS licencesUsed 
				FROM T_Session s
				WHERE s.F_StartDateStamp >= ?
				AND s.F_Duration > 15
EOD;
		}
		
		// gh#1211 And the other old and new combinations
		$oldProductCode = $this->getOldProductCode($productCode);
		if ($oldProductCode) {
			$sql.= " AND s.F_ProductCode IN (?, $oldProductCode)";
		} else {
			$sql.= " AND s.F_ProductCode = ?";
		}			
							
		if (stristr($rootID,',')!==FALSE) {
			$sql.= " AND s.F_RootID in ($rootID)";
		} else if ($rootID=='*') {
			// check all roots in that case - just for special cases, usually self-hosting
			// Note that leaving the root empty would include teachers
			$sql.= " AND s.F_RootID > 0";
		} else {
			$sql.= " AND s.F_RootID = $rootID";
		}
		$bindingParams = array($licence->licenceControlStartDate, $productCode);
		$rs = $this->db->Execute($sql, $bindingParams);
		
		if ($rs && $rs->RecordCount() > 0) {
			$licencesUsed = (int)$rs->FetchNextObj()->licencesUsed;
		} else {
			throw $this->copyOps->getExceptionForId("errorReadingLicenceControlTable");
		}
				
		return $licencesUsed;
	}
	
	/**
	 * DEPRECATED
	 * Add a new record to the licence control table for this user/product
	 * @param User $user
	 * @param String $rootID
	 * @param Number $productCode
	 */
	/*
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
	*/
	/**
	 * 
	 * This function updates a licence record with a timestamp
	 * @param Number $id
	 * @param Licence $licence
	 */
    // gh#1342
	function updateLicence($licence, $hibernate = false) {

		// gh#604 Teacher records with licence=0 do not need updating
		if ($licence->id <= 0)
			return false;

		// gh#815
		//$dateNow = date('Y-m-d H:i:s');
		$dateStampNow = new DateTime('now', new DateTimeZone(TIMEZONE));
		$dateNow = $dateStampNow->format('Y-m-d H:i:s');
		
		// The licence slot checking is based on licence type
		switch ($licence->licenceType) {
			// Concurrent licences
			case Title::LICENCE_TYPE_AA:
			case Title::LICENCE_TYPE_CT:
			case Title::LICENCE_TYPE_NETWORK:
				$licenceControlTable = 'T_Licences';
				break;
				
			// TODO. What about single and individual licences?
			case Title::LICENCE_TYPE_SINGLE:
			case Title::LICENCE_TYPE_I:
			
			// Named licences
			case Title::LICENCE_TYPE_LT:
			case Title::LICENCE_TYPE_TT:
				
				// Not used for Tracking licences anymore
				// $licenceControlTable = 'T_LicenceControl';
				return false;
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
        // gh#1342
		$sql = <<<EOD
			UPDATE $licenceControlTable 
			SET F_LastUpdateTime=?, F_Hibernating=?
			WHERE F_LicenceID=?
EOD;
		$bindingParams = array($dateNow, $hibernate, $licence->id);
		$rs = $this->db->Execute($sql, $bindingParams);
        //AbstractService::$debugLog->info('time='.$dateNow.' id='.$licence->id.' hibernate='.$hibernate);
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
			case Title::LICENCE_TYPE_NETWORK:
				
				// First need to confirm that this licence record exists
				// No point in this. Simply try to delete the licence if you can.
				// You don't want to throw errors at this point, just keep clearing up.
				/*
				$sql = <<<EOD
					SELECT * FROM T_Licences
					WHERE F_LicenceID=?
EOD;
				$bindingParams = array($licence->id);
				$rs = $this->db->Execute($sql, $bindingParams);
				if (!$rs || $rs->RecordCount() != 1)
					throw $this->copyOps->getExceptionForId("errorCantFindLicence", array("licenceID" => $licence->id));
				*/
				$sql = <<<EOD
					DELETE FROM T_Licences 
					WHERE F_LicenceID=?
EOD;
				$bindingParams = array($licence->id);
				$rs = $this->db->Execute($sql, $bindingParams);
				/*
				if (!$rs)
					throw $this->copyOps->getExceptionForId("errorCantDeleteLicence", array("licenceID" => $licence->id));
				*/
				break;
		
			// TODO. What about single and individual licences?
			case Title::LICENCE_TYPE_SINGLE:
			case Title::LICENCE_TYPE_I:
			
			// Named licences
			case Title::LICENCE_TYPE_LT:
			case Title::LICENCE_TYPE_TT:

				// Nothing to do
				break;
		}

	}
	/**
	 * Record the failure to get a licence or otherwise start the program 
	 */
	function failLicenceSlot($user, $rootID, $productCode, $licence, $ip = '', $reasonCode) {
		
		if (!$ip) 
			$ip = $_SERVER['REMOTE_ADDR'];
			
		if ($reasonCode == null || $reasonCode == '')
			$reasonCode = 0;
			
		$dateStampNow = new DateTime('now', new DateTimeZone(TIMEZONE));
		$dateNow = $dateStampNow->format('Y-m-d H:i:s');
		$bindingParams = array($ip, $dateNow, $rootID, $user->id, $productCode, $reasonCode);
		$sql = <<<EOD
			INSERT INTO T_Failsession (F_UserIP, F_StartTime, F_RootID, F_UserID, F_ProductCode, F_ReasonCode)
			VALUES (?, ?, ?, ?, ?, ?)
EOD;
		$rs = $this->db->Execute($sql, $bindingParams);
		
	}

	/**
	 * Count how many licences have been used in this licence period. 
	 * Moved from UsageOps when updated to using simple T_Session count.
	 * gh#125 duplicate of countUsedLicences, so merge into that 
	 */
	public function countLicencesUsed($title, $rootID, $fromDateStamp = null) {
		// gh#125 convert types of passed object
		$productCode = $title->productCode;
		$licence = new Licence();
		$licence->licenceClearanceDate = $title->licenceClearanceDate;
		$licence->licenceStartDate = $title->licenceStartDate;
		$licence->licenceClearanceFrequency = $title->licenceClearanceFrequency;
		$licence->licenceType = $title->licenceType;
		$licence->findLicenceClearanceDate();
		
		return $this->countUsedLicences($rootID, $productCode, $licence);
		/*
		if (!$fromDateStamp)
			$fromDateStamp = $this->getLicenceClearanceDate($title);
			
		$fromDate = strftime('%Y-%m-%d 00:00:00', $fromDateStamp);
		
		// Transferable tracking needs to invoke the T_User table as well to ignore records from users that don't exist anymore.
		// v6.6.4 change to counting based on F_StartDateStamp to avoid problems in F_EndDateStamp
		if ($title->licenceType == Title::LICENCE_TYPE_TT) {
			$sql = <<<EOD
				SELECT COUNT(DISTINCT(u.F_UserID)) AS licencesUsed 
				FROM T_Session s, T_User u
				WHERE s.F_UserID = u.F_UserID
				AND s.F_StartDateStamp >= ?
				AND s.F_Duration > 15
EOD;
		} else {
			$sql = <<<EOD
				SELECT COUNT(DISTINCT(s.F_UserID)) AS licencesUsed 
				FROM T_Session s
				WHERE s.F_StartDateStamp >= ?
				AND s.F_Duration > 15
EOD;
		}
		if (stristr($rootID,',')!==FALSE) {
			$sql.= " AND s.F_RootID in ($rootID)";
		} else if ($rootID=='*') {
			// check all roots in that case - just for special cases, usually self-hosting
			// Note that leaving the root empty would include teachers
			$sql.= " AND s.F_RootID > 0";
		} else {
			$sql.= " AND s.F_RootID = $rootID";
		}
		
		// To allow old Road to IELTS to count with the new
		if ($title->productCode == 52) {
			$sql.= " AND s.F_ProductCode IN (?, 12)";
		} else if ($title->productCode == 53) {
			$sql.= " AND s.F_ProductCode IN (?, 13)";
		} else {
			$sql.= " AND s.F_ProductCode = ?";			
		}
		
		$rs = $this->db->GetRow($sql, array($fromDate, $title->productCode));
		if ($rs) {
			$licencesUsed = (int)$rs['licencesUsed'];
		} else {
			$licencesUsed = 0;
		}
		return $licencesUsed;
		*/
	}

	// v3.6.5 Figure out the most recent clearance date
	// Moved from UsageOps
	public function getLicenceClearanceDate($title) {
		// The from date for counting licence use is calculated as follows:
		// If there is no licenceClearanceDate, then use licenceStartDate.
		// If there is no licenceClearanceFrequency, then use +1y
		// Take licenceClearanceDate and add the frequency to it until we get a date in the future.
		// The previous date is our fromDate.
		if (!$title->licenceClearanceDate) 
			$title->licenceClearanceDate = $title->licenceStartDate;
		if (!$title->licenceClearanceFrequency)
			$title->licenceClearanceFrequency = '1 year';
			
		// Just in case dates have been put in wrongly. 
		// First, if clearance date is in the future, use the start date
		if (strtotime($title->licenceClearanceDate) > time()) 
			$title->licenceClearanceDate = $title->licenceStartDate;
			
		// If clearance date is before the start date, it doesn't much matter
		// Turn the string into a timestamp
		$fromDateStamp = strtotime($title->licenceClearanceDate);
		
		// You mustn't have a negative frequency otherwise the loop will be infinite
		if (stristr($title->licenceClearanceFrequency, '-')!==FALSE) 
			$title->licenceClearanceFrequency = str_replace('-', '', $title-> licenceClearanceFrequency);
		// Check that the frequency is valid
		if (!strtotime($title->licenceClearanceFrequency, $fromDateStamp) > 0)
			$title->licenceClearanceFrequency = '1 year';
			
		// Just in case we still have invalid data
		//NetDebug::trace("fromDateStamp=".$fromDateStamp.' which is '.strftime('%Y-%m-%d 00:00:00',$fromDateStamp));
		$safetyCount=0;
		while ($safetyCount<99 && strtotime($title->licenceClearanceFrequency, $fromDateStamp) < time()) {
			$fromDateStamp = strtotime($title->licenceClearanceFrequency, $fromDateStamp);
			$safetyCount++;
		}
		// We want the datestamp, not a formatted date
		return $fromDateStamp;
	}

	// gh#1211 To allow old and new versions of titles to be counted together for licences and usage
	public function getOldProductCode($pc) {
		switch ($pc) {
			case 52:
				return 12;
				break;
			case 53:
				return 13;
				break;
			case 55:
				return 9;
				break;
			case 56:
				return 33;
				break;
			case 60:
				return 49;
				break;
			case 58:
				return 50;
				break;
			case 57:
				return 39;
				break;
			case 62:
				return 10;
				break;
		}
		return false;
	}
	
}