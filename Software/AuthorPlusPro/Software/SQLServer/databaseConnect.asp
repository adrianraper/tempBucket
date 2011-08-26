<!--#include file="dbPath.asp"--> 
<%
' v2.1.1.0, DL: to facilitate choosing of db from queries, dbDetails.inc is not used anymore
' strconn is assumed to be the key variable
'dim strconn
'dim serverName, catalog, userName, password

' functions to connect to the progress database
dim connProgress, rsProgress
' ar v2.0 Make this a function to allow failure to be handled by calling routine
function dbConnectProgress (db)

	' ar v2.0 Add error handling
	on error resume next
	Err.number = 0
	set connProgress = server.createobject("adodb.connection")
	
	' ar v2.3 path made by getDbDetails
	connProgress.ConnectionString = getDbDetails(db)
	connProgress.open
	
	' ar v2.0 Add error handling
	dim errLoop
	If Err.Number > 0 then ' this does not pick up ADO errors
		xmlNode = xmlNode & "<err code='100'>asp error " & Err.Number & " on " & strconn & "</err>"
		on error goto 0
		dbConnectProgress = 1
		exit function
	else
		' an extra check based on the connection object
		If not connProgress.State = adStateOpen then
			' with no errors you won't go through this loop at all
			For each errLoop in connProgress.Errors
				xmlNode = xmlNode & "<err code='101'>Sorry, cannot connect to the database " & db & ". " & dbCheckErrMsg & errLoop.Description & "</err>"
				on error goto 0
				dbConnectProgress = 1
				exit function
			Next
			on error goto 0
			xmlNode = xmlNode & "<err code='101'>Sorry, cannot connect to the database " & db & ".</err>"
			dbConnectProgress = 1
			exit function
		end if
	end if

	set rsProgress = server.createObject ("adodb.recordset")
	dbConnectProgress = 0
	
end function

sub dbCloseProgress ()
	' always close and tidy up at the end of the query 
	on error resume next
	rsProgress.close
	set rsProgress=nothing
	connProgress.close
	set connProgress=nothing
	on error goto 0
end sub
%>
