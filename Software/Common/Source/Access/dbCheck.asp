<%@ LANGUAGE="VBSCRIPT" %>
<% Option Explicit %>
<!--#include file="adovbs.inc"-->
<!--#include file="XMLQuery.asp"-->
<!--#include file="dbPath.asp"--> 
<!--#include file="dbProgress.asp"-->
<% 
'response.write("status=ok")

	' first read the passed query
	Dim myQuery, xReadingOK, xWritingOK
	xReadingOK=0
	xWritingOK=0
	
	Set myQuery = New XMLQuery
	myQuery.parseFromRequest

	' v6.3.4
	' next find the database details
	Dim strconn
	strconn = getDbDetails(myQuery.dbHost)
	
	' connect to the progress database
	Dim Progress
	err=0
	on error resume next		
	' create a xml node to hold the return information
	Dim xmlnode
	xmlNode = "<" & "?xml version='1.0' encoding='UTF-8'?><dbCheck>"

	if err=0 then	
		xmlNode = xmlNode & "<note>Creating database object: "		
		Set Progress = New DBProgress
		if err=0 then
			xmlNode = xmlNode & "Success"		
		else
			xmlNode = xmlNode & "failure - " & err.number & ": " & err.Description
		end if
		xmlNode = xmlNode & "</note>"		
	end if
	
	if err=0 then	
		xmlNode = xmlNode & "<note>Connecting database: "
		Progress.Connect()
		if err=0 then
			xmlNode = xmlNode & "Success"		
		else
			xmlNode = xmlNode & "failure - " & err.number & ": " & err.Description
		end if
		xmlNode = xmlNode & "</note>"		
	end if

	myQuery.RootID = 1
	if err=0 then	
		xmlNode = xmlNode & "<note>Opening user table: "
		Progress.selectUsers(myQuery)
		if err=0 then
			xmlNode = xmlNode & "Success"		
		else
			xmlNode = xmlNode & "failure - " & err.number & ": " & err.Description
		end if
		xmlNode = xmlNode & "</note>"		
	end if
	
	' list the results
	dim count
	count=0
	if err=0 then	
		xmlNode = xmlNode & "<note>Counting rows: "
		do while not Progress.rsResult.eof
			count = count+1
			Progress.rsResult.MoveNext
		loop
		if err=0 then
			xmlNode = xmlNode & "Success"
			xReadingOK=1		
		else
			xmlNode = xmlNode & "failure - " & err.number & ": " & err.Description
		end if
		xmlNode = xmlNode & "</note>"		
	end if
	' make a node to the return information
	xmlNode = xmlNode & "<note>Users=" & count & "</note>"

	if err=0 then	
		xmlNode = xmlNode & "<note>Closing table: "
		Progress.closeRS
		if err=0 then
			xmlNode = xmlNode & "Success"		
		else
			xmlNode = xmlNode & "failure - " & err.number & ": " & err.Description
		end if
		xmlNode = xmlNode & "</note>"		
	end if

	'try updating table
	myQuery.UserID = 1
	myQuery.SentData = "clarity"
	if err=0 then	
		xmlNode = xmlNode & "<note>Write text to user table with UserID=1: "
		Progress.updateScratchPad(myQuery)
		if err=0 then
			xmlNode = xmlNode & "Success"	
			xWritingOK=1			
		else
			xmlNode = xmlNode & "failure - " & err.number & ": " & err.Description
		end if
		xmlNode = xmlNode & "</note>"		
	end if

	'Disconnecting the database in any cases 
	err=0	
	if err=0 then	
		xmlNode = xmlNode & "<note>Closing database: "
		Progress.Disconnect
		if err=0 then
			xmlNode = xmlNode & "Success"		
		else
			xmlNode = xmlNode & "failure - " & err.number & ": " & err.Description
		end if
		xmlNode = xmlNode & "</note>"		
	end if

	xmlNode = xmlNode & "<result>Reading database test: "
	if xReadingOK=1 then
		xmlNode = xmlNode & "OK"		
	else
		xmlNode = xmlNode & "Failure"
	end if
	xmlNode = xmlNode & "</result>"		
	xmlNode = xmlNode & "<result>Writing database test: "
	if xWritingOK=1 then
		xmlNode = xmlNode & "OK"		
	else
		xmlNode = xmlNode & "Failure"
	end if
	xmlNode = xmlNode & "</result>"		
	
	' having closed the XML node to make it well-formed
	xmlNode = xmlNode & "</dbCheck>"
	response.write(xmlNode)

%>
