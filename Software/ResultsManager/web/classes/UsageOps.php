<?php
require_once(dirname(__FILE__)."/SelectBuilder.php");
class UsageOps {

	var $db;

	function UsageOps($db) {
		$this->db = $db;
		//$this->emailOps = new EmailOps($this->db);
	}
	
	function getUsageForTitle($title, $fromDate, $toDate) {
		//NetDebug::trace("getUsageForTitle: from ".$fromDate." to ".$toDate);		
		$usage = array();
		//$usage['courseUserCounts'] = $this->getCourseUserCounts($title, $fromDate, $toDate);
		//$usage['courseTimeCounts'] = $this->getCourseTimeCounts($title, $fromDate, $toDate);
		// v3.5 This is picking up all usage stats that we want, it differs for AA and LT licences
		$rootID = Session::get('rootID');
		// What stats do we want for AA licences? Well, everything except for licence counts
		$fromDateStamp = $this->getLicenceClearanceDate($title);

		if ($title->licenceType == 2) {
			//NetDebug::trace("AA usage stats please");		
			//$usage['sessionDuration'] = $this->getAASessionDuration($title, $fromDate, $toDate);
		} else {
			// AR also read the number of title/user licences that have been used. This is based on licence
			// period, not the dates the reporter selected
			$usage['titleUserCounts'] = $this->getTitleUserCounts($title, $rootID, $fromDateStamp);
		}
		$usage['sessionCounts'] = $this->getAASessionCounts($title, $fromDate, $toDate);
		$courseCountArray = $this->getCourseCounts($title, $fromDate, $toDate);
		$usage['courseCounts'] = $courseCountArray['courseCounts'];
		if (isset($courseCountArray['otherCourseCounts']))
			$usage['otherCourseCounts'] = $courseCountArray['otherCourseCounts'];
		$usage['failedLoginCounts'] = $this->getFailedLoginCounts($title, $rootID, $fromDate, $toDate);
		// Tell RM what date we used for licence clearance date, so it doesn't calculate it wrongly
		$usage['licenceClearanceDate'] = strftime('%Y-%m-%d 00:00:00',$fromDateStamp);
		
		return $usage;
	}
	// The following is a public function for getting licences used for all titles in an account.
	// Called from DMS EarlyWarning
	function getLicencesUsedForAccount($account) {
		$accountLicenceTypes=0;
		foreach ($account->titles as $title) {
			// v3.6.5 Add licence clearance date.
			$fromDateStamp = $this->getLicenceClearanceDate($title);
				
			// As well as licences used, I want to know if this account is purely one licence type.
			// If an AA licence has had RM added, it too should be AA
			// This should also pick up Transferable Tracking
			switch ($title->licenceType) {
				case 1:
				case 6:
					$title->licencesUsed = $this->getTitleUserCountsApprox($title, $account->id, $fromDateStamp);
					$accountLicenceTypes = $accountLicenceTypes | 1;
					break;
				case 2:
					$accountLicenceTypes = $accountLicenceTypes | 2;
					break;
				case 3:
					$accountLicenceTypes = $accountLicenceTypes | 4;
					break;
				case 4:
					$accountLicenceTypes = $accountLicenceTypes | 8;
					break;
				case 5:
					$accountLicenceTypes = $accountLicenceTypes | 16;
					break;
				default:
					// Shouldn't exist at the moment
					$accountLicenceTypes = $accountLicenceTypes | 32;
					break;
			}
		}
		$account->licenceType=$accountLicenceTypes;
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
	 *
	 */
	private function getAASessionCounts($title, $fromDate, $toDate) {
		
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
		if ($firstYear < 2008)
			$firstYear=2008;
		if ($lastYear > intval(date('Y')))
			$lastYear = intval(date('Y'));
			
		// for each year, get the stats
		// But we are sending a usage period with first and last dates, so shouldn't we respect these?
		// No - ends up showing a wrong graph since Jan is always there
		$statsArray = array();
		for ($i = $firstYear; $i <= $lastYear; $i++) {
			$j = $i + 1;
			/*
			if ($i == $firstYear) {
				$startDate = $fromDate;
			} else {
				$startDate = $i;
			}
			if ($i == $lastYear) {
				$endDate = $toDate;
			} else {
				$endDate = $j;
			}
			*/
			//$startDate = $i;
			//$endDate = $j;
			//v3.6 datepart is not MySQL compatible
			// options are date_format(F_StartDateStamp, %m) or month(F_StartDateStamp)
			// Use adodb SQLDATE($fmt, $date)
			//		select count(F_SessionID) sessionCount, datepart(m, F_StartDateStamp) month
			//		select count(F_SessionID) sessionCount, month(F_StartDateStamp) month
			//		select count(F_SessionID) sessionCount, $sqldatemonth month
			// Or month is a common function to T-SQL and MySQL. Not SQLite though.
			//v3.6 This fails in sqlite and the adodb functions don't have SQLDATE. 
			// strftime('%m',F_StartDateStamp) is what we need.
			if (strpos($GLOBALS['db'],"sqlite")!==false) {
				$sqldatemonth = "strftime('%m',F_StartDateStamp) ";
			} else {
				$sqldatemonth = $this->db->SQLDATE('m', F_StartDateStamp);
			}
			$sql = 	<<<EOD
					select count(F_SessionID) sessionCount, $sqldatemonth month
					from T_Session
					where F_RootID = ?
					and F_ProductCode = ?
					and F_StartDateStamp>='$i-01-01'
					and F_StartDateStamp<'$j'
					group by $sqldatemonth
					order by $sqldatemonth;
EOD;
			//NetDebug::trace("sql=". $sql);
			//$statsArray["$i"] = $this->db->GetArray($sql, array(Session::get('rootID'), $title->id, $i, $i+1));
			$statsArray["$i"] = $this->db->GetArray($sql, array(Session::get('rootID'), $title->id));
		}
		
		//return array("2009"=>$rs2009, "2010"=>$rs2010);
		return $statsArray;
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
		$sql = 	<<<EOD
				SELECT F_CourseID courseID, COUNT(ss.F_SessionID) courseCount, SUM(ss.F_Duration) duration
				FROM T_Session ss
				WHERE ss.F_ProductCode=?
				AND ss.F_RootID = ?
				AND ss.F_StartDateStamp >= '$fromDateStamp'
				AND ss.F_StartDateStamp <= '$toDateStamp'
				GROUP BY ss.F_CourseID
EOD;
		$bindingParams = array($title->id, Session::get('rootID'));
		//NetDebug::trace("USAGE: sql=".$sql);		
		//NetDebug::trace("bindings=".implode(",",$bindingParams));		
		// Unfortunately date bindings don't seem to work so they are directly embedded in the SQL string
		//$rs = $this->db->GetArray($sql, array($_SESSION['rootID'], $this->db->BindDate("$fromDateStamp"), $this->db->BindDate("$toDateStamp")));
		//$rs = $this->db->GetArray($sql, array(Session::get('rootID')));
		$rs = $this->db->GetArray($sql, $bindingParams);
		
		// If you have a product that has different courseIDs for different language versions, then here you get double.
		// It would be nice to consolidate them based on name. But of very small interest I suppose. And of course I don't know the names
		// of courseIDs from the db. But I suppose I could just count those that are NOT in the current courseIDs?
		$otherCount=0;
		foreach ($rs as $record) {
			// Is this SQL record listed in the current title?
			if (in_array($record['courseID'],$courseIdArray)) {
				// add this count and duration to the return set
				$currentRS[] = $record;
			} else {
				$otherCount+=$record['courseCount'];
				$otherDuration+=$record['duration'];
			}
		}
		$returnArray = array(courseCounts=>$currentRS);
		if ($otherCount>0)
			//$currentRS[] = array(courseID=>0,userCount=>$otherCount,duration=>$otherDuration);
			$returnArray['otherCourseCounts'] = array(courseID=>0,courseCount=>$otherCount,duration=>$otherDuration);
		
		return $returnArray;
	}
	
	// AR How many title/user licences have been used so far in this licence period?
	//private function getTitleUserCounts($title, $rootID) {
	private function getTitleUserCounts($title, $rootID, $fromDateStamp = null) {
		// AR We want special processing for counting licences in perpetual licences, basically a rolling 1 year.
		// So test to see if perpetual (any date>=2049). The $title dates are in m/d/y format. Why? I think this will change 
		// Note that you can't do strtotime for dates after 19 Jan 2038 as this is greatest range of integer
		// So well have to do it manually
		// v3.6.5 Add licence clearance date.
		if (!$fromDateStamp)
			$fromDateStamp = $this->getLicenceClearanceDate($title);
		$fromDate = strftime('%Y-%m-%d 00:00:00',$fromDateStamp);
		//echo strftime('%d %B, %Y',$fromDateStamp);
		
		/*
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
		*/
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
			$rs2 = $this->db->GetRow($sql, array($title-> productCode, $rootID));
			//NetDebug::trace("UsageOps.sql.deleted.rs=".$rs2['allDeletedCount']);
			$deletedCount = $rs2['allDeletedCount'];
		}

		return $rs['activeStudentCount'] + $deletedCount;
	}
	// AR This is used in EarlyWarningSystem. It is much quicker, though a little rough
	//private function getTitleUserCountsApprox($title, $rootID) {
	private function getTitleUserCountsApprox($title, $rootID, $fromDateStamp=null) {
		/*
		$myYearBit = explode(" ", $title->expiryDate);
		$brokenDate = explode("-", $myYearBit[0]);
		if ($brokenDate[0] >= '2037') {
			$fromDateStamp = date('Y-m-d', strtotime("-1 year"));
		} else {
			$fromDateStamp = $title->licenceStartDate;
		}
		*/
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
		$sql = 	<<<EOD
				SELECT COUNT(*) failedLogins, F_ReasonCode
				FROM T_Failsession
				WHERE F_ProductCode = ?
				AND F_RootID = ?
				AND F_StartTime >= '$fromDateStamp'
				AND F_StartTime <= '$toDateStamp'
				GROUP BY F_ReasonCode
EOD;
		
		// Not just one row, but a table now
		//$rs = $this->db->GetRow($sql, array($title->productCode, $_SESSION['rootID']));
		//$rs = $this->db->GetArray($sql, array($title->productCode, Session::get('rootID')));
		$rs = $this->db->GetArray($sql, array($title->productCode, $rootID));
		//echo $sql;
		//NetDebug::trace("UsageOps.failLogins.sql.rs=".$rs['failedLogins']);
		//return $rs['failedLogins'];
		return $rs;
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
				SELECT F_SecureString AS secureString FROM T_DirectStart
				WHERE F_RootID=?
EOD;
		$bindingParams = array($account->id);
		//echo "sql=$sql with id=".$account->id;
		$rs = $this->db->Execute($sql, $bindingParams);
		if ($rs)
			return ((string)($rs->FetchNextObj()->secureString));
		
	}
	// Called to remove old records
	public function clearDirectStartRecords() {
		$this->db->Execute("DELETE FROM T_DirectStart WHERE F_ValidUntilDate<?", array(date('Y-m-d H:i:s', time())));		
	}

	// v3.6.5 Figure out the most recent clearance date
	private function getLicenceClearanceDate($title) {
		// The from date for counting licence use is calculated as follows:
		// If there is no licenceClearanceDate, then use licenceStartDate.
		// If there is no licenceClearanceFrequency, then use +1y
		// Take licenceClearanceDate and add the frequency to it until we get a date in the future.
		// The previous date is our fromDate.
		if (!$title->licenceClearanceDate) 
			$title->licenceClearanceDate = $title->licenceStartDate;
		// Just in case dates have been put in wrongly. 
		// First, if clearance date is in the future, use the start date
		if ($title->licenceClearanceDate > time()) 
			$title->licenceClearanceDate = $title->licenceStartDate;
		// If clearance date is before the start date, it doesn't much matter
		// Turn the string into a timestamp
		$fromDateStamp = strtotime($title->licenceClearanceDate);
		
		// You mustn't have a negative frequency otherwise the loop will be infinite
		if (!$title->licenceClearanceFrequency)
			$title->licenceClearanceFrequency = '1 year';
		if (stristr($title->licenceClearanceFrequency, '-')!==FALSE) 
			$title->licenceClearanceFrequency = str_replace('-', '', $title-> licenceClearanceFrequency);
		// Check that the frequency is valid
		if (!strtotime($title-> licenceClearanceFrequency, $fromDateStamp) > 0)
			$title->licenceClearanceFrequency = '1 year';
		// Just in case we still have invalid data
		//NetDebug::trace("fromDateStamp=".$fromDateStamp.' which is '.strftime('%Y-%m-%d 00:00:00',$fromDateStamp));
		$safetyCount=0;
		while ($safetyCount<99 && strtotime($title->licenceClearanceFrequency, $fromDateStamp) < time()) {
			$fromDateStamp = strtotime($title->licenceClearanceFrequency, $fromDateStamp);
			$safetyCount++;
		}
		// We want the datestamp, not a formatted date
		return $fromDateStamp;
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
}
?>
