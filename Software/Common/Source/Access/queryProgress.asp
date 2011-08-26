<%
' this function will read the RM security settings
function getRMSettings (myQuery)
	
	' if there is no setting, then RM is not on so assume selfRegister
	'on error resume next
	Progress.selectAdmin myQuery
	
	if not Progress.rsResult.eof then
		xmlNode = xmlNode & "<settings loginOption=""" & Progress.rsResult.fields("F_LoginOption") & """ " &_ 
				"verified=""" & Progress.rsResult.fields("F_Verified") & """ " &_ 
				"selfRegister=""" & Progress.rsResult.fields("F_SelfRegister") & """ />"
	else 
		' the default setting is no self-registering, login with name only
		' v6.3.5 But why is there ANY default?
		xmlNode = xmlNode & "<settings loginOption='1' verified='0' selfRegister='0' />"
	end if
	
	Progress.CloseRS
	
	' v6.3.5 run the encryption key query
	Progress.selectEKey(myQuery)
	if not Progress.rsResult.eof then
		xmlNode = xmlNode & "<decrypt key=""" & Progress.rsResult.fields("F_KeyBase") & """ />"
	else 
		xmlNode = xmlNode & "<decrypt key='undefined' />"
	end if
	
	Progress.CloseRS
	on error goto 0
	getRMSettings = 0
	
end function
%>
<%
function getScores (myQuery)

	Progress.selectScores myQuery
	
	' put the results into an XML object
	dim buildString, scoreNode, iCount
	' v6.3.4 Send back the new field for test units if it is there
	' v6.4.3 Send back the new field for test units anyway, not based on unitID
	dim testUnitsAttr
	do while not Progress.rsResult.eof
		'returnString = "in loop looking for " & UserName
		' replace with userType
		'if myQuery.UserID = 1 then
		'if myQuery.UserType > 0 then
			'scoreNode = scoreNode + "userID=""" & Progress.rsResult.fields("thisUserID") & """ "
		'end if
		'if CLng(Progress.rsResult.fields("F_UnitID")) < 0 then
		'	testUnitsAttr = "testUnits=""" & Progress.rsResult.fields("F_TestUnits") & """ "
		'else
		'	testUnitsAttr = ""
		'end if

		'v6.3.6 Do not worry about 'e' in the itemID, it will either be there or not be there.
		' and orchid can cope with either
		'v6.3.6 F_ExerciseId might be like 2.005061E+16, so convert to a plain number (no commas, points, leading zero etc)
		'scoreNode = scoreNode + "itemID=""e" & Progress.rsResult.fields("F_ExerciseID") & """ " &_
		'			"debug=""" & "yes" & """ " &_
		scoreNode = "<score dateStamp=""" & Progress.rsResult.fields("F_DateStamp") & """ " &_
					"userID=""" & myQuery.UserID & """ " &_
					"itemID=""" & FormatNumber(Progress.rsResult.fields("F_ExerciseID"),0,0,0,0) & """ " &_
					"unit=""" & Progress.rsResult.fields("F_UnitID") & """ " &_
					"testUnits=""" & Progress.rsResult.fields("F_TestUnits") & """ " &_
					"score=""" & Progress.rsResult.fields("F_Score") & """ " &_
					"duration=""" & Progress.rsResult.fields("F_Duration") & """ " &_
					"correct=""" & Progress.rsResult.fields("F_ScoreCorrect") & """ " &_
					"wrong=""" & Progress.rsResult.fields("F_ScoreWrong") & """ " &_
					"skipped=""" & Progress.rsResult.fields("F_ScoreMissed") & """ />"
		buildString = buildString & scoreNode
'		iCount = iCount + 1
		Progress.rsResult.MoveNext
	loop
	xmlNode = xmlNode & buildString

	Progress.CloseRS
	on error goto 0
	getScores = 0
	
end function
%>
<%
function getAllScores (myQuery)

	'v6.4.2.8 Not complete
	' The first recordset gets all attempts at exercises
	'Progress.selectAllViews myQuery
	
	' Then we need another that just picks up the scored ones
	Progress.selectAllScores myQuery
	
	' Then merge in a loop through the bigger one, put into XML for output
	' put the results into an XML object
	dim buildString, scoreNode
	dim i, thisScore, thisCount
	i=0
	do while not Progress.rsResult.eof
		'if Progress.rsResult.fields("F_ExerciseID") = Progress.rsResult2[i].fields("F_ExerciseID")
		'	thisCount = Progress.rsResult.fields("NumberDone") +Progress.rsResult2[i].fields("NumberDone")
			thisScore = Progress.rsResult.fields("AvgScore")
		'	i=i+1
		' else
			thisCount = CInt(Progress.rsResult.fields("NumberDone"))
		'	thisScore = -1
		'end if
		
		scoreNode = "<score itemID='" & FormatNumber(Progress.rsResult.fields("F_ExerciseID"),0,0,0,0) & "' " &_
					"unit=""" & Progress.rsResult.fields("F_UnitID") & """ " &_
					"score=""" & thisScore & """ " &_
					"count=""" & thisCount & """ />"
		buildString = buildString & scoreNode
		Progress.rsResult.MoveNext
	loop
	xmlNode = xmlNode & buildString

	Progress.CloseRS
	on error goto 0
	getAllScores = 0
	
end function
%>
<%
function getUser (myQuery)

	' if this is an anonymous login, allow it as the program will have already
	' validated that this was allowed
	'v6.4.2 UserID should not be tested here!
	'if (myQuery.name = "" and myQuery.userID = "" and myQuery.studentID="") then
	if (myQuery.name = "" and myQuery.studentID="") then
		xmlNode = xmlNode & "<user name="""" userID=""-1"" />"
		exit function
	end if

	' v6.3.4 StudentID can be used as well as/or name
	dim searchType
	if (myQuery.name <> "") then
		searchType = "name"
		if (myQuery.studentID <> "") then
			searchType = "both"
		end if
	else
		if (myQuery.studentID <> "") then
			searchType = "id"
		end if
	end if
	
	' run the query
	xmlNode = xmlNode & "<note>using root=" & myQuery.RootID & "</note>"
	Progress.selectUser myQuery, searchType

	dim typedPassword, savedPassword
	dim sql, errorString
	'name = Cstr(request("F_UserName"))
	typedPassword = Cstr(myQuery.Password)

	' look at the results (only expecting 1 record but be prepared to loop anyway)
	if Progress.rsResult.bof and Progress.rsResult.eof then
		if searchType="name" then
			xmlNode = xmlNode + "<err code='203'>no such user</err>"
		else
			xmlNode = xmlNode + "<err code='206'>no such id</err>"
		end if
		getUser = 1
	end if
	do while not Progress.rsResult.eof
		savedPassword = Progress.rsResult.fields("F_Password").value
		if IsNull(savedPassword) then
			'xmlNode = xmlNode + "<note>saved password was null</note>"
			savedPassword = ""
		end if
		' v6.3.4 null password (sent from APO) )means don't check it
		if myQuery.Password = "$!null_!$" then
			typedPassword = savedPassword
		end if
		if savedPassword = typedPassword then
			'returnString = "found user"
			' OK, this is the right user
			' save the found userID in the query object for later use
			myQuery.UserID = Progress.rsResult.fields("F_UserID")
			' make a node to the return information
			'v6.3.6 Add userType (separate teacher and student)
			xmlNode = xmlNode &_
					"<user name=""" & Progress.rsResult.fields("F_UserName") & """ " &_ 
						"userID=""" & Progress.rsResult.fields("F_UserID") & """ " &_ 
						"userSettings=""" & Progress.rsResult.fields("F_UserSettings") & """ " &_ 
						"country=""" & Progress.rsResult.fields("F_Country") & """ " &_ 
						"email=""" & Progress.rsResult.fields("F_Email") & """ " &_ 
						"userType=""" & Progress.rsResult.fields("F_UserType") & """ " &_ 
						"studentID=""" & Progress.rsResult.fields("F_StudentID") & """ />"
						'"className=""" & Progress.rsResult.fields("F_Class") & """ " &_ 
						'"password=""" & savedPassword & """ " &_ 
			' save the found userID in the query object for later use
			myQuery.UserID = Progress.rsResult.fields("F_UserID")
			getUser = 0
		else
			xmlNode = xmlNode & "<err code='204'>password does not match</err>"
			getUser = 1
		end if
		Progress.rsResult.MoveNext
	loop
	
	Progress.CloseRS
	on error goto 0
	getUser = 0
	
end function
%>
<%
' v6.3 New code to help with teacher reporting
function getUsers (myQuery)

	' run the query
	Progress.selectUsers myQuery
	
	' put the results into an XML object
	dim buildString, userNode
	do while not Progress.rsResult.eof
		' v6.3.6 Return userType to catch just students
		userNode = "<user id='" & Progress.rsResult.fields("F_UserID") & "'" &_
				"userType='" & Progress.rsResult.fields("F_UserType") & "'" &_
				"name='" & Progress.rsResult.fields("F_UserName") & "' />"
		buildString = buildString & userNode
		Progress.rsResult.MoveNext
	loop
	' catch a zero user database (impossible?)
	if buildString = "" then
		buildString = "<note>No users in this database</note>"
	end if
	
	xmlNode = xmlNode & buildString
	
	Progress.CloseRS
	on error goto 0
	getUsers = 0
	
end function
%>

<%
function getScratchPad (myQuery)

	' run the query		
	dim sPText
	sPText = Progress.selectScratchPad(myQuery)
	xmlNode = xmlNode &_
			"<scratchPad>" & sPText & "</scratchPad>"
			
	getScratchPad = 0
	on error goto 0
	
end function
%>

<%
' this function will update the user record with a new scratch pad
function setScratchPad (myQuery)

	Progress.updateScratchPad myQuery

	' check that this was successful
	if not Err.Number = 0 then
		xmlNode = xmlNode & "<err code='205'>your scratch pad has not been saved</err>"
		setScratchPad = 1
	else
		xmlNode = xmlNode & "<scratchPad>saved</scratchPad>"
		setScratchPad = 0
	end if

	'Progress.CloseRS
	on error goto 0
	
end function
%>
<%
function addUser (myQuery)

	' v6.4.1.6 use a separate function to check username so that CE.com can employ more complex checking
	' The checkUniqueName function will now just return 0 for unique and 1 for not
	dim uniqueName
	uniqueName = Progress.checkUniqueName(myQuery)

	' look at the results - any records returned means that we cannot use this userName
	if uniqueName > 0  then
		xmlNode = xmlNode & "<err code='206'>a user with this name or id already exists</err>"
		addUser = 1
		exit function
	end if
	
	Progress.insertUser myQuery
	
	' check that this was successful
	if not Err.Number = 0 then
		xmlNode = xmlNode & "<err code='206'>user could not be added</err>"
		addUser = 1
		'Progress.closeRS
		exit function
	else
		' need to find out the UserID that the database assigned
		Progress.selectNewUser myQuery
		' was a record found?
		if (Progress.rsResult.bof and Progress.rsResult.eof) then
			xmlNode = xmlNode & "<err code='206'>user could not be added</err>"
			addUser = 1
			Progress.closeRS
			exit function
		else
			myQuery.UserID = Progress.rsResult.fields("F_UserID")
			' make a node of the return information
			xmlNode = xmlNode &_
					"<user name=""" & Progress.rsResult.fields("F_UserName") & """ " &_ 
						"userID=""" & Progress.rsResult.fields("F_UserID") & """ " &_ 
						"password=""" & Progress.rsResult.fields("F_Password") & """ " &_ 
						"userSettings=""" & Progress.rsResult.fields("F_UserSettings") & """ " &_ 
						"email=""" & Progress.rsResult.fields("F_Email") & """ " &_ 
						"country=""" & Progress.rsResult.fields("F_Country") & """ " &_ 
						"studentID=""" & Progress.rsResult.fields("F_StudentID") & """ />"
			Progress.closeRS
			' v6.3.1 Also add to membership table
			Progress.insertMembership myQuery
		end if
	end if

	'Progress.CloseRS
	on error goto 0
	addUser = 0
	
end function
%>
<%
' 6.0.6.0 Sessions are now also course based rather than just user based.
' this function will add a new session record for the user who has just logged in
function insertSession (myQuery)
	
	dim saveNow, numSessions, sessionID
	' response.write("userID=" & UserID)
	on error resume next
	' v6.4.2 date is now passed from APP to get local times
	'saveNow = dateFormat(Now)
	saveNow = myQuery.datestamp
	
	Progress.insertSession myQuery, saveNow
	' no need to close a recordset after an insert
	' Progress.closeRS
	
	' check that this was successful
	if not Err.Number = 0 then
		xmlNode = xmlNode & "<err code='205'>your progress cannot be recorded, code=" & CStr(Err.Description) & "</err>"
		insertSession = 1
	else
		' xmlNode = xmlNode & "<note>insertSession seemed successful</note>"
		numSessions = Progress.countSessions(myQuery)
		' xmlNode = xmlNode & "<note>countSessions=" & numSessions & "</note>"
		Progress.closeRS
		
		' How can I tell if the insert was really successful? Do a before and after count?		
		' use an auto increment in the session table to give us an index for later updating
		sessionID = Progress.selectInsertedSessionID(myQuery, saveNow)
		Progress.closeRS
		
		xmlNode = xmlNode & "<session id='" & sessionID & "' count='" & numSessions & "' startTime='" & saveNow & "'/>"
		insertSession = 0
	end if
	
	on error goto 0
	
end function
%>
<%
' this function will update the session record for the current user
function updateSession (myQuery)

	dim saveNow
	' response.write("userID=" & UserID)
	on error resume next
	' v6.4.2 date is now passed from APP to get local times
	'saveNow = dateFormat(Now)
	saveNow = myQuery.datestamp
	
	Progress.updateSession myQuery, saveNow
	
	' check that this was successful
	if not Err.Number = 0 then
		xmlNode = xmlNode & "<err code='205'>your session cannot be updated</err>"
		updateSession = 1
	else
		xmlNode = xmlNode & "<session>updated</session>"
		updateSession = 0
	end if
	
	Progress.closeRS
	on error goto 0
	
end function
%>
<%
' this function will add a new score record for the exercise that has just been marked
function insertScore (myQuery)

	dim saveNow
	' response.write("userID=" & UserID)
	on error resume next
	' v6.4.2 date is now passed from APP to get local times
	'saveNow = dateFormat(Now)
	saveNow = myQuery.datestamp
	
	Progress.insertScore myQuery, saveNow
	
	' check that this was successful
	if not Err.Number = 0 then
		xmlNode = xmlNode & "<err code='205'>your progress is not being recorded " & Err.Description & "</err>"
		insertScore = 1
	else
		xmlNode = xmlNode & "<score status='true' />"
		insertScore = 0
	end if
	
	on error goto 0
	' no need to close a recordset after an insert
	'Progress.closeRS
	
end function
%>
<% 
' v6.3.2 Code for counting registered users
function countUsers (myQuery)

	' run the query
	dim numUsers
	numUsers = Progress.countUsers(myQuery)
	if numUsers >= 1 then
		xmlNode = xmlNode & "<licence users='" & CStr(numUsers) & "' />"
		numUsers = 0
	else 
		xmlNode = xmlNode & "<err code='208'>technical problem:users table: " & Err.Description & "</err>"
		numUsers = 1
	end if
	
	Progress.CloseRS
	on error goto 0
	
end function
%>
<% 
' v6.4.2.5 MGS functions
function getMGS (myQuery)

	Progress.selectGroup myQuery
	
	if not Progress.rsResult.eof then
		'response.write("F_UserID=" & myQuery.UserID & " F_GroupID=" & Progress.rsResult.fields("F_GroupID"))
		myQuery.GroupID = Progress.rsResult.fields("F_GroupID")
		Progress.CloseRS
		getMGSFromHeirarchy myQuery
	else 
		' This is an error, there must be a group
		xmlNode = xmlNode & "<MGS enabled=""false"" />"
		Progress.CloseRS
	end if
	
	on error goto 0
	getMGS = 0
	
end function
function getMGSFromHeirarchy (myQuery)

	' The following call may fail if you don't have the MGS fields in the database. Make sure it is not catastrophic.
	Progress.getMGSFromGroup myQuery
	
	' Does this group have an enabled MGS?
	if not Progress.rsResult.eof then
		'response.write("parent=" & Progress.rsResult.fields("F_GroupParent") & " F_EnableMGS=" & Progress.rsResult.fields("F_EnableMGS"))
		if Progress.rsResult.fields("F_EnableMGS") = "1" then
			xmlNode = xmlNode & "<MGS enabled='true' name=""" & Progress.rsResult.fields("F_MGSName") & """ />"
			Progress.CloseRS
		else
			' recursive to check it's parent Group has MGS enable or not
			' But don't recurse if the parent groupID is the same as this groupId as it means you are at the root
			if Progress.rsResult.fields("F_GroupParent") = myQuery.GroupID then
				xmlNode = xmlNode & "<MGS enabled=""false"" />"
				Progress.CloseRS
			else
				myQuery.GroupID = Progress.rsResult.fields("F_GroupParent")
				Progress.CloseRS
				getMGSFromHeirarchy(myQuery)
			end if
		end if
	else 
		' This is an error, there must be a group
		xmlNode = xmlNode & "<MGS enabled=""false"" />"
		Progress.CloseRS
	end if
	on error goto 0
	getMGSFromHeirarchy = 0	
	
end function
%>
<%
' v6.4.2.8 Merged from customQuery
' this function will read get statistics for this user in this course
function getGeneralStats (myQuery)
		
	' First find the stats for records that have a score - should just take highest if same exercise done several times
	' See the queryProjector version for a query that does it in one go, viewed and scored.
	Progress.getScoredStats myQuery
	dim avgScored, countScored, dupScored, totalScore, totalCorrect
	dim countUnScored, dupUnScored
	dim duplicates
	if (Progress.rsResult.bof AND Progress.rsResult.eof) then
		avgScored = 0
		countScored = 0
		dupScored = 0
		totalScore = 0
		totalCorrect = 0
	else 
		totalScore=0
		duplicates=0
		countScored = 0
		totalCorrect = 0
		do while not Progress.rsResult.eof
			countScored = countScored + 1
			totalScore = totalScore + Progress.rsResult.fields("maxScore")
			totalCorrect = totalCorrect + Progress.rsResult.fields("totalScore")
			duplicates= duplicates+ Progress.rsResult.fields("cntScore")
			Progress.rsResult.MoveNext
		loop
		if (countScored>0) then 
			avgScored = totalScore / countScored
		end if
		dupScored = duplicates - countScored
	end if	
	Progress.CloseRS

	' Then those that are not scored
	Progress.getViewedStats myQuery
	
	if (Progress.rsResult.bof AND Progress.rsResult.eof) then
		countUnScored = 0
		dupUnScored = 0
	else 
		duplicates=0
		countUnScored = 0
		do while not Progress.rsResult.eof
			countUnScored = countUnScored + 1
			duplicates= duplicates+ Progress.rsResult.fields("cntScore")
			Progress.rsResult.MoveNext
		loop
		dupUnScored = duplicates - countUnScored
	end if	
	Progress.CloseRS

	xmlNode = xmlNode & "<stats total='" & totalCorrect &  "' average='" & avgScored &  "' counted='"  & countScored & "' viewed='" & countUnScored &_
			"' duplicatesCounted='"  & dupScored & "' duplicatesViewed='" & dupUnScored & "'/>"
	
	on error goto 0
	getGeneralStats = 0
	
end function
%>
<%
' this function will read get statistics for this user in this course
function getExerciseScore (myQuery)
		
	' Find the score for a specific exercise - only count ones which have been done, not just viewed
	Progress.getExerciseScore myQuery
			
	if (Progress.rsResult.bof AND Progress.rsResult.eof) then
		xmlNode = xmlNode & "<stats score='-1'  />"
	else 
		do while not Progress.rsResult.eof
			xmlNode = xmlNode &  "<stats score='" & Progress.rsResult.fields("F_Score") & "' dateStamp='" & Progress.rsResult.fields("F_DateStamp") & "'/>"
			Progress.rsResult.MoveNext
		loop
	end if	
	Progress.CloseRS

	on error goto 0
	getExerciseScore = 0
	
end function
%>
<%
' this function will read get statistics for this user in this course
function getScoreDetail (myQuery)
		
	' Find the score detail for a particular exercise
	Progress.getScoreDetail myQuery
			
	if (Progress.rsResult.bof AND Progress.rsResult.eof) then
		xmlNode = xmlNode & "<detail score='-1'  />"
	else 
		do while not Progress.rsResult.eof
			xmlNode = xmlNode &  "<detail score='" & Progress.rsResult.fields("F_Score") & "' sessionID='" & Progress.rsResult.fields("F_SessionID") & "' detail='" & Progress.rsResult.fields("F_Detail") & "'/>"
			Progress.rsResult.MoveNext
		loop
	end if	
	Progress.CloseRS

	on error goto 0
	getScoreDetail = 0
	
end function
%>
<%
' this function will read get statistics for this user in this course
function insertDetail (myQuery)
		
	' Add a detail record
	Progress.insertDetail myQuery
			
	if Err.Number = 0 then
		xmlNode = xmlNode & "<insert success='true'  />"
	else 
		xmlNode = xmlNode &  "<insert success='false' />"
	end if	

	on error goto 0
	insertDetail = 0
	
end function
%>
<%
' ===============
' CSTDI
' ===============
' this function will read statistics for this user in this course
function countScoreDetails (myQuery)
		
	' Count the detail records that match the given parameters
	Progress.countScoreDetails myQuery
			
	if (Progress.rsResult.bof AND Progress.rsResult.eof) then
		xmlNode = xmlNode & "<stats count='-1'  />"
	else 
		xmlNode = xmlNode &  "<stats count='" & Progress.rsResult.fields("cntScore") & "' />"
	end if	
	Progress.CloseRS

	on error goto 0
	countScoreDetails = 0
	
end function
%>

