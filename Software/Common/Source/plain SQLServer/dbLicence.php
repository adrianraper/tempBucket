<?php

class LICENCE {
	function LICENCE() {
		// v6.5.5.1 Be more responsive since the licence is held every minute
		//$this->delay = 10; // minutes
		$this->delay = 2; // minutes
	}

	// v6.5.5.0 Different process for different licence types
	function getTrackingLicenceSlot( &$vars, &$node ) {
		global $db;
		
		// v6.5.5.0 Tracking licence uses now based on the time the user sends
		$this->dateNow = $vars['DATESTAMP'];

		// v6.5.5.0 We don't try to limit teachers
		if ($vars['USERTYPE']==0) {
			// v6.5.5.0 First of all see if this user has already used a licence
			if ($this->checkExistingLicence( $vars, $node)) {
				// They have, so update the time that we used it to now
				// v6.5.5.0 Remove this as we are dropping T_Licences in favour of T_Session
				//$rC = $this->udpateLicence( $vars, $node );
				$node .= "<note>use existing licence</note>";
			} else {
				// This is a new licence, check to see if we have space
				$rC = $this->checkAvailableLicences( $vars, $node );
				//if ($rC) {
					// We do, so record it
					// v6.5.5.0 Remove this as we are dropping T_Licences in favour of T_Session
					//$rC = $this->addNewLicence( $vars, $node );
				//}
			}
		} else {
			// v6.5.6 We must send back a licence ID now
			$node .= "<licence id='0'/>";
			$node .= "<note>You are more than a student</note>";
		}
	}
	//function getLicenceSlot( &$vars, &$node ) {
	function getConcurrentLicenceSlot( &$vars, &$node ) {
		global $db;
	
		// v6.5.5.0 Tracking licence uses now based on the server (to be more accurate)
		// Although maybe I should use the client time as that might help work out if odd stuff is happening?
		//$this->dateNow = date('Y-m-d H:i:s', time());
		// v6.5.6 But I don't send this variable!
		//$this->dateNow = $vars['DATESTAMP'];
		$this->dateNow = date('Y-m-d H:i:s', time());

		$liT = $vars['LICENCES'];
		if ($liT < 1) {
			$node .= "<err code='201'>your licence is invalid (0 users)</err>";
			return false;
		}

		if (isset($vars['LICENCEID'])) {
			$sT = $this->countLicences($vars, 0, 0);
			if ($sT > 0) {
				// this seems to be for matching an existing licenceID - not sure why you don't send back a node
				// v6.5.5.1 Add one
				$node .= "<licence ID='".$vars['LICENCEID']."' note='use existing' />";
				return true;
			}
		}

		$liN = $this->countLicences($vars, 1, 0);	
		//$node .= "<note>compare liN and liT=$liN, $liT</note>";
		//print 'licences used=' .$liN .'    ';
		if ($liN < $liT) {
			// There are available slots, so just take one.
			return $this->insertLicenceRecord(  $vars, $liN, $liT, $node );
		}

		// v6.5.5.1 At this point revoke old licences, then repeat the simple count
		/*
		//$timeNow = time();
		//$dateNow = date('Y-m-d H:i:s', $timeNow);
		$aWhileAgo = time() - $this->delay*60; // seconds
		$dateconv = date('Y-m-d H:i:s', $aWhileAgo);
		//$node .= "<note>now is $dateNow, 10 mins ago is $dateconv</note>";
		
		//print 'date='.$dateadd;	
		$ord = $this->countLicences($vars, 2, $dateconv);
		//$node .= "<note>licences older than $dateconv=$ord</note>";
		//print 'old licences=' .$ord .'    ';	
		if ($ord > 0) {
			$returnCode = $this->deleteLicencesOld(  $vars, $dateconv );
			$liN -= $ord;
			$node .= "<warning>$ord licence(s) revoked</warning>";
			if ($liN < $liT)
				return $this->insertLicenceRecord(  $vars, $liN, $liT, $node );
			else {
				$node .= "<err code='201'>no free licences ($liN)</err>";
				return false;
			}
		} else {
			$node .= "<err code='201'>no free licences ($liN)</err>";
			return false;
		}
		*/
		$aWhileAgo = time() - $this->delay*60; // seconds
		$dateconv = date('Y-m-d H:i:s', $aWhileAgo);
		$node .= "<note>$this->delay mins ago is $dateconv</note>";
		$returnCode = $this->deleteLicencesOld(  $vars, $dateconv );
		// repeat the count
		$liNN = $this->countLicences($vars, 1, 0);
		if ($liNN<$liN) {
			$node .= "<warning>".intval($liN-$liNN)." licence(s) revoked</warning>";
			if ($liNN < $liT) {
			// Now there are enough free slots
				return $this->insertLicenceRecord(  $vars, $liNN, $liT, $node );
			} else {
				$vars['ERRORREASONCODE'] = 212;
				$node .= "<err code='212'>still no free licences ($liNN)</err>";
				return false;
			}
		} else {
			$vars['ERRORREASONCODE'] = 212;
			$node .= "<err code='212'>no free licences ($liN)</err>";
			return false;
		}
	}
	// v6.5.5.0 This is used for concurrent and tracking licences
	function updateLicence( &$vars, &$node ) {
		global $db;
	
		$returnCode = $this->updateLicenceRecord($vars );
		
		//if ($Db->affected_rows > 0) {
		if ($returnCode) {
			$id = $vars['LICENCEID'];
			$node .= "<licence id='" .$id . "'>updated</licence>";
			return true;
		} else {
			$node .= "<err code='203'>your licence can not be updated: ".$db->ErrorMsg()."</err>";
			return false;
		}	
	}
	// This call is duplicated in dbProgress so that stopUser can call it directly
	function dropLicence( &$vars , &$node) {

		$returnCode = $this->deleteLicencesID($vars);
	
		//if ($Db->affected_rows > 0) {
		if ($returnCode) {
			$id = $vars['LICENCEID'];
			$node .= "<licence id='$id'>dropped</licence>";
			return true;
		} else {
			$node .= "<err code='203'>your licence can not be updated: ".$db->ErrorMsg()."</err>";
			return false;
		}	
	}
	function failLicenceSlot( &$vars, &$node ) {
		$returnCode = $this->insertFail( $vars );
		if ($returnCode) {
			$node .= "<note>licence failure recorded</note>";
			return true;
		} else {
			$node .= "<note>licence failure can not be noted: ".$db->ErrorMsg()."</note>";
			return false;
		}	
	}
	function insertLicenceRecord( &$vars, $liN, $liT, &$node) {
		global $db;
	
		// v6.5.4.5 use Akamai header if applicable
		// This can trigger a PHP warning if not present, so wrap with array_key_exists
		if (array_key_exists('HTTP_TRUE_CLIENT_IP', $_SERVER)) {
			$userIP = $_SERVER['HTTP_TRUE_CLIENT_IP'];
		} else {
			$userIP = $_SERVER['REMOTE_ADDR'];
		}
		$rootID = $vars['ROOTID'];
		// v6.5.6 It is possible that this is a list of roots, in which case take the first as the default
		$rootArray = explode(",", $rootID);
		$singleRootID = $rootArray[0];
		if (isset($this->dateNow)) {
			$dateNow = $this->dateNow;
		} else {
			$dateNow = date('Y-m-d H:i:s', time());
		}
		$productCode = $vars['PRODUCTCODE'];
		$userID = $vars['USERID'];
		if ($userID=="") {
			$userID=null; // will this get correctly converted?
		}
		$bindingParams = array($userIP, $dateNow, $dateNow, $rootID, $productCode, $userID);
		//v6.5.4.5 New database has proper datetime fields. Old one did too for this table
		//if ($vars['DATABASEVERSION']>1) {		
			// v6.5.5.5 MySQL migration
			//	('$userIP', CONVERT(datetime,'$dateNow',120), CONVERT(datetime,'$dateNow',120), $rootID, $productCode, $userID)
			//	('$userIP', '$dateNow', '$dateNow', $rootID, $productCode, $userID)
			$sql = <<<EOD
				INSERT INTO T_Licences (F_UserHost, F_StartTime, F_LastUpdateTime, F_RootID, F_ProductCode, F_UserID) VALUES
				('$userIP', '$dateNow', '$dateNow', $singleRootID, $productCode, $userID)
EOD;
		//		(?, CONVERT(datetime,?,120), CONVERT(datetime,?,120), ?, ?, ?)
		//} else {
		//	$sql = <<<EOD
		//		INSERT INTO T_Licences (F_UserHost, F_StartTime, F_LastUpdateTime, F_RootID, F_ProductCode, F_UserID) VALUES
		//		(?, ?, ?, ?, ?, ?)
//EOD;
		//}
		//$rs = $db->Execute($sql, $bindingParams);
		$rs = $db->Execute($sql);
		// v6.5.4.8 adodb will get the identity ID (F_LicenceID) for us.
		// Except that it fails. Seems due to fact that with parameters, the insert is in a different scope to the identity scope call so fails. 
		// If I don't do it with parameters then it works. Seems safe since nothing is typed by the user.
		$id = $db->Insert_ID();

		// v6.5.4.5 New database has proper datetime fields
		// Just in case the identity check doesn't work
		if ($id == false) {
			// v6.5.5.5 MySQL migration
			//	AND F_StartTime=CONVERT(datetime,?,120) 
			$sql = <<<EOD
				SELECT MAX(F_LicenceID) as licenceID FROM T_Licences 
				WHERE F_UserHost=?
				AND F_StartTime=?
EOD;
			$bindingParams = array($userIP, $dateNow);
			$rs = $db->Execute($sql, $bindingParams);

			if ( $rs->RecordCount()==1 ) {
				$dbObj = $rs->FetchNextObj();
				$id = $dbObj->licenceID;
			} else {
				$id= -1;
			}
		}
		
		if ( $id > 0 ) {
			$liN++;
			//$node .= "<licence host='$userIP' ID='$id' note='$liN of $liT' />";
			$node .= "<licence host='$userIP' ID='$id' note='$liN of $liT' root='$singleRootID' />";
			return true;
		} else {
			$node .= "<err code='202'>failed to insert licence record</err>";
			return false;
		}
	}

	// v6.5.5.0 For concurrent checking
	function countLicences( &$vars, $mode, $updateTime ) {
	
		global $db;
		
		$rootID = $vars['ROOTID'];
		$productCode = $vars['PRODUCTCODE'];
		$userID = $vars['USERID'];
		$extraClause = '';
		//$bindingParams = array($rootID, $productCode);
		$bindingParams = array($productCode);
		// v6.5.5.5 This is old code that was created for APL. We are now always sending userID, so we certainly don't want to include it here!
		//if ($userID >= 0) {
		//	$extraClause .= "AND F_UserID=? ";
		//	$bindingParams[] = $userID;
		//}
			
		// mode 0 not relevant I think
		if ($mode == 0) {
			$licenceID = $vars['LICENCEID'];
			//print ' id='.$id.' ';
			$extraClause .= "AND F_LicenceID=? ";
			$bindingParams[] = $licenceID;
			
		// mode 2 no longer used
		} else if($mode == 2) {
			//v6.5.4.5 New database has proper datetime fields. Old one did too for this table
			//if ($vars['DATABASEVERSION']>1) {		
			// v6.5.5.5 MySQL migration
			//$extraClause .= " AND F_LastUpdateTime < CONVERT(datetime,?,120) ";
			$extraClause .= " AND F_LastUpdateTime < ? ";
			//} else {
			//	$extraClause .= " AND F_LastUpdateTime < ? ";
			//}
			$bindingParams[] = $updateTime;
			//print $makeQuery;
		}
		// v6.5.6 It is possible that you will send a comma delimited list of roots rather than just one.
		//		WHERE F_RootID=? 
		$sql = <<<EOD
			SELECT COUNT(F_LicenceID) as i FROM T_Licences 
				WHERE F_RootID in ($rootID) 
				AND F_ProductCode=? 
				$extraClause
EOD;
		$rs = $db->Execute($sql, $bindingParams);
		$dbObj = $rs->FetchNextObj();
		return $dbObj->i;
	}	

	function deleteLicencesID( &$vars) {
		global $db;
		$id = $vars['LICENCEID'];
		$bindingParams = array($id);
		$sql = <<<EOD
			DELETE FROM T_Licences WHERE F_LicenceID=? 
EOD;
		$rs = $db->Execute($sql, $bindingParams);
		if (!$rs) {
			// the sql call failed
			return false;
		} else {
			return true;
		};
	}
	function deleteLicencesOld( &$vars , $updateTime) {
		global $db;
		// v6.5.5.1 Either this SQL should clear out ALL old licences, or it should just do it for this product/root.
		// It should also stop any records that are bad - such as ones that have F_StartTime but no F_LastUpdateTime.
		// This situation shouldn't happen since insertLicenceRecord makes sure that both are filled in, but it does.
		
		// v6.4.2.4 Use productCode to help with separating different titles for concurrent licences
		// v6.4.2.6 correction
		//$productCode = $vars['LICENCEID'];
		$productCode = $vars['PRODUCTCODE'];
		$rootID = $vars['ROOTID'];
		// v6.5.6 It is possible that this is a list of roots, in which case take the first as the default
		$rootArray = explode(",", $rootID);
		$singleRootID = $rootArray[0];
		
		//$Db->query("DELETE FROM T_Licences WHERE F_LastUpdateTime < $jn");
		//v6.5.4.5 New database has proper datetime fields. Old one did too for this table
		//if ($vars['DATABASEVERSION']>1) {		
			// v6.5.5.5 MySQL migration
			//	WHERE (F_LastUpdateTime<CONVERT(datetime,?,120) OR F_LastUpdateTime is null) 
			$sql = <<<EOD
				DELETE FROM T_Licences 
				WHERE (F_LastUpdateTime<? OR F_LastUpdateTime is null) 
				AND F_ProductCode=? 
				AND F_RootID=? 
EOD;
		//} else {
		//	$sql = <<<EOD
		//		DELETE FROM T_Licences 
		//		WHERE F_LastUpdateTime<? 
		//		AND F_ProductCode=? 
//EOD;
		//}
		//$bindingParams = array($updateTime, $productCode, $rootID);
		$bindingParams = array($updateTime, $productCode, $singleRootID);
		$rs = $db->Execute($sql, $bindingParams);
		if (!$rs) {
			// the sql call failed
			return false;
		} else {
			return true;
		};
	}
	// Just for concurrent licences
	function updateLicenceRecord( &$vars ) {
		global $db;
		$id = $vars['LICENCEID'];
		// v6.5.5.0 Should I use $vars['datestamp'] to get the user's own dates rather than the server time?
		//$dateNow = $this->dateNow;
		if (isset($this->dateNow)) {
			$dateNow = $this->dateNow;
		} else {
			$dateNow = date('Y-m-d H:i:s', time());
		}
		// v6.5.5.1 but the SQL doesn't fail if the F_LicenceID is missing, it just updates 0 records. No good to us.
		// So need to use a SELECT first
		$sql = <<<EOD
			SELECT * FROM T_Licences 
			WHERE F_LicenceID=?
EOD;
		$bindingParams = array($id);
		$rs = $db->Execute($sql, $bindingParams);
		// Confirm that there is one and only one record for this licenceID
		if ( $rs->RecordCount()==1 ) {
			// Just in case it would be best to clear this recordset up before doing another query
			$rs->Close();
			//v6.5.4.5 New database has proper datetime fields. Old one did too for this table
			// v6.5.5.5 MySQL migration
			//	SET F_LastUpdateTime=CONVERT(datetime,?,120) 
			$sql = <<<EOD
				UPDATE T_Licences 
				SET F_LastUpdateTime=?
				WHERE F_LicenceID=?
EOD;
			$bindingParams = array($dateNow, $id);
			$rs = $db->Execute($sql, $bindingParams);
			if (!$rs) {
				// the sql call failed
				return false;
			} else {
				return true;
			};
		} else {
			// No such licence - oh dear
			return false;
		}
	}
	
	function insertFail (&$vars ) {
		global $db;
		
		//$dateNow = $this->dateNow;
		if (isset($this->dateNow)) {
			$dateNow = $this->dateNow;
		} else {
			$dateNow = date('Y-m-d H:i:s', time());
		}
		// v6.5.4.5 use Akamai header if applicable
		// This can trigger a PHP warning if not present, so wrap with array_key_exists
		if (array_key_exists('HTTP_TRUE_CLIENT_IP', $_SERVER)) {
			$userIP = $_SERVER['HTTP_TRUE_CLIENT_IP'];
		} else {
			$userIP = $_SERVER['REMOTE_ADDR'];
		}
		$rootID = $vars['ROOTID'];
		$userID = $vars['USERID'];
		$productCode = $vars['PRODUCTCODE'];
		$reasonCode = $vars['ERRORREASONCODE'];
		
		//v6.5.4.5 New database has proper datetime fields. Old one did too for this table
		//if ($vars['DATABASEVERSION']>1) {		
			// v6.5.5.5 MySQL migration
			//	VALUES (?, CONVERT(datetime,?,120), ?, ?, ?, ?)
			// v6.5.6 Capitalisation
			//	INSERT INTO T_FailSession (F_UserIP, F_StartTime, F_RootID, F_UserID, F_ProductCode, F_ReasonCode)
			$sql = <<<EOD
				INSERT INTO T_Failsession (F_UserIP, F_StartTime, F_RootID, F_UserID, F_ProductCode, F_ReasonCode)
				VALUES (?, ?, ?, ?, ?, ?)
EOD;
		//} else {
		//	$sql = <<<EOD
		//		INSERT INTO T_FailSession (F_UserIP, F_StartTime, F_RootID, F_UserID, F_ProductCode, F_ReasonCode)
		//		VALUES (?, ?, ?, ?, ?, ?)
//EOD;
		//}
		$bindingParams = array($userIP, $dateNow ,$rootID, $userID, $productCode, $reasonCode);
		$rs = $db->Execute($sql, $bindingParams);
		if (!$rs) {
			// the sql call failed
			return false;
		} else {
			return true;
		};
	}
	// new functions for simultaneous login
	// v6.5.5.0 This is not licence, it is instance for stopping double login
	//function setLicenceID (&$vars, &$node  ) {
	function setInstanceID (&$vars, &$node  ) {
		global $db;
		
		// v6.5.4.5 use Akamai header if applicable
		// This can trigger a PHP warning if not present, so wrap with array_key_exists
		if (array_key_exists('HTTP_TRUE_CLIENT_IP', $_SERVER)) {
			$userIP = $_SERVER['HTTP_TRUE_CLIENT_IP'];
		} else {
			$userIP = $_SERVER['REMOTE_ADDR'];
		}
		//$licenceID = $vars['LICENCEID'];
		$instanceID = $vars['INSTANCEID'];
		$userID = $vars['USERID'];
		
		$sql = <<<EOD
			UPDATE T_User 
			SET F_UserIP=?, F_LicenceID=? 
			WHERE F_UserID=? 
EOD;
		//$bindingParams = array($userIP, $licenceID ,$userID);
		$bindingParams = array($userIP, $instanceID ,$userID);
		$rs = $db->Execute($sql, $bindingParams);
		if ($rs) {
			$node .= "<instance>$instanceID</instance>";
			return true;
		} else {
			$node .= "<err code='202'>failed to insert instance: ".$db->ErrorMsg()."</err>";
			return false;
		}
	}
	// v6.5.5.0 This is not licence, it is instance for stopping double login
	//function getLicenceID (&$vars, &$node  ) {
	function getInstanceID (&$vars, &$node  ) {
		global $db;
		
		$userID = $vars['USERID'];	
		$sql = <<<EOD
			SELECT F_LicenceID, F_UserIP FROM T_User 
			WHERE F_UserID=? 
EOD;
		$bindingParams = array($userID);
		$rs = $db->Execute($sql, $bindingParams);
		if ( $rs->RecordCount()==1 ) {
			$dbObj = $rs->FetchNextObj();
			//$licenceID = $dbObj->F_LicenceID;
			$instanceID = $dbObj->F_LicenceID;
			$userIP = $dbObj->F_UserIP;
			//$node .= "<licence id='$licenceID' userIP='$userIP' />";
			$node .= "<instance id='$instanceID' userIP='$userIP' />";
		//	error_log($node."\n", 3, "debugs.log");
			return true;
		} else {
			$node .= "<err>instance not recorded</err>";
		//	error_log($node."\n", 3, "debugs.log");
			return false;
		}
	}
	// v6.5.5.0 Moved from dbProgress scripts
	// Used for licence control (Learner Tracking licence)
	function checkExistingLicence ( &$vars, &$node ) {
		global $db;
		$uid  = $vars['USERID'];
		$pid  = $vars['PRODUCTCODE'];
		$rootID = $vars['ROOTID'];
		// v6.5.5.0 This should also include the licenceStartDate as we will ignore records before this date
		$datestamp = $vars['LICENCESTARTDATE'];
		// v6.5.5.0 Use lastUpdateTime instead of the initial time the licence was created
		// AND F_StartTime>=CONVERT(datetime,?,120)
		// v6.5.5.0 Change SQL call entirely to be based on T_Session instead of T_Licences which will be dropped
		// what we want to know now is has this user started a session on this product since the licenceStartDate?
		//	SELECT F_LicenceID FROM T_Licences 
		//	WHERE F_UserID=? 
		//	AND F_ProductCode=? 
		//	AND F_LastUpdateTime>=CONVERT(datetime,?,120)
		// v6.5.5.5 MySQL migration
		//	AND s.F_StartDateStamp  >= convert(datetime, ?, 120)
		// v6.5.6 It is possible that you will send a comma delimited list of roots rather than just one.
			// and what if you send a wildcard? Meaning that ALL roots should be checked (such as HCT)
		//	AND s.F_RootID=?
		// v6.5.6.6 BUT if you are only counting sessions that have scores as part of licence control, you should do the same with existing licences!
		$sql = <<<EOD
			SELECT COUNT(s.F_SessionID) as Sessions
			FROM T_Session s
			WHERE s.F_UserID=?
				AND s.F_ProductCode = ?
				AND s.F_StartDateStamp  >= ?
				AND EXISTS (SELECT * FROM T_Score c WHERE c.F_SessionID=s.F_SessionID)
EOD;
		if ($rootID!='*') {
			$sql.= " AND s.F_RootID in ($rootID)";
		}
		//$bindingParams = array($uid, $pid);
		$bindingParams = array($uid, $pid, $datestamp);      //by Edward
		// $bindingParams = array($uid, $pid, $datestamp, $rootID);
		$rs = $db->Execute($sql, $bindingParams);
		// Don't use the count, but send back the licenceID if any
		//return $rs->RecordCount()>0;
		//if ($rs->RecordCount()>0 ) {
		$dbObj = $rs->FetchNextObj();
		if ($dbObj->Sessions>0 ) {
			//$dbObj = $rs->FetchNextObj();
			// save the ID so we can use it for updating
			// never mind, no updating will happen
			$node .= "<licence id='0'/>";
			//$vars['LICENCEID'] = $dbObj->F_LicenceID;
			return true;
		} else {
			return false;
		}
	}
	// v6.5.5.0 This is for tracking licences
	function checkAvailableLicences( &$vars, &$node) {
		global $db;
		if ($vars['DATABASEVERSION']>1 ) {
			// Count the number of students who have accessed this title since the start of the current licence period
			// It shouldn't be possible to have a duplicate userID. But just in case add in DISTINCT
			//	SELECT COUNT(u.F_UserID) AS licencesUsed FROM T_Licences c, T_User u
			// Oh, and certainly we need to add in the rootID! 
			// v6.5.5.0 Drop T_Licences in favour of the T_Session table
			//	SELECT COUNT(DISTINCT u.F_UserID) AS licencesUsed FROM T_Licences c, T_User u
			//	WHERE u.F_UserType=0
			//	AND c.F_UserID=u.F_UserID
			//	AND c.F_ProductCode=? 
			//	AND c.F_RootID=? 
			//	AND c.F_StartTime >= CONVERT(datetime, ?, 120)
			// v6.5.5.5 MySQL migration
			//	AND s.F_StartDateStamp>CONVERT(datetime,?,120)
			// v6.5.6 It is possible that you will send a comma delimited list of roots rather than just one.
			// and what if you send a wildcard? Meaning that ALL roots should be checked (such as HCT)
			//	WHERE s.F_RootID=?
			// v6.5.6.4 RM has a much more sophisticated system.
			//	1) Deleted users are not counted here
			//	2) Users who start a session but no scores should be counted
			// AR It might be useful to let this module pick up the licence start date (assuming you send a root) if it is not set.
			//  This would make it useful to non-Orchid programs as well.
			// v6.5.6.6 Change the rules for a Transferable Licence (6) - in which case you only care about active students
			// Drop the check on a EXISTS score as I think this slows things down considerably. Mind you - it is very fast on production
			$rootID = $vars['ROOTID'];
			// v6.5.6 SciencesPo temporary workround
			if ($rootID==14652) {
				$node .= "<licence id='0' users='99' active='49' deleted='0' />"; 
				return true;
			}
			/*
			$sql = <<<EOD
				SELECT COUNT(DISTINCT s.F_UserID)  AS licencesUsed
				FROM T_Session s, T_User u
				WHERE s.F_RootID in ($rootID)
				AND s.F_ProductCode=?
				AND u.F_UserID = s.F_UserID
				AND u.F_UserType=0
				AND s.F_StartDateStamp>?
EOD;
			*/
			//	AND s.F_StartDateStamp>CONVERT(datetime,?,120) 
			$sql = <<<EOD
				SELECT COUNT(DISTINCT s.F_UserID)  AS activeStudentCount
				FROM T_Session s, T_User u
				WHERE s.F_ProductCode=?
				AND u.F_UserID = s.F_UserID
				AND u.F_UserType=0
				AND s.F_StartDateStamp>?
				AND EXISTS (SELECT * FROM T_Score c WHERE c.F_SessionID=s.F_SessionID)
EOD;
			if ($rootID!='*') {
				$sql.= " AND s.F_RootID in ($rootID)";
			}
			//$bindingParams = array($vars['ROOTID'], $vars['PRODUCTCODE'], $vars['LICENCESTARTDATE'] );
			$bindingParams = array($vars['PRODUCTCODE'], $vars['LICENCESTARTDATE'] );
			$rs = $db->Execute($sql, $bindingParams);
			if ($rs->RecordCount()==0) {
				// throw an error should be impossible
				return false;
			}
			$dbObj = $rs->FetchNextObj();
			//$licencesUsed = (int)$dbObj->licencesUsed;
			$activeLicencesUsed = (int)$dbObj->activeStudentCount;

			//$node .= "<note licenceType='". $vars['LICENCETYPE'] ."' />";
			if ($vars['LICENCETYPE']=='6') {
				$orphanedLicencesUsed=0;
			} else {
				// See above why need to also count sessions that have no active users.
				$sql = <<<EOD
					SELECT COUNT(DISTINCT s.F_UserID) AS allDeletedCount
					FROM T_Session s
					left join T_User u
					on s.F_UserID = u.F_UserID
					WHERE s.F_ProductCode=?
					AND u.F_UserID IS NULL
					AND s.F_UserID > 0
					AND s.F_StartDateStamp>?
EOD;
				if ($rootID!='*') {
					$sql.= " AND s.F_RootID in ($rootID)";
				}
				$rs = $db->Execute($sql, $bindingParams);
				if ($rs->RecordCount()==0) {
					// throw an error should be impossible
					return false;
				}
				$dbObj = $rs->FetchNextObj();
				$orphanedLicencesUsed = (int)$dbObj->allDeletedCount;
			}
			
			// Add them up
			$licencesUsed = $activeLicencesUsed + $orphanedLicencesUsed;
			
			// Compare against the licence the school purchased
			if ($licencesUsed>=$vars['LICENCES']) {
				$vars['ERRORREASONCODE'] = 211;
				$node .= "<err code='211' userID='".$vars['USERID']."' licencesUsed='$licencesUsed'>No licences available</err>";
				return false;
			} else {
				//$node .= "<note>$licences licences have now been used.</note>";
				$node .= "<licence id='0' users='$licencesUsed' active='$activeLicencesUsed' deleted='$orphanedLicencesUsed' />"; // Just to let us know that all is well, what is a better return for the id?
			}
		}
		return true;
	}
	// v6.5.5.0 Drop this in favour of using the T_Session table for tracking licences
	/*
	function addNewLicence( &$vars, &$node ) {
		
		// v6.5.4.5 Finally update the table with the licenceID
		if ($vars['DATABASEVERSION']>1) {		
			return $this->insertLicenceCount( $vars, $node );
		}
		return true;
	}
	// Used for licence control (Learner Tracking licence)
	function insertLicenceCount (&$vars, &$node) {
		global $db;
		$userID = $vars['USERID'];
		$pid = $vars['PRODUCTCODE'];
		$rootID = $vars['ROOTID'];
		$datestamp = $vars['DATESTAMP'];
		$sql = <<<EOD
			INSERT INTO T_Licences ([F_UserID], [F_ProductCode], [F_RootID], [F_StartTime], [F_LastUpdateTime])
			VALUES($userID,$pid,$rootID,CONVERT(datetime,'$datestamp',120), CONVERT(datetime,'$datestamp',120))
EOD;
		// v6.5.4.7 We pass dates to php as strings in canonical ODBC format. So to convert to datetime use CONVERT(datetime, $formattedString, 120)
		// $bindingParams = array($userID, $pid, $rootID, strtotime($datestamp));
		$bindingParams = array($userID, $pid, $rootID, $datestamp);
		// v6.5.4.8 adodb will get the identity ID (F_LicenceID) for us.
		// Except that it fails. Seems due to fact that with parameters, the insert is in a different scope to the identity scope call so fails. 
		// If I don't do it with parameters then it works. Seems safe since nothing is typed by the user.
		//	VALUES(?,?,?,CONVERT(datetime,?,120))
		//$rs = $db->Execute($sql, $bindingParams);
		$rs = $db->Execute($sql);
		$id = $db->Insert_ID();
		if ( $id > 0 ) {
			$node .= "<licence id='$id' />";
			return true;
		} else {
			$node .= "<err code='202'>failed to insert licence record</err>";
			return false;
		}
	}
	*/

}
?>
