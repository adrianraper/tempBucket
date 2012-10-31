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
	
	// For archiving expired users.
	// Expected to be run by a daily CRON job
	function archiveExpiredUsers($expiryDate, $database) {
		
		// copy the expired records to the expiry tables
		// first records from T_User
		$sql = <<<SQL
			INSERT INTO $database.T_User_Expiry
			SELECT * FROM $database.T_User where F_ExpiryDate <= ?;
SQL;
		$bindingParams = array($expiryDate);
		$rs = $this->db->Execute($sql, $bindingParams);

		// TODO. You could save a lot of time by getting the list of userIDs from one SQL call
		// and then passing it to the rest of the calls. At the moment you make the same
		// SQL call 7 times - and it is a big table too.
		
		// and the membership records
		$sql = <<<SQL
			INSERT INTO $database.T_Membership_Expiry
			SELECT * FROM $database.T_Membership where F_UserID in 
			(SELECT F_UserID FROM $database.T_User where F_ExpiryDate <= ?);
SQL;
		$bindingParams = array($expiryDate);
		$rs = $this->db->Execute($sql, $bindingParams);

		// and the score records
		$sql = <<<SQL
			INSERT INTO $database.T_Score_Expiry
			SELECT * FROM $database.T_Score where F_UserID in 
			(SELECT F_UserID FROM $database.T_User where F_ExpiryDate <= ?);
SQL;
		$bindingParams = array($expiryDate);
		$rs = $this->db->Execute($sql, $bindingParams);

		// and the session records
		$sql = <<<SQL
			INSERT INTO $database.T_Session_Expiry
			SELECT * FROM $database.T_Session where F_UserID in 
			(SELECT F_UserID FROM $database.T_User where F_ExpiryDate <= ?);
SQL;
		$bindingParams = array($expiryDate);
		$rs = $this->db->Execute($sql, $bindingParams);

		// Then delete these records
		$sql = <<<SQL
			DELETE FROM $database.T_Score where F_UserID in 
			(SELECT F_UserID FROM $database.T_User where F_ExpiryDate <= ?);	
SQL;
		$bindingParams = array($expiryDate);
		$rs = $this->db->Execute($sql, $bindingParams);

		$sql = <<<SQL
			DELETE FROM $database.T_Session where F_UserID in 
			(SELECT F_UserID FROM $database.T_User where F_ExpiryDate <= ?);	
SQL;
		$bindingParams = array($expiryDate);
		$rs = $this->db->Execute($sql, $bindingParams);

		$sql = <<<SQL
			DELETE FROM $database.T_Membership where F_UserID in 
			(SELECT F_UserID FROM $database.T_User where F_ExpiryDate <= ?);	
SQL;
		$bindingParams = array($expiryDate);
		$rs = $this->db->Execute($sql, $bindingParams);

		// Finally the T_User records as nothing else depends on them now
		$sql = <<<SQL
			DELETE FROM $database.T_User where F_ExpiryDate <= ?;	
SQL;
		$bindingParams = array($expiryDate);
		$rs = $this->db->Execute($sql, $bindingParams);

		// send back the number of deleted users
		return $this->db->Affected_Rows();
		
	}
	
	// To delete records from T_Accounts when the licence has expired and move them to archive table
	function archiveExpiredAccounts($expiryDate, $database) {
		
		// copy the expired records to the expiry tables
		// first records from T_Accounts
		$sql = <<<SQL
			INSERT INTO $database.T_Accounts_Expiry
			SELECT * FROM $database.T_Accounts where F_ExpiryDate <= ?;
SQL;
		$bindingParams = array($expiryDate);
		$rs = $this->db->Execute($sql, $bindingParams);

		// Then delete these records
		$sql = <<<SQL
			DELETE FROM $database.T_Accounts 
			where F_ExpiryDate <= ?;	
SQL;
		$bindingParams = array($expiryDate);
		$rs = $this->db->Execute($sql, $bindingParams);

		// send back the number of deleted users
		return $this->db->Affected_Rows();
		
	}
}
