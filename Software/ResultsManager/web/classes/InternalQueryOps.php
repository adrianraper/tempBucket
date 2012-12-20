<?php

class InternalQueryOps {
	
	var $db;
	
	function InternalQueryOps($db = null) {
		$this->db = $db;
	}
	
	/**
	 * If you changed the db, you'll need to refresh it here
	 * Not a very neat function...
	 */
	function changeDB($db) {
		$this->db = $db;
	}
	
	function findEmail($email) {
		// Given an email, find it for a user and the linked root
		$sql = <<<SQL
			SELECT u.*, a.F_RootID, a.F_Name
			FROM T_User u, T_Membership m, T_AccountRoot a
			WHERE u.F_Email = ?
			AND m.F_UserID = u.F_UserID
			AND m.F_RootID = a.F_RootID
SQL;
		$rc = $this->db->GetArray($sql, array($email));
		$resultArray = array();
		if ($rc) {
			foreach ($rc as $result) {
				$resultArray[] = array('userID' => $result['F_UserID'],
								'userName' => $result['F_UserName'],
								'rootID' => $result['F_RootID'],
								'institutionName' => $result['F_Name'],
								);
			}
		} else {
			$resultArray = array('errCode' => 100, 'data'=> $email.'-'.$GLOBALS['db']);
		}
		return $resultArray;
	}
	
	/**
	 * First step to see if any subscription failed
	 * @param string $startDate
	 */
	function getSubscriptions($startDate) {
		// Just list all subscription records since a certain date
		$sql = <<<SQL
			SELECT s.*
			FROM T_Subscription s
			WHERE s.F_DateStamp >= ?
            ORDER BY F_SubscriptionID desc;
SQL;
		//echo $sql;
		$bindingParams = array($startDate);
		$rs = $this->db->Execute($sql, $bindingParams); 
		//echo $sql.' got'.$rs->RecordCount().' records';
		$subscriptions = array();
		if ($rs->RecordCount() > 0) {
			while ($subscriptionObj = $rs->FetchNextObj()) {
				$subscription = new Subscription();
				$subscription->fromDatabaseObj($subscriptionObj);
				$subscriptions[] = $subscription;
			}
		}
		
		return $subscriptions;
	}
	
	function getGlobalR2IUser($id) {
		// Given an ID, send back the user record
		$sql = "SELECT * FROM T_User WHERE F_StudentID=?";
		$rc = $this->db->GetArray($sql, array($id));
		$resultArray = array();
		if ($rc) {
			foreach ($rc as $result) {
				$resultArray[] = array('studentID' => $result['F_StudentID'],
								'password' => $result['F_Password'],
								'email' => $result['F_Email'],
								'registrationDate' => $result['F_RegistrationDate'],
								'userName' => $result['F_UserName']);
			}
		} else {
			$resultArray = array('errCode' => 100, 'data'=> $id.'-'.$GLOBALS['db']);
		}
		return $resultArray;
	}
	
	function updateSessionsForDeletedUsers($rootID, $productCode) {
	
		//AND s.F_StartDateStamp>'2010-09-07'
		$sql =<<<EOD
			UPDATE T_Session s
			LEFT JOIN T_User u
			ON s.F_UserID = u.F_UserID
			SET s.F_UserID=-1
			WHERE s.F_ProductCode=?
			AND u.F_UserID IS NULL
			AND s.F_UserID > 0
			AND s.F_RootID=?
EOD;
		$bindingParams = array($productCode, $rootID);
		$rc = $this->db->Execute($sql, $bindingParams);
		return $this->db->Affected_Rows();
	}
	
	// For archiving expired users from a number of roots.
	// Expected to be run by a daily CRON job
	function archiveExpiredUsers($expiryDate, $roots, $database) {
		
		if (is_array($roots)) {
			$rootList = implode(',', $roots);
		} else if ($roots) {
			$rootList = $roots;
		} else {
			return 0;
		}
		$bindingParams = array($expiryDate, $rootList);
			
		// Find all the users who we want to expire
		$sql = <<<SQL
			SELECT * FROM $database.T_User u, $database.T_Membership m 
			WHERE u.F_ExpiryDate <= ?
			AND u.F_UserID = m.F_UserID
			AND m.F_RootID in (?)
			AND u.F_StudentID = '57689';
SQL;
		$rs = $this->db->Execute($sql, $bindingParams);

		// Loop round the recordset, inserting to *_Expiry then deleting the related records for each userID
		if ($rs->RecordCount() > 0) {
			while ($dbObj = $rs->FetchNextObj()) {
				
				$this->db->StartTrans();
				
				$userID = $dbObj->F_UserID;
				$bindingParams = array($userID);
				
				$sql = <<<SQL
					INSERT INTO $database.T_Membership_Expiry
					SELECT * FROM $database.T_Membership 
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$sql = <<<SQL
					DELETE FROM $database.T_Membership
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				
				$sql = <<<SQL
					INSERT INTO $database.T_Session_Expiry
					SELECT * FROM $database.T_Session 
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$sql = <<<SQL
					DELETE FROM $database.T_Session
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				
				$sql = <<<SQL
					INSERT INTO $database.T_Score_Expiry
					SELECT * FROM $database.T_Score 
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$sql = <<<SQL
					DELETE FROM $database.T_Score
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				
				$sql = <<<SQL
					INSERT INTO $database.T_User_Expiry
					SELECT * FROM $database.T_User 
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$sql = <<<SQL
					DELETE FROM $database.T_User
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				
				$this->db->CompleteTrans();
			}
		}
		
		// send back the number of archived users
		return $rs->RecordCount();
		
	}
	
	// To delete records from T_Accounts when the licence has expired and move them to archive table
	function archiveExpiredAccounts($expiryDate, $database) {
		
		// copy the expired records to the expiry tables
		// first records from T_Accounts
		$sql = <<<SQL
			INSERT INTO $database.T_Accounts_Expiry
			SELECT * FROM $database.T_Accounts 
			WHERE F_ExpiryDate <= ?
SQL;
		$bindingParams = array($expiryDate);
		$rs = $this->db->Execute($sql, $bindingParams);

		// Then delete these records
		$sql = <<<SQL
			DELETE FROM $database.T_Accounts 
			WHERE F_ExpiryDate <= ?
SQL;
		if ($rootList) 
			$sql .= ' AND F_RootID in (?)';			
		$rs = $this->db->Execute($sql, $bindingParams);

		// send back the number of deleted users
		return $this->db->Affected_Rows();
		
	}
	
	// To merge users from one database into another
	function mergeDatabases() {
		
		// Need to get each active user from global_r2iv2 (r2i) and add them as a new user to rack80829 (rack)
		// Then using the new userID, update all session, score, membership records in r2i to the new ID
		// Once this is all done, you can move all these session, score and membership records to rack
		$database = 'global_r2iv2';
		$target = 'rack80829';

		//	where F_Email = 'Magdamostkova@hotmail.com';
		$sql = <<<SQL
			SELECT * FROM $database.T_User
			where F_UserID > 1000
			LIMIT 0,3000
SQL;
		$bindingParams = array();
		$rs = $this->db->Execute($sql, $bindingParams);
		
		echo "There are ".$rs->RecordCount()." users to move.\r\n";
		if ($rs->RecordCount() > 0) {
			while ($dbObj = $rs->FetchNextObj()) {
				
				$this->db->StartTrans();
				
				$logMsg = "";
				$user = new User();
				$user->fromDatabaseObj($dbObj);
				$userID = $user->userID;
				
				$rc = $this->db->Execute($user->toSQLInsert(), $user->toBindingParams());
				if (!$rc)
					throw $this->copyOps->getExceptionForId("errorDatabaseWriting", array("msg" => $this->db->ErrorMsg()));
				
				$newUserID = $this->db->Insert_ID();
				$bindingParams = array($newUserID, $userID);
				
				$sql = <<<SQL
					UPDATE $database.T_Membership
					SET F_UserID = ?
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$affectedRows = $this->db->Affected_Rows();
				$logMsg .= "For $userID, updated $affectedRows record from T_Membership";
				
				$sql = <<<SQL
					UPDATE $database.T_Session
					SET F_UserID = ?
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$affectedRows = $this->db->Affected_Rows();
				$logMsg .= ", $affectedRows from T_Session";
				
				$sql = <<<SQL
					UPDATE $database.T_Score
					SET F_UserID = ?
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$affectedRows = $this->db->Affected_Rows();
				$logMsg .= " and $affectedRows from T_Score";
				
				$sql = <<<SQL
					DELETE FROM $database.T_User
					WHERE F_UserID = ?;
SQL;
				$bindingParams = array($userID);
				$rc = $this->db->Execute($sql, $bindingParams);
				$affectedRows = $this->db->Affected_Rows();
				$logMsg .= " and deleted $affectedRows from T_User.\r\n";
				
				echo $logMsg;
				
				$this->db->CompleteTrans();
			}
		}
		
		// Issues. 
		// Need to remove session, score and membership records that are NOT updated
		// so archive records that have no active F_UserID. OK, SQL written
		
	}
}
