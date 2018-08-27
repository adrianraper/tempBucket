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
		$this->testCops = new TestCops($db);
		$this->authenticationCops = new AuthenticationCops($db);
		$this->licenceCops = new LicenceCops($db);
		$this->memoryCops = new MemoryCops($db);
		$this->progressCops = new ProgressCops($db);
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
		    // sss#356 all sign in details are case-insensitive
            $keyValue = strtolower($login);
        } else {
            throw $this->copyOps->getExceptionForId("errorLoginKeyEmpty", array("loginOption" => $loginOption, "loginKeyField" => $loginKeyField));
        }

		// #503
        // gh#1596 SQL query performance
		$selectFields = array("m.F_GroupID as groupID",
							  "m.F_RootID as rootID",
							  "u.*");
		$sql  = "SELECT ".join(",", $selectFields);
		$sql .=	<<<EOD
				FROM T_User u LEFT JOIN T_Membership m ON m.F_UserID = u.F_UserID  
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
                    //$dbPassword = ($loginOption & User::LOGIN_HASHED) ? md5($userObj->F_Email . $userObj->F_Password) : $userObj->F_Password;
					//if ($password == $dbPassword) {
                    if ($this->verifyPassword($password, $userObj->F_Password, $keyValue)) {
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
		
		if ($verified) {
            if (!$this->verifyPassword($password, $dbLoginObj->F_Password, $keyValue)) {
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

	public function verifyPassword($typedPassword, $dbPassword, $salt) {
        // sss#132 Since the password might be hashed or not do a run through
        // If the email is not set - use an empty string for hashing
        // sss#359 the salt is the loginKeyField, not the actual email
        //$salt = (isset($dbLoginObj->F_Email)) ? strtolower($dbLoginObj->F_Email) : '';
        // 1. Couloir apps assume that the password they are sent is hashed, first see if the db version is too
        if ($typedPassword != $dbPassword) {
            // 2. It didn't match, so hash the db version to see if that matches
            if ($typedPassword != md5($salt . $dbPassword)) {
                // 3. So maybe the password was sent as plain text (should be impossible for Couloir apps)
                if (md5($salt . $typedPassword) != $dbPassword) {
                    return false;
                }
            }
        }
        return true;
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
			
			// Use JSON to decode a JSON string from the database into an array
			return json_decode($rs->FetchNextObj()->control, true);
		}
		
		throw $this->copyOps->getExceptionForId("errorGetInstanceId", array("userID" => $userId));
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
    // Extracted from CouloirService
    public function login($login, $password, $productCode, $rootId = null, $apiToken = null) {
        // sss#229 If the productCode is a comma delimited string '52,53' you need to handle it here
        // Until we get to a situation (Road to IELTS) that requires it, just assume a single integer
        $productCode = intval($productCode);

        // If you know the account, pick it up
        if ($rootId) {
            $account = $this->accountCops->getBentoAccount($rootId, $productCode);

            // Remove any other titles from the account
            // m#278 You only get one title back from getBentoAccount anyway...
            $account->titles = array_filter($account->titles, function($title) use ($productCode) {
                return ($title->productCode == intval($productCode));
            });

            // What sort of licence is it?
            $licenceType = $account->titles[0]->licenceType;

        } else {
            $account = null;
            $licenceType = Title::LICENCE_TYPE_LT;
        }

        // sss#130 If an anonymous access is requested, build a null user
        if ($licenceType == Title::LICENCE_TYPE_AA && (is_null($login))) {
            $userObj = $this->loginAnonymousCouloir($rootId, $productCode);

        } else {
            // Check the validity of the user details for this product
            //$loginObj["password"] = $password;
            $loginOption = ((isset($account->loginOption)) ? $account->loginOption : User::LOGIN_BY_EMAIL) + User::LOGIN_HASHED;

            // m#16 If you are from SCORM it is as if you had sent an apiToken, perhaps one day you will
            // For now, the only way you can tell is based on the specialised password that the app makes up
            //const plaintext = login + (new Date().getUTCHours()).toString() + "h=F?9;";
            //const password = CryptoJS.MD5(plaintext).toString(CryptoJS.enc.Hex);
            $plaintext = $login . date('G') . "h=F?9;";
            $dbPassword = md5($plaintext);
            if ($this->verifyPassword($password, $dbPassword, strtolower($login)))
                $apiToken = true;

            // m#16 SCORM needs this to be as set from the account
            // m#316 Never ask for password if using apiToken
            if ($apiToken) {
                $verified = false;
            } elseif (isset($account->verified)) {
                $verified = $account->verified;
            } else {
                $verified = true;
            }

            $allowedUserTypes = array(User::USER_TYPE_TEACHER, User::USER_TYPE_ADMINISTRATOR, User::USER_TYPE_STUDENT, User::USER_TYPE_REPORTER);
            $userObj = $this->loginCouloir($login, $password, $loginOption, $verified, $allowedUserTypes, $rootId, $productCode);
        }
        $user = new User();
        $user->fromDatabaseObj($userObj);

        // sss#130 This will cope with anonymous user
        $groups = $this->manageableOps->getUsersGroups($user, $rootId);
        $group = (isset($groups[0])) ? $groups[0] : null;
        // Add the user into the group for standard Bento organisation
        $group->addManageables(array($user));

        // If we didn't know the root id, then we do now
        if (!$rootId) {
            $rootId = $this->manageableOps->getRootIdForUserId($user->id);

            // sss#152 now that we know an account, we must check the validity of the title
            $foundAccount = $this->accountCops->getBentoAccount($rootId, $productCode);
            // sss#128
            $foundAccount->titles[0]->contentLocation = $this->accountCops->getTitleContentLocation($productCode, $foundAccount->titles[0]->languageCode);
        }

        // Check on hidden content at the product level for this group
        $groupIdList =  implode(',', $this->manageableOps->getGroupParents($group->id));
        if ($this->isTitleBlockedByHiddenContent($groupIdList, $productCode)) {
            throw $this->copyOps->getExceptionForId("errorTitleBlockedByHiddenContent");
        }

        // sss#12 After standard Couloir login, DPT and DE also need to grab available tests
        $testId = null;
        if ($productCode == 63 || $productCode == 65) {
            // Get the tests that the user's group can take part in
            // But remember that you DON'T pass the security access code back to the app
            $tests = $this->testCops->getTestsSecure($group, $productCode);
            if ($tests) {
                // For now, the app will only work if max of one test is returned.
                // There is no test selection page so just drop everything except the first
                if (count($tests) > 1)
                    $tests = array_slice($tests,0,1);
                $testId = $tests[0]->testId;
            }
        }

        // Create a session
        $session = $this->progressCops->startCouloirSession($user, $rootId, $productCode, $testId);

        // Create a token that contains this session id
        $token = $this->authenticationCops->createToken(["sessionId" => (string) $session->sessionId]);

        // Grab a licence slot - this will send exception if none available
        // TODO if you catch an exception from this, you could then invalidate the session you just created
        $rc = $this->licenceCops->acquireCouloirLicenceSlot($session);

        // sss#192 Update the user with the instance id (using session id) to cope with only one user on one device
        if ($user->id > 0) {
            $rc = $this->setInstanceId($user->id, $session->sessionId, $productCode);

            // sss#228 Return the user's memory too
            $memory = $this->memoryCops->getWholeMemory($user->id, $productCode);
        }

        // Include default returns of null or empty objects as required by app
        $rc = array(
            "user" => $user->couloirView(),
            "tests" => (isset($tests)) ? $tests : null,
            "token" => $token,
            "memory" => (isset($memory)) ? $memory : json_decode ("{}"));

        // sss#12 For a title that uses encrypted content, send the key
        if ($productCode == 63 || $productCode == 65) {
            $rc["key"] = (string)$group->id;
        } else {
            $rc["key"] = null;
        }

        // sss#304 Return an account if login had to look one up
        if (isset($foundAccount)) {
            // Remove other titles
            $foundAccount->titles = array_filter($foundAccount->titles, function ($title) use ($productCode) {
                return $title->productCode = intval($productCode);
            });
            $rc["account"] = array(
                "lang" => $foundAccount->titles[0]->languageCode,
                "contentName" => $foundAccount->titles[0]->contentLocation,
                "rootId" => intval($foundAccount->id),
                "institutionName" => $foundAccount->name,
                "menuFilename" => "menu.json");
        } else {
            $rc["account"] = null;
        }
        return $rc;

    }
    // m#404 Extracted from CouloirService so apiService can run it too
    public function addUser($rootId, $groupId, $loginObj) {
        /*
        // Pick the productCode and rootId from the token
        $json = $this->authenticationCops->getPayloadFromToken($token);
        $productCode = isset($json->productCode) ? $json->productCode : null;
        $rootId = isset($json->rootId) ? $json->rootId : null;
        if (!$productCode || !$rootId) {
            throw $this->copyOps->getExceptionForId("errorNoAccountFound");
        }
        */

        // sss#229 If the productCode is a comma delimited string '52,53' you need to handle it here
        // Until we get to a situation (Road to IELTS) that requires it, just assume a single integer
        //$productCode = intval($productCode);

        // Check that there is not already a user with this information
        // Name/Id has to be unique in the account
        // Email has to be unique (this was not true in the past but it is better to require it now)
        //$account = $this->accountCops->getBentoAccount($rootId, $productCode);
        $account = $this->manageableOps->getAccountRoot($rootId);
        $loginOption = ((isset($account->loginOption)) ? $account->loginOption : User::LOGIN_BY_EMAIL) + User::LOGIN_HASHED;

        $stubUser = new User();
        if ($loginOption & User::LOGIN_BY_NAME || $loginOption & User::LOGIN_BY_NAME_AND_ID) {
            $loginKeyField = $this->copyOps->getCopyForId("nameKeyfield");
            if (isset($loginObj["login"])) {
                $loginKeyValue = $stubUser->name = $loginObj["login"];
                /// sss#132
                if (isset($loginObj["email"]))
                    $stubUser->email = $loginObj["email"];
                if (isset($loginObj["id"]))
                    $stubUser->studentID = $loginObj["id"];
            } else {
                throw $this->copyOps->getExceptionForId ("errorLoginKeyEmpty", array("loginOption" => $loginOption, "loginKeyField" => $loginKeyField));
            }
        } elseif ($loginOption & User::LOGIN_BY_ID) {
            $loginKeyField = $this->copyOps->getCopyForId("IDKeyfield");
            if (isset($loginObj["login"])) {
                $loginKeyValue = $stubUser->studentID = $loginObj["login"];
                if (isset($loginObj["email"]))
                    $stubUser->email = $loginObj["email"];
                if (isset($loginObj["name"]))
                    $stubUser->name = $loginObj["name"];
            } else {
                throw $this->copyOps->getExceptionForId ( "errorLoginKeyEmpty", array("loginOption" => $loginOption, "loginKeyField" => $loginKeyField));
            }
        } elseif ($loginOption & User::LOGIN_BY_EMAIL) {
            $loginKeyField = $this->copyOps->getCopyForId("emailKeyfield");
            if (isset($loginObj["login"])) {
                $loginKeyValue = $stubUser->email = $loginObj["login"];
                // Add the name if it was passed
                if (isset($loginObj["name"]))
                    $stubUser->name = $loginObj["name"];
                if (isset($loginObj["id"]))
                    $stubUser->name = $loginObj["id"];
            } else {
                throw $this->copyOps->getExceptionForId ( "errorLoginKeyEmpty", array("loginOption" => $loginOption, "loginKeyField" => $loginKeyField));
            }
        } else {
            throw $this->copyOps->getExceptionForId ( "errorInvalidLoginOption", array("loginOption" => $loginOption));
        }
        // sss#132 Check that a required password has been sent
        if ($account->verified && !isset($loginObj["password"])) {
            throw $this->copyOps->getExceptionForId ( "errorPasswordEmpty");
        }

        $user = $this->manageableOps->getUserByKey($stubUser, $rootId, $loginOption);
        if ($user) {
            // A user already exists with these details, so throw an error as we can't add the new one
            throw $this->copyOps->getExceptionForId("errorDuplicateUser", array("name" => $stubUser->name, "loginOption" => $loginOption, "loginKeyField" => $loginKeyField));
        }

        // Add the new user to the top-level group for this account if one was not passed
        if (isset($groupId)) {
            $groups = array($this->manageableOps->getGroup($groupId));
        } else {
            $adminUser = new User();
            $adminUser->id = $account->getAdminUserID();
            $groups = $this->manageableOps->getUsersGroups($adminUser);
        }

        if (isset($loginObj["password"])) {
            // sss#132 save the hashed password
            $stubUser->password = $loginObj["password"];
        }
        $stubUser->registerMethod = "selfRegister";
        $stubUser->userType = User::USER_TYPE_STUDENT;
        $dateStampNow = AbstractService::getNow();
        $dateNow = $dateStampNow->format('Y-m-d H:i:s');
        $stubUser->registrationDate = $dateNow;

        // Use a minimal add user that has no authentication and user duplication checking
        $newUser = $this->manageableOps->minimalAddUser($stubUser, $groups[0], $rootId);
        return $newUser;
    }
}