<?php
/*
 * A couloir version of Bento's LicenceOps
 * Implements sss#61, sss#82
 */

class LicenceCops {

    var $db;

    // The licence server will let an AA licence linger for 1 minute with no internet connection
    // and for 5 minutes without any activity in the app.
    // The back end uses 2 minutes for expiry of AA if the licence server has forgotten a licence.
    const LICENCE_DELAY = 5;
    const AA_LICENCE_EXTENSION = 120;
    const AA_RECONNECTION_WINDOW = 60;
    const AA_INACTIVITY_WINDOW = 300; // 30 days
    const LT_RECONNECTION_WINDOW = 2592000; // 30 days
    const LT_INACTIVITY_WINDOW = 2592000; // 30 days

    //const HIBERNATE_DELAY = 15; // production = 2

    function LicenceCops($db) {
        $this->db = $db;
        $this->copyOps = new CopyOps();
        $this->manageableOps = new ManageableOps($db);
        $this->accountCops = new AccountCops($db);
        $this->contentOps = new ContentOps($db);
        $this->loginCops = new LoginCops($db);
    }

    /**
     * If you changed the db, you'll need to refresh it here
     * Not a very neat function...
     */
    function changeDB($db) {
        $this->db = $db;
    }

    /*
     * A check that an existing licence is still valid,
     */
    public function checkCouloirLicenceSlot($session) {
        // For AA licences, userId will be a generic -1 - or the anonymous user for an account
        $sessionId = $session->sessionId;
        $userId = $session->userId;
        $rootId = $session->rootId;
        $productCode = $session->productCode;
        $licence = $this->accountCops->getLicenceDetails($rootId, $productCode);

        // Then licence slot checking is based on licence type
        switch ($licence->licenceType) {
            // No need to check LT licence other than during sign-in
            case Title::LICENCE_TYPE_SINGLE:
            case Title::LICENCE_TYPE_I:
            case Title::LICENCE_TYPE_LT:
            case Title::LICENCE_TYPE_TT:
                $reconnectionWindow = LicenceCops::LT_RECONNECTION_WINDOW;
                $inactivityWindow = LicenceCops::LT_INACTIVITY_WINDOW;
                break;

            case Title::LICENCE_TYPE_AA:
            case Title::LICENCE_TYPE_CT:
            case Title::LICENCE_TYPE_NETWORK:
            default:
                // TODO It is possible that a licence might have specific time limits to override these defaults
                $reconnectionWindow = LicenceCops::AA_RECONNECTION_WINDOW;
                $inactivityWindow = LicenceCops::AA_INACTIVITY_WINDOW;

                $activeLicence = $this->checkCurrentLicence($productCode, $rootId, $sessionId, $userId, $licence);
                if ($activeLicence) {
                    $this->extendLicence($sessionId);
                } else {
                    return ["hasLicenseSlot" => false];
                }
                break;

        }
        // sss#192 Check the instance id - does it still match the sign in one?
        if ($userId > 0) {
            $instanceId = $this->loginCops->getInstanceId($userId, $productCode);
            if ($sessionId != $instanceId) {
                return ["hasLicenseSlot" => false];
            }
        }

        return ["hasLicenseSlot" => true, "reconnectionWindow" => $reconnectionWindow, "inactivityWindow" => $inactivityWindow];
    }

    /*
     * Get a licence slot for this session
     *  Check the account to find the licence type and limits
     *  Check if a current licence exists
     *  Grant a new licence if possible
     *
     * Return an exception if no licence slot available, or reconnectionWindow if ok
     * Takes care of all database records related to the licence
     *
     */
    function acquireCouloirLicenceSlot($session) {

        // For AA licences, userId will be a generic -1 - or the anonymous user for an account
        $sessionId = $session->sessionId;
        $userId = $session->userId;
        $user = $this->manageableOps->getCouloirUserFromID($userId);
        $rootId = $session->rootId;
        $productCode = $session->productCode;
        $licence = $this->accountCops->getLicenceDetails($rootId, $productCode);

        // Some checks are independent of licence type
        // gh#815
        $dateStampNow = AbstractService::getNow();
        $dateNow = $dateStampNow->format('Y-m-d H:i:s');
        // An AA licence stays active for 5 minutes if untouched
        //$aShortWhileAgo = $dateStampNow->modify('-'.(LicenceCops::LICENCE_DELAY * 60).' secs')->format('Y-m-d H:i:s');
        //$aLongerWhileAgo = $dateStampNow->modify('-'.(LicenceOps::HIBERNATE_DELAY * 60).' secs')->format('Y-m-d H:i:s');

        if ($licence->licenceStartDate > $dateNow)
            throw $this->copyOps->getExceptionForId("errorLicenceHasntStartedYet");

        if ($licence->expiryDate < $dateNow) {
            // Write a record to the failure table
            $this->failLicenceSlot($user, $rootId, $productCode, $licence, null, $this->copyOps->getCodeForId("errorLicenceExpired"));

            throw $this->copyOps->getExceptionForId("errorLicenceExpired", array("expiryDate" => $licence->expiryDate));
        }

        // Then licence slot checking is based on licence type
        switch ($licence->licenceType) {
            case Title::LICENCE_TYPE_AA:
            case Title::LICENCE_TYPE_CT:
            case Title::LICENCE_TYPE_NETWORK:
                // TODO It is possible that a licence might have specific time limits to override these defaults
                $reconnectionWindow = LicenceCops::AA_RECONNECTION_WINDOW;
                $inactivityWindow = LicenceCops::AA_INACTIVITY_WINDOW;

                // Only check on learners. AA licence doesn't have teachers, but a CT licence will
                // No, I think we should control all concurrent users
                //if ($user->userType != User::USER_TYPE_STUDENT) {
                //   break;

                /*
                    From session id pick up user id, root id and product code.
                    Get the licence from root and product.
                    Read T_CouloirLicenceHolders to see if licence exists that is active (endDate is in the future).
                    If yes, return true.
                    Count T_CouloirLicenceHolders for this root and product (that are active).
                    If licence limit permits, insert to T_CouloirLicenceHolders and return true.
                 */
                $activeLicence = $this->checkCurrentLicence($productCode, $rootId, $sessionId, $userId, $licence);
                if ($activeLicence) {
                    $rc = $this->extendLicence($sessionId);
                    if ($rc) {
                        // Licence slot found, get out of this case.
                        break;
                    } else {
                        throw $this->copyOps->getExceptionForId("errorCantClearLicences");
                    }
                }

                // Count to see how many this account is currently using
                $usedLicences = $this->countCurrentLicences($productCode, $rootId);
                if ($usedLicences >= $licence->maxStudents) {
                    $this->failLicenceSlot($user, $rootId, $productCode, $licence, null, $this->copyOps->getCodeForId("errorConcurrentLicenceFull"));

                    throw $this->copyOps->getExceptionForId("errorConcurrentLicenceFull");
                }

                // There is a free licence, so grab it
                $this->grabLicenceSlot($productCode, $rootId, $sessionId, $userId, $licence);
                break;

            // Currently treated as tracking types.
            case Title::LICENCE_TYPE_SINGLE:
            case Title::LICENCE_TYPE_I:
            case Title::LICENCE_TYPE_LT:
            case Title::LICENCE_TYPE_TT:
                $reconnectionWindow = LicenceCops::LT_RECONNECTION_WINDOW;
                $inactivityWindow = LicenceCops::LT_INACTIVITY_WINDOW;

                // Only track learners
                if ($user->userType != User::USER_TYPE_STUDENT) {
                    break;

                } else {
                    // gh#1496 Clarity Tests never block you from signing in due to licence issues
                    if ($productCode == 63 || $productCode == 65) {
                        break;

                    } else {
                        /*
                            From session id pick up user id, root id and product code.
                            Get the licence from root and product.
                            Read T_CouloirLicenceHolders to see if licence exists that is active (started within last year).
                            If yes, then update the lastActivity time and return true.
                            Delete T_CouloirLicenceHolders for this root and product that are not active.
                            Count T_CouloirLicenceHolders for this root and product (that are active).
                            If licence limit permits, insert to T_CouloirLicenceHolders and return true.
                         */
                        $activeLicence = $this->checkCurrentLicence($productCode, $rootId, $sessionId, $userId, $licence);
                        if ($activeLicence) {
                            break;
                        }

                        // No, so is there a free one?
                        $usedLicences = $this->countUsedLicences($productCode, $rootId, $licence);
                        if ($usedLicences >= $licence->maxStudents) {
                            // You really can't get a space
                            // Write a record to the failure table
                            $this->failLicenceSlot($user, $rootId, $productCode, $licence, null, $this->copyOps->getCodeForId("errorTrackingLicenceFull"));
                            throw $this->copyOps->getExceptionForId("errorTrackingLicenceFull");
                        }
                    }
                    // There is a free licence, so grab it
                    $this->grabLicenceSlot($productCode, $rootId, $sessionId, $userId, $licence);
                }
                break;
            default:
                // Write a record to the failure table
                $this->failLicenceSlot($user, $rootId, $productCode, $licence, null, $this->copyOps->getCodeForId("errorInvalidLicenceType"));

                throw $this->copyOps->getExceptionForId("errorInvalidLicenceType");
        }
        return ["hasLicenseSlot" => true, "reconnectionWindow" => $reconnectionWindow, "inactivityWindow" => $inactivityWindow];
    }
    /**
     * Grab a licence slot
     * gh#1230
     */
    public function grabLicenceSlot($productCode, $rootId, $sessionId, $userId, $licence) {

        // The licence expiry date is very different for AA and LT.
        $dateStamp = AbstractService::getNow();
        $dateNow = $dateStamp->format('Y-m-d H:i:s');
        $expungeDateStamp = AbstractService::getNow();
        switch ($licence->licenceType) {
            case Title::LICENCE_TYPE_LT:
                $expungeDateStamp->modify('+'.$licence->licenceClearanceFrequency); // one licence period in the future
                $licenceEndDate = $expungeDateStamp->modify('-1 day')->format('Y-m-d 23:59:59'); // minus one day
                $keyId = $userId;
                break;
            case Title::LICENCE_TYPE_AA:
            case Title::LICENCE_TYPE_CT:
            case Title::LICENCE_TYPE_NETWORK:
            default:
                $keyId = $sessionId;
                // sss#161 Delete any existing licence for this session before you add a new one.
                // Just as a safety check. REALLY?
                $sql = <<<EOD
                    DELETE FROM T_CouloirLicenceHolders
                    WHERE F_ProductCode=?
                    AND F_RootID=?
                    AND F_KeyID=?
EOD;
                $bindingParams = array($productCode, $rootId, $keyId);
                $rs = $this->db->Execute($sql, $bindingParams);
                if (!$rs) {
                    throw $this->copyOps->getExceptionForId("errorCantClearLicences");
                }

                $licenceEndDate = $expungeDateStamp->modify('+'.(LicenceCops::AA_LICENCE_EXTENSION).' secs')->format('Y-m-d H:i:s');
                break;
        }
        $sql = <<<EOD
            INSERT INTO T_CouloirLicenceHolders (F_KeyID, F_RootID, F_ProductCode, F_StartDateStamp, F_EndDateStamp, F_LicenceType) VALUES
            ($keyId, $rootId, $productCode, '$dateNow', '$licenceEndDate', $licence->licenceType)
EOD;
        $rs = $this->db->Execute($sql);
        if (!$rs) {
            throw $this->copyOps->getExceptionForId("errorDatabaseWriting");
        }
        AbstractService::$debugLog->info("grabbedLicenceSlot for key=$keyId");
        return true;
    }

    /*
     * Is there an active licence for this session or user?
     */
    private function checkCurrentLicence($productCode, $rootId, $sessionId, $userId, $licence) {
        $dateStampNow = AbstractService::getNow();
        $dateStamp = $dateStampNow->format('Y-m-d H:i:s');
        // AA is keyed on sessionId, LT keyed on userId
        switch ($licence->licenceType) {
            case Title::LICENCE_TYPE_AA:
            case Title::LICENCE_TYPE_CT:
            case Title::LICENCE_TYPE_NETWORK:
                $keyId = $sessionId;
                // An AA licence stays active for 5 minutes if untouched
                //$dateStamp = $dateStampNow->modify('-' . (LicenceCops::LICENCE_DELAY * 60) . ' secs')->format('Y-m-d H:i:s');
                break;

            case Title::LICENCE_TYPE_SINGLE:
            case Title::LICENCE_TYPE_I:
            case Title::LICENCE_TYPE_LT:
            case Title::LICENCE_TYPE_TT:
                $keyId = $userId;
                // An LT licence is valid for a year (normally)
                // $dateStampNow->modify('+'.$licence->licenceClearanceFrequency); // one licence period in the future
                // $licenceEndDate = $dateStampNow->modify('-1 day')->format('Y-m-d 23:59:59');
                break;
        }
        $sql = <<<EOD
            SELECT * FROM T_CouloirLicenceHolders
        	WHERE F_KeyID=?
            AND F_ProductCode=?
            AND F_RootID=?
            AND F_EndDateStamp>?
EOD;
        $bindingParams = array($keyId, $productCode, $rootId, $dateStamp);
        $rs = $this->db->Execute($sql, $bindingParams);
        // If you got a few records back, it indicates something went wrong, but you DO still have a licence
        if ($rs && $rs->RecordCount() > 0) {
            //AbstractService::$debugLog->info("checkCurrentLicence success for key=$keyId > $dateStamp");
            return true;
        }
        //AbstractService::$debugLog->info("checkCurrentLicence fail for key=$keyId > $dateStamp");
        return false;
    }
    /**
     * Count how many licences are currently in use
     * Although this is designed to count AA licences, if the account was switched from LT to AA
     * the existing LT licences are going to stick around for a year and will be continually counted.
     * TODO should we count only by AA licence type? Or is this only a problem for testing accounts?
     */
    private function countCurrentLicences($productCode, $rootId) {
        $dateStampNow = AbstractService::getNow();
        //$dateStamp = $dateStampNow->modify('-1 day')->format('Y-m-d H:i:s');
        $dateStamp = $dateStampNow->format('Y-m-d H:i:s');
        $sql = <<<EOD
            SELECT COUNT(F_KeyID) as i FROM T_CouloirLicenceHolders
        	WHERE F_ProductCode=?
		    AND F_RootID=?
            AND F_EndDateStamp>?
            AND NOT F_LicenceType=?
EOD;
        $bindingParams = array($productCode, $rootId, $dateStamp, Title::LICENCE_TYPE_LT);
        $rs = $this->db->Execute($sql, $bindingParams);
        $count = $rs->FetchNextObj()->i;
        AbstractService::$debugLog->info("countCurrentLicence=$count");

        return $count;
    }

    /**
     *
     * Does this user already have a licence for this product?
     * Change to use T_Session for tracking licence use
     * @param User $user
     * @param Number $productCode
     * @param Licence $licence
     */
    function checkExistingOldStyleLicence($userId, $productCode, $licence) {
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
        $bindingParams = array($userId, $licence->licenceControlStartDate, $productCode);
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
                return $userId;
        }
    }

    /**
     *
     * Does this user already have a licence for this product?
     * Change to use T_Session for tracking licence use
     * gh#1230 Change to use T_CouloirLicenceHolders
     * @param User $user
     * @param Number $productCode
     * @param Licence $licence
     */
    function checkExistingLicence($userId, $productCode, $licence) {
        // gh#125 Need exactly the same conditions here as with countUsedLicences
        // Have they taken a licence within the last [licence period]?
        $dateStamp = AbstractService::getNow();
        $licencePeriodAgo = $dateStamp->modify('-'.$licence->licenceClearanceFrequency)->format('Y-m-d H:i:s');
        AbstractService::$debugLog->info("licences used since ".$licencePeriodAgo);
        $sql = <<<EOD
			SELECT * FROM T_CouloirLicenceHolders l
			WHERE l.F_KeyID = ?
			AND l.F_StartDateStamp > ?
EOD;

        // gh#1211 And the other old and new combinations
        $oldProductCode = $this->getOldProductCode($productCode);
        if ($oldProductCode) {
            $sql.= " AND l.F_ProductCode IN (?, $oldProductCode)";
        } else {
            $sql.= " AND l.F_ProductCode = ?";
        }
        $bindingParams = array($userId, $licencePeriodAgo, $productCode);
        $rs = $this->db->Execute($sql, $bindingParams);

        // SQL error
        if (!$rs)
            throw $this->copyOps->getExceptionForId("errorReadingLicenceControlTable");

        switch ($rs->RecordCount()) {
            case 0:
                return false;
                break;
            default:
                // Valid login, return the last licence ID
                return $rs->FetchNextObj()->F_LicenceID;
        }
    }

    /**
     * This function is a one-off to pick up the oldest session (within the last year) - which is the current way of counting licences.
     * Does this user have a current licence for this productCode?
     * Will be deprecated as soon as new licence style implemented.
     */
    function checkEarliestOldStyleLicence($userId, $productCode) {
        $aYearAgo = AbstractService::getNow();
        $aYearAgo->modify('-1 year');
        $earliestDate = $aYearAgo->format('Y-m-d');

        $sql = <<<EOD
            SELECT MIN(s.F_StartDateStamp) as earliestDate FROM T_Session s
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
        $bindingParams = array($userId, $earliestDate, $productCode);
        $rs = $this->db->Execute($sql, $bindingParams);

        // SQL error
        if (!$rs)
            throw $this->copyOps->getExceptionForId("errorReadingLicenceControlTable");

        if ($rs->RecordCount() > 0) {
            return $rs->FetchNextObj()->earliestDate;
        } else {
            return false;
        }
    }
    /**
     * This function is a one-off to pick up the oldest session (within the last year) - which is the current way of counting licences.
     * Returns one record for each user in a root
     * Will be deprecated as soon as new licence style implemented.
     */
    function checkEarliestOldStyleLicences($rootId, $productCode) {
        $aYearAgo = AbstractService::getNow();
        $aYearAgo->modify('-1 year');
        $earliestDate = $aYearAgo->format('Y-m-d');

        $sql = <<<EOD
            SELECT s.F_UserID as userId, MIN(s.F_StartDateStamp) as earliestDate FROM T_Session s
			WHERE s.F_RootID = ?
			AND s.F_StartDateStamp >= ?
			AND s.F_Duration > 15
            and s.F_UserID > 0
EOD;

        // gh#1211 And the other old and new combinations
        $oldProductCode = $this->getOldProductCode($productCode);
        if ($oldProductCode) {
            $sql.= " AND s.F_ProductCode IN (?, $oldProductCode)";
        } else {
            $sql.= " AND s.F_ProductCode = ?";
        }
        $sql.= " group by s.F_UserID";
        $bindingParams = array($rootId, $earliestDate, $productCode);
        $rs = $this->db->Execute($sql, $bindingParams);

        // SQL error
        if (!$rs)
            throw $this->copyOps->getExceptionForId("errorReadingLicenceControlTable");

        if ($rs->RecordCount() > 0) {
            return $rs;
        } else {
            return false;
        }
    }
    /**
     * This function is a one-off to see if any users in this account used this title
     * gh#1230 Used to avoid lengthy checks
     */
    function countTimesTitleUsed($rootId, $productCode) {
        $aYearAgo = AbstractService::getNow();
        $aYearAgo->modify('-1 year');
        $earliestDate = $aYearAgo->format('Y-m-d');

        $sql = <<<EOD
            SELECT COUNT(*) as sessions FROM T_Session s
			WHERE s.F_RootID = ?
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
        $bindingParams = array($rootId, $earliestDate, $productCode);
        $rs = $this->db->Execute($sql, $bindingParams);

        // SQL error
        if (!$rs)
            throw $this->copyOps->getExceptionForId("errorReadingLicenceControlTable");

        return $rs->FetchNextObj()->sessions;
    }

    /**
     * Count the number of used licences for this root / product since the clearance date
     */
    function countUsedLicences($productCode, $rootId, $licence) {
        // Transferable tracking needs to invoke the T_User table as well to ignore records from users that don't exist anymore.
        // v6.6.4 change to counting based on F_StartDateStamp to avoid problems in F_EndDateStamp
        // gh#1230 How many licences have been used since the licence clearance date?
        if ($licence->licenceType == Title::LICENCE_TYPE_TT) {
            $sql = <<<EOD
				SELECT COUNT(l.F_KeyID) AS licencesUsed 
				FROM T_CouloirLicenceHolders l, T_User u
				WHERE l.F_KeyID = u.F_UserID
				AND l.F_EndDateStamp >= ?
EOD;
        } else {
            // gh#604 Teacher records in session will now include root, so ignore them here
            // gh#1228 But that ignores deleted/archived users, so revert
            $sql = <<<EOD
				SELECT COUNT(l.F_KeyID) AS licencesUsed 
				FROM T_CouloirLicenceHolders l
				WHERE l.F_EndDateStamp >= ?
EOD;
        }

        // gh#1211 And the other old and new combinations
        $oldProductCode = $this->getOldProductCode($productCode);
        if ($oldProductCode) {
            $sql.= " AND l.F_ProductCode IN (?, $oldProductCode)";
        } else {
            $sql.= " AND l.F_ProductCode = ?";
        }

        if (stristr($rootId,',')!==FALSE) {
            $sql.= " AND l.F_RootID in ($rootId)";
        } else if ($rootId=='*') {
            // check all roots in that case - just for special cases, usually self-hosting
            // Note that leaving the root empty would include teachers
            $sql.= " AND l.F_RootID > 0";
        } else {
            $sql.= " AND l.F_RootID = $rootId";
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
     * This is a count of all the people who can currently access the title.
     * It is probably more than licences used as it includes people who started in the previous licence period
     * but haven't been cleared out yet.
     */
    function countTotalLicences($rootID, $productCode, $licence) {
        $aYearAgo = AbstractService::getNow();
        $aYearAgo->modify('-1 year');
        $earliestDate = $aYearAgo->format('Y-m-d');

        if ($licence->licenceType == Title::LICENCE_TYPE_TT) {
            $sql = <<<EOD
				SELECT COUNT(l.F_KeyID) AS licencesUsed 
				FROM T_CouloirLicenceHolders l, T_User u
				WHERE l.F_KeyID = u.F_UserID
				AND l.F_StartDateStamp >= ?
EOD;
        } else {
            // gh#604 Teacher records in session will now include root, so ignore them here
            // gh#1228 But that ignores deleted/archived users, so revert
            $sql = <<<EOD
				SELECT COUNT(l.F_KeyID) AS licencesUsed 
				FROM T_CouloirLicenceHolders l
				WHERE l.F_StartDateStamp >= ?
EOD;
        }

        // gh#1211 And the other old and new combinations
        $oldProductCode = $this->getOldProductCode($productCode);
        if ($oldProductCode) {
            $sql.= " AND l.F_ProductCode IN (?, $oldProductCode)";
        } else {
            $sql.= " AND l.F_ProductCode = ?";
        }

        if (stristr($rootID,',')!==FALSE) {
            $sql.= " AND l.F_RootID in ($rootID)";
        } else if ($rootID=='*') {
            // check all roots in that case - just for special cases, usually self-hosting
            // Note that leaving the root empty would include teachers
            $sql.= " AND l.F_RootID > 0";
        } else {
            $sql.= " AND l.F_RootID = $rootID";
        }
        $bindingParams = array($earliestDate, $productCode);
        $rs = $this->db->Execute($sql, $bindingParams);

        if ($rs && $rs->RecordCount() > 0) {
            $licencesUsed = (int)$rs->FetchNextObj()->licencesUsed;
        } else {
            throw $this->copyOps->getExceptionForId("errorReadingLicenceControlTable");
        }

        return $licencesUsed;
    }

    /**
     * Count the number of used licences for this root / product since the clearance date
     */
    function countUsedOldStyleLicences($rootID, $productCode, $licence) {
        // Transferable tracking needs to invoke the T_User table as well to ignore records from users that don't exist anymore.
        // v6.6.4 change to counting based on F_StartDateStamp to avoid problems in F_EndDateStamp
        if ($licence->licenceType == Title::LICENCE_TYPE_TT) {
            $sql = <<<EOD
            SELECT COUNT(DISTINCT(s.F_UserID)) AS licencesUsed 
            FROM T_Session s, T_User u
            WHERE s.F_UserID = u.F_UserID
            AND s.F_StartDateStamp >= ?
            AND s.F_Duration > 15
            AND s.F_UserID > 0
EOD;
        } else {
            // gh#604 Teacher records in session will now include root, so ignore them here
            // gh#1228 But that ignores deleted/archived users, so revert
            $sql = <<<EOD
            SELECT COUNT(DISTINCT(s.F_UserID)) AS licencesUsed 
            FROM T_Session s
            WHERE s.F_StartDateStamp >= ?
            AND s.F_Duration > 15
            AND s.F_UserID > 0
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
     *
     * This function extends a licence record with a timestamp
     * It is only relevant for AA licences that constantly check the date
     */
    // gh#1342
    function extendLicence($sessionId, $timestamp=null) {
        $extendBy = LicenceCops::AA_LICENCE_EXTENSION;

        // gh#815 sss#161 You might be updating based on an activity message from a little while ago that just arrived
        $dateStampNow = is_null($timestamp) ? AbstractService::getNow() : new DateTime('@'.intval($timestamp), new DateTimeZone(TIMEZONE));
        // Set an extra x seconds on the licence
        $dateNow = $dateStampNow->add(new DateInterval('PT'.$extendBy.'S'))->format('Y-m-d H:i:s');

        // sss#161 Check first that this IS an AA licence
        // TODO I think this is unnecessary, we won't call it for LT
        /*
        $sql = <<<EOD
			SELECT * FROM T_CouloirLicenceHolders 
			WHERE F_KeyID=?
            AND F_LicenceType=?
EOD;
        $bindingParams = array($sessionId, Title::LICENCE_TYPE_AA);
        $rs = $this->db->Execute($sql, $bindingParams);
        if (!$rs || $rs->recordCount()==0)
            return;
        */
        // Update the licence in the table
        // gh#1342
        $sql = <<<EOD
			UPDATE T_CouloirLicenceHolders 
			SET F_EndDateStamp=?
			WHERE F_KeyID=?
EOD;
        $bindingParams = array($dateNow, $sessionId);
        $rs = $this->db->Execute($sql, $bindingParams);
        if (!$rs)
            throw $this->copyOps->getExceptionForId("errorCantUpdateLicence", array("licenceID" => $sessionId));
        return true;
    }

    function releaseCouloirLicenceSlot($session, $timestamp) {
        $sessionId = $session->sessionId;
        $userId = $session->userId;
        $rootId = $session->rootId;
        $productCode = $session->productCode;
        $licence = $this->accountCops->getLicenceDetails($rootId, $productCode);
        return $this->dropLicenceSlot($productCode, $rootId, $sessionId, $userId, $licence, $timestamp);
    }
    /**
     * Drop a licence slot - this clears the record from the licence table
     * and closes the session tracking.
     * gh#1230
     */
    public function dropLicenceSlot($productCode, $rootId, $sessionId, $userId, $licence, $timestamp) {

        switch ($licence->licenceType) {
            case Title::LICENCE_TYPE_AA:
            case Title::LICENCE_TYPE_CT:
            case Title::LICENCE_TYPE_NETWORK:
                $keyId = $sessionId;
                break;
            case Title::LICENCE_TYPE_LT:
                // You can't release an LT licence slot
                return true;
                break;
        }
        $sql = <<<EOD
            DELETE FROM T_CouloirLicenceHolders
            WHERE F_KeyID=?
            AND F_RootID=?
            AND F_ProductCode=?
EOD;
        $bindingParams = array($keyId, $rootId, $productCode);
        $rs = $this->db->Execute($sql, $bindingParams);
        if (!$rs) {
            throw $this->copyOps->getExceptionForId("errorDatabaseWriting");
        }
        return true;
    }

    public function deleteExpiredLicenceSlots($session) {
        $sessionId = $session->sessionId;
        $rootId = $session->rootId;
        $productCode = $session->productCode;
        $dateStampNow = AbstractService::getNow();
        $dateNow = $dateStampNow->format('Y-m-d H:i:s');
        $sql = <<<EOD
            DELETE FROM T_CouloirLicenceHolders
            WHERE F_ProductCode=?
            AND F_RootID=?
            AND (F_EndDateStamp<? OR F_EndDateStamp IS NULL)
EOD;
        $bindingParams = array($productCode, $rootId, $dateNow);
        $this->db->Execute($sql, $bindingParams);
    }

    /**
     * Record the failure to get a licence or otherwise start the program
     */
    function failLicenceSlot($user, $rootID, $productCode, $licence, $ip = '', $reasonCode) {

        if (!$ip)
            $ip = $_SERVER['REMOTE_ADDR'];

        if ($reasonCode == null || $reasonCode == '')
            $reasonCode = 0;

        $dateStampNow = AbstractService::getNow();
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

        // gh#1230
        $account = $this->accountCops->getBentoAccount($rootID, $productCode);
        if ($account->useOldLicenceCount) {
            $count = $this->countUsedOldStyleLicences($rootID, $productCode, $licence);
        } else {
            $count = $this->countUsedLicences($rootID, $productCode, $licence);
        }
        return $count;
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