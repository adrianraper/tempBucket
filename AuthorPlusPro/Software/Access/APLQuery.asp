<%
Option Explicit
On Error Resume Next
%>
<!--#include file="adovbs.inc"--> 
<!--#include file="databaseConnect.asp"-->
<!--#include file="dbFunctions.asp"-->
<%
' if this file is called from somewhere outside APO, give no response
If Request.QueryString("prog") <> "NNW" Then
	Response.End
End If

' assign database
dim dbHost
' ar v6.2.4.1 replaced by common dbPath routines
If Request.QueryString("dbHost") <> "" Then
'	assignDatabase Request.QueryString("dbHost")
	dbHost = CInt(Request.QueryString("dbHost"))
Else
'	assignDatabase "1"
	dbHost = 1
End If

' declare variables
Dim XMLDoc, returnValue
Dim xmlNode

' load XML document from request
Set XMLDoc = Server.CreateObject("MSXML2.DOMDocument")
XMLDoc.async = False
returnValue = True
returnValue = XMLDoc.load(Request)
' returnValue = XMLDoc.load()
xmlNode = "<db>"

' error in loading
If returnValue = False Then
	xmlNode = xmlNode & "<db error='true' code='" & XMLDoc.parseError.ErrorCode & "'>" & XMLDoc.parseError.reason & "</db>"
Else

	' declare variables
	Dim root, myQuery
	Set myQuery = New XMLQuery
	Set root = XMLDoc.documentElement
	' get query details
	myQuery.parseXMLQuery root

	' For debugging
	' remember to switch the comment for lines 33 and 34 above about picking up the XML response
	'myQuery.purpose = "checkMGS"
	'myQuery.Username= "Mr Black"
	'myQuery.Password = "ClarityRM"
	'myQuery.RootID = "163"
	
	'xmlNode = xmlNode & "<note>query is " & myQuery.purpose & "</note>"
	' work according to purpose
	Select Case UCase(myQuery.purpose)
		Case "GETDECRYPTKEY"
			' ar v6.2.4.1 replaced by common dbPath routines
			'returnValue = dbConnectProgress(myQuery.dbPath)
			returnValue = dbConnectProgress(dbHost)
			If returnValue = 0 then
				getDecryptKey myQuery
				dbCloseProgress
			End If
		Case "CHECKLOGIN"
			returnValue = dbConnectProgress(dbHost)
			'xmlNode = xmlNode & "<note>connect returns " & returnValue &"</note>"
			If returnValue = 0 then
				checkLogin myQuery
				dbCloseProgress
			End If
		' v6.4.2.5 Add MGS
		Case "CHECKMGS" :
			returnValue = dbConnectProgress(dbHost)
			If returnValue = 0 then
				checkMGS myQuery
				dbCloseProgress
			End If

	End Select	
	
End If

xmlNode = xmlNode & "</db>"
Response.ContentType = "text/xml"
Response.Write xmlNode

Set XMLDoc = Nothing
%>