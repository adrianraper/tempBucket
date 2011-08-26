<?php
class PROGRESS {
	function PROGRESS() {
	}

	function selectAdmin( &$vars ) {
		//print 'selectAdmin';
		global $Db;
		//$node .= "<note>rootID=" .$vars['ROOTID'] ."</note>";
		// v6.3.1 Add root groupID
		//$Db->query("SELECT * FROM T_Admin");
		//$Db->query("SELECT * FROM T_Admin WHERE F_RootID=0;");
		// v6.3.4 Change table from T_Admin to T_GroupStructure
		//$Db->query("SELECT * FROM T_Admin WHERE F_RootID='{$vars[ROOTID]}';");
		// v6.4.1.4 Capitalisation
		//$Db->query("SELECT * FROM T_GroupStructure WHERE F_GroupID='{$vars[ROOTID]}';");
		$Db->query("SELECT * FROM T_Groupstructure WHERE F_GroupID='{$vars['ROOTID']}';");
		return 0;
	}
	//v6.3.5 Encryption key
	function selectEKey( &$vars ) {
		global $Db;
		// v6.4.1.4 Capitalisation
		//$Db->query("SELECT F_KeyBase FROM T_EncryptKey WHERE F_KeyID='{$vars[EKEY]}';");
		$Db->query("SELECT F_KeyBase FROM T_Encryptkey WHERE F_KeyID='{$vars['EKEY']}';");
		return 0;
	}

	// v6.3.5 Session table now has courseID not courseName
				//AND (T_Session.F_CourseName='" .$vars['COURSENAME'] ."')) 
				//AND T_Session.F_CourseName='" .$vars['COURSENAME'] ."' 
	function selectScores( &$vars ) {
		// v6.3.6 To allow RM to catch up, Orchid sends both course name and ID. Let XMLQuery determine which to use
		//based on the RM installation. So XMLQuery is an installation dependent file.
		//v6.3.6 CourseID now needs to be a double datatype (Access) or bigint (MySQL, SQLServer)
		//Clng(myQuery.CourseID)
		//v6.4.1.4 Coursename is only written for backwards compatability with RM. So just focus on courseID
		global $Db;
		//if ($vars['USECOURSENAME'] == "true") {
		//	if ($vars['USERID'] == 1) {
		//		$sql = "SELECT T_Score.*, T_User.F_UserID AS thisUserID FROM T_Score, T_Session, T_User 
		//			WHERE ((T_Score.F_SessionID=T_Session.F_SessionID) 
		//			AND (T_Score.F_UserID=T_User.F_UserID) 
		//			AND (T_Session.F_CourseName='" .$vars['COURSENAME'] ."')) 
		//			ORDER BY T_User.F_UserID;";
		//	} else {
		//		$sql = "SELECT T_Score.* FROM T_Score, T_Session 
		//			WHERE T_Score.F_UserID=" .$vars['USERID'] ." AND T_Score.F_SessionID=T_Session.F_SessionID 
		//			AND T_Session.F_CourseName='" .$vars['COURSENAME'] ."' 
		//			ORDER BY T_Score.F_DateStamp;";
		//	}
		//} else {
		// v6.5 Always use userID
		//	if ($vars['USERID'] == 1) {
		//		$sql = "SELECT T_Score.*, T_User.F_UserID AS thisUserID FROM T_Score, T_Session, T_User 
		//			WHERE ((T_Score.F_SessionID=T_Session.F_SessionID) 
		//			AND (T_Score.F_UserID=T_User.F_UserID) 
		//			AND (T_Session.F_CourseID=" .$vars['COURSEID'] .")) 
		//			ORDER BY T_User.F_UserID;";
		//	} else {
				$sql = "SELECT T_Score.* FROM T_Score, T_Session 
					WHERE T_Score.F_UserID=" .$vars['USERID'] ." 
					AND T_Score.F_SessionID=T_Session.F_SessionID 
					AND T_Session.F_CourseID=" .$vars['COURSEID'] ." 
					ORDER BY T_Score.F_DateStamp;";
		//	}
		//}
		$Db->query($sql);
		return 0;
	}
	// v6.5 Add for everyone's score
	function selectAllScores( &$vars ) {
		// v6.4.2.8 Average (and count) for all scores for each exercise. Used for comparison against the individual
		// so exclude this user from the counting - and exclude non-scored exercises
		// Pass the rootID or the groupID to narrow the range
		global $Db;
			$sql = "SELECT SC.F_ExerciseID, SC.F_UnitID, AVG(SC.F_Score) AS AvgScore, COUNT(SC.F_Score) AS NumberDone  
				FROM T_Score as SC, T_Session as SE, T_Membership as M 
				WHERE SE.F_UserID=M.F_UserID
				AND SE.F_UserID<>" .$vars['USERID'] ."
				AND SE.F_CourseID=" .$vars['COURSEID'] ." 
				AND SC.F_Score>=0 
				AND M.F_RootID=" .$vars['ROOTID'] ."
				AND SC.F_SessionID=SE.F_SessionID
				GROUP BY SC.F_ExerciseID, SC.F_UnitID
				ORDER BY SC.F_ExerciseID;";
		//	}
		//}
		$Db->query($sql);
		return 0;
	}
	function selectAllViews( &$vars ) {
		// v6.4.2.8 Average (and count) for all scores for each exercise. Used for comparison against the individual
		// so exclude this user from the counting - and exclude non-scored exercises
		// Pass the rootID or the groupID to narrow the range
		global $Db;
			$sql = "SELECT SC.F_ExerciseID, SC.F_UnitID, COUNT(SC.F_Score) AS NumberDone  
				FROM T_Score as SC, T_Session as SE, T_Membership as M 
				WHERE SE.F_UserID=M.F_UserID
				AND SE.F_UserID<>" .$vars['USERID'] ."
				AND SE.F_CourseID=" .$vars['COURSEID'] ." 
				AND M.F_RootID=" .$vars['ROOTID'] ."
				AND SC.F_SessionID=SE.F_SessionID
				GROUP BY SC.F_ExerciseID, SC.F_UnitID
				ORDER BY SC.F_ExerciseID;";
		$Db->query($sql);
		return 0;
	}
	function selectUser ( &$vars , $searchType) {
		global $Db;

		//v6.3.4 Add login by studentID as well
		// Prepare strings
		// v6.4.2.7 Let username be case insensitive - it seems that MySQL and PHP make it case sensitive by default
		//$name = $Db->dbPrepare($vars['NAME']);
		$name = strtoupper($Db->dbPrepare($vars['NAME']));
		//$studentID = $Db->dbPrepare($vars['STUDENTID']);
		$studentID = strtoupper($Db->dbPrepare($vars['STUDENTID']));
		// v6.3.1 Add root groupID
		//$Db->query("SELECT * FROM T_User WHERE F_UserName='$name';");
		if ($searchType == "name") {
			// v6.4.2.7 Let username be case insensitive - it seems that MySQL and PHP make it case sensitive by default
			//$whereClause = "WHERE T_User.F_UserName='$name'";
			$whereClause = "WHERE UCASE(T_User.F_UserName)='$name'";
		} else {
			if ($searchType == "both") {
				$whereClause = "WHERE UCASE(T_User.F_UserName)='$name' AND UCASE(T_User.F_StudentID)='$studentID'";
			} else {
				$whereClause = "WHERE UCASE(T_User.F_StudentID)='$studentID'";
			}
		}

		//		WHERE F_UserName='$name' 
		$Db->query("SELECT T_User.* FROM T_User, T_Membership 
				$whereClause 
				AND T_User.F_UserID = T_Membership.F_UserID 
				AND T_Membership.F_RootID='{$vars['ROOTID']}';");
		return 0;	
	}
	// v6.4.2 New function for checking if this username or studentID is unique
	// This function will be overridden by the contents of the include file if it exists
	// the purpose being to let anything running ClarityEnglish to use more complex, cross db checking
	function checkUniqueName ( &$vars , $searchType) {
		global $Db;
		// v6.4.2.7 Let username be case insensitive - it seems that MySQL and PHP make it case sensitive by default
		//$name = $Db->dbPrepare($vars['NAME']);
		$name = strtoupper($Db->dbPrepare($vars['NAME']));
		//$studentID = $Db->dbPrepare($vars['STUDENTID']);
		$studentID = strtoupper($Db->dbPrepare($vars['STUDENTID']));
		if ($searchType == "name") {
			// v6.4.2.7 Let username be case insensitive - it seems that MySQL and PHP make it case sensitive by default
			//$whereClause = "WHERE T_User.F_UserName='$name'";
			$whereClause = "WHERE UCASE(T_User.F_UserName)='$name'";
		} else {
			// v6.4.2 If you are adding both, then neither of them should be present
			if ($searchType == "both") {
				$whereClause = "WHERE UCASE(T_User.F_UserName)='$name' OR UCASE(T_User.F_StudentID)='$studentID'";
			} else {
				$whereClause = "WHERE UCASE(T_User.F_StudentID)='$studentID'";
			}
		}
		$Db->query("SELECT T_User.* FROM T_User, T_Membership 
				$whereClause 
				AND T_User.F_UserID = T_Membership.F_UserID 
				AND T_Membership.F_RootID='{$vars['ROOTID']}';");
		if ($Db->num_rows>0) {
			return 1;
		} else {
			return 0;
		}
	}
	// v6.4.4 MGS get the user's group
	function selectGroup ( &$vars ) {
		global $Db;
		// Prepare strings
		$userID = $Db->dbPrepare($vars['USERID']);
		//print "selectGroup for " .$userID;
		
		// First get the user's groupID
		$Db->query("SELECT T_Groupstructure.F_GroupID FROM T_Groupstructure, T_Membership, T_User 
					WHERE T_User.F_UserID=\"".$userID."\" 
					AND T_User.F_UserID=T_Membership.F_UserID 
					AND T_Membership.F_GroupID=T_Groupstructure.F_GroupID");
		return 0;
	}
	// v6.4.4 MGS pick up from the group, or recursively to parents
	// Note, unlike Rickson's code - I can't recurse here as I don't see how to call another method in this class.
	
	// v6.4.4 MGS from a group
	function getMGSFromGroup ( &$gid ) {
		global $Db;
		//print "getMGSFromGroup for " .$gid;
		// You have to be prepared for this SQL to fail if you are running against an old DB that doesn't have MGS
		$Db->query("SELECT F_GroupID, F_EnableMGS, F_MGSName, F_GroupParent FROM T_Groupstructure 
					WHERE F_GroupID=".$gid);
		return 0;
	}
	
	//v6.3.1 Add root groupID
	function selectNewUser ( &$vars ) {
		global $Db;

		// Prepare strings
		// v6.4.2.7 Let username be case insensitive - it seems that MySQL and PHP make it case sensitive by default
		//$name = $Db->dbPrepare($vars['NAME']);
		$name = strtoupper($Db->dbPrepare($vars['NAME']));
		$Db->query("SELECT MAX(F_UserID) AS uid FROM T_User WHERE UCASE(F_UserName)='$name';");
		$newID = $Db->result[0]['uid'];
		$Db->query("SELECT * FROM T_User WHERE F_UserID='$newID';");
		return 0;
	}
	function selectUsers ( &$vars ) {
		global $Db;

		// v6.3.1 Add root groupID
		//$Db->query("SELECT F_UserID, F_UserName FROM T_User;");
		//v6.3.6 Also return userType
		//$Db->query("SELECT T_User.F_UserID, F_UserName
		$Db->query("SELECT T_User.F_UserID, F_UserName, F_UserType
				FROM T_User, T_Membership 
				WHERE T_User.F_UserID = T_Membership.F_UserID 
				AND F_RootID='{$vars['ROOTID']}';");
		return 0;	
	}
	function insertUser( &$vars ) {
		global $Db;		
		$name = $Db->dbPrepare($vars['NAME']);
		$Db->query("INSERT INTO T_User (F_UserName, F_Password, F_StudentID, F_Country, F_Email) 
			VALUES ('" . $name . "', '"
			. $vars['PASSWORD'] . "', '"
			. $vars['STUDENTID'] . "', '"
			//. $vars['CLASSNAME'] . "', '"
			. $vars['COUNTRY'] . "', '"
			. $vars['EMAIL'] ."');");
		return 0;
	}
	//v6.3.1 Add root groupID
	function insertMembership( &$vars ) {
		global $Db;
		$Db->query("INSERT INTO T_Membership (F_UserID, F_GroupID, F_RootID)
				VALUES ( '{$vars['USERID']}', '{$vars['ROOTID']}', '{$vars['ROOTID']}');");
		return 0;
	}
	function selectScratchPad ( &$vars ) {
		global $Db;
		$Db->query("SELECT F_ScratchPad FROM T_User WHERE F_UserId='{$vars['USERID']}'");
		return $Db->result[0]['F_ScratchPad'];
	}
	function updateScratchPad ( &$vars ) {
		global $Db;
		$pad = $Db->dbPrepare($vars['SENTDATA']);
		//print 'pad=' .$pad .' for user=' .$vars[USERID];
		$Db->query("UPDATE T_User SET F_ScratchPad='$pad' WHERE F_UserId='{$vars['USERID']}'");
		return 0;
	}
	//v6.3.5 Session table holds courseID not courseName
	function insertSession ( &$vars, $date ) {
		//print 'insertSession';
		global $Db;
		//v6.4.2 Use new escaping functions to cope with unicode - remember to decode on retrieval!
		//$cname  = $Db->dbPrepare($vars['COURSENAME']);
		//v6.4.2 But this is now done in Flash
		//$cname  = $Db->asc2hex($vars['COURSENAME']);
		$cname  = $vars['COURSENAME'];
		$cid  = $vars['COURSEID'];
		$uid = $vars['USERID'];
		// v6.5 Add rootID to the session record - not implemented yet
		$rootid = $vars['ROOTID'];

		// Insert a new session
		//$Db->query("INSERT INTO T_Session (F_UserID, F_CourseName, F_StartDateStamp)
		//	    VALUES ('$uid', '$cname', '$date');");
		// v6.3.6 To allow RM to catch up, Orchid sends both course name and ID. Let XMLQuery determine which to use
		// based on the RM installation. So XMLQuery is an installation dependent file.
		//v6.3.6 F_CourseID converted from longint to double (Access), bigint (MySQL and SQLServer)
		//Clng(myQuery.CourseID)
		//v6.4.2 For now, keep recording courseName even though RM doesn't use it so that we can
		// use archive reporting at a later date (if courseID has disappeared from course.xml)
		// This makes it very important to allow ANY kind of characters to be written to coursename
		// as unicode names will be used (and apostrophes)
		//if ($vars['USECOURSENAME'] == "true") {
			// v6.5 Add in rootID. No, don't implement this yet, until you can be sure the database has the field
			$Db->query("INSERT INTO T_Session (F_UserID, F_CourseName, F_CourseID, F_StartDateStamp)
				VALUES ('$uid', '$cname', '$cid', '$date');");
			//$Db->query("INSERT INTO T_Session (F_UserID, F_RootID, F_CourseName, F_CourseID, F_StartDateStamp)
			//	VALUES ('$uid', '$rootid', '$cname', '$cid', '$date');");
		//} else {
		//	$Db->query("INSERT INTO T_Session (F_UserID, F_CourseID, F_StartDateStamp)
		//		    VALUES ('$uid', '$cid', '$date');");
		//}
		return 0;
	}
	//v6.3.5 Session table holds courseID not courseName
	function countSessions ( &$vars ) {
		global $Db;
		//v6.3.5 The following line was missing, presumably led to problems??
		//$cname  = $Db->dbPrepare($vars['COURSENAME']);
		$uid  = $vars['USERID'];
		$cid  = $vars['COURSEID'];
		//print "countSessions for $cid";
		//		WHERE F_UserID='$uid' AND F_CourseName='$cname';");
		// v6.3.6 To allow RM to catch up, Orchid sends both course name and ID. Let XMLQuery determine which to use
		// based on the RM installation. So XMLQuery is an installation dependent file.
		//v6.3.6 F_CourseID converted from longint to double (Access), bigint (MySQL and SQLServer)
		//Clng(myQuery.CourseID)
		// v6.4.1.4 Should only be recording coursename for backward compatability - use courseID
		//if ($vars['USECOURSENAME'] == "true") {
		//	$Db->query("SELECT COUNT(F_UserID) AS i FROM T_Session 
		//		WHERE F_UserID='$uid' AND F_CourseName='$cname';");
		//} else {
			$Db->query("SELECT COUNT(F_UserID) AS i FROM T_Session 
				WHERE F_UserID='$uid' AND F_CourseID='$cid';");
		//}
		return $Db->result[0][i];
	}
	function selectInsertedSessionID ( &$vars, &$date ) {
		//print 'selectInsertedSessionID';
		global $Db;
		$uid  = $vars['USERID'];
		$Db->query("SELECT F_SessionID FROM T_Session 
				WHERE F_UserID='$uid' AND F_StartDateStamp='$date';");
		return $Db->result[0]['F_SessionID'];
	}
	function updateSession ( &$vars, $date ) {
		global $Db;
		$sid = $vars['SESSIONID'];
		$Db->query("UPDATE T_Session SET F_EndDateStamp='$date' 
			WHERE F_SessionID='$sid';");
		return 0;
	}
	function insertScore ( &$vars, $date ) {
		global $Db;
		// v6.3.4 New field for unit IDs used in dynamic test construction
		if ($vars['UNITID'] < 0) {
			$fieldName = "F_TestUnits";
			$valueName = $vars['TESTUNITS'];
		} else {
			$fieldName = "F_ExerciseID";
			$valueName = $vars['ITEMID'];
		}
		// Insert a new session
		//v6.3.6 F_ExerciseID converted from longint to double (Access), bigint (MySQL and SQLServer)
		$Db->query("INSERT INTO T_Score (
				F_UserID, F_DateStamp, F_UnitID, F_SessionID, 
				F_ExerciseID, F_TestUnits, 
				F_Score, F_ScoreCorrect, F_ScoreWrong, F_ScoreMissed, F_Duration
				) VALUES (
				'{$vars['USERID']}', '$date', '{$vars['UNITID']}',  '{$vars['SESSIONID']}', 
				'{$vars['ITEMID']}', '{$vars['TESTUNITS']}', 
				'{$vars['SCORE']}', '{$vars['CORRECT']}', '{$vars['WRONG']}', '{$vars['SKIPPED']}', '{$vars['DURATION']}');"
		);
		return 0;
	}
	// v6.3.2 Count the number of registered users in this root
	function countUsers ( &$vars ) {
		global $Db;
		$rootid = $vars['ROOTID'];
		$Db->query("SELECT COUNT(T_User.F_UserID) AS i FROM T_User, T_Membership 
				WHERE T_User.F_UserID = T_Membership.F_UserID AND T_Membership.F_RootID='$rootid';");
		return $Db->result[0][i];
	}
	
	// v6.5 For the certificate - exclude special exercises (assumed to be id<100)
	function getScoredStats( &$vars ) {
		global $Db;
		$userID=$vars['USERID'];
		$courseID=$vars['COURSEID'];
		$sql = "SELECT F_ExerciseID, MAX( F_Score ) AS maxScore, COUNT(F_Score) AS cntScore, MAX( F_ScoreCorrect ) AS totalScore 
				FROM T_Score, T_Session
				WHERE T_Score.F_UserID='$userID' AND T_Score.F_SessionID=T_Session.F_SessionID 
				AND T_Session.F_CourseID='$courseID'
				AND F_Score>=0
				AND T_Score.F_ExerciseID>=100
				GROUP BY F_ExerciseID;";
		$Db->query($sql);
		return 0;
	}
	function getViewedStats( &$vars ) {
		global $Db;
		$userID=$vars['USERID'];
		$courseID=$vars['COURSEID'];
		$sql = "SELECT F_ExerciseID, MAX( F_Score ) AS maxScore, COUNT(F_Score) AS cntScore, MAX( F_ScoreCorrect ) AS totalScore 
				FROM T_Score, T_Session
				WHERE T_Score.F_UserID='$userID' AND T_Score.F_SessionID=T_Session.F_SessionID 
				AND T_Session.F_CourseID='$courseID'
				AND F_Score<0
				AND T_Score.F_ExerciseID>=100
				GROUP BY F_ExerciseID;";
		$Db->query($sql);
		return 0;
	}
}
?>
