<?php
class ManageableOps {

	var $db;

	// gh#653
	const XML_IMPORT = "xml_import";
	const EXCEL_IMPORT = "import_from_excel";
	const EXCEL_MOVE_IMPORT = "import_from_excel_with_move";
	const EXCEL_COPY_IMPORT = "import_from_excel_with_copy";
	
	function ManageableOps($db) {
		$this->db = $db;
		
		$this->copyOps = new CopyOps();
		$this->emailOps = new EmailOps($db);
		$this->templateOps = new TemplateOps($db);
	}
	
	/**
	 * If you changed the db, you'll need to refresh it here
	 * Not a very neat function...
	 */
	function changeDB($db) {
		$this->db = $db;
	} 
	
	/*
	 * Add $group to $parentGroup where both are instances of Group
	 */
	function addGroup($group, $parentGroup = null, $allowDuplicates = true) {
		// Ensure that this user has permission to access the parent group
		AuthenticationOps::authenticateGroups(array($parentGroup));
		
		// v3.5 I can't see any circumstance when I would want to allow groups with the same name?
		if (!$allowDuplicates) {
			// Check if the group already exists and if so just return that group
			foreach ($parentGroup->manageables as $manageable) {
                if (get_class($manageable) == "Group") {
                    if (strtolower($manageable->name) == strtolower($group->name))
                        return $manageable;
                }
            }
		}
		
		// Set the parent id (from $parentGroup) and write the new record to the database
		$dbObj = $group->toAssocArray();
		$dbObj['F_GroupParent'] = ($parentGroup) ? $parentGroup->id : 0;
		$this->db->AutoExecute("T_Groupstructure", $dbObj, "INSERT");
		
		// Add the auto-generated id to the original group object
		$group->id = $this->db->Insert_ID();
		
		// gh#448
		AbstractService::$controlLog->info('userID '.Session::get('userID').' added a group(s) with id='.$group->id.' to group '.$parentGroup->id);
		
		// gh#769 If this account is for a distributor, can we send an email to the account manager as this  
		// is quite likely to be the setting up of a trial
		if (Session::get('distributorTrial')) {
			$templateID = 'distributor_created_trial';
			$rootID = Session::get('rootID');
			// TODO: If this gets unwieldy here, use literals.xml or other form to hold all roots and their account manager
			switch ($rootID) {
				case 20895: // EPIC
					$adminEmail = 'info@bookery.com.au';
					break;
				case 7: // Bookery
					$adminEmail = 'sales@clarityenglish.com';
					break;
				// Other distributor accounts will not do anything
				default:
					$adminEmail = null;
			}
			
			if ($adminEmail && $this->templateOps->checkTemplate('emails', $templateID)) {
				$emailData = array("rootID" => $rootID, "group" => $group, "parent" => $parentGroup);
				$emailArray = array("to" => $adminEmail, "data" => $emailData);
				//disabled by Sky according to Andrew's request
				//$this->emailOps->sendEmails("", $templateID, array($emailArray));
			}
		}
		
		// If parentGroup is null then this is a special case and a top-level group has been created (in DMS) so we need to set
		// parentGroup to the same as ID.  Since this is the only place this will ever happen just do it with straight SQL.
		if (!$parentGroup) 
			$this->db->Execute("UPDATE T_Groupstructure SET F_GroupParent=? WHERE F_GroupID=?", array($group->id, $group->id));
		
		// Add this to the valid groups for the logged in user
		AuthenticationOps::addValidGroupIDs(array($group->id));
		
		// v3.5 Can I also add this new group as a manageable to the parent so that it impacts later code?
		if ($parentGroup) 
			$parentGroup->addManageables(array($group));
		
		// Return the created object
		return $group;
	}

	/* 
	 * Allow a hierarchy of groups to be added
	 */
	function addGroupHierarchy($groupHierarchy, $parentGroup = null) {
		//NetDebug::trace("addGroupHierarchy for $groupHierarchy to $parentGroup->name");
		
		// This will create a group hierarchy, using or creating groups as necessary
		// It returns the bottom group
		// Year 1/Group B/Stragglers
		$tempParentGroup = $parentGroup;
		$groupNames = explode("/", $groupHierarchy);
		// 
		//foreach ($groupNames as $groupName) {
		for ($counter = 0; $counter < count($groupNames); $counter++) {
			$groupName = $groupNames[$counter];
			// Check if each group in the hierarchy already exists and if so return it
			foreach ($tempParentGroup->manageables as $manageable) {
				if (strtolower($manageable->name) == strtolower($groupName)) {
					$tempParentGroup = $manageable;
					//NetDebug::trace("addGroupHierarchy, $manageable->name exsits");
					if (count($groupNames)>1) {
						//NetDebug::trace("addGroupHierarchy, keep going");
						$dummy = array_shift($groupNames);
						$group = $this->addGroupHierarchy(implode("/", $groupNames), $tempParentGroup);
					} else {
						//NetDebug::trace("addGroupHierarchy, it was the bottom of the pile so return it");
						$group = $manageable;
					}
					return $group;
				}
			}
			
			// I didn't find this group, so add it
			//NetDebug::trace("addGroupHierarchy, $groupName doesn't exist");
			$newGroup = new Group();
			$newGroup->name = $groupName;
			$newGroup = $this->addGroup($newGroup, $tempParentGroup, true);
			// Will you keep going or is this the last in the hierarchy?
			if ($counter==count($groupNames)-1) {
				//NetDebug::trace("addGroupHierarchy, added all that I need to");
				return $newGroup;
			} else {
				//NetDebug::trace("addGroupHierarchy, keep going after adding new one");
				// But the trouble is that the new group is not a manageable in the array that I already have
				// So I might end up adding it again
				$tempParentGroup = $newGroup;
			}
		}
		// You shouldn't end up here.
		throw new Exception("Unexpected error creating group hierarchy for $groupHierarchy");
	}
	/*
	 * Add $user to $parentGroup where user is an instance of User and $parentGroup is an instance of Group
	 * Note that when you are importing, this is called in a loop using a try / catch mechanism to cope with the exceptions.
	 * TODO It might make a lot more sense to have a cleaner importWithMove that first checks existence and then moves or adds
	 * 	rather than adding and catching exceptions.
	 */
	function addUser($user, $parentGroup, $rootID = null, $loginOption = null) {
		// Ensure that this user has permission to access the parent group
		AuthenticationOps::authenticateGroups(array($parentGroup));
		
		// gh#653 Replace with conflictedUser
		$rc = $this->isUserConflicted($user, $rootID, $loginOption);
		
		// This user cannot be added (probably because it does not have a unique key in this root context)
		if ($rc['returnCode'] > 0) {
			// TODO refactor with updateUser
			switch ($rc['returnCode']) {
				case User::LOGIN_BY_NAME:
					if (isset($rc['conflictedUsers'])) {
						throw new Exception($this->copyOps->getCopyForId("usernameExistsError", array('username' => $user->name)));
					} else {
						throw new Exception($this->copyOps->getCopyForId("usernameBlankError", array('studentID' => $user->studentID, 'email' => $user->email)));							
					}
					break;
				case User::LOGIN_BY_ID:
					if (isset($rc['conflictedUsers'])) {
						throw new Exception($this->copyOps->getCopyForId("studentIDExistsError", array('studentID' => $user->studentID)));
					} else {
						throw new Exception($this->copyOps->getCopyForId("studentIDBlankError", array('username' => $user->name, 'email' => $user->email)));							
					}
					break;
				case User::LOGIN_BY_EMAIL:
					if (isset($rc['conflictedUsers'])) {
						throw new Exception($this->copyOps->getCopyForId("emailExistsError", array('email' => $user->email)));
					} else {
						throw new Exception($this->copyOps->getCopyForId("emailBlankError", array('username' => $user->name, 'studentID' => $user->studentID)));							
					}
			    	break;
				default:
					throw new Exception("unexpected error when checking user conflict");
			}
		}
				
		// Check this doesn't exceed the MAX_userType for teachers, authors and reporters
		if (!$this->canAddUsersOfType($user->userType, 1))
			throw new Exception($this->copyOps->getCopyForId("exceedsMaximumUserTypeError"));
		
		// gh#816 Shouldn't adodb handle this for me if SQLite has no transactions?
		if ($GLOBALS['dbms'] != 'pdo_sqlite') {
			$this->db->SetTransactionMode("SERIALIZABLE");
			$this->db->StartTrans();
		}
		
		// #340 SQLite doesn't like autoexecute
		//$this->db->AutoExecute("T_User", $dbObj, "INSERT");
		$rc = $this->db->Execute($user->toSQLInsert(), $user->toBindingParams());
		if (!$rc)
			throw $this->copyOps->getExceptionForId("errorDatabaseWriting", array("msg" => $this->db->ErrorMsg()));
		
		// Add the auto-generated id to the original user object
		$user->userID = $this->db->Insert_ID();
		$user->id = (string)$parentGroup->id.'.'.$user->userID;
		
		// Now insert a record in the group membership table to say which parent group the user belongs to
		// #340 SQLite doesn't like autoexecute
		$sql = <<<EOD
			INSERT INTO T_Membership (F_UserID,F_GroupID,F_RootID)
			VALUES (?,?,?) 
EOD;
		$bindingParams = array($user->userID, $parentGroup->id, ($rootID) ? $rootID : Session::get('rootID'));
		$rc = $this->db->Execute($sql, $bindingParams);
		if (!$rc)
			throw $this->copyOps->getExceptionForId("errorDatabaseWriting", array("msg" => $this->db->ErrorMsg()));
			
		// gh#164 Check that you haven't just added a duplicate before you commit the transaction
		// Problems - this call uses Authenticate user - which we haven't set yet.
		try {
			$rc = $this->getUserByKey($user, $rootID, $loginOption);
		} catch (Exception $e) {
			// gh#164 
			if ($GLOBALS['dbms'] != 'pdo_sqlite')
				$this->db->FailTrans();
			// gh#353 Need to send exception for a message to the user
			throw $this->copyOps->getExceptionForId("duplicateKeyError", array("loginOption" => $loginOption));
		}
		
		if ($GLOBALS['dbms'] != 'pdo_sqlite')
			$rc = $this->db->CompleteTrans();
		
		// gh#448
		AbstractService::$controlLog->info('userID '.Session::get('userID').' added a user with id='.$user->userID.' to group '.$parentGroup->id);
		
		// Add this to the valid user for the logged in user
		// v3.4 Multi-group users
		//AuthenticationOps::addValidUserIDs(array($user->id));
		AuthenticationOps::addValidUserIDs(array($user->userID));
		
		// Return the newly created user object
		return $user;
	}

	/*
	 * Add $user to $parentGroup where user is an instance of User and $parentGroup is an instance of Group
	 * This does not do any authentication or duplicate checking - for use with bulk processes that have already done that
	 */
	function minimalAddUser($user, $parentGroup, $rootID = null, $loginOption = null) {

		$rc = $this->db->Execute($user->toSQLInsert(), $user->toBindingParams());
		if (!$rc)
			throw $this->copyOps->getExceptionForId("errorDatabaseWriting", array("msg" => $this->db->ErrorMsg()));

		// Add the auto-generated id to the original user object
		$user->userID = $this->db->Insert_ID();
		$user->id = (string)$parentGroup->id.'.'.$user->userID;

		// Now insert a record in the group membership table to say which parent group the user belongs to
		$sql = <<<EOD
			INSERT INTO T_Membership (F_UserID,F_GroupID,F_RootID)
			VALUES (?,?,?)
EOD;
		$bindingParams = array($user->userID, $parentGroup->id, ($rootID) ? $rootID : Session::get('rootID'));
		$rc = $this->db->Execute($sql, $bindingParams);
		if (!$rc)
			throw $this->copyOps->getExceptionForId("errorDatabaseWriting", array("msg" => $this->db->ErrorMsg()));

		// gh#448
		AbstractService::$controlLog->info('userID '.Session::get('userID').' minimally added a user with id='.$user->userID.' to group '.$parentGroup->id);

		// Return the newly created user object
		return $user;
	}

	/*
	 * Move $user to $parentGroup where user is an instance of User and $parentGroup is an instance of Group
	 */
	function moveAndUpdateUser($userDetails, $parentGroup, $rootID = null) {
		// Ensure that this user has permission to access the parent group
		AuthenticationOps::authenticateGroups(array($parentGroup));
		
		// You should only call this function if you know the user exists, but you still need to get their userID
		// If this function fails, generate an exception
		// v3.6 But you don't know that this user has a unique learnerID!
		// And some DMS stuff doesn't use this at all
		if (Session::is_set('loginOption')) {
			$loginOption = Session::get('loginOption');
		}
		if ($loginOption & 2) {
			$user = $this->getUserByLearnerId($userDetails);
		} else {
			$user = $this->getUserByName($userDetails);
		}
		//NetDebug::trace('ManageableOps.moveUser id='.$user->userID);
		if ($user->userType != $userDetails->userType) {
			// If the user type has changed then ensure that making this change will not exceed allowed users of this type
			if (!$this->canAddUsersOfType($userDetails->userType, 1))
				throw new Exception($this->copyOps->getCopyForId("exceedsMaximumUserTypeError"));
		}
		
		//NetDebug::trace('addUser name='.$user->name.' expire='.$user->expiryDate.' type='.$user->userType);
		
		// Update the existing user details - can only do specific fields for now. In fact, just email for now
		$updateRequired = false;
		//NetDebug::trace('ManageableOps.updateUser new email ='.$userDetails->email);
		if (isset($userDetails->email) && ($user->email != $userDetails->Eemail)) {
			$user->email = $userDetails->email;
			$updateRequired = true;
		}
		if ($updateRequired) {
			//NetDebug::trace('ManageableOps.updateUser update him first='.$user->name);
			// Update the user record
			$this->db->AutoExecute("T_User", $user->toAssocArray(), "UPDATE", "F_UserID=".$user->userID);
			/*
			 * assuming that SQLite doesn't like autoexec
			$rc = $this->db->Execute($user->toSQLUpdate($user->userID), $user->toBindingParams());
			if (!$rc)
				throw $this->copyOps->getExceptionForId("errorDatabaseWriting", array("msg" => $this->db->ErrorMsg()));
			 */
			
		}
		
		// Then remove the current membership record(s)
		// TODO Actually you should just be using moveManageables here!
		// gh#653 use moveUsers
		$this->moveUsers(array($user), $parentGroup);
		/*
		$this->db->Execute("DELETE FROM T_Membership WHERE F_UserID =".$user->userID);
		
		// Then insert a record in the group membership table to say which parent group the user now belongs to
		$sql = <<<EOD
			INSERT INTO T_Membership (F_UserID,F_GroupID,F_RootID)
			VALUES (?,?,?) 
EOD;
		$bindingParams = array($user->userID, $parentGroup->id, ($rootID) ? $rootID : Session::get('rootID'));
		$rc = $this->db->Execute($sql, $bindingParams);
		if (!$rc)
			throw $this->copyOps->getExceptionForId("errorDatabaseWriting", array("msg" => $this->db->ErrorMsg()));
		*/
				
		// Return the moved user
		return $user;
	}
	/*
	 * Check that the email address you want to add for a user is unique.
	 * When there was just one product, IYJ, that was sold individually you could check unique email
	 * based on that. But now we could check based on licence type?
	 */
	//function checkUniqueEmail($email) {
	function checkUniqueEmail($email, $licenceType=Title::LICENCE_TYPE_I) {
		
		// Ensure the username is unique within this context
		//		WHERE t.F_ProductCode=1001
		$sql = 	<<<EOD
				SELECT distinct(u.F_UserID)
				FROM T_User u 
				JOIN T_Membership m ON u.F_UserID = m.F_UserID 
				JOIN T_Accounts t ON m.F_RootID = t.F_RootID 
				WHERE t.F_LicenceType=?
				AND u.F_Email=?
EOD;
		$rs = $this->db->Execute($sql, array($licenceType, $email));
		switch ($rs->RecordCount()) {
			case 0:
				// There are no duplicates
				return true;
			default:
				// This email address already exists.
				// Can we return the whole user object instead?
				return false;
		}
	}
	/*
	 * Given an email and password, do they match for this licence type
	 */
	function checkEmailPassword($email, $password, $licenceType=5) {
		
		$sql = 	<<<EOD
				SELECT distinct(u.F_UserID) 
				FROM T_User u 
				JOIN T_Membership m ON u.F_UserID = m.F_UserID 
				JOIN T_Accounts t ON m.F_RootID = t.F_RootID 
				WHERE t.F_LicenceType=?
				AND u.F_Email=?
				AND u.F_Password=?
EOD;
		$rs = $this->db->Execute($sql, array($licenceType, $email, $password));
		
		return $rs->RecordCount();
		/*
		switch ($rs->RecordCount()) {
			case 0:
				// No matches
				return false;
			case 1:
				// One matching record, all is well
				return true;
			default:
				// Multiple matches  - which should give a different error
				return false;
		}
		*/
	}
	/**
	 * Update the given array of groups in the database
	 * 
	 * @param groupsArray An array of Group objects
	 */
	function updateGroups($groupsArray) {
		// Ensure that this user has permission to access all these groups
		AuthenticationOps::authenticateGroups($groupsArray);
		
		$this->db->StartTrans();
		
		foreach ($groupsArray as $group)
			$this->db->AutoExecute("T_Groupstructure", $group->toAssocArray(), "UPDATE", "F_GroupID=".$group->id);
		
		$this->db->CompleteTrans();
	}
	
	/**
	 * Update the given array of users in the database
	 
	 * @param usersArray An array of User objects
	 */
	function updateUsers($usersArray, $rootID = null) {
		if (sizeof($usersArray) == 0) return;
		
		// Ensure that this root context has permission to access all these users
		AuthenticationOps::authenticateUsers($usersArray);
	
		// If changing user type we need to check this doesn't exceed the MAX_userType for teachers and authors
		
		// First determine if we are changing the userType by getting the userType of the first user and seeing if it has changed.
		// Note that we can assume that the userTypes of all the object in $usersArray are the same (as batch changes in 'Details...'
		// will guarantee this).
		// v3.4 Multi-group users
		//$oldUser = $this->getUserById($usersArray[0]->id);
		$oldUser = $this->getUserById($usersArray[0]->userID);
		if ($oldUser->userType != $usersArray[0]->userType) {
			// If the user type has changed then ensure that making this change will not exceed allowed users of this type
			if (!$this->canAddUsersOfType($usersArray[0]->userType, sizeof($usersArray)))
				throw new Exception($this->copyOps->getCopyForId("exceedsMaximumUserTypeError"));
		}
		
		$this->db->StartTrans();
		
		foreach ($usersArray as $user) {
			// gh#653 check if changed user details conflict with existing users
			$rc = $this->isUserConflicted($user, $rootID);

			// This user cannot be updated (probably because it does not have a unique key in this root context)
			if ($rc['returnCode'] > 0) {
				switch ($rc['returnCode']) {
					case User::LOGIN_BY_NAME:
						if (isset($rc['conflictedUsers'])) {
							throw new Exception($this->copyOps->getCopyForId("usernameExistsError", array(username => $user->name)));
						} else {
							throw new Exception($this->copyOps->getCopyForId("usernameBlankError", array(studentID => $user->studentID, email => $user->email)));							
						}
						break;
					case User::LOGIN_BY_ID:
						if (isset($rc['conflictedUsers'])) {
							throw new Exception($this->copyOps->getCopyForId("studentIDExistsError", array(studentID => $user->studentID)));
						} else {
							throw new Exception($this->copyOps->getCopyForId("usernameBlankError", array(username => $user->name, email => $user->email)));							
						}
						break;
					case User::LOGIN_BY_EMAIL:
						if (isset($rc['conflictedUsers'])) {
							throw new Exception($this->copyOps->getCopyForId("emailExistsError", array(email => $user->email)));
						} else {
							throw new Exception($this->copyOps->getCopyForId("usernameBlankError", array(username => $user->name, studentID => $user->studentID)));							
						}
				    	break;
					default:
						throw new Exception("unexpected error when checking user conflict");
				}
			}
			$this->db->AutoExecute("T_User", $user->toAssocArray(), "UPDATE", "F_UserID=".$user->userID);
		}
		
		return $this->db->CompleteTrans();
	}
	
	/**
	 * Determine if we are allowed to add $numberToAdd users of type $userType based on the F_MaxTeachers, F_MaxAuthors, etc fields in T_Account
	 * for ResultsManager.  This is a helper function used by addUser and updateUser.
	 */
	private function canAddUsersOfType($userType, $numberToAdd) {
		// Students are not governed by adding limits (they are licenced instead)
		if ($userType == User::USER_TYPE_STUDENT) return true;
		
		$max = Session::get('max'.$userType);
				
		if ($max > 0) {
			// Count current authors
			$sql = <<<EOD
				   SELECT COUNT(*) count
				   FROM T_User u, T_Membership m
				   WHERE u.F_UserID=m.F_UserID
				   AND u.F_UserType=?
				   AND m.F_RootID=?
EOD;
			$currentCount = $this->db->GetRow($sql, array($userType, Session::get('rootID')));
			
			// Return whether we are allowed to add this number of new users
			return ($currentCount['count'] + $numberToAdd <= $max);
		} else {
			// F_Max<userType> is 0 so there is no limit for this type of user
			return true;
		}
	}
	
	/**
	 * Move the array of manageables.  This function assumes that all the items in the array are the same type (this is assured
	 * in the results manager).  This method delegates the operation to moveUsers or moveGroups depending on the type.
	 *
	 * @param manageables An array of Manageable objects (which must all be of the same class)
	 */
	function moveManageables($manageables, $parentGroup) {
		switch (get_class($manageables[0])) {
			case "User":
				$this->moveUsers($manageables, $parentGroup);
				break;
			case "Group":
				$this->moveGroups($manageables, $parentGroup);
				break;
			default:
				throw new Exception("moveManageables: Unknown class '" + get_class($manageables[0]) + "'");
				break;
		}
	}
	
	function moveUsers($usersArray, $parentGroup, $userDetails = null) {
		if (sizeof($usersArray) == 0) return;
		
		// Ensure that this root context has permission to access all these users
		AuthenticationOps::authenticateUsers($usersArray);
		
		// Ensure that this root context has permission to access all these groups
		AuthenticationOps::authenticateGroups(array($parentGroup));
		
        // gh#1275 Seems very little benefit in running these calls in a transaction, so remove the overhead
		//$this->db->StartTrans();
		
		// gh#653 Since each user might be coming from a different group, need to do multiple sql updates
		// each of which references the old group as well as the userID. 
		foreach ($usersArray as $user) {
			$sql = <<<EOD
				   SELECT COUNT(*) AS count
				   FROM T_Membership m
				   WHERE F_GroupID=?
				   AND F_UserID=?
EOD;
			$rs = $this->db->GetRow($sql, array($parentGroup->id, $user->userID));
			// Does this user already exist in the target group? If so, just delete them from their old group(s).
			if ($rs['count'] > 0) {
				$thisGroupId = $user->getMultiUserGroupID();
				// gh#717 But NOT if you are (accidentally) moving the user within one group
				if ($thisGroupId && $thisGroupId > 0 && $thisGroupId != $parentGroup->id) {
					$bindingParams = array($thisGroupId, $user->userID);
					$this->db->Execute("DELETE FROM T_Membership WHERE F_GroupID=? AND F_UserID=?", $bindingParams);
				} else {
                    // gh#1275 This DELETE WHERE NOT an expensive call, and quite likely not necessary, so it might be worth counting first
                    $sql = <<<EOD
				   SELECT COUNT(*) AS count
				   FROM T_Membership m
				   WHERE F_UserID=?
EOD;
                    $rs = $this->db->GetRow($sql, array($user->userID));
                    if ($rs['count'] > 1) {
                        // AbstractService::$debugLog->info("delete user from outside this group");
                        $bindingParams = array($parentGroup->id, $user->userID);
                        $this->db->Execute("DELETE FROM T_Membership WHERE NOT F_GroupID=? AND F_UserID=?", $bindingParams);
                    }
				}
			} else { 
				// Otherwise update T_Membership
				// During import, if you are moving a user you will have got their data from the database
				// so you will NOT have the group portion of id. You could just update based on userID
				// but this will crash if there the user is already in here twice. In that case you need
				// to delete then insert.
				$thisGroupId = $user->getMultiUserGroupID();
				if ($thisGroupId && $thisGroupId > 0) {
					// make sure you only move this one instance of the user
					$bindingParams[] = array($parentGroup->id, $thisGroupId, $user->userID);
					$this->db->Execute("UPDATE T_Membership SET F_GroupID=? WHERE F_GroupID=? AND F_UserID=?", $bindingParams);
				} else {
					// delete all memberships and then add this one
					$bindingParams[] = array($user->userID);
					$this->db->Execute("DELETE FROM T_Membership WHERE F_UserID=?", $bindingParams);
					$bindingParams = array($user->userID, $parentGroup->id, Session::get('rootID'));
					$sql = <<<EOD
						INSERT INTO T_Membership (F_UserID,F_GroupID,F_RootID)
						VALUES (?,?,?) 
EOD;
					$rc = $this->db->Execute($sql, $bindingParams);
					if (!$rc)
						throw $this->copyOps->getExceptionForId("errorDatabaseWriting", array("msg" => $this->db->ErrorMsg()));
				}					
			}
			
			// gh#653 Since a moved user might have updated some details, check to see if need an update too
			if ($userDetails) {
				// It is safe to update all relevant fields as conflict with loginOption key field will have already been resolved
				if (($userDetails->email != $user->email) ||
					($userDetails->studentID != $user->studentID) ||
					($userDetails->name != $user->name) ||
					($userDetails->password != $user->password)) {
					$user->email = $userDetails->email;
					$user->studentID = $userDetails->studentID;
					$user->name = $userDetails->name;
					$user->password = $userDetails->password;
					$this->db->AutoExecute("T_User", $user->toAssocArray(), "UPDATE", "F_UserID=".$user->userID);
				}
			}

            // gh#1275 Report which users moved
            $userIds[] = $user->userID;
		}

        // gh#1275
		//$this->db->CompleteTrans();
		
		// gh#448
		AbstractService::$controlLog->info('userID '.Session::get('userID').' moved a user(s) with id='.implode(',',$userIds).' to group '.$parentGroup->id);
	}
	
	function moveGroups($groupsArray, $parentGroup) {
		if (sizeof($groupsArray) == 0) return;
		
		// Ensure that this root context has permission to access all these groups.  It would obviously be better to combine these
		// in a single query but PHP keeps balking at array_merge and + so just go with this as the performance hit is negligable.
		AuthenticationOps::authenticateGroups($groupsArray);
		AuthenticationOps::authenticateGroups(array($parentGroup));
		
		$this->db->StartTrans();
		
		$groupIdArray = array();
		foreach ($groupsArray as $group) {
			// TODO: This should perhaps be astracted into AuthenticationOps
			if (in_array($group->id, Session::get('groupIDs'))) return;
			$groupIdArray[] = $group->id;
		}
		
		$groupIdInString = join(",", $groupIdArray);
		
		$this->db->Execute("UPDATE T_Groupstructure SET F_GroupParent=? WHERE F_GroupID IN (".$groupIdInString.")", array($parentGroup->id));
		
		$this->db->CompleteTrans();
		
		// gh#448
		AbstractService::$controlLog->info('userID '.Session::get('userID').' moved a group(s) with id='.$groupIdInString.' to group '.$parentGroup->id);

	}
	
	// gh#653
	function copyUsers($usersArray, $parentGroup, $userDetails = null) {
		if (sizeof($usersArray) == 0) return;
		
		// Ensure that this root context has permission to access all these users
		AuthenticationOps::authenticateUsers($usersArray);
		
		// Ensure that this root context has permission to access all these groups
		AuthenticationOps::authenticateGroups(array($parentGroup));
		
		$this->db->StartTrans();
		
		// We know that the user records exist, we just need to add membership records
		foreach ($usersArray as $user) {
			// Does this user already exist in the target group? If so, nothing to add.
			$sql = <<<EOD
			   SELECT COUNT(*) AS count
			   FROM T_Membership m
			   WHERE F_GroupID=?
			   AND F_UserID=?
EOD;
			$rs = $this->db->GetRow($sql, array($parentGroup->id, $user->userID));
			if ($rs['count'] == 0) {
				$bindingParams = array($user->getMultiUserGroupID(), $user->userID);
				$sql = <<<EOD
					INSERT INTO T_Membership (F_UserID, F_GroupID, F_RootID)
					VALUES (?,?,?) 
EOD;
				$bindingParams = array($user->userID, $parentGroup->id, ($rootID) ? $rootID : Session::get('rootID'));
				$rc = $this->db->Execute($sql, $bindingParams);
				if (!$rc)
					throw $this->copyOps->getExceptionForId("errorDatabaseWriting", array("msg" => $this->db->ErrorMsg()));
			}
							
			// gh#653 Since a copied user might have updated some details, check to see if need an update too
			if ($userDetails) {
				// It is safe to update all relevant fields as conflict with loginOption key field will have already been resolved
				if (($userDetails->email != $user->email) ||
					($userDetails->studentID != $user->studentID) ||
					($userDetails->name != $user->name) ||
					($userDetails->password != $user->password)) {
					$user->email = $userDetails->email;
					$user->studentID = $userDetails->studentID;
					$user->name = $userDetails->name;
					$user->password = $userDetails->password;
					$this->db->AutoExecute("T_User", $user->toAssocArray(), "UPDATE", "F_UserID=".$user->userID);
				}
			}
		}
		
		$this->db->CompleteTrans();
	}
	/**
	 * Given an array of manageables recurse down the tree and delete every bit of information in or associated to the objects.
	 * 
	 * TODO: This currently relies on us getting the entire tree in each manageable, so we can't make them [Transient] which could
	 * have a performance impact on the rest of the application.  If we are taking a performance kick check here first.
	 */
	function deleteManageables($manageablesArray) {
		$this->db->StartTrans();
		
		foreach ($manageablesArray as $manageable) {
            set_time_limit(60);
			// gh#448
			AbstractService::$controlLog->info('userID '.Session::get('userID').' wants to delete a '.get_class($manageable).' with id='.$manageable->id.' and name='.$manageable->name);
			
			switch (get_class($manageable)) {
				case "Group":
					// A special case - it is not possible to delete top level groups in RM
					// TODO: This should perhaps be abstracted into AuthenticationOps
					// That would probably be a good idea as DMS wants to use this routine and it DOES want to delete top level groups.
					// It also seems that DMS has not set group IDs into the session variables, so this call fails anyway.
					//if (in_array($manageable->id, Session::get('groupIDs'))) {
					//	return;
					//}
					AuthenticationOps::authenticateGroupIDForDelete($manageable->id);
					
					// Get all the group IDs we need to delete (including this one)
					// What this is doing is to read the manageable object and just pull out a simple list of group IDs
					$groupIdArray = $manageable->getSubGroupIds();
					$groupIdArray[] = $manageable->id;
					
					// Ensure that this root context has permission to access all these groups
					AuthenticationOps::authenticateGroupIDs($groupIdArray);
					
					// gh#653 get users, not just userIDs to delete them
					// Delete the users (note that we do not check if the user has permission because by this point rows have already
					// been deleted from T_Membership - however, unauthorised users will never be able to get to here without failing
					// the group authentication so this is fine).
					$userArray = $manageable->getSubUsers();
					$this->deleteUsers($userArray);
					
					// Delete the groups
					$this->deleteGroupsById($groupIdArray);
					
					break;
				case "User":
					// Ensure that this root context has permission to access this user
					// v3.4 Multi-group users
					//AuthenticationOps::authenticateUserIDs(array($manageable->id));
					AuthenticationOps::authenticateUserIDs(array($manageable->userID));
					
					// Delete the user
					// gh#653 get the multi-group id rather than pure userID
					//$this->deleteUsersById(array($manageable->id));
					$this->deleteUsers(array($manageable));
					break;
			}
		}
		
		$this->db->CompleteTrans();
	}
	
	/**
	 * Given an array of group ids delete rows from all relevant tables
	 * gh#653 delete all users in this group separately
	 *
	 * @param groupIdArray An array of group ids to delete
	 */
	function deleteGroupsById($rawGroupIdArray) {
		
		// gh#1190 just in case
		$groupIdArray = array_filter($rawGroupIdArray, function ($groupId) {
			if ($groupId <= 0)
				AbstractService::$controlLog->info("Request to delete group $groupId repulsed! ManageableOps.deleteGroupsById");
			return ($groupId > 0);
		});
			
		// If there are no ids in the array do nothing
		if (sizeof($groupIdArray) == 0) return;
		
		$groupIdInString = join(",", $groupIdArray);
		AbstractService::$controlLog->info(' delete these groups '.$groupIdInString);
		
		// gh#1190 Archive instead of delete
		$sql = <<<SQL
			INSERT INTO T_Groupstructure_Deleted
			SELECT * FROM T_Groupstructure WHERE F_GroupID IN ($groupIdInString);
SQL;
		$rc = $this->db->Execute($sql);
		$sql = <<<SQL
			DELETE FROM T_Groupstructure WHERE F_GroupID IN ($groupIdInString);
SQL;
		$rc = $this->db->Execute($sql);

		// Delete entries for these groups in hidden content
		$sql = <<<SQL
			INSERT INTO T_HiddenContent_Deleted
			SELECT * FROM T_HiddenContent WHERE F_GroupID IN ($groupIdInString);
SQL;
		$rc = $this->db->Execute($sql);
		$sql = <<<SQL
			DELETE FROM T_HiddenContent WHERE F_GroupID IN ($groupIdInString);
SQL;
		$rc = $this->db->Execute($sql);
		
		// Delete entries for these groups in edited content (obsolete, so no need to archive)
		$this->db->Execute("DELETE FROM T_EditedContent WHERE F_GroupID IN ($groupIdInString)");

		// Delete entries for any teachers linked to this group
		$sql = <<<SQL
			INSERT INTO T_ExtraTeacherGroups_Deleted
			SELECT * FROM T_ExtraTeacherGroups WHERE F_GroupID IN ($groupIdInString);
SQL;
		$rc = $this->db->Execute($sql);
		$sql = <<<SQL
			DELETE FROM T_ExtraTeacherGroups WHERE F_GroupID IN ($groupIdInString);
SQL;
		$rc = $this->db->Execute($sql);
	}
	
	/**
	 * Given an array of users delete rows from all relevant tables
	 *
	 * @param An array of users to delete
	 */
	private function deleteUsers($userArray) {
		
		// gh#359
		$filteredArray = $userArray;
		$filteredArray = array_filter($userArray, function ($user) {
			if ($user->userID <= 0)
				AbstractService::$debugLog->notice("Request to delete user $user->userID repulsed! ManageableOps.deleteUsers");
			return ($user->userID > 0);
		});
			
		// If there are no users in the array do nothing
		if (sizeof($filteredArray) == 0) return;
		
		// gh#653 delete one by one in case they exist in multiple groups
		// gh#1190 Archive instead of delete
		foreach ($filteredArray as $user) {
			
			$this->db->StartTrans();
			
			$sql = <<<EOD
				   SELECT COUNT(*) AS count
				   FROM T_Membership m
				   WHERE F_UserID=?
EOD;
			$rs = $this->db->GetRow($sql, array($user->userID));
			if ($rs['count'] > 1) {
				// This user exists in another group too, so only remove this membership record
				AbstractService::$controlLog->info(' remove from one group, user id='.$user->userID);
				
				$bindingParams = array($user->getMultiUserGroupID(), $user->userID);
				$sql = <<<SQL
					INSERT INTO T_Membership_Deleted
					SELECT * FROM T_Membership WHERE F_GroupID=? AND F_UserID=?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$sql = <<<SQL
					DELETE FROM T_Membership WHERE F_GroupID=? AND F_UserID=?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
			} else { 
				AbstractService::$controlLog->info(' delete user id='.$user->userID);
				$bindingParams = array($user->userID);
				
				$sql = <<<SQL
					INSERT INTO T_User_Deleted
					SELECT * FROM T_User WHERE F_UserID=?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$sql = <<<SQL
					DELETE FROM T_User WHERE F_UserID=?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				
				$sql = <<<SQL
					INSERT INTO T_Membership_Deleted
					SELECT * FROM T_Membership WHERE F_UserID=?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$sql = <<<SQL
					DELETE FROM T_Membership WHERE F_UserID=?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				
				$sql = <<<SQL
					INSERT INTO T_Score_Deleted
					SELECT * FROM T_Score WHERE F_UserID=?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$sql = <<<SQL
					DELETE FROM T_Score WHERE F_UserID=?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				
				// gh#1067
				$sql = <<<SQL
					INSERT INTO T_Memory_Deleted
					SELECT * FROM T_Memory WHERE F_UserID=?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$sql = <<<SQL
					DELETE FROM T_Memory WHERE F_UserID=?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
			}
			
			$this->db->CompleteTrans();
		}
	}
	
	/**
	 * Export the tree of manageables (beginning with $groupID) as an XML file.
	 */
	function exportXMLFromIDs($groupIDArray, $userIDArray) {
		// Create the XML.  Note that the groupID is authenticated against the root context in getManageables so no need to do it
		// explicitly here.
		$groups = $this->getManageables($groupIDArray);
		
		$users = array();
		
		//AR It would be much better to export dates as Y/m/d rather than the standard m/d/Y
		// as this doesn't need any explanation. 2009/04/05 would be understood by everybody as 5th May.
		// This is only for output to XML though as passing back to ActionScript works nicely with the ansi date.
		// This would be best done in User.php as there is a special function for building an XML node
		foreach ($userIDArray as $userID)
			if ($userID != "")
				$users[] = $this->getUserById($userID);
		
		return $this->exportXML($groups, $users);
	}
	
	function exportXML($groups, $users, $returnDOM = false) {
		// Create the XML
		$dom = new DOMDocument("1.0", "UTF-8");
		
		$manageablesXML = $dom->createElement("manageables");
		
		foreach ($groups as $group) {
			// gh#653 If the group uses a | delimiter, it means we want this user to be in all the groups
			if (stripos($group->name, '|')) {
				// split the groups and duplicate the node for each
				foreach (explode('|', $group->name) as $groupName) {
					// clone the group
					$newGroup = clone $group;
					$newGroup->name = $groupName;
					$node = $newGroup->toXMLNode();
					$manageablesXML->appendChild($dom->importNode($node, true));
				}
			} else {
				$node = $group->toXMLNode();
				$manageablesXML->appendChild($dom->importNode($node, true));
			}
		}
		
		// Add all the users
		foreach ($users as $user) {
			$node = $user->toXMLNode();
			$manageablesXML->appendChild($dom->importNode($node, true));
		}
		
		$dom->appendChild($manageablesXML);
		
		if ($returnDOM) {
			return $dom;
		} else {
			$dom->formatOutput = true;
			return $dom->saveXML();
		}
	}
	
	/**
	 * Read an uploaded XML file into a DOMDocument and import it into parentGroup
	 */
	function importXMLFromUpload($parentGroup) {
		// Ensure that this root context has permission to access this parent group
		AuthenticationOps::authenticateGroups(array($parentGroup));
		
		// Make sure the XML document has been uploaded
		$file = "../../".$GLOBALS['tmp_dir']."/upload_".Session::get('userID');
		if (!file_exists($file))
			throw new Exception("XML file has not been uploaded");
		
		// Load the XML file
		$doc = new DOMDocument();
		$doc->load($file, LIBXML_COMPACT);
		
		// Now we've loaded the temporary file we can delete it
		unlink($file);
		
		return $this->importXML($doc, $parentGroup);
	}
	
	/**
	 * Given arrays of groups and users import them into parentGroup
	 */
	function importManageables($groups, $users, $parentGroup, $moveExistingStudents = self::EXCEL_MOVE_IMPORT) {
		
		// TODO for testing without interface options, just set this
		//$moveExistingStudents = self::EXCEL_IMPORT;
		
		// Ensure that this root context has permission to access this parent group
		AuthenticationOps::authenticateGroups(array($parentGroup));
		
		// Export the manageables as XML
		$doc = $this->exportXML($groups, $users, true);
		
		// And import into the database. When calling this function (i.e. from Excel pasting) we want to merge together groups.
		return $this->importXML($doc, $parentGroup, true, $moveExistingStudents);
	}
	
	/**
	 * Temporary function for updating user names if studentID matches
	 * This does NOT move users. It simply finds a matching studentID and changes the name.
	 * No errors or success flags are raised.
	 */
	function updateManageableNames($groups) {
		$this->db->StartTrans();
		//NetDebug::trace('ManageableOps.updateManageableNames groups='.count($groups));
		foreach ($groups as $group) {
			$manageables = $group->manageables;
			//NetDebug::trace('ManageableOps.updateManageableNames group='.$group->name);
			foreach ($manageables as $manageable) {
				//NetDebug::trace('ManageableOps.getUser from id='.$manageable->studentID);
				$user = $this->getUserByLearnerId($manageable);
				if ($user) {
					//NetDebug::trace('ManageableOps.got name='.$user->name);
					
					// Update the existing user name
					$updateRequired = false;
					//NetDebug::trace('ManageableOps.updateUser new email ='.$userDetails->email);
					if (isset($manageable->name) && ($user->name != $manageable->name)) {
						$user->name = $manageable->name;
						$updateRequired = true;
					}
					if ($updateRequired) {
						//NetDebug::trace('ManageableOps.updateUser to='.$user->name);
						// Update the user record
						$this->db->AutoExecute("T_User", $user->toAssocArray(), "UPDATE", "F_UserID=".$user->userID);
					}
				}
			}
		}
		$this->db->CompleteTrans();
		return true;
	}

	/**
	 * Import the given XML document into parentGroup
	 * v3.6.1 Allow moving and importing
	 */
	function importXML($doc, $parentGroup, $mergeGroups = false, $moveExistingStudents = self::EXCEL_MOVE_IMPORT) {
		// Create a parser and create the manageables tree from the xml
		$importXMLParser = new ImportXMLParser();
		$manageables = $importXMLParser->xmlToManageables($doc);

        // Now go through adding everything, building up the results
        $this->initImportResults();

		foreach ($manageables as $manageable)
            $this->_importManageable($manageable, $parentGroup, $mergeGroups, $moveExistingStudents);

		// Return the results for display in the client
		return $this->getImportResults();
	}

    public function initImportResults() {
        $this->_importResults = array();
    }
    public function getImportResults($sort = true) {
        if (!isset($this->_importResults))
            return false;

        if ($sort)
            // Sort the importResults on success so that the failures appear at the top
            usort($this->_importResults, function ($a, $b) {
                if ($a["success"] == $b["success"]) return 0;
                return ($a["success"] == false && $b["success"] == true) ? 0 : 1;
            });

        return $this->_importResults;
    }
    private function addImportResult($type, $name, $success = "not known", $message = "") {
        // gh#1275
        if (isset($this->_importResults))
            $this->_importResults[] = array("type" => $type,
                "name" => $name,
                "success" => $success,
                "message" => $message);
    }

    /**
	 * usort() function that orders import results failures first
	 */
	static function successCmp($a, $b) {
		if ($a["success"] == $b["success"]) return 0;
		return ($a["success"] == false && $b["success"] == true) ? 0 : 1;
	}
	
	// v3.6.1 Allow moving and importing
	function _importManageable($manageable, $parentGroup, $mergeGroups, $controlExistingStudents) {
		if (get_class($manageable) == "Group") {
			// v3.5 Allow group names to be hierarchies

			// This section checks that the group(s) exists and returns it
			if (stripos($manageable->name,"/")!==false) {				
				$parentGroup = $this->addGroupHierarchy($manageable->name, $parentGroup, !$mergeGroups);
			} else {
				// When $mergeGroups is set duplicates are not allowed (it needs to merge into existing groups) so add parameter to addGroup
				$parentGroup = $this->addGroup($manageable, $parentGroup, !$mergeGroups);
			}
			$this->addImportResult("Group", $manageable->name, true);
			
			foreach ($manageable->manageables as $m) {
				$this->_importManageable($m, $parentGroup, $mergeGroups, $controlExistingStudents);
			}
			
		} else if (get_class($manageable) == "User") {
			// #653 Check if the user details conflict with existing users
			// If they don't, then simply add them.
			// If they do and the control parameter=move - then call moveUser
			// If they do and the control parameter=copy - then call copyUser
			// If they do and the control parameter=simple - then report an error
			$rc = $this->isUserConflicted($manageable);
			if ($rc['returnCode'] > 0) {
                // gh#1275 Catch permission problem exceptions so you can keep going
                try {
                    if ($controlExistingStudents == self::EXCEL_MOVE_IMPORT) {
                        $addedMsg = "moved";
                        $this->moveUsers($rc['conflictedUsers'], $parentGroup, $manageable);
                        $success = true;
                    } elseif ($controlExistingStudents == self::EXCEL_COPY_IMPORT) {
                        $addedMsg = "copied";
                        $this->copyUsers($rc['conflictedUsers'], $parentGroup, $manageable);
                        $success = true;
                    } else {
                        $addedMsg = "duplicate details";
                        $success = false;
                    }
                } catch (Exception $e) {
                    AbstractService::$debugLog->info("caught exception for " . $manageable->name . " of ".$e->getMessage());
                    $addedMsg = $e->getMessage();
                    $success = false;
                }
			} else {
				$addedMsg = "added";
				// gh#769 record source of registration
				$today = new DateTime();
				if (!isset($manageable->registrationDate))  $manageable->registrationDate = $today->format('Y-m-d H:i:s');
				if (!isset($manageable->registerMethod)) $manageable->registerMethod = 'RMimport';
				
				$this->addUser($manageable, $parentGroup);
				$success = true;
			}
				
			$typeName = $manageable->getTypeName();
			$this->addImportResult($typeName, $manageable->name, $success, $addedMsg);
			/*
			if ($e->getCode() != $parentGroup->id) {
				$existingUser = $this->moveAndUpdateUser($manageable, $parentGroup);
				$typeName = $existingUser->getTypeName();
				$this->addImportResult($typeName, $existingUser->name, true, "moved");
			} else {
				$this->addImportResult($typeName, $manageable->name, false, $e->getMessage());
			}
			*/
		}
        // gh#1275
        return $success;
	}

	/**
	 * This function reads account root information
	 */
	function getAccountRoot($rootID) {
		// Ensure the username is unique within this context
		$sql  = "SELECT ".Account::getSelectFields($this->db);
		$sql .= <<<EOD
				FROM T_AccountRoot a
				WHERE a.F_RootID=?
EOD;
		$rs = $this->db->Execute($sql, array($rootID));
		//NetDebug::trace('sql='.$sql.' with '.$rootID.' gives '.$rs->RecordCount());
		switch ($rs->RecordCount()) {
			case 0:
				// There are no records
				return false;
			default:
				// Should be absolutely impossible to get more than one record
				// Just send back the first if somehow you do
				$accountObj = $rs->FetchNextObj();
				$account = new Account();
				$account->fromDatabaseObj($accountObj);
				return $account;
		}
	}
	 
	/**
	 * Given a user id, what group(s) are they in?
	 */
	function getUsersGroups($user) {
		$sql = <<<EOD
			SELECT g.*
			FROM T_Membership m, T_Groupstructure g
			WHERE m.F_UserID = ?
			AND m.F_GroupID = g.F_GroupID
EOD;
		$rs = $this->db->Execute($sql, array($user->id));
		switch ($rs->RecordCount()) {
			case 0:
				// There are no records
				return false;
			default:
				// At some point users will be able to be in multiple groups
				// in which case we need to know them all.
				$groups = array();
				while ($groupObj = $rs->FetchNextObj())
					$groups[] = $this->_createGroupFromObj($groupObj);
		}

		return $groups;
	}
	/**
	 * This returns a specific user object defined by its ID
	 */
	function getUserById($userID) {
        // gh#1292 Are you just trying to get yourself?
        if ($userID == Session::get('userID')) {
            // AbstractService::$debugLog->notice("getUserById recognised myself");
            $sql  = "SELECT ".User::getSelectFields($this->db);
            $sql .= <<<EOD
				FROM T_User u
				WHERE u.F_UserID=?
EOD;
            $bindingParams = array($userID);
            $usersRS = $this->db->Execute($sql, $bindingParams);

            if ($usersRS->RecordCount() == 1) {
                return $this->_createUserFromObj($usersRS->FetchNextObj());
            } else {
                throw new Exception("Database error, user lost");
            }

        } else {
            // AbstractService::$debugLog->notice("getUserById working the old way on someone else $userID");
            $users = $this->getUsersById(array($userID));
            if (isset($users[0]))
                return $users[0];
        }
	}
	
	/**
	 * This returns an array of users defined by the given id array
	 */
	function getUsersById($userIDArray) {
		AuthenticationOps::authenticateUserIDs($userIDArray);
		
		$userIdInString = join(",", $userIDArray);
		
		// Get the given users
		$sql  = "SELECT ".User::getSelectFields($this->db);
		$sql .= <<<EOD
				FROM T_User u
				WHERE u.F_UserID IN ($userIdInString)
EOD;
		
		$usersRS = $this->db->Execute($sql);
		
		$users = array();
		if ($usersRS->RecordCount() > 0)
			while ($userObj = $usersRS->FetchNextObj())
				$users[] = $this->_createUserFromObj($userObj);
				
		return $users;
	}
	/**
	 * This returns a specific user object defined by a key set from loginOption
	 * Look in one or more roots for this user.
	 */
	function getRootUserByKey($stubUser, $rootID = null) {
		
		if (!$rootID)
			$rootID = '*';
			
		if (isset($stubUser->name)) {
			$whereClause = 'u.F_UserName=?';
			$key = $stubUser->name;
			$loginKeyField = $this->copyOps->getCopyForId("nameKeyfield");
		} else if (isset($stubUser->studentID)) {
			$whereClause = 'u.F_StudentID=?';
			$key = $stubUser->studentID;
			$loginKeyField = $this->copyOps->getCopyForId("IDKeyfield");
		} else if (isset($stubUser->email)) {
			$whereClause = 'u.F_Email=?';
			$key = $stubUser->email;
			$loginKeyField = $this->copyOps->getCopyForId("emailKeyfield");
		} else {
			throw new Exception("Unspecified login option");
		}
		// gh#653 Might be duplicate membership records so just grab unique userIDs
		$sql  = "SELECT DISTINCT ".User::getSelectFields($this->db);
		$sql .= <<<EOD
			FROM T_User u, T_Membership m
			WHERE $whereClause
			AND m.F_UserID = u.F_UserID
EOD;
		if (stristr($rootID,',')!==FALSE) {
			$sql.= " AND m.F_RootID in ($rootID)";
		} else if ($rootID=='*') {
			// check all roots in that case - just for special cases, usually self-hosting
		} else {
			$sql.= " AND m.F_RootID = $rootID";
		}
		$usersRS = $this->db->Execute($sql, array($key));

		// If you don't get a unique match, throw an exception
		if ($usersRS->RecordCount()==1) {
			$userObj = $usersRS->FetchNextObj();
			$user = $this->_createUserFromObj($userObj);
		} else if ($usersRS->RecordCount()==0) {
			return false;
		} else {
			throw $this->copyOps->getExceptionForId("errorDuplicateUsers", array("loginKeyField" => $loginKeyField));
		}
		
		// How can we use AuthenticationOps to make sure that the logged in teacher has rights over this user?
		AuthenticationOps::authenticateUsers(array($user));
		return $user;
	}
	/**
	 * This returns a specific user object defined by a key set from loginOption
	 * It assumes that a CLS user has licenceType=5 in an account which our user is the admin for
	 */
	function getCLSUserByKey($stubUser, $loginOption = null) {

		// gh#653 tidy up
		if ($loginOption == User::LOGIN_BY_NAME) {
			$whereClause = 'WHERE u.F_UserName=?';
			$key = $stubUser->name;
			$loginKeyField = $this->copyOps->getCopyForId("nameKeyfield");
		} else if ($loginOption == User::LOGIN_BY_ID) {
			$whereClause = 'WHERE u.F_StudentID=?';
			$key = $stubUser->studentID;
			$loginKeyField = $this->copyOps->getCopyForId("IDKeyfield");
		} else if ($loginOption == User::LOGIN_BY_EMAIL) {
			$whereClause = 'WHERE u.F_Email=?';
			$key = $stubUser->email;
			$loginKeyField = $this->copyOps->getCopyForId("emailKeyfield");
		} else if (isset($stubUser->name)) {
			$whereClause = 'WHERE u.F_UserName=?';
			$key = $stubUser->name;
			$loginKeyField = $this->copyOps->getCopyForId("nameKeyfield");
		} else if (isset($stubUser->studentID)) {
			$whereClause = 'WHERE u.F_StudentID=?';
			$key = $stubUser->studentID;
		} else if (isset($stubUser->email)) {
			$loginKeyField = $this->copyOps->getCopyForId("IDKeyfield");
			$whereClause = 'WHERE u.F_Email=?';
			$key = $stubUser->email;
			$loginKeyField = $this->copyOps->getCopyForId("emailKeyfield");
		} else {
			throw new Exception("Unspecified loginOption");
		}
		
		$sql  = "SELECT DISTINCT ".User::getSelectFields($this->db);
		$sql .= <<<EOD
		FROM T_User u, T_AccountRoot ar, T_Accounts a
		$whereClause
		AND ar.F_AdminUserID = u.F_UserID
		AND a.F_RootID = ar.F_RootID
		AND a.F_LicenceType = 5
		GROUP BY u.F_UserID;
EOD;
		$usersRS = $this->db->Execute($sql, array($key));

		// If you don't get a unique match, throw an exception
		if ($usersRS->RecordCount()==1) {
			$userObj = $usersRS->FetchNextObj();
			$user = $this->_createUserFromObj($userObj);
		} else if ($usersRS->RecordCount()==0) {
			return false;
		} else {
			//throw new Exception("More than one user with this key $key");
			throw $this->copyOps->getExceptionForId("errorDuplicateUsers", array("loginKeyField" => $loginKeyField));
			
		}
		
		// How can we use AuthenticationOps to make sure that the logged in teacher has rights over this user?
		// #341 There might not be a teacher
		//AuthenticationOps::authenticateUsers(array($user));
		return $user;
	}
	
	/**
	 * This returns a specific user object defined by a key set from loginOption
	 * gh#164 you might pass the loginOption now
	 */
	function getUserByKey($stubUser, $rootID = NULL, $loginOption = null) {

		// gh#653
		// gh#1067 you might want to force root to be empty, not picked up from session
		if ($rootID === 0) {
			$rootID = null;
		} else {
			$rootID = ($rootID) ? $rootID : Session::get('rootID');
		}
		$loginOption = ($loginOption) ? $loginOption : Session::get('loginOption');
		
		if ($loginOption == User::LOGIN_BY_NAME) {
			$whereClause = 'WHERE u.F_UserName=?';
			$key = $stubUser->name;
			$loginKeyField = $this->copyOps->getCopyForId("nameKeyfield");			
		} else if ($loginOption == User::LOGIN_BY_ID) {
			$whereClause = 'WHERE u.F_StudentID=?';
			$key = $stubUser->studentID;
			$loginKeyField = $this->copyOps->getCopyForId("IDKeyfield");			
		} else if ($loginOption == User::LOGIN_BY_EMAIL) {
			$whereClause = 'WHERE u.F_Email=?';
			$key = $stubUser->email;
			$loginKeyField = $this->copyOps->getCopyForId("emailKeyfield");			
		} else if (isset($stubUser->name)) {
			$whereClause = 'WHERE u.F_UserName=?';
			$key = $stubUser->name;
			$loginKeyField = $this->copyOps->getCopyForId("nameKeyfield");			
		} else if (isset($stubUser->studentID)) {
			$whereClause = 'WHERE u.F_StudentID=?';
			$key = $stubUser->studentID;
			$loginKeyField = $this->copyOps->getCopyForId("IDKeyfield");			
		} else if (isset($stubUser->email)) {
			$whereClause = 'WHERE u.F_Email=?';
			$key = $stubUser->email;
			$loginKeyField = $this->copyOps->getCopyForId("emailKeyfield");			
		} else {
			throw new Exception("Unspecified loginOption");
		}
		// gh#164 No need to join on membership if you don't have a rootID
		// gh#653 Might be duplicate membership records so just grab unique userIDs
		if ($rootID != null) {
			$sql  = "SELECT DISTINCT ".User::getSelectFields($this->db);
			$sql .= <<<EOD
					FROM T_User u LEFT JOIN 
					T_Membership m ON m.F_UserID = u.F_UserID LEFT JOIN
					T_Groupstructure g ON m.F_GroupID = g.F_GroupID 
					$whereClause
					AND m.F_RootID=?
EOD;
			$bindingParams = array($key, $rootID);
		} else {
			$sql  = "SELECT DISTINCT ".User::getSelectFields($this->db);
			$sql .= <<<EOD
					FROM T_User u 
					$whereClause
EOD;
			$bindingParams = array($key);
		}
		$usersRS = $this->db->Execute($sql, $bindingParams);
		
		// If you don't get a unique match, throw an exception
		if ($usersRS->RecordCount()==1) {
			$userObj = $usersRS->FetchNextObj();
			$user = $this->_createUserFromObj($userObj);
		} else if ($usersRS->RecordCount()==0) {
			return false;
		} else {
			//throw new Exception("More than one user with this key $key");
			throw $this->copyOps->getExceptionForId("errorDuplicateUsers", array("loginKeyField" => $loginKeyField));
		}
		
		// How can we use AuthenticationOps to make sure that the logged in teacher has rights over this user?
		// #341 There might not be a teacher
		//AuthenticationOps::authenticateUsers(array($user));
		return $user;
	}
	
	/**
	 * This returns a specific user object defined by its studentID.
	 * Should be deprecated by the more general function getUserByKey
	 */
	function getUserByLearnerId($stubUser) {
		$rootID = Session::get('rootID');	    
		// gh#653 Might be duplicate membership records so just grab unique userIDs
		$sql  = "SELECT DISTINCT ".User::getSelectFields($this->db);
		$sql .= <<<EOD
				FROM T_User u, T_Membership m
				WHERE u.F_StudentID=?
                AND m.F_RootID = ?
                AND u.F_UserID = m.F_UserID;
EOD;
		$usersRS = $this->db->Execute($sql, array($stubUser->studentID));

		// If you don't get a unique match, throw an exception
		if ($usersRS->RecordCount()==1) {
			$userObj = $usersRS->FetchNextObj();
			$user = $this->_createUserFromObj($userObj);
		} else if ($usersRS->RecordCount()==0) {
			return false;
		} else {
			throw new Exception("More than one user with this studentID ($stubUser->studentID)");
		}
		
		// How can we use AuthenticationOps to make sure that the logged in teacher has rights over this user?
		AuthenticationOps::authenticateUsers(array($user));
		return $user;
	}
	/**
	 * This returns a specific user object defined by its name.
	 * Should be deprecated by the more general function getUserByKey
	 */
	function getUserByName($user) {
		$rootID = Session::get('rootID');	    
		// gh#653 Might be duplicate membership records so just grab unique userIDs
		$sql  = "SELECT DISTINCT ".User::getSelectFields($this->db);
		$sql .= <<<EOD
				FROM T_User u, T_Membership m
                WHERE u.F_UserName = ?
                AND m.F_RootID = ?
                AND u.F_UserID = m.F_UserID;
EOD;
		$usersRS = $this->db->Execute($sql, array($user->name, $rootID));

		// If you don't get a unique match, throw an exception
		if ($usersRS->RecordCount()==1) {
			$userObj = $usersRS->FetchNextObj();
			$user = $this->_createUserFromObj($userObj);
		} else {
			throw new Exception("More than one user with this name ($user->name)");
		}
		
		// How can we use AuthenticationOps to make sure that the logged in teacher has rights over this user?
		AuthenticationOps::authenticateUsers(array($user));
		return $user;
	}
	/**
	 * Return the user's details if the email address matches.
	 * When there was just one product, IYJ, that was sold individually you could check unique email
	 * based on that. But now we could check based on licence type?
	 * Should be deprecated by the more general function getUserByKey
	 */
	function getUserFromEmail($email, $licenceType=null) {

		// gh#487
		$sql  = "SELECT ".User::getSelectFields($this->db);
		if ($licenceType) {
			$sql .= <<<EOD
					FROM T_User u 
					JOIN T_Membership m ON u.F_UserID = m.F_UserID 
					JOIN T_Accounts t ON m.F_RootID = t.F_RootID 
					WHERE u.F_Email = ?
					AND t.F_LicenceType = ?
EOD;
			$bindingParams = array($email, $licenceType);
		} else {
			$sql .= <<<EOD
					FROM T_User u 
					WHERE u.F_Email = ?
EOD;
			$bindingParams = array($email);
		}
		$rs = $this->db->Execute($sql, $bindingParams);
		
		switch ($rs->RecordCount()) {
			case 0:
				// There are no records
				return false;
			default:
				// gh#487
				// Send back the user(s) that you found
				$users = Array();
				while ($userObj = $rs->FetchNextObj())
					$users[] = $this->_createUserFromObj($userObj);
				return $users;
		}
	}
		
	/**
	 * Get all learners in a root
	 */
	function getAllLearners($rootID) {
		$sql = "SELECT DISTINCT ".User::getSelectFields($this->db);
		$sql .= <<<EOD
			FROM T_User u
			INNER JOIN T_Membership m ON u.F_UserID = m.F_UserID
			WHERE u.F_UserType = 0
			AND m.F_RootID = ?
			ORDER BY u.F_UserID ASC
EOD;
		$rs = $this->db->Execute($sql, array($rootID));
		switch ($rs->RecordCount()) {
			case 0:
				$users = false;
				break;
				
			default:
				$users = Array();
				while ($userObj = $rs->FetchNextObj()) {
					$users[] = $this->_createUserFromObj($userObj);
				}
		}
		
		return $users;
	}
	/**
	 * This returns the group ID that a given user belongs to.  At present this is only used by DMS, but it might come in useful for something
	 * later on so I've left it in here.
	 * gh#653 return a comma delimitted list of multiple groups for this user
	 * Also used by Bento hiddenContentTransform
	 */
	function getGroupIdForUserId($userID) {
		// gh#653 tidy up SQL as no need to join on T_Groupstructure
		$sql = <<<EOD
			   SELECT m.F_GroupID as groupID
			   FROM T_User u, T_Membership m
			   WHERE m.F_UserID = u.F_UserID
			   AND u.F_UserID=?
EOD;
		$rs = $this->db->Execute($sql, array($userID));
		if ($rs) {
			while ($row = $rs->FetchNextObj())
				$groups[] = $row->groupID;
			return implode(',', $groups); 
		}

		return null;
	}
    /**
     * This returns the group that matches a productCode (as a name) in an account. Will be used by TB6weeks.
     * If the group doesn't exist, it is created.
     * gh#1118
     */
    function getGroupForTB6weeks(Account $account, $productCode) {
        $parentGroup = $this->getGroup($this->getGroupIdForUserId($account->getAdminUserID()));
        $group = $this->getGroupInParent($productCode.Group::SELF_REGISTER_GROUP_NAME, $parentGroup);

        if (!$group) {
            $group = new Group();
            $group->name = $productCode.Group::SELF_REGISTER_GROUP_NAME;
            $this->addGroup($group, $parentGroup, false);
        }
        return $group;
    }
	/**
	 * This returns the root ID that a given user belongs to.
	 */
	function getRootIdForUserId($userId) {
		$sql = <<<EOD
			   SELECT m.F_RootID
			   FROM T_User u, T_Membership m
			   WHERE m.F_UserID = u.F_UserID
			   AND u.F_UserID=?
EOD;
		return $this->db->GetOne($sql, array($userId));
	}
	
	/**
	 * This returns a group. 
	 * Added for loginGateway, though I don't see why it isn't here already!
	 * It's in loginOps, that's why. Though I am sure it shouldn't be.
	 */
	function getGroup($groupID) {
		$sql = <<<EOD
			   SELECT *
			   FROM T_Groupstructure g
			   WHERE g.F_GroupID=?
EOD;
		$rs = $this->db->Execute($sql, array($groupID));
		$group = new Group();
		
		if ($rs->RecordCount() == 1) {
			$obj = $rs->FetchNextObj();
			$group->fromDatabaseObj($obj);
		} else {
			$group = false;
		}
		return $group;
	}
    /**
     * Get group by name within another group. No need to have any members.
     * gh#1118
     */
    function getGroupInParent($groupName, Group $parentGroup) {
        $sql = <<<EOD
			   SELECT *
			   FROM T_Groupstructure g
			   WHERE g.F_GroupName = ?
			   AND g.F_GroupParent = ?
EOD;
        $rs = $this->db->Execute($sql, array($groupName, $parentGroup->id));
        $group = new Group();

        // Not sure if this is right, but if you find more than one group with a matching name
        // just return the first.
        if ($rs->RecordCount() >= 1) {
            $obj = $rs->FetchNextObj();
            $group->fromDatabaseObj($obj);
        } else {
            $group = false;
        }
        return $group;
    }
    /**
	 * Similar function to get by name. You have to know a rootID, and there has to be at least one user in the group.
	 */
	function getGroupByName($groupName, $rootID) {
		$sql = <<<EOD
			   SELECT *
			   FROM T_Groupstructure g, T_Membership m
			   WHERE g.F_GroupName = ?
			   AND g.F_GroupID = m.F_GroupID
			   AND m.F_RootID = ?
EOD;
		$rs = $this->db->Execute($sql, array($groupName, $rootID));
		$group = new Group();
		
		// Not sure if this is right, but if you find more than one group with a matching name
		// just return the first.
		if ($rs->RecordCount() >= 1) {
			$obj = $rs->FetchNextObj();
			$group->fromDatabaseObj($obj);
		} else {
			$group = false;
		}
		return $group;
	}	
	
	// TODO. Badly named as it actually sends back groupIDs - and ClarityService expects it to.
	function getExtraGroups($userID) {
		// Only authenticate if this is not the logged in user attempting to get their groups (during login).
		if ($userID != Session::get('userID'))
			AuthenticationOps::authenticateUserIDs(array($userID));
		
		// Get the extra groups for the given user id
		// v3.3.1 Add an extra check that their main group isn't in this list.
		$sql = 	<<<EOD
				SELECT x.F_GroupID as groupID
				FROM T_ExtraTeacherGroups x, T_Membership m
				WHERE x.F_UserID = ?
				AND x.F_UserID = m.F_UserID
				AND x.F_GroupID <> m.F_GroupID
EOD;

		$extraGroupsRS = $this->db->Execute($sql, array($userID));
		
		$extraGroupIDs = array();
		
		foreach ($extraGroupsRS->GetArray() as $element)
			$extraGroupIDs[] = $element['groupID'];
			
		return $extraGroupIDs;
	}
	
	// TODO. But this one expects full groups.
	function setExtraGroups($user, $groupsArray) {
		AuthenticationOps::authenticateUsers(array($user));
		AuthenticationOps::authenticateGroups($groupsArray);
		
		$this->db->StartTrans();
		
		// Delete the old extra groups
		// v3.4 Multi-group users
		//$this->db->Execute("DELETE FROM T_ExtraTeacherGroups WHERE F_UserID=?", array($user->id));
		$this->db->Execute("DELETE FROM T_ExtraTeacherGroups WHERE F_UserID=?", array($user->userID));
		
		// Add the new ones
		foreach ($groupsArray as $group) {
			$dbObj = array();
			// v3.4 Multi-group users
			//$dbObj['F_UserID'] = $user->id;
			$dbObj['F_UserID'] = $user->userID;
			$dbObj['F_GroupID'] = $group->id;
			$this->db->AutoExecute("T_ExtraTeacherGroups", $dbObj, "INSERT");
		}
		
		$this->db->CompleteTrans();
		
		return true;
	}
	
	/**
	 * This is link a teacher to a group through the extra groups table
	 */
	function addTeacherToExtraGroup($teacher, $group) {
		$existingGroupIDs = $this->getExtraGroups($teacher->userID);
		$existingGroupIDs[] = $group->id;
		
		// Loop through a distinct list of these groupIDs
		// TODO. You have to do an extra bit to get an array of groups as getExtraGroups only returns IDs
		$existingGroups = array();
		foreach (array_unique($existingGroupIDs) as $groupID) {
			$existingGroups[] = $this->getGroup($groupID);
		}
		
		return $this->setExtraGroups($teacher, $existingGroups);
	}
	
	// gh#1424 Function that gets all manageables for a root
	function getAllManageablesFromRoot() {
	    $rootId = Session::get('rootID');
	    
	    // First get all the groups in this root
	    $onlyGroups = true;
        $manageables = $this->getManageables(array(Session::get('rootGroupID')), false, true, $onlyGroups);
        	    
	    // Then get all the users from the root in the membership table, organised by groupID
	    $sql = <<<"SQL"
	    SELECT u.*, m.F_GroupID from T_User u, T_Membership m
	    WHERE u.F_UserID = m.F_UserID
	    AND m.F_RootID = ?
	    ORDER BY m.F_GroupID ASC, u.F_UserType ASC, u.F_UserName DESC
SQL;
	    $bindingParams = array($rootId);
	    $usersRS = $this->db->Execute($sql, $bindingParams);
        // Is it more efficent to get all the records into a simple array now, or to use the recordSet for looping many times?
        // Try to make an array keyed on the group id so easy to grab the users later
        $users = array();
        while ($userObj = $usersRS->FetchNextObj()) {
            $groupId = $userObj->F_GroupID;
            // gh#1424 Do I need this here?
            AuthenticationOps::addValidGroupIds(array($groupId));
            $user = $this->_createUserFromObj($userObj);
            // v3.3 Multi-group users.
            $user->id = (string)$groupId.'.'.$user->userID;
            $users[$groupId][] = $user;
        }

	    // Now go through each group in the manageables tree and add in the the users extracted from the recordset
	    $this->_addUsersToManageable($manageables[0], $users);

        return $manageables;
	}
	
	private function _addUsersToManageable($group, $users) {
        if (get_class($group) == "Group") {
            $thisGroupID = $group->id;

            // Recurse on any subgroups
            foreach ($group->manageables as $manageable)
                if (get_class($manageable) == "Group")
                    $this->_addUsersToManageable($manageable, $users);

            // Are there any users in this group?
            $atEnd = true;
            if (isset($users[$thisGroupID])) {
				$group->addManageables(array_reverse($users[$thisGroupID]), $atEnd);
				AuthenticationOps::addValidUserIds($group->getSubUserIds());
			}
	    }
        return $group->manageables;
	}
	
	function getAllManageables($onlyGroups = false) {
		// Get manageables for all the given groups.  If $onlyGroups is set (i.e. only get groups) then do not store authentication details or we end up with no
		// validated users in the session and we can't use any functions.
		return $this->getManageables(Session::get('groupIDs'), false, !$onlyGroups, $onlyGroups);
	}
	
	/*
	 * This returns an array of Manageable trees
	 *
	 * @param groupIDArray The root groups to begin each tree from
	 * @param authenticate Whether or not to authenticate the given group IDs
	 * @param storeIDs Whether or not to store the retrieved group and user ids.  This is used in authentication and should only be
	 *                 true when we are retrieving the entire tree for the logged in user (i.e. from getAllManageables) or this might
	 * 				   result in unexpected behaviour.
	 */
	function getManageables($groupIDArray, $authenticate = true, $storeIDs = false, $onlyGroups = false) {
		// Ensure that the logged in user has permission to access this group
		if ($authenticate) AuthenticationOps::authenticateGroupIDs($groupIDArray);
		
		if ($storeIDs) {
			AuthenticationOps::clearValidUsersAndGroups();
			AuthenticationOps::addValidGroupIds($groupIDArray); // The given groups are automatically valid
		}
		
		$manageables = array();
		
		foreach ($groupIDArray as $groupID) {
			// To begin the recursion we need to initially get the root node
			$sql  = "SELECT ".Group::getSelectFields($this->db);
			$sql .= <<<EOD
					FROM T_Groupstructure g
					WHERE F_GroupID=?;
EOD;

			// Perform the query and create a Group object from the results
			$rootGroupRS = $this->db->Execute($sql, array($groupID));
			
			$rootGroup = $this->_createGroupFromObj($rootGroupRS->FetchNextObj());
			
			$rootGroup->addManageables($this->_getManageables($rootGroup, $onlyGroups));
			
			if ($storeIDs) {
				AuthenticationOps::addValidUserIds($rootGroup->getSubUserIds());
				AuthenticationOps::addValidGroupIds($rootGroup->getSubGroupIds());
			}

			$manageables[] = $rootGroup;
		}
		
		return $manageables;
	}

	/*
	 * Recursive function to generate a tree of manageables from a given root group node.
	 */
	private function _getManageables($group, $onlyGroups = false) {
		$result = array();

		// gh#1424 pass down the onlyGroups
		$childrenArray = $this->_getChildrenOfGroups($group, $onlyGroups);
		$groupsRS = $childrenArray["groups"];
		
		// Add the groups
		if ($groupsRS->RecordCount() > 0) {
			while ($childGroupObj = $groupsRS->FetchNextObj()) {
			    // gh#1275 Check that you are not adding a group into itself
			    if ($childGroupObj->F_GroupID != $group->id) {
    				$childGroup = $this->_createGroupFromObj($childGroupObj);
    				$childGroup->addManageables($this->_getManageables($childGroup, $onlyGroups));
    				$result[] = $childGroup;
			    }
			}
		}

		// Add the users
		if (!$onlyGroups) {
		    $usersRS = $childrenArray["users"];
		    if ($usersRS->RecordCount() > 0) {
				while ($userObj = $usersRS->FetchNextObj()) {
					$user = $this->_createUserFromObj($userObj);
					// v3.3 Multi-group users.
					$user->id = (string)$group->id.'.'.$user->userID;
					$group->addManageables(array($user));
				}
			}
		}

		return $result;
	}

	// v3.4 For EditedContent I want to be able to work from the root group down to my group
	// So I need to know the parents of my group. Which I don't read in the normal course of events.
	// Maybe this should be a method of a group, but I think I am going to call it as part of login, rather
	// than as part of getManageables (which usually starts at my group and goes down).
	// This is a very simple recursion doing multiple SQL calls. But group structures are never going to get very deep
	// and any kind of recursive SQL call tends to be DBMS specific (and complicated to write/maintain).
	// We should make a call like this a standard part of all logins. Orchid and Arthur too.
	public function getGroupParents($startGroupID) {
		//error_log("RM session rootID=".Session::get('rootID')."\r\n", 3, $GLOBALS['logs_dir']."RMOps_error.log");

		$result = array();
		$groupID = $startGroupID;
		//echo "getParentGroups=".$startGroupID." dbHost=".$_SESSION['dbHost'];
		//echo $GLOBALS['db'];
		$keepGoingUp = true;
		do {
			$result[] = $groupID;
			$sql = <<<EOD
					SELECT F_GroupParent as parentID
					FROM T_Groupstructure
					WHERE F_GroupID=?
EOD;
			//echo $sql.",$groupID";
			$groupRS = $this->db->Execute($sql, array($groupID));
			//error_log("groupID=$groupID, type=".gettype($groupID).", records=".$groupRS->RecordCount(), 3, "/tmp/RMOps_error.log");
			if ($groupRS) {
			//if ($groupRS->RecordCount()==1) {
				$parentGroupID = $groupRS->FetchNextObj()->parentID;
			} else {
				// If, for some reason, you don't get any records, things are desperate and you should crash out
				throw new Exception("Your group doesn't exist ($groupID)");
			}
			// Have we found the root group?
			//echo "groupID=$groupID and parentGroupID=".$parentGroupID;
			if ($groupID == $parentGroupID) {
				$keepGoingUp = false;
			} else {
				$groupID = $parentGroupID;
			} 
		} while ($keepGoingUp);
		
		return $result;
	}
	
	/**
	 * Get the parent group id.
	 */
	public function getGroupParent($startGroupID) {
		$sql = <<<EOD
				SELECT F_GroupParent as parentID
				FROM T_Groupstructure
				WHERE F_GroupID = ?
				AND F_GroupParent <> F_GroupID
EOD;
		
		$groupObjs = $this->db->getArray($sql, array($startGroupID));
		return (sizeof($groupObjs) == 0) ? null : $groupObjs[0]['parentID'];
	}
	
	// This to just try and quickly get subgroups from SQL
	public function getGroupSubgroups($startGroupID) {
		$subGroupIDs = array($startGroupID);
		$sql = <<<EOD
				SELECT F_GroupID
				FROM T_Groupstructure
				WHERE F_GroupParent = ?
				AND F_GroupParent <> F_GroupID
EOD;
		$groupRS = $this->db->Execute($sql, array($startGroupID));
		if ($groupRS->recordCount() > 0) {		
			foreach ($groupRS->GetArray() as $group) {
				$subGroupIDs = array_merge($subGroupIDs, $this->getGroupSubgroups($group['F_GroupID']));
			}
		}
		
		return $subGroupIDs;
	}
	
	// Count the users in these groups
	public function countUsersInGroup($groupsArray) {
		// Get all subgroup IDs
		$subGroupsArray = array();
		foreach ($groupsArray as $groupID) {
			$subGroupsArray = array_merge($subGroupsArray, $this->getGroupSubgroups($groupID));
		}
		
		// Assume that the array is flat, turn it into a list for SQL
		$groupList = implode(',', $subGroupsArray);
		$sql = <<<EOD
				SELECT COUNT(u.F_UserID) as UserCount
				FROM T_User u, T_Membership m
				WHERE m.F_GroupID in ($groupList)
				and m.F_UserID = u.F_UserID
EOD;
		$groupRS = $this->db->Execute($sql, array());
		if ($groupRS) {
			return $groupRS->FetchNextObj()->UserCount;
		} else {
			return 0;
		}
	}
	
	private function _getChildrenOfGroups($group, $onlyGroups = false) {
		// RootID is not set by DMS, and is not necessary in this function anyway
		//$rootID = Session::get('rootID');
		$groupID = $group->id;
		
		if (strlen($groupID) == 0) return array("groups" => new ADORecordSet_empty(), "users" => new ADORecordSet_empty());

		// Get all the groups.  We need to explicitly check that the groupID isn't in the $groupIDs.
		// v3.5 I want the groups to display ordered by name.
		// v3.6.2 This is a slow query in MySQL. Why do we need DISTINCT? Should we index in F_GroupParent too?
		//$sql  = "SELECT DISTINCT ".Group::getSelectFields($this->db);
		// gh#1275 Let the calling loop get rid of the self-referencing group
		$sql  = "SELECT ".Group::getSelectFields($this->db);
		$sql .= <<<EOD
				FROM T_Groupstructure g
				WHERE g.F_GroupParent=?
				ORDER BY g.F_GroupParent, g.F_GroupName ASC
EOD;
		$groupsRS = $this->db->Execute($sql, array($groupID));

		// gh#1424
		if (!$onlyGroups) {
    		// Now get all the users in this group
    		// AR Why are we adding root to this query? Ha ha, especially as DMS doesn't use or set this session variable!
    		//		AND m.F_RootID=?
    		$sql  = "SELECT DISTINCT ".User::getSelectFields($this->db);
    		$sql .= <<<EOD
    				FROM T_User u, T_Membership m
    				WHERE u.F_UserID=m.F_UserID
    				AND m.F_GroupID=?
    				AND u.F_UserType>=?
    				ORDER BY u.F_UserType ASC, u.F_UserName DESC
EOD;
		
    		// Special functionality for RM.  If Session::get('no_students') is set then get users with type > 1 (i.e. not learners) otherwise > 0 (all)
    		$userTypeMinimum = (Session::get('no_students')) ? 1 : 0;
    		$usersRS = $this->db->Execute($sql, array($groupID, $userTypeMinimum));
		} else {
		    $usersRS = null;
		}
		return array("groups" => $groupsRS, "users" => $usersRS);
	}

	/*
	 * This method creates a new Group from an AdoDB object returned by FetchNextObject()
	 */
	private function _createGroupFromObj($groupObj) {
		$group = new Group();
		$group->fromDatabaseObj($groupObj);
		return $group;
	}

	/*
	 * This method creates a new User from an AdoDB object returned by FetchNextObject()
	 */
	private function _createUserFromObj($userObj) {
		$user = new User();
		$user->fromDatabaseObj($userObj, $this->db); // fromDatabaseObj needs the AdoDB connection object too in order to process dates
		// v3.4 Multi-group users.
		// Can't do this here because it might be an isolated user, not attached to a group yet
		//$user->id = $user->getIDForIDObject();
		return $user;
	}
	
	/**
	 * Determine if the details you know about a new/updated user conflict with any existing user.
	 * Returns false if no conflicts
	 * 			loginOption and array of conflicted users if found
	 * 			returnCode=loginOption
	 * 			conflictedUsers=array of user objects
	 * 
	 * gh#653 replaces isUserValid 
	 */
	private function isUserConflicted($user, $rootID = null, $loginOption = null) {
		$rootID = ($rootID) ? $rootID : Session::get('rootID');
		$loginOption = ($loginOption) ? $loginOption : Session::get('loginOption');
		$groupedRoots = Session::get('groupedRoots');

		if ($loginOption && $loginOption > 0) {
		} else {
			// v3.6.1 Check Access Control
			$sql = 	<<<EOD
					SELECT F_LoginOption as loginOption
					FROM T_AccountRoot
					WHERE F_RootID=?
EOD;
			$rs = $this->db->Execute($sql, array($rootID));
			switch ($rs->RecordCount()) {
				case 0:
					throw new Exception("No account with this root ($rootID)");
					break;
				case 1:
					$loginOption = (int)($rs->FetchNextObj()->loginOption);
					break;
				default:
					throw new Exception("More than one account with this root ($rootID)");
			}
		}
		Session::set('loginOption', $loginOption);

		// There may be no groupedRoots, a single one, a list or a wildcard.
		if (!$groupedRoots) {
			// v3.6.1 Check T_LicenceAttributes - for now just to get groupedRoots
			$sql = 	<<<EOD
					SELECT *
					FROM T_LicenceAttributes
					WHERE F_RootID=?
EOD;
			$rs = $this->db->Execute($sql, array($rootID));
			$groupedRoots = 'none';
			if ($rs->RecordCount() > 0) {
				while($record = $rs->FetchNextObj()) {
					// For now all I care about is groupedRoots.
					if ($record->F_Key == 'groupedRoots') {
						// at least check that this is not empty or spaces
						if ($record->F_Value && trim($record->F_Value)!='')
							$groupedRoots = trim($record->F_Value);
						break;
					}
				}
			}
			Session::set('groupedRoots', $groupedRoots);
		}
		if ($groupedRoots != 'none') {
			$rootList = $groupedRoots;
		} else {
			$rootList = $rootID;
		}
		
		// TODO. Can we parse the root list to make sure it is a valid list of commma delimited roots?
		if ($rootList == '*') {
			$rootClause = '';
		} elseif (stripos($rootList, ',') === FALSE) {
			$rootClause = " AND m.F_RootID = $rootList";
		} else {
			$rootClause = " AND m.F_RootID IN ($rootList)";
		}
		
		// Check the key value for uniqueness and presence based on loginOption
		if ($loginOption & User::LOGIN_BY_NAME) {
			if (!$user->name) {
				$rc['returnCode'] = $loginOption;
				return $rc;
			}
			$checkClause = ' AND u.F_UserName = ? ';
			$bindingParams = array($user->name);
		} elseif ($loginOption & User::LOGIN_BY_ID) {
			if (!$user->studentID) {
				$rc['returnCode'] = $loginOption;
				return $rc;
			}
			$checkClause = ' AND u.F_StudentID = ? ';
			$bindingParams = array($user->studentID);
		} elseif ($loginOption & User::LOGIN_BY_NAME_AND_ID) {
			throw new Exception("Using old login option of name AND id ($rootID)");
		} elseif ($loginOption & User::LOGIN_BY_EMAIL) {
			if (!$user->email) {
				$rc['returnCode'] = $loginOption;
				return $rc;
			}
			$checkClause = ' AND u.F_Email = ? ';
			$bindingParams = array($user->email);
		} else {
			throw new Exception("Unknown login option, $loginOption, for root $rootID");
		}
			
		$sql  = "SELECT ".User::getSelectFields($this->db).", m.F_GroupID";
		$sql .= <<<EOD
			FROM T_User u, T_Membership m
			WHERE u.F_UserID = m.F_UserID
			$rootClause
			$checkClause
EOD;
		$rs = $this->db->Execute($sql, $bindingParams);

		$rc['returnCode'] = 0;
		switch ($rs->RecordCount()) {
			case 0:
				// There are no duplicates
				break;
			case 1:
			default:
				// There is a duplicate(s), but if this is an update it might be the same user
				while ($dbObj = $rs->FetchNextObj()) {
					if ((int)($dbObj->F_UserID) != (int)($user->userID)) {
						// Found a conflict - return the user in case you need it for copy, move, delete
						$rc['returnCode'] = $loginOption;
						$cU = new User();
						$cU->fromDatabaseObj($dbObj);
						$rc['conflictedUsers'][] = $cU; 
					}
				}
		}
		
		return $rc;
	}

	/**
	 * Determine if a user is valid.  A user is valid (i.e. can be updated / created) if no user with the same name exists in this
	 * rootID context. Administrator users are a special case - these have to have username / password unique across every root.
	 * This isn't quite the whole picture as some titles (like Its Your Job) will have a login page that needs a unique login - for which
	 * we plan to use email.
	 * v3.6.1 It is also flawed for cases where the Access Control is based on studentID, because that should be unique too.
	 *	We need loginOptions to know this - either it has to be sent with addUser / importUsers or we need another call here.
	 *	Probably simpler to get it again here.
	 * v3.6.1.1 Also at HCT you need ID to be unique across all roots. You can pick this up from groupedRoots in T_LicenceAttributes
	 */
	private function isUserValid($user, $newRootID = null) {
		//v3.1 Need to pass rootID as it may not be in session variables for DMS (addAccount)
		$rootID = ($newRootID) ? $newRootID : Session::get('rootID');
		// AR Do we really have to encode quotes? It would match the std better if the db had ' not &apos;
		//$username = Manageable::apos_encode($user->name);
		
		// v3.6.1 Check Access Control
		$sql = 	<<<EOD
				SELECT F_LoginOption as loginOption
				FROM T_AccountRoot
				WHERE F_RootID=?
EOD;
		$rs = $this->db->Execute($sql, array($rootID));
		switch ($rs->RecordCount()) {
			case 0:
				throw new Exception("No account with this root ($rootID)");
				break;
			case 1:
				$loginOption = (int)($rs->FetchNextObj()->loginOption);
				break;
			default:
				throw new Exception("More than one account with this root ($rootID)");
		}
		Session::set('loginOption',$loginOption);
		
		// v3.6.1 Check T_LicenceAttributes - for now just to get groupedRoots
		// TODO This is ridiculous to call it here, it should be passed to here. Likewise loginOption.
		$sql = 	<<<EOD
				SELECT *
				FROM T_LicenceAttributes
				WHERE F_RootID=?
EOD;
		$rs = $this->db->Execute($sql, array($rootID));
		// Expecting many attributes. 
		// There may be no groupedRoots, a single one, a list or a wildcard.
		$rootList = $rootID;
		if ($rs->RecordCount() > 0) {
			while($record = $rs->FetchNextObj()) {
				// For now all I care about is groupedRoots.
				if ($record->F_Key == 'groupedRoots') {
					// at least check that this is not empty or spaces
					if ($record->F_Value && trim($record->F_Value)!='') {
						$rootList = trim($record->F_Value);
					}
					break;
				}
			}
		}
		// TODO. Can we parse the root list to make sure it is a valid list of commma delimited roots?
		if ($rootList!='*') {
			$rootClause = " AND m.F_RootID in ($rootList)";
		} else {
			$rootClause = '';
		}
		
		// gh#98.1
		// Sky/AR If we always block duplicate emails, it means that ORS can't use ID login and pass duplicate emails
		// which the Indian agents insist on doing.
		
		// gh#653 Tidy up the checking into one section
		switch ($loginOption) {
			case User::LOGIN_BY_NAME:
				$checkClause = ' AND u.F_UserName = ? ';
				$bindingParams = array($user->name);
				break;
			case User::LOGIN_BY_ID:
				$checkClause = ' AND u.F_StudentID = ? ';
				$bindingParams = array($user->studentID);
				break;
			case User::LOGIN_BY_NAME_AND_ID:
				throw new Exception("Using old login option of name AND id ($rootID)");
				break;
			case User::LOGIN_BY_EMAIL:
			default:
				$checkClause = ' AND u.F_Email = ? ';
				$bindingParams = array($user->email);
				break;
		}
			
		$sql = <<<EOD
				SELECT distinct(u.F_UserID) as userID, u.F_UserName, u.F_StudentID, m.F_GroupID
				FROM T_User u, T_Membership m
				WHERE u.F_UserID = m.F_UserID
				$rootClause
				$checkClause
EOD;
		$rs = $this->db->Execute($sql, $bindingParams);
			
		switch ($rs->RecordCount()) {
			case 0:
				// There are no duplicates
				$checkOK = true;
				break;
			case 1:
			default:
				// There is a duplicate(s), but if this is an update it might be the same record
				$checkOK = true;
				while ($dbObj = $rs->FetchNextObj()) {
					if ((int)($dbObj->userID) != (int)($user->userID)) {
						$checkOK = false;
						$rc['returnInfo'][] = Array('name' => $record->F_UserName, 'email' => $record->F_Email, 'studentID' => $record->F_StudentID, 'group' => $record->F_GroupID);
					}
				}
		}
		
		// You need to be able to return different info for different failures
		if (!$checkOK)
			$rc['returnCode'] = $loginOption;
			
		return $rc;
	}
	
	
	/**
	 * This returns a specific database feedback selected from a given user email, user of licencetype 5 is excluded
	 * Dicky's implementation on 8 Jan 2013
	 */
	function getUserByEmail($stubUser) {

		$key = $stubUser->email;
		$sql = <<<EOD
				SELECT DISTINCT u.F_UserID, u.F_Password, u.F_Email, a.F_LicenceType
				FROM T_User u
				JOIN T_Membership m ON u.F_UserID = m.F_UserID 
				JOIN T_Accounts a ON m.F_RootID = a.F_RootID 
				WHERE u.F_Email = ?
				AND a.F_LicenceType <> 5
EOD;

	// change that back to 5
		$usersRS = $this->db->Execute($sql, array($key));
		// How can we use AuthenticationOps to make sure that the logged in teacher has rights over this user?
		// #341 There might not be a teacher
		//AuthenticationOps::authenticateUsers(array($user));
		return $usersRS;
	}

	/**
	 * Get the account that a user is in
	 * 
	 */
	public function getAccountFromUser($user) {
		$key = $user->userID;
		
		$sql = <<<EOD
				SELECT a.*
				FROM T_Membership m, T_AccountRoot a
				WHERE m.F_RootID = a.F_RootID 
				AND m.F_UserID = ?
EOD;

		$rs = $this->db->Execute($sql, array($key));
		$recordCount = $rs->RecordCount();
		
		switch ($recordCount) {
			case 1:
				$dbObj = $rs->FetchNextObj();
				$account = new Account();
				$account->fromDatabaseObj($dbObj);
				return $account;
				break;
			default:
				return null;
		}
	}
	
	/**
	 * This will either find the user, or will add a new one
	 * 
	 * @param User $stubUser
	 */
	public function getOrAddUser($stubUser, $rootId, $groupId, $loginOption = User::LOGIN_BY_EMAIL) {
		
		$users = $this->getUserFromEmail($stubUser->email);
		if (!$users) {
			$group = new Group();
			$group->id = $groupId;
			$users = array($this->addUser($stubUser, $group, $rootId, $loginOption));
		}
		
		return $users[0];
	}

    /**
     * Anonymize a user without removing them
     *
     */
    public function anonymizeUser($user) {
        $user->email = $this->anonymized($user->email, 'e');
        $user->name = $this->anonymized($user->name, 'n');
        $user->studentID = $this->anonymized($user->studentID, 'i');
        return $this->updateUsers(array($user));
    }
    public function anonymized($data, $type = null) {
        $base = new DateTime();
        $buildString = $base->getTimestamp().mt_rand();
        if ($type)
            $buildString = $type.$buildString;
        return $buildString;
    }
}

