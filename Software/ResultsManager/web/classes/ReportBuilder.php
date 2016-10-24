<?php

require_once(dirname(__FILE__)."/SelectBuilder.php");

class ReportBuilder {
	
	var $db;
	var $opts;
	
	var $selectBuilder;
	var $valideExerciseID;

	const GROUPED = "grouped";
	
	const SHOW_TITLE = "show_title";
	const SHOW_COURSE = "show_course";
	// gh#23
	const WITHIN_COURSE = "within_course";
	
	const SHOW_UNIT = "show_unit"; // SHOW_UNIT automatically includes SHOW_COURSE
	const SHOW_EXERCISE = "show_exercise"; // SHOW_EXERCISE automatically includes SHOW_UNIT & SHOW_COURSE
	const SHOW_GROUPNAME = "show_groupname";
	const SHOW_USERNAME = "show_username";
	const SHOW_STUDENTID = "show_studentID";
	const SHOW_EMAIL = "show_email";
	// v3.4 To allow you to group together scores from one session for summary (test) reports
	const SHOW_SESSIONID = "show_sessionID";
	
	const SHOW_SCORE = "show_score";
	const SHOW_SCORE_CORRECT = "show_score_correct";
	const SHOW_SCORE_WRONG = "show_score_wrong";
	const SHOW_SCORE_MISSED = "show_score_missed";
	const SHOW_SCORE_OF = "show_score_of"; // add up correct+missed+wrong
	const SHOW_DURATION = "show_duration";
	const SHOW_STARTDATE = "show_startdate";
	
	const SHOW_AVERAGE_SCORE = "show_average_score";
	const SHOW_COMPLETE = "show_complete";
	// gh#23
	const SHOW_EXERCISE_PERCENTAGE = "show_exercise_percentage";
	const SHOW_EXERCISEUNIT_PERCENTAGE = "show_exerciseunit_percentage";
	const SHOW_UNIT_PERCENTAGE = "show_unit_percentage";
	
	const SHOW_AVERAGE_TIME = "show_average_time";
	const SHOW_TOTAL_TIME = "show_total_time";

	// gh#1470
	const SHOW_LICENCES_USED = "show_licences_used";
	const SHOW_SESSIONS_USED = "show_sessions_used";
	
	const DETAILED_REPORT = "detailed_report"; // boolean
	const ATTEMPTS = "attempts"; // Can be empty (i.e. all), "first" or "last"
	const FROM_DATE = "from_date";
	const TO_DATE = "to_date";
	const SCORE_LESS_THAN = "score_less_than";
	const SCORE_MORE_THAN = "score_more_than";
	const DURATION_LESS_THAN = "duration_less_than";
	const DURATION_MORE_THAN = "duration_more_than";
	
	const FOR_USERS = "for_users";
	const FOR_GROUPS = "for_groups";
	const FOR_COURSES = "for_courses";
	const FOR_UNITS = "for_units";
	const FOR_EXERCISES = "for_exercises";
	const FOR_IDOBJECTS = "for_idobjects";

	const ORDERBY_USERS = "orderby_users";
	const ORDERBY_UNIT = "orderby_unit";
	
	// gh#777
	const SHOW_INACTIVE_USERS = "show_inactive_users";

    // gh#1505
    const SHOW_CEF = 'show_cef';

	function ReportBuilder($db = null) {
		$this->db = $db;
		$this->opts = array();
		// AR To avoid php Notice warnings:
		if (!isset($this->opts[ReportBuilder::SHOW_TITLE])) $this->opts[ReportBuilder::SHOW_TITLE] = "";
		if (!isset($this->opts[ReportBuilder::SHOW_COURSE])) $this->opts[ReportBuilder::SHOW_COURSE] = "";
		// gh#23
		if (!isset($this->opts[ReportBuilder::WITHIN_COURSE])) $this->opts[ReportBuilder::WITHIN_COURSE] = "";
		
		if (!isset($this->opts[ReportBuilder::SHOW_UNIT])) $this->opts[ReportBuilder::SHOW_UNIT] = "";
		if (!isset($this->opts[ReportBuilder::SHOW_EXERCISE])) $this->opts[ReportBuilder::SHOW_EXERCISE] = "";
		if (!isset($this->opts[ReportBuilder::SHOW_GROUPNAME])) $this->opts[ReportBuilder::SHOW_GROUPNAME] = "";
		if (!isset($this->opts[ReportBuilder::SHOW_USERNAME])) $this->opts[ReportBuilder::SHOW_USERNAME] = "";
		if (!isset($this->opts[ReportBuilder::SHOW_STUDENTID])) $this->opts[ReportBuilder::SHOW_STUDENTID] = "";
		if (!isset($this->opts[ReportBuilder::SHOW_EMAIL])) $this->opts[ReportBuilder::SHOW_EMAIL] = "";
		if (!isset($this->opts[ReportBuilder::SHOW_SCORE])) $this->opts[ReportBuilder::SHOW_SCORE] = "";
		if (!isset($this->opts[ReportBuilder::SHOW_SCORE_CORRECT])) $this->opts[ReportBuilder::SHOW_SCORE_CORRECT] = "";
		if (!isset($this->opts[ReportBuilder::SHOW_SCORE_WRONG])) $this->opts[ReportBuilder::SHOW_SCORE_WRONG] = "";
		if (!isset($this->opts[ReportBuilder::SHOW_SCORE_MISSED])) $this->opts[ReportBuilder::SHOW_SCORE_MISSED] = "";
		if (!isset($this->opts[ReportBuilder::SHOW_SCORE_OF])) $this->opts[ReportBuilder::SHOW_SCORE_OF] = "";
		if (!isset($this->opts[ReportBuilder::SHOW_DURATION])) $this->opts[ReportBuilder::SHOW_DURATION] = "";
		if (!isset($this->opts[ReportBuilder::SHOW_STARTDATE])) $this->opts[ReportBuilder::SHOW_STARTDATE] = "";
		if (!isset($this->opts[ReportBuilder::ATTEMPTS])) $this->opts[ReportBuilder::ATTEMPTS] = "";
		if (!isset($this->opts[ReportBuilder::DETAILED_REPORT])) $this->opts[ReportBuilder::DETAILED_REPORT] = "";
		if (!isset($this->opts[ReportBuilder::FROM_DATE])) $this->opts[ReportBuilder::FROM_DATE] = "";
		if (!isset($this->opts[ReportBuilder::TO_DATE])) $this->opts[ReportBuilder::TO_DATE] = "";
		if (!isset($this->opts[ReportBuilder::SCORE_LESS_THAN])) $this->opts[ReportBuilder::SCORE_LESS_THAN] = "";
		if (!isset($this->opts[ReportBuilder::SCORE_MORE_THAN])) $this->opts[ReportBuilder::SCORE_MORE_THAN] = "";
		if (!isset($this->opts[ReportBuilder::DURATION_LESS_THAN])) $this->opts[ReportBuilder::DURATION_LESS_THAN] = "";
		if (!isset($this->opts[ReportBuilder::DURATION_MORE_THAN])) $this->opts[ReportBuilder::DURATION_MORE_THAN] = "";
		if (!isset($this->opts[ReportBuilder::FOR_USERS])) $this->opts[ReportBuilder::FOR_USERS] = "";
		if (!isset($this->opts[ReportBuilder::FOR_GROUPS])) $this->opts[ReportBuilder::FOR_GROUPS] = "";
		if (!isset($this->opts[ReportBuilder::FOR_COURSES])) $this->opts[ReportBuilder::FOR_COURSES] = "";
		if (!isset($this->opts[ReportBuilder::FOR_UNITS])) $this->opts[ReportBuilder::FOR_UNITS] = "";
		if (!isset($this->opts[ReportBuilder::FOR_EXERCISES])) $this->opts[ReportBuilder::FOR_EXERCISES] = "";
		if (!isset($this->opts[ReportBuilder::FOR_IDOBJECTS])) $this->opts[ReportBuilder::FOR_IDOBJECTS] = "";
		if (!isset($this->opts[ReportBuilder::GROUPED])) $this->opts[ReportBuilder::GROUPED] = "";
		if (!isset($this->opts[ReportBuilder::SHOW_AVERAGE_SCORE])) $this->opts[ReportBuilder::SHOW_AVERAGE_SCORE] = "";
		if (!isset($this->opts[ReportBuilder::SHOW_COMPLETE])) $this->opts[ReportBuilder::SHOW_COMPLETE] = "";
		//issue:#23
		if (!isset($this->opts[ReportBuilder::SHOW_EXERCISE_PERCENTAGE])) $this->opts[ReportBuilder::SHOW_EXERCISE_PERCENTAGE] = "";
		if (!isset($this->opts[ReportBuilder::SHOW_EXERCISEUNIT_PERCENTAGE])) $this->opts[ReportBuilder::SHOW_EXERCISEUNIT_PERCENTAGE] = "";
		if (!isset($this->opts[ReportBuilder::SHOW_UNIT_PERCENTAGE])) $this->opts[ReportBuilder::SHOW_UNIT_PERCENTAGE] = "";
		
		if (!isset($this->opts[ReportBuilder::SHOW_AVERAGE_TIME])) $this->opts[ReportBuilder::SHOW_AVERAGE_TIME] = "";
		if (!isset($this->opts[ReportBuilder::SHOW_TOTAL_TIME])) $this->opts[ReportBuilder::SHOW_TOTAL_TIME] = "";
		if (!isset($this->opts[ReportBuilder::ORDERBY_USERS])) $this->opts[ReportBuilder::ORDERBY_USERS] = "";
		if (!isset($this->opts[ReportBuilder::ORDERBY_UNIT])) $this->opts[ReportBuilder::ORDERBY_UNIT] = "";
		if (!isset($this->opts[ReportBuilder::SHOW_SESSIONID])) $this->opts[ReportBuilder::SHOW_SESSIONID] = "";
		// gh#777
		if (!isset($this->opts[ReportBuilder::SHOW_INACTIVE_USERS])) $this->opts[ReportBuilder::SHOW_INACTIVE_USERS] = "";
        // gh#1505
        if (!isset($this->opts[ReportBuilder::SHOW_CEF])) $this->opts[ReportBuilder::SHOW_CEF] = "";
	}
	
	function setOpt($opt, $value) {
		$this->opts[$opt] = $value;
		
		// gh#23	
		if ($opt == ReportBuilder::WITHIN_COURSE && $value) {
			//$this->setOpt(ReportBuilder::SHOW_UNIT_PERCENTAGE, true);
            $this->setOpt(ReportBuilder::SHOW_EXERCISEUNIT_PERCENTAGE, true);			
		}
		
		// Special cases
		if ($opt == ReportBuilder::SHOW_UNIT && $value) {
		    $this->setOpt(ReportBuilder::SHOW_COURSE, true);
			// gh#23
			$this->setOpt(ReportBuilder::SHOW_EXERCISE_PERCENTAGE, true);
		}
		if ($opt == ReportBuilder::SHOW_EXERCISE && $value) {
		    $this->setOpt(ReportBuilder::SHOW_UNIT, true);
			// gh#23
			$this->setOpt(ReportBuilder::SHOW_EXERCISE_PERCENTAGE, false);
		}
	}
	
	// v3.4 ReportOps needs to call this too
	//private function getOpt($opt) {
	function getOpt($opt) {
		return $this->opts[$opt];
	}
	
	private function checkGrouped($grouped) {
		if ($this->getOpt(ReportBuilder::GROUPED) != $grouped)
			throw new Exception("Illegal option passed to ReportBuilder for this group mode");
	}
	
	private function addColumn($column, $name, $function = null) {
		$this->selectBuilder->addSelect((($function == null) ? $column : $function)." ".$name);
		
		if ($this->getOpt(ReportBuilder::GROUPED) && $function == null) {
			$this->selectBuilder->addGroup($column);
			$this->selectBuilder->addOrder($column);
		}
		
	}

	// gh#1505 For test summary report
	function buildCTPReportSQL() {
		$this->selectBuilder = new SelectBuilder();
		$fromClause = <<<EOD
						T_TestSession s
						INNER JOIN T_User u ON s.F_UserID=u.F_UserID
						INNER JOIN T_Membership m ON s.F_UserID=m.F_UserID
						INNER JOIN T_Groupstructure g on g.F_GroupID = m.F_GroupID
EOD;
		$this->selectBuilder->setFrom($fromClause);

        // Selection of name columns
        if ($this->getOpt(ReportBuilder::SHOW_GROUPNAME)) $this->addColumn("g.F_GroupName", "groupName");
        if ($this->getOpt(ReportBuilder::SHOW_USERNAME)) $this->addColumn("u.F_UserName", "userName");
        if ($this->getOpt(ReportBuilder::SHOW_STUDENTID)) $this->addColumn("u.F_StudentID", "studentID");
        if ($this->getOpt(ReportBuilder::SHOW_EMAIL)) $this->addColumn("u.F_Email", "email");

        // Selection of ungrouped columns
        if ($this->getOpt(ReportBuilder::SHOW_CEF)) $this->addColumn("s.F_Result", "result");
        if ($this->getOpt(ReportBuilder::SHOW_DURATION)) $this->addColumn("s.F_Duration", "duration");
        if ($this->getOpt(ReportBuilder::SHOW_STARTDATE)) $this->addColumn("s.F_StartedDateStamp", "start_date");

        // From date
        if ($fromDate = $this->getOpt(ReportBuilder::FROM_DATE))
            $this->selectBuilder->addWhere("s.F_DateStamp >= '$fromDate'");
        if ($toDate = $this->getOpt(ReportBuilder::TO_DATE))
            $this->selectBuilder->addWhere("s.F_DateStamp <= '$toDate'");

        // v3.4 For summary reports, you want to use sessionID
        $this->addColumn("s.F_SessionID", "sessionID");
        $this->addColumn("u.F_UserID", "userID");

        // For idObjects (e.g. CourseID=? AND UnitID=? AND ExerciseID=?)
        if ($idObjects = $this->getOpt(ReportBuilder::FOR_IDOBJECTS)) {
                foreach ($idObjects as $idObject) {
                    $wheres = array();
                    foreach ($idObject as $class => $id) {
                        switch ($class) {
                            case "Title":
                                $wheres[] = "s.F_ProductCode=".$id;
                                break;
                        }
                    }
                    // Passing true as a parameter to addWhere marks these as OR clauses instead of the default AND
                    //gh#28
                    $this->selectBuilder->addWhere("(".implode(" AND ", $wheres).")", true);
                }
        }

        // v3.0.4 If you want special ordering
        if ($this->getOpt(ReportBuilder::ORDERBY_USERS)) $this->selectBuilder->addOrder('s.F_UserID');
        if ($this->getOpt(ReportBuilder::ORDERBY_UNIT)) $this->selectBuilder->addOrder('s.F_UnitID');

        // v3.4 Get last session results first
        if ($this->getOpt(ReportBuilder::SHOW_SESSIONID)) $this->selectBuilder->addOrder('s.F_SessionID', 'DESC');

        // AR To only pick up results for learners - ignore teachers etc
        $this->selectBuilder->addWhere("u.F_UserType=".USER::USER_TYPE_STUDENT);

        return $this->selectBuilder->toSQL();
    }

	// TODO: This needs to check against $_SESSION['rootID'] too otherwise it could pick up students in multiple roots (maybe)
	function buildReportSQL() {
		$this->selectBuilder = new SelectBuilder();
		
		// The FROM field is always the same for all reports
		// Small problem with attempts. It sometimes happens that sessionID=-1 and whilst this usually means a problem happened
		// it does happen. If you are running with attempts, then the inner select here picks up -1 sessions though the outer doesn't
		// which means you can end up with a first_attempt date that won't match. If you want to fix it, add this WHERE clause
		//					SELECT F_ExerciseID e,
		//							...
		//							FROM T_Score >>>WHERE F_SessionID>0<<<
		//							GROUP BY F_ExerciseID, F_UserID
		// Added just in case.
		// Note that if we are not using attempts to filter the results (and the default is not to), this introduces a massive
		// extra select into the SQL. It would be much much better to check for it, and to also include userID filtering.
		// I might be wrong. The inner select on its own takes 16 seconds and gives 1m+ rows, but the sql as a whole is very fast.
		// So there must be some non-obvious filtering going on. Clever old SQL Server.
		// v3.3 MySQL Migration. This hangs up in MySQL, so perhaps we should break it all up a bit.
		// Start by removing the attempts subclause if you don't need it.
		//$this->selectBuilder->setFrom(<<<EOD
		// v3.5 Title based sessions. But actually, so long as F_CourseID is in score, which it now is, 
		// there is no need for T_Session in this call at all.
		//				INNER JOIN T_Session ss ON s.F_SessionID=ss.F_SessionID
		// Now, because courseID is not unique for R2I we need session back again!
		// Desperation for HCT. PC suggests INNER JOINS are very bad news too
		//				T_Score s, T_User u, T_Membership m, T_Groupstructure g, T_Session ss
		// But the real problem is the join of score and session (which can be easily removed as productCode can come from using courseID on T_CourseInfo)
		// and the first/last attempts SELECT. I wonder if I can write a stored procedure and cursor to do this in two queries?
		// Or build a slightly different query when I have a limited number of userIDs - and MySQL
		// a) Replace session with courseIn
		// b) remove SessionID>0
		// Now gone further and denormalised so we write ProductCode to T_Score, so no need for T_CourseInfo
		//				INNER JOIN T_CourseInfo c ON s.F_CourseID=c.F_CourseID
		$attempts = $this->getOpt(ReportBuilder::ATTEMPTS);
		$forUsers = $this->getOpt(ReportBuilder::FOR_USERS);
		
		$fromClause = <<<EOD
						T_Score s
						INNER JOIN T_User u ON s.F_UserID=u.F_UserID
						INNER JOIN T_Membership m ON s.F_UserID=m.F_UserID
						INNER JOIN T_Groupstructure g on g.F_GroupID = m.F_GroupID
EOD;
		// gh#690 First and Last filtering requires duplication of clauses
		// TODO in fact, if you do them here you DON'T need to do them anywhere else
		if ($attempts == "first" || $attempts == "last") {
			
			$innerSelect = new SelectBuilder();
			$innerSelect->setFrom('T_Score');
			$innerSelect->addSelect('F_ExerciseID as e');
			$innerSelect->addSelect('F_UserID as u');
			$innerSelect->addSelect('MIN(F_DateStamp) first_attempt');
			$innerSelect->addSelect('MAX(F_DateStamp) last_attempt');
			if ($forUsers) {
				$forUsersInString = implode(",", $forUsers);
				$innerSelect->addWhere("F_UserID IN ($forUsersInString)");
			}	
			// Less than score condition
			if ($scoreLessThan = $this->getOpt(ReportBuilder::SCORE_LESS_THAN))
				$innerSelect->addWhere("F_Score <= ".$scoreLessThan);
		
			// More than score condition
			if ($scoreMoreThan = $this->getOpt(ReportBuilder::SCORE_MORE_THAN))
				$innerSelect->addWhere("F_Score >= ".$scoreMoreThan);
		
			// Less than duration condition. The duration from the screen is minutes, in the database it is seconds
			if ($durationLessThan = $this->getOpt(ReportBuilder::DURATION_LESS_THAN))
				$innerSelect->addWhere("F_Duration <= ".(int)($durationLessThan*60));
		
			// More than duration condition
			if ($durationMoreThan = $this->getOpt(ReportBuilder::DURATION_MORE_THAN))
				$innerSelect->addWhere("F_Duration > ".(int)($durationMoreThan*60));
		
			// From and to date setting
			if ($fromDate = $this->getOpt(ReportBuilder::FROM_DATE))
				$innerSelect->addWhere("F_DateStamp >= '$fromDate'");
			if ($toDate = $this->getOpt(ReportBuilder::TO_DATE))
				$innerSelect->addWhere("F_DateStamp <= '$toDate'");
				
			$innerSelect->addGroup('F_ExerciseID');
			$innerSelect->addGroup('F_UserID');
			
			// gh#690 simplify
			$fromClause.= " INNER JOIN (".$innerSelect->toSQL().") attempts "; 
			$fromClause.= <<<EOD
				ON s.F_ExerciseID=attempts.e
				AND s.F_UserID = attempts.u
EOD;
			$fromClause.= " AND s.F_DateStamp=attempts.".$attempts."_attempt ";
		}
		$this->selectBuilder->setFrom($fromClause);
		// From earlier INNER JOINS
		//$this->selectBuilder->addWhere('s.F_UserID=u.F_UserID');
		//$this->selectBuilder->addWhere('g.F_GroupID = m.F_GroupID');
		//$this->selectBuilder->addWhere('s.F_UserID=u.F_UserID');
		//$this->selectBuilder->addWhere('s.F_SessionID=ss.F_SessionID');

		// gh#777 Need userID for later searching/filtering
		$this->addColumn("u.F_UserID", "userID");
				
		// Selection of common columns
		// v3.4 To allow productCode to be sent back too. Put it first to help sorting the returned results if grouped.
		//if ($this->getOpt(ReportBuilder::SHOW_COURSE)) $this->addColumn("c.F_ProductCode", "productCode");
		// gh#797		
		if ($this->getOpt(ReportBuilder::SHOW_TITLE) || $this->getOpt(ReportBuilder::SHOW_COURSE)) $this->addColumn("s.F_ProductCode", "productCode");		
		// v3.4 This could be read from s.F_CourseID if I want session to be by product not course
		//if ($this->getOpt(ReportBuilder::SHOW_COURSE)) $this->addColumn("ss.F_CourseID", "courseID");
		if ($this->getOpt(ReportBuilder::SHOW_COURSE)) $this->addColumn("s.F_CourseID", "courseID");
		if ($this->getOpt(ReportBuilder::SHOW_UNIT)) $this->addColumn("s.F_UnitID", "unitID");
		// gh#28
		//if ($this->getOpt(ReportBuilder::SHOW_UNIT)) $this->addColumn("s.F_ExerciseID", "exerciseUnitID");
		
		if ($this->getOpt(ReportBuilder::SHOW_EXERCISE)) $this->addColumn("s.F_ExerciseID", "exerciseID");
		
		// Selection of name columns
		if ($this->getOpt(ReportBuilder::SHOW_GROUPNAME)) $this->addColumn("g.F_GroupName", "groupName");
		if ($this->getOpt(ReportBuilder::SHOW_USERNAME)) $this->addColumn("u.F_UserName", "userName");
		if ($this->getOpt(ReportBuilder::SHOW_STUDENTID)) $this->addColumn("u.F_StudentID", "studentID");
		if ($this->getOpt(ReportBuilder::SHOW_EMAIL)) $this->addColumn("u.F_Email", "email");
		
		// For Science Po who need more data. How can I tell if it is them?
		// updated for 2013/14/15/16
		$rootID = Session::get('rootID');
		$this->selectBuilder->addWhere("m.F_RootID = '$rootID'");
		if ($rootID == '14781' || $rootID == '19278' || $rootID == '26155' || $rootID == '35886') {
			$this->addColumn("u.F_StudentID", "studentID");
			$this->addColumn("u.F_Email", "email");
			$this->addColumn("u.F_FullName", "fullName");
			$this->addColumn("u.F_custom1", "studentsYear");
			$this->addColumn("u.F_custom2", "correspondingFaculty");
		}
		// And BC Test summary wants email. Why not just add that to everything, surely the template can decide if it wants to use it?
		// Sadly no, if you add it in, a normal report ends up using email instead of name :(
		//if ($rootID == '14159') {
		//	$this->addColumn("u.F_Email", "email");
		//}		
		
		// Selection of ungrouped columns
		if ($this->getOpt(ReportBuilder::SHOW_SCORE)) { $this->checkGrouped(false); $this->addColumn(null, "score", "CASE s.F_Score WHEN -1 THEN NULL ELSE s.F_Score END"); }
		if ($this->getOpt(ReportBuilder::SHOW_DURATION)) { $this->checkGrouped(false); $this->addColumn("s.F_Duration", "duration"); }
		if ($this->getOpt(ReportBuilder::SHOW_STARTDATE)) { $this->checkGrouped(false); $this->addColumn("s.F_DateStamp", "start_date"); }
		// v3.0.4 For special reports
		if ($this->getOpt(ReportBuilder::SHOW_SCORE_CORRECT)) { $this->checkGrouped(false); $this->addColumn(null, "correct", "CASE s.F_ScoreCorrect WHEN -1 THEN NULL ELSE s.F_ScoreCorrect END"); }
		if ($this->getOpt(ReportBuilder::SHOW_SCORE_WRONG)) { $this->checkGrouped(false); $this->addColumn(null, "wrong", "CASE s.F_ScoreWrong WHEN -1 THEN NULL ELSE s.F_ScoreWrong END"); }
		if ($this->getOpt(ReportBuilder::SHOW_SCORE_MISSED)) { $this->checkGrouped(false); $this->addColumn(null, "missed", "CASE s.F_ScoreMissed WHEN -1 THEN NULL ELSE s.F_ScoreMissed END"); }
		if ($this->getOpt(ReportBuilder::SHOW_SCORE_OF)) { $this->checkGrouped(false); $this->addColumn(null, "numQuestions", "CASE s.F_ScoreCorrect WHEN -1 THEN NULL ELSE (s.F_ScoreCorrect + s.F_ScoreWrong + s.F_ScoreMissed) END"); }
		
		// Selection of grouped columns
		if ($this->getOpt(ReportBuilder::SHOW_AVERAGE_SCORE)) { $this->checkGrouped(true); $this->addColumn(null, "average_score", "AVG(CASE s.F_Score WHEN -1 THEN NULL ELSE s.F_Score END)"); }
		if ($this->getOpt(ReportBuilder::SHOW_COMPLETE)) { $this->checkGrouped(true); $this->addColumn(null, "complete", "COUNT(s.F_Score)"); }
		// gh#23
		if ($this->getOpt(ReportBuilder::SHOW_EXERCISE_PERCENTAGE)) { $this->checkGrouped(true); $this->addColumn(null, "exercise_percentage", "COUNT(DISTINCT s.F_ExerciseID)"); }
		if ($this->getOpt(ReportBuilder::SHOW_EXERCISEUNIT_PERCENTAGE)) { $this->checkGrouped(true); $this->addColumn(null, "exerciseUnit_percentage", "COUNT(DISTINCT s.F_ExerciseID)"); }
		if ($this->getOpt(ReportBuilder::SHOW_UNIT_PERCENTAGE)) { $this->checkGrouped(true); $this->addColumn(null, "unit_percentage", "COUNT(DISTINCT s.F_UnitID)"); }
		
		if ($this->getOpt(ReportBuilder::SHOW_AVERAGE_TIME)) { $this->checkGrouped(true); $this->addColumn(null, "average_time", "AVG(s.F_Duration)"); }
		if ($this->getOpt(ReportBuilder::SHOW_TOTAL_TIME)) { $this->checkGrouped(true); $this->addColumn(null, "total_time", "SUM(s.F_Duration)"); }
		
		// From date
		if ($fromDate = $this->getOpt(ReportBuilder::FROM_DATE)) {
			// Ticket #95 - the FROM_DATE is already an ANSI string
			//$dateStamp = ClarityService::_dateToDB($this->db, $fromDate);
			// Ticket #117
			$dateStamp = $fromDate;
			//$this->selectBuilder->addWhere("s.F_DateStamp >= '".$dateStamp."'");
			// v3.3 MySQL Conversion
			//$this->selectBuilder->addWhere("s.F_DateStamp >= CONVERT(datetime, '".$dateStamp."',120)");
			$this->selectBuilder->addWhere("s.F_DateStamp >= '$dateStamp'");
		}
		
		// To date
		if ($toDate = $this->getOpt(ReportBuilder::TO_DATE)) {
			//$dateStamp = ClarityService::_dateToDB($this->db, $toDate);
			// Ticket #95 - the FROM_DATE is already an ANSI string
			// Ticket #117
			$dateStamp = $toDate;
			//$this->selectBuilder->addWhere("s.F_DateStamp <= '".$dateStamp."'");
			// v3.3 MySQL Conversion
			//$this->selectBuilder->addWhere("s.F_DateStamp <= CONVERT(datetime, '".$dateStamp."',120)");
			$this->selectBuilder->addWhere("s.F_DateStamp <= '$dateStamp'");
		}
		
		// v3.4 For summary reports, you want to use sessionID
		if ($this->getOpt(ReportBuilder::SHOW_SESSIONID)) $this->addColumn("s.F_SessionID", "sessionID");
		
		// Less than score condition
		if ($scoreLessThan = $this->getOpt(ReportBuilder::SCORE_LESS_THAN))
			$this->selectBuilder->addWhere("s.F_Score <= ".$scoreLessThan);
		
		// More than score condition
		if ($scoreMoreThan = $this->getOpt(ReportBuilder::SCORE_MORE_THAN))
			$this->selectBuilder->addWhere("s.F_Score >= ".$scoreMoreThan);
		
		// Less than duration condition. The duration from the screen is minutes, in the database it is seconds
		if ($durationLessThan = $this->getOpt(ReportBuilder::DURATION_LESS_THAN))
			$this->selectBuilder->addWhere("s.F_Duration <= ".(int)($durationLessThan*60));
		
		// More than duration condition
		if ($durationMoreThan = $this->getOpt(ReportBuilder::DURATION_MORE_THAN))
			$this->selectBuilder->addWhere("s.F_Duration > ".(int)($durationMoreThan*60));
		
		// For specific group ids
		// gh#777 You can't select groups and users for a report, so if group selected ignore users
		if ($forGroups = $this->getOpt(ReportBuilder::FOR_GROUPS)) {
			$forGroupsInString = implode(",", $forGroups);
			$this->selectBuilder->addWhere("g.F_GroupID IN ($forGroupsInString)");
		// For specific user ids
		} elseif ($forUsers) {
			$forUsersInString = implode(",", $forUsers);
			//echo "forUsers=$forUsersInString";
			$this->selectBuilder->addWhere("s.F_UserID IN ($forUsersInString)");
		}
		
		// For specific course ids
		if ($forCourses = $this->getOpt(ReportBuilder::FOR_COURSES)) {
			$forCoursesInString = implode(",", $forCourses);
			// v3.4 This could be read from s.F_CourseID if I want session to be by product not course
			//$this->selectBuilder->addWhere("ss.F_CourseID IN ($forCoursesInString)");
			$this->selectBuilder->addWhere("s.F_CourseID IN ($forCoursesInString)");
		}
		
		// For specific unit ids
		if ($forUnits = $this->getOpt(ReportBuilder::FOR_UNITS)) {
			$forUnitsInString = implode(",", $forUnits);
			//echo $forUnitsInString;
			$this->selectBuilder->addWhere("s.F_UnitID IN ($forUnitsInString)");
		}
		
		// For specific exercise ids
		if ($forExercises = $this->getOpt(ReportBuilder::FOR_EXERCISES)) {
			$forExercisesInString = implode(",", $forExercises);
			$this->selectBuilder->addWhere("s.F_ExerciseID IN ($forExercisesInString)");
		}
		
		// For idObjects (e.g. CourseID=? AND UnitID=? AND ExerciseID=?)
		if ($idObjects = $this->getOpt(ReportBuilder::FOR_IDOBJECTS)) {
			$titleReport = !isset($idObjects[0]["Unit"]) ? true : false;
			$exerciseReport = isset($idObjects[0]["Exercise"]) ? true : false;
			//print_r($idObjects);
			// v3.5 If I only have course objects, then I want to make a simple list rather than a whole set of individual clauses
			// Except that you don't come in here if you are doing a course report.
			// So what I want to do is set it for title reports which send title AND course.
			// Is this a title report?
			if ($titleReport) {
				$wheres = array();
				foreach ($idObjects as $idObject) {
					$wheres[] = $idObject["Course"];
				}
				$this->selectBuilder->addWhere("s.F_CourseID IN (".implode(',', $wheres).")");
			} else {
				foreach ($idObjects as $idObject) {
					$wheres = array();
					foreach ($idObject as $class => $id) {
						//echo "$class=$id";
						switch ($class) {
							case "Title":
								break;
							case "Course":
								// v3.4 This could be read from s.F_CourseID if I want session to be by product not course
								//$wheres[] = "ss.F_CourseID=".$id;
								$wheres[] = "s.F_CourseID=".$id;
								break;
							// Likewise, if this is an exercise report I want to drop the unit clause as entirely unnecessary
							// It would be good if I could rely on exerciseID to be absolutely unique across courses, then
							// I could just make it a simple list. Things like certificates don't count anyway.
							// Even so, there are some 750 exercises listed in T_Score that are associated with more than 1 course.
							// Let's hope it doesn't matter! Exercise reports are quite rare I would think, but surely even
							// rarer across different titles...
							case "Unit":
								if (!$exerciseReport) {
									$wheres[] = "s.F_UnitID=".$id;
								}
								break;
							case "Exercise":
								$wheres[] = "s.F_ExerciseID=".$id;
								break;
							default:
								throw new Exception("Unknown id object ".$class);
						}
					}
					// Passing true as a parameter to addWhere marks these as OR clauses instead of the default AND
					//gh#28
					$this->selectBuilder->addWhere("(".implode(" AND ", $wheres).")", true);
				}
				
			}
		}
		// v3.0.4 If you want special ordering
		if ($this->getOpt(ReportBuilder::ORDERBY_USERS)) $this->selectBuilder->addOrder('s.F_UserID');
		if ($this->getOpt(ReportBuilder::ORDERBY_UNIT)) $this->selectBuilder->addOrder('s.F_UnitID');
		
		// v3.4 Get last session results first
		if ($this->getOpt(ReportBuilder::SHOW_SESSIONID)) $this->selectBuilder->addOrder('s.F_SessionID', 'DESC');
		
		// AR To only pick up results for learners - ignore teachers etc
		$this->selectBuilder->addWhere("u.F_UserType=".USER::USER_TYPE_STUDENT);
		
		return $this->selectBuilder->toSQL();
	}
	// v3.4 If you want to write a report that shows students who have done NOTHING, here is the starting SQL
	/*
		SELECT ci.F_ProductCode productCode,ci.F_CourseID courseID,g.F_GroupName groupName,u.F_UserName userName,
		0 average_score, 0 complete, 0 average_time, 0 total_time 
		FROM T_CourseInfo ci, T_User u 
		INNER JOIN T_Membership m ON u.F_UserID=m.F_UserID 
		INNER JOIN T_Groupstructure g on g.F_GroupID = m.F_GroupID 
		WHERE NOT EXISTS (SELECT * FROM T_Score es
						WHERE es.F_UserID = u.F_UserID
						AND es.F_CourseID IN (1189057932446) )
		AND g.F_GroupID IN (21560,10379) 
		AND ci.F_CourseID IN (1189057932446) 
		AND u.F_UserType=0 
		GROUP BY ci.F_ProductCode,ci.F_CourseID,g.F_GroupName,u.F_UserName 
		ORDER BY ci.F_ProductCode,ci.F_CourseID,g.F_GroupName,u.F_UserName 
	*/
		
	// v3.4 A new function for getting score details into a report
	function buildDetailReportSQL() {
		$this->selectBuilder = new SelectBuilder();
		
		$attempts = $this->getOpt(ReportBuilder::ATTEMPTS);
		$forUsers = $this->getOpt(ReportBuilder::FOR_USERS);
		$fromClause = <<<EOD
						T_ScoreDetail s
						INNER JOIN T_User u ON s.F_UserID=u.F_UserID
						INNER JOIN T_Membership m ON s.F_UserID=m.F_UserID
						INNER JOIN T_Groupstructure g on g.F_GroupID = m.F_GroupID
						INNER JOIN T_Session ss ON s.F_SessionID=ss.F_SessionID
EOD;
		$this->selectBuilder->setFrom($fromClause);
		
		// v3.4 Attempts forms such a terrible sql statement. For this it would be better to 
		// base it on max or min sessionID since you can't have multiple exercise attempts in one session.
		if ($this->getOpt(ReportBuilder::SHOW_SESSIONID)) $this->addColumn("s.F_SessionID", "sessionID");
		
		// Selection of common columns
		// v3.4 To allow productCode to be sent back too. Put it first to help sorting the returned results if grouped.
		// gh#797
		if ($this->getOpt(ReportBuilder::SHOW_COURSE) || $this->getOpt(ReportBuilder::SHOW_TITLE)) $this->addColumn("ss.F_ProductCode", "productCode");		
		if ($this->getOpt(ReportBuilder::SHOW_UNIT)) $this->addColumn("s.F_UnitID", "unitID");
		if ($this->getOpt(ReportBuilder::SHOW_EXERCISE)) $this->addColumn("s.F_ExerciseID", "exerciseID");
		// v3.4 Detail report columns
		$this->addColumn("s.F_ItemID", "itemID");
		$this->addColumn("s.F_Score", "score");
		$this->addColumn("s.F_Detail", "detail");
		
		// Selection of name columns
		if ($this->getOpt(ReportBuilder::SHOW_GROUPNAME)) $this->addColumn("g.F_GroupName", "groupName");
		if ($this->getOpt(ReportBuilder::SHOW_USERNAME)) $this->addColumn("u.F_UserName", "userName");
		if ($this->getOpt(ReportBuilder::SHOW_STUDENTID)) $this->addColumn("u.F_StudentID", "studentID");
		if ($this->getOpt(ReportBuilder::SHOW_EMAIL)) $this->addColumn("u.F_Email", "email");
		
		// Selection of ungrouped columns
		if ($this->getOpt(ReportBuilder::SHOW_SCORE)) { $this->checkGrouped(false); $this->addColumn(null, "score", "CASE s.F_Score WHEN -1 THEN NULL ELSE s.F_Score END"); }
		
		// From date
		if ($fromDate = $this->getOpt(ReportBuilder::FROM_DATE)) {
			// Ticket #95 - the FROM_DATE is already an ANSI string
			//$dateStamp = ClarityService::_dateToDB($this->db, $fromDate);
			// Ticket #117
			$dateStamp = $fromDate;
			//$this->selectBuilder->addWhere("s.F_DateStamp >= '".$dateStamp."'");
			// v3.3 MySQL Conversion
			//$this->selectBuilder->addWhere("s.F_DateStamp >= CONVERT(datetime, '".$dateStamp."',120)");
			$this->selectBuilder->addWhere("s.F_DateStamp >= '$dateStamp'");
		}
		
		// To date
		if ($toDate = $this->getOpt(ReportBuilder::TO_DATE)) {
			//$dateStamp = ClarityService::_dateToDB($this->db, $toDate);
			// Ticket #95 - the FROM_DATE is already an ANSI string
			// Ticket #117
			$dateStamp = $toDate;
			//$this->selectBuilder->addWhere("s.F_DateStamp <= '".$dateStamp."'");
			// v3.3 MySQL Conversion
			//$this->selectBuilder->addWhere("s.F_DateStamp <= CONVERT(datetime, '".$dateStamp."',120)");
			$this->selectBuilder->addWhere("s.F_DateStamp <= '$dateStamp'");
		}
		
		// For specific user ids
		if ($forUsers = $this->getOpt(ReportBuilder::FOR_USERS)) {
			$forUsersInString = implode(",", $forUsers);
			//echo "forUsers=$forUsersInString";
			$this->selectBuilder->addWhere("s.F_UserID IN ($forUsersInString)");
		}
		
		// For specific group ids
		if ($forGroups = $this->getOpt(ReportBuilder::FOR_GROUPS)) {
			$forGroupsInString = implode(",", $forGroups);
			$this->selectBuilder->addWhere("g.F_GroupID IN ($forGroupsInString)");
		}
		
		// For specific unit ids
		if ($forUnits = $this->getOpt(ReportBuilder::FOR_UNITS)) {
			$forUnitsInString = implode(",", $forUnits);
			$this->selectBuilder->addWhere("s.F_UnitID IN ($forUnitsInString)");
		}
		
		// For specific exercise ids
		if ($forExercises = $this->getOpt(ReportBuilder::FOR_EXERCISES)) {
			$forExercisesInString = implode(",", $forExercises);
			$this->selectBuilder->addWhere("s.F_ExerciseID IN ($forExercisesInString)");
		}
		
		// For idobjects (e.g. CourseID=? AND UnitID=? AND ExerciseID=?)
		if ($idObjects = $this->getOpt(ReportBuilder::FOR_IDOBJECTS)) {
			//print_r($idObjects);
			foreach ($idObjects as $idObject) {
				//print_r($idObject);
				$wheres = array();
				foreach ($idObject as $class => $id) {
					//echo "$class=$id";
					switch ($class) {
						case "Title":
						case "Course":
							break;
						case "Unit":
							$wheres[] = "s.F_UnitID=".$id;
							break;
						case "Exercise":
							$wheres[] = "s.F_ExerciseID=".$id;
							break;
						default:
							throw new Exception("Unknown id object ".$class);
					}
				}
				
				// Passing true as a parameter or addWhere marks these as OR clauses instead of the default AND
				$this->selectBuilder->addWhere("(".implode(" AND ", $wheres).")", true);
			}
		}
		// v3.0.4 If you want special ordering
		if ($this->getOpt(ReportBuilder::ORDERBY_USERS)) $this->selectBuilder->addOrder('s.F_UserID');
		if ($this->getOpt(ReportBuilder::ORDERBY_UNIT)) $this->selectBuilder->addOrder('s.F_UnitID');
		// v3.4 Get last session results first
		if ($this->getOpt(ReportBuilder::SHOW_SESSIONID)) $this->selectBuilder->addOrder('s.F_SessionID', 'DESC');
		
		// AR To only pick up results for learners - ignore teachers etc
		$this->selectBuilder->addWhere("u.F_UserType=".USER::USER_TYPE_STUDENT);
		
		return $this->selectBuilder->toSQL();
	}

	// gh#777 Used to copy any missing fields from one array to another, setting the value to empty
	public function createBlankRow($user, $template, $copyFields) {
		foreach ($template as $key => $value) {
			if (!array_key_exists($key, $user))
				// if this field is one that you want copied, take the value
				// TODO. You only want to copy the value if there is just one of this type in the report
				// ie. one course or one unit. Otherwise just put a placeholder in
				if (array_key_exists($key, $copyFields)) {
					$temp = $copyFields[$key];
					if ((string)$copyFields[$key] == 'value') {
						$user[$key] = $value;
					} else {
						$user[$key] = $copyFields[$key];
					}
				} elseif (stristr('courseID|total_time|average_time|completed', $key)) {
					$user[$key] = 0;
				} else {
					$user[$key] = null;
				}
		}
		return $user;
	}
}
