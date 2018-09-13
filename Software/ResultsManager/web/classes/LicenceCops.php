<?php
/*
 * A couloir version of Bento's LicenceOps
 * Implements sss#61, sss#82
 */

class LicenceCops
{

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
            case Title::LICENCE_TYPE_TOKEN:
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
                    $this->extendLicence($sessionId, $licence->licenceType);
                } else {
                    return ["hasLicenseSlot" => false];
                }
                break;

        }
        // sss#192 Check the instance id - does it still match the sign in one?
        //if ($userId > 0) {
        //    $instanceId = $this->loginCops->getInstanceId($userId, $productCode);
        //    if ($sessionId != $instanceId) {
        //        return ["hasLicenseSlot" => false];
        //    }
        //}

        return ["hasLicenseSlot" => true, "reconnectionWindow" => $reconnectionWindow, "inactivityWindow" => $inactivityWindow];
    }

    // m#404 This is the only way to get a licence to run a token title.
    // If there is a licence available you will be allocated one
    public function allocateTokenLicenceSlot($session, $licence, $token) {

        $sessionId = $session->sessionId;
        $userId = $session->userId;
        $rootId = $session->rootId;
        $productCode = $session->productCode;
        $user = $this->manageableOps->getUserByIdNotAuthenticated($userId);

        $dateStampNow = AbstractService::getNow();
        $dateNow = $dateStampNow->format('Y-m-d H:i:s');
        if ($licence->licenceStartDate > $dateNow)
            throw $this->copyOps->getExceptionForId("errorLicenceHasntStartedYet");

        if ($licence->expiryDate < $dateNow) {
            // Write a record to the failure table
            $this->failLicenceSlot($user, $rootId, $productCode, $licence, null, $this->copyOps->getCodeForId("errorLicenceExpired"));

            throw $this->copyOps->getExceptionForId("errorLicenceExpired", array("expiryDate" => $licence->expiryDate));
        }

        // Do you already have a licence, in which case extend it by duration
        // TODO this should actually be getCurrentLicence so that we can then find the end date and add duration to that
        // BUG Currently this adds token duration to today, which is quite quite wrong
        $activeLicence = $this->checkCurrentLicence($productCode, $rootId, $sessionId, $userId, $licence);
        if ($activeLicence) {
            $this->extendLicence($userId, $licence->licenceType, $token->duration);

        } else {
            $usedLicences = $this->countCurrentLicences($productCode, $rootId, $licence->licenceType);
            if ($usedLicences >= $licence->maxStudents) {
                $this->failLicenceSlot($user, $rootId, $productCode, $licence, null, $this->copyOps->getCodeForId("errorTrackingLicenceFull"));

                throw $this->copyOps->getExceptionForId("errorTrackingLicenceFull");
            }

            // There is a free licence, so grab it
            $this->grabLicenceSlot($productCode, $rootId, $sessionId, $userId, $licence, $token->duration);

        }
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
    function acquireCouloirLicenceSlot($session, $licence) {

        // For AA licences, userId will be a generic -1 - or the anonymous user for an account
        $sessionId = $session->sessionId;
        $userId = $session->userId;
        $rootId = $session->rootId;
        $productCode = $session->productCode;
        $user = $this->manageableOps->getUserByIdNotAuthenticated($userId);

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
            // m#404 You can only use a token title if you already have a licence to it.
            case  Title::LICENCE_TYPE_TOKEN:
                $reconnectionWindow = LicenceCops::LT_RECONNECTION_WINDOW;
                $inactivityWindow = LicenceCops::LT_INACTIVITY_WINDOW;
                $activeLicence = $this->checkCurrentLicence($productCode, $rootId, $sessionId, $userId, $licence);
                if (!$activeLicence)
                    throw $this->copyOps->getExceptionForId("errorNoProductCodeInRoot", array('productCode' => $productCode, 'rootID' => $rootId));
                break;

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
                    $rc = $this->extendLicence($sessionId, $licence->licenceType);
                    if ($rc) {
                        // Licence slot found, get out of this case.
                        break;
                    } else {
                        throw $this->copyOps->getExceptionForId("errorCantClearLicences");
                    }
                }

                // Count to see how many this account is currently using
                // gh#1577 pass licence type
                $usedLicences = $this->countCurrentLicences($productCode, $rootId, $licence->licenceType);
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
    public function grabLicenceSlot($productCode, $rootId, $sessionId, $userId, $licence, $duration=null) {

        // The licence expiry date is very different for AA and LT.
        $dateStamp = AbstractService::getNow();
        $dateNow = $dateStamp->format('Y-m-d H:i:s');
        $expungeDateStamp = AbstractService::getNow();
        // gh#1577 switch the order to mirror other calls, and add _I and _SINGLE
        switch ($licence->licenceType) {
            case Title::LICENCE_TYPE_AA:
            case Title::LICENCE_TYPE_CT:
            case Title::LICENCE_TYPE_NETWORK:
                $keyId = $sessionId;
                // sss#161 Delete any existing licence for this session before you add a new one.
                // Just as a safety check. REALLY?
                /* m#493
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
                */
                // The licence will end in 2 minutes
                $licenceEndDate = $expungeDateStamp->modify('+' . (LicenceCops::AA_LICENCE_EXTENSION) . ' secs')->format('Y-m-d H:i:s');
                break;

            case Title::LICENCE_TYPE_SINGLE:
            case Title::LICENCE_TYPE_I:
            case Title::LICENCE_TYPE_LT:
            case Title::LICENCE_TYPE_TT:
                $keyId = $userId;
                // The licence will end 1 day less than a year (or other licence clearance frequency)
                $expungeDateStamp->modify('+' . $licence->licenceClearanceFrequency); // one licence period in the future
                $licenceEndDate = $expungeDateStamp->modify('-1 day')->format('Y-m-d 23:59:59'); // minus one day
                break;

            case Title::LICENCE_TYPE_TOKEN:
                $keyId = $userId;
                // The licence will end based on now + duration in the token
                $expungeDateStamp->modify('+' . $duration . ' days'); // x days in the future
                $licenceEndDate = $expungeDateStamp->format('Y-m-d 23:59:59');
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
        //$licenceId = $this->db->Insert_ID();
        //AbstractService::$debugLog->info("grab new licence ($licenceId) for key=$keyId in pc=$productCode");
        return true;
    }

    // m#404 Detect if a user has a licence for a title
    public function getUserCouloirLicence($productCode, $userId) {
        $dateStampNow = AbstractService::getNow();
        $dateStamp = $dateStampNow->format('Y-m-d H:i:s');
        $sql = <<<EOD
            SELECT * FROM T_CouloirLicenceHolders
        	WHERE F_KeyID=?
            AND F_ProductCode=?
            AND F_EndDateStamp>?
EOD;
        $bindingParams = array($userId, $productCode, $dateStamp);
        $rs = $this->db->Execute($sql, $bindingParams);
        // If you got a few records back, it indicates something went wrong, but you DO still have a licence
        if ($rs && $rs->RecordCount() > 0) {
            return true;
        }
        return false;
    }

    // m#404 Bento programs can use old or new licence forms
    public function getUserOldLicence($productCode, $userId, $useOrchidLicence, $licence) {
        if ($useOrchidLicence) {
            $licenceID = $this->checkOrchidLicence($productCode, $userId, $licence);
        } else {
            $licenceID = $this->checkBentoLicence($productCode, $userId, $productCode);
        }
        return $licenceID;
    }

    public function countUsedOldLicences($productCode, $rootId, $useOrchidLicence, $licence) {
        if ($useOrchidLicence) {
            $count = $this->countOrchidLicences($productCode, $rootId, $licence);
        } else {
            $count = $this->countBentoLicences($productCode, $rootId, $licence);
        }
        return $count;
    }

    public function countBentoLicences($productCode, $rootId, $licence) {
        // Transferable tracking needs to invoke the T_User table as well to ignore records from users that don't exist anymore.
        // v6.6.4 change to counting based on F_StartDateStamp to avoid problems in F_EndDateStamp
        // gh#1230 How many licences have been used since the licence clearance date?
        if ($licence->licenceType == Title::LICENCE_TYPE_TT) {
            // m#175 Add a distinct filter in case the licence table includes duplicates
            $sql = <<<EOD
				SELECT COUNT(DISTINCT(l.F_UserID)) AS licencesUsed 
				FROM T_LicenceHolders l, T_User u
				WHERE l.F_UserID = u.F_UserID
				AND l.F_StartDateStamp >= ?
                AND l.F_ProductCode = ?
                AND l.F_RootID = ?
EOD;
        } else {
            // gh#604 Teacher records in session will now include root, so ignore them here
            // gh#1228 But that ignores deleted/archived users, so revert
            // m#175 Add a distinct filter in case the licence table includes duplicates
            $sql = <<<EOD
				SELECT COUNT(DISTINCT(l.F_UserID)) AS licencesUsed 
				FROM T_LicenceHolders l
				WHERE l.F_StartDateStamp >= ?
                AND l.F_ProductCode = ?
                AND l.F_RootID = ?
EOD;
        }

        $bindingParams = array($licence->licenceControlStartDate, $productCode, $rootId);
        $rs = $this->db->Execute($sql, $bindingParams);

        if ($rs && $rs->RecordCount() > 0) {
            $licencesUsed = (int)$rs->FetchNextObj()->licencesUsed;
        } else {
            throw $this->copyOps->getExceptionForId("errorReadingLicenceControlTable");
        }

        return $licencesUsed;
    }

    // Copied from LicenceOps
    public function countOrchidLicences($productCode, $rootId, $licence) {
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
            AND s.F_ProductCode = ?
            AND s.F_RootID = ?
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
            AND s.F_ProductCode = ?
            AND s.F_RootID = ?
EOD;
        }
        $bindingParams = array($licence->licenceControlStartDate, $productCode, $rootId);
        $rs = $this->db->Execute($sql, $bindingParams);

        if ($rs && $rs->RecordCount() > 0) {
            $licencesUsed = (int)$rs->FetchNextObj()->licencesUsed;
        } else {
            throw $this->copyOps->getExceptionForId("errorReadingLicenceControlTable");
        }

        return $licencesUsed;
    }

    // Copied from LicenceOps so that this class can check up on old licences
    public function checkOrchidLicence($productCode, $userId, $licence) {
        $sql = <<<EOD
        SELECT * FROM T_Session s
        WHERE s.F_UserID = ?
        AND s.F_StartDateStamp >= ?
        AND s.F_Duration > 15
        AND s.F_ProductCode = ?
EOD;

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
                return true;
        }
    }

    public function checkBentoLicence($productCode, $userId) {
        $dateStamp = AbstractService::getNow();
        $dateNow = $dateStamp->format('Y-m-d H:i:s');
        $sql = <<<EOD
			SELECT * FROM T_LicenceHolders l
			WHERE l.F_UserID = ?
			AND l.F_EndDateStamp > ?
            AND l.F_ProductCode = ?
EOD;

        $bindingParams = array($userId, $dateNow, $productCode);
        $rs = $this->db->Execute($sql, $bindingParams);

        // SQL error
        if (!$rs)
            throw $this->copyOps->getExceptionForId("errorReadingLicenceControlTable");

        switch ($rs->RecordCount()) {
            case 0:
                return false;
                break;
            default:
                return true;
        }
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
            case Title::LICENCE_TYPE_TOKEN:
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
            AND F_LicenceType=?
EOD;
        $bindingParams = array($keyId, $productCode, $rootId, $dateStamp, $licence->licenceType);
        $rs = $this->db->Execute($sql, $bindingParams);
        // If you got a few records back, it indicates something went wrong, but you DO still have a licence
        if ($rs && $rs->RecordCount() > 0) {
            //$licenceId = $rs->FetchNextObj()->F_LicenceID;
            //AbstractService::$debugLog->info("got current licence ($licenceId) for key=$keyId in pc=$productCode (since $dateStamp)");
            return true;
        }
        //AbstractService::$debugLog->info("checkCurrentLicence fail for key=$keyId > $dateStamp");
        //AbstractService::$debugLog->info("No existing licence for $keyId in pc=$productCode (since $dateStamp)");

        return false;
    }

    /**
     * Count how many licences are currently in use
     * Although this is designed to count AA licences, if the account was switched from LT to AA
     * the existing LT licences are going to stick around for a year and will be continually counted.
     */
    private function countCurrentLicences($productCode, $rootId, $licenceType) {
        $dateStampNow = AbstractService::getNow();
        //$dateStamp = $dateStampNow->modify('-1 day')->format('Y-m-d H:i:s');
        $dateStamp = $dateStampNow->format('Y-m-d H:i:s');
        $sql = <<<EOD
            SELECT COUNT(F_KeyID) as i FROM T_CouloirLicenceHolders
        	WHERE F_ProductCode=?
		    AND F_RootID=?
            AND F_EndDateStamp>?
            AND F_LicenceType=?
EOD;
        $bindingParams = array($productCode, $rootId, $dateStamp, $licenceType);
        $rs = $this->db->Execute($sql, $bindingParams);
        $count = $rs->FetchNextObj()->i;
        //AbstractService::$debugLog->info("countCurrentLicence=$count");

        return $count;
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
            $sql .= " AND s.F_ProductCode IN (?, $oldProductCode)";
        } else {
            $sql .= " AND s.F_ProductCode = ?";
        }
        $bindingParams = array($rootId, $earliestDate, $productCode);
        $rs = $this->db->Execute($sql, $bindingParams);

        // SQL error
        if (!$rs)
            throw $this->copyOps->getExceptionForId("errorReadingLicenceControlTable");

        return $rs->FetchNextObj()->sessions;
    }

    /**
     * Count the number of used (tracking) licences for this root / product since the clearance date
     */
    public function countUsedLicences($productCode, $rootId, $licence) {
        // Transferable tracking needs to invoke the T_User table as well to ignore records from users that don't exist anymore.
        // v6.6.4 change to counting based on F_StartDateStamp to avoid problems in F_EndDateStamp
        // gh#1230 How many licences have been used since the licence clearance date?
        if ($licence->licenceType == Title::LICENCE_TYPE_TT) {
            $sql = <<<EOD
				SELECT COUNT(l.F_KeyID) AS licencesUsed 
				FROM T_CouloirLicenceHolders l, T_User u
				WHERE l.F_KeyID = u.F_UserID
				AND l.F_StartDateStamp >= ?
                AND l.F_LicenceType = ?
EOD;
        } else {
            // gh#604 Teacher records in session will now include root, so ignore them here
            // gh#1228 But that ignores deleted/archived users, so revert
            $sql = <<<EOD
				SELECT COUNT(l.F_KeyID) AS licencesUsed 
				FROM T_CouloirLicenceHolders l
				WHERE l.F_StartDateStamp >= ?
                AND l.F_LicenceType = ?
EOD;
        }

        // gh#1211 And the other old and new combinations
        $oldProductCode = $this->getOldProductCode($productCode);
        if ($oldProductCode) {
            $sql .= " AND l.F_ProductCode IN (?, $oldProductCode)";
        } else {
            $sql .= " AND l.F_ProductCode = ?";
        }

        if (stristr($rootId, ',') !== FALSE) {
            $sql .= " AND l.F_RootID in ($rootId)";
        } else if ($rootId == '*') {
            // check all roots in that case - just for special cases, usually self-hosting
            // Note that leaving the root empty would include teachers
            $sql .= " AND l.F_RootID > 0";
        } else {
            $sql .= " AND l.F_RootID = $rootId";
        }
        $bindingParams = array($licence->licenceControlStartDate, $licence->licenceType, $productCode);
        $rs = $this->db->Execute($sql, $bindingParams);

        if ($rs && $rs->RecordCount() > 0) {
            $licencesUsed = (int)$rs->FetchNextObj()->licencesUsed;
        } else {
            throw $this->copyOps->getExceptionForId("errorReadingLicenceControlTable");
        }
        //AbstractService::$debugLog->info("count used licences=$licencesUsed");
        return $licencesUsed;
    }

    /**
     * This is a count of all the people who can currently access the title.
     * It is probably more than licences used as it includes people who started in the previous licence period
     * but haven't been cleared out yet.
     * gh#1577 Simply count all licences in table as expired ones are removed daily
     */
    function countTotalLicences($rootID, $productCode, $licence) {
        if ($licence->licenceType == Title::LICENCE_TYPE_TT) {
            $sql = <<<EOD
				SELECT COUNT(l.F_KeyID) AS licencesUsed 
				FROM T_CouloirLicenceHolders l, T_User u
				WHERE l.F_KeyID = u.F_UserID
EOD;
        } else {
            // gh#604 Teacher records in session will now include root, so ignore them here
            // gh#1228 But that ignores deleted/archived users, so revert
            // Add an unnecessary condition just to get WHERE and AND correct
            $sql = <<<EOD
				SELECT COUNT(l.F_KeyID) AS licencesUsed 
				FROM T_CouloirLicenceHolders l
				WHERE l.F_KeyID >= 0
EOD;
        }

        // gh#1211 And the other old and new combinations
        $oldProductCode = $this->getOldProductCode($productCode);
        if ($oldProductCode) {
            $sql .= " AND l.F_ProductCode IN (?, $oldProductCode)";
        } else {
            $sql .= " AND l.F_ProductCode = ?";
        }

        if (stristr($rootID, ',') !== FALSE) {
            $sql .= " AND l.F_RootID in ($rootID)";
        } else if ($rootID == '*') {
            // check all roots in that case - just for special cases, usually self-hosting
            // Note that leaving the root empty would include teachers
            $sql .= " AND l.F_RootID > 0";
        } else {
            $sql .= " AND l.F_RootID = $rootID";
        }
        $bindingParams = array($productCode);
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
     * m#404 Or for token licences that get extra days added to them
     */
    // gh#1342
    function extendLicence($keyId, $licenceType, $duration = null) {
        $dateStampNow = AbstractService::getNow();
        if ($licenceType == Title::LICENCE_TYPE_TOKEN) {
            $endDate = $dateStampNow->add(new DateInterval('P' . $duration . 'D'))->format('Y-m-d H:i:s');

        } else {
            $extendBy = LicenceCops::AA_LICENCE_EXTENSION;
            $endDate = $dateStampNow->add(new DateInterval('PT' . $extendBy . 'S'))->format('Y-m-d H:i:s');
        }
        // Update the licence in the table
        // gh#1342
        $sql = <<<EOD
			UPDATE T_CouloirLicenceHolders 
			SET F_EndDateStamp=?
			WHERE F_KeyID=?
EOD;
        $bindingParams = array($endDate, $keyId);
        $rs = $this->db->Execute($sql, $bindingParams);
        if (!$rs)
            throw $this->copyOps->getExceptionForId("errorCantUpdateLicence", array("licenceID" => $keyId));
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
                $dateStampNow = is_null($timestamp) ? AbstractService::getNow() : new DateTime('@'.intval($timestamp), new DateTimeZone(TIMEZONE));
                $dateNow = $dateStampNow->format('Y-m-d H:i:s');
                break;
            case Title::LICENCE_TYPE_LT:
            case Title::LICENCE_TYPE_TT:
            case Title::LICENCE_TYPE_I:
            case Title::LICENCE_TYPE_SINGLE:
            case Title::LICENCE_TYPE_TOKEN:
                // You can't release an LT licence slot
                return true;
                break;
        }
        // m#493 Update the expiry date rather than delete the record
        $sql = <<<EOD
            UPDATE T_CouloirLicenceHolders
            SET F_EndDateStamp=?
            WHERE F_KeyID=?
            AND F_RootID=?
            AND F_ProductCode=?
EOD;
        $bindingParams = array($dateNow, $keyId, $rootId, $productCode);
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
        $bindingParams = array($ip, $dateNow, $rootID, $user->userID, $productCode, $reasonCode);
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
        //$account = $this->accountCops->getBentoAccount($rootID, $productCode);
        $count = $this->countUsedLicences($rootID, $productCode, $licence);
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
        if (stristr($title->licenceClearanceFrequency, '-') !== FALSE)
            $title->licenceClearanceFrequency = str_replace('-', '', $title->licenceClearanceFrequency);
        // Check that the frequency is valid
        if (!strtotime($title->licenceClearanceFrequency, $fromDateStamp) > 0)
            $title->licenceClearanceFrequency = '1 year';

        // Just in case we still have invalid data
        //NetDebug::trace("fromDateStamp=".$fromDateStamp.' which is '.strftime('%Y-%m-%d 00:00:00',$fromDateStamp));
        $safetyCount = 0;
        while ($safetyCount < 99 && strtotime($title->licenceClearanceFrequency, $fromDateStamp) < time()) {
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
            case 57:
                return 39;
                break;
            case 62:
                return 10;
                break;
            case 66:
                return 49;
                break;
            case 68:
                return 55;
                break;
            case 69:
                return 56;
                break;
            case 70:
                return 61;
                break;
            case 72:
                return 52;
                break;
            case 73:
                return 53;
                break;
            case 74:
                return 61;
                break;
        }
        return false;
    }

    /**
     * Read every session for this title in this root.
     * For each user go through the sessions.
     * Add the first as a licence record. Skip to a year later and add the next as a licence record. Loop.
     * TODO if this is a big account, it might be better to first get all unique users, then get each of their records one by one.
     * It would be a lot slower, but might avoid eating too much memory?
     */
    public function convertSessionsIntoCouloirLicences($rootId, $oldProductCode, $newProductCode, $licence) {
        $sql = <<<EOD
            SELECT s.F_UserID as userId, s.F_StartDateStamp as sessionDate FROM T_Session s
			WHERE s.F_RootID = ?
			AND s.F_Duration > 15
            AND s.F_UserID > 0
            AND s.F_ProductCode = ?
            order by s.F_UserID, s.F_StartDateStamp asc
EOD;
        $bindingParams = array($rootId, $oldProductCode);
        $rs = $this->db->Execute($sql, $bindingParams);

        if ($rs->RecordCount() <= 0)
            return array();

        // Go through these records for each user
        $lastUser = $blockedUser = $licenceCount = 0;
        $licenceEndDate = new DateTime();
        $blockedUsers = array();
        while ($r = $rs->FetchNextObj()) {
            $thisUser = $r->userId;
            if ($thisUser != $lastUser) {
                // This is the first record for this user
                $lastUser = $thisUser;

                // First check that there are no records for this user in couloir licence holders
                $licences = $this->existCouloirLicences($thisUser, $newProductCode);
                if ($licences) {
                    $blockedUsers[] = $blockedUser = $thisUser;
                    continue;
                }
                $licenceStartDate = $r->sessionDate;
                $startDate = DateTime::createFromFormat('Y-m-d H:i:s', $licenceStartDate);
                $startDate->add(DateInterval::createFromDateString($licence->licenceClearanceFrequency))->format('Y-m-d');
                $licenceEndDate = $startDate->sub(DateInterval::createFromDateString('1 day'))->format('Y-m-d 23:59:59');
                $this->addCouloirLicence($thisUser, $rootId, $newProductCode, $licenceStartDate, $licenceEndDate, $licence);
                $licenceCount++;
            } else {
                if ($thisUser == $blockedUser)
                    continue;

                // This is another record for the same user, is it more than a year after the first?
                if ($r->sessionDate > $licenceEndDate) {
                    // Yes it is, so write another licence record
                    $licenceStartDate = $r->sessionDate;
                    $startDate = DateTime::createFromFormat('Y-m-d H:i:s', $licenceStartDate);
                    $startDate->add(DateInterval::createFromDateString($licence->licenceClearanceFrequency))->format('Y-m-d');
                    $licenceEndDate = $startDate->sub(DateInterval::createFromDateString('1 day'))->format('Y-m-d 23:59:59');
                    $this->addCouloirLicence($thisUser, $rootId, $newProductCode, $licenceStartDate, $licenceEndDate, $licence);
                    $licenceCount++;
                }
            }
        }
        return array('licencesAdded' => $licenceCount, 'productCode' => $newProductCode, 'rootId' => $rootId, 'blockedUsers' => $blockedUsers);
    }
    private function addCouloirLicence ($thisUser, $rootId, $productCode, $licenceStartDate, $licenceEndDate, $licence) {
        $sql = <<<EOD
        INSERT INTO T_CouloirLicenceHolders (F_KeyID, F_RootID, F_ProductCode, F_StartDateStamp, F_EndDateStamp, F_LicenceType) VALUES
        ($thisUser, $rootId, $productCode, '$licenceStartDate', '$licenceEndDate', $licence->licenceType)
EOD;
        $rs = $this->db->Execute($sql);
        if (!$rs)
            throw $this->copyOps->getExceptionForId("errorDatabaseWriting");
    }

    private function existCouloirLicences($userId, $productCode) {
        $sql = <<<EOD
            SELECT * FROM T_CouloirLicenceHolders l
			WHERE l.F_KeyID = ?
            AND l.F_ProductCode = ?
EOD;
        $bindingParams = array($userId, $productCode);
        $rs = $this->db->Execute($sql, $bindingParams);

        return ($rs->RecordCount() > 0);
    }

}