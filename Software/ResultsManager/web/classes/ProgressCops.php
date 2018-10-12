<?php
/*
 * Couloir version of Bento ProgressOpe
 */
class ProgressCops {

	var $db;
	var $menu;

	// gh#604 Seconds before the session record is considered too old and a new one started
	const SESSION_IDLE_THRESHOLD = 3600;
    // gh#954 All licence counting is > 15, so for new users this will help accurate reflection
	const MINIMUM_DURATION = 16; // Minimum seconds used as duration for new session records

	function ProgressCops($db) {
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
     * m#446 This is no longer called by backend, but perhaps the BCEA dashboard does directly?
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
		SELECT @productCode, F_CourseID, null, AVG(nullif(F_Score,-1)) as AverageScore, AVG(if(F_Duration>3600,3600,F_Duration)) as AverageDuration, COUNT(F_UserID) as Count, now(), 'Worldwide'
		FROM T_Score
		WHERE F_ProductCode = @productCode
		GROUP BY F_CourseID;
		-- Then each country in turn
		SET @country = 'Hong Kong';
		SET @country = 'India';
		INSERT INTO T_ScoreCache (F_ProductCode, F_CourseID, F_UnitId, F_AverageScore, F_AverageDuration, F_Count, F_DateStamp, F_Country)
		SELECT @productCode, s.F_CourseID, null, AVG(nullif(F_Score,-1)) as AverageScore, AVG(if(s.F_Duration>3600,3600,s.F_Duration)) as AverageDuration, COUNT(s.F_UserID) as Count, now(), @country
		FROM T_Score s, T_User u
		WHERE s.F_ProductCode = @productCode
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
    			AND F_UnitID is null
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
    // For want of anywhere better to put it for the moment, this is the SQL to populate the cache table
        SET @productCode = 55;
        INSERT INTO T_ScoreCache (F_ProductCode, F_CourseID, F_UnitID, F_AverageScore, F_AverageDuration, F_Count, F_DateStamp, F_Country)
        SELECT @productCode, F_CourseID, F_UnitID, AVG(nullif(F_Score,-1)) as AverageScore, AVG(if(F_Duration>3600,3600,F_Duration)) as AverageDuration, COUNT(F_UserID) as Count, now(), 'Worldwide'
        FROM T_Score
        WHERE F_ProductCode = @productCode
        GROUP BY F_CourseID, F_UnitID;
	function getEveryoneUnitSummary($productCode, $rootID=null) {
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
     */
    /**
     * m#446 Get everyone's summary at multiple levels
     */
    function getEveryoneNodeSummary($productCode, $mode=null) {
        global $service;
        $country = (is_null($mode)) ? 'Worldwide' : $mode;
        $nodeLevels = $this->getNodeLevels($productCode);

        $nodes = array();
        foreach ($nodeLevels as $nodeLevel) {
            // m#578 Until app version corrected, only do this for R2I
            //$nodeIdPrefix = (version_compare($service->getAppVersion(), '2.0.0', '>=')) ? $nodeLevel['caption'].':' : '';
            $nodeIdPrefix = ($productCode==72 || $productCode==73) ? $nodeLevel['caption'].':' : '';
            if ($nodeLevel['level']==1) {
                // This is to get course level summary
                $sql = <<<EOD
                    SELECT CONCAT('$nodeIdPrefix',sc.F_CourseID) as nodeId, sc.F_AverageScore as AverageScore, sc.F_AverageDuration as AverageDuration, sc.F_Count as Count, sc.F_Country as Country
                    FROM T_ScoreCache sc
                    INNER JOIN(
                        SELECT F_CourseID as id, MAX(F_DateStamp) as latest
                        FROM T_ScoreCache
                        WHERE F_ProductCode = ?
                        AND F_UnitID is null
                        AND F_Country = ?
                        GROUP BY F_CourseID
                    ) i ON sc.F_CourseID = i.id AND sc.F_DateStamp = i.latest
                    WHERE sc.F_ProductCode = ?
                    AND sc.F_UnitID is null
                    AND sc.F_Country = ?
                    GROUP BY sc.F_CourseID
                    ORDER BY sc.F_CourseID;
EOD;
            } else {
                // This is to get unit or set level summary
                $sql = <<<EOD
                    SELECT CONCAT('$nodeIdPrefix',sc.F_UnitID) as nodeId, sc.F_AverageScore as AverageScore, sc.F_AverageDuration as AverageDuration, sc.F_Count as Count, sc.F_Country as Country
                    FROM T_ScoreCache sc
                    INNER JOIN(
                        SELECT F_UnitID as id, max(F_DateStamp) as latest
                        FROM T_ScoreCache
                        WHERE F_ProductCode = ?
                        AND F_Country = ?
                        AND F_UnitID is not null
                        GROUP BY F_UnitID
                    ) i ON sc.F_UnitID = i.id AND sc.F_DateStamp = i.latest
                    WHERE sc.F_ProductCode = ?
                    AND F_Country = ?
                    AND sc.F_UnitID is not null
                    GROUP BY sc.F_UnitID
                    ORDER BY sc.F_UnitID;
EOD;
            }
            $bindingParams = array($productCode, $country, $productCode, $country);
            $rs = $this->db->GetArray($sql, $bindingParams);
            $nodes = array_merge($nodes, $rs);
        }
        return $nodes;
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
     * Get details of all exercises completed (marked)
     */
    public function getExercisesCompleted($session) {
        $sql = <<<SQL
			SELECT *
			FROM T_Score
			WHERE F_ProductCode=?
			AND F_UserID=?
SQL;

        $bindingParams = array($session->productCode, $session->userId);
        $rs = $this->db->GetArray($sql, $bindingParams);

        return $rs;
    }

    /**
     * m#446
     * Get sum and average for one user grouped at any node level(s)
     */
    public function getNodeProgress($session) {
        global $service;

        // What level of hierarchies are we grouping at for this title?
        $nodes = $this->getNodeLevels($session->productCode);

        $sql = <<<SQL
			SELECT *
			FROM T_Score
			WHERE F_ProductCode=?
			AND F_UserID=?
            ORDER BY F_ExerciseID
SQL;

        $bindingParams = array($session->productCode, $session->userId);
        $rs = $this->db->GetArray($sql, $bindingParams);

        // Now group by the node you want and sum and average
        $build = array();
        foreach ($nodes as $node) {
            $level = $node['level'];
            // m#578 Until app version corrected, only do this for R2I
            //$nodeIdPrefix = (version_compare($service->getAppVersion(), '2.0.0', '>=')) ? $node['caption'].':' : '';
            $nodeIdPrefix = ($session->productCode==72 || $session->productCode==73) ? $node['caption'].':' : '';
            $buildRow = array();
            $lastNode = false;
            foreach ($rs as $r) {
                $thisNode = $this->parseNode($r['F_ExerciseID'], $level);
                // Initialise if this is the first of a new node group
                if ($thisNode != $lastNode) {
                    // If there is something to write out
                    if ($lastNode) {
                        $buildRow['averageScore'] = ($buildRow['scoredExercises'] > 0) ? round($buildRow['totalScore'] / $buildRow['scoredExercises']) : 0;
                        $build[] = $buildRow;
                    }
                    $lastNode = $thisNode;
                    $buildRow = array('nodeId' => $nodeIdPrefix.$thisNode, 'scoredExercises' => 0, 'exerciseCount' => 0, 'duration' => 0, 'totalScore' => 0);
                }
                $buildRow['duration'] += ($r['F_Duration'] > 3600) ? 3600 : $r['F_Duration'];
                $buildRow['exerciseCount']++;
                if ($r['F_Score'] >= 0) {
                    $buildRow['scoredExercises']++;
                    $buildRow['totalScore'] += $r['F_Score'];
                }
            }
            // write out the final row
            $buildRow['averageScore'] = ($buildRow['scoredExercises'] > 0) ? round($buildRow['totalScore'] / $buildRow['scoredExercises']) : 0;
            $build[] = $buildRow;
        }
        return $build;
    }

    public function getNodeLevels($pc) {
        switch ($pc) {
            case '72':
            case '73':
                $levels = array(array("caption" => 'course', "level" => 1), array("caption" => 'set', "level" => 3));
                break;
            case '68':
            default:
                $levels = array(array("caption" => 'unit', "level" => 2));
                break;
        }
        return $levels;
    }

    // Given an exercise id, what course/unit/set/xxx is it in?
    private function parseNode($exId, $level) {
        // id is in format [publication year,4][productCode,3][course,2][unit,2][set,2][exercise,2]
        // But you might not have 'set'
        $publicationYear = substr($exId,0,4);
        $productCode = substr($exId,4,3);
        $course = substr($exId,7,2);
        $unit = substr($exId,9,2);
        $set = (strlen($exId) > 13) ? substr($exId,11,2) : null;
        $exercise = substr($exId, -2);

        // How long should the return id be?
        // TODO for now assume that only set is optional, but later titles might need more flexibility
        //$idLength = ($set) ? 15 : 13;
        $idLength = strlen($exId);

        switch ($level) {
            case 1:
                return str_pad($publicationYear.$productCode.$course, $idLength, '0', STR_PAD_RIGHT);
                break;
            case 2:
                return str_pad($publicationYear.$productCode.$course.$unit, $idLength, '0', STR_PAD_RIGHT);
                break;
            case 3:
                return str_pad($publicationYear.$productCode.$course.$unit.$set, $idLength, '0', STR_PAD_RIGHT);
                break;
        }
    }

    /**
     * Get summary of progress at the course level
     * m#11
     */
    public function getCourseProgress($session, $courseId) {
        $sql = <<<SQL
			SELECT SUM(if(F_Duration>3600,3600,F_Duration)) as duration, 
			      ROUND(AVG(nullif(F_Score, -1)),0) as averageScore, 
			      COUNT(DISTINCT(F_ExerciseID)) as exercisesDone
			FROM T_Score
			WHERE F_ProductCode=?
			AND F_UserID=?
			AND F_CourseID=?
SQL;

        $bindingParams = array($session->productCode, $session->userId, $courseId);
        $rs = $this->db->Execute($sql, $bindingParams);

        return $rs->FetchNextObj();
    }

    /**
     * This is for calculating the placement test result.
     * With full complexity this will require access to detailed scores so you can look at question tags (A2 etc)
     * as well as the number correct.
     * It should also be read from a DPT specific scoring chart. scoring.json perhaps?
     *
     */
    function getTestResult($session, $mode=null) {

        // Do you need to exclude any 'exercises' from scoring? Requirements for one...
        // Because T_Score does not have valid exercise id, use unit ids
        // It might be more efficient to exclude things like requirements unit, but is more explicit to do it by includes
        $gaugeUnitID = DPTConstants::gaugeUnitID;
        $gaugeBonusBUnitID = DPTConstants::gaugeBonusBUnitID;
        $gaugeBonusCUnitID = DPTConstants::gaugeBonusCUnitID;
        $trackAUnitID = DPTConstants::trackAUnitID;
        $trackBUnitID = DPTConstants::trackBUnitID;
        $trackCUnitID = DPTConstants::trackCUnitID;
        $bonusA2UnitID = DPTConstants::bonusA2UnitID;
        $bonusB1UnitID = DPTConstants::bonusB1UnitID;
        $bonusB2UnitID = DPTConstants::bonusB2UnitID;
        $bonusC1UnitID = DPTConstants::bonusC1UnitID;
        $bonusC2UnitID = DPTConstants::bonusC2UnitID;
        // ctp#438
        $gaugeOneExerciseID = DPTConstants::gaugeOneExerciseID;
        $gaugeTwoExerciseID = DPTConstants::gaugeTwoExerciseID;

        $includeUnitIDs = array($gaugeUnitID, $gaugeBonusBUnitID, $gaugeBonusCUnitID,
            $trackAUnitID, $trackBUnitID, $trackCUnitID,
            $bonusA2UnitID, $bonusB1UnitID, $bonusB2UnitID, $bonusC1UnitID, $bonusC2UnitID);

        // 1. Get all the detailed answers that are part of the test
        // ctp#366 Exclude duplicates for each item
        // dpt#469 ignore not attempted details
        $sql = <<<SQL
            SELECT sd.*
        	FROM T_ScoreDetail sd
	        INNER JOIN (
              SELECT F_SessionID as id, F_ItemID as itemID, MIN(F_DateStamp) as firstRecord
		      FROM T_ScoreDetail
		      WHERE F_SessionID=?
              AND F_Score is not null
SQL;
        $sql .= " AND F_UnitID in ('".implode("','",$includeUnitIDs)."')";
        $sql .= <<<SQL
		      GROUP BY F_ExerciseID, F_ItemID
	        ) i ON sd.F_SessionID = i.id AND sd.F_ItemID = i.itemID AND sd.F_DateStamp = i.firstRecord
	        WHERE sd.F_SessionID=?
SQL;
        $sql .= " AND F_UnitID in ('".implode("','",$includeUnitIDs)."')";
        $sql .= " GROUP BY sd.F_ExerciseID, sd.F_ItemID;";
        $bindingParams = array($session->sessionId, $session->sessionId);
        $rs = $this->db->Execute($sql, $bindingParams);

        if ($rs->RecordCount()==0)
            // No answers have been saved. Exception?
            return null;

        $totalCorrect = $totalWrong = $totalMissed = 0;
        $trackCorrect = $bonusCorrect = $gaugeBonusCorrect = $gaugeCorrect = $gaugeOneCorrect = $gaugeTwoCorrect = 0;
        $trackUnitID = $lastUnitID = 0;
        $unitIdx = $lastUnitIdx = 0;
        // ctp#438 Just for reporting the test path
        $gaugeTwoUsed = $gaugeBonusBUsed = $gaugeBonusCUsed = $trackBonusA2Used = $trackBonusB1Used = $trackBonusB2Used = $trackBonusC1Used = $trackBonusC2Used = false;

        $trackDetails = array();
        $gaugeDetails = array();
        while ($record = $rs->FetchNextObj()) {
            // ctp#315 Although records are mostly written in order, a few do get out of sync so you can't assume
            // that the last one written was the last one done.
            $unitIdx = array_search($record->F_UnitID, $includeUnitIDs);
            $lastUnitIdx = ($unitIdx && ($unitIdx > $lastUnitIdx)) ? $unitIdx : $lastUnitIdx;

            // Keep track of total questions answered to see if you passed a threshold for an unspoilt test
            if ($record->F_Score > 0) {
                $totalCorrect++;
            } elseif ($record->F_Score < 0) {
                $totalWrong++;
            } elseif ($record->F_Score == null) {
                $totalMissed++;
            }

            // We want to know tags for correct answers in the main tracks and separately for the gauge
            switch ($record->F_UnitID) {
                case $trackAUnitID:
                case $trackBUnitID:
                case $trackCUnitID:
                    if ($record->F_Score > 0) {
                        $trackCorrect += $record->F_Score;
                        $scoreDetail = new ScoreDetail();
                        $scoreDetail->fromDatabaseObj($record);
                        $trackDetails[] = $scoreDetail;
                    }
                    // This only needed to tell if you went into a shared bonus from which track
                    $trackUnitID = $record->F_UnitID;
                    break;

                case $bonusA2UnitID:
                case $bonusB1UnitID:
                case $bonusB2UnitID:
                case $bonusC1UnitID:
                case $bonusC2UnitID:
                    if ($record->F_Score > 0)
                        $bonusCorrect += $record->F_Score;
                    break;

                case $gaugeUnitID:
                    if ($record->F_Score > 0) {
                        if ($record->F_ExerciseID == $gaugeOneExerciseID)
                            $gaugeOneCorrect += $record->F_Score;
                        if ($record->F_ExerciseID == $gaugeTwoExerciseID)
                            $gaugeTwoCorrect += $record->F_Score;
                        $scoreDetail = new ScoreDetail();
                        $scoreDetail->fromDatabaseObj($record);
                        $gaugeDetails[] = $scoreDetail;
                    }
                    // ctp#438 To tell if we went through both parts of the gauge - for reporting test path
                    if ($record->F_ExerciseID == $gaugeTwoExerciseID)
                        $gaugeTwoUsed = true;
                    break;

                case $gaugeBonusBUnitID:
                case $gaugeBonusCUnitID:
                    if ($record->F_Score > 0)
                        $gaugeBonusCorrect += $record->F_Score;
                    // ctp#438 To tell if we went through a gauge bonus - for reporting test path
                    if ($record->F_UnitID == $gaugeBonusBUnitID)
                        $gaugeBonusBUsed = true;
                    if ($record->F_UnitID == $gaugeBonusCUnitID)
                        $gaugeBonusCUsed = true;
                    break;

                default:
                    // ignore anything else
            }
        }
        // ctp#438 Use an overall gauge score
        $gaugeCorrect = $gaugeOneCorrect + $gaugeTwoCorrect;

        // Also note which was the last section you were in
        $lastUnitID = $includeUnitIDs[$lastUnitIdx];
        switch ($lastUnitID) {
            case $gaugeUnitID:
                $track = "gauge";
                break;
            case $gaugeBonusBUnitID:
                $track = "gaugeBonusB";
                break;
            case $gaugeBonusCUnitID:
                $track = "gaugeBonusC";
                break;
            case $trackAUnitID:
                $track = 'A';
                break;
            case $trackBUnitID:
                $track = 'B';
                break;
            case $trackCUnitID:
                $track = 'C';
                break;
            case $bonusA2UnitID:
                $track = 'bonusA2';
                break;
            case $bonusB1UnitID:
                $track = 'bonusB1';
                break;
            case $bonusB2UnitID:
                $track = 'bonusB2';
                break;
            case $bonusC1UnitID:
                $track = 'bonusC1';
                break;
            case $bonusC2UnitID:
                $track = 'bonusC2';
                break;
            default:
                // Hmmmm, what track to set?
                $track = "U";
        }

        // Count tags for the items in the tracks - see later why this is not necessary
        //$A1count = $this->countTags('/A1/i', $trackDetails);
        //$A2count = $this->countTags('/A2/i', $trackDetails);
        //$B1count = $this->countTags('/B1/i', $trackDetails);
        //$B2count = $this->countTags('/B2/i', $trackDetails);
        //$C1count = $this->countTags('/C1/i', $trackDetails);
        //$C2count = $this->countTags('/C2/i', $trackDetails);

        // Count tags for items in the gauge
        $gaugeB2orAboveCount = $this->countTags('/B2|C[1-2]/i', $gaugeDetails);
        $gaugeAboveB2Count = $this->countTags('/C[1-2]/i', $gaugeDetails);

        // If you didn't make it out of the gauge, which track would you have been on?
        switch ($track) {
            case 'gauge':
                switch (true) {
                    case ($gaugeCorrect <= 4):
                    case ($gaugeCorrect >= 5 && $gaugeCorrect <= 7 && $gaugeAboveB2Count == 0):
                        $track = "A";
                        break;
                    case ($gaugeCorrect >= 5 && $gaugeCorrect <= 7 && $gaugeAboveB2Count >= 1):
                    case ($gaugeCorrect >= 8 && $gaugeCorrect <= 15):
                        $track = "B";
                        break;
                    case ($gaugeCorrect >= 16):
                        $track = "C";
                        break;
                }
                break;
            case 'gaugeBonusB':
                if ($gaugeBonusCorrect <= 1) {
                    $track = 'A';
                } else {
                    $track = 'B';
                }
                break;
            case 'gaugeBonusC':
                if ($gaugeBonusCorrect <= 1) {
                    $track = 'B';
                } else {
                    $track = 'C';
                }
                break;
            default:
                break;
        }

        // Build the CEF
        /*
         * These are the explicit conditions, but they boil down to a much simpler merged one
         * because the tag counting is only relevant to see if you get bonus questions
         *
        case ($trackCorrect <= 8):
        case ($trackCorrect == 9 && $A2count == 0):
        // This means you should have seen the A2 bonus, but never answered questions from it.
        case ($trackCorrect == 9 && $A2count > 0):
        case ($trackCorrect >= 10 && $totalCorrect <= 11):
        // A2
        case ($trackCorrect >= 12 && $trackCorrect <= 18):
        case ($trackCorrect >= 19 && $trackCorrect <= 22):

        */
        // ctp#122
        switch ($track) {
            case 'A':
                switch (true) {
                    // Special case - include gauge here for A0 test
                    case (($trackCorrect + $gaugeCorrect) <= 2):
                        $result = "A0";
                        break;
                    case ($trackCorrect <= 11):
                        $result = "A1";
                        break;
                    case ($trackCorrect >= 12):
                        $result = "A2";
                        break;
                }
                break;

            // There are two ways to run the A2 bonus questions, boundary between A1 and A2 or A2 and B1
            case 'bonusA2':
                switch (true) {
                    case ($bonusCorrect <= 1):
                        if ($trackUnitID == $trackAUnitID) {
                            $result = "A1";
                        } else {
                            $result = "A2";
                        }
                        break;
                    case ($bonusCorrect >= 2):
                        if ($trackUnitID == $trackAUnitID) {
                            $result = "A2";
                        } else {
                            $result = "B1";
                        }
                        break;
                }
                // ctp#438 To tell if we went through a gauge bonus - for reporting test path
                $trackBonusA2Used = true;
                break;

            // Only ask B1 bonus if you might be going down
            case 'bonusB1':
                switch (true) {
                    case ($bonusCorrect <= 1):
                        $result = "A2";
                        break;
                    case ($bonusCorrect >= 2):
                        $result = "B1";
                        break;
                }
                $trackBonusB1Used = true;
                break;

            case 'B':
                switch (true) {
                    case ($trackCorrect <= 2):
                        // This means you should have seen the A2 bonus, but never answered questions from it.
                        $result = "A2";
                        break;
                    case ($trackCorrect >= 3 && $trackCorrect <= 11):
                        $result = "B1";
                        break;
                    case ($trackCorrect >= 12):
                        $result = "B2";
                        break;
                }
                break;

            case 'bonusB2':
                switch (true) {
                    case ($bonusCorrect <= 1):
                        if ($trackUnitID == $trackBUnitID) {
                            $result = "B1";
                        } else {
                            $result = "B2";
                        }
                        break;
                    case ($bonusCorrect >= 2):
                        if ($trackUnitID == $trackBUnitID) {
                            $result = "B2";
                        } else {
                            $result = "C1";
                        }
                        break;
                }
                $trackBonusB2Used = true;
                break;

            case 'bonusC1':
                switch (true) {
                    case ($bonusCorrect <= 1):
                        $result = "B2";
                        break;
                    case ($bonusCorrect >= 2):
                        $result = "C1";
                        break;
                }
                $trackBonusC1Used = true;
                break;

            case 'bonusC2':
                switch (true) {
                    case ($bonusCorrect <= 1):
                        $result = "C1";
                        break;
                    case ($bonusCorrect >= 2):
                        $result = "C2";
                        break;
                }
                $trackBonusC2Used = true;
                break;

            case 'C':
                switch (true) {
                    case ($trackCorrect <= 2):
                        // This means you should have seen the B2 bonus, but never answered questions from it.
                        $result = "B2";
                        break;
                    case ($trackCorrect >= 3 && $trackCorrect <= 11):
                        $result = "C1";
                        break;
                    case ($trackCorrect >= 12):
                        $result = "C2";
                        break;
                }
                break;

            case 'U':
                $result = "U";
                break;
        }

        // ctp#438 The hurdle is based on the track that you answered questions for, not the CEFR you end up with
        switch ($trackUnitID) {
            case $trackCUnitID:
                $hurdle = 60;
                break;
            case $trackBUnitID:
                $hurdle = 30;
                break;
            case $trackAUnitID:
            default:
                $hurdle = 0;
                break;
        }


        // Check that enough questions were answered to make this a valid test (includes gauge, track and bonuses)
        if (($totalCorrect + $totalWrong) <= DPTConstants::minimumAnswersForValidResult)
            $result = "U";

        $rc = array("level" => $result, "numeric" => $gaugeCorrect + $trackCorrect + $hurdle);

        // ctp#438 Report the test path
        if ($mode=='debug') {
            $rc['gaugeOneCorrect'] = $gaugeOneCorrect;
            if ($gaugeTwoUsed)
                $rc['gaugeTwoCorrect'] = $gaugeTwoCorrect;
            $rc['gaugeAboveB2'] = $gaugeAboveB2Count;
            if ($gaugeBonusBUsed)
                $rc['gaugeBonusBCorrect'] = $gaugeBonusCorrect;
            if ($gaugeBonusCUsed)
                $rc['gaugeBonusCCorrect'] = $gaugeBonusCorrect;
            switch ($trackUnitID) {
                case $trackAUnitID:
                    $rc['track'] = 'A';
                    break;
                case $trackBUnitID:
                    $rc['track'] = 'B';
                    break;
                case $trackCUnitID:
                    $rc['track'] = 'C';
                    break;
                default:
                    $rc['track'] = 'none';
                    break;
            }
            $rc['trackCorrect'] = $trackCorrect;
            if ($track != $rc['track'])
                $rc['lastUnit'] = $track;
            if ($trackBonusA2Used)
                $rc['trackBonusA2Correct'] = $bonusCorrect;
            if ($trackBonusB1Used)
                $rc['trackBonusB1Correct'] = $bonusCorrect;
            if ($trackBonusB2Used)
                $rc['trackBonusB2Correct'] = $bonusCorrect;
            if ($trackBonusC1Used)
                $rc['trackBonusC1Correct'] = $bonusCorrect;
            if ($trackBonusC2Used)
                $rc['trackBonusC2Correct'] = $bonusCorrect;
            //$rc['lastUnitID'] = $lastUnitID;

            // Show which tags applied to correct answers
            $tags = array();
            foreach ($trackDetails as $trackDetail) {
                $detail = json_decode($trackDetail->detail);
                $tags = array_merge($tags, $detail->tags);
            }
            if (count($tags)>0) {
                $rc['trackTagsCorrect'] = array_count_values($tags);
            }
        }
        return $rc;
    }

    /**
     * This method is most likely to be tidied and moved.
     * It counts how many correctly answered questions had a particular tag
     */
    function countTags($pattern, $scoreDetails) {
        $count = 0;
        foreach ($scoreDetails as $scoreDetail) {
            $tagString = implode(',', $scoreDetail->getTags());
            $count += ((preg_match($pattern, $tagString)) && ($scoreDetail->score > 0)) ? 1 : 0;
        }
        return $count;
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
            // TODO Until the Flash Bento programs update the sessionId if it is sent back differently, this will keep
            // triggering new session records whenever anyone changes course and then for every exercise after that
            //AbstractService::$debugLog->info("update session? $sessionId as courseId=$courseId and last one is " . $rsObj->F_CourseID);
            if (($interval > self::SESSION_IDLE_THRESHOLD) ||
                ($courseId && $rsObj->F_CourseID && ($rsObj->F_CourseID != $courseId))) {
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
				// gh#954 No need to update courseId unless it was null
                if ($courseId && is_null($rsObj->F_CourseID)) {
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
     * This method is called to insert a session record for a test
     */
    function startTestSession($user, $rootId, $productCode, $testId = null) {
        // ctp#195 Is there an unfinished session for this user/test already?
        // If there is, return it (or the last one) so that we can use the same seed to recreate the same test
        // gh#1563 Update to general couloir session
        $sql = <<<EOD
				SELECT s.*
				FROM T_SessionTrack s
				WHERE s.F_UserID=?
                AND s.F_ContentID=?
                AND s.F_CompletedDateStamp = 0
                ORDER BY s.F_SessionID desc
EOD;
        $bindingParams = array($user->userID, $testId);
        $rs = $this->db->Execute($sql, $bindingParams);
        if ($rs) {
            if ($rs->recordCount() > 0) {
                $session = new SessionTrack($rs->FetchNextObj());
                // ctp#195 temporary until older sessions expunged
                if (is_null($session->getSeed()))
                    $session->setSeed(uniqid());
                return $session;
            }
        }

        // gh#604 You might start with user as a plain userId
        if ($user instanceof User) {
            // ctp#282 Everybody uses up a licence
            // For teachers we will set rootID to -1 in the session record, so, are you a teacher?
            // Or more specifically are you NOT a student
            //if (!$user->userType == User::USER_TYPE_STUDENT)
            //    $rootId = -1;
            $userId = $user->userID;
        } else {
            $userId = $user;
        }

        // ctp#261 This is written in server UTC time
        $dateStampNow = new DateTime('now', new DateTimeZone(TIMEZONE));
        $dateNow = $dateStampNow->format('Y-m-d H:i:s');

        $session = new SessionTrack();
        $session->userId = $userId;
        $session->rootId = $rootId;
        $session->productCode = $productCode;
        $session->contentId = $testId;
        $session->startDateStamp = $dateNow;
        // ctp#195 Create a seed
        $session->seed = uniqid();
        $rs = $this->db->AutoExecute("T_SessionTrack", $session->toAssocArray(), "INSERT");
        if ($rs) {
            $sessionId = $this->db->Insert_ID();
            if ($sessionId) {
                $session->sessionId = $sessionId;
                return $session;
            } else {
                // The database probably doesn't support the Insert_ID function
                throw $this->copyOps->getExceptionForId("errorCantFindAutoIncrementSessionId");
            }
        } else {
            throw $this->copyOps->getExceptionForId("errorDatabaseWriting");
        }
    }
    /**
     * This method is called to insert a session record for couloir
     * sss#17 will be superceded by common SessionTrack asap
     */
    function startCouloirSession($user, $rootId, $productCode, $uid) {
        // A special case for some titles will only run one session for a particular uid
        // An example is a test. One user will use the same session for one test even if you are signing in a second time
        if ($productCode == 63 || $productCode == 65) {
            // ctp#195 Is there an unfinished session for this user/title already?
            // If there is, return it (or the last one)
            $sql = <<<EOD
                    SELECT s.*
                    FROM T_SessionTrack s
                    WHERE s.F_UserID=?
                    AND s.F_ProductCode=?
                    AND s.F_Status = ?
                    AND s.F_ContentID=?
                    ORDER BY s.F_SessionID DESC
EOD;
            $bindingParams = array($user->userID, $productCode, SessionTrack::STATUS_OPEN, $uid);
            $rs = $this->db->Execute($sql, $bindingParams);
            if ($rs) {
                if ($rs->recordCount() > 0) {
                    return new SessionTrack($rs->FetchNextObj());
                }
            }
        }

        // gh#604 You might start with user as a plain userId
        if ($user instanceof User) {
            // ctp#282 Everybody uses up a licence
            // For teachers we will set rootID to -1 in the session record, so, are you a teacher?
            // Or more specifically are you NOT a student
            //if (!$user->userType == User::USER_TYPE_STUDENT)
            //    $rootId = -1;
            $userId = $user->userID;
        } else {
            $userId = $user;
        }

        // ctp#261 This is written in server UTC time
        $dateStampNow = new DateTime('now', new DateTimeZone(TIMEZONE));
        $dateNow = $dateStampNow->format('Y-m-d H:i:s');

        $session = new SessionTrack();
        $session->userId = $userId;
        $session->rootId = $rootId;
        $session->productCode = $productCode;
        $session->startDateStamp = $dateNow;
        $session->lastUpdateDateStamp = $dateNow;
        $session->duration = SessionTrack::MINIMUM_DURATION;
        $session->contentId = $uid;
        $session->status = SessionTrack::STATUS_OPEN;
        $rs = $this->db->AutoExecute("T_SessionTrack", $session->toAssocArray(), "INSERT");
        if ($rs) {
            $sessionId = $this->db->Insert_ID();
            if ($sessionId) {
                $session->sessionId = $sessionId;
                return $session;
            } else {
                // The database probably doesn't support the Insert_ID function
                throw $this->copyOps->getExceptionForId("errorCantFindAutoIncrementSessionId");
            }
        } else {
            throw $this->copyOps->getExceptionForId("errorDatabaseWriting");
        }
    }

    /**
     * Update a session record for Couloir
     * sss#17
     */
    public function updateCouloirSession($session, $timestamp) {

        $newDateTime = new DateTime('@'.intval($timestamp), new DateTimeZone(TIMEZONE));
        $lastDateTime = new DateTime($session->lastUpdateDateStamp, new DateTimeZone(TIMEZONE));
        $secondsDifference = $newDateTime->format('U')-$lastDateTime->format('U');

        // If this timestamp is just after the last one, add the time difference to the duration
        // If the last timestamp is quite a while ago, assume they have not been doing anything
        // and simply update the timestamp. This will be the first of at least 5 updates.
        // If this timestamp is already in the past, just drop it
        if ($secondsDifference < 0) {
            return false;
        } else if ($secondsDifference < SessionTrack::THINKING_DURATION) {
            $session->duration += $secondsDifference;
        }

        $session->lastUpdateDateStamp = $newDateTime->format('Y-m-d H:i:s');
        $rs = $this->db->AutoExecute("T_SessionTrack", $session->toAssocArray(), "UPDATE", "F_SessionID=".$session->sessionId);
    }

    /**
     * This picks up details on the session for Couloir
     * sss#17
     */
    public function getCouloirSession($sessionId) {
        $sql = <<<EOD
			select s.* from T_SessionTrack s
            where s.F_SessionID = ?
EOD;
        $bindingParams = array($sessionId);
        $rs = $this->db->Execute($sql, $bindingParams);
        if ($rs) {
            if ($rs->recordCount() > 0) {
                $rsObj = $rs->FetchNextObj();
                $session = new SessionTrack($rsObj);
                return $session;
            }
        }
        throw $this->copyOps->getExceptionForId("errorNoSession", array("id" => $sessionId));
    }
    /**
	 * This method is called to insert a score record to the database 
	 */
    // ctp#282 Force score to be written for any usertype
	function insertScore($score) {

		$sql = <<<EOD
			INSERT INTO T_Score (F_UserID,F_ProductCode,F_CourseID,F_UnitID,F_ExerciseID,
					F_Duration,F_Score,F_ScoreCorrect,F_ScoreWrong,F_ScoreMissed,
					F_DateStamp,F_SessionID)
			VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
EOD;

		$bindingParams = array($score->userID, $score->productCode, $score->courseID, $score->unitID, $score->exerciseID, 
								$score->duration, $score->score, $score->scoreCorrect, $score->scoreWrong, $score->scoreMissed, 
								$score->dateStamp, $score->sessionID);

		try {
            $rc = $this->db->Execute($sql, $bindingParams);
        } catch (Exception $e) {
            // ctp#166
            if ($this->db->ErrorNo() == 1062)
                throw $this->copyOps->getExceptionForId("errorDatabaseDuplicateRecord", array("msg" => $this->db->ErrorMsg()));
            throw $e;
        }
		if (!$rc)
            throw $this->copyOps->getExceptionForId("errorDatabaseWriting", array("msg" => $this->db->ErrorMsg()));

		// #308
		//return $rc;
		// gh#119
		return $score;
	}

    /**
     * This method is called to insert a score record to the database
     */
    // ctp#282 Force score to be written for any usertype
    function insertScoreDetails($scoreDetails) {

        $rootID = 'null'; // I don't think this needs to be in T_ScoreDetail does it?
        $sqlData = array();
        foreach($scoreDetails as $scoreDetail) {
            if (!$scoreDetail->unitID) $scoreDetail->unitID = 'null';
            if (!$scoreDetail->exerciseID) $scoreDetail->exerciseID = 'null';
            if (!$scoreDetail->courseID) $scoreDetail->courseID = 'null';
            if (!$scoreDetail->score) $scoreDetail->score = 'null';
            // dpt#469 Included presented but not attempted, datestamp will be null
            $quotedDateStamp = ($scoreDetail->dateStamp) ? "'".$scoreDetail->dateStamp."'" : 'null';
            $sqlData[] = "(".$scoreDetail->userID.", ".$rootID.", ".$scoreDetail->sessionID.
                ", ".$scoreDetail->unitID.", '".$scoreDetail->exerciseID."'".
                ", '".$scoreDetail->itemID."', ".$scoreDetail->score.", '".$scoreDetail->detail."', ".$quotedDateStamp.")";
        }
        $sql = <<<EOD
			INSERT INTO T_ScoreDetail (F_UserID,F_RootID,F_SessionID,F_UnitID,F_ExerciseID,F_ItemID,F_Score,F_Detail,F_DateStamp)
			VALUES 
EOD;
        $sql .= implode(',', $sqlData);

        // ctp#337
        try {
            $rc = $this->db->Execute($sql);
        } catch (Exception $e) {
            // ctp#166
            if ($this->db->ErrorNo() == 1062)
                throw $this->copyOps->getExceptionForId("errorDatabaseDuplicateRecord", array("msg" => $this->db->ErrorMsg()));
            throw $e;
        }
        if (!$rc)
            throw $this->copyOps->getExceptionForId("errorDatabaseWriting", array("msg" => $this->db->ErrorMsg()));

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
