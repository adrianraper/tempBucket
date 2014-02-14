<?php
/*
 * To run code on the database
 */
require_once(dirname(__FILE__)."/MinimalService.php");
$thisService = new MinimalService();

header('Content-Type: text/plain; charset=utf-8');

$newLine = "<br/>";
$newLine = "\n";

/*
 * Action for the script
 */
/*
 * This is to add a shared learner to all AA accounts so that students can login with out the admin password
 * 1) Find accounts that are AA (based on RM) but that don't have prefix_learner as a user
 * 2) Get the top level group for that account (from the admin user)
 * 3) Add prefix_learner to the T_User and get back the F_UserID
 * 4) Add membership record linking userID, rootID and groupID
 */

try {
	// Get all AA accounts - doesn't really matter if active or not
	$sql = 	<<<EOD
		select r.F_RootID as rootID, r.F_Prefix as prefix 
		from T_AccountRoot r, T_Accounts a
		where a.F_ProductCode = 2
		and a.F_LicenceType = 2
		and a.F_RootID = r.F_RootID
EOD;
	$rs = $thisService->db->Execute($sql);
	if ($rs) {
		while ($dbObj = $rs->FetchNextObj()) {
			$prefix = $dbObj->prefix; 
			$rootID = $dbObj->rootID;
			echo "$prefix: root $rootID lets check".$newLine;
			
			// Search for 2 users, the admin and the generic one  
			$sql = 	<<<EOD
				select * 
				from T_User u, T_Membership m
				where u.F_UserID = m.F_UserID
				and m.F_RootID=?
				and (u.F_Username=? OR u.F_UserType=2)
EOD;
			$rs1 = $thisService->db->Execute($sql, array($dbObj->rootID, $prefix.'_learner'));
			if ($rs1) {
				while ($userObj = $rs1->FetchNextObj()) {
					// If this is the admin user, pick up their group
					if ($userObj->F_UserType == 2) {
						$groupID = $userObj->F_GroupID;
						echo "$prefix: root $rootID has groupID=$groupID".$newLine;
					// If a generic user, just skip out of this account
					} else {						
						echo "$prefix: root $rootID already has generic learner".$newLine;
						continue 2;
					}
				}
			}

			$group = $thisService->manageableOps->getGroup($groupID);
			$stubUser = new User();
			$stubUser->name = $prefix.'_learner';
			$stubUser->password = $prefix;
			
			$stubUser->userType = User::USER_TYPE_STUDENT;
			$stubUser->registrationDate = date('Y-m-d H:i:s');
			$stubUser->registerMethod = "dbWorkbench";
			
			$thisService->manageableOps->addUser($stubUser, $group, $dbObj->rootID);
			echo "$prefix: root $rootID now added generic learner ".$dbObj->prefix.'_learner'.$newLine;
		}
			
	} else {
		echo "Select failed";
		
	}
} catch (Exception $e) {
	echo $e->getMessage();
}	

flush();
exit(0);
