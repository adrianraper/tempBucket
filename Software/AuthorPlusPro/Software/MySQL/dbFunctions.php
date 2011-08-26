<?php
function getDecryptKey( &$vars, &$node ) {
	global $Db;
	
	$rC = $Db->query("SELECT F_KeyBase FROM T_Encryptkey WHERE F_KeyID=".$vars["EKEY"]);
	
	// return success if there's a key decrypted
	if ($Db->num_rows > 0) {
		$node .= "<decrypt success=\"true\" key=\"".$Db->result[0]['F_KeyBase']."\" />";
	// return fail
	} else {
		$node .= "<decrypt success=\"false\" />";
	}
	return 0;
}

function checkLogin( &$vars, &$node ) {
	global $Db;
	
	//v6.4.2.1 RootID should be passed, but isn't. So until then, allow any root
	// select admin/teacher by username
	//$rC = $Db->query("SELECT F_UserID, F_Password, F_FullName, F_Email, F_UserName,F_UserSettings FROM T_User WHERE F_UserName=\"".$vars["USERNAME"]."\" AND (F_UserType=1 OR F_UserType=2)");
	//v6.4.2.6 Now it is
	$sql = "SELECT T_User.* FROM T_User, T_Membership WHERE F_UserName=\"".$vars["USERNAME"]."\" ".
			"AND T_User.F_UserID = T_Membership.F_UserID AND T_Membership.F_RootID=".$vars["ROOTID"].";";
	$rC = $Db->query($sql);
	
	// if there's a record
	if ($Db->num_rows > 0) {
		// check the password
		if ($Db->result[0]["F_Password"]<>$vars["PASSWORD"]) {
			$node .= "<login success='false' info='invalid password' />";
			return 1;
		// and the usertype
		} elseif ($Db->result[0]["F_UserType"]==0) {
			$node .= "<login success='false' info='user is a student' />";
			return 1;
		// return fail if the password is incorrect
		} else {
			// Ar v6.2.4.6 and send back userID
			$node .= "<login success='true' name=\"".$Db->result[0]["F_UserName"]."\" userID=\"".$Db->result[0]["F_UserID"]."\" email=\"".$Db->result[0]["F_Email"]."\" userSettings=\"".$Db->result[0]["F_UserSettings"]."\" />";
			return 0;
		}
	// if there's no record, return fail
	} else {
		$node .= "<login success='false' info='no such user' />";
		return 1;
	}
}

function checkMGS( $vars, &$node ) {
	global $Db;
	// check T_Groupstructure.F_enableMGS
	// v6.4.2.5 AR return in one go if you find the MGS straight away
	// v6.4.2.6 AR we now know the userID
	//$rC = $Db->query("SELECT F_EnableMGS, F_MGSName, T_Groupstructure.F_GroupParent from T_Groupstructure, T_Membership, T_User WHERE T_User.F_Username=\"".$vars["USERNAME"]."\" AND T_User.F_UserID=T_Membership.F_UserID AND T_Membership.F_GroupID=T_Groupstructure.F_GroupID");
	$sql = "SELECT F_EnableMGS, F_MGSName, F_GroupParent from T_Groupstructure, T_Membership"
					." WHERE T_Membership.F_UserID=".$vars["USERID"]." AND T_Membership.F_GroupID=T_Groupstructure.F_GroupID;";
	$rC = $Db->query($sql);
	if ($Db->num_rows > 0) {
		$enableMGS = $Db->result[0]['F_EnableMGS'];
		// query success
		// if we found it directly, go back, otherwise need to check the parent
		if ($enableMGS>0) {
			$node .= "<checkMGS success=\"true\" enableMGS=\"1\" name=\"".$Db->result[0]['F_MGSName']."\"/>";
		} else {
			// pass the parent group
			$gid = $Db->result[0]['F_GroupParent'];
			getParentGroup($gid, &$node);
		}
		return 0;
	// return fail
	} else {
		$node .= "<checkMGS success=\"false\" />";
		return 1;
	} 
}

// v6.4.2.5 Not used
/*
function getMGS( $vars, &$node ) { 
	global $Db;
	//get the parentgroup
	$rC = $Db->query("SELECT T_Groupstructure.F_GroupID from T_Groupstructure, T_Membership, T_User WHERE T_User.F_Username=\"".$vars["USERNAME"]."\" AND T_User.F_UserID=T_Membership.F_UserID AND T_Membership.F_GroupID=T_Groupstructure.F_GroupID");
	//return the GroupID
	if ($Db->num_rows > 0) {
		$gid = $Db->result[0]['F_GroupID'];
		getParentGroup($gid, &$node);
	} else {
		$node .= "<checkMGS success=\"false\" gid=\"".$gid."\"/>";
		return 1;
	}
	
}
*/
function getParentGroup( $gid, &$node ) {
	global $Db;
	$rC = $Db->query("SELECT F_GroupID, F_EnableMGS, F_MGSName, F_GroupParent from T_Groupstructure WHERE F_GroupID=".$gid);
	//print $vars." ";
	if ($Db->num_rows > 0) {
		// v6.4.2.5 Swap the order of checks - MGS first then top-level
		// Found a group parent record, does it have MGS enabled?
		if ($Db->result[0]['F_EnableMGS']=='1') {
			$node .= "<checkMGS success=\"true\" name=\"".$Db->result[0]['F_MGSName']."\" enableMGS=\"".$Db->result[0]['F_EnableMGS']."\" />";
			return 0;
		} else {
			// No, so can we keep going up (not if this top level)
			if ($Db->result[0]['F_GroupID']==$Db->result[0]['F_GroupParent']) {
				$node .= "<checkMGS success=\"true\" name=\"\" enableMGS=\"0\" />";
				return 0;		
			} else {
				// recursive to check it's parent Group has MGS enable or not
				getParentGroup($Db->result[0]['F_GroupParent'], &$node );			
			}
		}
	} else {
		$node .= "<checkMGS success=\"false\" />";
		return 1;
	}
}
/*
function getParentGroup( $vars, &$node ) {
	global $Db;
	$rC = $Db->query("SELECT F_GroupID, F_EnableMGS, F_MGSName, F_GroupParent from T_Groupstructure WHERE F_GroupID=".$vars);
	//print $vars." ";
	if ($Db->num_rows > 0) {
		if ($Db->result[0]['F_EnableMGS']=='1') {
			if ($Db->result[0]['F_GroupID']==$Db->result[0]['F_GroupParent']) {
				$node .= "<getMGS success=\"true\" MGSName=\"\" enableMGS=\"0\" gid=\"".$Db->result[0]['F_GroupID']."\" />";
				return 0;				
			} else {
				$node .= "<getMGS success=\"true\" MGSName=\"".$Db->result[0]['F_MGSName']."\" enableMGS=\"".$Db->result[0]['F_EnableMGS']."\" gid=\"".$Db->result[0]['F_GroupID']."\" />";
				return 0;			
			}
		} else {
			// recursive to check it's parent Group has MGS enable or not
			getParentGroup($Db->result[0]['F_GroupParent'], &$node );
		}
	} else {
		$node .= "<getMGS success=\"false\" />";
		return 1;
	}
}
*/
?>