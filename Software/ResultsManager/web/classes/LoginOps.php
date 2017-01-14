<?php

class LoginOps {
	
	var $db;
	
	function LoginOps($db) {
		$this->db = $db;
		
		$this->copyOps = new CopyOps();
		$this->manageableOps = new ManageableOps($db);
		$this->accountOps = new AccountOps($db);
	}
	
	/**
	 * If you changed the db, you'll need to refresh it here
	 * Not a very neat function...
	 */
	function changeDB($db) {
		$this->db = $db;
		$this->accountOps->changeDB($db);
		$this->manageableOps->changeDB($db);
	}
	
	// Bento login has different options than RM
	// For now write this as a different function so it can exist in the same file yet be completely different
	// #503 rootID is now an array or rootIDs, although there will only be more than one if subRoots is set in the licence
	// gh#156 separate timezoneOffset
	function loginBento($loginObj, $loginOption, $verified, $userTypes, $rootID, $productCode = null, $clientTimezoneOffset = null) {
		// Pull out the relevant login details from the passed object
		// loginOption controls what fields you use to login with.
		// TODO. The code below doesn't properly do username+studentID at the moment
		if ($loginOption & User::LOGIN_BY_NAME || $loginOption & User::LOGIN_BY_NAME_AND_ID) {
			$loginKeyField = $this->copyOps->getCopyForId("nameKeyfield");
            // ctp#204
            if (isset($loginObj['username']) && $loginObj['username'] != '') {
				$key = 'u.F_UserName';
				$keyValue = $loginObj['username'];
			} else {
				throw $this->copyOps->getExceptionForId("errorLoginKeyEmpty", array("loginOption" => $loginOption, "loginKeyField" => $loginKeyField));
			}
		} elseif ($loginOption & User::LOGIN_BY_ID) {
			$loginKeyField = $this->copyOps->getCopyForId("IDKeyfield");
            // ctp#204
            if (isset($loginObj['studentID']) && $loginObj['studentID'] != '') {
				$key = 'u.F_StudentID';
				$keyValue = $loginObj['studentID'];
			} else {
				throw $this->copyOps->getExceptionForId("errorLoginKeyEmpty", array("loginOption" => $loginOption, "loginKeyField" => $loginKeyField));
			}
		} elseif ($loginOption & User::LOGIN_BY_EMAIL) {
			$loginKeyField = $this->copyOps->getCopyForId("emailKeyfield");
			// ctp#204
			if (isset($loginObj['email']) && $loginObj['email'] != '') {
				$key = 'u.F_Email';
				$keyValue = $loginObj['email'];
			} else {
				throw $this->copyOps->getExceptionForId("errorLoginKeyEmpty", array("loginOption" => $loginOption, "loginKeyField" => $loginKeyField));
			}
		} else {
			throw $this->copyOps->getExceptionForId("errorInvalidLoginOption", array("loginOption" => $loginOption));
		}
		// gh#ctp#80 This might be the hashed version that has been passed
        if (isset($loginObj['password']))
            $password = $loginObj['password'];

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
				// Whilst testing tablet login, tell me about all logins
				//$logMessage = "login $keyValue no such user";
				//if (($loginOption & User::LOGIN_BY_EMAIL) && ($rootID == null)) $logMessage.=' -tablet-';
				//AbstractService::$debugLog->info($logMessage);
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
                // gh#1531 You are only looking at accounts with the tragetted productCode
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
			
				//$logMessage = "login $keyValue but expired on ".$dbLoginObj->F_ExpiryDate;
				//if (($loginOption & User::LOGIN_BY_EMAIL) && ($rootID == null)) $logMessage.= '-tablet-';
				//AbstractService::$debugLog->info($logMessage);
				throw $this->copyOps->getExceptionForId("errorUserExpired", array("expiryDate" => date("d M Y", strtotime($dbLoginObj->F_ExpiryDate))));
		}
		
		// Authenticate the user with the session
		// gh#1140 In case name is null
		$sessionName = (string)$dbLoginObj->F_UserID.$dbLoginObj->F_UserName;
		Authenticate::login($sessionName, $dbLoginObj->F_UserType);
		
		// gh#156 - update the timezone difference for this user in the database
		// gh#1231
		// Should come in as number of minutes needed to be added to local time to get UTC. So HKG will be -480.
		// gh#156 Realize that better to include timezoneOffset separate from loginObj as this is often null
		// But there is no point saving in T_User if we send the same offset with each score, which is the only place we use it
		/*
        AbstractService::$debugLog->info("will check existing timezone offset as new one is $clientTimezoneOffset");
        if ($clientTimezoneOffset !== null) {
	        // gh#1231 Cope with the Number cast as uint from as3 Flash Player bug
            if ($clientTimezoneOffset > 4294966500)
                $clientTimezoneOffset = -(4294967296 - $clientTimezoneOffset);

            // Sanity check
            if ($clientTimezoneOffset < 660 && $clientTimezoneOffset > -840) {
                AbstractService::$debugLog->info("update as old was ". $dbLoginObj->F_TimeZoneOffset);

                // Update if different from before
                if ($clientTimezoneOffset != $dbLoginObj->F_TimeZoneOffset)
                    $this->db->Execute("UPDATE T_User SET F_TimeZoneOffset=? WHERE F_UserID=?", array($clientTimezoneOffset, $dbLoginObj->F_UserID));
            }
        }
		*/

		// Return the $dbLoginObj so the specific service can continue with whatever action it likes
		return $dbLoginObj;

	}
	
	/**
	 * Get the anonymous user from the database
	 */
	public function anonymousUser($rootID) {
		$sql =	<<<EOD
				SELECT * FROM T_User u
				WHERE F_UserID=-1; 
EOD;
		$rs = $this->db->Execute($sql);
		
		if ($rs->RecordCount() > 0) {
			$loginObj = $rs->FetchNextObj();
		} else {
			throw $this->copyOps->getExceptionForId("errorNoAnonymousUser");
		}
		
		// #503 rootID could be an array. 
		if (is_array($rootID)) {
			if (count($rootID) > 1) {
				$rootClause = "m.F_RootID IN (".implode(",",$rootID).")";
			} else {
				$rootClause = "m.F_RootID=".$rootID[0];
			}
		} else {
			$rootClause = "m.F_RootID=".$rootID;
		}
				
		// Then we need the top level group ID for this root.
		// #503 Since we might be searching in a root list, save the one that you actually find
		$sql =	<<<EOD
				SELECT m.F_GroupID as groupID, m.F_RootID as rootID 
				FROM T_Membership m, T_User u
				WHERE $rootClause
				AND m.F_UserID = u.F_UserID
				AND u.F_UserType=?; 
EOD;
		$bindingParams = array(User::USER_TYPE_ADMINISTRATOR);
		$rs = $this->db->Execute($sql, $bindingParams);
		
		if ($rs->RecordCount() > 0) {
			$dbObj = $rs->FetchNextObj();
			$loginObj->groupID = $dbObj->groupID;
			// #503 Since we might be searching in a root list, save the one that you actually find
			$loginObj->rootID = $dbObj->rootID;
		} else {
			throw $this->copyOps->getExceptionForId("errorNoSuchGroup");
		}
			
		// gh#334 Authenticate the user with the session
		// gh#1140 In case name is null
		$sessionName = (string)$loginObj->F_UserID.$loginObj->F_UserName;
		Authenticate::login($sessionName, $loginObj->F_UserType);
		
		return $loginObj;
	}
	
	// Results Manager login
	function login($username, $password, $userTypes, $rootID, $productCode = null) {
		// Network version. SQLite can't cope with this query. RIGHT and FULL OUTER JOINs are not currently supported.
		// I suspect that for a network login it can be made simpler as there will only be 1 root.
		// v3.4.1 Need to pass back name to pick up 'correct' capitalisation
		if ($GLOBALS['dbms'] == 'pdo_sqlite') {
			$sql .=	<<<EOD
				SELECT g.F_GroupID, m.F_RootID,
						u.F_UserType, u.F_UserID, u.F_Password, u.F_StartDate UserStartDate, u.F_ExpiryDate UserExpiryDate,
						u.F_UserName,
						a.F_ExpiryDate ProductExpiryDate,a.F_LanguageCode,a.F_MaxTeachers,a.F_MaxAuthors,a.F_MaxReporters,a.F_LicenceType				
				FROM T_User u 
					LEFT JOIN 
						T_Membership m ON m.F_UserID = u.F_UserID
					LEFT JOIN
						T_Groupstructure g ON m.F_GroupID = g.F_GroupID 					
					LEFT JOIN
						T_Accounts a ON a.F_RootID = m.F_RootID				
				WHERE a.F_ProductCode=?
				AND u.F_UserName=?
				AND u.F_Password=?
				AND (u.F_UserType=1 OR u.F_UserType=2 OR u.F_UserType=3 OR u.F_UserType=4)
EOD;
		} else {

			// Build the basic login query
			// TODO: This currently binds the language to productCode=2 (RM) but we'll want to make this configurable when we add more products)
			// AR I also want to know the login user's ID back in RM. Hmm, I think I was able to pick this up anyway without it being in the selectFields. How?
			// No, I don't think it was being properly passed. Anyway, it is now.
			$selectFields = array("g.F_GroupID",
								  "m.F_RootID",
								  "u.F_UserType",
								  "u.F_UserName",
								  "u.F_UserID",
								  "u.F_Password",
								  $this->db->SQLDate("Y-m-d H:i:s", "u.F_StartDate")." UserStartDate",
								  $this->db->SQLDate("Y-m-d H:i:s", "u.F_ExpiryDate")." UserExpiryDate");
								  
			// Only add in the titles fields if $productCode is specified (i.e. this is not DMS)
			if ($productCode) { 
				$selectFields = array_merge($selectFields, 
									  array($this->db->SQLDate("Y-m-d H:i:s", "a.F_ExpiryDate")." ProductExpiryDate",
											"a.F_LanguageCode",
											"a.F_MaxTeachers",
											"a.F_MaxAuthors", 
											"a.F_MaxReporters",
											"a.F_LicenceType"));
			}
			
			$sql  = "SELECT ".join(",", $selectFields);
			$sql .=	<<<EOD
					FROM T_User u LEFT JOIN 
					T_Membership m ON m.F_UserID = u.F_UserID LEFT JOIN
					T_Groupstructure g ON m.F_GroupID = g.F_GroupID 
EOD;
			
			// Only add in the titles fields if $productCode is specified (i.e. this is not DMS)
			if ($productCode) {
				$sql .=	<<<EOD
						RIGHT JOIN
							(SELECT F_RootID, F_LanguageCode, F_MaxTeachers, F_MaxAuthors, F_MaxReporters, F_ExpiryDate, F_LicenceType
							FROM T_Accounts
							WHERE F_ProductCode = ?) a ON a.F_RootID = m.F_RootID
EOD;
			}
			
			$sql .=	<<<EOD
					WHERE u.F_UserName=?
					AND u.F_Password=?
EOD;
			
			// Construct the allowed login types into an SQL string and add it to the end of the query
			$userTypesSQL = array();
				foreach ($userTypes as $userType)
					$userTypesSQL[] = "u.F_UserType=$userType";
			$sql .= " AND (".implode(" OR ", $userTypesSQL).")";
		
		}		
		// Create the binding parameters
		$bindingParams = array($username, $password);
		
		// Only add in the titles productcode binding if $productCode is specified (i.e. this is not DMS)
		if ($productCode) array_unshift($bindingParams, $productCode);
		
		if ($rootID != null) {
			$sql.= "AND m.F_RootID=?";
			$bindingParams[] = $rootID;
		}
		
        //AbstractService::$debugLog->notice("sql=".$sql);
        //AbstractService::$debugLog->notice("bindingParams=".implode(",",$bindingParams));
		$rs = $this->db->Execute($sql, $bindingParams);
        //AbstractService::$debugLog->notice("records==".$rs->RecordCount());

		switch ($rs->RecordCount()) {
			case 0:
				// Invalid login to regular account
				// gh#1118 - But are you a super user and did you specify the account?
				if ($rootID) {
					$loginObj = $this->login($username, $password, array(User::USER_TYPE_DMS, User::USER_TYPE_DMS_VIEWER), null);
					if (!$loginObj)
						return false;
						
					// Graft the originally requested root onto the returning data
					$loginObj->F_RootID = $rootID;
					// Get the top level group for that root
					$account = $this->manageableOps->getAccountRoot($rootID);
					$topGroupID = $this->manageableOps->getGroupIdForUserId($account->getAdminUserID());
					$loginObj->F_GroupID = $topGroupID;
					// And pretend that RM is not AA
					$loginObj->F_LicenceType = 1;
					
					// Authenticate the user with the session
					$sessionName = (string)$loginObj->F_UserID.$loginObj->F_UserName;
					Authenticate::login($sessionName, $loginObj->F_UserType);
					Session::set('userID', $loginObj->F_UserID);
					Session::set('userType', $loginObj->F_UserType);
					return $loginObj;
						
				} else {
					return false;
				}
			case 1:
				// Valid login
				$loginObj = $rs->FetchNextObj();

				// A special case to check that the password matches the case (by default MSSQL and MYSQL are case-insensitive)
				if ($password != $loginObj->F_Password) return false;
				
				// Check if the user has expired.  Specify the language code as EN when getting copy as we haven't logged in yet.
				// AR Some users have NULL expiry date, so this will throw an exception, so add an extra condition to test for this
				// Also, you can't use strtotime on this date format if year > 2038
				if ($loginObj->UserExpiryDate && ($loginObj->UserExpiryDate > '2038')) $loginObj->UserExpiryDate = '2038-01-01';
				if ($loginObj->UserExpiryDate && 
						(strtotime($loginObj->UserExpiryDate) > 0) && 
						(strtotime($loginObj->UserExpiryDate) < strtotime(date("Y-m-d"))))
					//throw new Exception($this->copyOps->getCopyForId("userExpiredError", array("date" => $loginObj->UserExpiryDate), "EN"));
					throw new Exception("Your user account expired on ".date("d M Y", strtotime($loginObj->UserExpiryDate)));
				
				// Check if the product has expired.  Specify the language code as EN when getting copy as we haven't logged in yet.
				// It seems that copyOps not yet loaded? But this should do it as required, right?
				if ($loginObj->ProductExpiryDate && ($loginObj->ProductExpiryDate > '2038')) $loginObj->ProductExpiryDate = '2038-01-01';
				// v3.4 We ask people to look at usage stats in the email sent 2 weeks after other titles expired.
				// But usually RM is set to expire at the same time. Easiest fix is to allow RM login for 2 weeks after it's expiry
				// but then (ideally) limit access to usage stats. Not sure how to do that bit, so just let them in anyway.
						//(strtotime($loginObj->ProductExpiryDate) < strtotime(date("Y-m-d"))))
				if ($loginObj->ProductExpiryDate && 
						(strtotime($loginObj->ProductExpiryDate) < strtotime("-3 weeks")))
					//throw new Exception($this->copyOps->getCopyForId("productExpiredError", array("date" => $loginObj->ProductExpiryDate, "EN")));
					throw new Exception("Your Results Manager expired on ".date("d M Y", strtotime($loginObj->ProductExpiryDate)));
				
				// Authenticate the user with the session
				// gh#1140 In case name is null
				$sessionName = (string)$loginObj->F_UserID.$loginObj->F_UserName;
				Authenticate::login($sessionName, $loginObj->F_UserType);
				
				// Store information about this login in the session
				Session::set('userID', $loginObj->F_UserID);
				Session::set('userType', $loginObj->F_UserType);

				// Return the loginObj so the specific service can continue with whatever action it likes
				return $loginObj;
				
			default:
				// Something is wrong with the database
				throw new Exception("Multiple users were returned from this login or there are multiple 'Results Manager' titles registered to this account.");
		}
		
	}

	/**
	 * 
	 * This function gets a group record.
	 * Deprecated as should be in ManageableOps
	 * @param Number $groupID
	 */
	function getGroup($groupID) {
		$sql = "SELECT * FROM T_Groupstructure WHERE F_GroupID=?";
		$rs = $this->db->Execute($sql, array($groupID));
		if ($rs)
			return $rs->FetchNextObj();
	}
	
	/**
	 * This function updates a user record with an instance ID
	 * 
	 * @param Number $instanceID
	 */
	function setInstanceID($userID, $instanceID, $productCode) {
		
		// TODO. This seems messy to do it here rather than in config.php
		// But it isn't actually very important so leave here for now.
		// v6.5.6 Add support for HTTP_X_FORWARDED_FOR
		if (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
			$ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
		} elseif (isset($_SERVER['HTTP_TRUE_CLIENT_IP'])) {
			$ip=$_SERVER['HTTP_TRUE_CLIENT_IP'];
		} elseif (isset($_SERVER["HTTP_CLIENT_IP"])) {
			$ip = $_SERVER["HTTP_CLIENT_IP"];
		} else {
			$ip = $_SERVER["REMOTE_ADDR"];
		}
		
		// #319 Instance ID per productCode
		// Get the existing set of instance IDs and add/update for this title
		$instanceArray = $this->getInstanceArray($userID);
		
		// If the database value is null, the above returns null
		// but php then makes the array assignment work fine!
		// However, safer to do it explicitly 
		if (!$instanceArray)
			$instanceArray = array();
		$instanceArray[$productCode] = $instanceID;
		$instanceControl = json_encode($instanceArray);

		// #340. SQLite doesn't like symbolic names for the table in an update
		$sql = <<<EOD
			UPDATE T_User
			SET F_UserIP=?, F_InstanceID=? 
			WHERE F_UserID=?
EOD;
		$bindingParams = array($ip, $instanceControl, $userID);
		$resultObj = $this->db->Execute($sql, $bindingParams);
		if ($resultObj)
			return true;
		
		throw $this->copyOps->getExceptionForId("errorSetInstanceId", array("userID" => $userID, "productCode" => $productCode));
	}
	
	/**
	 * This function gets the instanceID for a user for a particular title
	 * 
	 * @param Number $userID
	 */
	function getInstanceID($userID, $productCode) {
		
		// #319 Instance ID per productCode
		$instanceArray = $this->getInstanceArray($userID);
		
		if (isset($instanceArray[$productCode]))
			return $instanceArray[$productCode];
				
		return false;		
	}
	/**
	 * Helper function to turn string to array
	 */
	function getInstanceArray($userID) {
		$sql = <<<EOD
		SELECT u.F_InstanceID as control
		FROM T_User u					
		WHERE u.F_UserID=?
EOD;
		$bindingParams = array($userID);
		$rs = $this->db->Execute($sql, $bindingParams);
		if ($rs && $rs->RecordCount() == 1) {
			
			// Use JSON to encode an array into a string for the database
			return json_decode($rs->FetchNextObj()->control, true);
		}
		
		throw $this->copyOps->getExceptionForId("errorGetInstanceId", array("userID" => $userID));
	}
	
	// v3.2 A simplified login which is for identification rather than authentication purposes
	// Not used yet.
	/*
	function simplelogin($userID) {		
		$selectFields = array("g.F_GroupID",
							  "m.F_RootID",
							  "u.F_UserType",
							  "u.F_UserID",
							  $this->db->SQLDate("Y-m-d H:i:s", "u.F_ExpiryDate")." UserExpiryDate");
							  
		
		$sql  = "SELECT ".join(",", $selectFields);
		$sql .=	<<<EOD
				FROM T_User u LEFT JOIN 
				T_Membership m ON m.F_UserID = u.F_UserID LEFT JOIN
				T_Groupstructure g ON m.F_GroupID = g.F_GroupID 
				WHERE u.F_UserID=?
EOD;
		
		// Create the binding parameters
		$bindingParams = array($userID);
		
		//NetDebug::trace("sql=".$sql);
		$rs = $this->db->Execute($sql, $bindingParams);
		
		switch ($rs->RecordCount()) {
			case 0:
				// Invalid login
				return false;
			case 1:
				// Valid login
				$loginObj = $rs->FetchNextObj();
		
				// Check if the user has expired.  Specify the language code as EN when getting copy as we haven't logged in yet.
				// AR Some users have NULL expiry date, so this will throw an exception, so add an extra condition to test for this
				// Also, you can't use strtotime on this date format if year > 2038
				if ($loginObj->UserExpiryDate && ($loginObj->UserExpiryDate > '2038')) $loginObj->UserExpiryDate = '2038-01-01';
				if ($loginObj->UserExpiryDate && 
						(strtotime($loginObj->UserExpiryDate) > 0) && 
						(strtotime($loginObj->UserExpiryDate) < strtotime(date("Y-m-d"))))
					throw new Exception($this->copyOps->getCopyForId("userExpiredError", array("date" => $loginObj->UserExpiryDate), "EN"));
				
				// Check if the product has expired.  Specify the language code as EN when getting copy as we haven't logged in yet.
				if ($loginObj->ProductExpiryDate && ($loginObj->ProductExpiryDate > '2038')) $loginObj->ProductExpiryDate = '2038-01-01';
				if ($loginObj->ProductExpiryDate && 
						(strtotime($loginObj->ProductExpiryDate) < strtotime(date("Y-m-d"))))
					throw new Exception($this->copyOps->getCopyForId("productExpiredError", array("date" => $loginObj->ProductExpiryDate, "EN")));
				
				// Authenticate the user with the session
				Authenticate::login($username, $loginObj->F_UserType);
				
				// Store information about this login in the session
				Session::set('userID', $loginObj->F_UserID);
				Session::set('userType', $loginObj->F_UserType);
				
				// Return the loginObj so the specific service can continue with whatever action it likes
				return $loginObj;
				
			default:
				// Something is wrong with the database
				throw new Exception("Multiple users were returned from this login or there are multiple 'Results Manager' titles registered to this account.");
		}
		
	}
	*/
	
	function logout() {
		Authenticate::logout();
		
		Session::clear();
		
		// TODO. Close the session and drop any licence control
		
		//session_unset();
		//unset($_SESSION['rootID']);
		//unset($_SESSION['userID']);
		//unset($_SESSION['userType']);
		
		// v6.5.4.7 Until we know which are our own RM session variables.
		//session_destroy();
		//$_SESSION = array();
	}
	
	// v3.0.6 I don't think this really has anything to do with RM or DMS login. It is for setting student login.
	// I think it fits better under AccountOps, although carefully protected as it is an RM update and a DMS update.
	// for now we are keeping accountOps for DMS, so leave it here, and add EmailOpts too!
	function getLoginOpts() {
		// AR Change to the account table
		//$sql = "SELECT F_LoginOption, F_SelfRegister, F_Verified FROM T_GroupStructure WHERE F_GroupID=?";
		//$resultObj = $this->db->GetRow($sql, array($_SESSION['rootGroupID']));
		$sql = "SELECT F_LoginOption, F_SelfRegister, F_Verified FROM T_AccountRoot WHERE F_RootID=?";
		$resultObj = $this->db->GetRow($sql, array(Session::get('rootID')));
		
		return array("loginOption" => $resultObj['F_LoginOption'],
					 "selfRegister" => $resultObj['F_SelfRegister'],
					 "passwordRequired" => $resultObj['F_Verified']);
	}
	
	function setLoginOpts($loginOption, $selfRegister, $passwordRequired) {
		// AR Change to the account table
		//$sql = "UPDATE T_GroupStructure SET F_LoginOption=?, F_SelfRegister=?, F_Verified=? WHERE F_GroupID=?";
		//$this->db->Execute($sql, array($loginOption, $selfRegister, $passwordRequired, $_SESSION['rootGroupID']));
		//$sql = "UPDATE T_AccountRoot SET F_LoginOption=?, F_SelfRegister=?, F_Verified=? WHERE F_RootID=?";
		//$this->db->Execute($sql, array($loginOption, $selfRegister, $passwordRequired, Session::get('rootID')));
		// v3.2 F_Verified is an integer
		$useVerified = ($passwordRequired) ? 1: 0;
		
		// gh#101 You must ask for at least the loginOption field if you are self-registering
		//        sadly email is NOT the same in both!
		if ($selfRegister && ($selfRegister > 0)) {
			if ($loginOption == User::LOGIN_BY_NAME) {
				$selfRegister = $selfRegister | 1;
			}
			if ($loginOption == User::LOGIN_BY_ID) {
				$selfRegister = $selfRegister | 2;
			}
			if ($loginOption == User::LOGIN_BY_EMAIL) {
				$selfRegister = $selfRegister | 4;
			}
		}
		$sql = "UPDATE T_AccountRoot SET F_LoginOption=$loginOption, F_SelfRegister=$selfRegister, F_Verified=$useVerified WHERE F_RootID=?";
		//NetDebug::trace("sql=".$sql);
		$this->db->Execute($sql, array(Session::get('rootID')));
		
		// gh#653 loginOption is a session variable, so update it
		Session::set('loginOption', $loginOption);
	}
	
	// To hold each contact email and the type of message that they should receive
	// Note that admin emails are NOT saved in the T_AccountEmails to avoid duplication and problems with editing
	// So you 
	function getEmailOpts() {
		$bindingParams = array(Session::get('rootID'));
		//	SELECT IF((e.F_Email IS NULL), u.F_Email, e.F_Email), e.F_MessageType 
		// TODO: Not tested in SQL Server yet
		$sql .=	<<<EOD
			SELECT CASE WHEN (e.F_Email IS NULL) THEN u.F_Email ELSE e.F_Email END as F_Email, e.F_MessageType 
			FROM T_AccountEmails e, T_AccountRoot r, T_User u
			WHERE r.F_RootID = ?
			AND r.F_RootID = e.F_RootID
			AND r.F_AdminUserID = u.F_UserID
			ORDER BY e.F_AdminUser DESC
EOD;
		//echo $sql;
		$resultObj = $this->db->GetArray($sql, $bindingParams);
		$emailArray = array();
		if ($resultObj) {
			foreach ($resultObj as $result) {
				$emailArray[] = array('email' => $result['F_Email'],'messageType' => intval($result['F_MessageType']));
			}
		}
		//echo print_r($emailArray);
		return $emailArray;
	}
	
	function setEmailOpts($emailArray) {
		$bindingParams = array(Session::get('rootID'));
		// First clear out existing emails and settings
		$this->db->Execute("DELETE FROM T_AccountEmails WHERE F_RootID=?", $bindingParams);
		
		$rootID = Session::get('rootID');
		for ($i = 0; $i < count($emailArray); $i++) {
			// The first item is the admin user - so this has a special seting. This is why we do it with a for loop counter
			$emailItem = $emailArray[$i];
			if ($i == 0) {
				$email = null;
				$adminUser = true;
			} else {
				$email = $emailItem['email'];
				$adminUser = false;
			}
			$messageType = $emailItem['messageType'];
			NetDebug::trace("item ".$i.' has email='.$email.' and message='.$messageType. ' and admin='.$adminUser);

			if ($i==0 || ($email != '' && $email != null)) {
				if ($messageType == null || $messageType == '')
					$messageType=0;
				$dbObj = array();
				$dbObj['F_RootID'] = $rootID;
				$dbObj['F_Email'] = $email;
				$dbObj['F_MessageType'] = $messageType;
				$dbObj['F_AdminUser'] = $adminUser;
				$this->db->AutoExecute("T_AccountEmails", $dbObj, "INSERT");
			}
		}
		/*
		foreach ($emailArray as $emailItem) {
			// The first item is the admin user - so this has a special seting. This is why we do it with a for loop counter
			$email = $emailItem['email'];
			$messageType = $emailItem['messageType'];
			if ($email != '' && $email != null) {
				if ($messageType == null || $messageType == '')
					$messageType=0;
				$dbObj = array();
				$dbObj['F_RootID'] = $rootID;
				$dbObj['F_Email'] = $email;
				$dbObj['F_MessageType'] = $messageType;
				$this->db->AutoExecute("T_AccountEmails", $dbObj, "INSERT");
			}
		}
		*/
	}
	
	/**
	 * 
	 * Before you login a user, you need to find things like loginOptions from the account.
	 * @param Number productCode
	 * @param Number prefix
	 * @param Number rootID
	 */
	function getAccountSettings($config) {
		// Check data
		$prefix = (isset($config['prefix'])) ? (string) $config['prefix'] : null; //#519
		$rootID = (isset($config['rootID'])) ? $config['rootID'] : null;
		$productCode = (isset($config['productCode'])) ? $config['productCode'] : null;
		// gh#315
		$ip = (isset($config['ip'])) ? $ip = $config['ip'] : null;
			
		// gh#39 productCode might be a comma delimited list '52,53'
		if (!$productCode)
			throw $this->copyOps->getExceptionForId("errorNoProductCode");
		
		// RootID is more important than prefix.
		// TODO. At present getAccounts can only cope with rootID not prefix. 
		// That should be OK short term, but for max flexibility we should also be able to query from prefix.
		//} else if (isset($config['prefix'])) {
		//	$prefix = $config['prefix'];
		//if (!$rootID)
		//	throw new Exception("No rootID sent to getAccountSettings", 100);
		if (!$prefix && !$rootID) {
			// gh#315 Allow lookup for IP
			if ($ip) {
				$rawRootID = $this->accountOps->getRootIDFromIP($ip, $productCode);
				$rootID = (int) $rawRootID;
				if (!$rootID) 
					return null;
					
			} else {
				throw $this->copyOps->getExceptionForId("errorNoPrefixOrRoot");
			}
		}
		
		// Query the database
		// Kind of silly, but bento is usually keyed on prefix and getAccounts always works on rootID
		// so add an extra call if you don't currently know the rootID
		if (!$rootID || is_nan($rootID)) {
			$rawRootID = $this->accountOps->getAccountRootID($prefix);
			$rootID = (int) $rawRootID;
			// #519
			if (!$rootID) {
				$logMessage = 'prefix error, prefix='.$prefix.' rootID='.$rawRootID.' db='.$GLOBALS['db'];
				AbstractService::$debugLog->err($logMessage);
				throw $this->copyOps->getExceptionForId("errorNoPrefixForRoot", array("prefix" => $prefix));
			}		
		}
		
		// First get the record from T_AccountRoot and T_Accounts
		//$conditions = array("productCode" => $productCode);
		// Hmm. By reusing AccountOps from RM/DMS we end up getting the whole course.xml, when we really don't want it.
		// It probably wouldn't really matter except that we end up with contentLocation goverened by config.php in RM/web which is wrong.
		// Since I have to change something, I might as well make a new method in AccountOps
		$account = $this->accountOps->getBentoAccount($rootID, $productCode);
		
		// Next get account licence details, which are not pulled in from getAccounts as DMS doesn't usually want them
		// gh#39 TODO we need to do this for each title
		// gh#723 add $config, for judge whether the login is the premier library login.
		$account->addLicenceAttributes($this->accountOps->getAccountLicenceDetails($rootID, $config, $productCode));

		// Also check whether we want a default content location
		// gh#39 gh#135
		foreach ($account->titles as $thisTitle) {
			if (!$thisTitle->contentLocation) {
				$sql = <<< SQL
						SELECT F_ContentLocation 
						FROM T_ProductLanguage
						WHERE F_ProductCode = ?
						AND F_LanguageCode = ?;
SQL;
				$bindingParams = array($thisTitle->productCode, $thisTitle->languageCode);
				$rs = $this->db->Execute($sql, $bindingParams);	
				if ($rs) 
					$thisTitle->contentLocation = $rs->FetchNextObj()->F_ContentLocation;
			}
		}
		
		return $account;
	}
	
	// gh#156 not used anymore
	public function setTimeZoneForUser($userID) {
		$zones = array(
	        'Pacific/Midway' => 660,
	        'Pacific/Honolulu' => 600,
            'Pacific/Marquesas' => 570,
	        'America/Anchorage' => 540,
	        'America/Los_Angeles' => 480,
	        'America/Denver' => 420,
	        'America/Tegucigalpa' => 360,
	        'America/New_York' => 300,
	        'America/Caracas' => 270,
	        'America/Belize' => 240,
	        'America/St_Johns' => 210,
	        'America/Sao_Paulo' => 180,
	        'Atlantic/South_Georgia' => 120,
	        'Atlantic/Azores' => 60,
	        'Europe/London' => 0,
	        'Europe/Belgrade' => -60,
	        'Europe/Minsk' => -120,
	        'Asia/Kuwait' => -180,
	        'Asia/Tehran' => -210,
	        'Asia/Muscat' => -240,
            'Asia/Kabul' => -270,
            'Asia/Karachi' => -300,
	        'Asia/Kolkata' => -330,
	        'Asia/Katmandu' => -345,
	        'Asia/Dhaka' => -360,
	        'Asia/Rangoon' => -390,
	        'Asia/Krasnoyarsk' => -420,
	        'Asia/Hong_Kong' => -480,
            'Australia/Eucla' => -525,
	        'Asia/Tokyo' => -540,
	        'Australia/Darwin' => -570,
	        'Australia/Canberra' => -600,
            'Australia/Lord_Howe' => -630,
	        'Asia/Vladivostok' => -660,
            'Pacific/Norfolk' => -690,
	        'Pacific/Fiji' => -720,
            'Pacific/Chatham' => -765,
	        'Pacific/Tongatapu' => -780,
            'Pacific/Kiritimati' => -840
    	);
    	
    	$cols = $this->db->getCol("SELECT F_TimeZoneOffset FROM T_User WHERE F_UserID=?", array($userID));
    	$index = array_keys($zones, $cols[0]);
    	if (sizeof($index) == 1) date_default_timezone_set($index[0]);
	}
}