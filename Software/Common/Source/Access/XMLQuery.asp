<%
' this class is used for queries sent as XML from Orchid
Class XMLQuery
	' have a property for each parameter that you might pass from Orchid
	' as a query attribute in the XML
	' If this gets too big it would surely be better to have different classes for
	' different sections of the program.
	Public Method
	
	Public UserID
	Public Name
	Public Password
	Public RMSetting
	Public RootID

	Public LicenceID
	Public Licences
	Public SessionID

	Public CourseName
	Public ItemID 	' Note that this is the exerciseID and should be renamed
	Public UnitID
	'Public Scored	' Note that this comes from xml 'score' and should be renamed
	Public Score		' v6.4.2.4
	Public Correct
	Public Wrong
	Public Skipped
	Public Duration

	Public Country
	Public Email
	Public Group
	Public StudentID

	Public SentData
	' v6.3.4 New field for test results
	Public TestUnits
	' v6.3.4 New field for database selection
	Public DBHost
	' v6.3.4 New field for key encryption
	Public eKey
	' v6.3.4 Session table now uses courseID not courseName
	Public CourseID
	' v6.3.5 Now need licence type
	Public LicenceType
	' v6.3.6 Variable to determine if courseName is in the table (old) or not (new)
	'Public UseCourseName
	' v6.4.2 Send local time for scores and sessions
	Public Datestamp
	' v6.4.2 To limit scope of name uniqueness
	Public UniqueName
	'v6.4.2 Add field for score detail
	Public QuestionID
	'v6.4.2.4 Add field for product code (licence control)
	Public ProductCode
	' v6.4.2.5 Internal field used in MGS
	Public GroupID
	' v6.4.3 Pass for getting scores
	Public UserType
	
	Public Sub parseFromRequest
		dim myBytes, thisXML, thisData
		myBytes = Cint(request.TotalBytes)
		thisXML = request.binaryread(myBytes)
		thisData = BinaryToString(thisXML)
		'response.write("request=" & thisData)
		parseXMLString thisData
	End Sub
	Public Sub parseXMLString(data)

		' see if each parameter is in the string, and, if it is, extract it's value
		Method = getAttrFromStr(data, "METHOD", "help")
		UserID = getAttrFromStr(data, "USERID", "-1")
		' v6.5 Change default for the rootID to 1
		'RootID = getAttrFromStr(data, "ROOTID", "0")
		RootID = getAttrFromStr(data, "ROOTID", "1")
		Name = getAttrFromStr(data, "NAME", "")
		Password = getAttrFromStr(data, "PASSWORD", "")
		RMSetting = getAttrFromStr(data, "RMSETTING", "")
		CourseName = getAttrFromStr(data, "COURSENAME", "")
		ItemID = getAttrFromStr(data, "ITEMID", "0")
		UnitID = getAttrFromStr(data, "UNITID", "0")
		LicenceID = getAttrFromStr(data, "LICENCEID", "0")
		Licences = getAttrFromStr(data, "LICENCES", "0")
		' Scored = getAttrFromStr(data, "SCORE", "0") 
		Score = getAttrFromStr(data, "SCORE", "0") ' v6.4.2.4
		Correct = getAttrFromStr(data, "CORRECT", "0")
		Wrong = getAttrFromStr(data, "WRONG", "0")
		Skipped = getAttrFromStr(data, "SKIPPED", "0")
		Country = getAttrFromStr(data, "COUNTRY", "")
		Group = getAttrFromStr(data, "GROUP", "")
		Email = getAttrFromStr(data, "EMAIL", "")
		StudentID = getAttrFromStr(data, "STUDENTID", "")
		SessionID = getAttrFromStr(data, "SESSIONID", "-1")
		Duration = getAttrFromStr(data, "DURATION", "0")
		' v6.3.4 New field for test results
		TestUnits = getAttrFromStr(data, "TESTUNITS", "")
		' v6.3.4 New field for database selection
		DBhost = getAttrFromStr(data, "DBHOST", "1")
		' v6.3.4 New field for key encryption
		eKey = getAttrFromStr(data, "EKEY", "1")
		' v6.3.4 session table uses courseID not courseName
		' v6.3.6 But RM takes a while to catch up, and Orchid will write out both.
		' So IF the database has coursename, then write out both but focus on coursename.
		' If not, then (naturally) just use courseID.
		CourseID = getAttrFromStr(data, "COURSEID", "1")
		'v6.4.2 No longer use
		'UseCourseName = "true" '  this will force courseName to be used for the database. Comment if this field is no longer in the db
		' v6.3.5 Licence type
		LicenceType = getAttrFromStr(data, "LICENCETYPE", "Single")
		' v6.4.2 Send local time for scores and sessions
		dim formattedNow
		formattedNow = ZeroPad(Year(Now)) & "-" & ZeroPad(Month(Now)) & "-" & ZeroPad(Day(Now)) & " " & ZeroPad(Hour(Now)) & ":" & ZeroPad(Minute(Now)) & ":" & ZeroPad(Second(Now))
		Datestamp = getAttrFromStr(data, "DATESTAMP", formattedNow)
		' v6.4.2 To limit scope of name uniqueness
		UniqueName = getAttrFromStr(data, "UNIQUENAME", "1")
		' v6.4.2 For score detail
		QuestionID = getAttrFromStr(data, "QUESTIONID", "0")
		' v6.4.2.4 For product code
		ProductCode = getAttrFromStr(data, "PRODUCTCODE", "0")
		' v6.4.3 Pass for getting scores
		UserType = getAttrFromStr(data, "USERTYPE", "0")
		
		' is there a data section to this bit of XML?
		' detect it by looking for a full closing node rather than just / at the end of the node
		dim dStart, dEnd
		dStart = instr(1, data, ">") + 1
		dEnd = instr(dStart, data, "</") 
		if dEnd > dStart then
			SentData = mid(data, dStart, dEnd - dStart)
		end if
		'response.write "<note>" + data + "</note>"
		
	End Sub
	' you need to be sure that you are searching for the whole attribute so that you dont get
	' conflict between things like method="WriteScore" and score="22"
	' so include the = character in the search string. This does mean we will fail if the = does not
	' come immediately after the attribute name. Could also put space in front - should be safe
	private function getAttrFromStr(node, attribute, defaultValue)
		'response.write("search for " + attribute + " in " + node + " default=" + defaultValue)
		dim Pstart, valueStart, valueEnd
		Pstart = InStr(UCase(node), attribute + "=") 
		if Pstart > 0 then
			valueStart = InStr(Pstart, node, Chr(34)) + 1
			valueEnd = InStr(valueStart, node, Chr(34)) 
			'response.write("found " + mid(node, valueStart, valueEnd - valueStart))
			' if the passed value is empty (undefined), then use the default
			if valueEnd > valueStart then
				getAttrFromStr = mid(node, valueStart, valueEnd - valueStart)
			else
				getAttrFromStr = defaultValue
			end if
		else
			getAttrFromStr = defaultValue
		end if
	end function
End Class

%>
<%
' this is only suitable for strings up to 100k
Function BinaryToString(Binary)
	Dim I, S
	For I = 1 To LenB(Binary)
		S = S & Chr(AscB(MidB(Binary, I, 1)))
	Next
	BinaryToString = S
End Function
%>