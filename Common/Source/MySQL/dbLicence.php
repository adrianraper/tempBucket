<?php

class LICENCE {
	function LICENCE() {
		$this->delay = -10;
	}
	function countLicences( &$vars, $mode, $jn ) {
		global $Db;
		// v6.3.3 Add root to connection tables
		//6.3.5 Add userID to connection tables
		// v6.4.2 Only if userID is passed to you do you use it - see OrchidObjects:getLicenceSlot
		// v6.4.2.4 Use productCode to help with separating different titles for concurrent licences
		if ($vars['USERID'] < 0) {
			//$makeQuery = "SELECT COUNT(F_LicenceID) as i FROM T_Licences  WHERE F_RootID='{$vars['ROOTID']}'";
			$makeQuery = "SELECT COUNT(F_LicenceID) as i FROM T_Licences  
							WHERE F_RootID='{$vars['ROOTID']}' 
							AND F_ProductCode='{$vars['PRODUCTCODE']}' 
							";
		} else {
			//$makeQuery = "SELECT COUNT(F_LicenceID) as i FROM T_Licences WHERE F_RootID='{$vars['ROOTID']}' AND F_UserID='{$vars['USERID']}'";
			$makeQuery = "SELECT COUNT(F_LicenceID) as i FROM T_Licences 
							WHERE F_RootID='{$vars['ROOTID']}' 
							AND F_ProductCode='{$vars['PRODUCTCODE']}'
							AND F_UserID='{$vars['USERID']}'";
		}
		if ($mode == 0) {
			$id = $vars['LICENCEID'];
			//print ' id='.$id.' ';
			$makeQuery .= " AND F_LicenceID='$id';";
		} else if($mode == 2) {
			$makeQuery .= " AND F_LastUpdateTime < $jn;";
			//print $makeQuery;
		} else {
			$makeQuery .= ";";
		}
		$Db->query($makeQuery);
		return $Db->result[0][i];
	}
	function deleteLicencesID( &$vars) {
		global $Db;
		$id = $vars['LICENCEID'];
		$Db->query("DELETE FROM T_Licences WHERE F_LicenceID='$id';");
		return 0;
	}
	function deleteLicencesOld( &$vars , $jn) {
		global $Db;
		// v6.4.2.4 Use productCode to help with separating different titles for concurrent licences
		// v6.4.2.6 correction
		//$productCode = $vars['LICENCEID'];
		$productCode = $vars['PRODUCTCODE'];
		//$Db->query("DELETE FROM T_Licences WHERE F_LastUpdateTime < $jn");
		$Db->query("DELETE FROM T_Licences 
					WHERE F_LastUpdateTime < $jn
					AND F_ProductCode = $productCode
					");
		return 0;
	}
	function updateLicence( &$vars ) {
		global $Db;
		$id = $vars['LICENCEID'];
		$now = $Db->now();
		$Db->query("UPDATE T_Licences SET F_LastUpdateTime='$now' WHERE F_LicenceID='$id'");
		return 0;
	}
	function insertLicence( &$vars , $time ) {
		global $Db;
		$host = $Db->dbPrepare($_SERVER['REMOTE_ADDR']);
		$id = $vars['ROOTID'];
		$userID = $vars['USERID'];
		// v6.3.3 Add root to connection tables
		// v6.3.5 Add userID to connection tables
		//$Db->query("INSERT INTO T_Licences (F_UserHost, F_StartTime, F_LastUpdateTime) VALUES
		//	('$host', '$time', '$time')");
		// v6.4.2 Only if userID is passed to you do you use it - see OrchidObjects:getLicenceSlot
		// v6.4.2.4 Use productCode to help with separating different titles for concurrent licences
		$productCode = $vars['PRODUCTCODE'];
		if ($vars['USERID'] < 0) {
			//$Db->query("INSERT INTO T_Licences (F_UserHost, F_StartTime, F_LastUpdateTime, F_RootID) VALUES
			//	('$host', '$time', '$time', '$id')");
			$Db->query("INSERT INTO T_Licences (F_UserHost, F_StartTime, F_LastUpdateTime, F_RootID, F_ProductCode) VALUES
				('$host', '$time', '$time', '$id', $productCode)");
		} else {
			//$Db->query("INSERT INTO T_Licences (F_UserHost, F_StartTime, F_LastUpdateTime, F_RootID, F_UserID) VALUES
			//	('$host', '$time', '$time', '$id', '$userID')");
			$Db->query("INSERT INTO T_Licences (F_UserHost, F_StartTime, F_LastUpdateTime, F_RootID, F_UserID, F_ProductCode) VALUES
				('$host', '$time', '$time', '$id', '$userID', $productCode)");
		}
		return 0;
	}
	function selectInsertedLicence ( &$vars , &$time ) {
		global $Db;
		$host = $Db->dbPrepare($_SERVER['REMOTE_ADDR']);
		$Db->query("SELECT F_LicenceID FROM T_Licences 
				WHERE F_UserHost = '$host' AND F_StartTime = '$time'");
		if ( $Db->num_rows > 0 ) {
			return $Db->result[0][F_LicenceID];
		} else {
			return -1;
		}
        }
	function insertFail (&$vars ) {
		global $Db;
		$now = $Db->now();
		$host = $Db->dbPrepare($_SERVER['REMOTE_ADDR']);
		$id = $vars['ROOTID'];
		$userID = $vars['USERID'];
		$productCode = $vars['PRODUCTCODE'];
		// v6.3.3 Add root to connection tables
		// v6.3.5 Add userID to connection tables
		//sql = "INSERT INTO T_FailSession (F_UserHost, F_StartTime, F_RootID, F_UserID) " &_
		//	"VALUES ( '" & Request.ServerVariables("HTTP_Host") & "', '" & dateFormat(rN) & "', " & CLng(mQ.rootID)  & ", " & CLng(mQ.userID)& ");"
		// v6.4.2 Only if userID is passed to you do you use it - see OrchidObjects:getLicenceSlot
		// v6.4.2.4 Use productCode to help with separating different titles for concurrent licences
		if ($vars['USERID'] < 0) {
			//$Db->query("INSERT INTO T_FailSession (F_UserHost, F_StartTime, F_RootID) 
			//		VALUES ('$host', '$now', '$id')");
			$Db->query("INSERT INTO T_FailSession (F_UserHost, F_StartTime, F_RootID, F_ProductCode) 
					VALUES ('$host', '$now', '$id', $productCode)");
		} else {
			//$Db->query("INSERT INTO T_FailSession (F_UserHost, F_StartTime, F_RootID, F_UserID) 
			//		VALUES ('$host', '$now', '$id', '$userID')");
			$Db->query("INSERT INTO T_FailSession (F_UserHost, F_StartTime, F_RootID, F_UserID, F_ProductCode) 
					VALUES ('$host', '$now', '$id', '$userID', $productCode)");
		}
		return 0;
	}
}
?>
