<?php
class ManageableOps {

	var $db;

	function ManageableOps($db) {
		$this->db = $db;
		
		$this->copyOps = new CopyOps();
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
			foreach ($parentGroup->manageables as $manageable) 
				if (strtolower($manageable->name) == strtolower($group->name))
					return $manageable;
		}
		
		// Set the parent id (from $parentGroup) and write the new record to the database
		$dbObj = $group->toAssocArray();
		$dbObj['F_GroupParent'] = ($parentGroup) ? $parentGroup->id : 0;
		$this->db->AutoExecute("T_Groupstructure", $dbObj, "INSERT");
		
		// Add the auto-generated id to the original group object
		$group->id = $this->db->Insert_ID();
		
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
				NetDebug::trace("addGroupHierarchy, added all that I need to");
				return $newGroup;
			} else {
				NetDebug::trace("addGroupHierarchy, keep going after adding new one");
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
	function addUser($user, $parentGroup, $rootID = null) {
		// Ensure that this user has permission to access the parent group
		AuthenticationOps::authenticateGroups(array($parentGroup));
		
		// v3.1 Need to pass rootID as it may not be in session variables (DMS)
		// v3.6.1 Also checking for studentID, so return is a binary flag
		//if (!$this->isUserValid($user, $rootID)) {
		$rc = $this->isUserValid($user, $rootID);
		//NetDebug::trace('addUser rc='.$rc['returnCode']);
		// v3.6.1 More, this now returns full information if it is NOT a valid user
		//if ($rC>0) {
		if ($rc['returnCode']>0) {
			// This user cannot be added (probably because it does not have a unique username in this root context)
			// TODO: AR We should allow unique ID as an option. Kind of complex!
			// Now we are checking studentID if that is the loginOption. So how to give a good error message?
			// And it would be really good if we could tell which group the existing user was in to help sort out the problem.
			// Perhaps I could get back an object from isUserValid {name, id, group) with items only set if they clash.
			// I wonder if we ought to be checking for duplicate emails too?
			// Hijack the exception code to send back the groupID. I don't like it one little bit.
			if (($rc['returnCode'] & 1) && ($rc['returnCode'] & 2)) {
				//NetDebug::trace('so generate name and studentID exception for group '.$rc['returnInfo'][0]['group']);
				// both name and ID are duplicates
				throw new Exception($this->copyOps->getCopyForId("usernameAndIDExistsError", array("username" => $user->name, "studentID" => $user->studentID))
									, $rc['returnInfo'][0]['group']);
			} elseif ($rc['returnCode'] & 2) {
				//NetDebug::trace('so generate studentID exception for group '.$rc['returnInfo'][0]['group']);
				// just the ID is duplicated
				throw new Exception($this->copyOps->getCopyForId("studentIDExistsError", array("studentID" => $user->studentID))
									, $rc['returnInfo'][0]['group']);
			} else {
				//NetDebug::trace('so generate name exception for group '.$rc['returnInfo'][0]['group']);
				// assume any other error is the name
				throw new Exception($this->copyOps->getCopyForId("usernameExistsError", array("username" => $user->name))
									, $rc['returnInfo'][0]['group']);
			}
		}
		
		// Check this doesn't exceed the MAX_userType for teachers, authors and reporters
		if (!$this->canAddUsersOfType($user->userType, 1))
			throw new Exception($this->copyOps->getCopyForId("exceedsMaximumUserTypeError"));
		
		// First create the user
		//NetDebug::trace('addUser name='.$user->name.' expire='.$user->expiryDate.' type='.$user->userType);
		$dbObj = $user->toAssocArray();
		//NetDebug::trace('sql expire='.$dbObj['F_ExpiryDate']);
		
		$this->db->StartTrans();
		
		$this->db->AutoExecute("T_User", $dbObj, "INSERT");
		
		// Add the auto-generated id to the original group object
		// v3.4 Multi-group users
		//$user->id = $this->db->Insert_ID();
		$user->userID = $this->db->Insert_ID();
		$user->id = (string)$parentGroup->id.'.'.$user->userID;
		
		// Now insert a record in the group membership table to say which parent group the user belongs to
		$dbObj = array();
		// v3.4 Multi-group users
		//$dbObj['F_UserID'] = $user->id;
		$dbObj['F_UserID'] = $user->userID;
		$dbObj['F_GroupID'] = $parentGroup->id;
		$dbObj['F_RootID'] = ($rootID) ? $rootID : Session::get('rootID'); // If root id is given then use that (for DMS), otherwise use the session root
		$this->db->AutoExecute("T_Membership", $dbObj, "INSERT");
		
		$this->db->CompleteTrans();
		
		// Add this to the valid user for the logged in user
		// v3.4 Multi-group users
		//AuthenticationOps::addValidUserIDs(array($user->id));
		AuthenticationOps::addValidUserIDs(array($user->userID));
		
		// Return the newly created user object
		return $user;
	}
	
	/*
	 * Move $user to $parentGroup where user is an instance of User and $parentGroup is an instance of Group
	 */
	function moveAndUpdateUser($userDetails, $parentGroup, $rootID = null) {
		// Ensure that this user has permission to access the parent group
		AuthenticationOps::authenticateGroups(array($parentGroup));
		NetDebug::trace('ManageableOps.moveUser move='.$userDetails->name);
		
		// You should only call this function if you know the user exists, but you still need to get their userID
		// If this function fails, generate an exception
		// v3.6 But you don't know that this user has a unique learnerID!
		// And some DMS stuff doesn't use this at all
		if (Session::is_set('loginOption')) {
			$loginOption = Session::get('loginOption');
		}
		if ($loginOption==2) {
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
		$this->db->StartTrans();
		
		// Update the existing user details - can only do specific fields for now. In fact, just email for now
		$updateRequired = false;
		//NetDebug::trace('ManageableOps.updateUser new email ='.$userDetails->email);
		if (isset($userDetails->email) && ($user->email != $userDetails->Eemail)) {
			$user->email = $userDetails->email;
			$updateRequired = true;
		}
		if ($updateRequired) {
			NetDebug::trace('ManageableOps.updateUser update him first='.$user->name);
			// Update the user record
			$this->db->AutoExecute("T_User", $user->toAssocArray(), "UPDATE", "F_UserID=".$user->userID);
		}
		
		// Then remove the current membership record(s)
		// TODO Actually you should just be using moveManageables here!
		//NetDebug::trace('ManageableOps.deleted old membership');
		$this->db->Execute("DELETE FROM T_Membership WHERE F_UserID =".$user->userID);
		
		// Then insert a record in the group membership table to say which parent group the user now belongs to
		$dbObj = array();
		$dbObj['F_UserID'] = $user->userID;
		$dbObj['F_GroupID'] = $parentGroup->id;
		$dbObj['F_RootID'] = ($rootID) ? $rootID : Session::get('rootID'); // If root id is given then use that (for DMS), otherwise use the session root
		$this->db->AutoExecute("T_Membership", $dbObj, "INSERT");
		//NetDebug::trace('ManageableOps.add new membership to group='.$parentGroup->id);
		
		$this->db->CompleteTrans();
		
		// Return the moved user object
		return $user;
	}
	/*
	 * Check that the email address you want to add for a user is unique.
	 * When there was just one product, IYJ, that was sold individually you could check unique email
	 * based on that. But now we could check based on licence type?
	 */
	//function checkUniqueEmail($email) {
	function checkUniqueEmail($email, $licenceType=5) {
		
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
	/*
	 * Return the user's details if the email address matches.
	 * When there was just one product, IYJ, that was sold individually you could check unique email
	 * based on that. But now we could check based on licence type?
	 */
	//function getUserFromEmail($email, $pc) {
	function getUserFromEmail($email, $licenceType) {
		
		// Ensure the username is unique within this context
		//		AND t.F_ProductCode=?
		// I will get one row for each account that this user has, so make sure we measure distinct ones
		//$sql  = "SELECT ".User::getSelectFields($this->db);
		$sql  = "SELECT DISTINCT ".User::getSelectFields($this->db);
		$sql .= <<<EOD
				FROM T_User u 
				JOIN T_Membership m ON u.F_UserID = m.F_UserID 
				JOIN T_Accounts t ON m.F_RootID = t.F_RootID 
				WHERE u.F_Email = ?
				AND t.F_LicenceType = ?
EOD;
		$rs = $this->db->Execute($sql, array($email, $licenceType));
		//echo $sql;
		switch ($rs->RecordCount()) {
			case 0:
				// There are no records
				return false;
			case 1:
				// Found just one record, so return it as a user object
				$userObj = $rs->FetchNextObj();
				$user = $this->_createUserFromObj($userObj);
				return Array($user);
			default:
				// There is more than one user with this email address in this context
				// What can we tell the learner?
				$users = Array();
				while ($userObj = $rs->FetchNextObj())
					$users[] = $this->_createUserFromObj($userObj);
				return $users;
		}
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
	function updateUsers($usersArray, $rootID=null) {
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
			//if (!$this->isUserValid($user)) {
			//	// This user cannot be added (probably because it does not have a unique username in this root context)
			//	throw new Exception($this->copyOps->getCopyForId("usernameExistsError", array("username" => $user->name)));
			//}
			// v3.6.1 More info comes back for users that you can't add
			$rC = $this->isUserValid($user, $rootID);
			//NetDebug::trace('updateUser rC='.$rC['returnCode']);
			//if ($rC>0) {
			if ($rC['returnCode']>0) {
				// This user cannot be added (probably because it does not have a unique username in this root context)
				// TODO: AR We should allow unique ID as an option. Kind of complex!
				// Now we are checking studentID if that is the loginOption. So how to give a good error message?
				$rcType = $rC['returnCode'];
				if (($rcType & 1) && ($rcType & 2)) {
					// both name and ID are duplicates
					throw new Exception($this->copyOps->getCopyForId("usernameAndIDExistsError", array("username" => $user->name, "studentID" => $user->studentID)));
				} elseif ($rcType & 2) {
					// v3.6.1.1 Messy but... If the account is set for login with ID, there is every chance that the admin user
					// will not have an ID. But that will probably stop them being updated when the account is updated.
					// So lets ignore admin users at this point. Teachers too? Best not.
					if ($user->userType == User::USER_TYPE_ADMINISTRATOR || $user->userType == User::USER_TYPE_DMS) {
					} else {
						// just the ID is duplicated
						throw new Exception($this->copyOps->getCopyForId("studentIDExistsError", array("studentID" => $user->studentID)));
					}
				} else {
					// assume any other error is the name
					throw new Exception($rcType.' '.$this->copyOps->getCopyForId("usernameExistsError", array("username" => $user->name)));
				}
			}
			
			// v3.4 Multi-group users
			//$this->db->AutoExecute("T_User", $user->toAssocArray(), "UPDATE", "F_UserID=".$user->id);
			$this->db->AutoExecute("T_User", $user->toAssocArray(), "UPDATE", "F_UserID=".$user->userID);
		}
		
		$this->db->CompleteTrans();
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
	
	function moveUsers($usersArray, $parentGroup) {
		if (sizeof($usersArray) == 0) return;
		
		// Ensure that this root context has permission to access all these users
		AuthenticationOps::authenticateUsers($usersArray);
		
		// Ensure that this root context has permission to access all these groups
		AuthenticationOps::authenticateGroups(array($parentGroup));
		
		$this->db->StartTrans();
		
		$userIdArray = array();
		foreach ($usersArray as $user)
			// v3.4 Multi-group users
			//$userIdArray[] = $user->id;
			$userIdArray[] = $user->userID;
		
		$userIdInString = join(",", $userIdArray);
		
		$this->db->Execute("UPDATE T_Membership SET F_GroupID=? WHERE F_UserID IN (".$userIdInString.")", array($parentGroup->id));
		
		$this->db->CompleteTrans();
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
			//NetDebug::trace('ManageableOps.dM id='.$manageable->id.' class='.get_class($manageable));
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
					
					// Get all the user IDs we need to delete. Same as above.
					$userIdArray = $manageable->getSubUserIds();
					NetDebug::trace('ManageableOps.deleteAccounts all users='.implode(",",$userIdArray));
					
					// Ensure that this root context has permission to access all these groups
					AuthenticationOps::authenticateGroupIDs($groupIdArray);
					NetDebug::trace('ManageableOps.deleteAccounts all groups='.implode(",",$groupIdArray));
					
					// Delete the groups
					$this->deleteGroupsById($groupIdArray);
					
					// Delete the users (note that we do not check if the user has permission because by this point rows have already
					// been deleted from T_Membership - however, unauthorised users will never be able to get to here without failing
					// the group authentication so this is fine).
					$this->deleteUsersById($userIdArray);
					
					break;
				case "User":
					//NetDebug::trace('ManageableOps.dM user='.$manageable->id);
					// Ensure that this root context has permission to access this user
					// v3.4 Multi-group users
					//AuthenticationOps::authenticateUserIDs(array($manageable->id));
					AuthenticationOps::authenticateUserIDs(array($manageable->userID));
					
					// Delete the user
					//$this->deleteUsersById(array($manageable->id));
					$this->deleteUsersById(array($manageable->userID));
					break;
			}
		}
		
		$this->db->CompleteTrans();
	}
	
	/**
	 * Given an array of group ids delete rows from all relevant tables
	 *
	 * @param groupIdArray An array of group ids to delete
	 */
	function deleteGroupsById($groupIdArray) {
		// If there are no ids in the array do nothing
		if (sizeof($groupIdArray) == 0) return;
		
		$groupIdInString = join(",", $groupIdArray);
		//NetDebug::trace('ManageableOps.deleteGroups sql id='.$groupIdInString);
		
		// Delete groups from the T_Groupstructure table
		$this->db->Execute("DELETE FROM T_Groupstructure WHERE F_GroupID IN ($groupIdInString)");
		//NetDebug::trace('ManageableOps.deleteGroups deleted '.$this->db->Affected_Rows());
		
		// Delete groups from the T_Membership table
		$this->db->Execute("DELETE FROM T_Membership WHERE F_GroupID IN ($groupIdInString)");
		
		// Delete entries for these groups in hidden content
		$this->db->Execute("DELETE FROM T_HiddenContent WHERE F_GroupID IN ($groupIdInString)");
	}
	
	/**
	 * Given an array of user ids delete rows from all relevant tables
	 *
	 * @param An array of user ids to delete
	 */
	function deleteUsersById($userIdArray) {
		// If there are no ids in the array do nothing
		if (sizeof($userIdArray) == 0) return;
		
		$userIdInString = join(",", $userIdArray);
		
		
		// Delete users from the T_User table
		$this->db->Execute("DELETE FROM T_User WHERE F_UserID IN ($userIdInString)");
		
		// Delete users from the T_Membership table
		$this->db->Execute("DELETE FROM T_Membership WHERE F_UserID IN ($userIdInString)");
		
		// Delete users from the T_Titlelicences table 
		// v3.0.5 (allocation, no longer used)
		//$this->db->Execute("DELETE FROM T_Titlelicences WHERE F_UserID IN ($userIdInString)");
		
		// Delete user records from the T_Score table
		$this->db->Execute("DELETE FROM T_Score WHERE F_UserID IN ($userIdInString)");
		
		// Delete user from the t_licences table
		// v6.5.5.0 The T_Licences table is dropped in favour of using T_Session.
		// So this clear out is unnecessary
		//$this->db->Execute("DELETE FROM t_licences WHERE F_UserID IN ($userIdInString)");
		
		// Delete user records from the t_session table? (NO - ADRIAN WANTS THIS KEPT FOR CLARITY RECORDS)
		//$this->db->Execute("DELETE FROM t_session WHERE F_UserID IN ($userIdInString)");
		
		// Delete user records from the t_failsession table? (NO - ADRIAN WANTS THIS KEPT FOR CLARITY RECORDS)
		//$this->db->Execute("DELETE FROM t_failsession WHERE F_UserID IN ($userIdInString)");
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
			$node = $group->toXMLNode();
			$manageablesXML->appendChild($dom->importNode($node, true));
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
	function importManageables($groups, $users, $parentGroup, $moveExistingStudents=false) {
		// Ensure that this root context has permission to access this parent group
		AuthenticationOps::authenticateGroups(array($parentGroup));
		
		// Export the manageables as XML
		$doc = $this->exportXML($groups, $users, true);
		
		// And import into the database.  When calling this function (i.e. from Excel pasting) we want to merge together groups.
		return $this->importXML($doc, $parentGroup, true, $moveExistingStudents);
	}
	
	/**
	 * Import the given XML document into parentGroup
	 * v3.6.1 Allow moving and importing
	 */
	function importXML($doc, $parentGroup, $mergeGroups = false, $moveExistingStudents = false) {
		// Create a parser and create the manageables tree from the xml
		$importXMLParser = new ImportXMLParser();
		$manageables = $importXMLParser->xmlToManageables($doc);
		
		// Now go through adding everything, building up the results in $this->importResults
		$this->importResults = array();
		
		foreach ($manageables as $manageable)
			$this->_importManageable($manageable, $parentGroup, $mergeGroups, $moveExistingStudents);
		
		// Sort the importResults on success so that the failure appear at the top
		usort($this->importResults, array(&$this, "successCmp"));
		
		// Return the results for display in the client
		return $this->importResults;
	}
	
	/**
	 * usort() function that orders import results failures first
	 */
	static function successCmp($a, $b) {
		if ($a["success"] == $b["success"]) return 0;
		return ($a["success"] == false && $b["success"] == true) ? 0 : 1;
	}
	
	// v3.6.1 Allow moving and importing
	//function _importManageable($manageable, $parentGroup, $mergeGroups = false) {
	function _importManageable($manageable, $parentGroup, $mergeGroups = false, $moveExistingStudents = false) {
		if (get_class($manageable) == "Group") {
			// v3.5 Allow group names to be hierarchies
			//NetDebug::trace("_importMgble $manageable->name");

			// This section checks that the group(s) exists and returns it
			if (stripos($manageable->name,"/")!==false) {				
				//NetDebug::trace("_importManageable check hierarchy");
				$parentGroup = $this->addGroupHierarchy($manageable->name, $parentGroup, !$mergeGroups);
				//NetDebug::trace("_importMgble, got back group $parentGroup->name and id=$parentGroup->id");
			} else {
				//NetDebug::trace("_importMgble check simple group");
				// When $mergeGroups is set duplicates are not allowed (it needs to merge into existing groups) so add parameter to addGroup
				$parentGroup = $this->addGroup($manageable, $parentGroup, !$mergeGroups);
			}
			$this->addImportResult("Group", $manageable->name, true);
			
			foreach ($manageable->manageables as $m) {
				$this->_importManageable($m, $parentGroup, $mergeGroups, $moveExistingStudents);
			}
			
		} else if (get_class($manageable) == "User") {
			try {
				// v3.5 If we want to allow importing to update users, then we need a different setup here
				// as well as needing a new parameter.
				// So first we could see if this is a new user (keyed on name or studentID).
				// If it is, then we can just go ahead and add them with addUser.
				// If we find the user exists, then we can update them. 
				// This might mean changing some details, though not the loginOption field (name or ID).
				// It might also mean changing the group that they are in.
				
				//NetDebug::trace("_importManageable adduser".$manageable->name." of type ".$manageable->userType);
				$this->addUser($manageable, $parentGroup);
				// TODO We should send back the different types of user - $manageable->userType? (convert number to string)
				// How to properly pick up the literals names for the types?
				//$this->addImportResult("User", $manageable->name, true);
				//$this->addImportResult($manageable->userType, $manageable->name, true);
				$typeName = $manageable->getTypeName();
				/*
				switch ($manageable->userType) {
					case User::USER_TYPE_TEACHER:
						$typeName = "Teacher";
						break;
					case User::USER_TYPE_REPORTER:
						$typeName = "Reporter";
						break;
					case User::USER_TYPE_AUTHOR:
						$typeName = "Author";
						break;
					default:
						$typeName = "Student";
				}
				*/
				//NetDebug::trace("_importManageable ".$manageable->name." of type ".$manageable->userType);
				// v3.6.1.1 This is a bad message if there is no expiry date.
				if ($manageable-> expiryDate != '') {
					$addedMsg = "expire on ".$manageable-> expiryDate;
				} else {
					$addedMsg = "added";
				}
				$this->addImportResult($typeName, $manageable-> name, true, $addedMsg);
			} catch (Exception $e) {
				//$this->addImportResult("User", $manageable->name, false, $e->getMessage());
				// There was an error adding this as a new user, so do you want to try to move/update them?
				// v3.6.1 Allowing moving and importing
				if ($moveExistingStudents) {
					NetDebug::trace("importing, ".$manageable->name." exists in group ".$e->getCode()." so try to move them to ".$parentGroup->id);
					try {
						// To avoid appearing to move any duplicated students who you don't really want to move, check groups first
						// TODO But how???
						// When we get an exception from addUser, can we include information about which group that user is already in?
						// Well, yes you can, but because you come back from addUser to here with an exception, you can't get the data.
						// I think that means that instead of trying addUser and picking up the exception, we have to call isUserValid first
						// and only then go to addUser (which will do the check again). Getting messy. 
						// I could hijack the exception code to use as the groupID...
						// Or is it worth doing another call here? I think not.
						// Again, this is flawed because you might want to just update the user (email) and not move them.
						if ($e->getCode() != $parentGroup->id) {
							$existingUser = $this->moveAndUpdateUser($manageable, $parentGroup);
							//NetDebug::trace("moved $existingUser->name");
							$typeName = $existingUser->getTypeName();
							//NetDebug::trace("got type $typeName");
							$this->addImportResult($typeName, $existingUser->name, true, "moved");
						} else {
							//NetDebug::trace("already in that group $manageable->name");
							// so show the error message
							$this->addImportResult($typeName, $manageable->name, false, $e->getMessage());
						}
					} catch (Exception $e) {
						//NetDebug::trace("exception of $e->getMessage()");
						$this->addImportResult($typeName, $manageable->name, false, $e->getMessage());
					}
				} else {
					$this->addImportResult($typeName, $manageable->name, false, $e->getMessage());
				}
			}
		}
	}
	
	private function addImportResult($type, $name, $success, $message = "") {
		$this->importResults[] = array("type" => $type,
									   "name" => $name,
									   "success" => $success,
									   "message" => $message);
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
	 * This returns a specific user object defined by its ID
	 */
	function getUserById($userID) {
		$users = $this->getUsersById(array($userID));
		if (isset($users[0]))
			return $users[0];
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
	 * This returns a specific user object defined by its studentID
	 */
	function getUserByLearnerId($user) {
		$sql  = "SELECT ".User::getSelectFields($this->db);
		$sql .= <<<EOD
				FROM T_User u
				WHERE u.F_StudentID=?
EOD;
		$usersRS = $this->db->Execute($sql, array($user->studentID));

		// If you don't get a unique match, throw an exception
		if ($usersRS->RecordCount()==1) {
			$userObj = $usersRS->FetchNextObj();
			$user = $this->_createUserFromObj($userObj);
		} else {
			throw new Exception("More than one user with this studentID ($user->studentID)");
		}
		
		// How can we use AuthenticationOps to make sure that the logged in teacher has rights over this user?
		AuthenticationOps::authenticateUsers(array($user));
		return $user;
	}
	// And an equivalent one by name
	function getUserByName($user) {
		$sql  = "SELECT ".User::getSelectFields($this->db);
		$sql .= <<<EOD
				FROM T_User u
				WHERE u.F_UserName=?
EOD;
		$usersRS = $this->db->Execute($sql, array($user->name));

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
	 * This returns the group ID that a given user belongs to.  At present this is only used by DMS, but it might come in useful for something
	 * later on so I've left it in here.
	 */
	function getGroupIdForUserId($userID) {
		$sql = <<<EOD
			   SELECT g.F_GroupID
			   FROM T_User u LEFT JOIN 
			   T_Membership m ON m.F_UserID = u.F_UserID LEFT JOIN
			   T_Groupstructure g ON m.F_GroupID=g.F_GroupID
			   WHERE u.F_UserID=?
EOD;
		
		$row = $this->db->getRow($sql, array($userID));
		return $row['F_GroupID'];
	}
	
	function getExtraGroups($userID) {
		// Only authenticate if this is not the logged in user attempting to get their groups (during login).
		if ($userID != Session::get('userID'))
			AuthenticationOps::authenticateUserIDs(array($userID));
		
		// Get the extra groups for the given user id
		// v3.3.1 Add an extra check that their main group isn't in this list.
		$sql = 	<<<EOD
				SELECT x.F_GroupID
				FROM T_ExtraTeacherGroups x, T_Membership m
				WHERE x.F_UserID = ?
				AND x.F_UserID = m.F_UserID
				AND x.F_GroupID <> m.F_GroupID
EOD;

		$extraGroupsRS = $this->db->Execute($sql, array($userID));
		
		$extraGroupIDs = array();
		
		foreach ($extraGroupsRS->GetArray() as $element)
			$extraGroupIDs[] = $element['F_GroupID'];
			
		return $extraGroupIDs;
	}
	
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
	
	function getAllManageables() {
		return $this->getManageables(Session::get('groupIDs'), false, true);
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
	function getManageables($groupIDArray, $authenticate = true, $storeIDs = false) {
		// Ensure that the logged in user has permission to access this group
		if ($authenticate) AuthenticationOps::authenticateGroupIDs($groupIDArray);
		
		if ($storeIDs) {
			AuthenticationOps::clearValidUsersAndGroups();
			AuthenticationOps::addValidGroupIds($groupIDArray); // The given groups are automatically valid
		}
		
		$manageables = array();
		
		foreach ($groupIDArray as $groupID) {
			//NetDebug::trace('ManageableOps.getManageables sql id='.$groupID);
			// To begin the recursion we need to initially get the root node
			$sql  = "SELECT ".Group::getSelectFields($this->db);
			$sql .= <<<EOD
					FROM T_Groupstructure g
					WHERE F_GroupID=?;
EOD;

			// Perform the query and create a Group object from the results
			$rootGroupRS = $this->db->Execute($sql, array($groupID));
			
			$rootGroup = $this->_createGroupFromObj($rootGroupRS->FetchNextObj());
			
			$rootGroup->addManageables($this->_getManageables($rootGroup));
			//NetDebug::trace('ManageableOps.getManageables root group='.$rootGroup->id);
			
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
	private function _getManageables($group) {
		$result = array();

		$childrenArray = $this->_getChildrenOfGroups($group);
		
		$groupsRS = $childrenArray["groups"];
		$usersRS = $childrenArray["users"];
		
		// Add the groups
		if ($groupsRS->RecordCount() > 0) {
			while ($childGroupObj = $groupsRS->FetchNextObj()) {
				$childGroup = $this->_createGroupFromObj($childGroupObj);
				$childGroup->addManageables($this->_getManageables($childGroup));
				$result[] = $childGroup;
			}
		}

		// Add the users
		if ($usersRS->RecordCount() > 0) {
			while ($userObj = $usersRS->FetchNextObj()) {
				$user = $this->_createUserFromObj($userObj);
				// v3.3 Multi-group users.
				$user->id = (string)$group->id.'.'.$user->userID;
				$group->addManageables(array($user));
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
	// This to just try and quickly get subgroups from SQL
	private function getGroupSubgroups($startGroupID) {
		$subGroupIDs = array($startGroupID);
		$sql = <<<EOD
				SELECT F_GroupID
				FROM T_Groupstructure
				WHERE F_GroupParent = ?
				AND F_GroupParent <> F_GroupID
EOD;
		$groupRS = $this->db->Execute($sql, array($startGroupID));
		if ($groupRS->recordCount()>0) {		
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
	
	
	private function _getChildrenOfGroups($group) {
		// RootID is not set by DMS, and is not necessary in this function anyway
		//$rootID = Session::get('rootID');
		$groupID = $group->id;
		
		if (strlen($groupID) == 0) return array("groups" => new ADORecordSet_empty(), "users" => new ADORecordSet_empty());

		// Get all the groups.  We need to explicitly check that the groupID isn't in the $groupIDs.
		// v3.5 I want the groups to display ordered by name.
		// v3.6.2 This is a slow query in MySQL. Why do we need DISTINCT? Should we index in F_GroupParent too?
		//$sql  = "SELECT DISTINCT ".Group::getSelectFields($this->db);
		$sql  = "SELECT ".Group::getSelectFields($this->db);
		$sql .= <<<EOD
				FROM T_Groupstructure g
				WHERE g.F_GroupParent=?
				AND g.F_GroupID!=?
				ORDER BY g.F_GroupParent, g.F_GroupName ASC
EOD;

		$groupsRS = $this->db->Execute($sql, array($groupID, $groupID));

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
		//NetDebug::trace('ManageableOps.getChildren group='.$groupID.' type='.$userTypeMinimum.' sql='.$sql);
		//$usersRS = $this->db->Execute($sql, array($rootID, $groupID, $userTypeMinimum));
		$usersRS = $this->db->Execute($sql, array($groupID, $userTypeMinimum));
		//NetDebug::trace('ManageableOps.getChildren usersRS='.$usersRS->RecordCount());
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
		//$rootID = Session::get('rootID');
		$rootID = ($newRootID) ? $newRootID : Session::get('rootID');
		// AR Do we really have to encode quotes? It would match the std better if the db had ' not &apos;
		//$username = Manageable::apos_encode($user->name);
		$username = $user->name;
		$password = $user->password;
		$studentID = $user->studentID;
		
		// v3.6.1 Check Access Control
		$sql = 	<<<EOD
				SELECT F_LoginOption as loginOption
				FROM T_AccountRoot
				WHERE F_RootID=?
EOD;
		$rs = $this->db->Execute($sql, array($rootID));
		switch ($rs->RecordCount()) {
			case 1:
				$loginOption = (int)($rs->FetchNextObj()->loginOption);
				break;
			default:
				throw new Exception("More than one account with this root ($rootID)");
		}
		// I am going to put this into session variables so I can get it again
		//Session::get('loginOption',$loginOption); // Set NOT get please!
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
					$rootList = $record->F_Value;
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
		
		// Ensure the username is unique within this context
		// v3.3 Multi-group users
		// You may now have multiple membership rows for one user, so only get distinct userIDs
		//		SELECT u.F_UserID
		// v3.6.1 You might want to know WHY this is not a valid user
		// Also, surely I need to bring teachers and reporters into the uniqueness too?
		//		SELECT distinct(u.F_UserID), u.F_UserName, u.F_StudentID, m.F_GroupID
		//		AND u.F_UserType>=0 
		//		AND m.F_RootID=? 	
		$sql = 	<<<EOD
				SELECT distinct(u.F_UserID) as userID, u.F_UserName, u.F_StudentID, m.F_GroupID
				FROM T_User u, T_Membership m
				WHERE u.F_UserID=m.F_UserID
				AND u.F_UserName = ?
				$rootClause
EOD;
		//NetDebug::trace('isUserValid name sql='.$sql);
		
		//if ($user->userType != User::USER_TYPE_ADMINISTRATOR) {
		//	$sql .= "AND m.F_RootID=? "; 
		//} else {
		//	//$sql .= "AND u.F_Password=?"; 
		//}
		//$sql .= "AND m.F_RootID=? "; 
		
		// TODO: u.F_UserType>=0 might need to change; can't quite work this out...
		// v3.2 If we have removed password from the check, then don't send it in bindingParams...
		//$rs = $this->db->Execute($sql, array($username, $rootID, $password));
		// v3.6.1.1 And root handled above
		//$rs = $this->db->Execute($sql, array($username, $rootID));
		$rs = $this->db->Execute($sql, array($username));
		
		// v3.6.1 Initialise return
		$rc = Array();
		$rc['returnInfo'] = Array();
		
		switch ($rs->RecordCount()) {
			case 0:
				// There are no duplicates
				// But you might need to check for ID too
				// return true;
				$nameOK = true;
				break;
			case 1:
				// There is a duplicate, but if this is an update it might be the same record
				// v3.3 Multi-group users
				// return ((int)($rs->FetchNextObj()->F_UserID) == (int)($user->id));
				//NetDebug::trace('isUserValid duplicate name='.$user->name.' userID='.$user->userID);
				// But you might need to check for ID too
				//return ((int)($rs->FetchNextObj()->F_UserID) == (int)($user->userID));
				//$nameOK = ((int)($rs->FetchNextObj()->F_UserID) == (int)($user->userID));
				//$nameOK = ((int)($rs->FetchNextObj()->userID) == (int)($user->userID));
				$firstRecord = $rs->FetchNextObj();
				if ((int)($firstRecord->userID) == (int)($user->userID)) {
					//NetDebug::trace('but it is the same person');
					$nameOK = true;
				} else {
					NetDebug::trace('found another person by name');
					$nameOK = false;
					$rc['returnInfo'][] = Array('name'=>$firstRecord->F_UserName, 'group'=>$firstRecord->F_GroupID);
				}
				break;
			default:
				// You found many existing users with this name
				// Is this really an exception, or just a sign that this is a user your can't add/update?
				//throw new Exception("isUserValid: More than one user was returned with username '".$username."'");
				//return false;
				$nameOK = false;
				// You really should send back info on all the duplicates to be useful
				while($record = $rs->FetchNextObj()) {
					$rc['returnInfo'][] = Array('name' => $record->F_UserName, 'group' => $record->F_GroupID);
				}
		}
		// Do we want to check the studentID for uniqueness too?
		if ($loginOption & 2) {
			// v3.6.1 Do an extra check on the studentID if that is in Access Control.
			// Of course, you could argue that if you only login with ID, the name could be duplicated, but that seems like it could lead to confusion...
			//		SELECT distinct(u.F_UserID)
			//		AND u.F_UserType>=0 
			//		AND m.F_RootID=? 	
			$sql = 	<<<EOD
					SELECT distinct(u.F_UserID) as userID, u.F_UserName, u.F_StudentID, m.F_GroupID
					FROM T_User u, T_Membership m
					WHERE u.F_UserID=m.F_UserID
					AND u.F_StudentID = ?
					$rootClause
EOD;
			//NetDebug::trace('isUserValid studentID sql='.$sql);
			//$rs = $this->db->Execute($sql, array($studentID, $rootID));
			$rs = $this->db->Execute($sql, array($studentID));
			
			switch ($rs->RecordCount()) {
				case 0:
					// There are no duplicates
					$idOK = true;
					break;
				case 1:
					// There is a duplicate, but if this is an update it might be the same record
					//$idOK = ((int)($rs->FetchNextObj()->F_UserID) == (int)($user->userID));
					//NetDebug::trace('isUserValid duplicate id='.$user->studentID.' userID='.$user->userID);
					$firstRecord = $rs->FetchNextObj();
					if ((int)($firstRecord->userID) == (int)($user->userID)) {
						$idOK = true;
					} else {
						NetDebug::trace('found another person by id');
						$idOK = false;
						$rc['returnInfo'][] = Array('studentID'=>$firstRecord->F_StudentID, 'group'=>$firstRecord->F_GroupID);
					}
					break;
				default:
					// You found many existing users with this ID
					//throw new Exception("isUserValid: More than one user was returned with id '".$studentID."'");
					//return false;
					$idOK = false;
					// You really should send back info on all the duplicates to be useful
					while($record = $rs->FetchNextObj()) {
						$rc['returnInfo'][] = Array('studentID'=>$firstRecord->F_StudentID, 'group' => $record->F_GroupID);
					}
			}
		} else {
			$idOK = true;
		}
		// You need to be able to return different info for different failures
		// 1 = name failed
		// 2 = id failed
		//return ($nameOK && $idOK);
		$returnCode=0;
		if (!$nameOK) $returnCode+=1;
		if (!$idOK) $returnCode += 2;
		$rc['returnCode']=$returnCode;
		//return $returnCode;
		return $rc;
	}
	
}
?>
