<%@ LANGUAGE="VBSCRIPT" %>
<% Option Explicit %>
<!--#include file="adovbs.inc"--> 
<!--#include file="XMLQuery.asp"-->
<!--#include file="dbPath.asp"--> 
<!--#include file="dbLicence.asp"-->
<!--#include file="queryLicence.asp"-->
<%
	
	'v6.3.4 Allow debugging
	Dim debugSetting
	debugSetting = "false"
	
	const timeDelay = -10 
	Dim mQ
	Set mQ = New XMLQuery
	mQ.parseFromRequest

	' debugging only (allows the code to be run direct in the browser)
	'mQ.method = "DROPLICENCE"
	'mQ.method = "HOLDLICENCE"
	'mQ.method = "GETLICENCESLOT"
	'mQ.method = "FAILLICENCESLOT"
	'mQ.licences = "2"
	'mQ.licenceID = "3"
	'mQ.userID = "6"
	'mQ.rootID = "1"
	'mQ.sessionID = "5"
	'mQ.courseName = "Author Plus Online Demo"
	'mQ.name = "Adrian"
	'mQ.country = "Hong Kong"

	' v6.3.4
	' next find the database details
	Dim strconn
	strconn = getDbDetails(mQ.dbHost)
	
	Dim xmlnode
	xmlNode = "<" & "?xml version=""1.0"" encoding=""UTF-8""?><db>"
	dim rC
	
	' connect to the progress database
	Dim Licence
	Set Licence = New DBLicence
	rC = Licence.Connect()
	if rC = 0 then
			
		select case Ucase(mQ.method)
		case "GETLICENCESLOT"
			rC = getLicenceSlot(mQ)
		case "DROPLICENCE"
			rC = dropLicence(mQ)
		case "HOLDLICENCE"
			rC = updateLicence(mQ)
		case "FAILLICENCESLOT"
			rC = failLicenceSlot(mQ)
	
		case else
			xmlNode = xmlNode & "<err code='101'>No method sent</err>"
		end select
	
		' break the database connection
		Licence.Disconnect
	end if
	xmlNode = xmlNode & "</db>"
	response.write(xmlNode)
%>
