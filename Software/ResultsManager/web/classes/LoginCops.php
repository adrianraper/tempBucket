<?php
/*
 * A couloir version of Bento's LoginOps
 * Implements sss#61, sss#82
 */

class LoginCops {
	
	var $db;
	
	function LoginCops($db) {
		$this->db = $db;
		
		$this->copyOps = new CopyOps();
		$this->manageableOps = new ManageableOps($db);
		$this->accountCops = new AccountCops($db);
	}
	
	/**
	 * If you changed the db, you'll need to refresh it here
	 * Not a very neat function...
	 */
	function changeDB($db) {
		$this->db = $db;
		$this->accountCops->changeDB($db);
		$this->manageableOps->changeDB($db);
	}

	/*
	 * Login does the following:
	 *  Check that the user is valid
	 */
	function loginCouloir($login, $password, $loginOption, $verified, $userTypes, $rootID, $productCode) {
		// Pull out the relevant login details from the passed object
		// loginOption controls what fields you use to login with.
		if ($loginOption & User::LOGIN_BY_NAME || $loginOption & User::LOGIN_BY_NAME_AND_ID) {
			$loginKeyField = $this->copyOps->getCopyForId("nameKeyfield");
            $key = 'u.F_UserName';
		} elseif ($loginOption & User::LOGIN_BY_ID) {
			$loginKeyField = $this->copyOps->getCopyForId("IDKeyfield");
    		$key = 'u.F_StudentID';
		} elseif ($loginOption & User::LOGIN_BY_EMAIL) {
			$loginKeyField = $this->copyOps->getCopyForId("emailKeyfield");
			$key = 'u.F_Email';
		} else {
			throw $this->copyOps->getExceptionForId("errorInvalidLoginOption", array("loginOption" => $loginOption));
		}
        if (isset($login) && $login != '') {
            $keyValue = $login;
        } else {
            throw $this->copyOps->getExceptionForId("errorLoginKeyEmpty", array("loginOption" => $loginOption, "loginKeyField" => $loginKeyField));
        }

		// #503
		$selectFields = array("g.F_GroupID as groupID",
							  "m.F_RootID as rootID",
							  "u.*");
		$sql  = "SELECT ".join(",", $selectFields);
		$sql .=	<<<EOD
				FROM T_User u LEFT JOIN 
				T_Membership m ON m.F_UserID = u.F_UserID LEFT JOIN
				T_Groupstructure g ON m.F_GroupID = g.F_GroupID 
EOD;
		
		// Check password in the code afterwards
		//		AND u.F_Password=?
		$sql .=	<<<EOD
				WHERE $key = ?
EOD;
		
		// Create the binding parameters
		$bindingParams = array($keyValue);
		
		if ($rootID != null) {
			// #503 rootID is an array
			if (is_array($rootID)) {
				if (count($rootID) > 1) {
					$sql .= "AND m.F_RootID IN (".implode(",", $rootID).")";
				} else {
					$sql .= "AND m.F_RootID=".implode(",", $rootID);
				}
			} else {
				$sql .= "AND m.F_RootID=?";
				$bindingParams[] = $rootID;
			}
		}
		
		$rs = $this->db->Execute($sql, $bindingParams);
		
		switch ($rs->RecordCount()) {
			case 0:
				// Invalid login
				throw $this->copyOps->getExceptionForId("errorNoSuchUser", array("loginOption" => $loginOption, "loginKeyField" => $loginKeyField));
				break;
				
			case 1:
				// Valid login
				$dbLoginObj = $rs->FetchNextObj();
				break;
				
			default:
				// More than one user with this name/password
				// gh#653 One user in many groups would give multiple records with same userID.
				// In this case, just treat as one user.
				$justOneUser = true;
				$userID = 0;
				while ($rsObj = $rs->FetchNextObj()) {
					// save first record for later use
					if ($userID == 0) {
						$dbLoginObj = $rsObj;
						$userID = $rsObj->F_UserID;
					} else if ($userID != $rsObj->F_UserID) {
						$justOneUser = false;
						continue;
					}
				}
				// How to send back the list of groups that this user is in? Or is that repeated later?
				if ($justOneUser)
					break;
					
				// gh#231 It is entirely possible to have two user records for the same person in the db
				// typically one would be an LM account and the other a IP.com purchase
				// So first of all see if you can figure out some rules for picking one of the multiple users
				
				// 1. Does the password match just one of them?
                $matches = 0;
				// gh#741
				$rs->MoveFirst();
				while ($userObj = $rs->FetchNextObj()) {
                    // ctp#80
                    $dbPassword = ($loginOption & User::LOGIN_HASHED) ? md5($userObj->F_Email . $userObj->F_Password) : $userObj->F_Password;
					if ($password == $dbPassword) {
						$dbLoginObj = $userObj;
						$matches++;
					}
				}
				if ($matches == 1)
					continue;

				// 2. Is there just one that has not expired?
				$matches = 0;
				$rs->MoveFirst();
				while ($userObj = $rs->FetchNextObj()) {
					if ($userObj->F_ExpiryDate && ($userObj->F_ExpiryDate > '2038')) $userObj->F_ExpiryDate = '2038-01-01';
					if (($userObj->F_ExpiryDate == null) ||
						($userObj->F_ExpiryDate && 
							(strtotime($userObj->F_ExpiryDate) > strtotime(date("Y-m-d"))))) {
						$dbLoginObj = $userObj;
						$matches++;
					}
				}
				if ($matches == 1) 
					continue;
					
				// 3. What about by account attributes?
                // gh#1531 You are only looking at accounts with the targetted productCode
				$rs->MoveFirst();
				while ($userObj = $rs->FetchNextObj())
					$userIDArray[] = $userObj->F_UserID;
				$userIDList = join(',', $userIDArray);
				
				// requires a SQL look up on the accounts for each user
				$selectFields = array("g.F_GroupID as groupID",
								"m.F_RootID as rootID",
								"a.F_ProductVersion as productVersion",
                                "a.F_ProductCode as productCode",
								"a.F_ExpiryDate as expiryDate",
								"u.*");
				$sql  = "SELECT ".join(",", $selectFields);
				$sql .= <<<EOD
					from T_User u, T_Membership m, T_Groupstructure g, T_Accounts a
					where a.F_RootID = m.F_RootID
					and m.F_UserID = u.F_UserID
					and g.F_GroupID = m.F_GroupID
					and u.F_UserID in ($userIDList)
					and a.F_ProductCode in ($productCode);
EOD;
				$rs1 = $this->db->Execute($sql);

                // gh#1531 3a. Check if the userID is unique that you have now filtered by accounts with this productCode
                $matches = $matchedUserID = 0;
                $rs1->MoveFirst();
                while ($accountObj = $rs1->FetchNextObj()) {
                    if ($accountObj->F_UserID != $matchedUserID) {
                        $dbLoginObj = $accountObj;
                        $matches++;
                        $matchedUserID = $accountObj->F_UserID;
                    }
                }
                if ($matches == 1)
                    continue;

				// 3b. Can we rank them by programVersion? HomeUser > FullVersion > LastMinute > TestDrive > Demo
                $matches = $matchedUserID = 0;
				$rs1->MoveFirst();
				while ($accountObj = $rs1->FetchNextObj()) {
					
					if ($accountObj->productVersion && stristr($accountObj->productVersion, 'HU')) {
						
						// the account must still be active
						if ($accountObj->expiryDate && ($accountObj->expiryDate > '2038')) $accountObj->expiryDate = '2038-01-01';
						if (strtotime($accountObj->expiryDate) > strtotime(date("Y-m-d"))) {
							
							// There might be more than one account record for one user, so only count
							// duplicates with different userIDs.
                            if ($accountObj->F_UserID != $matchedUserID) {
								$dbLoginObj = $accountObj;
								$matches++;
                                $matchedUserID = $accountObj->F_UserID;
							}
						}
					}
				}
				if ($matches == 1) 
					continue;

                $matches = $matchedUserID = 0;
				$rs1->MoveFirst();
				while ($accountObj = $rs1->FetchNextObj()) {
					if ($accountObj->productVersion && stristr($accountObj->productVersion, 'FV')) {
						// the account must still be active
						if ($accountObj->expiryDate && ($accountObj->expiryDate > '2038')) $accountObj->expiryDate = '2038-01-01';
						if (strtotime($accountObj->expiryDate) > strtotime(date("Y-m-d"))) {

                            // There might be more than one account record for one user, so only count
                            // duplicates with different userIDs.
                            if ($accountObj->F_UserID != $matchedUserID) {
                                $dbLoginObj = $accountObj;
                                $matches++;
                                $matchedUserID = $accountObj->F_UserID;
                            }
						}
					}
				}
				if ($matches == 1)
					continue;
					
				// TODO. This is not perfect. You might have an expired account that is HU and it is chosen over
				// non-expired FV ones.

				throw $this->copyOps->getExceptionForId("errorDuplicateUsers", array("loginOption" => $loginOption, "loginKeyField" => $loginKeyField));
		}
		
		// A special case to check that the password matches the case (by default MSSQL and MYSQL are case-insensitive)
		// #341 Only check password if you have set this to be the case 
		if ($verified) {
		    // ctp#80
            // ctp#230 Build the hash from the lowercase email
            $dbPassword = ($loginOption & User::LOGIN_HASHED) ? md5(strtolower($dbLoginObj->F_Email) . $dbLoginObj->F_Password) : $dbLoginObj->F_Password;
			if ($password != $dbPassword) {
				//$logMessage = "login $keyValue wrong password, they typed $password, should be ".$dbLoginObj->F_Password;
				//if (($loginOption & User::LOGIN_BY_EMAIL) && ($rootID == null)) $logMessage.=' -tablet-';
				//AbstractService::$debugLog->info($logMessage);
				throw $this->copyOps->getExceptionForId("errorWrongPassword", array("loginOption" => $loginOption, "loginKeyField" => $loginKeyField));
			}
		}
		
		// gh#66 check that the retrieved record is the right type of user
		if (!in_array($dbLoginObj->F_UserType, $userTypes))
			throw $this->copyOps->getExceptionForId("errorWrongUserType", array("userType" => $dbLoginObj->F_UserType));
		
		// Check if the user has expired.
		// AR Some users have NULL expiry date, so this will throw an exception, so add an extra condition to test for this
		// Also, you can't use strtotime on this date format if year > 2038
		if ($dbLoginObj->F_ExpiryDate && ($dbLoginObj->F_ExpiryDate > '2038')) $dbLoginObj->F_ExpiryDate = '2038-01-01';
		if ($dbLoginObj->F_ExpiryDate && 
				(strtotime($dbLoginObj->F_ExpiryDate) > 0) && 
				(strtotime($dbLoginObj->F_ExpiryDate) < strtotime(date("Y-m-d")))) {
				throw $this->copyOps->getExceptionForId("errorUserExpired", array("expiryDate" => date("d M Y", strtotime($dbLoginObj->F_ExpiryDate))));
		}
		
		// Return the $dbLoginObj so the specific service can continue with whatever action it likes
		return $dbLoginObj;
	}
	
	/**
	 * Get the anonymous user from the database
     * TODO This seems utterly pointless - getting back basically a null record from the database
     * sss#130
	 */
	public function loginAnonymousCouloir() {
        $sql = <<<EOD
				SELECT * FROM T_User u
				WHERE F_UserID=-1; 
EOD;
        $rs = $this->db->Execute($sql);

        if ($rs->RecordCount() > 0) {
            $loginObj = $rs->FetchNextObj();
        } else {
            throw $this->copyOps->getExceptionForId("errorNoAnonymousUser");
        }
        return $loginObj;
	}
	
	/**
	 * This function updates a user record with an instance ID
	 * 
	 * @param Number $instanceID
	 */
	function setInstanceId($userId, $instanceId, $productCode) {
		
		// #319 Instance ID per productCode
		// Get the existing set of instance IDs and add/update for this title
		$instanceArray = $this->getInstanceArray($userId);
		
		// If the database value is null, the above returns null
		// but php then makes the array assignment work fine!
		// However, safer to do it explicitly 
		if (!$instanceArray)
			$instanceArray = array();
		$instanceArray[$productCode] = $instanceId;
		$instanceControl = json_encode($instanceArray);

		$sql = <<<EOD
			UPDATE T_User
			SET F_InstanceID=? 
			WHERE F_UserID=?
EOD;
		$bindingParams = array($instanceControl, $userId);
		$resultObj = $this->db->Execute($sql, $bindingParams);
		if ($resultObj)
			return true;
		
		throw $this->copyOps->getExceptionForId("errorSetInstanceId", array("userID" => $userId, "productCode" => $productCode));
	}
	
	/**
	 * This function gets the instanceID for a user for a particular title
	 * 
	 * @param Number $userID
	 */
	function getInstanceID($userId, $productCode) {
		
		// #319 Instance ID per productCode
		$instanceArray = $this->getInstanceArray($userId);
		
		if (isset($instanceArray[$productCode]))
			return $instanceArray[$productCode];
				
		return false;		
	}
	/**
	 * Helper function to turn string to array
	 */
	function getInstanceArray($userId) {
		$sql = <<<EOD
		SELECT u.F_InstanceID as control
		FROM T_User u					
		WHERE u.F_UserID=?
EOD;
		$bindingParams = array($userId);
		$rs = $this->db->Execute($sql, $bindingParams);
		if ($rs && $rs->RecordCount() == 1) {
			
			// Use JSON to encode an array into a string for the database
			return json_decode($rs->FetchNextObj()->control, true);
		}
		
		throw $this->copyOps->getExceptionForId("errorGetInstanceId", array("userID" => $userID));
	}

	// TODO pass sessionId so that you can close it and release T_LicenceHolders
	function logout() {
	}

    /**
     * Get hidden content records from the database to see if this user is blocked at the title level
     *
     */
    public function isTitleBlockedByHiddenContent($groupID, $productCode) {

        // Default position
        $blocked = false;

        // Get an ordered list of any hidden content records for this title and group hierarchy
        $sql = <<<EOD
            select * from T_HiddenContent 
            where F_HiddenContentUID = ?
EOD;
        // gh#653 groupID might be a comma delimitted list
        if (stripos($groupID, ',')) {
            $sql .= " AND F_GroupID IN ($groupID) ";
        } else {
            $sql .= " AND F_GroupID = $groupID ";
        }
        $sql .= " order by F_GroupID desc;";

        $bindingParams = array((string) $productCode);
        $rs = $this->db->Execute($sql, $bindingParams);

        // The most specifc group is first (assuming that sub-groups have a higher id than their parents)
        // This is all you need as it overrides all parents
        if ($rs->RecordCount() > 0) {
            $dbObj = $rs->FetchNextObj();
            $blocked = ($dbObj->F_EnabledFlag == 8);
        }
        return $blocked;
    }
}