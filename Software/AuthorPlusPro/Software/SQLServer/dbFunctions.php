<?php
class FUNCTIONS {
	function FUNCTIONS() {
	}

	//v6.5.4.5 AR functions to see which database you are working on to allow different SQL calls
	function checkDatabaseVersion( &$vars, &$node ){
		global $db;
		
		//' v6.5.4.5 The first test is to see if T_DatabaseVersion exists - this is the difference between 1 and 2
		$sql = <<<EOD
				select name, type_name(xtype) as type, length from syscolumns 
				where id = object_id(?) order by colid;
EOD;
		$tableName = "T_DatabaseVersion";
		$bindingParams = array($tableName);
		$rs = $db->Execute($sql, $bindingParams);
		// no columns means this table doesn't exist
		if ($rs->RecordCount()==0) {
			$node .= "<database version='1'  />";
			$vars['DATABASEVERSION'] = 1;
			$rs->Close();
			return true;
		}
		$rs->Close();

		// v6.5.4.5 The second call is to read the version number from the table we now know exists
		$sql = <<<EOD
			select Max(F_VersionNumber) as versionNumber from T_DatabaseVersion
EOD;
		$rs = $db->Execute($sql);
		$dbObj = $rs->FetchNextObj();
		$vars['DATABASEVERSION'] = $dbObj->versionNumber;
		$node .= "<database version='" .$dbObj->versionNumber ."'  />";
		$rs->Close();
		return true;
	}
	// v6.5.5.3 For CE.com accounts
	// v6.5.5.56 Also send back content location - we expect T_Accounts.F_ContentLocation to always have a value for Author Plus
	function getLicenceDetails( &$vars, &$node ) {
		global $db;
		
		$productCode = 1;
		$rootID = $vars['ROOTID'];
		$prefix = $vars['PREFIX'];
		$bindingParams = array($productCode);
		// v6.5.6 All dates are good now
		//if (strpos($vars['DBDRIVER'],"mysql")!==false) {
			$sql = <<<EOD
				SELECT A.F_ExpiryDate as formattedDate, 
					A.F_LicenceStartDate as licenceStartDate, 
					R.F_Name as institution, 
					R.F_RootID as rootID, 
					A.* 
				FROM T_Accounts A, T_AccountRoot R 
				WHERE A.F_RootID = R.F_RootID 
				AND A.F_ProductCode=?
EOD;
		//} else {
		//	$sql = <<<EOD
		//		SELECT CONVERT(char(19), A.F_ExpiryDate,120) as formattedDate, CONVERT(char(19), A.F_LicenceStartDate,120) as licenceStartDate,	R.F_Name as institution, R.F_RootID as rootID, A.* 
		//		FROM T_Accounts A, T_AccountRoot R 
		//		WHERE A.F_RootID = R.F_RootID AND A.F_ProductCode=?
		//	EOD;
		//}
		
		if (isset($vars['ROOTID']) && $vars['ROOTID']>0) {
			$sql.=" AND R.F_RootID=?";
			$bindingParams[] = $rootID;
		} else {
			$sql.=" AND R.F_Prefix=?";
			$bindingParams[] = $prefix;
		}
		$rs = $db->Execute($sql, $bindingParams);
		
		// Expecting just one record
		switch ($rs->RecordCount()) {
			case 0:
				//throw new Exception("No account for this product in this root.");
				$node .= "<licence error='true' note='No licence for this account'  />";
				return false;
				break;
			case 1:
				$dbObj = $rs->FetchNextObj();
				$node .= "<licence rootID='$dbObj->rootID' 
								name='".htmlspecialchars($dbObj->institution, ENT_QUOTES, 'UTF-8')."'
								expiryDate='$dbObj->formattedDate' 
								startDate='$dbObj->licenceStartDate' 
								maxAuthors='$dbObj->F_MaxAuthors' 
								maxTeachers='$dbObj->F_MaxTeachers'  
								contentLocation='$dbObj->F_ContentLocation'  
								/>";
				break;
			default:
				//throw new Exception("Multiple accounts for the same product in this root.");
				$node .= "<licence error='true' note='Multiple accounts for the same product in this root' />"; 
				return false;
		}
		$rs->Close();
		return true;
	}
	
	function getDecryptKey( &$vars, &$node ) {
		global $db;
		
		$sql = <<<EOD
		SELECT F_KeyBase FROM T_Encryptkey WHERE F_KeyID=?
EOD;
		$eKey = $vars['EKEY'];
		$bindingParams = array($eKey);
		$rs = $db->Execute($sql, $bindingParams);
		
		// return success if there's a key decrypted
		switch ($rs->RecordCount()) {
			case 1:
				$dbObj = $rs->FetchNextObj();
				$node .= "<decrypt success='true' key='".$dbObj->F_KeyBase."' />";
				break;
			default:
				$node .= "<decrypt success='false' />";
		}
		$rs->Close();
		return true;
	}
	
	function checkLogin( &$vars, &$node ) {
		global $db;
		
		//v6.4.2.1 RootID should be passed, but isn't. So until then, allow any root
		// select admin/teacher by username
		//$rC = $Db->query("SELECT F_UserID, F_Password, F_FullName, F_Email, F_UserName,F_UserSettings FROM T_User WHERE F_UserName=\"".$vars["USERNAME"]."\" AND (F_UserType=1 OR F_UserType=2)");
		//v6.4.2.6 Now it is
		// v6.5.5.6 Allow null password if we have some other way of validating
		//		AND T_User.F_Password=?
		// v6.5.6 use adodb functions for this database specific stuff instead
		//if (strpos($vars['DBDRIVER'],"mssql")!==false || strpos($vars['DBDRIVER'],"sqlite")!==false) {
		//	$sqlCaseFunction = "UPPER";
		//} else {
		//	$sqlCaseFunction = "UCASE";
		//}
		$sql = <<<EOD
			SELECT T_User.*, T_Membership.F_GroupID As groupID
			FROM T_User, T_Membership WHERE {$db->upperCase}(F_UserName)=?
				AND T_User.F_UserID = T_Membership.F_UserID
				AND T_Membership.F_RootID=?
EOD;
		$username = strtoupper($vars['USERNAME']);
		$rootID = $vars['ROOTID'];
		$password = $vars['PASSWORD'];
		//$bindingParams = array($username, $rootID, $password);
		$bindingParams = array($username, $rootID);
		$rs = $db->Execute($sql, $bindingParams);
		
		// if there's a record
		switch ($rs->RecordCount()) {
			case 1:
				$dbObj = $rs->FetchNextObj();
				if ($dbObj->F_UserType==0) {
					$node .= "<login success='false' info='user is a student' />";
				} else if ($dbObj->F_Password != $password && $password != '$!null_!$') {
					$node .= "<login success='false' info='invalid password' />";
				} else {
					// v6.5.6 AR Send back usertype too
					$node .= "<login success='true' "
								."name='" .htmlspecialchars($username, ENT_QUOTES, 'UTF-8') ."' "
								."groupID='".$dbObj->groupID."' "
								."userType='".$dbObj->F_UserType."' "
								."userID='".$dbObj->F_UserID."' email='".$dbObj->F_Email."' userSettings='".$dbObj->F_UserSettings."' />";
				}
				break;
			case 0:
				$node .= "<login success='false' info='invalid password or name' />";
				break;
			default:
			// v6.5.5.7 There might be multiple users in this root with the same name, but different passwords. really?			
			// No surely not.
		}
		$rs->Close();
		return true;
	}
	
	function checkMGS( $vars, &$node ) {
		global $db;
		// check T_Groupstructure.F_enableMGS
		// v6.4.2.5 AR return in one go if you find the MGS straight away
		// v6.4.2.6 AR we now know the userID
		//$rC = $Db->query("SELECT F_EnableMGS, F_MGSName, T_Groupstructure.F_GroupParent from T_Groupstructure, T_Membership, T_User WHERE T_User.F_Username=\"".$vars["USERNAME"]."\" AND T_User.F_UserID=T_Membership.F_UserID AND T_Membership.F_GroupID=T_Groupstructure.F_GroupID");
		$sql = <<<EOD
			SELECT F_EnableMGS, F_MGSName, F_GroupParent from T_Groupstructure, T_Membership
				WHERE T_Membership.F_UserID=?
				AND T_Membership.F_GroupID=T_Groupstructure.F_GroupID
EOD;
		$userID = $vars['USERID'];
		$bindingParams = array($userID);
		$rs = $db->Execute($sql, $bindingParams);
		
		// if there's a record
		switch ($rs->RecordCount()) {
			case 1:
				$dbObj = $rs->FetchNextObj();
				$enableMGS = $dbObj->F_EnableMGS;
				$MGSName = $dbObj->F_MGSName;
				$parentGid = $dbObj->F_GroupParent;
				$rs->Close();
				// if we found it directly, go back, otherwise need to check the parent
				if ($enableMGS>0) {
					$node .= "<checkMGS success='true' enableMGS='1' name='".$MGSName."' />";
				} else {
					// pass the parent group
					$this->getParentGroup($parentGid, $node);
				}
				break;
			default:
				$node .= "<checkMGS success='false' />";
				$rs->Close();
		} 
		return true;
	}

	function getParentGroup( $gid, &$node ) {
		global $db;
		$sql = <<<EOD
			SELECT F_GroupID, F_EnableMGS, F_MGSName, F_GroupParent from T_Groupstructure 
				WHERE F_GroupID=?
EOD;
		$bindingParams = array($gid);
		$rs = $db->Execute($sql, $bindingParams);
		
		switch ($rs->RecordCount()) {
			case 1:
				$dbObj = $rs->FetchNextObj();
				$enableMGS = $dbObj->F_EnableMGS;
				$MGSName = $dbObj->F_MGSName;
				$parentGid = $dbObj->F_GroupParent;
				$gid = $dbObj->F_GroupID;
				// v6.4.2.5 Swap the order of checks - MGS first then top-level
				// Found a group parent record, does it have MGS enabled?
				if ($enableMGS>0) {
					$node .= "<checkMGS success='true' enableMGS='1' name='".$MGSName."' />";
					return 0;
				} else {
					// No, so can we keep going up (not if this top level)
					if ($parentGid==$gid) {
						$node .= "<checkMGS success='true' name='' enableMGS='0' />";
						return 0;		
					} else {
						// recursive to check it's parent Group has MGS enable or not
						$this->getParentGroup($parentGid, $node );			
					}
				}
				break;
			default:
				$node .= "<checkMGS success='false' />";
				$rs->Close();
		}
		return true;
	}

	function updateEditedContent( &$vars, &$node ){
		global $db;
		$sql = <<<EOD
			Update T_EditedContent Set F_EnabledFlag = ?
			Where F_EditedContentUID = ?
EOD;
		$bindingParams = array($vars["eF"], $vars["UID"]);
		$rs = $db->Execute($sql, $bindingParams);
		$node .= "<updateEditedContent success='true'/>";
		$rs->Close();
		return true;
	}
}
?>
