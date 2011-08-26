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
			xmlNode = xmlNode & "Success "		
		else
			xmlNode = xmlNode & "failure - " & err.number & ": " & err.Description
		end if
		xmlNode = xmlNode & "</note>"		
	end if
	
	if err=0 then	
		xmlNode = xmlNode & "<note>Connecting database: "
		Progress.Connect()
		if err=0 then
			xmlNode = xmlNode & "Success "		
		else
			xmlNode = xmlNode & "failure - " & err.number & ": " & err.Description
		end if
		xmlNode = xmlNode & "</note>"		
	end if

	myQuery.RootID = 1
	if err=0 then	
		xmlNode = xmlNode & "<note>Updating T_Groupstructure table: "
		dim sql
		xmlNode = xmlNode & "<note>add F_EnableMGS "
		sql = "ALTER TABLE T_Groupstructure ADD F_EnableMGS SMALLINT NOT NULL DEFAULT 0;"
		Progress.rsResult.Open sql, Progress.Connection, ,adLockOptimistic 
		if err=0 then
			xmlNode = xmlNode & "Success, field added "		
		elseif InStr(err.Description, "already exists in table") then
			xmlNode = xmlNode & "Success, field already exists "
			' reset the error since all is well
			err=0
		else
			xmlNode = xmlNode & "failure - " & err.number & ": " & err.Description
		end if
		if err=0 then
			xmlNode = xmlNode & "<note>add F_MGSName "
			sql = "ALTER TABLE T_Groupstructure ADD F_MGSName VARCHAR( 255 ) NULL;"
			Progress.rsResult.Open sql, Progress.Connection, ,adLockOptimistic 
			if err=0 then
				xmlNode = xmlNode & "Success, field added "		
			elseif InStr(err.Description, "already exists in table") then
				xmlNode = xmlNode & "Success, field already exists "
				' reset the error since all is well
				err=0
			else
				xmlNode = xmlNode & "failure - " & err.number & ": " & err.Description
			end if
		end if

		xmlNode = xmlNode & "</note>"	
	end if
	
	' list the results
	sql = "SELECT * FROM T_Groupstructure WHERE F_GroupID=1;"
	Progress.rsResult.Open sql, Progress.Connection
	dim count
	count=0
	if err=0 then	
		xmlNode = xmlNode & "<note>Counting rows: "
		do while not Progress.rsResult.eof
			count = count+1
			Progress.rsResult.MoveNext
		loop
		if err=0 then
			xmlNode = xmlNode & "Success "
			xReadingOK=1		
		else
			xmlNode = xmlNode & "failure - " & err.number & ": " & err.Description
		end if
		xmlNode = xmlNode & "</note>"		
	end if
	' make a node to the return information
	xmlNode = xmlNode & "<note>Admin=" & count & "</note>"

	if err=0 then	
		xmlNode = xmlNode & "<note>Closing table: "
		Progress.closeRS
		if err=0 then
			xmlNode = xmlNode & "Success "		
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

	' having closed the XML node to make it well-formed
	xmlNode = xmlNode & "</dbCheck>"
	response.write(xmlNode)

%>
