<%@ LANGUAGE="VBSCRIPT" %>
<% Option Explicit %>
<!--#include file="adovbs.inc"--> 
<!--#include file="XMLQuery.asp"-->
<!--#include file="dbPath.asp"--> 
<!--#include file="dbProgress.asp"-->
<!--#include file="queryProgress.asp"-->
<%
	' v6.4.2 Override for CE.com uniqueName checking function
	' If you want to use this feature, edit the code in CEUniqueName.asp and set following var to 1
	Dim CEUniqueName
	CEUniqueName = 0
%>
<!--#include file="CEUniqueName.asp"--> 
<%
	
	'v6.3.4 Allow debugging
	Dim debugSetting
	debugSetting = "false"
	
	'constants
	' this is minutes after which someone is kicked out of the licence table
	' deliberately set very low during development
	' 6.0.6.0 set this at 10 minutes initially. Perhaps eventually it will be set by RM
	const timeDelay = -10 
	
	' create a xml node to hold the return information
	Dim xmlnode
	 xmlNode = "<" & "?xml version=""1.0"" encoding=""UTF-8""?><db>"
	' and then polish it off at the end with:
	' xmlNode = xmlNode & "</db>"
	
	' first read the passed query
	Dim myQuery
	Set myQuery = New XMLQuery
	myQuery.parseFromRequest

		' debugging only (allows the code to be run direct in the browser)
		'myQuery.method = "ADDNEWUSER"
		'myQuery.method = "GETSCORES"
		'myQuery.method = "GETALLSCORES"
		'myQuery.method = "STARTUSER"
		'myQuery.method = "WRITESCORE"
		'myQuery.method = "HOLDLICENCE"
		'myQuery.method = "STOPUSER"
		'myQuery.method = "GETSCRATCHPAD"
		'myQuery.method = "SETSCRATCHPAD"
		'myQuery.method = "STARTSESSION"
		'myQuery.method = "GETRMSETTINGS"
		'myQuery.method = "COUNTUSERS"
		'myQuery.rootID = "1"
		'myQuery.dbHost = "1"
		'myQuery.name = "Mr Black"
		'myQuery.password = "password"
		'myQuery.studentID = "P574528(8)"
		'myQuery.email = "adrian@noodles.hk"
		'myQuery.licenceType = "Total"
		'myQuery.uniqueName = "1"
		'myQuery.country = ""
		'myQuery.sentData = "This is my new Scratch Pad"
		'myQuery.eKey = "1"
		'myQuery.licences = "5000"
		'myQuery.licenceID = "203"
		'myQuery.userID = "11259"
		'myQuery.userID = "6"
		'myQuery.sessionID = "5"
		'myQuery.courseName = "Adrian%2527s%2520test%2520%25E0%25A4%258D"
		'myQuery.courseID = "1"
		'myQuery.scored = "33"
		'myQuery.correct = "5"
		'myQuery.wrong = "2"
		'myQuery.skipped = "3"
		'myQuery.itemID = "110"
		'myQuery.unitID = "5"
		'myQuery.duration = "10"

	' v6.3.4
	' next find the database details
	Dim strconn
	strconn = getDbDetails(myQuery.dbHost)
	
	' connect to the progress database
	' throughout, a returnCode of 0 = success, any other value is some kind of error code
	Dim Progress, returnCode
	Set Progress = New DBProgress
	returnCode = Progress.Connect()

	' only keep going if the connection is successfully made
	if returnCode = 0 then
	
		
		' for debugging use the following at critical points
		'xmlNode = xmlNode & "<note>started off</note>"
		
		'response.write("query=" & myQuery.Method & " user=" + myQuery.name)
		select case Ucase(myQuery.method)
	
		case "STARTUSER"		
			' v6.4.2.5 MGS Pick up the MGS for this user as well as their user details
			returnCode = getUser(myQuery)
			if returnCode = 0 then
				returnCode = getMGS(myQuery)
			end if
	
		case "ADDNEWUSER"
			returnCode = addUser(myQuery)
			' v6.4.2.6 MGS Pick up the MGS for this new user as well
			if returnCode = 0 then
				returnCode = getMGS(myQuery)
			end if
	
		'v6.3.2 Count total users
		case "COUNTUSERS"
			returnCode = countUsers(myQuery)
			
		' v6.3 New code for teacher login
		case "GETUSERS"
			returnCode = getUsers(myQuery)
	
		case "GETSCRATCHPAD"
			returnCode = getScratchPad(myQuery)
	
		case "SETSCRATCHPAD"
			returnCode = setScratchPad(myQuery)
	
		' 6.0.6.0 Return to the course choosing screen or logout
		case "STOPSESSION", "STOPUSER"	
			returnCode = updateSession(myQuery)
	
		' 6.0.6.0 On selecting a course (user already logged in)
		case "STARTSESSION"
			returnCode = insertSession(myQuery)
	
		case "WRITESCORE"
			returnCode = insertScore(myQuery)
			if returnCode = 0 then
				' update the session for this user while you are here
				returnCode = updateSession(myQuery)
			end if
				
		case "GETSCORES"
			returnCode = getScores(myQuery)
			' v6.4.2.8 And add in everyone's scores
			'if returnCode = 0 then
			'	returnCode = getAllScores(myQuery)
			'end if
	
		' v6.4.2.8 For comparative progress reporting
		case "GETALLSCORES"
			returnCode = getAllScores(myQuery)
	
		case "GETRMSETTINGS"
			returnCode = getRMSettings(myQuery)
	
		' v6.4.2.8 For certificates
		case "GETGENERALSTATS"		
			returnCode = getGeneralStats(myQuery)
	
		case "GETEXERCISESCORE"
			returnCode = getExerciseScore(myQuery)
	
		case "INSERTDETAIL"
			returnCode = insertDetail(myQuery)
		
		case "GETSCOREDETAIL"
			returnCode = getScoreDetail(myQuery)
	
		case "COUNTSCOREDETAILS"
			returnCode = countScoreDetails(myQuery)
	
		case else
			' ===============
			' For running custom queries
			' v6.4.2.4 This is all untested in asp - just sketched out
			' ===============
			dim customStart, valueStart, valueEnd
			customStart = InStr(myQuery.method, "CUSTOM#")
			if customStart = 1 then
				' now that you know we want a custom query, load the query script from wherever you have been told
				'Server.Execute myQuery.customQuery
				'customMethod = mid(myQuery.method, 8)
				'Execute("returnCode = " & customMethod & "(myQuery)")
			
			' ===============
			' End custom queries
			' ===============
			else 
				xmlNode = xmlNode & "<err code='101'>No method sent</err>"
			end if
		end select
	
		' break the database connection
		Progress.Disconnect
		
	end if
	' send back the collected information (if any)
	' having closed the XML node to make it well-formed
	xmlNode = xmlNode & "</db>"
	response.write(xmlNode)
%>
