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
			//echo $db->database;
			// v6.5.5.0 First of all see if this user has already used a licence
			$licenceID = $this->checkExistingLicence( $vars, $node);
			if ($licenceID) {
				// They have, so update the time that we used it to now
				// v6.5.5.0 Remove this as we are dropping T_Licences in favour of T_Session
				//$rC = $this->updateLicence( $vars, $node );
				// v6.5.6.7 Add back in
				// v6.6.0 Licence control solely through T_Session
				//$rC = $this->updateLicenceControl( $vars, $licenceID );
				//if ($rC) {
					$node .= "<note>use existing licence</note>";
				//} else {
				//	$node .= "<err code='203'>your licence can not be updated: ".$db->ErrorMsg()."</err>";
				//}
			} else {
				// This is a new licence, check to see if we have space
				// IF this is an account where we are really just counting licences used rather than setting a limit
				// (such as BC Global R2I) there is not much point doing this.
				// In particular for GlobalR2I this is a VERY expensive call. And totally unnecessary.
				// 6.6.0 In fact, it ought to be a type of tracking licence - CountTrackingLicence
				if (stristr($db->database, 'GlobalRoadToIELTS')!==false) {
					$node .= "<licence id='0' />";
					$node .= "<note>skip check because db=".$db->database."</note>";
				} else {
					$rC = $this->checkAvailableLicences( $vars, $node );
				}
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
	
		// Whilst rootID might be a comma delimited list, you can treat
		// licence control as simply use the first one in the list
		$rootID = $vars['ROOTID'];
		if (stristr($rootID, ',')) {
			$rootArray = explode(',', $rootID);
			$singleRootID = $rootArray[0];
		} else {
			$singleRootID = $rootID;
		}
		
		// v6.6.0 To follow Bento we should now do it like this:
		// First, delete all old licences
		$aWhileAgo = time() - $this->delay * 60;
		$updateTime = date('Y-m-d H:i:s', $aWhileAgo);
		$productCode = $vars['PRODUCTCODE'];
		$licences = $vars['LICENCES'];

		$sql = <<<EOD
		DELETE FROM T_Licences 
		WHERE F_ProductCode=? 
		AND F_RootID=?
		AND (F_LastUpdateTime<? OR F_LastUpdateTime is null) 
EOD;
		$bindingParams = array($productCode, $singleRootID, $updateTime);
		$rs = $db->Execute($sql, $bindingParams);
		if (!$rs) {
			// Write a record to the failure table - NO, this is done by Orchid itself
			//$failLicenceSlot($vars, $node);
			$node .= "<err code='201'>Can't clear out old licences</err>";
			return false;
		}
		
		// Then count how many are currently in use
		$sql = <<<EOD
		SELECT COUNT(F_LicenceID) as i FROM T_Licences 
		WHERE F_ProductCode=?
		AND F_RootID=? 
EOD;
		$bindingParams = array($productCode, $singleRootID);			
		$rs = $db->Execute($sql, $bindingParams);
		$usedLicences = $rs->FetchNextObj()->i;
		
		if ($usedLicences >= $licences) {
			$vars['ERRORREASONCODE'] = 212;
			$node .= "<err code='212'>still no free licences ($usedLicences of $licences)</err>";
			return false;
		}

		// Finally insert this user in the licence control table
		$this->dateNow = date('Y-m-d H:i:s');
		return $this->insertLicenceRecord(  $vars, 'x', 'y', $node );

	}
	// v6.5.6.7 This is used for tracking licences
	// v6.6.0 Simply use T_Session so no need for this
	function updateLicenceControl( $vars, $licenceID ) {
		//global $db;
		//$returnCode = $this->updateLicenceControlRecord($vars, $licenceID );
		//if ($returnCode) {
			return true;
		//} else {
		//	return false;
		//}	
	}
	// v6.5.6.7 This is used for tracking licences
	// v6.6.0 Deprecated
	/*
	function updateLicenceControlRecord( &$vars, $id ) {
		global $db;
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
			SELECT * FROM T_LicenceControl
			WHERE F_LicenceID=?
EOD;
		$bindingParams = array($id);
		$rs = $db->Execute($sql, $bindingParams);
		// Confirm that there is one and only one record for this licenceID
		if ( $rs->RecordCount()==1 ) {
			$rs->Close();
			$sql = <<<EOD
				UPDATE T_LicenceControl
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
	*/
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
		global $db;

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
		global $db;
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
			//$liN++;
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
		} else if ($mode == 2) {
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
	
		// v6.6.0 If you pick up something like account expired, you might not know the rootID at this point
		if ($rootID=='')
			return false;
			
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
	// Duplicated in dbProgress
	function setInstanceID (&$vars, &$node  ) {
		global $db;
		$node .= "<note>in dbLicence.setInstanceID - unexpected</note>";
		
		if (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
			// This might show a list of IPs. Assume/hope that EZProxy puts itself at the head of the list.
			$ipList = explode(',',$_SERVER['HTTP_X_FORWARDED_FOR']);
			$ip = $ipList[0];
		} elseif (isset($_SERVER['HTTP_TRUE_CLIENT_IP'])) {
			$ip=$_SERVER['HTTP_TRUE_CLIENT_IP'];
		} elseif (isset($_SERVER["HTTP_CLIENT_IP"])) {
			$ip = $_SERVER["HTTP_CLIENT_IP"];
		} else {
			$ip = $_SERVER["REMOTE_ADDR"];
		}
		
		$instanceID = $vars['INSTANCEID'];
		$userID = $vars['USERID'];
		// v6.6.0 CS and IIE don't pass productCode, so just have to lump them together
		if (!isset($vars['PRODUCTCODE'])) {
			$productCode = 0;
		} else {
			$productCode = $vars['PRODUCTCODE'];
		}
		// v6.5.5.0 Needs coordinated action to change the database field name
		// v6.6 Updated field name to instanceID and make is multiple product
		
		// Get the existing set of instance IDs and add/update for this title
		$instanceArray = $this->getInstanceArray($userID);
		$instanceArray[$productCode] = $instanceID;
		$instanceControl = json_encode($instanceArray);
		
		$sql = <<<EOD
		UPDATE T_User u					
		SET u.F_UserIP=?, u.F_InstanceID=? 
		WHERE u.F_UserID=?
EOD;
		$bindingParams = array($ip, $instanceControl, $userID);
		$resultObj = $db->Execute($sql, $bindingParams);
		if ($resultObj) {
			$node .= "<instance>$instanceID</instance>";
			return true;
		} else {
			$node .= "<err code='202'>failed to insert instance: ".$db->ErrorMsg()."</err>";
			return false;
		}
	}
	// v6.5.5.0 This is not licence, it is instance for stopping double login
	// v6.6 Updated for multiple titles and different db field. Duplicated in dbProgress.php
	//function getLicenceID (&$vars, &$node  ) {
	function getInstanceID (&$vars, &$node  ) {
		global $db;
		
		$userID = $vars['USERID'];
		// v6.6.0 CS and IIE don't pass productCode, so just have to lump them together
		// Because SQU can't clear objects.swf they are stuck in a terrible loop. So overwrite their productCode to always use 0
		// BUT, you never pass rootID to here, so this doesn't work
		//if (isset($vars['ROOTID']) && $vars['ROOTID']==14265) {
		//	$productCode = 0;
		if (!isset($vars['PRODUCTCODE'])) {
			$productCode = 0;
		} else {
			$productCode = $vars['PRODUCTCODE'];
		}
		
		// #319 Instance ID per productCode
		$instanceArray = $this->getInstanceArray($userID);
		
		if (isset($instanceArray[$productCode])) {
			$instanceID = $instanceArray[$productCode];
			$node .= "<instance id='$instanceID' />";
			return true;
			
		} else {
			$node .= "<err>instance not recorded</err>";
			return false;
		}
	}

	/**
	 * Helper function to turn string to array
	 */
	function getInstanceArray($userID) {
		global $db;
		$sql = <<<EOD
		SELECT u.F_InstanceID as control
		FROM T_User u					
		WHERE u.F_UserID = ?
EOD;
		$bindingParams = array($userID);
		$rs = $db->Execute($sql, $bindingParams);
		if ($rs && $rs->RecordCount() == 1) {
			
			// Use JSON to encode an array into a string for the database
			return json_decode($rs->FetchNextObj()->control, true);
		}
		
		return array();
	}
		
	// v6.5.5.0 Moved from dbProgress scripts
	// Used for licence control (Learner Tracking licence)
	// v6.5.6.7 Change to T_LicenceControl table
	// Note that there are parallel functions in dbProgress for writing records.
	// v6.6.0 T_session licence control
	function checkExistingLicence ( &$vars, &$node ) {
		global $db;
		$uid  = $vars['USERID'];
		$pid  = $vars['PRODUCTCODE'];
		$rootID = $vars['ROOTID'];
		// This is actually licence clearance date as calculated by getRMSettings
		$datestamp = $vars['LICENCESTARTDATE'];
		// gh#125 v6.6.4 change to counting based on F_StartDateStamp to avoid problems in F_EndDateStamp
		$sql = <<<EOD
			SELECT * FROM T_Session s
			WHERE s.F_UserID = ?
			AND s.F_StartDateStamp >= ?
			AND s.F_Duration > 15
			AND s.F_ProductCode = ?
EOD;
		
		$bindingParams = array($uid, $datestamp, $pid);
		$rs = $db->Execute($sql, $bindingParams);
		if ($rs && $rs->RecordCount()>0) {
			$dbObj = $rs->FetchNextObj();
			// v6.6.0 Not sure there is any value in a licence ID, but might as well use the last session ID
			$licenceID = $dbObj->F_SessionID;
			$node .= "<licence id='$licenceID' />";
			return $licenceID;
		} else {
			return false;
		}
	}
	// v6.5.5.0 This is for tracking licences
	// v6.5.6.7 Change to T_LicenceControl table
	function checkAvailableLicences( &$vars, &$node) {
		global $db;
		$pid  = $vars['PRODUCTCODE'];
		$rootID = $vars['ROOTID'];
		// This is actually licence clearance date as calculated by getRMSettings
		$datestamp = $vars['LICENCESTARTDATE'];
		// Transferable tracking needs to invoke the T_User table as well to ignore records from users that don't exist anymore.
		v6.6.4 change to counting based on F_StartDateStamp to avoid problems in F_EndDateStamp
		if ($vars['LICENCETYPE']=='6') {
			$sql = <<<EOD
				SELECT COUNT(DISTINCT(s.F_UserID)) AS licencesUsed 
				FROM T_Session s, T_User u
				WHERE s.F_UserID = u.F_UserID
				AND s.F_StartDateStamp >= ?
				AND s.F_Duration > 15
				AND s.F_ProductCode = ?
EOD;
		} else {
		// v6.6.0 Teachers write session records, but with a root of -1
			$sql = <<<EOD
				SELECT COUNT(DISTINCT(F_UserID)) AS licencesUsed 
				FROM T_Session s
				WHERE s.F_StartDateStamp >= ?
				AND s.F_Duration > 15
				AND s.F_ProductCode = ?
EOD;
		}
		if (stristr($rootID,',')!==FALSE) {
			$sql.= " AND s.F_RootID in ($rootID)";
		} else if ($rootID=='*') {
			// check all roots in that case - just for special cases, usually self-hosting
			// Note that leaving the root empty would include teachers
			$sql.= " AND s.F_RootID > 0";
		} else {
			$sql.= " AND s.F_RootID = $rootID";
		}
		
		// To allow old Road to IELTS to count with the new. Rather pointless since ne Road to IELTS doesn't use this script!
		
		$bindingParams = array($datestamp, $pid);
		$rs = $db->Execute($sql, $bindingParams);
		if ($rs && $rs->RecordCount()>0) {
			$dbObj = $rs->FetchNextObj();
			$licencesUsed = (int)$dbObj->licencesUsed;
		} else {
			$node .= "<err code='100' userID='".$vars['USERID']."' licencesUsed='$licencesUsed'>Error getting licence tracking</err>";
			return false;
		}
		// Compare against the licences the school purchased
		if ($licencesUsed>=$vars['LICENCES']) {
			$vars['ERRORREASONCODE'] = 211;
			$node .= "<err code='211' userID='".$vars['USERID']."' licencesUsed='$licencesUsed'>No licences available</err>";
			return false;
		} else {
			$node .= "<licence id='0' users='$licencesUsed' />";
		}
	}

}
?>
