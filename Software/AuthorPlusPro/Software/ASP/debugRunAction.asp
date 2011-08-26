<%
' v6.4.2.7 Updated MSXML to MSXML3.0 throughout
On Error Resume Next
%>
<!--#include file="actionFunctions.asp"-->
<%
' Query Class
Class XMLQuery

	Public Purpose
	
	Public Username
	Public Password
	Public ContentPath
	Public Course
	Public ExerciseID
	Public Sender
	Public Email
	Public Subject
	Public Body
	' v0.16.1, DL: upload image, audio, video
	Public UploadPath
	Public UploadType
	Public UploadMultiple
	' v0.16.1, DL: file locking
	Public FilePath
	Public Time
	Public Account
	Public UserIP	' v6.4.0.1, DL: add IP address for file locking
	' v0.16.1, DL: zip files
	Public BasePath	' path to the expanded unzip directory
	Public Files()
	Public SubFolders()
	Public SCORM	' boolean to indicate whether it's a SCORM export
	' v6.4.2.1 Not used anymore
	'Public SoftwarePath	' this is not a variable get from APP but holds the path the Software directory
	Public MenuXmlPath	' v6.4.0.1, DL: hold the path of menu.xml to be edited (requires MapPath)
	' v0.16.1, DL: unzip file
	Public ZipFile
	' v6.4.2, DL: for SCORM
	Public Product	' product code (AP, BW, RO, SSS, TB)
	Public CID	' course id
	Public CSubFolder	' v6.5.0.1 course subfolder (if not the same as CID)
	Public CName	' course name
	Public UIDs()	' unit id's
	Public UNames()	' unit names
	' v6.4.2.7 Path to avoid get parent paths
	Public ServerPath	
	Public UserDataPath	
	' v6.4.3 Path if you are in MGS pointing to original content, saves reading location.ini
	Public OriginalContentPath	
	' v6.4.3 Need to know what to do with enabledFlags
	Public MGSEnabled	
	
	Public Sub parseXMLQuery(root)
		SetDefaultValues
		
		Dim queryNode, node
		Set queryNode = root.childNodes
		For Each node In queryNode
			fillInAttributes node
		Next
	End Sub

	Private Sub fillInAttributes(node)
		Dim u
		
		Select Case Ucase(node.nodeName)
			Case "SENDER"
				Sender = node.firstChild.nodeValue
			Case "EMAIL"
				Email = node.firstChild.nodeValue
			Case "SUBJECT"
				Subject = node.firstChild.nodeValue
			Case "BODY"
				Body = node.firstChild.nodeValue
			Case "PURPOSE"
				Purpose = node.firstChild.nodeValue
			Case "USERNAME"
				Username = node.firstChild.nodeValue
			Case "PASSWORD"
				Password = node.firstChild.nodeValue
			Case "CONTENTPATH"
				ContentPath = node.firstChild.nodeValue
			Case "COURSE"
				Course = node.firstChild.nodeValue
			Case "EXID"
				ExerciseID = node.firstChild.nodeValue
				
			' v0.16.1, DL: upload image, audio, video
			Case "UPLOADPATH"
				UploadPath = node.firstChild.nodeValue
			Case "UPLOADTYPE"
				UploadType = node.firstChild.nodeValue
			Case "UPLOADMULTIPLE"
				UploadMultiple = node.firstChild.nodeValue
				
			' v0.16.1, DL: file locking
			Case "FILEPATH"
				FilePath = node.firstChild.nodeValue
			Case "ACCOUNT"
				Account = node.firstChild.nodeValue
				
			' v0.16.1, DL: zip files
			Case "BASEPATH"
				BasePath = node.firstChild.nodeValue
			Case "FILE"
				u = Ubound(Files)
				Redim Preserve Files(u+1)
				Files(u) = node.firstChild.nodeValue
			Case "FOLDER"
				u = Ubound(SubFolders)
				Redim Preserve SubFolders(u+1)
				SubFolders(u) = node.firstChild.nodeValue
			Case "SCORM"
				If node.firstChild.nodeValue = "true" Then
					SCORM = True
				Else
					SCORM = False
				End If
			Case "MENUXMLPATH"
				MenuXmlPath = node.firstChild.nodeValue
				
			'v6.4.2 AR SCORM create SCO - handle arrays
			Case "UID"
				u = Ubound(UIDs)
				Redim Preserve UIDS(u+1)
				UIDS(u) = node.firstChild.nodeValue
			Case "UNAME"
				u = Ubound(UNames)
				Redim Preserve UNames(u+1)
				UNames(u) = node.firstChild.nodeValue
			' v6.4.2.7 Path to avoid get parent paths
			Case "SERVERPATH"
				ServerPath = node.firstChild.nodeValue
			Case "USERDATAPATH"
				UserDataPath = node.firstChild.nodeValue
			' v6.4.3 Path if you are in MGS pointing to original content, saves reading location.ini
			Case "ORIGINALCONTENTPATH"
				OriginalContentPath = node.firstChild.nodeValue
				
			' v0.16.1, DL: unzip file
			Case "ZIPFILE"
				ZipFile = node.firstChild.nodeValue
				
			' v6.4.2, DL: for SCORM
			Case "PRODUCT"
				Product = node.firstChild.nodeValue
			Case "CID"
				CID = node.firstChild.nodeValue
				' v6.5.0.1 If you set this, also set subFolder name if it isn't special
				if CSubFolder="" then
					CSubFolder = CID
				end if
			' v6.5.0.1 For special cases where subfolder not equal id
			Case "CSUBFOLDER"
				CSubFolder = node.firstChild.nodeValue
				' v6.5.0.1 If you set this, also set subFolder name if it isn't special
				if CSubFolder="" then
					CSubFolder = CID
				end if
			Case "CNAME"
				'v6.4.2.7 Need to escape the course name as it might have apostrophe
				' no - it was another problem. Sweeter to leave unescaped
				'CName = escape(node.firstChild.nodeValue)
				CName = node.firstChild.nodeValue
				
			' v6.4.3 for enabledFlags
			Case "MGSENABLED"
				MGSEnabled = node.firstChild.nodeValue

		End Select
	End Sub

	Private Sub SetDefaultValues()
		Purpose = ""
	
		Username = ""
		Password = ""
		ContentPath = ""
		Course = ""
		ExerciseID = ""
		Sender = ""
		Email = "webmaster@clarity.com.hk"
		Subject = ""
		Body = ""
		' v0.16.1, DL: upload image, audio, video
		UploadPath = ""
		UploadType = ""
		UploadMultiple = ""
		' v0.16.1, DL: file locking
		FilePath = ""
		Time = ""
		Account = ""
		' v6.4.0.1, DL: user's IP address
		UserIP = Request.ServerVariables("REMOTE_ADDR")
		' v0.16.1, DL: zip files
		BasePath = ""
		Redim Files(3)
		Redim SubFolders(3)
		SCORM = False
		'v6.4.2.1 This does not work with all IIS servers - it can give a system error. Need to find other way to get it.
		' What I want is the parent folder to this one - generally that is /Clarity/Software/AuthorPlusPro/Software
		' Can I get myself as a full name and go up that? Note that in PHP it is defaulted to empty. So how is it used in ASP?
		' simply for picking up SCORM templates, so just do it all then
		'SoftwarePath = CStr(Server.MapPath("..\"))
		MenuXmlPath = ""
		' v0.16.1, DL: unzip file
		ZipFile = ""
		' v6.4.2, DL: for SCORM
		Product = "AP"
		CID = ""
		CSubFolder = ""
		CName = ""
		Redim UIDs(0)
		Redim UNames(0)
		' v6.4.2.7 Path to avoid get parent paths
		ServerPath = ""
		UserDataPath = ""
		' v6.4.3 Path to avoid reading location.ini
		OriginalContentPath = ""
		' v6.4.3 for enabledFlags
		MGSEnabled = "false"
	End Sub
	
	'v6.4.2 AR; not needed as SCORM output done separately
	'Public Sub addUnitForSCORM(id, caption)
	'	Dim u
	'	u = Ubound(UIDs)
	'	Redim Preserve UIDs(u+1)
	'	UIDs(u) = id
	'	u = UBound(UNames)
	'	Redim Preserve UNames(u+1)
	'	UNames(u) = caption
	'End Sub
End Class

' if this file is called from somewhere outside APO, give no response
If Request.QueryString("prog") <> "NNW" Then
	Response.End
End If

' declare variables
Dim XMLDoc, returnValue
Dim xmlNode

' load XML document from request
Set XMLDoc = Server.CreateObject("MSXML2.DOMDocument.3.0")
XMLDoc.async = False

' for debugging
dim debugMode
' ==========
debugMode = true
XMLDoc.createElement("action")
returnValue = true
' ========== OR
'debugMode = false
'returnValue = XMLDoc.load(Request)
' ==========

xmlNode = "<action>"

' error in loading
If returnValue = False Then
	xmlNode = xmlNode & "<action error='true' code='" & XMLDoc.parseError.ErrorCode & "'>" & XMLDoc.parseError.reason & "</action>"
Else

	' declare variables
	Dim root, myQuery
	Set myQuery = New XMLQuery
	Set root = XMLDoc.documentElement
	' get query details
	myQuery.parseXMLQuery root

	'xmlNode = xmlNode & "<note query.cname='" & myQuery.CName & "' />"
	
	' for debugging
	if debugMode then
		myQuery.purpose = "createSCO"
		myQuery.userDatapath = ">/Fixbench/AuthorPlus"
		myQuery.basePath = "D:\Fixbench\Content\AuthorPlus"
		myQuery.uid = "1178007262864"
		myQuery.cid = "1174987637859"
		myQuery.CNAME = "Adrian&apos;s test"
		'myQuery.originalContentPath = "/Fixbench/Content/MyCanada"
		'myQuery.files(0) = "D:\Fixbench\Content\Spaces\Disturbing\MyCanada\Courses\1127356511328\menu.xml"
		'myQuery.files(1) = "D:\Fixbench\Content\MyCanada\Courses\1127356511328\Exercises\1127386318657.xml"
		'myQuery.files(2) = "D:\Fixbench\Content\MyCanada\Courses\1127356511328\Media\birch bark wigwams copy.jpg"
		'myQuery.subfolders(0) = "1127356511328"
		myQuery.ServerPath = "Fixbench/Software/AuthorPlusPro/Software"
	end if

	' work according to purpose
	Select Case UCase(myQuery.purpose)
		
		' v0.16.1, DL: upload files
		Case "SETUPLOADSETTINGS"
			setUploadForm(myQuery)
			setUploadLocation(myQuery)
			
		' v0.16.1, DL: file locking
		Case "LOCKFILE"
			lockFile(myQuery)
		Case "CHECKLOCKFILE"
			checkLockFile(myQuery)
		Case "CHECKLOCKCOURSE"
			checkLockCourse(myQuery)
		Case "RELEASEFILE"
			releaseFile(myQuery)
			
		' v0.16.1, DL: zip files
		Case "EXPORTFILES"
			exportFiles(myQuery)
		Case "CHECKFILEFORDOWNLOAD"
			checkFileForDownload(myQuery)
		'v6.4.2 AR SCORM output
		Case "CREATESCO"
			createSCO(myQuery)
		
		' v0.16.1, DL: unzip file
		Case "UNZIPFILE"
			unzipFile(myQuery)
		' v6.4.0.1, DL: import files to current course
		Case "IMPORTFILESTOCURRENTCOURSE"
			importFilesToCurrentCourse(myQuery)
		' v0.16.1, DL: import files
		Case "IMPORTFILES"
			importFiles(myQuery)
			
		Case "SENDEMAIL"
			sendEmail(myQuery)
		Case "PREVIEWCOURSES"
			setSessionVariables(myQuery)
		Case "PREVIEWMENU"
			setSessionVariables(myQuery)
		Case "PREVIEWEXERCISE"
			setSessionVariables(myQuery)
			
		' v6.4.2, DL: delete file
		Case "DELETEFILE"
			deleteFile(myQuery)
	End Select
	
End If

xmlNode = xmlNode & "</action>"
Response.ContentType = "text/xml"
Response.Write xmlNode

Set XMLDoc = Nothing
%>