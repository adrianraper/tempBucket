<%
' v6.4.2.4 Converge Access and SQLServer versions. It seems to just be the date format that is different.
' So use the dateFormat to either put # or ' around the date.
' Progess does not use real dates, strings are sent from Orchid
' This file changes between different databases
Class DBProgress

	Private sql
	' ADO connection
	Public  Connection
	' Resulting recordset
	Public  rsResult
	
	' Conect with specified DB
	Public Function Connect()

		set Connection = server.createobject("adodb.connection")
		Connection.ConnectionString = strconn
		Connection.open
		
		' ar v2.0 Add error handling
		dim errLoop
		If Err.Number > 0 then ' this does not pick up ADO errors
			xmlNode = xmlNode & "<err code='100'>asp error " & Err.Number & " on " & strconn & "</err>"
			on error goto 0
			Connect = 1
			exit function
		else
			' an extra check based on the connection object
			If not Connection.State = adStateOpen then
				' with no errors you won't go through this loop at all
				For each errLoop in Connection.Errors
					xmlNode = xmlNode & "<err code='101'>Sorry, cannot connect to the database " & db & ". " & dbCheckErrMsg & errLoop.Description & "</err>"
					on error goto 0
					Connect = 1
					exit function
				Next
				on error goto 0
				xmlNode = xmlNode & "<err code='101'>Sorry, cannot connect to the database " & db & ".</err>"
				Connect = 1
				exit function
			end if
		end if
		set rsResult = server.createObject ("adodb.recordset")
		Connect = 0
		
	End function
    
	' Disconnect from specified DB
	Public Sub Disconnect
		' always close and tidy up at the end of the query 
		on error resume next
		rsResult.close
		set rsResult=nothing
		Connection.close
		set Connection=nothing
		on error goto 0
	End Sub
    
	Public Sub CloseRS
		rsResult.Close
	End Sub

' Specific sql queries -------------------------
	Public Sub selectAdmin(myQuery)
		'v6.3.1 Add root groupID
		'sql = "SELECT * FROM T_Admin;"
		'sql = "SELECT * FROM T_Admin WHERE F_RootID=" & CLng(myQuery.RootID) & ";"
		' v6.3.4 Change table from T_Admin to T_GroupStructure
		sql = "SELECT * FROM T_GroupStructure WHERE F_GroupID=" & CLng(myQuery.RootID) & ";"
		rsResult.Open sql, Connection
	End Sub 
	' v6.3.5 Encryption key
	Public Sub selectEKey(myQuery)
		sql = "SELECT F_KeyBase " &_
			"FROM T_EncryptKey " &_
			"WHERE F_KeyID=" & Clng(myQuery.eKey) & ";"
		rsResult.open sql, Connection
	End Sub

	' v6.3.5 Session table now has courseID not courseName
				' "AND (T_Session.F_CourseName='" & Cstr(myQuery.CourseName) & "')) " &_
				' "AND T_Session.F_CourseName='" & Cstr(myQuery.CourseName) & "' " &_
	Public Sub selectScores(myQuery)
		' v6.3 Teachers want to see everybodies score, and know their name
		' v6.3.6 To allow RM to catch up, Orchid sends both course name and ID. Let XMLQuery determine which to use
		' based on the RM installation. So XMLQuery is an installation dependent file.
		'v6.3.6 CourseID now needs to be a double datatype (Access) or bigint (MySQL, SQLServer)
		'Clng(myQuery.CourseID)
		'v6.4.2 No longer using coursename at all
		'if myQuery.UseCourseName = "true" then
		'	if myQuery.UserID = 1 then
		'		sql = "SELECT T_Score.*, T_User.F_UserID AS thisUserID FROM T_Score, T_Session, T_User " &_
		'			"WHERE ((T_Score.F_SessionID=T_Session.F_SessionID) " &_
		'			"AND (T_Score.F_UserID=T_User.F_UserID) " &_
		'			"AND (T_Session.F_CourseName='" & Cstr(myQuery.CourseName) & "')) " &_
		'			"ORDER BY T_User.F_UserID;"
		'	else		
		'		sql = "SELECT T_Score.* " &_
		'			"FROM T_Score, T_Session " &_
		'			"WHERE T_Score.F_UserID=" & Clng(myQuery.UserID) & " AND T_Score.F_SessionID=T_Session.F_SessionID " &_
		'			"AND T_Session.F_CourseName='" & Cstr(myQuery.CourseName) & "' " &_
		'			"ORDER BY T_Score.F_DateStamp;"
		'	end if
		'else
		' v6.4.2.8 This should be based on userType
		' Er no, everybody now gets simply their own records in Orchid progress
			'if myQuery.UserID = 1 then
			'if myQuery.UserType > 0 then
			'	sql = "SELECT T_Score.*, T_User.F_UserID AS thisUserID FROM T_Score, T_Session, T_User " &_
			'		"WHERE ((T_Score.F_SessionID=T_Session.F_SessionID) " &_
			'		"AND (T_Score.F_UserID=T_User.F_UserID) " &_
			'		"AND (T_Session.F_CourseID=" & myQuery.CourseID & ")) " &_
			'		"ORDER BY T_User.F_UserID;"
			'else		
				sql = "SELECT T_Score.* " &_
					"FROM T_Score, T_Session " &_
					"WHERE T_Score.F_UserID=" & Clng(myQuery.UserID) & " AND T_Score.F_SessionID=T_Session.F_SessionID " &_
					"AND T_Session.F_CourseID=" & myQuery.CourseID & " " &_
					"ORDER BY T_Score.F_DateStamp;"
			'end if
		'end if
		rsResult.Open sql, Connection
	End Sub
    
	Public Sub selectAllScores(myQuery)
		' v6.4.2.8 Average (and count) for all scores for each exercise. Used for comparison against the individual
		' so exclude this user from the counting - and exclude non-scored exercises
		' Pass the rootID or the groupID to narrow the range
			sql = "SELECT SC.F_ExerciseID, SC.F_UnitID, AVG(SC.F_Score) AS AvgScore, COUNT(SC.F_Score) AS NumberDone  " &_
				"FROM T_Score as SC, T_Session as SE, T_Membership as M " &_
				"WHERE SE.F_UserID=M.F_UserID " &_
				"AND SE.F_UserID<>" & myQuery.UserID & " " &_
				"AND SE.F_CourseID=" & myQuery.CourseID & " " &_
				"AND SC.F_Score>=0 " &_
				"AND M.F_RootID=" & myQuery.RootID & " " &_
				"AND SC.F_SessionID=SE.F_SessionID " &_
				"GROUP BY SC.F_ExerciseID, SC.F_UnitID " &_
				"ORDER BY SC.F_ExerciseID;"
			rsResult.Open sql, Connection
	End Sub
	Public Sub selectAllViews(myQuery)
		' v6.4.2.8 Count attempts at all exercises. Used for comparison against the individual
		' Pass the rootID or the groupID to narrow the range
			sql = "SELECT SC.F_ExerciseID, SC.F_UnitID, COUNT(SC.F_SessionID) AS NumberDone  " &_
				"FROM T_Score as SC, T_Session as SE, T_Membership as M " &_
				"WHERE SE.F_UserID=M.F_UserID " &_
				"AND SE.F_UserID<>" & myQuery.UserID & " " &_
				"AND SE.F_CourseID=" & myQuery.CourseID & " " &_
				"AND M.F_RootID=" & myQuery.RootID & " " &_
				"AND SC.F_SessionID=SE.F_SessionID " &_
				"GROUP BY SC.F_ExerciseID, SC.F_UnitID " &_
				"ORDER BY SC.F_ExerciseID;"
			rsResult.Open sql, Connection
	End Sub
	
	' The function will now just return 0 for unique (enough) and 1 for not
	Public Function checkUniqueName(myQuery)

		'response.write("CEUniqueName=" & CEUniqueName & " and myQuery.uniqueName=" & myQuery.uniqueName)
		' v6.4.2 use a separate function to check username so that CE.com can employ more complex checking
		' Normally you will do this based on CEUniqueName, which is installation specific, but it might be based
		' on a user setting (originally taken) from T_GroupStructure.F_LoginOption which means that this account DOESN'T use CE.com
		' but passed to here in query as uniqueName - default is 1, which means the name should be unique outside the root as well.
		' So the first check is to see if you are going to use the override function to do the checking
		if (CEUniqueName>0 AND myQuery.UniqueName=1) then
			dim rc 
			rc = CE_checkUniqueName(myQuery)
			'response.write("from CE.com, checkUniqueName=" & rc)
			if (rc > 0) then
				checkUniqueName = rc
				exit function
			end if
			
			' then you should check that the studentID (if any) is unique within the root of the current database
			if (myQuery.StudentID <> "") then
				sql = "SELECT T_User.* " &_
					" FROM T_User, T_Membership " &_
					" WHERE T_User.F_StudentID='" & CStr(myQuery.StudentID) & "'"  &_
					" AND T_User.F_UserID = T_Membership.F_UserID " &_
					" AND T_Membership.F_RootID = " & CLng(myQuery.RootID) & ";"
				Progress.rsResult.open sql, Progress.Connection
				if (Progress.rsResult.bof and Progress.rsResult.eof) then
					checkUniqueName = 0 ' myQuery.name IS unique and so is ID (if used)
				else
					checkUniqueName = 1 ' myQuery.StudentID is NOT unique
				end if
				Progress.closeRS
			end if

		else
			' Just check within this root then. Base on name and id if both are passed.
			dim whereClause
			if (myQuery.name <> "") then
				if (myQuery.studentID <> "") then
					whereClause = "WHERE (T_User.F_UserName='" & CStr(myQuery.Name) & "' OR T_User.F_StudentID='" & CStr(myQuery.StudentID) & "') "
				else 
					whereClause = "WHERE T_User.F_UserName='" & CStr(myQuery.Name) & "' "
				end if
			else 
				' v6.4.2 This is not a unique name as it is blank! Not allowed.
				checkUniqueName = 1
				exit function
			end if
			sql = "SELECT T_User.* " &_
				"FROM T_User, T_Membership " &_
				whereClause &_
				" AND T_User.F_UserID = T_Membership.F_UserID " &_
				" AND T_Membership.F_RootID=" & CLng(myQuery.RootID) & ";"
			'response.write(sql)
			rsResult.open sql, Connection
			if (rsResult.bof and rsResult.eof) then
				checkUniqueName = 0
			else
				checkUniqueName = 1
			end if
			Progress.closeRS
		end if
	end function
	
	'v6.4.1.6 Old sub stays as other places use it
	Public Sub selectUser(myQuery, searchType)
		'sql = "SELECT * " &_
		'	"FROM T_User " &_
		'	"WHERE F_UserName='" & CStr(myQuery.name) & "';"
		'v6.3.1 Add root groupID
		'v6.3.4 Add login by studentID as well
		dim whereClause
		if searchType = "name" then
			whereClause = "WHERE T_User.F_UserName='" & CStr(myQuery.Name) & "'"
		else 
			if searchType = "both" then
				whereClause = "WHERE T_User.F_UserName='" & CStr(myQuery.Name) & "' AND T_User.F_StudentID='" & CStr(myQuery.StudentID) & "'"
			else
				whereClause = "WHERE T_User.F_StudentID='" & CStr(myQuery.StudentID) & "'"
			end if
		end if
		sql = "SELECT T_User.* " &_
			"FROM T_User, T_Membership " &_
			whereClause &_
			" AND T_User.F_UserID = T_Membership.F_UserID " &_
			" AND T_Membership.F_RootID=" & CLng(myQuery.RootID) & ";"
		rsResult.open sql, Connection
		
	End Sub
	'v6.3.1 Add root groupID
	Public Sub selectNewUser(myQuery)
		sql = "SELECT MAX(F_UserID) AS uid FROM T_User " &_
			"WHERE F_UserName='" & CStr(myQuery.Name) & "';"
		rsResult.open sql, Connection
		dim newID
		newID = rsResult.fields("uid")
		rsResult.Close
		sql = "SELECT * FROM T_User WHERE F_UserID=" & CLng(newID) & ";"
		rsResult.open sql, Connection
	End Sub

	Public Sub selectUsers(myQuery)
		'v6.3.1 Add root groupID
		'sql = "SELECT F_UserID, F_UserName FROM T_User;"
		'v6.3.6 Also return userType
		'sql = "SELECT T_User.F_UserID, F_UserName " &_
		sql = "SELECT T_User.F_UserID, F_UserName, F_UserType " &_
			"FROM T_User, T_Membership " &_
			"WHERE T_User.F_UserID = T_Membership.F_UserID " &_
			" AND F_RootID=" & CLng(myQuery.RootID) & ";"
		rsResult.open sql, Connection
	End Sub
	
	Public Function selectScratchPad(myQuery)
		sql = "SELECT F_ScratchPad " &_
			"FROM T_User " &_
			"WHERE F_UserID=" & Clng(myQuery.UserID) & ";"
		rsResult.open sql, Connection
		selectScratchPad = rsResult.fields(0)
		closeRs
	End Function
        
	Public Sub updateScratchPad(myQuery)
		sql = "UPDATE T_User " &_ 
			"SET F_ScratchPad='" & CStr(myQuery.sentData) & "' " &_
			"WHERE F_UserID=" & CLng(myQuery.userID) & ";" 
		rsResult.open sql, Connection, , adLockOptimistic
	End Sub    
    
	Public Sub insertUser(myQuery)
		'v6.3.5 Add new fields, initialised, into database. UniqueName is based on licence type
		'v6.4.2 UniqueName is now based on its own field. Coming originally from F_LoginOption in T_GroupStructure and
		' then passed in the user record. The default is 1 and it is only set to 0 if the account doesn't go through CE.com
		dim uniqueName
		'if (myQuery.licenceType = "Concurrent") then
		'	uniqueName=0
		'else
		'	uniqueName=1
		'end if
		uniqueName = CInt(myQuery.uniqueName)
	
		' v6.4.2.7 F_UserSettings cannot be NULL for SQLServer database.
		'sql = "INSERT INTO T_User (F_UserName, F_Password, F_StudentID, F_Country, F_Email) " &_ 
		'	"F_AccountStatus, F_UserProfileOption, F_UserType, F_UniqueName) " &_ 
		'	"0,0,0," & uniqueName & ");" 
		sql = "INSERT INTO T_User (F_UserName, F_Password, F_StudentID, F_Country, F_Email,  " &_ 
			"F_AccountStatus, F_UserProfileOption, F_UserType, F_UniqueName, F_UserSettings) " &_ 
			"VALUES ( '" & CStr(myQuery.name) & "', " &_
			"'" & CStr(myQuery.password)  & "', " &_
			"'" & CStr(myQuery.studentID)  & "', " &_
			"'" & CStr(myQuery.country)  & "', " &_
			"'" & CStr(myQuery.email)  & "', " &_
			"0,0,0," & uniqueName & ",0);" 
		rsResult.open sql, Connection, , adLockOptimistic
	End Sub
	'v6.3.1 Add root groupID
	Public Sub insertMembership(myQuery)
		sql = "INSERT INTO T_Membership (F_UserID, F_GroupID, F_RootID) " &_ 
			"VALUES ( " & CLng(myQuery.userID) & ", " & CLng(myQuery.RootID)  & ", " & CLng(myQuery.RootID)  & ");" 
		rsResult.open sql, Connection, , adLockOptimistic
	End Sub
    
	'v6.3.5 Session table holds courseID not courseName
	Public Sub insertSession(myQuery, CurDate)
		' sql = "INSERT INTO T_Session (F_UserID, F_CourseName, F_StartDateStamp) " &_ 
		' 	"VALUES ( " & Clng(myQuery.UserID) & ", '" & CStr(myQuery.CourseName) & "', '" & CStr(CurDate) & "');" 
		' v6.3.6 To allow RM to catch up, Orchid sends both course name and ID. Let XMLQuery determine which to use
		' based on the RM installation. So XMLQuery is an installation dependent file.
		'v6.3.6 F_CourseID converted from longint to double (Access), bigint (MySQL and SQLServer)
		'Clng(myQuery.CourseID)
		'v6.4.2 No longer base anything on coursename, but DO still write to help with later archiving
		'if myQuery.UseCourseName = "true" then
			'v6.4.2 Since courseName is double escaped in Flash, need to undo it once more here.
			' Or, you could do this at the XMLQuery level - easier to apply to other variables as well
			' There are web notes that unescape was only introduced into vbscript at version 5.6. However
			' msdn notes indicate that was available, but undocumented, for much longer (since 2001). Since we
			' are not using it to decode URIs, this should be a safe call.
			' v6.5 Add in rootID. No, don't implement this yet, until you can be sure the database has the field
			dim safeCourseName
			safeCourseName = unescape(CStr(myQuery.CourseName))
			sql = "INSERT INTO T_Session (F_UserID, F_CourseName, F_CourseID, F_StartDateStamp) " &_ 
				"VALUES ( " & Clng(myQuery.UserID) & ", '" & safeCourseName & "', " & myQuery.CourseID & ", '" & CStr(CurDate) & "');" 
			'sql = "INSERT INTO T_Session (F_UserID, F_CourseName, F_CourseID, F_StartDateStamp, F_RootID) " &_ 
			'	"VALUES ( " & Clng(myQuery.UserID) & ", '" & safeCourseName & "', " & myQuery.CourseID & ", '" & CStr(CurDate) & "', " & myQuery.RootID & ");" 
		'else
		'	sql = "INSERT INTO T_Session (F_UserID, F_CourseID, F_StartDateStamp) " &_ 
		'		"VALUES ( " & Clng(myQuery.UserID) & ", " & myQuery.CourseID & ", '" & CStr(CurDate) & "');" 
		'end if
		rsResult.open sql, Connection, , adLockOptimistic
	End Sub
	'v6.3.5 Session table holds courseID not courseName
	Public Function countSessions(myQuery)
		' Count the number of sessions for this user (total across all courses or within this course?)
		'sql = "SELECT COUNT(F_UserID) FROM T_Session WHERE F_UserID=" & Clng(myQuery.UserID) &_
		'	" AND F_CourseName='" & Cstr(myQuery.courseName) & "';" 
		'sql = "SELECT COUNT(F_UserID) FROM T_Session WHERE F_UserID=" & Clng(myQuery.UserID) & ";" 
		' v6.3.6 To allow RM to catch up, Orchid sends both course name and ID. Let XMLQuery determine which to use
		' based on the RM installation. So XMLQuery is an installation dependent file.
		'v6.3.6 F_CourseID converted from longint to double (Access), bigint (MySQL and SQLServer)
		'Clng(myQuery.CourseID)
		'v6.4.2 No longer using coursename at all
		'if myQuery.UseCourseName = "true" then
		'	sql = "SELECT COUNT(F_UserID) FROM T_Session WHERE F_UserID=" & Clng(myQuery.UserID) &_
		'		" AND F_CourseName='" & Cstr(myQuery.courseName) & "';" 
		'else
			sql = "SELECT COUNT(F_UserID) FROM T_Session WHERE F_UserID=" & Clng(myQuery.UserID) &_
				" AND F_CourseID=" & myQuery.courseID & ";" 
		'end if
		rsResult.open sql, Connection
		countSessions = rsResult.fields(0)
	End Function
	Public Function selectInsertedSessionID(myQuery, CurDate)
		sql = "SELECT F_SessionID FROM T_Session WHERE F_UserID=" & CLng(myQuery.UserID) &_
			" AND F_StartDateStamp='" & CurDate & "';" 
		rsResult.open sql, Connection
		selectInsertedSessionID = rsResult.fields(0)
	End Function
	Public Sub updateSession(myQuery, CurDate)
		sql = "UPDATE T_Session " &_ 
			"SET F_EndDateStamp='" & CStr(CurDate) & "' " &_
			"WHERE F_SessionID=" & CLng(myQuery.SessionID) & ";" 
		rsResult.open sql, Connection, , adLockOptimistic
	End Sub
	   
	Public Sub insertScore(myQuery, CurDate)
		' 6.0.6.0 replace courseName with sessionID in the score table
		'sql = "INSERT INTO T_Score  (F_UserID, F_DateStamp, F_UnitID, F_ExerciseID, F_CourseName, " &_
		'	CLng(myQuery.itemID) & ", '" & CStr(myQuery.courseName) & "', " &_
		' 6.3.4 New field for unit IDs used in dynamic test construction
		'v6.3.6 F_ExerciseID converted from longint to double (Access), bigint (MySQL and SQLServer)
		' CInt(myQuery.itemID)
		' v6.4.2.4 new name - scored to score
		'	CInt(myQuery.scored) & ", " & CInt(myQuery.correct) & ", " & CInt(myQuery.wrong) & ", " & CInt(myQuery.skipped) & ", " &_
		sql = "INSERT INTO T_Score  (F_UserID, F_DateStamp, F_UnitID, F_SessionID, " &_
						"F_ExerciseID, F_TestUnits, " &_
						"F_Score, F_ScoreCorrect, F_ScoreWrong, F_ScoreMissed, F_Duration) " &_ 
			"VALUES ( " & CLng(myQuery.userID) & ", " &_
			"'" & CStr(CurDate) & "', " & CLng(myQuery.UnitID) & ", " & CLng(myQuery.sessionID) & ", " &_
			myQuery.itemID & ", '" & CStr(myQuery.testUnits) & "', " &_
			CInt(myQuery.score) & ", " & CInt(myQuery.correct) & ", " & CInt(myQuery.wrong) & ", " & CInt(myQuery.skipped) & ", " &_
			CLng(myQuery.duration) & ");"
		rsResult.open sql, Connection, , adLockOptimistic
	End Sub
	
	' v6.3.2 Count the number of registered users in this root
	Public Function countUsers(myQuery)
		' it seems we cannot do COUNT AS in Access
		sql = "SELECT COUNT(T_User.F_UserID) FROM T_User, T_Membership " &_
			"WHERE T_User.F_UserID = T_Membership.F_UserID " &_
			" AND T_Membership.F_RootID=" & CLng(myQuery.RootID) & ";"
		rsResult.open sql, Connection
		countUsers = rsResult.fields(0)
	End Function

	' v6.4.2.5 Get this user's group for MGS checking
	Public Sub selectGroup (myQuery)
		sql = "SELECT T_Groupstructure.F_GroupID FROM T_Groupstructure, T_Membership, T_User  " &_
			"WHERE T_User.F_UserID = " & CLng(myQuery.UserID) &_
			" AND T_User.F_UserID=T_Membership.F_UserID" &_ 
			" AND T_Membership.F_GroupID=T_Groupstructure.F_GroupID;"
		rsResult.open sql, Connection
	End Sub

	' v6.4.2.5 MGS pick up from the group, or recursively to parents
	Public Sub getMGSFromGroup(myQuery)
		sql = "SELECT F_GroupID, F_EnableMGS, F_MGSName, F_GroupParent FROM T_Groupstructure  " &_
			"WHERE F_GroupID = " & CLng(myQuery.GroupID) & ";"
		rsResult.open sql, Connection
	End Sub

	' v6.4.2.8 Merged from customQuery
	' Get the stats for records that have a score - take highest if same exercise done several times
	' Always exclude special exercises. 51=certificate. Maybe this will extend to anything between 50 and 100?
	' Depends a bit on older TB exercise IDs.
	Public Sub getScoredStats(myQuery)
		sql = "SELECT F_ExerciseID, MAX( F_Score ) AS maxScore, COUNT( * ) AS cntScore, MAX( F_ScoreCorrect ) AS totalScore" &_
			" FROM T_Score, T_Session " &_
			" WHERE T_Score.F_UserID =" & myQuery.UserID &_
			" AND F_Score >=0 " &_
			" AND T_Score.F_SessionID = T_Session.F_SessionID " &_
			" AND T_Session.F_CourseID=" & myQuery.CourseID &_
			" AND T_Score.F_ExerciseID>=100" &_
			" GROUP BY F_ExerciseID;"
		'response.Write sql
		rsResult.Open sql, Connection
	End Sub 
    
	' Get the stats for records that DON'T have a score - take highest if same exercise done several times
	' What do you mean highest? There is no score
	Public Sub getViewedStats(myQuery)
		sql = "SELECT F_ExerciseID, MAX( F_Score ) AS maxScore, COUNT( * ) AS cntScore " &_
			" FROM T_Score, T_Session " &_
			" WHERE T_Score.F_UserID =" & myQuery.UserID &_
			" AND F_Score < 0 " &_
			" AND T_Score.F_SessionID = T_Session.F_SessionID " &_
			" AND T_Session.F_CourseID=" & myQuery.CourseID &_
			" AND T_Score.F_ExerciseID>=100" &_
			" GROUP BY F_ExerciseID;"
		rsResult.Open sql, Connection
	End Sub 

	' Find the score for a specific exercise
	Public Sub getExerciseScore(myQuery)
		sql = "SELECT * FROM T_Score, T_Session" &_
			" WHERE T_Score.F_UserID =" & myQuery.UserID &_
			" AND T_Score.F_ExerciseID=" & myQuery.ItemID &_
			" AND T_Session.F_CourseID=" & myQuery.CourseID &_
			" AND T_Session.F_SessionID = T_Score.F_SessionID; "
		rsResult.Open sql, Connection
	End Sub 

	Public Sub getScoreDetail(myQuery)
		sql = "SELECT * FROM T_Scoredetail, T_Session" &_
			" WHERE T_Scoredetail.F_UserID =" & myQuery.UserID &_
			" AND T_Scoredetail.F_ExerciseID=" & myQuery.ItemID &_
			" AND T_Scoredetail.F_ItemID=" & myQuery.QuestionID &_
			" AND T_Session.F_CourseID=" & myQuery.CourseID &_
			" AND T_Session.F_SessionID = T_Scoredetail.F_SessionID; "
		rsResult.Open sql, Connection
	End Sub 

	Public Sub insertDetail(myQuery)
		sql = "INSERT INTO T_Scoredetail (F_UserID, F_ExerciseID, F_SessionID, F_ItemID, F_DateStamp, F_Score, F_Detail) " &_
			" VALUES (" & myQuery.userID  & ", " &_
			myQuery.itemID  & ", " &_
			myQuery.sessionID  & ", " &_
			myQuery.questionID  & ", " &_
			"'" & myQuery.dateStamp  & "', " &_
			myQuery.scored  & ", " &_
			"'" & myQuery.sentData  & "');"
		' Note: With ado you can use connection.execute and get back a 'records affected' parameter
		rsResult.open sql, Connection, , adLockOptimistic
		
	End Sub
	
	' ===============
	' CSTDI
	' ===============
	' Count the detail records that match the given parameters
	Public Sub countScoreDetails(myQuery)
		sql = "SELECT COUNT(*) as cntScore FROM T_Scoredetail " &_
			" WHERE F_ExerciseID=" & myQuery.ItemID &_
			" AND F_ItemID=" & myQuery.QuestionID &_
			" AND F_Score>=0; "
		rsResult.Open sql, Connection
	End Sub 

End Class
%>
