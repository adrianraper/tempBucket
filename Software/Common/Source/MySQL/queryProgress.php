<?php

function getRMSettings( &$vars, &$node ){
	global $Db;
	global $Progress;
	
	$rC = $Progress->selectAdmin( $vars );
	
	if ($Db->num_rows > 0) {
		$node .= "<settings loginOption='" .$Db->result[0]["F_LoginOption"] . "' 
			verified='" .$Db->result[0]["F_Verified"] ."' 
			selfRegister='" .$Db->result[0]["F_SelfRegister"] ."'/>";
	} else {
		// the default setting is no self-register + password
		$node .= "<settings loginOption='1' verified='0' selfRegister='0' />";
	};	

	// v6.3.5 run the encryption key query
	$rC = $Progress->selectEKey( $vars );
	if ($Db->num_rows > 0) {
		$node .= "<decrypt key='" .$Db->result[0]["F_KeyBase"] . "' />";
	} else {
		$node .= "<decrypt key='undefined' />";
	}
	return 0;
}
function getScores( &$vars, &$node ) {
	global $Db;
	global $Progress;

	$rC = $Progress->selectScores( $vars );
	
	if ($Db->num_rows > 0)  {
		foreach($Db->result as $row) {
			$node .= "<score datestamp='{$row[F_DateStamp]}' ";

			// v6.5 Always send this back
			//if ($vars['USERID'] == 1) 
			//	$node .=  "userID='{$row[thisUserID]}' ";
				$node .=  "userID='{$vars[USERID]}' ";

			//v6.3.4 Send back the new field for test units if it is there
			//v6.4.3 Do it anyway, not based on unitID
			//if ($row[F_UnitID] < 0 ) 
				$node .=  "testUnits='{$row[F_TestUnits]}' ";

		//v6.3.6 Do not worry about 'e' in the itemID, it will either be there or not be there.
		// and orchid can cope with either
		//	$node .= "itemID='e{$row[F_ExerciseID]}' "
			$node .= "itemID='{$row[F_ExerciseID]}' "
				."unit='{$row[F_UnitID]}' "
				."score='{$row[F_Score]}' "
				."duration='{$row[F_Duration]}' "      
				."correct='{$row[F_ScoreCorrect]}' "
				."wrong='{$row[F_ScoreWrong]}' "
				."skipped='{$row[F_ScoreMissed]}' />";
		}
		return 0;
	} else {
		return 1;
	}
}	
// v6.5 Note that this is NOT tested yet
function getAllScores( &$vars, &$node ) {
	global $Db;
	global $Progress;

	// The first recordset gets all attempts at exercises
	//$rC = $Progress->selectAllViews( $vars );
	
	// Then we need another that just picks up the scored ones
	$rC = $Progress->selectAllScores( $vars );
	
	if ($Db->num_rows > 0)  {
		foreach($Db->result as $row) {
			$thisScore = $row[AvgScore];
			$thisCount = $row[NumberDone];
			$node .= "<score itemID='{$row[F_ExerciseID]}' "
				."unit='{$row[F_UnitID]}' "
				."score='{$thisScore}' "
				."count='{$thisCount}' />";
		}
		return 0;
	} else {
		return 1;
	}
}	
function getUser( &$vars, &$node ) {
	global $Db;
	global $Progress;
	// if this is an anonymous login, allow it as the program will have already
	// validated that this was allowed
	if ($vars['NAME'] == "" && $vars['STUDENTID'] == "") {
		$node .= "<user name=\"\" userID=\"-1\"/>";
		return 0;
	}

	// v6.3.4 StudentID can be used as well as/or name
	if ($vars['NAME'] <> "") {
		$searchType = "name";
		if ($vars['STUDENTID'] <> "") {
			$searchType = "both";
		}
	} else {
		if ($vars['STUDENTID'] <> "") {
			$searchType = "id";
		}
	}
	
	// Validate user/password
	$Progress->selectUser( $vars, $searchType );
	if ($Db->num_rows < 1) {
		// v6.3.4 Need to know which error to send back
		if ($searchType == "id") {
		    $node .= "<err code=\"206\">no such id</err>";
		} else {
		    $node .= "<err code=\"203\">no such user</err>";
		}
		return 1;            
	} 
    
	$pass = $Db->dbPrepare($vars['PASSWORD']);
        foreach($Db->result as $record) {
		// v6.3.4 null password (sent from APO) means don't check it
		if ($record['F_Password'] != $pass && $pass != "$!null_!$") {
			$node .= "<err code=\"204\">Password does not match</err>";
			return 1;
		}
	}

	// build user info
	$node .= "<user name=\"" . $record["F_UserName"] . "\" " . 
		"userID=\"" .       $record["F_UserID"] . "\" " . 
		"userSettings=\"" . $record["F_UserSettings"] . "\" " . 
		"country=\"" .      $record["F_Country"] . "\" " . 
		"email=\"" .        $record["F_Email"] . "\" " . 
		//v6.3.6 Add userType (separate teacher and student)
		"userType=\"" .        $record["F_UserType"] . "\" " . 
		//"className=\"" .    $record["F_Class"] . "\" " . 
		"studentID=\"" .    $record["F_StudentID"] .  "\" />";
	
	$vars['USERID'] = $record["F_UserID"];
	return 0;
}
// v6.4.4 MGS
function getMGS( &$vars, &$node ) {
	global $Db;
	global $Progress;
	
	// $Progress->selectMGS( $vars , $node);
	$Progress->selectGroup( $vars );
	if ($Db->num_rows < 1) {
		$node .= "<MGS enabled=\"false\" />";
	} else {
		$gid = $Db->result[0]['F_GroupID'];
		//print "got groupID=" .$gid;
		getMGSFromHierarchy( $gid, $node );
	}
	return 0;
}
// v6.4.4 MGS
function getMGSFromHierarchy( &$gid, &$node ) {
	//print "check groupID=" .$gid;
	global $Db;
	global $Progress;
	// The following call may fail if you don't have the MGS fields in the database. Make sure it is not catastrophic.
	$Progress->getMGSFromGroup( $gid );
	// Does this group have an enabled MGS?
	if ($Db->num_rows > 0) {
		//print "got MGS row";
		if ($Db->result[0]['F_EnableMGS']=='0') {
			//print "but MGS disabled";
			// recursive to check it's parent Group has MGS enable or not
			// But don't recurse if the parent groupID is the same as this groupId as it means you are at the root
			$parentGroupID = $Db->result[0]['F_GroupParent'];
			if ($parentGroupID == $gid) {
				$node .= "<MGS enabled=\"false\" />";
				return 0;
			} else {
				getMGSFromHierarchy($parentGroupID , $node );
			}
		} else {
			//print "so add node with " .$Db->result[0]["F_MGSName"];
			$node .= "<MGS enabled=\"true\" name=\"" .$Db->result[0]["F_MGSName"] . "\" />";
			return 0;
		}
	} else {
		//print "no data for this group";
		// this should be impossible as it means the group doesn't exist
		$node .= "<MGS enabled=\"false\" />";
		return 1;
	}
}
function getUsers( &$vars, &$node ) {
	global $Db;
	global $Progress;
	
	// Validate user/password
	$Progress->selectUsers( $vars );
	if ($Db->num_rows < 1) {
	    $node .= "<note>No users in this database</note>";
	    return 1;            
	} 
    
	// v6.3.6 Return userType to catch just students
        foreach($Db->result as $record) {
		// build user info
		$node .= "<user id=\"" .$record["F_UserID"] ."\" " . 
			"userType=\"" . $record["F_UserType"] ."\" " . 
			"name=\"" . $record["F_UserName"] ."\" />";
	}
	return 0;
}
function getScratchPad( &$vars, &$node ) {
	global $Db;
	global $Progress;
	$spText = $Progress->selectScratchPad( $vars );
        if ($Db->num_rows > 0) {
		$node .= "<scratchPad><![CDATA[" . $spText . "]]></scratchPad>";
	} else {
		$node .= "<err code='203'>no such user</err>";
		return 1;
	}
	return 0;
}
function setScratchPad( &$vars, &$node ) {
	global $Db;
	global $Progress;
	$rC = $Progress->updateScratchPad( $vars  );
	//print 'db=' .$Db->affected_rows;
	if ($Db->affected_rows > 0) {
		$node .= "<scratchPad>saved</scratchPad>";
	} else {
		$node .= "<err code='205'>Your scratch pad has not been saved." . $Db->getError() ."</err>";
		return 1;
	}
	return 0;
}

function addUser( &$vars, &$node ) {
	global $Db;
	global $Progress;
	// v6.3.4 Add search type (though not used for adding)
	// v6.4.2 Also allow id or both
	//$rC = $Progress->selectUser( $vars , "name");
	if ($vars['NAME'] <> "") {
		$searchType = "name";
		if ($vars['STUDENTID'] <> "") {
			$searchType = "both";
		}
	} else {
		if ($vars['STUDENTID'] <> "") {
			$searchType = "id";
		}
	}
	// v6.4.2 Check for unique name with a new, specialised function
	//$rC = $Progress->selectUser( $vars , $searchType);
        //if ($Db->num_rows > 0) {
	//    $node .= "<err code='206'>a user with this name already exists</err>";
	//    return 1;
        //}
	$rC = $Progress->checkUniqueName( $vars, $searchType );
	if ($rC > 0) {
		$node .= "<err code='206'>a user with this name or id already exists</err>";
		return 1;
        }
	
	$rC = $Progress->insertUser( $vars );
        if ( $Db->affected_rows < 1 ) {
            $node .= "<err code='205'>user cannot be added</err>";
            return 1;
        }
	// v6.3.1 add root groupID
	$sessionID = $Progress->selectNewUser( $vars );
        if ($Db->num_rows < 1) {
            $node .= "<err code='205'>user was not added</err>";
            return 1;            
        } 

	// only expecting one record, but loop anyway
	foreach($Db->result as $record) {
		// Return user info
		$node .= "<user name=\"" . $record["F_UserName"] . "\" " . 
			"userID=\"" .       $record["F_UserID"] . "\" " . 
			"password=\"" .     $record["F_Password"] . "\" " . 
			"userSettings=\"" . $record["F_UserSettings"] . "\" " . 
			"country=\"" .      $record["F_Country"] . "\" " . 
			"email=\"" .        $record["F_Email"] . "\" " . 
			//"className=\"" .    $record["F_Class"] . "\" " . 
			"studentID=\"" .    $record["F_StudentID"] .  "\" />";
		$vars['USERID'] = $record["F_UserID"];
	}
	$rC = $Progress->insertMembership( $vars );
        if ( $Db->affected_rows < 1 ) {
            $node .= "<err code='205'>membership record not added</err>";
            return 1;
        }
	return 0;
}
function insertSession( &$vars, &$node ) {
	global $Db;
	global $Progress;
	//print 'in insertSession';
	//v6.4.2 pass local time from app
        //$date = $Db->now();
	//$thisCourseName = $vars['COURSENAME'];
	//$node .= "<note>coursename='$thisCourseName' </note>";

        $date = $vars['DATESTAMP'];
	$rC = $Progress->insertSession($vars, $date);
	//print 'affected_rows=' .$Db->affected_rows;
        if ( $Db->affected_rows < 1 ) {
            $node .= "<err code='205'>Your progress cannot be recorded. " . $Db->getError() ."</err>";
            return 1;
        }

	$numSessions = $Progress->	countSessions($vars);
	$sessionID = $Progress->SelectInsertedSessionID($vars, $date);
        $node .= "<session id='$sessionID' count='$numSessions' starttime='$date' />";
	//$sessionID = $Db->result[0]['F_SessionID'];
	//$cname=$Db->result[0]['F_CourseName'];
	//$node .= "<session id='$sessionID' count='$numSessions' starttime='$date' coursename='$cname' />";
	return 0;
}

function updateSession( &$vars, &$node ) {
	global $Db;
	global $Progress;
	//v6.4.2 pass local time from app
        //$date = $Db->now();
        $date = $vars['DATESTAMP'];
	$rC = $Progress->updateSession($vars, $date);
	// Verify the query
	if ($Db->affected_rows > 0) {
		$node .= "<session>updated</session>";
	} else {
		$node .= "<err code='205'>your session is not being updated</err>";
		return 1;
	}
	return 0;
}
function insertScore( &$vars, &$node ) {
	global $Db;
	global $Progress;
	//v6.4.2 pass local time from app
        //$date = $Db->now();
        $date = $vars['DATESTAMP'];
	$rC = $Progress->insertScore($vars, $date);
	// Verify the query
	if ($Db->affected_rows > 0) {
		$node .= "<score status='true' />";
	} else {
		$node .= "<err code='205'>your progress is not being recorded " . $Db->getError() . "</err>";
		return 1;
	}   
	return 0;
}
// v6.3.2 Code for counting registered users
function countUsers( &$vars, &$node ) {
	global $Db;
	global $Progress;

	$count = $Progress->countUsers($vars);
	if ($count > 0) {
		$node .= "<licence users='$count' />";
	} else {
		$node .= "<err code='208'>technical problem:users table</err>";
		return 1;
	}   
	return 0;
}

// v6.5 For certificate
function getGeneralStats( &$vars, &$node ) {
	global $Db;
	global $Progress;

	$rC = $Progress->getScoredStats( $vars );

	// add up the exercise scores to get totals
	$countScored=0;
	$countUnScored=0;
	$totalScore=0;
	$totalCorrect=0;
	$duplicates=0;
	$avgScored=0;
	$dupScored=0;
	$dupUnScored=0;
	if ($Db->num_rows > 0)  {
		foreach($Db->result as $row) {
			//$node .= "<row maxScore='$row[maxScore]' totalScore='$row[totalScore]' cntScore='$row[cntScore]' />";
			$countScored++;
			$totalScore += $row["maxScore"];
			$totalCorrect += $row["totalScore"];
			$duplicates += $row["cntScore"];
		}
	}
	if ($countScored>0) {
		$avgScored = $totalScore / $countScored;
	}
	$dupScored = $duplicates - $countScored;
	
	
	// then repeat for the unscored (viewed) ones
	$rC = $Progress->getViewedStats( $vars );

	// add up the exercise scores to get totals
	$duplicates=0;
	if ($Db->num_rows > 0)  {
		foreach($Db->result as $row) {
			//$node .= "<row cntUnScore='$row[cntScore]' />";
			$countUnScored++;
			$duplicates= $duplicates+ $row["cntScore"];
		}
	}
	$dupUnScored = $duplicates - $countUnScored;
	
	$node .= "<stats total='$totalCorrect' average='$avgScored' counted='$countScored' viewed='$countUnScored' 
			duplicatesCounted='$dupScored' duplicatesViewed='$dupUnScored' />";
	return 0;
}	

?>
