<?php
class ProgressOps {

	var $db;
	var $menu;
	
	function ProgressOps($db) {
		$this->db = $db;
		$this->copyOps = new CopyOps();
	}
	
	/**
	 * If you changed the db, you'll need to refresh it here
	 * Not a very neat function...
	 */
	function changeDB($db) {
		$this->db = $db;
	}
	
	/**
	 * 
	 * Take an exercise record and return is a bookmark XML
	 * @param recordset $rs
	 */
	function formatBookmark($rs) {
		$score = new Score();
		$score->fromDatabaseObj($rs);
		$bookmark = new SimpleXMLElement('<bookmark />');
		$bookmark->addAttribute('uid', $score->getUID());
		$bookmark->addAttribute('date', $score->dateStamp);
		return $bookmark->asXML();		
	}
	
	/**
	 * This method gets all users' progress records at the summary level
	 */
	function getEveryoneSummary($productCode) {
		// For want of anywhere better to put it for the moment, this is the SQL to populate the cache table
		/*
		USE global_r2iv2;
		SET @productCode = 52;
		SET @productCode = 53;
		INSERT INTO T_ScoreCache (F_ProductCode, F_CourseID, F_AverageScore, F_AverageDuration, F_Count, F_DateStamp, F_Country)
		SELECT @productCode, F_CourseID, AVG(F_Score) as AverageScore, AVG(F_Duration) as AverageDuration, COUNT(F_UserID) as Count, now(), 'Worldwide' 
		FROM T_Score
		WHERE F_ProductCode = @productCode
		AND F_Score>=0
		GROUP BY F_CourseID;
		*/
		
		// Start working off cached results
		// It would be safest if we could ensure that we only read the record with the latest datestamp
		$sql = 	<<<EOD
			SELECT F_CourseID, F_AverageScore as AverageScore, F_AverageDuration as AverageDuration, F_Count as Count FROM T_ScoreCache
			WHERE F_ProductCode = ?
			ORDER BY F_CourseID;
EOD;
		$bindingParams = array($productCode);
		$rs = $this->db->GetAssoc($sql, $bindingParams);
		return $rs;
	}
	
	/**
	 * This method gets all users' progress records
	 */
	function getEveryoneUnitSummary($productCode, $rootID) {
		$sql = 	<<<EOD
			SELECT AVG(sc.F_Score) as AverageScore, sc.F_UnitID as UnitID, sc.F_CourseID as CourseID
    		FROM T_Score sc, T_Session s
    		WHERE s.F_ProductCode = ?
    		AND s.F_RootID = ?
    		AND s.F_SessionID = sc.F_SessionID
    		GROUP BY sc.F_UnitID
    		ORDER BY sc.F_UnitID;
EOD;
		$bindingParams = array($productCode, $rootID);
		$rs = $this->db->GetArray($sql, $bindingParams);
		return $rs;
	}
	/**
	 * This method gets the user's last record
	 */
	function getMyLastExercise($userID, $productCode) {
		$sql = 	<<<SQL
			SELECT s.*
			FROM T_Score as s
			WHERE s.F_UserID=?
			AND s.F_ProductCode=?
			ORDER BY s.F_DateStamp DESC
			LIMIT 1;
SQL;
		$bindingParams = array($userID, $productCode);
		$rs = $this->db->GetArray($sql, $bindingParams);
		return $rs;
	}
	
	/**
	 * This method is called to insert a session record when a user starts a program
	 */
	function startSession($user, $rootID, $productCode, $dateNow = null) {
		// For teachers we will set rootID to -1 in the session record, so, are you a teacher?
		// Or more specifically are you NOT a student
		if (!$user->userType == 0)
			$rootID = -1;
		
		// Check that the date is valid
		// #321
		//$dateStampNow = strtotime($dateNow);
		//if (!$dateStampNow) {
			$dateStampNow = time();
			$dateNow = date('Y-m-d H:i:s',$dateStampNow);
		//}
		$dateSoon = date('Y-m-d H:i:s',strtotime("+15 seconds", $dateStampNow));
		
		// CourseID is in the db for backwards compatability, but no longer used. All sessions are across one title.
		// StartDateStamp is usually sent so that we can record a user's local time. It might be better to send a time-zone if we could.
		// EndDateStamp and Duration are different views of the same data. It might be better to just focus on Duration.
		// When you start a session, the minimum duration is 15 seconds.
		$sql = <<<SQL
			INSERT INTO T_Session (F_UserID, F_StartDateStamp, F_EndDateStamp, F_Duration, F_RootID, F_ProductCode)
			VALUES (?, ?, ?, 15, ?, ?)
SQL;

		// We want to return the newly created F_SessionID (or the SQL error)
		$bindingParams = array($user->userID, $dateNow, $dateSoon, $rootID, $productCode);
		$rs = $this->db->Execute($sql, $bindingParams);
		if ($rs) {
			$sessionID = $this->db->Insert_ID();
			if ($sessionID) {
				return $sessionID;
			} else {
				// The database probably doesn't support the Insert_ID function
				throw $this->copyOps->getExceptionForId("errorCantFindAutoIncrementSessionId");
			}
		} else {
			throw $this->copyOps->getExceptionForId("errorDatabaseWriting");
		}
	}
	
	/**
	 * This method is called to update a session record.
	 * This is used both when a user exits the program, and regularly whilst the connection is still going.
	 * Remember that scores are written with client time (so you can see what time a student did their homework)
	 * but sessions are written with server time so that they are accurate.
	 */
	function updateSession($sessionID, $dateNow = null) {
		// Check that the date is valid
		// #321
		//$dateStampNow = strtotime($dateNow);
		//if (!$dateStampNow)
			$dateNow = date('Y-m-d H:i:s',time());
			
		// Calculate F_Duration as well as setting F_EndDateStamp
		// We can either do it one call, with different SQL for different databases, or
		// do two calls and make it common.
		if (strpos($GLOBALS['dbms'],"mysql")!==false) {
			$sql = <<<EOD
				UPDATE T_Session
				SET F_EndDateStamp=?,
				F_Duration=TIMESTAMPDIFF(SECOND,F_StartDateStamp,?)
				WHERE F_SessionID=?
EOD;
		} else if (strpos($GLOBALS['dbms'],"sqlite")!==false) {
			$sql = <<<EOD
				UPDATE T_Session
				SET F_EndDateStamp=?,
				F_Duration=strftime('%s',?) - strftime('%s',F_StartDateStamp)
				WHERE F_SessionID=?
EOD;
		} else {
			$sql = <<<EOD
				UPDATE T_Session
				SET F_EndDateStamp=?,
				F_Duration=DATEDIFF(s,F_StartDateStamp,?)
				WHERE F_SessionID=?
EOD;
		}
		$bindingParams = array($dateNow, $dateNow, $sessionID);
		$rs = $this->db->Execute($sql, $bindingParams);
		return $rs;
	}
	
	/**
	 * This method is called to insert a score record to the database 
	 */
	function insertScore($score, $user) {
		// For teachers we will set score to -1 in the score record, so, are you a teacher?
		if (!$user->userType==0)
			$score->score = -1;
		
		// Write anonymous records to an ancilliary table that will not slow down reporting
		if ($score->userID < 1) {
			$tableName = 'T_ScoreAnonymous';
		} else {
			$tableName = 'T_Score';
		}

		// #340. This fails to insert or raise an error for SQLite
		//$dbObj = $score->toAssocArray();
		//$rc = $this->db->AutoExecute($tableName, $dbObj, "INSERT");
		//if (!$rc)
		//	throw $this->copyOps->getExceptionForId("errorDatabaseWriting", $this->db->ErrorMsg());

		$sql = <<<EOD
			INSERT INTO T_Score (F_UserID,F_ProductCode,F_CourseID,F_UnitID,F_ExerciseID,
					F_Duration,F_Score,F_ScoreCorrect,F_ScoreWrong,F_ScoreMissed,
					F_DateStamp,F_SessionID)
			VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
EOD;

		$bindingParams = array($score->userID, $score->productCode, $score->courseID, $score->unitID, $score->exerciseID, 
								$score->duration, $score->score, $score->scoreCorrect, $score->scoreWrong, $score->scoreMissed, 
								$score->dateStamp, $score->sessionID);
								
		$rc = $this->db->Execute($sql, $bindingParams);
		if (!$rc)
			throw $this->copyOps->getExceptionForId("errorDatabaseWriting", array("msg" => $this->db->ErrorMsg()));
		
		// #308
		// TODO: I have commented this out so I can return a real score
		//return $rc;
		
		// gh#119
		return $score;
	}
	
	/**
	 * Get hidden content records from the database that describe which bits of content users in this group should see.
	 *
	 */
	public function getHiddenContent($groupID, $productCode) {
		$sql = <<<EOD
			SELECT F_HiddenContentUID UID, F_EnabledFlag eF 
			FROM T_HiddenContent
			WHERE F_GroupID=?
			AND F_ProductCode=?
			ORDER BY UID ASC;
EOD;
		$bindingParams = array($groupID, $productCode);
		return $this->db->GetArray($sql, $bindingParams);
	}
	
}