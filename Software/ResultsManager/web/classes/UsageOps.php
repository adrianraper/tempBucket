<?php
require_once(dirname(__FILE__)."/SelectBuilder.php");
class UsageOps {

	var $db;

	function UsageOps($db) {
		$this->db = $db;
		$this->licenceOps = new LicenceOps($db);
		$this->manageableOps = new ManageableOps($db);
	}
	
	/**
	 * If you changed the db, you'll need to refresh it here
	 * Not a very neat function...
	 */
	function changeDB($db) {
		$this->db = $db;
		$this->licenceOps->changeDB($db);
		$this->manageableOps->changeDB($db);
	}
	
	function getUsageForTitle($title, $fromDate, $toDate) {
		//NetDebug::trace("getUsageForTitle: from ".$fromDate." to ".$toDate);		
		$usage = array();
		//$usage['courseUserCounts'] = $this->getCourseUserCounts($title, $fromDate, $toDate);
		//$usage['courseTimeCounts'] = $this->getCourseTimeCounts($title, $fromDate, $toDate);
		// v3.5 This is picking up all usage stats that we want, it differs for AA and LT licences
		$rootID = Session::get('rootID');
		// What stats do we want for AA licences? Well, everything except for licence counts
		//$fromDateStamp = $this->licenceOps->getLicenceClearanceDate($title);

		//v3.7 move this part to getFixedUsageForTitle
		/*if ($title->licenceType == 2) {
			//NetDebug::trace("AA usage stats please");		
			//$usage['sessionDuration'] = $this->getAASessionDuration($title, $fromDate, $toDate);
		} else {
			// AR also read the number of title/user licences that have been used. This is based on licence
			// period, not the dates the reporter selected
			$usage['titleUserCounts'] = $this->getTitleUserCounts($title, $rootID, $fromDateStamp);
			NetDebug::trace("getUsageForTitle: from ".strftime('%Y-%m-%d 00:00:00',$fromDateStamp)." is ".$usage['titleUserCounts']);
		}
		$usage['sessionCounts'] = $this->getAASessionCounts($title, $fromDate, $toDate);*/
		$courseCountArray = $this->getCourseCounts($title, $fromDate, $toDate);
		$usage['courseCounts'] = $courseCountArray['courseCounts'];
		if (isset($courseCountArray['otherCourseCounts']))
			$usage['otherCourseCounts'] = $courseCountArray['otherCourseCounts'];
		$usage['failedLoginCounts'] = $this->getFailedLoginCounts($title, $rootID, $fromDate, $toDate);
		//v3.7 move this part to getFixedUsageForTitle
		/*// Tell RM what date we used for licence clearance date, so it doesn't calculate it wrongly
		$usage['licenceClearanceDate'] = strftime('%Y-%m-%d 00:00:00',$fromDateStamp);
		//get the total usage times over the last year.
		  $usage['overLastYear'] = $this->getOverLastYear($title, $fromDate, $toDate);*/
		return $usage;
	}
	
	/*
	V3.7 We seperate the fixed statistic from the getUsageForTitle, which include session, overLastYear and licence.
	*/
	function getFixedUsageForTitle ($title, $fromDate, $toDate) {
	    $usage = array();
		$rootID = Session::get('rootID');
		
		$fromDateStamp = $this->licenceOps->getLicenceClearanceDate($title);
		if ($title->licenceType == 2) {
			//NetDebug::trace("AA usage stats please");		
			//$usage['sessionDuration'] = $this->getAASessionDuration($title, $fromDate, $toDate);
		} else {
			// AR also read the number of title/user licences that have been used. This is based on licence
			// period, not the dates the reporter selected
			$usage['titleUserCounts'] = $this->getTitleUserCounts($title, $rootID, $fromDateStamp);
			//NetDebug::trace("getUsageForTitle: from ".strftime('%Y-%m-%d 00:00:00',$fromDateStamp)." is ".$usage['titleUserCounts']);
		}
		
		$usage['sessionCounts'] = $this->getAASessionCounts($title, $fromDate, $toDate);
		$usage['licenceClearanceDate'] = strftime('%Y-%m-%d 00:00:00',$fromDateStamp);
		$usage['overLastYear'] = $this->getOverLastYear($title, $fromDate, $toDate);
		return $usage;
	}
	
	function getTitleUserCounts($title, $rootID, $fromDateStamp = null) {
		return $this->licenceOps->countLicencesUsed($title, $rootID, $fromDateStamp);
	}
	
	// The following is a public function for getting licences used for all titles in an account.
	// Called from DMS EarlyWarning
	function getLicencesUsedForAccount($account) {
		$accountLicenceTypes=0;
		foreach ($account->titles as $title) {
			// v3.6.5 Add licence clearance date.
			$fromDateStamp = $this->licenceOps->getLicenceClearanceDate($title);
				
			// As well as licences used, I want to know if this account is purely one licence type.
			// If an AA licence has had RM added, it too should be AA
			switch ($title->licenceType) {
				case Title::LICENCE_TYPE_LT:
				case Title::LICENCE_TYPE_TT:
					$title->licencesUsed = $this->getTitleUserCounts($title, $account->id, $fromDateStamp);
					$accountLicenceTypes = $accountLicenceTypes | 1;
					break;
				case Title::LICENCE_TYPE_AA:
					$accountLicenceTypes = $accountLicenceTypes | 2;
					break;
				case Title::LICENCE_TYPE_CT:
				case Title::LICENCE_TYPE_NETWORK:
					$accountLicenceTypes = $accountLicenceTypes | 4;
					break;
				case Title::LICENCE_TYPE_SINGLE:
					$accountLicenceTypes = $accountLicenceTypes | 8;
					break;
				case Title::LICENCE_TYPE_I:
					$accountLicenceTypes = $accountLicenceTypes | 16;
					break;
				default:
					// Shouldn't exist at the moment
					$accountLicenceTypes = $accountLicenceTypes | 32;
					break;
			}
		}
		$account->licenceType = $accountLicenceTypes;
	}
	function getFailedSessionsForAccount($account, $fromDate, $toDate) {
	//echo 'getFailedSessionsForAccount='.$account->name;
		$counter=0;
		foreach ($account->titles as $title) {
			$allFailures = $this->getFailedLoginCounts($title, $account->id, $fromDate, $toDate);
			// Save them all, but particularly pull out the sum of all failed because licence full
			$title-> failedLoginCounts = $allFailures;
			foreach($allFailures as $record) {
				if ($record['F_ReasonCode']==211) {
					$counter+=$record['failedLogins'];
				}
			}
		}
		$account->failedSessionCount = $counter;
	}
	function getSessionsForAccount($account, $fromDate, $toDate) {
	//echo 'getSessionsForAccount='.$account->name;
		$counter = 0;
		$rs = $this->getDMSSessionCounts($account->id, $fromDate, $toDate);
		foreach ($account->titles as $title) {
			$theseSessions=0;
			foreach ($rs as $record) {
				if ($record['productCode'] == $title->productCode) {
					$theseSessions = $record['sessionCount'];
					break 1;
				}
			}
			$title->sessionCounts = $theseSessions;
			// Might as well add them up here
			$account->sessionCounts+=$theseSessions;
		}
	}
	
	/* 
	 * v3.5 For usage stats used in DMS reports
	 */
	function getDMSSessionCounts($root, $fromDate, $toDate) {
		
		//			and F_StartDateStamp>='$fromDate' // CONVERT(datetime, ?, 120)
		//			and F_StartDateStamp <= '$toDate'
		// TODO: No idea why I have to add CONVERT statements here when I use SQLServer on dock. Is it the db engine or odbtp?
		$sql = 	<<<EOD
				select F_ProductCode productCode, count(F_SessionID) sessionCount
					from T_Session
					where F_RootID = ?
					and F_StartDateStamp>=?
					and F_StartDateStamp<=?
					group by F_ProductCode
EOD;
		$rs = $this->db->GetArray($sql, array($root, $fromDate, $toDate));
		//$rs = $this->db->GetArray($sql, array($root));
		return $rs;
	}
	/* 
	 * v3.5 For usage stats used in DMS reports
	 */
	function getDMSUserCounts($root) {
		
		$sql = 	<<<EOD
				select u.F_UserType userType, count(u.F_UserID) users
					from T_User u, T_Membership m
					where m.F_RootID = ?
					and m.F_UserID = u.F_UserID
					group by u.F_UserType
					order by u.F_UserType
EOD;
		$rs = $this->db->GetArray($sql, array($root));
		return $rs;
	}
	/* 
	 * v3.5 For AA usage stats
	 * Note, used for ALL usage stats, not just AA
	 *
	 */
	private function getAASessionCounts($title, $fromDate, $toDate) {

        // m#269 Does this title need to pick up stats from older versions?
        // OK to only go back one version
        $oldProductCode = $this->licenceOps->getOldProductCode($title->id);

	    // sss#290
        if ($title->isTitleCouloir()) {
            $tableName = 'T_SessionTrack';
        } else {
            $tableName = 'T_Session';
        }

		// For HCT aggregated results, include all roots
		$rootID = Session::get('rootID');
		if ($rootID == 14292)
			$rootID = '14276,14277,14278,14279,14280,14281,14282,14283,14284,14285,14286,14287,14288,14289,14290,14291,14292';
		
		$fromDateStamp = $fromDate;
		$toDateStamp = $toDate;
		// Need a loop for each year covered by these dates
		$firstYear = intval(substr($fromDate, 0, 4));
		$lastYear = intval(substr($toDate, 0, 4));
		// Simple validity check
		if ($lastYear < $firstYear) {
			$switchYear = $firstYear;
			$firstYear = $lastYear;
			$lastYear = $switchYear;
		}
		if ($lastYear > intval(date('Y')))
			$lastYear = intval(date('Y'));

		$statsArray = array();
        // m#269 If there are two titles, do the old one first as it will have earliest months
        if ($oldProductCode && $title->isTitleCouloir()) {
            // Do the whole loop on T_Session for the old title
            $sql = $this->buildSQLForGetSessionCounts("T_Session", $firstYear, $lastYear, $rootID);
            $rs = $this->db->GetArray($sql, array($oldProductCode));
            foreach ($rs as $r) {
                if (!isset($statsArray[strval($r['year'])])) $statsArray[strval($r['year'])] = array();
                $statsArray[strval($r['year'])][] = array('sessionCount' => intval($r['sessionCount']), 'month' => strval($r['month']));
            }
        }

        $sql = $this->buildSQLForGetSessionCounts($tableName, $firstYear, $lastYear, $rootID);
        $rs = $this->db->GetArray($sql, array($title->id));
        foreach ($rs as $r) {
            if (!isset($statsArray[strval($r['year'])])) $statsArray[strval($r['year'])] = array();
            // Has this month already got anything in it?
            $monthMerged = false;
            foreach ($statsArray[strval($r['year'])] as &$m) {
                if ($m['month'] == $r['month']) {
                    $m['sessionCount'] += intval($r['sessionCount']);
                    $monthMerged = true;
                    break;
                }
            }
            if (!$monthMerged)
                $statsArray[strval($r['year'])][] = array('sessionCount' => intval($r['sessionCount']), 'month' => strval($r['month']));
        }

		return $statsArray;
	}
	// Clumsy way for Bento and Couloir session tables to be checked
    private function buildSQLForGetSessionCounts($tableName, $firstYear, $lastYear, $rootID) {
        $sql = <<<EOD
                select count(F_SessionID) as sessionCount, DATE_FORMAT(F_StartDateStamp,'%m') as month, DATE_FORMAT(F_StartDateStamp,'%Y') as year
                from $tableName
                where F_StartDateStamp >= '$firstYear-01-01'
                and F_StartDateStamp <= '$lastYear-12-31 23:59:59'
EOD;
        if (stristr($rootID, ',') !== FALSE) {
            $sql .= " AND F_RootID in ($rootID)";
        } else if ($rootID == '*') {
            // check all roots in that case - just for special cases, usually self-hosting
            // Note that leaving the root empty would include teachers
            $sql .= " AND F_RootID > 0";
        } else {
            $sql .= " AND F_RootID = $rootID";
        }

        // m#269 It is more than 2 years since we last launched a Bento upgrade, so can drop this now
        //if ($oldProductCode) {
        //	$sql.= " AND F_ProductCode IN (?, $oldProductCode)";
        //} else {
        $sql .= " AND F_ProductCode = ?";
        //}

        $sql .= <<<EOD
             group by year,month
             order by year,month
EOD;
        return $sql;
    }

	// Merge courseUserCounts and courseTimeCounts
	// private function getCourseUserCounts($title, $fromDate, $toDate) {
	private function getCourseCounts($title, $fromDate, $toDate) {
		// v3.6 I can't see why I don't do this based on productCode rather than courseID
		$courseIdArray = $title->getCourseIDs();
		//$courseIdInString = join(",", $courseIdArray);
		
		/*
		// AR Now that the database contains F_Duration for all session records we can simplify this call
		// In fact, this call can surely now be done in one with course user counts. Then I would just get one dataProvider
		// for the two different charts. (Great for the data grid!)
		*/
		// Ticket #95 - dates passed are now ANSI strings so no conversion is necessary
		//$fromDateWrapper = new DateWrapper($fromDate);
		//$toDateWrapper = new DateWrapper($toDate);

		$fromDateStamp = $fromDate;
		$toDateStamp = $toDate;
		// v3.0.5 Block admin and teachers from usage statistics
		// v3.3 MySQL conversion. This works, but seems a touch slow.
		// It also works on CE.com SQLServer, but NOT on claritymain. (As DK always said was the case)
		// If I run this on claritymain, I can then drop CONVERT too
		// set dateformat ymd, but this is connection dependent, but maybe that is no bad thing
		// Can I throw it into AbstractService? Yes, but it now suddenly seems unnecessary.
		// I was trying to run sp_addlanguage, and it seemed to be failing, but maybe it actually succeeded.
		// AND ss.F_StartDateStamp >= '$fromDateStamp'		
		//		AND ss.F_StartDateStamp >= CONVERT(datetime, '$fromDateStamp', 120)
		//		AND ss.F_StartDateStamp <= CONVERT(datetime, '$toDateStamp', 120)
		// v3.6 I can't see why I don't do this based on productCode rather than courseID
		//		WHERE ss.F_CourseID IN ($courseIdInString)
		// v3.6 And, as with licence counting, you are tying this to users still in the database.
		// In this case, I don't think it matters to include teachers, does it?
		//		FROM T_Session ss, T_User u
		//		AND ss.F_UserID = u.F_UserID
		//		AND u.F_UserType=0
		// v3.7 For Bento titles, courseID is NOT part of session, so you have to join session and score, sadly
		// v3.7 we changed ss.F_Duration to sc.F_Duration for it lead the numbers of one exercises mutiply ss.F_Duration
        $titleId = intval($title->productCode);
        // sss#290 Couloir titles use T_SessionTrack
        if ($title->isTitleCouloir()) {
            $sessionTableName = 'T_SessionTrack';
        } else {
            $sessionTableName = 'T_Session';
        }
        if ($titleId > 50) {
			$sql = 	<<<EOD
				SELECT sc.F_CourseID courseID, COUNT(sc.F_SessionID) courseCount, SUM(sc.F_Duration) duration
				FROM $sessionTableName ss, T_Score sc
				WHERE ss.F_ProductCode= ?
				AND ss.F_RootID = ?
				AND ss.F_SessionID = sc.F_SessionID
				AND ss.F_StartDateStamp >= ?
				AND ss.F_StartDateStamp <= ?
				GROUP BY sc.F_CourseID;
EOD;
		} else {
			$sql = 	<<<EOD
				SELECT F_CourseID courseID, COUNT(ss.F_SessionID) courseCount, SUM(ss.F_Duration) duration
				FROM $sessionTableName ss
				WHERE ss.F_ProductCode=?
				AND ss.F_RootID = ?
				AND ss.F_StartDateStamp >= ?
				AND ss.F_StartDateStamp <= ?
				GROUP BY ss.F_CourseID
EOD;
		}
		$bindingParams = array($titleId, Session::get('rootID'), $fromDateStamp, $toDateStamp);
		//NetDebug::trace("USAGE: sql=".$sql);		
		//NetDebug::trace("bindings=".implode(",",$bindingParams));		
		// Unfortunately date bindings don't seem to work so they are directly embedded in the SQL string
		//$rs = $this->db->GetArray($sql, array($_SESSION['rootID'], $this->db->BindDate("$fromDateStamp"), $this->db->BindDate("$toDateStamp")));
		//$rs = $this->db->GetArray($sql, array(Session::get('rootID')));
		$rs = $this->db->GetArray($sql, $bindingParams);

		// v3.7 If you have a title with just one course (SSS) then it would be nice to get units at this point
		/*
		if (count($rs) == 1) {
			$courseID = $rs[0]['courseID'];
			$sql = 	<<<EOD
				SELECT sc.F_UnitID courseID, COUNT(ss.F_SessionID) courseCount, SUM(ss.F_Duration) duration
				FROM T_Session ss, T_Score sc
				WHERE ss.F_ProductCode=?
				AND sc.F_CourseID = $courseID
				AND ss.F_RootID = ?
				AND ss.F_StartDateStamp >= ?
				AND ss.F_StartDateStamp <= ?
				AND ss.F_SessionID = sc.F_SessionID
				GROUP BY sc.F_UnitID
EOD;
			$rs = $this->db->GetArray($sql, $bindingParams);
			$returnArray = array(courseCounts => $rs);
		} else {
		*/
			// If you have a product that has different courseIDs for different language versions, then here you get double.
			// It would be nice to consolidate them based on name. But of very small interest I suppose. And of course I don't know the names
			// of courseIDs from the db. But I suppose I could just count those that are NOT in the current courseIDs?
			$otherCount=0;

		$otherDuration=0;
        $currentRS = array();
			foreach ($rs as $record) {
				// Is this SQL record listed in the current title?
				if (in_array($record['courseID'], $courseIdArray)) {
					// add this count and duration to the return set
					$currentRS[] = $record;
				} else {
					$otherCount+=$record['courseCount'];
					$otherDuration+=$record['duration'];
				}
			}
			$returnArray = array("courseCounts" => $currentRS);
		//}
		if ($otherCount>0)
			//$currentRS[] = array(courseID=>0,userCount=>$otherCount,duration=>$otherDuration);
			$returnArray['otherCourseCounts'] = array("courseID" => 0, "courseCount" => $otherCount, "duration" => $otherDuration);
		
		return $returnArray;
	}
	
	/* Moved to LicenceOps or deprecated */
	/*
	//private function getTitleUserCounts($title, $rootID) {
	private function xxgetTitleUserCounts($title, $rootID, $fromDateStamp = null) {
		// AR We want special processing for counting licences in perpetual licences, basically a rolling 1 year.
		// So test to see if perpetual (any date>=2049). The $title dates are in m/d/y format. Why? I think this will change 
		// Note that you can't do strtotime for dates after 19 Jan 2038 as this is greatest range of integer
		// So well have to do it manually
		// v3.6.5 Add licence clearance date.
		if (!$fromDateStamp)
			$fromDateStamp = $this->getLicenceClearanceDate($title);
		$fromDate = strftime('%Y-%m-%d 00:00:00',$fromDateStamp);
		//echo strftime('%d %B, %Y',$fromDateStamp);
		
		//*
		$myYearBit = explode(" ", $title->expiryDate);
		//$brokenDate = explode("/", $myYearBit[0]);
		$brokenDate = explode("-", $myYearBit[0]);
		//NetDebug::trace("UsageOps expiryDate=".date('Y-m-d', strtotime($title-> expiryDate)));
		//if ($brokenDate[2] >= '2049') {
		//if ($brokenDate[0] >= '2049') {
		if ($brokenDate[0] >= '2037') {
			// if it is, then licence start date is 1 year ago today (ignore time)
			//$fromDateStamp = date('m/d/Y', strtotime("-1 year"));
			$fromDateStamp = date('Y-m-d', strtotime("-1 year"));
		} else {
			$fromDateStamp = $title->licenceStartDate;
		}
		//* /
		//NetDebug::trace("UsageOps.getTitleUserCounts.fromDateStamp=".$fromDateStamp." expiryDate=".$title->expiryDate." productCode=".$title->productCode." root=".Session::get('rootID'));
		//		AND l.F_StartTime >= '$fromDateStamp'	
		// v6.5.5.0 There will be no T_Licences table anymore, just get everything from T_Session
		//		SELECT COUNT(DISTINCT l.F_UserID) as titleUserCount 
		//		FROM T_Licences l, T_User u 
		//		WHERE l.F_ProductCode = ? 
		//		AND l.F_UserID = u.F_UserID 
		//		AND u.F_UserType=0 
		//		AND l.F_RootID = ? 
		//		AND l.F_StartTime >= CONVERT(datetime, '$fromDateStamp', 120)
		// v3.3 MySQL conversion
		//AND s.F_StartDateStamp>CONVERT(datetime,'$fromDateStamp',120)
		// v3.6 No. This does not work because you are tying session records (which are never deleted) to user records (which are). 
		// So all orphaned session records are not counted. This is wrong, they should be. But equally, I don't want to count known teachers.
		// So if the user record exists and is > student, or the record doesn't exist I should count it.
		// But I do also have session records with no score, and I suppose I shouldn't count those...
		// (joining to T_Score is very query intensive - and to be realistic I suppose we should only count those who 
		//	use at least x minutes - which means adding up score durations...)
		// One option would be to add up session durations, and ignore those that are less than x minutes...
		// or better (from a SQL point of view) is to only include sessions that link to a score.
		// Remember that I won't be able to do that for deleted users as scores are deleted as well.
		//	AND EXISTS (SELECT * FROM T_Score c WHERE c.F_SessionID=s.F_SessionID)
		// Even for root 13964 which had a problem in that they deleted loads of users early on in the licence, still 
		// there was only 1 of 230 which had a session but no scores.
		// Break this down into a couple of calls then to keep it simple. 
		// First is students who are still in T_User
		//v6.6.0 T_Session is now the only count for licence use. See dbLicence checkAvailableLicences
		//*
		// This is code from Orchid
		if ($vars['LICENCETYPE']=='6') {
			$sql = <<<EOD
				SELECT COUNT(DISTINCT(c.F_UserID)) AS licencesUsed 
				FROM T_Session c, T_User u
				WHERE c.F_ProductCode = ?
				AND c.F_UserID = u.F_UserID
				AND c.F_EndDateStamp >= ?
EOD;
		} else {
		// v6.6.0 BUT do confirm that teachers don't write session records. If they do, we need to exclude them by joining on T_User.F_UserType=0
			$sql = <<<EOD
				SELECT COUNT(DISTINCT(F_UserID)) AS licencesUsed 
				FROM T_Session
				WHERE F_ProductCode = ?
				AND F_EndDateStamp >= ?
EOD;
		}
		//* /
		$sql = 	<<<EOD
			SELECT COUNT(DISTINCT s.F_UserID) AS activeStudentCount
			FROM T_Session s, T_User u
			WHERE s.F_ProductCode=?
			AND s.F_RootID=?
			AND s.F_UserID = u.F_UserID
			AND u.F_UserType=0
			AND s.F_StartDateStamp>'$fromDate'
			AND EXISTS (SELECT * FROM T_Score c WHERE c.F_SessionID=s.F_SessionID)
EOD;
		//NetDebug::trace("UsageOps active ".$sql);
		//NetDebug::trace("UsageOps $rootID ".$title->productCode." $fromDateStamp");
		// v3.4 Now you pass rootID in case you are working in DMS mode
		//$rs = $this->db->GetRow($sql, array($title->productCode, Session::get('rootID')));
		$rs = $this->db->GetRow($sql, array($title->productCode, $rootID));
		//NetDebug::trace("UsageOps.sql.active.rs=".$rs['activeStudentCount']);
		
		// v3.6 The new 'transfer' licence will ONLY count active students so you can get back a licence
		// that you have already used by deleting the student from RM
		if ($title->licenceType == 6) {
			$deletedCount=0;
		} else {
			// Then any type of user who has a session, but deleted from T_User
			$sql = 	<<<EOD
					SELECT COUNT(DISTINCT s.F_UserID) AS allDeletedCount
					FROM T_Session s
					left join T_User u
					on s.F_UserID = u.F_UserID
					WHERE s.F_ProductCode=?
					AND s.F_RootID=?
					AND s.F_StartDateStamp>'$fromDate'
					AND u.F_UserID IS NULL
					AND s.F_UserID > 0
EOD;
			//NetDebug::trace("UsageOps deleted ".$sql);
			//$rs2 = $this->db->GetRow($sql, array($title->productCode, Session::get('rootID')));
			$rs2 = $this->db->GetRow($sql, array($title->productCode, $rootID));
			//NetDebug::trace("UsageOps.sql.deleted.rs=".$rs2['allDeletedCount']);
			$deletedCount = $rs2['allDeletedCount'];
		}

		return $rs['activeStudentCount'] + $deletedCount;
	}
	// AR This is used in EarlyWarningSystem. It is much quicker, though a little rough
	//private function getTitleUserCountsApprox($title, $rootID) {
	private function getTitleUserCountsApprox($title, $rootID, $fromDateStamp=null) {
		//*
		$myYearBit = explode(" ", $title->expiryDate);
		$brokenDate = explode("-", $myYearBit[0]);
		if ($brokenDate[0] >= '2037') {
			$fromDateStamp = date('Y-m-d', strtotime("-1 year"));
		} else {
			$fromDateStamp = $title->licenceStartDate;
		}
		* /
		if (!$fromDateStamp)
			$fromDateStamp = $this->getLicenceClearanceDate($title);
		$fromDate = strftime('%Y-%m-%d 00:00:00',$fromDateStamp);

		$sql = 	<<<EOD
			SELECT COUNT(DISTINCT s.F_UserID) AS activeStudentCount
			FROM T_Session s, T_User u
			WHERE s.F_ProductCode=?
			AND s.F_RootID=?
			AND s.F_UserID = u.F_UserID
			AND u.F_UserType=0
			AND s.F_StartDateStamp>'$fromDate'
EOD;
		$rs = $this->db->GetRow($sql, array($title->productCode, $rootID));
		
		$sql = 	<<<EOD
				SELECT COUNT(DISTINCT s.F_UserID) AS allDeletedCount
				FROM T_Session s
				left join T_User u
				on s.F_UserID = u.F_UserID
				WHERE s.F_ProductCode=?
				AND s.F_RootID=?
				AND s.F_StartDateStamp>'$fromDate'
				AND u.F_UserID IS NULL
				AND s.F_UserID > 0
EOD;
		$rs2 = $this->db->GetRow($sql, array($title-> productCode, $rootID));
		$deletedCount = $rs2['allDeletedCount'];

		return $rs['activeStudentCount'] + $deletedCount;
	}
	*/
	
	private function getFailedLoginCounts($title, $rootID, $fromDate, $toDate) {
		//$fromDateWrapper = new DateWrapper($fromDate);
		//$toDateWrapper = new DateWrapper($toDate);
		
		//$fromDateStamp = $this->db->DBTimeStamp($fromDateWrapper->getRawDate());
		//$toDateStamp = $this->db->DBTimeStamp($toDateWrapper->getRawDate());
		
		// Ticket #95 - dates passed are now ANSI strings so no conversion is necessary
		$fromDateStamp = $fromDate;
		$toDateStamp = $toDate;
		
		// AR We would like to also know why they failed. So count by reasonCode
		//		AND F_StartTime >= '$fromDateStamp'
		//		AND F_StartTime <= '$toDateStamp'
		// v3.3 MySQL conversion
		//		AND F_StartTime >= CONVERT(datetime, '$fromDateStamp', 120)
		//		AND F_StartTime <= CONVERT(datetime, '$toDateStamp', 120)
		
		// v6.6 Very nasty, but only display the 'good' failures!
		$sql = 	<<<EOD
				SELECT COUNT(*) failedLogins, F_ReasonCode
				FROM T_Failsession
				WHERE F_RootID = ?
				AND F_StartTime >= '$fromDateStamp'
				AND F_StartTime <= '$toDateStamp'
				AND F_ReasonCode in (203,204,207,208,301,211,303,212,304,209,210,213,311,312,313,220)
EOD;
		// gh#1211 And the other old and new combinations
		$oldProductCode = $this->licenceOps->getOldProductCode($title->id);
		if ($oldProductCode) {
			$sql.= " AND F_ProductCode IN (?, $oldProductCode)";
		} else {
			$sql.= " AND F_ProductCode = ?";
		}			
						
		$sql.= " GROUP BY F_ReasonCode";
		
		// Not just one row, but a table now
		//$rs = $this->db->GetRow($sql, array($title->productCode, $_SESSION['rootID']));
		//$rs = $this->db->GetArray($sql, array($title->productCode, Session::get('rootID')));
		$rs = $this->db->GetArray($sql, array($rootID, $title->id));
		//echo $sql;
		//NetDebug::trace("UsageOps.failLogins.sql.rs=".$rs['failedLogins']);
		//return $rs['failedLogins'];
		return $rs;
	}
	
	private function getOverLastYear($title, $fromDate, $toDate) {

        // m#269 Does this title need to pick up stats from older versions?
        // OK to only go back one version
        $oldProductCode = $this->licenceOps->getOldProductCode($title->id);
        $rootID = Session::get('rootID');

        $fromDateStamp = $fromDate;
		$toDateStamp = $toDate;
        // sss#290
        if ($title->isTitleCouloir()) {
            $tableName = 'T_SessionTrack';
        } else {
            $tableName = 'T_Session';
        }

        $totalCourse = $totalDuration = 0;
        // m#269 If there are two titles, do the old one first
        if ($oldProductCode && $title->isTitleCouloir()) {
            // Do the whole loop on T_Session for the old title
            $sql = $this->buildSQLForGetOverLastYear("T_Session", $fromDateStamp, $toDateStamp, $rootID);
            $rs = $this->db->GetArray($sql, array($oldProductCode));
            if ($rs) {
                $totalCourse = $rs[0]['totalCourse'];
                $totalDuration = $rs[0]['totalDuration'];
            }
        }

        $sql = $this->buildSQLForGetOverLastYear($tableName, $fromDateStamp, $toDateStamp, $rootID);
        $rs = $this->db->GetArray($sql, array($title->id));
        if ($rs) {
            $totalCourse += $rs[0]['totalCourse'];
            $totalDuration += $rs[0]['totalDuration'];
        }

		return array(array('totalCourse' => $totalCourse, 'totalDuration' => $totalDuration));
	}
    // m#269 Clumsy way for Bento and Couloir session tables to be checked
    private function buildSQLForGetOverLastYear($tableName, $fromDateStamp, $toDateStamp, $rootID) {
        $secondsLimit = 10800; // 3 hours
        // This is simply different dates that getCourseCounts total...
        $sql = <<<EOD
            SELECT COUNT(ss.F_SessionID) as totalCourse,
                SUM(CASE WHEN ss.F_Duration>$secondsLimit THEN $secondsLimit ELSE ss.F_Duration END) as totalDuration
            FROM $tableName ss
            WHERE ss.F_StartDateStamp >= '$fromDateStamp'
            AND ss.F_StartDateStamp <= '$toDateStamp'
            AND ss.F_RootID = $rootID
            AND ss.F_ProductCode = ?
EOD;
        return $sql;
    }

    /**
	 * This function reads progress records to work out the learner's coverage of an array of reportables
	 */
	public function getCoverage($reportables, $startDate=0, $endDate=0, $userID, $singleStyle=null) {
		//NetDebug::trace("UsageOps.getCoverage singleStyle=".$singleStyle);	
		// We have to have a different style of getting coverage from SQL as AP exercises record differently than EMU exercises.
		// So split based on productCode>1000 for EMUs.
		$emuIDs = array();
		$authorPlusIDs = array();
		foreach ($reportables as $productCode) {
			if ($productCode > 1000) {
				$emuIDs[] = $productCode;
			} else {
				$authorPlusIDs[] = $productCode;
			}
		}
		$emuList = implode(",", $emuIDs);
		$authorPlusList = implode(",", $authorPlusIDs);
		//NetDebug::trace("UsageOps.userID=$userID emuList=$emuList");
		
		// In order to have just one function, allow just one call to be made at a time
		if ((strtolower($singleStyle=="emu") || $singleStyle==null) && $userID>0) {
			
			// EMU progress records have the itemID then the number of unique score_corrects (equivalent to pages or cuepoints) then the total that you could have got
			// Note that avg is ridiculous for adding up score correct and missed. What I really want is LATEST, but that is not available.
			// Send back a zero unitID for consistency with AP records. No, not useful.
			$sql = 	<<<EOD
					SELECT c.F_ExerciseID id, count(distinct c.F_ScoreCorrect) completed, round(avg(c.F_ScoreCorrect+c.F_ScoreMissed),0) total
					FROM T_Session s, T_Score c
					WHERE s.F_ProductCode IN ($emuList)
					AND s.F_UserID = ?
					and s.F_SessionID = c.F_SessionID
					GROUP BY c.F_ExerciseID
					ORDER BY c.F_ExerciseID
EOD;
			//NetDebug::trace("UsageOps.EMUcoverage productCode IN ".$emuList);
			//$emurs = $this->db->GetArray($sql, array(Session::get('userID')));
			$emurs = $this->db->GetArray($sql, $userID);
		} else {
			$emurs = array();
		}
		if ((strtolower($singleStyle)=="authorplus" || $singleStyle==null) && $userID>0) {
		
			// AP progress records have the itemID then the number of times this exercise has been done (which is irrelevant really)
			// We do not know the total from progress, can only get it from the menu.xml. But we might need the unit ID of the exercise. No, not useful.
			// Since we don't care about number of times you have done an exercise, lets just return 1 if you have done it at least once.
			//		SELECT c.F_ExerciseID id, count(c.F_ExerciseID) completed, 0 total, max(c.F_UnitID) unitID 
			$sql = 	<<<EOD
					SELECT c.F_ExerciseID id, 1 completed, 1 total
					FROM T_Session s, T_Score c
					WHERE s.F_ProductCode IN ($authorPlusList)
					AND s.F_UserID = ?
					and s.F_SessionID = c.F_SessionID
					GROUP BY c.F_ExerciseID
					ORDER BY c.F_ExerciseID
EOD;
			//NetDebug::trace("UsageOps.APcoverage productCode IN ".$authorPlusList);
			$authorplusrs = $this->db->GetArray($sql, $userID);
		} else {
			$authorplusrs = array();
		}		
		//$dummyRow = array(array( id=>'123456', completed=>6, total=>8 ));
		//return array_merge($dummyRow, $emurs, $authorplusrs);
		return array_merge($emurs, $authorplusrs);
	}
	// The same thing, but for everyone (in a particular country)
	public function getEveryonesCoverage($reportables, $startDate = 0, $endDate = 0, $userID, $rootID = null, $country = 'worldwide') {
		// We have to have a different style of getting coverage from SQL as AP exercises record differently than EMU exercises.
		// So split based on productCode>1000 for EMUs.
		//NetDebug::trace("UsageOps.EveryonesCoverage userID=".$userID." startDate=".$startDate." endDate=".$endDate." country=".$country);
		$emuIDs = array();
		$authorPlusIDs = array();
		foreach ($reportables as $productCode) {
			if ($productCode > 1000) {
				$emuIDs[] = $productCode;
			} else {
				$authorPlusIDs[] = $productCode;
			}
			//$fullIDs[] = $productCode;
		}
		$emuList = join(",", $emuIDs);
		$authorPlusList = join(",", $authorPlusIDs);
		//$fullList = join(",", $fullIDs);
		
		// In order to have just one function, allow just one call to be made at a time
		if ((strtolower($singleStyle=="emu") || $singleStyle==null) && $userID>0) {
			
			// EMU progress records have the itemID then the number of unique score_corrects (equivalent to pages or cuepoints) then the total that you could have got.
			// If the video or eBook never changes length or segements, this data will never change. 
			// What we are getting here is 
			//		completed=number of pages done by people who have done at least 1
			//		total=total number of pages that these people could have done
			// We also need to know how many people there are in total. That has to be a separate call.
			// v3.2 Bad coding as the Common Table Expression is not standard SQL. Just works in SQLServer.
			// So either need to work this with a view - or more likely split into an SQL call and some local processing.
			// What are we trying to get here?
			// First the SQL gets all the unique items each user has done, with a completed and total score
			// Then I find each itemID and add up the completed and totals.
			// This shouldn't be too difficult to do in PHP. 
			// The removal of users in different countries could be done in the main SQL
			/*
			$bindingParams = array($userID);
			$sql = <<<EOD
			WITH SummarisedCTE (userID, itemID, completed, total) AS
				(SELECT s.F_userID userID, c.F_ExerciseID itemID, 
						count(distinct c.F_ScoreCorrect) completed, 
						max(c.F_ScoreCorrect+c.F_ScoreMissed) total 
				FROM T_Score c, T_Session s 
				WHERE s.F_ProductCode IN ($emuList)	
				AND s.F_UserID != ? 
				AND s.F_SessionID = c.F_SessionID
EOD;
			if ($startDate > 0) {
				// v3.3 MySQL conversion
				//$sql .= " AND s.F_StartDateStamp >= convert(datetime, ?, 120)";
				$sql .= " AND s.F_StartDateStamp >= ?";
				//NetDebug::trace("UsageOps.EMUEveryonecoverage startDate=".$startDate);
				$bindingParams[] = $startDate;
			}
			$sql .= <<<EOD
				GROUP BY s.F_UserID, c.F_ExerciseID)
			SELECT itemID id, sum(completed) completed, sum(total) total
			FROM SummarisedCTE
EOD;
			if (strtolower($country) != "worldwide" && $country != "") {
				$sql .= <<<EOD
					s, T_User u
					WHERE s.userID = u.F_UserID
					AND u.F_Country = ?
EOD;
				$bindingParams[] = $country;
			}
			$sql .= <<<EOD
			GROUP BY itemID
			ORDER BY itemID
EOD;
			//NetDebug::trace("UsageOps.EMUEveryonecoverage=".$sql);
			//$emurs = $this->db->GetArray($sql, $userID, $startDate, $endDate);
			$emurs = $this->db->GetArray($sql, $bindingParams);
			*/
			// Do the simple SQL first
			$bindingParams = array($userID);
			if (strtolower($country) != "worldwide" && $country != "") {
				$sql = <<<EOD
					SELECT s.F_userID userID, c.F_ExerciseID itemID, 
							count(distinct c.F_ScoreCorrect) completed, 
							max(c.F_ScoreCorrect+c.F_ScoreMissed) total 
					FROM T_Score c, T_Session s, T_User u
					WHERE s.F_ProductCode IN ($emuList)	
					AND s.F_UserID != ? 
					AND s.F_UserID = u.F_UserID
					AND u.F_Country=?
					AND s.F_SessionID = c.F_SessionID
EOD;
				$bindingParams[] = $country;
			} else {
				$sql = <<<EOD
					SELECT s.F_userID userID, c.F_ExerciseID itemID, 
							count(distinct c.F_ScoreCorrect) completed, 
							max(c.F_ScoreCorrect+c.F_ScoreMissed) total 
					FROM T_Score c, T_Session s 
					WHERE s.F_ProductCode IN ($emuList)	
					AND s.F_UserID != ? 
					AND s.F_SessionID = c.F_SessionID
EOD;
			}
			if ($startDate > 0) {
				// v3.3 MySQL conversion
				//$sql .= " AND s.F_StartDateStamp >= convert(datetime, ?, 120)";
				$sql .= " AND s.F_StartDateStamp >= ?";
				//NetDebug::trace("UsageOps.EMUEveryonecoverage startDate=".$startDate);
				$bindingParams[] = $startDate;
			}
			$sql .= <<<EOD
				GROUP BY s.F_UserID, c.F_ExerciseID
				ORDER BY c.F_ExerciseID
EOD;
			//NetDebug::trace("UsageOps.NewEMUEveryonecoverage=".$sql);
			//$emurs = $this->db->GetArray($sql, $userID, $startDate, $endDate);
			$workingrs = $this->db->GetArray($sql, $bindingParams);
			//NetDebug::trace("records=".count($workingrs));
			$emurs = array();
			// Now we need to add up the completed and total for each itemID
			$thisItemID = "";
			$thisItem = array();
			foreach ($workingrs as $record) {
				// is this record for a new itemID?
				if ($thisItemID != $record['itemID']) {
					if ($thisItemID != "") {
						//NetDebug::trace("write out ".$thisItem['itemID'].".completed".$thisItem['completed'].".total".$thisItem['total']);
						array_push($emurs, $thisItem);
						$thisItem = array();
					}
					$thisItem['id'] = $record['itemID'];
					$thisItemID = $record['itemID'];
				}
				$thisItem['completed']+= $record['completed'];
				$thisItem['total']+= $record['total'];
			}
			
		} else {
			$emurs = array();
		}
		if ((strtolower($singleStyle)=="authorplus" || $singleStyle==null) && $userID>0) {
		
			// AP progress records have the itemID then the number of times this exercise has been done (which is irrelevant really)
			// We do not know the total from progress, can only get it from the menu.xml. But we might need the unit ID of the exercise. No, not useful.
			// Since we don't care about number of times you have done an exercise, we just return 1 if you have done it at least once.
			//		SELECT c.F_ExerciseID id, count(c.F_ExerciseID) completed, 0 total, max(c.F_UnitID) unitID 
			// See above regarding WITH CTE
			$bindingParams = array($userID);
			/*
			$sql = <<<EOD
			WITH SummarisedCTE (userID, itemID, completed, total) AS
				(SELECT s.F_userID userID, c.F_ExerciseID itemID, 
						1 completed, 
						1 total
				FROM T_Score c, T_Session s
				WHERE s.F_ProductCode IN ($authorPlusList)			
				AND s.F_UserID != ?
				AND s.F_SessionID = c.F_SessionID
EOD;
			if ($startDate > 0) {
				//$sql .= " AND s.F_StartDateStamp >= convert(datetime, ?, 120)";
				$sql .= " AND s.F_StartDateStamp >= ?";
				//NetDebug::trace("UsageOps.EMUEveryonecoverage startDate=".$startDate);
				$bindingParams[] = $startDate;
			}
			$sql .= <<<EOD
				GROUP BY s.F_UserID, c.F_ExerciseID)
			SELECT itemID id, sum(completed) completed, sum(total) total
			FROM SummarisedCTE
EOD;
			if (strtolower($country) != "worldwide" && $country != "") {
				$sql .= <<<EOD
					s, T_User u
					WHERE s.userID = u.F_UserID
					AND u.F_Country = ?
EOD;
				$bindingParams[] = $country;
			}
			$sql .= <<<EOD
			GROUP BY itemID
			ORDER BY itemID
EOD;
			*/
			if (strtolower($country) != "worldwide" && $country != "") {
				$sql = <<<EOD
					SELECT s.F_userID userID, c.F_ExerciseID itemID, 
							1 completed, 
							1 total
					FROM T_Score c, T_Session s, T_User u
					WHERE s.F_ProductCode IN ($authorPlusList)			
					AND s.F_UserID != ?
					AND s.F_UserID = u.F_UserID
					AND u.F_Country=?
					AND s.F_SessionID = c.F_SessionID
EOD;
				$bindingParams[] = $country;
			} else {
				$sql = <<<EOD
					SELECT s.F_userID userID, c.F_ExerciseID itemID, 
							1 completed, 
							1 total
					FROM T_Score c, T_Session s
					WHERE s.F_ProductCode IN ($authorPlusList)			
					AND s.F_UserID != ?
					AND s.F_SessionID = c.F_SessionID
EOD;
			}
			if ($startDate > 0) {
				$sql .= " AND s.F_StartDateStamp >= ?";
				$bindingParams[] = $startDate;
			}
			$sql .= <<<EOD
				GROUP BY s.F_UserID, c.F_ExerciseID
				ORDER BY c.F_ExerciseID
EOD;

			//NetDebug::trace("UsageOps.APEveryonecoverage=".$sql);
			$workingrs = $this->db->GetArray($sql, $bindingParams);
			//NetDebug::trace("records=".count($workingrs));
			$authorplusrs = array();
			// Now we need to add up the completed and total for each itemID
			$thisItemID = "";
			$thisItem = array();
			foreach ($workingrs as $record) {
				// is this record for a new itemID?
				if ($thisItemID != $record['itemID']) {
					if ($thisItemID != "") {
						//NetDebug::trace("write out ".$thisItem['itemID'].".completed".$thisItem['completed'].".total".$thisItem['total']);
						array_push($authorplusrs, $thisItem);
						$thisItem = array();
					}
					$thisItem['id'] = $record['itemID'];
					$thisItemID = $record['itemID'];
				}
				$thisItem['completed']+= $record['completed'];
				$thisItem['total']+= $record['total'];
			}			
		} else {
			$authorplusrs = array();
		}
		// We finally need to know the number of 'everyone', and clearly this should be a separate call
		// This will not work as our current decision is that with an EMU, you just have one session record, not one per course.
		// So we will put the titleID into the F_CourseID field. But our averaging does need to know the number of people who have
		// done something in each course. So we need to read that there is at least one score record related to a course.
		// But how to do that? I think we'll have to add F_CourseID to T_Score. In the end, it would make sense for session to
		// include all courses anyway - this would allow MyCanada and Author Plus to show progress across all courses which is much
		// more sensible. Note that if someone has only done the AP exercises in a course, this will not count them.
		/*
					SELECT count(distinct u.F_UserID) users, s.F_courseID id
					FROM T_Session s, T_User u
					where s.F_ProductCode IN ($fullList)
					and u.F_UserID = s.F_UserID
					and u.F_UserID != ?
					GROUP BY s.F_CourseID
		*/
		$bindingParams = array($userID);
		//
		// This call if you need to filter by country
		// v3.2 Remove CTE as non-standard SQL
		// (Also remove country option from network version - but protect this just in case)
		if (strtolower($country) != "worldwide" && $country != "") {
			$sql = <<<EOD
				SELECT count(distinct s.F_UserID) users, c.F_CourseID id
				FROM T_Session s, T_Score c, T_User u
				WHERE s.F_ProductCode IN ($emuList) 
				AND s.F_UserID != ? 
				AND u.F_UserID = s.F_UserID 
				AND u.F_Country=?
				AND s.F_SessionID = c.F_SessionID 
				AND c.F_CourseID is not null 
EOD;
			$bindingParams[] = $country;
			if ($startDate > 0) {
				// v3.3 MySQL conversion
				$sql.= "AND s.F_StartDateStamp >= ?";
				$bindingParams[] = $startDate;
			}
			$sql.= <<<EOD
				GROUP BY c.F_CourseID 
EOD;
		} else {
		// This call for all countries
			$sql = <<<EOD
				SELECT count(distinct s.F_UserID) users, c.F_CourseID id 
				FROM T_Session s, T_Score c 
				WHERE s.F_ProductCode IN ($emuList) 
				AND s.F_UserID != ? 
				AND s.F_SessionID = c.F_SessionID 
				AND c.F_CourseID is not null 
EOD;
			if ($startDate > 0) {
				// v3.3 MySQL conversion
				//$sql.= "AND s.F_StartDateStamp >= convert(datetime, ?, 120)";
				$sql.= "AND s.F_StartDateStamp >= ? ";
				$bindingParams[] = $startDate;
			}
			$sql .= <<<EOD
			GROUP BY c.F_CourseID 
EOD;
		}
		//NetDebug::trace("UsageOps.EveryoneNumbers=".$sql." with ".implode(", ",$bindingParams));
		$overallrs = $this->db->GetArray($sql, $bindingParams);
		// Add this as the first records in the return array. Yikes, that is so clumsy.
		return array_merge($overallrs, $emurs, $authorplusrs);
	}

	// AR no longer used
	/*
	private function getCourseTimeCounts($title, $fromDate, $toDate) {
		$courseIdArray = $title->getCourseIDs();
		$courseIdInString = join(",", $courseIdArray);
		
		//$fromDateWrapper = new DateWrapper($fromDate);
		//$toDateWrapper = new DateWrapper($toDate);
		
		//$fromDateStamp = $this->db->DBTimeStamp($fromDateWrapper->getRawDate());
		//$toDateStamp = $this->db->DBTimeStamp($toDateWrapper->getRawDate());
		
		// Ticket #95 - dates passed are now ANSI strings so no conversion is necessary
		$fromDateStamp = $fromDate;
		$toDateStamp = $toDate;
		
		// AR Now that the database contains F_Duration for all session records we can simplify this call
		// In fact, this call can surely now be done in one with course user counts. Then I would just get one dataProvider
		// for the two different charts. (great for the data grid!)
		// SELECT F_CourseID courseID, COUNT(ss.F_UserID) userCount, SUM(ss.F_Duration) duration
		//
		$sql = 	<<<EOD
				SELECT ss.F_CourseID courseID, SUM(s.F_Duration) duration
				FROM T_Session ss, T_Score s
				WHERE ss.F_SessionID = s.F_SessionID
				AND ss.F_CourseID IN ($courseIdInString)
				AND ss.F_RootID = ?
				AND ss.F_StartDateStamp >= $fromDateStamp
				AND ss.F_StartDateStamp <= $toDateStamp
				GROUP BY ss.F_CourseID
EOD;
		// AR the $fromDateStamp is in the format YYYY-MM-DD. I can only run that directly on SQL using CONVERT(datetime, $fromDateStamp, 120)
		// but doing it like this seems to work. I suppose adodb is handling this for me.
		$sql = 	<<<EOD
				SELECT ss.F_CourseID courseID, SUM(ss.F_Duration) duration 
				FROM T_Session ss 
				WHERE ss.F_CourseID IN ($courseIdInString) 
				AND ss.F_RootID = ? 
				AND ss.F_StartDateStamp >= CONVERT(datetime, '$fromDateStamp', 120)
				AND ss.F_StartDateStamp <= CONVERT(datetime, '$toDateStamp', 120)
				GROUP BY ss.F_CourseID
EOD;
		//NetDebug::trace("courseTimeCounts sql=".$sql);
		// Unfortunately date bindings don't seem to work so they are directly embedded in the SQL string
		$rs = $this->db->GetArray($sql, array(Session::get('rootID')));
		
		return $rs;
	}
	*/
	
	/*
	 * These functions are used by triggers for monthly usage reports
	 */
	public function insertDirectStartRecord($account) {
		// gh#733
		if (!$account->adminUser)
			throw new Exception('account root='.$account->id.' has no admin user');
			
		// If we don't want to change the security code every month, then we should just insert once.
		// After RM expires you won't be able to get in anyway.
		$directStartInfo = array();
		$directStartInfo['F_SecureString'] = md5(strval(microtime().rand()));
		$directStartInfo['F_RootID'] = $account->id;
		$directStartInfo['F_Email'] = $account->adminUser->email;
		$directStartInfo['F_UserName'] = $account->adminUser->name;
		$directStartInfo['F_Password'] = $account->adminUser->password;
		$directStartInfo['F_UserID'] = $account->getAdminUserID();
		// Currently this is not null, so just write a date in until this is all confirmed and you can drop the column.
		$validDays=365;
		$directStartInfo['F_ValidUntilDate'] = date('Y-m-d H:i:s', time() + ($validDays * 86400));
		
		$this->db->AutoExecute("T_DirectStart", $directStartInfo, "INSERT");
		
		// And if you fail?
		return $directStartInfo['F_SecureString'];
	}
	
	// Called to allow a subscription reminder email to include a link to usage stats.
	public function getDirectStartRecord($account) {
		$sql = 	<<<EOD
				SELECT F_SecureString AS secureString, F_Password as password FROM T_DirectStart
				WHERE F_RootID=?
EOD;
		$bindingParams = array($account->id);
		//echo "sql=$sql with id=".$account->id;
		$rs = $this->db->Execute($sql, $bindingParams);
		if ($rs && $rs->RecordCount() > 0) {
			// Check that the password hasn't changed
			$directStartRecord = $rs->FetchNextObj();
			//$one = $directStartRecord->password;
			//$two = $account->adminUser->password;
			if ($directStartRecord->password == $account->adminUser->password) {
				return ((string)($directStartRecord->secureString));
				
			// If it has, delete the old record(s)
			} else {
				$sql = 	<<<EOD
						DELETE FROM T_DirectStart
						WHERE F_RootID=?
EOD;
				$bindingParams = array($account->id);
				$rs = $this->db->Execute($sql, $bindingParams);
			}
		}
	}
	
	// Called to remove old records
	public function clearDirectStartRecords() {
		$this->db->Execute("DELETE FROM T_DirectStart WHERE F_ValidUntilDate<?", array(date('Y-m-d H:i:s', time())));		
	}

	// v3.4.3 I am not sure that we should be emailing from in here.
	/*
	public function sendDirectStartEmail($account, $templateID, $securityString) {
		$accountEmail = $account->email;
		$adminEmail = $account->adminUser->email;
		// To allow for testing without sending out real emails
		if (isset($_REQUEST['send']) || !isset($_SERVER["SERVER_NAME"])) {
			if ($accountEmail != $adminEmail && $accountEmail && $accountEmail!= '') {
				$emailArray[] = array("to" => $adminEmail
										,"data" => array("account" => $account, "session" => $securityString)
										,"cc" => array($accountEmail)
										);
			} else {
				$emailArray[] = array("to" => $adminEmail
										,"data" => array("account" => $account, "session" => $securityString)
										);
			}
			$this->emailOps->sendEmails("", $templateID, $emailArray);
		} else {
			if ($accountEmail != $adminEmail && $accountEmail && $accountEmail!= '') {
				echo "<b>Email: ".$adminEmail.", cc: ".$accountEmail."</b> $account->name, $account->id<br/><br/>";
			} else {
				echo "<b>Email: ".$adminEmail."</b> $account->name, $account->id<br/><br/>";
			}
			//echo $this->emailOps->fetchEmail($templateID, array("account" => $account, "session" => $securityString))."<hr/>";
		}
	}
	*/
	
	// gh#1487 Count tests purchased, used, scheduled
	public function getTestsUsed($pc, $rootID = null) {
        if (!$rootID)
		    $rootID = Session::get('rootID');
		
		// Tests purchased is currently T_Accounts.F_MaxStudents - we will manually have to add this with any incremental purchases
	    $bindingParams = array($pc, $rootID);
        $sql = <<<SQL
			SELECT * FROM T_Accounts
            WHERE F_ProductCode=?
            AND F_RootID=? 
SQL;
        $rs = $this->db->Execute($sql, $bindingParams);
        switch ($rs->RecordCount()) {
            case 0:
                // There are no records
                $purchased = 0;
                break;
            default:
            	// Just ignore anything more than one
                $dbObj = $rs->FetchNextObj();
                $purchased = intval($dbObj->F_MaxStudents);
        }
        
        // Tests completed is based on T_TestSession
        // Count the times one person did one test, but ignore it since it should only happen for special testing cases
        $sql = <<<SQL
			SELECT COUNT(*) as duplicates, F_UserID, F_TestID FROM T_TestSession
            WHERE F_ProductCode=?
            AND F_RootID=?
            AND F_CompletedDateStamp is not null
			GROUP BY F_UserID, F_TestID;
SQL;
        $rs = $this->db->Execute($sql, $bindingParams);
        $completed = $rs->RecordCount();

        // Find all the scheduled tests for groups in this root that have not closed.
        // TODO would it be worth saving F_RootID in T_ScheduledTests?
        $date = new DateTime();
		$dateNow = $date->format('Y-m-d H:i:s');
		$deletedStatus = ScheduledTest::STATUS_DELETED;
        $sql = <<<SQL
			SELECT * FROM T_ScheduledTests t, T_Membership m
            WHERE t.F_ProductCode=?
            AND t.F_GroupID = m.F_GroupID
            AND m.F_RootID=?
            AND t.F_CloseTime > '$dateNow'
            AND t.F_Status != $deletedStatus
			GROUP BY t.F_TestID
SQL;
        $rs = $this->db->Execute($sql, $bindingParams);
        $scheduledEstimate = 0;
        switch ($rs->RecordCount()) {
            case 0:
                // There are no records
                break;
            default:
            	// Include duplicate groups if they have multiple scheduled tests
            	$testList = array();
                while($dbObj = $rs->FetchNextObj())
                	$testList[] = new ScheduledTest($dbObj);

             	// Count number of students in each group
               	foreach ($testList as $test) {
               		$testId = $test->testId;
               		$groupId = $test->groupId;
               		$usersInGroup = $this->manageableOps->countUsersInGroup(array($groupId));

               		// See if any of them have completed this particular test
	               	$bindingParams1 = array($testId);
    		        $sql1 = <<<SQL
						SELECT COUNT(DISTINCT(F_UserID)) as testsUsed FROM T_TestSession
			            WHERE F_TestID=? 
			            AND F_CompletedDateStamp is not null
SQL;
			        $rs1 = $this->db->Execute($sql1, $bindingParams1);
			        switch ($rs1->RecordCount()) {
			            case 0:
			                // There are no records
			                $alreadyCompleted = 0;
			                break;
			            default:
			            	// Just ignore anything more than one
			                $dbObj1 = $rs1->FetchNextObj();
			                $alreadyCompleted = $dbObj1->testsUsed;
			        }
			        // ctp#341
                    $scheduledEstimate += $usersInGroup - $alreadyCompleted;
               	}
        }
        
		$usage = array();
		$usage['purchased'] = $purchased; 
		$usage['used'] = $completed; 
		$usage['scheduled'] = $scheduledEstimate;
		return $usage;
	}
}

