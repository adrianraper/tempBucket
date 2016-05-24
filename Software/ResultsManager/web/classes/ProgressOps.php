<?php
class ProgressOps {

	var $db;
	var $menu;

	// gh#604 Seconds before the session record is considered too old and a new one started
	const SESSION_IDLE_THRESHOLD = 100;
	const MINIMUM_DURATION = 15; // Minimum seconds used as duration for new session records

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
	function getEveryoneSummary($productCode, $country = 'Worldwide') {
		// For want of anywhere better to put it for the moment, this is the SQL to populate the cache table
		// This is NOT correct. You only want to average scores that are >=0 to avoid presentation exercises,
		// but you want to average all the durations. However, we mostly don't use duration so don't over worry about it.
		// Durations can be ridiculous - what is reasonable for one exercise? 1 hour? 3600 seconds
		/*
		SET @productCode = 52;
		-- First worldwide (all) average
		INSERT INTO T_ScoreCache (F_ProductCode, F_CourseID, F_UnitId, F_AverageScore, F_AverageDuration, F_Count, F_DateStamp, F_Country)
		SELECT @productCode, F_CourseID, null, AVG(F_Score) as AverageScore, AVG(if(F_Duration>3600,3600,F_Duration)) as AverageDuration, COUNT(F_UserID) as Count, now(), 'Worldwide' 
		FROM T_Score
		WHERE F_ProductCode = @productCode
		AND F_Score>=0
		GROUP BY F_CourseID;
		-- Then each country in turn
		SET @country = 'Hong Kong';
		SET @country = 'India';
		INSERT INTO T_ScoreCache (F_ProductCode, F_CourseID, F_UnitId, F_AverageScore, F_AverageDuration, F_Count, F_DateStamp, F_Country)
		SELECT @productCode, s.F_CourseID, null, AVG(s.F_Score) as AverageScore, AVG(if(s.F_Duration>3600,3600,s.F_Duration)) as AverageDuration, COUNT(s.F_UserID) as Count, now(), @country 
		FROM T_Score s, T_User u
		WHERE s.F_ProductCode = @productCode
		AND s.F_Score>=0
		AND u.F_UserID = s.F_UserID
		AND u.F_Country = @country
		GROUP BY F_CourseID;

		// For Practical Writing we have to preset the course and unit otherwise query runs forever
		SET @productCode = 61;
		SET @courseId = '2015061010000';
		SET @unitId =   '2015061010200';
		INSERT INTO T_ScoreCache (F_ProductCode, F_CourseID, F_UnitId, F_AverageScore, F_AverageDuration, F_Count, F_DateStamp, F_Country)
		SELECT @productCode, F_CourseID, @unitId, AVG(F_Score) as AverageScore, AVG(if(F_Duration>3600,3600,F_Duration)) as AverageDuration, COUNT(F_UserID) as Count, now(), 'Worldwide'
		FROM T_Score
		WHERE F_ProductCode = @productCode
		AND F_Score>=0
		AND F_CourseID = @courseId;

		*/

		// Work off cached results
		// gh#1014 Only take the latest datestamped result
		// gh#1166
		$sql = 	<<<EOD
			SELECT sc.F_CourseID as CourseID, sc.F_AverageScore as AverageScore, sc.F_AverageDuration as AverageDuration, sc.F_Count as Count, sc.F_Country as Country
			FROM T_ScoreCache sc
			INNER JOIN(
			    SELECT F_CourseID as id, MAX(F_DateStamp) as latest
			    FROM T_ScoreCache
			    WHERE F_ProductCode = ?
			    AND F_Country = ?
			    GROUP BY F_CourseID
			) i ON sc.F_CourseID = i.id AND sc.F_DateStamp = i.latest
			WHERE sc.F_ProductCode = ?
			AND sc.F_UnitID is null
			AND sc.F_Country = ?
			GROUP BY sc.F_CourseID
			ORDER BY sc.F_CourseID;
EOD;
		$bindingParams = array($productCode, $country, $productCode, $country);
		$rs = $this->db->GetAssoc($sql, $bindingParams);
		return $rs;
	}
	
	/**
	 * This method gets all users' progress records
	 */
	function getEveryoneUnitSummary($productCode, $rootID) {
		// For want of anywhere better to put it for the moment, this is the SQL to populate the cache table
		/*
		  SET @productCode = 55;
		  INSERT INTO T_ScoreCache (F_ProductCode, F_CourseID, F_UnitID, F_AverageScore, F_AverageDuration, F_Count, F_DateStamp, F_Country)
		  SELECT @productCode, F_CourseID, F_UnitID, AVG(F_Score) as AverageScore, AVG(if(F_Duration>3600,3600,F_Duration)) as AverageDuration, COUNT(F_UserID) as Count, now(), 'Worldwide' 
		  FROM T_Score
		  WHERE F_ProductCode = @productCode
		  AND F_Score>=0
		  GROUP BY F_CourseID, F_UnitID;
		*/
		$sql = 	<<<EOD
			SELECT sc.F_CourseID as CourseID, sc.F_UnitID as UnitID, sc.F_AverageScore as AverageScore, sc.F_AverageDuration as AverageDuration, sc.F_Count as Count
			FROM T_ScoreCache sc
			INNER JOIN(
			    SELECT F_UnitID as id, max(F_DateStamp) as latest
			    FROM T_ScoreCache
			    WHERE F_ProductCode = ?
				AND F_UnitID is not null
			    GROUP BY F_UnitID
			) i ON sc.F_UnitID = i.id AND sc.F_DateStamp = i.latest
			WHERE sc.F_ProductCode = ?
			AND sc.F_UnitID is not null
			GROUP BY sc.F_UnitID
			ORDER BY sc.F_CourseID, sc.F_UnitID;
EOD;
		$bindingParams = array($productCode, $productCode);
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
	 * @param $userID
	 * @param $productCode
	 * @return array
	 *
	 * This method gets the 'mastery' of each exercise, which is the sum of correct answers
	 */
	function getMastery($userID, $productCode) {
		$sql = <<<SQL
			SELECT F_ExerciseID as exerciseID, SUM(F_ScoreCorrect) as mastery
			FROM T_Score
			WHERE F_ProductCode=?
			AND F_UserID=?
			GROUP BY F_ExerciseID;
SQL;

		$bindingParams = array($productCode, $userID);
		$rs = $this->db->GetAssoc($sql, $bindingParams);

		// cast the values to integers and remove 0 entries
		return array_filter(array_map('intval', $rs));
	}
	
	/**
	 * This method is called to insert a session record when a user starts a program
	 * gh#954 If you are given a course id, link that to the session record. 
	 */
	function startSession($user, $rootId, $productCode, $courseId = null) {

		// gh#604 You might start with user as a plain userId
		if ($user instanceof User) {
			// For teachers we will set rootID to -1 in the session record, so, are you a teacher?
			// Or more specifically are you NOT a student
			// gh#604 Include all users in session records tied to a root
			// gh#1228 Revert due to licence counting issue
			if (!$user->userType == User::USER_TYPE_STUDENT)
				$rootId = -1;
			$userId = $user->userID;
		} else {
			$userId = $user;
		}

		// Check that the date is valid
		// #321
		//$dateStampNow = strtotime($dateNow);
		//if (!$dateStampNow) {
		// gh#815
			//$dateStampNow = time();
			//$dateNow = date('Y-m-d H:i:s',$dateStampNow);
		// gh#604 use constant
		$dateStampNow = new DateTime('now', new DateTimeZone(TIMEZONE));
		$dateNow = $dateStampNow->format('Y-m-d H:i:s');
		$dateSoon = $dateStampNow->modify('+'.self::MINIMUM_DURATION.' seconds')->format('Y-m-d H:i:s');
		
		// CourseID is in the db for backwards compatability, but no longer used. All sessions are across one title.
		// StartDateStamp is usually sent so that we can record a user's local time. It might be better to send a time-zone if we could.
		// EndDateStamp and Duration are different views of the same data. It might be better to just focus on Duration.
		// When you start a session, the minimum duration is 15 seconds.
		$sql = <<<SQL
			INSERT INTO T_Session (F_UserID, F_StartDateStamp, F_EndDateStamp, F_Duration, F_RootID, F_ProductCode, F_CourseID)
			VALUES (?, ?, ?, ?, ?, ?, ?)
SQL;

		// We want to return the newly created F_SessionID (or the SQL error)
		$bindingParams = array($userId, $dateNow, $dateSoon, self::MINIMUM_DURATION, $rootId, $productCode, $courseId);
		$rs = $this->db->Execute($sql, $bindingParams);
		if ($rs) {
			$sessionId = $this->db->Insert_ID();
			if ($sessionId) {
				return $sessionId;
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
	 * gh#954 If you are given a course id, link that to the session record. 
	 *   If it is different from the current id, then close the existing session and start a new one. 
	 *   Return the new session id.  
	 */
	function updateSession($sessionId, $courseId = null) {
		// Check that the date is valid
		// #321
		//$dateStampNow = strtotime($dateNow);
		//if (!$dateStampNow)
			//$dateNow = date('Y-m-d H:i:s',time());
		// gh#815
		$dateStampNow = new DateTime('now', new DateTimeZone(TIMEZONE));
		$dateNow = $dateStampNow->format('Y-m-d H:i:s');

        $sql = <<<EOD
				SELECT s.*
				FROM T_Session s
				WHERE F_SessionID=?
EOD;
        $bindingParams = array($sessionId);
        $rs = $this->db->Execute($sql, $bindingParams);
        if ($rs) {
            $rsObj = $rs->FetchNextObj();
            $rootId = $rsObj->F_RootID;
            $productCode = $rsObj->F_ProductCode;
            $userId = $rsObj->F_UserID;
            $lastUpdateAt = new DateTime($rsObj->F_EndDateStamp, new DateTimeZone(TIMEZONE));
            $interval = $dateStampNow->getTimestamp() - $lastUpdateAt->getTimestamp();

            // gh#604 Is the session record out of date?
            // gh#954 Do we have a passed courseId that is different from the existing record?
            if (($interval > self::SESSION_IDLE_THRESHOLD) ||
                ($courseId && (!is_null($rsObj->F_CourseID)) && ($rsObj->F_CourseID != $courseId)))  {
                $newSessionId = $this->startSession($userId, $rootId, $productCode, $courseId);
                AbstractService::$debugLog->info("change session record $sessionId to $newSessionId - last updated at " . $lastUpdateAt->format('Y-m-d H:i:s') . ", $interval seconds ago");
                return $newSessionId;

            } else {

                // Calculate F_Duration as well as setting F_EndDateStamp
                // We can either do it one call, with different SQL for different databases, or
                // do two calls and make it common.
                $bindingParams = array($dateNow, $dateNow, $sessionId);
                $sql = <<<EOD
						UPDATE T_Session
						SET F_EndDateStamp=?,
EOD;
                if (strpos($GLOBALS['dbms'], "mysql") !== false) {
                    $sql .=	" F_Duration=TIMESTAMPDIFF(SECOND,F_StartDateStamp,?) ";
                } else if (strpos($GLOBALS['dbms'], "sqlite") !== false) {
                    $sql .=	" F_Duration = strftime('%s',?) -strftime('%s', F_StartDateStamp) ";
                } else {
                    $sql .=	" F_Duration=DATEDIFF(s,F_StartDateStamp,?) ";
                }
                if ($courseId) {
                    $bindingParams = array($dateNow, $dateNow, $courseId, $sessionId);
                    $sql .= ", F_CourseID=? ";
                }
                $sql .= " WHERE F_SessionID=? ";
                $rs = $this->db->Execute($sql, $bindingParams);
            }
            return $sessionId;
        }
        return false;
    }
	
	/**
	 * This method is called to insert a score record to the database 
	 */
	function insertScore($score, $user) {
		// For teachers we will set score to -1 in the score record, so, are you a teacher?
		if (!$user->userType == 0)
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
		//return $rc;
		// gh#119
		return $score;
	}
	
	/**
	 * Get hidden content records from the database that describe which bits of content users in this group should see.
	 *
	 */
	public function getHiddenContent($groupID, $productCode) {
		// gh#653 groupID might be a comma delimitted list
		if (stripos($groupID, ',')) {
			$groupClause = " F_GroupID IN ($groupID) ";
		} else {
			$groupClause = " F_GroupID = $groupID ";
		}
		
		$sql = <<<EOD
			SELECT DISTINCT(F_HiddenContentUID) as UID, F_EnabledFlag as eF 
			FROM T_HiddenContent
			WHERE $groupClause
			AND F_ProductCode=?
			ORDER BY UID ASC;
EOD;
		$bindingParams = array($productCode);
		return $this->db->GetArray($sql, $bindingParams);
	}
	
}