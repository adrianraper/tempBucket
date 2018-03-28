<?php

class ProgressOps {

    var $db;
    var $menu;

    // gh#604 Seconds before the session record is considered too old and a new one started
    const SESSION_IDLE_THRESHOLD = 3600;
    // gh#954 All licence counting is > 15, so for new users this will help accurate reflection
    const MINIMUM_DURATION = 16; // Minimum seconds used as duration for new session records

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
        $sql = <<<EOD
			SELECT sc.F_CourseID AS CourseID, sc.F_AverageScore AS AverageScore, sc.F_AverageDuration AS AverageDuration, sc.F_Count AS Count, sc.F_Country AS Country
			FROM T_ScoreCache sc
			INNER JOIN(
			    SELECT F_CourseID AS id, MAX(F_DateStamp) AS latest
			    FROM T_ScoreCache
			    WHERE F_ProductCode = ?
			    AND F_Country = ?
			    GROUP BY F_CourseID
			) i ON sc.F_CourseID = i.id AND sc.F_DateStamp = i.latest
			WHERE sc.F_ProductCode = ?
			AND sc.F_UnitID IS NULL
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
        $sql = <<<EOD
			SELECT sc.F_CourseID AS CourseID, sc.F_UnitID AS UnitID, sc.F_AverageScore AS AverageScore, sc.F_AverageDuration AS AverageDuration, sc.F_Count AS Count
			FROM T_ScoreCache sc
			INNER JOIN(
			    SELECT F_UnitID AS id, max(F_DateStamp) AS latest
			    FROM T_ScoreCache
			    WHERE F_ProductCode = ?
				AND F_UnitID IS NOT NULL
			    GROUP BY F_UnitID
			) i ON sc.F_UnitID = i.id AND sc.F_DateStamp = i.latest
			WHERE sc.F_ProductCode = ?
			AND sc.F_UnitID IS NOT NULL
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
        $sql = <<<SQL
			SELECT s.*
			FROM T_Score AS s
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
			SELECT F_ExerciseID AS exerciseID, SUM(F_ScoreCorrect) AS mastery
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
     * These are Couloir functions but NOT called by CTPService (DPT) so are not called here
     *
     * public function getExercisesCompleted($session) {
     * $sql = <<<SQL
     * SELECT *
     * FROM T_Score
     * WHERE F_ProductCode=?
     * AND F_UserID=?
     * SQL;
     *
     * $bindingParams = array($session->productCode, $session->userId);
     * $rs = $this->db->GetArray($sql, $bindingParams);
     *
     * return $rs;
     *
     * }
     * public function getUnitProgress($session) {
     * // F_ProductCode, F_CourseID, F_UnitID, F_AverageScore, F_AverageDuration, F_Count, F_DateStamp, F_Country
     * $sql = <<<SQL
     * SELECT F_UnitID as unitId, SUM(if(F_Duration>3600,3600,F_Duration)) as duration, AVG(if(F_Score<0,0,F_Score)) as averageScore, AVG(if(F_Duration>3600,3600,F_Duration)) as averageDuration, COUNT(F_UserID) as exerciseCount
     * FROM T_Score
     * WHERE F_ProductCode=?
     * AND F_UserID=?
     * GROUP BY F_UnitID
     * SQL;
     *
     * $bindingParams = array($session->productCode, $session->userId);
     * $rs = $this->db->GetArray($sql, $bindingParams);
     *
     * return $rs;
     *
     * }
     */
    /**
     * This is for calculating the placement test result.
     * With full complexity this will require access to detailed scores so you can look at question tags (A2 etc)
     * as well as the number correct.
     * It should also be read from a DPT specific scoring chart. scoring.json perhaps?
     *
     */
    function getTestResult($session, $mode = null) {

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
        $sql = <<<SQL
            SELECT sd.*
        	FROM T_ScoreDetail sd
	        INNER JOIN (
              SELECT F_SessionID AS id, F_ItemID AS itemID, MIN(F_DateStamp) AS firstRecord
		      FROM T_ScoreDetail
		      WHERE F_SessionID=?
SQL;
        $sql .= " AND F_UnitID in ('" . implode("','", $includeUnitIDs) . "')";
        $sql .= <<<SQL
		      GROUP BY F_ExerciseID, F_ItemID
	        ) i ON sd.F_SessionID = i.id AND sd.F_ItemID = i.itemID AND sd.F_DateStamp = i.firstRecord
	        WHERE sd.F_SessionID=?
SQL;
        $sql .= " AND F_UnitID in ('" . implode("','", $includeUnitIDs) . "')";
        // dpt#469 And exclude presented but not attempted answers (though the datestamp should exclude them alredy)
        $sql .= " AND F_Score is not null";
        $sql .= " GROUP BY sd.F_ExerciseID, sd.F_ItemID";
        $bindingParams = array($session->sessionId, $session->sessionId);
        $rs = $this->db->Execute($sql, $bindingParams);

        if ($rs->RecordCount() == 0)
            // No answers have been saved. Exception?
            return null;

        // TODO Currently you don't get records from the query that are presented not attempted, but we should
        $totalCorrect = $totalWrong = $totalSkipped = 0;
        $trackCorrect = $trackWrong = $trackBonusCorrect = 0;
        $gaugeCorrect = $gaugeOneCorrect = $gaugeTwoCorrect = $gaugeBonusCorrect = $gaugeWrong = 0;
        $trackUnitID = $trackBonusUnitID = $gaugeBonusUnitID = $lastUnitID = null;
        $lastUnitIdx = 0;
        // ctp#438 Just for reporting the test path
        $gaugeTwoUsed = false; //$gaugeBonusBUsed = $gaugeBonusCUsed = $trackBonusA2Used = $trackBonusB1Used = $trackBonusB2Used = $trackBonusC1Used = $trackBonusC2Used = false;

        $trackDetails = array();
        $gaugeDetails = array();
        while ($record = $rs->FetchNextObj()) {
            // ctp#315 Although records are mostly written in order, a few do get out of sync so you can't assume
            // that the last one written was the last one done.
            $unitIdx = array_search($record->F_UnitID, $includeUnitIDs);
            $lastUnitIdx = ($unitIdx && ($unitIdx > $lastUnitIdx)) ? $unitIdx : $lastUnitIdx;

            // Keep track of total questions answered to see if you passed a threshold for an unspoilt test
            if ($record->F_Score > 0) {
                $totalCorrect += $record->F_Score;
            } elseif ($record->F_Score < 0) {
                $totalWrong += abs($record->F_Score);
            } elseif ($record->F_Score == null) {
                $totalSkipped++;
                //  No point doing anymore counting up with skipped questions
                continue;
            }

            // dpt#459
            if ($mode == 'debug') {
                $innerSql = <<<SQL
                SELECT u.* FROM T_User u
                WHERE u.F_UserID=?
SQL;
                $bindingParams = array($record->F_UserID);
                $innerRs = $this->db->Execute($innerSql, $bindingParams);
                if ($innerRs && $innerRs->recordCount() > 0) {
                    $userObj = $innerRs->FetchNextObj();
                    $email = $userObj->F_Email;
                } else {
                    $email = 'no email';
                }
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
                    } else if ($record->F_Score < 0) {
                        $trackWrong += abs($record->F_Score);
                    }
                    $trackUnitID = $record->F_UnitID;
                    break;

                case $bonusA2UnitID:
                case $bonusB1UnitID:
                case $bonusB2UnitID:
                case $bonusC1UnitID:
                case $bonusC2UnitID:
                    // TODO Why don't I add this record to trackDetails?
                    if ($record->F_Score > 0)
                        $trackBonusCorrect += $record->F_Score;
                    $trackBonusUnitID = $record->F_UnitID;
                    break;

                case $gaugeUnitID:
                    if ($record->F_Score > 0) {
                        if ($record->F_ExerciseID == $gaugeOneExerciseID) {
                            $gaugeOneCorrect += $record->F_Score;
                        }
                        if ($record->F_ExerciseID == $gaugeTwoExerciseID) {
                            $gaugeTwoCorrect += $record->F_Score;
                            // ctp#438 To tell if we went through both parts of the gauge - for reporting test path
                            $gaugeTwoUsed = true;
                        }
                        $scoreDetail = new ScoreDetail();
                        $scoreDetail->fromDatabaseObj($record);
                        $gaugeDetails[] = $scoreDetail;
                    } else if ($record->F_Score < 0) {
                        $gaugeWrong += abs($record->F_Score);
                    }
                    break;

                case $gaugeBonusBUnitID:
                case $gaugeBonusCUnitID:
                    if ($record->F_Score > 0)
                        $gaugeBonusCorrect += $record->F_Score;
                    // TODO Why don't I add this record to trackDetails?
                    // ctp#438 To tell if we went through a gauge bonus - for reporting test path
                    $gaugeBonusUnitID = $record->F_UnitID;
                    break;

                default:
                    // ignore anything else
            }
        }
        // ctp#438 Use an overall gauge score
        $gaugeCorrect = $gaugeOneCorrect + $gaugeTwoCorrect;

        // Which was the last section you were in?
        $lastUnitID = $includeUnitIDs[$lastUnitIdx];

        // Count tags for the items in the gauge and tracks
        // TODO is this duplication of $this->countTags('/B2|C[1-2]/i', $gaugeDetails);
        $trackTags = array();
        foreach ($trackDetails as $trackDetail) {
            $detail = json_decode($trackDetail->detail);
            $trackTags = array_merge($trackTags, $detail->tags);
        }
        $trackTags = array_count_values($trackTags);
        $gaugeTags = array();
        foreach ($gaugeDetails as $gaugeDetail) {
            $detail = json_decode($gaugeDetail->detail);
            $gaugeTags = array_merge($gaugeTags, $detail->tags);
        }
        $gaugeTags = array_count_values($gaugeTags);

        // Count tags for items in the gauge
        //$gaugeB2orAboveCount = $this->countTags('/B2|C[1-2]/i', $gaugeDetails);
        $gaugeAboveB2Count = $this->countTags('/C[1-2]/i', $gaugeDetails);

        // Figuring out which track you went through - or would have gone through
        switch ($lastUnitID) {
            case $gaugeUnitID:
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
            case $gaugeBonusBUnitID:
                if ($gaugeBonusCorrect <= 1) {
                    $track = 'A';
                } else {
                    $track = 'B';
                }
                break;
            case $gaugeBonusCUnitID:
                if ($gaugeBonusCorrect <= 1) {
                    $track = 'B';
                } else {
                    $track = 'C';
                }
                break;
            case $trackAUnitID:
            case $bonusB1UnitID:
                $track = 'A';
                break;
            case $trackBUnitID:
            case $bonusC1UnitID:
                $track = 'B';
                break;
            case $trackCUnitID:
            case $bonusC2UnitID:
                $track = 'C';
                break;
            case $bonusA2UnitID:
                if ($trackUnitID == $trackAUnitID) {
                    $track = 'A';
                } else {
                    $track = 'B';
                }
                break;
            case $bonusB2UnitID:
                if ($trackUnitID == $trackBUnitID) {
                    $track = 'B';
                } else {
                    $track = 'C';
                }
                break;
            default:
                $track = "U";
        }

        // Build the CEF
        // ctp#122
        switch ($track) {
            case 'A':
                if ($lastUnitID == $bonusA2UnitID) {
                    if ($trackBonusCorrect <= 1) {
                        $result = "A1";
                    } else {
                        $result = "A2";
                    }
                } else if ($lastUnitID == $bonusB1UnitID) {
                    if ($trackBonusCorrect <= 1) {
                        $result = "A2";
                    } else {
                        $result = "B1";
                    }
                } else {
                    // Special case - include gauge here for A0 test
                    if (($trackCorrect + $gaugeCorrect) <= 2) {
                        $result = "A0";
                    } else if ($trackCorrect <= 11) {
                        $result = "A1";
                    } else if ($trackCorrect >= 12) {
                        $result = "A2";
                    }
                }
                break;

            case 'B':
                if ($lastUnitID == $bonusB2UnitID) {
                    if ($trackBonusCorrect <= 1) {
                        $result = "B1";
                    } else {
                        $result = "B2";
                    }
                } else if ($lastUnitID == $bonusC1UnitID) {
                    if ($trackBonusCorrect <= 1) {
                        $result = "B2";
                    } else {
                        $result = "C1";
                    }
                } else {
                    if ($trackCorrect <= 2) {
                        // This means you should have seen the A2 bonus, but never answered questions from it.
                        $result = "A2";
                    } else if ($trackCorrect >= 3 && $trackCorrect <= 11) {
                        $result = "B1";
                    } else if ($trackCorrect >= 12) {
                        $result = "B2";
                    }
                }
                break;

            case 'C':
                if ($lastUnitID == $bonusB2UnitID) {
                    if ($trackBonusCorrect <= 1) {
                        $result = "B2";
                    } else {
                        $result = "C1";
                    }
                } else if ($lastUnitID == $bonusC2UnitID) {
                    if ($trackBonusCorrect <= 1) {
                        $result = "C1";
                    } else {
                        $result = "C2";
                    }
                } else {
                    if ($trackCorrect <= 2) {
                        // This means you should have seen the B2 bonus, but never answered questions from it.
                        $result = "B2";
                    } else if ($trackCorrect >= 3 && $trackCorrect <= 11) {
                        $result = "C1";
                    } else if ($trackCorrect >= 12) {
                        $result = "C2";
                    }
                }
                break;

            case 'U':
                $result = "U";
                break;
        }

        // Check that enough questions were answered to make this a valid test (includes gauge, track and bonuses)
        if (($totalCorrect + $totalWrong) <= DPTConstants::minimumAnswersForValidResult)
            $result = "U";

        // dpt#470 recalibrate the relative numeric
        if ($result == "U") {
            $rn = 0;
        } else {
            $rn = $this->rnMapper($result, $track, $trackCorrect, $trackBonusCorrect, $gaugeCorrect, $trackTags, $gaugeTags);
        }
        $rc = array("level" => $result, "numeric" => $rn);

        // ctp#438 Report the test path
        if ($mode == 'debug') {
            $rc['email'] = $email;
            $rc['gauge'] = array('one' => $gaugeOneCorrect);
            if ($gaugeTwoUsed)
                $rc['gauge']['two'] = $gaugeTwoCorrect;
            $rc['gauge']['wrong'] = $gaugeWrong;
            if ($gaugeBonusUnitID == $gaugeBonusBUnitID)
                $rc['gaugeBonus'] = array('B1' => $gaugeBonusCorrect);
            if ($gaugeBonusUnitID == $gaugeBonusCUnitID)
                $rc['gaugeBonus'] = array('C1' => $gaugeBonusCorrect);
            $rc['track'] = array($track => $trackCorrect, 'wrong' => $trackWrong);
            if ($trackBonusUnitID == $bonusA2UnitID)
                $rc['trackBonus'] = array('A2' => $trackBonusCorrect);
            if ($trackBonusUnitID == $bonusB1UnitID)
                $rc['trackBonus'] = array('B1' => $trackBonusCorrect);
            if ($trackBonusUnitID == $bonusB2UnitID)
                $rc['trackBonus'] = array('B2' => $trackBonusCorrect);
            if ($trackBonusUnitID == $bonusC1UnitID)
                $rc['trackBonus'] = array('C1' => $trackBonusCorrect);
            if ($trackBonusUnitID == $bonusC2UnitID)
                $rc['trackBonus'] = array('C2' => $trackBonusCorrect);
            //$rc['lastUnit'] = $lastUnitID;

            // Show which tags applied to correct answers
            $rc['gaugeTagsCorrect'] = $gaugeTags;
            $rc['trackTagsCorrect'] = $trackTags;
        }
        return $rc;
    }

    /*
     * Relative numeric has a range of 20 for each CEFR level. Use the number of questions
     * right in the track plus bonus questions (and perhaps the gauge) to map to these 20 points.
     */
    private function rnMapper($result, $track, $trackCorrect, $bonusCorrect, $gaugeCorrect, $trackTags, $gaugeTags) {
        // Mapping mainly based on final result
        switch ($result) {
            case 'A1':
                // map top of A1 based on bonus questions
                if ($trackCorrect == 9 && $this->getCorrectTags($trackTags, "A2") > 0) {
                    return ($bonusCorrect > 0) ? 16 : 15;
                } else if ($trackCorrect == 10) {
                    return ($bonusCorrect > 0) ? 18 : 17;
                } else if ($trackCorrect == 11) {
                    return ($bonusCorrect > 0) ? 20 : 19;
                    // map 0-9 to 1-14 in numeric
                } else if ($trackCorrect == 0) {
                    return 1;
                } else if ($trackCorrect == 1) {
                    return ($gaugeCorrect > 4) ? 3 : 2;
                } else if ($trackCorrect == 2) {
                    return 4;
                } else if ($trackCorrect == 3) {
                    return ($gaugeCorrect > 4) ? 6 : 5;
                } else if ($trackCorrect == 4) {
                    return 7;
                } else if ($trackCorrect == 5) {
                    return ($gaugeCorrect > 4) ? 9 : 8;
                } else if ($trackCorrect == 6) {
                    return 10;
                } else if ($trackCorrect == 7) {
                    return ($gaugeCorrect > 4) ? 12 : 11;
                } else if ($trackCorrect == 8) {
                    return 13;
                } else if ($trackCorrect == 9) {
                    return 14;
                }
                break;

            case 'A2':
                // Map 3 track + 2 bonus (6) to 5 slots
                if ($trackCorrect == 9) {
                    return ($bonusCorrect > 2) ? 22 : 21;
                } else if ($trackCorrect == 10) {
                    return ($bonusCorrect > 2) ? 23 : 22;
                } else if ($trackCorrect == 11) {
                    return ($bonusCorrect > 2) ? 25 : 24;
                    // map straight questions (7) to 7 slots
                } else if (12 <= $trackCorrect && $trackCorrect <= 18) {
                    return $trackCorrect + 14;
                    // map 4 track + 2 bonus (8) to 6 slots
                } else if ($trackCorrect == 19) {
                    return 33;
                } else if ($trackCorrect == 20) {
                    return ($bonusCorrect > 0) ? 35 : 34;
                } else if ($trackCorrect == 21) {
                    return ($bonusCorrect > 0) ? 37 : 36;
                } else if ($trackCorrect == 22) {
                    return 38;
                    // map drop from higher track + 2 bonus (2) to 2 slots
                } else if ($track == 'B') {
                    return ($bonusCorrect == 0) ? 39 : 40;
                } else {
                    // Raise an error as an unexpected condition
                }
                break;

            case 'B1':
                // map climb from lower track + 2 bonus (2) to 2 slots
                if ($track == 'A') {
                    return ($bonusCorrect == 2) ? 41 : 42;
                    // Map 3 track + 2 bonus (6) to 5 slots
                } else if ($trackCorrect == 0) {
                    return ($bonusCorrect > 2) ? 44 : 43;
                } else if ($trackCorrect == 1) {
                    return ($bonusCorrect > 2) ? 45 : 44;
                } else if ($trackCorrect == 2) {
                    return ($bonusCorrect > 2) ? 47 : 46;
                    // map straight questions (7) to 7 slots
                } else if ((3 <= $trackCorrect && $trackCorrect <= 8) ||
                    ($trackCorrect == 9 && $this->getCorrectTags($trackTags, "B2") == 0)) {
                    return $trackCorrect + 45;
                    // map 3 track + 2 bonus (6) to 6 slots
                } else if ($trackCorrect == 9) {
                    return ($bonusCorrect > 0) ? 56 : 55;
                } else if ($trackCorrect == 10) {
                    return ($bonusCorrect > 0) ? 58 : 57;
                } else if ($trackCorrect == 11) {
                    return ($bonusCorrect > 0) ? 60 : 59;
                }
                break;

            case 'B2':
                // Map 3 track + 2 bonus (6) to 5 slots
                if ($trackCorrect == 9) {
                    return ($bonusCorrect > 2) ? 62 : 61;
                } else if ($trackCorrect == 10) {
                    return ($bonusCorrect > 2) ? 63 : 62;
                } else if ($trackCorrect == 11) {
                    return ($bonusCorrect > 2) ? 65 : 64;
                    // map straight questions (7) to 7 slots
                } else if (12 <= $trackCorrect && $trackCorrect <= 18) {
                    return $trackCorrect + 54;
                    // map 4 track + 2 bonus (8) to 6 slots
                } else if ($trackCorrect == 19) {
                    return 73;
                } else if ($trackCorrect == 20) {
                    return ($bonusCorrect > 0) ? 75 : 74;
                } else if ($trackCorrect == 21) {
                    return ($bonusCorrect > 0) ? 77 : 76;
                } else if ($trackCorrect == 22) {
                    return 78;
                    // map drop from higher track + 2 bonus (2) to 2 slots
                } else if ($track == 'C') {
                    return ($bonusCorrect == 0) ? 79 : 80;
                } else {
                    // Raise an error as an unexpected condition
                }
                break;

            case 'C1':
                // map climb from lower track + 2 bonus (2) to 2 slots
                if ($track == 'B') {
                    return ($bonusCorrect == 2) ? 81 : 82;
                    // Map 3 track + 2 bonus (6) to 5 slots
                } else if ($trackCorrect == 0) {
                    return ($bonusCorrect > 2) ? 84 : 83;
                } else if ($trackCorrect == 1) {
                    return ($bonusCorrect > 2) ? 85 : 84;
                } else if ($trackCorrect == 2) {
                    return ($bonusCorrect > 2) ? 87 : 86;
                    // map straight questions (7) to 7 slots
                } else if ((3 <= $trackCorrect && $trackCorrect <= 8) ||
                    ($trackCorrect == 9 && $this->getCorrectTags($trackTags, "C2") == 0)) {
                    return $trackCorrect + 85;
                    // map 3 track + 2 bonus (6) to 6 slots
                } else if ($trackCorrect == 9) {
                    return ($bonusCorrect > 0) ? 96 : 95;
                } else if ($trackCorrect == 10) {
                    return ($bonusCorrect > 0) ? 98 : 97;
                } else if ($trackCorrect == 11) {
                    return ($bonusCorrect > 0) ? 100 : 99;
                }
                break;

            case 'C2':
                // map 3 track and 2 bonus to 6 slots
                if ($trackCorrect == 9) {
                    return ($bonusCorrect > 2) ? 102 : 101;
                } else if ($trackCorrect == 10) {
                    return ($bonusCorrect > 2) ? 104 : 103;
                } else if ($trackCorrect == 11) {
                    return ($bonusCorrect > 2) ? 106 : 105;
                } else {
                    return $trackCorrect + $this->getCorrectTags($gaugeTags, "C2") + 95;
                }
                break;

            default:
                // Catch A0 - and anything else unexpected
        }
        return 0;
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
     * This looks in a standard array to see how many items were correct at a level
     * It might be far too specific really
     */
    private function getCorrectTags($tags, $needle) {
        foreach ($tags as $tag => $value) {
            if ($needle == $tag)
                return $value;
        }
        return 0;
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
        $dateSoon = $dateStampNow->modify('+' . self::MINIMUM_DURATION . ' seconds')->format('Y-m-d H:i:s');

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
                    $sql .= " F_Duration=TIMESTAMPDIFF(SECOND,F_StartDateStamp,?) ";
                } else if (strpos($GLOBALS['dbms'], "sqlite") !== false) {
                    $sql .= " F_Duration = strftime('%s',?) -strftime('%s', F_StartDateStamp) ";
                } else {
                    $sql .= " F_Duration=DATEDIFF(s,F_StartDateStamp,?) ";
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
        $sql = <<<EOD
				SELECT s.*
				FROM T_TestSession s
				WHERE s.F_UserID=?
                AND s.F_TestID=?
                AND s.F_CompletedDateStamp IS NULL
                ORDER BY s.F_SessionID DESC
EOD;
        $bindingParams = array($user->userID, $testId);
        $rs = $this->db->Execute($sql, $bindingParams);
        if ($rs) {
            if ($rs->recordCount() > 0) {
                $rsObj = $rs->FetchNextObj();
                $session = new TestSession($rsObj);
                // ctp#195 temporary until older sessions expunged
                if (is_null($session->seed))
                    $session->seed = uniqid();
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

        $session = new TestSession();
        $session->userId = $userId;
        $session->rootId = $rootId;
        $session->productCode = $productCode;
        $session->testId = $testId;
        $session->readyDateStamp = $dateNow;
        // ctp#195 Create a seed
        $session->seed = uniqid();
        $rs = $this->db->AutoExecute("T_TestSession", $session->toAssocArray(), "INSERT");
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
     * Update a session record for a test - make sure it includes the test id and any updated status
     *
     */
    public function updateTestSession($session) {
        $this->db->AutoExecute("T_TestSession", $session->toAssocArray(), "UPDATE", "F_SessionID=" . $session->sessionId);
    }

    /**
     * These are Couloir functions but NOT called by CTPService (DPT) so are not called here
     *
     * public function getSession($sessionId) {
     * $sql = <<<EOD
     * select s.* from T_Session s
     * where s.F_SessionID = ?
     * EOD;
     * $bindingParams = array($sessionId);
     * $rs = $this->db->Execute($sql, $bindingParams);
     * if ($rs) {
     * if ($rs->recordCount() > 0) {
     * $rsObj = $rs->FetchNextObj();
     * $session = new ContextSession($rsObj);
     * return $session;
     * }
     * }
     * throw $this->copyOps->getExceptionForId("errorNoSession", array("id" => $sessionId));
     * }
     */

    /**
     * This method is called to insert a score record to the database
     */
    // ctp#282 Force score to be written for any usertype
    function insertScore($score, $user, $forceScoreWriting = false) {
        // For teachers we will set score to -1 in the score record, so, are you a teacher?
        if (!$user->userType == 0 && !$forceScoreWriting)
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
    function insertScoreDetails($scoreDetails, $user, $forceScoreWriting = false) {
        // For teachers we will not save any score details
        if (!$user->userType == 0 && !$forceScoreWriting)
            return;

        $rootID = 'null'; // I don't think this needs to be in T_ScoreDetail does it?
        $sqlData = array();
        foreach ($scoreDetails as $scoreDetail) {
            if (!$scoreDetail->unitID) $scoreDetail->unitID = 'null';
            if (!$scoreDetail->exerciseID) $scoreDetail->exerciseID = 'null';
            if (!$scoreDetail->courseID) $scoreDetail->courseID = 'null';
            if (!$scoreDetail->score) $scoreDetail->score = 'null';
            // dpt#469 Included presented but not attempted, datestamp will be null
            $quotedDateStamp = ($scoreDetail->dateStamp) ? "'" . $scoreDetail->dateStamp . "'" : 'null';
            $sqlData[] = "(" . $user->userID . ", " . $rootID . ", " . $scoreDetail->sessionID .
                ", " . $scoreDetail->unitID . ", '" . $scoreDetail->exerciseID . "'" .
                ", '" . $scoreDetail->itemID . "', " . $scoreDetail->score . ", '" . $scoreDetail->detail . "', " . $quotedDateStamp . ")";
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