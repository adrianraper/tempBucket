<?php

class AuthenticationOps {
	
	public static $useAuthentication = true;
	
	/**
	 * Clear the list of valid user and group ids for the logged in user
	 */
	public static function clearValidUsersAndGroups() {
		if (!AuthenticationOps::$useAuthentication) return;
	
		Session::set('valid_userIDs', array());
		Session::set('valid_groupIDs', array());
	}
	
	/**
	 * Add an array of valid user ids for the logged in user
	 */
	public static function addValidUserIDs($userIdArray) {
		if (!AuthenticationOps::$useAuthentication) return;
		
		Session::set('valid_userIDs', array_merge(Session::get('valid_userIDs'), $userIdArray));
	}
	
	/**
	 * Add an array of valid group ids for the logged in user
	 */
	public static function addValidGroupIDs($groupIdArray) {
		if (!AuthenticationOps::$useAuthentication) return;
	
		Session::set('valid_groupIDs', array_merge(Session::get('valid_groupIDs'), $groupIdArray));
	}
	
	/**
	 * This is a security check (used by most methods) which ensures that the given group ids belong to one of the logged in users groups.
	 * It works by comparing against Session::get('valid_groupIDs') which is set every time getAllManageables is called. 
	 */
	public static function authenticateGroupIDs($groupIdArray) {
		if (!AuthenticationOps::$useAuthentication) return;
		
		// If there are no ids in the array do nothing
		if (!is_array($groupIdArray) || sizeof($groupIdArray) == 0) return;
		
		$diff = array_diff($groupIdArray, Session::get('valid_groupIDs'));
			
		if (sizeof($diff) == 0) {
			return;
		} else {
			// Get the group access error message from the literals and subsitute in the ids to help with debugging
			$copyOps = new CopyOps();
			$replaceObj = array("ids" => join(",", $diff));
			throw new Exception($copyOps->getCopyForId("groupAccessError", $replaceObj));
		}
	}

	/**
	 * An alias for authenticateGroupIDs which accepts an array of Groups instead of group ids
	 */
	public static function authenticateGroups($groups) {
		if (!AuthenticationOps::$useAuthentication) return;
		
		$groupIdArray = array();
		
		foreach ($groups as $group)
			$groupIdArray[] = $group->id;
			
		AuthenticationOps::authenticateGroupIDs($groupIdArray);
	}
	
	/**
	 * This is a permissions check to ensure that you don't delete a group that you don't have permission to
	 * It works by comparing against Session::get('groupIDs') which is set if RM found a top level group for this user.
	 * DMS sets nothing.
	 */
	public static function authenticateGroupIDForDelete($groupId) {
		if (!AuthenticationOps::$useAuthentication) return;
		
		// And if no 'protected' groups have been set do nothing
		if (!Session::is_set('groupIDs')) return;
		
		// gh#1190 Check to see if the current group is in the protected array
		if (in_array($groupId, Session::get('groupIDs'))) {
			
			// Get the group access error message from the literals and substitute in the ids to help with debugging
			AbstractService::$controlLog->info('group delete blocked as top level');
			$copyOps = new CopyOps();
			$replaceObj = array("ids" => $groupId);
			throw new Exception($copyOps->getCopyForId("groupDeleteError", $replaceObj));
		}
	}
	
	/**
	 * This is a security check (used by most methods) which ensures that the given user ids belong to one of the logged in users groups.
	 * It works by comparing against Session::get('valid_userIDs') which is set every time getAllManageables is called. 
	 */
	public static function authenticateUserIDs($userIdArray) {
		if (!AuthenticationOps::$useAuthentication) return;
		
		// If there are no ids in the array do nothing
		if (sizeof($userIdArray) == 0) return;
		
		$valid_userIDs = Session::is_set('valid_userIDs') ? Session::get('valid_userIDs') : array();
		$diff = array_diff($userIdArray, $valid_userIDs);
		
		if (sizeof($diff) == 0) {
			return;
		} else {
			// Get the user access error message from the literals and subsitute in the ids to help with debugging
			$copyOps = new CopyOps();
			$replaceObj = array("ids" => join(",", $diff));
			throw new Exception($copyOps->getCopyForId("userAccessError", $replaceObj));
		}
	}
	
	/**
	 * An alias for authenticateUserIDs which accepts an array of Users instead of user ids
	 */
	public static function authenticateUsers($users) {
		if (!AuthenticationOps::$useAuthentication) return;
		
		$userIdArray = array();
		
		foreach ($users as $user)
			// v3.4 Multi-group users
			//$userIdArray[] = $user->id;
			$userIdArray[] = $user->userID;
			
		AuthenticationOps::authenticateUserIDs($userIdArray);
	}
	
	public static function countAuthenticatedGroups() {
		return sizeof(Session::get('valid_groupIDs'));
	}
	
	public static function countAuthenticatedUsers() {
		return sizeof(Session::get('valid_userIDs'));
	}

}
?>
