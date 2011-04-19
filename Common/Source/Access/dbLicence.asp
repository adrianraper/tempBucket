<%
' This file changes between different databases
' v6.3 Note that as our SQL server only has one database, the table in the old 'licence' database
' has changed from T_Session to T_Licences
' Also SQL server does not use # for dates - which Access does
' And DELETE * FROM does not work, maybe the * can be removed in Access version as well?
' v6.4.2.4 Converge Access and SQLServer versions. It seems to just be the date format that is different.
' So use the dateFormat to either put # or ' around the date.
' v6.3.3 Add rootID to T_Licences table for concurrent access
Class DBLicence

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
	Public Function countLicences(mQ, mode, jN)
		' v6.3.3 Add root to connection tables
		'sql = "SELECT COUNT(F_LicenceID) FROM T_Licences"
		'6.3.5 Add userID to connection tables
		'v6.4.2 ONLY if it is sent to you - see comment in OrchidObjects about APL and userID
		if mQ.userID < 0 then
			sql = "SELECT COUNT(F_LicenceID) FROM T_Licences WHERE F_RootID=" & CLng(mQ.rootID)
		else
			sql = "SELECT COUNT(F_LicenceID) FROM T_Licences WHERE F_RootID=" & CLng(mQ.rootID) & " AND F_UserID=" & CLng(mQ.userID)
		end if
		' v6.4.2.4 Use the productCode from the licence so that different products do NOT share the same licence limit
		sql = sql & " AND F_ProductCode=" & CInt(mQ.productCode)
		
		If mode=0 Then
			sql = sql & " AND F_LicenceID=" & CLng(mQ.licenceID) & ";"
		elseif mode=2 then
			' v6.4.2.4 All dates are now fully formatted in dateFormat routine
			'sql = sql & " AND F_LastUpdateTime<'" & dateFormat(jN) & "';"
			sql = sql & " AND F_LastUpdateTime<" & dateFormat(jN) & ";"
		else
			sql = sql & ";"
		end if
		rsResult.open sql, Connection
		countLicences = rsResult.fields(0)
		CloseRS
		
	End Function

	Public Sub deleteLicencesID(liN)
		sql = "DELETE FROM T_Licences " &_
			"WHERE F_LicenceID=" & CLng(liN) & ";"
		rsResult.Open sql, Connection
		'rsResult.Close
	End Sub

	Public Sub deleteLicencesOld(jN)
		' v6.4.2.4 Use the productCode from the licence so that different products do NOT share the same licence limit
		' v6.4.2.4 All dates are now fully formatted in dateFormat routine
		sql = "DELETE FROM T_Licences " &_
				"WHERE F_LastUpdateTime<" & dateFormat(jN) & " " &_
				" AND F_ProductCode=" & CInt(mQ.productCode) & ";"
		rsResult.Open sql, Connection
		'rsResult.Close
	End Sub
    
	Public Sub updateLicence(liN, jN)
		' v6.4.2.4 All dates are now fully formatted in dateFormat routine
		sql = "UPDATE T_Licences " &_ 
			"SET F_LastUpdateTime=" & dateFormat(jN) & " " &_
			"WHERE F_LicenceID=" & CLng(mQ.licenceID) & ";" 
		rsResult.Open sql, Connection, , adLockOptimistic
		'rsResult.Close
	End Sub

	Public Sub insertLicence(mQ, CurDate)
		'xmlNode = xmlNode & "<note>date=" & CurDate &"</note>"

		' v6.3.3 Add root to connection tables
		'sql = "INSERT INTO T_Licences (F_UserHost, F_StartTime, F_LastUpdateTime) " &_
		'	"VALUES ( '" & Request.ServerVariables("HTTP_Host") & "', '" & CurDate & "', '" & CurDate & "');"
		'6.3.5 Add userID to connection tables
		'sql = "INSERT INTO T_Licences (F_UserHost, F_StartTime, F_LastUpdateTime, F_RootID) " &_
		'	"VALUES ( '" & Request.ServerVariables("HTTP_Host") & "', '" & dateFormat(CurDate) & "', '" & dateFormat(CurDate) & "', " & CLng(mQ.rootID) & ");"
		' v6.4.2.4 Use the productCode from the licence so that different products do NOT share the same licence limit
		'sql = "INSERT INTO T_Licences (F_UserHost, F_StartTime, F_LastUpdateTime, F_RootID, F_UserID) " &_
		'	"VALUES ( '" & Request.ServerVariables("REMOTE_ADDR") & "', '" & dateFormat(CurDate) & "', '" & dateFormat(CurDate) & "', " & CLng(mQ.rootID) & ", " & CLng(mQ.userID)  & ");"
		' v6.4.2.4 All dates are now fully formatted in dateFormat routine
		sql = "INSERT INTO T_Licences (F_UserHost, F_StartTime, F_LastUpdateTime, F_RootID, F_UserID, F_ProductCode) " &_
			"VALUES ( '" & Request.ServerVariables("REMOTE_ADDR") & "', " & dateFormat(CurDate) & ", " & dateFormat(CurDate) & ", " &_
					CLng(mQ.rootID) & ", " & CLng(mQ.userID) & ", " & CInt(mQ.productCode) & ");"
		rsResult.Open sql, Connection
		'rsResult.Close
	End Sub
        
	Public Function selectInsertedLicence(jDate)
		' v6.4.2.4 All dates are now fully formatted in dateFormat routine
		sql = "SELECT F_LicenceID FROM T_Licences " &_
			"WHERE (F_UserHost = '" & Request.ServerVariables("REMOTE_ADDR") & "' " &_
			"AND F_StartTime = " & dateFormat(jDate) & ");"
		rsResult.Open sql, Connection
		If not rsResult.EOF Then
			selectInsertedLicence = rsResult.Fields("F_LicenceID")
		Else
			selectInsertedLicence = -1
		End If
		CloseRS
	End Function
	
	Public Sub insertFail(mQ, rN)
		' v6.3.3 Add root to connection tables
		'sql = "INSERT INTO T_FailSession (F_UserHost, F_StartTime) " &_
		'	"VALUES ( """ & Request.ServerVariables("HTTP_Host") & """, #" & rN & "#);" 
		'6.3.5 Add userID to connection tables
		'sql = "INSERT INTO T_FailSession (F_UserHost, F_StartTime, F_RootID) " &_
		'	"VALUES ( '" & Request.ServerVariables("HTTP_Host") & "', '" & dateFormat(rN) & "', " & CLng(mQ.rootID) & ");"
		' v6.4.2.4 Use the productCode from the licence so that different products do NOT share the same licence limit
		'sql = "INSERT INTO T_FailSession (F_UserHost, F_StartTime, F_RootID, F_UserID) " &_
		'	"VALUES ( '" & Request.ServerVariables("REMOTE_ADDR") & "', '" & dateFormat(rN) & "', " & CLng(mQ.rootID)  & ", " & CLng(mQ.userID)& ");"
		' v6.4.2.4 All dates are now fully formatted in dateFormat routine
		sql = "INSERT INTO T_FailSession (F_UserHost, F_StartTime, F_RootID, F_UserID, F_ProductCode) " &_
			"VALUES ( '" & Request.ServerVariables("REMOTE_ADDR") & "', " & dateFormat(rN) & ", " &_
			CLng(mQ.rootID)  & ", " & CLng(mQ.userID) & ", " & CInt(mQ.productCode) & ");"
		rsResult.Open sql, Connection
		'rsResult.Close
	End Sub

End Class
%>
