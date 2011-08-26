<!--#include file="clarityUniqueID.asp"-->
<%
' v6.4.2.7 Updated MSXML2 to MSXML2 throughout
Sub sendEmail(Query)
	Dim Rtn
	'Rtn = MySendEMail("comments@clarityenglish.com", "subject", "body", "webmaster@clarity.com.hk", "sender", 1)
	'Rtn = MySendEMail("comments@clarityenglish.com", Query.Subject, Query.Body, Query.Email, Query.Sender, 1)
	Rtn = MySendEMail("support@clarity.com.hk", Query.Subject, Query.Body, Query.Email, Query.Sender, 1)
	If Rtn <> "" Then
		xmlNode = xmlNode & "<action success='false' />"
	Else
		xmlNode = xmlNode & "<action success='true' />"
	End If
End Sub
%>
<%
Sub setSessionVariables(Query)
	Session("s_username") = Query.Username
	Session("gbUserName") = Query.Username
	Session("s_password") = Query.Password
	Session("gbPassword") = Query.Password
	Session("s_contentPath") = Query.ContentPath
	'Session("s_courseid") = Query.Course
	'Session("s_exerciseid") = "ex:"+Query.ExerciseID
	xmlNode = xmlNode & "<action success='true' un='" & Session("s_username") & "' pwd='" & Session("s_password") & "' content='" & Session("s_contentPath") & "' />"
End Sub
%>
<%
' v0.16.1, DL: upload image, audio, video
Sub setUploadLocation(Query)
	' see if path exists. if not, create it
	If Len(Query.UploadPath) > 0 Then
		Set FSO = Server.CreateObject("Scripting.FileSystemObject")
		returnValue = FSO.FolderExists(Server.MapPath(Query.UploadPath))
		
		If Not returnValue Then
			Dim F
			Set F = FSO.CreateFolder(Server.MapPath(Query.UploadPath))
			Set F = Nothing
		End If
		Set FSO = Nothing
	End If
	
	' set session variable for showing upload form
	Session("s_uploadPath") = Server.MapPath(Query.UploadPath)
	
	' return node
	xmlNode = xmlNode & "<action success='true'>" & Server.MapPath(Query.UploadPath) & "</action>"
End Sub
%>
<%
' v0.16.1, DL: upload image, audio, video
Sub setUploadForm(Query)

	If Query.UploadType = "image" Then
		Session("s_fileType") = """.jpg"""
		
	ElseIf Query.UploadType = "audio" Then
		Session("s_fileType") = """.mp3"","".fls"""
		
	ElseIf Query.UploadType = "video" Then
		Session("s_fileType") = """.flv"","".swf"""
		
	ElseIf Query.UploadType = "zip" Then
		Session("s_fileType") = """.zip"""
	End If
	
	If Query.UploadMultiple = "true" Then
		Session("s_multipleFiles") = "true"
	Else
		Session("s_multipleFiles") = "false"
	End If
	
End Sub
%>
<%
Sub lockFile(Query)
	Dim strPath, xmlDoc
	Set xmlDoc = Server.CreateObject("MSXML2.DomDocument.3.0")
	xmlDoc.async = False
	
	strPath = Query.FilePath
	strPath = Left(strPath, Len(strPath)-3)
	strPath = strPath & "lck"

	Dim i, root, currNode, newNode
	Dim thisUserLocking, lockingUser
	thisUserLocking = False
	lockingUser = ""
	
	' check if .lck file exists
	If xmlDoc.Load(Server.MapPath(strPath)) Then
		' exists, get username that locks the file
		Set root = xmlDoc.documentElement
		For i = 0 To (root.childNodes.length - 1)
			Set currNode = root.childNodes.Item(i)
			' if user is currently locking the file, just update the time
			If UCase(Query.Username) = UCase(currNode.childNodes.Item(0).Text) Then
				thisUserLocking = True
				currNode.childNodes.Item(1).Text = getTimeStamp()
			' otherwise get one of the user that locks the file
			ElseIf lockingUser = "" Then
				' only consider the lock less than 1 hour
				If getTimeStamp() - currNode.childNodes.Item(1).Text < 6000  Then
					lockingUser = currNode.childNodes.Item(0).Text
				End If
			End If
		Next
	Else
		' .lck file not found, not locked, create the root element in xmlDoc
		Set root = xmlDoc.createElement("locks")
		xmlDoc.appendChild root
	End If
	
	' if this user doesnt have a lock yet, add it
	If Not thisUserLocking Then
		Set currNode = xmlDoc.createElement("lock")
		root.appendChild currNode
		Set newNode = xmlDoc.createElement("user")
		newNode.Text = Query.Username
		currNode.appendChild newNode
		Set newNode = xmlDoc.createElement("time")
		newNode.Text = getTimeStamp()
		currNode.appendChild newNode
		Set newNode = xmlDoc.createElement("account")
		newNode.Text = Query.Account
		currNode.appendChild newNode
	End If
	
	xmlDoc.Save(Server.MapPath(strPath))

	Set root = Nothing
	Set currNode = Nothing
	Set xmlDoc = Nothing
	
	' return node
	xmlNode = xmlNode & "<action success='true' />"
End Sub
%>
<%
Sub checkLockCourse(Query)
	Dim strPath, xmlDoc, lockingUser, folderPath
	Set xmlDoc = Server.CreateObject("MSXML2.DomDocument.3.0")
	xmlDoc.async = False
	
	strPath = Query.FilePath
	strPath = Left(strPath, Len(strPath)-3)
	strPath = strPath & "lck"
	strPath = Server.MapPath(strPath)
	folderPath = Left(strPath, InStrRev(strPath, "\"))
	
	lockingUser = ""
	
	' check if .lck file exists
	If xmlDoc.Load(strPath) Then
		' exists, get username that locks the file
		Set root = xmlDoc.documentElement
		For i = 0 To (root.childNodes.length - 1)
			Set currNode = root.childNodes.Item(i)
			' if user is currently locking the file, just update the time
			If UCase(Query.Username) = UCase(currNode.childNodes.Item(0).Text) Then
				currNode.childNodes.Item(1).Text = getTimeStamp()
			ElseIf lockingUser = "" Then
				' only consider the lock less than 1 hour
				If getTimeStamp() - currNode.childNodes.Item(1).Text < 6000  Then
					lockingUser = currNode.childNodes.Item(0).Text
				End If
			End If
		Next
	End If
	
	' if there's no locking user on menu.xml, gotta check each lck file in the exercises folder
	If lockingUser = "" Then
		Dim FSO, FO, file
		Set FSO = Server.CreateObject("Scripting.FileSystemObject")
		If FSO.FolderExists(folderPath & "Exercises") Then
		Set FO = FSO.GetFolder(folderPath & "Exercises")
			For Each file In FO.Files
				If lockingUser="" And Right(file.Name, 4)=".lck" Then
					If xmlDoc.Load(file.Path) Then
						' exists, get username that locks the file
						Set root = xmlDoc.documentElement
						For i = 0 To (root.childNodes.length - 1)
							Set currNode = root.childNodes.Item(i)
							' if user is currently locking the file, just update the time
							If UCase(Query.Username) = UCase(currNode.childNodes.Item(0).Text) Then
								currNode.childNodes.Item(1).Text = getTimeStamp()
							ElseIf lockingUser = "" Then
								' only consider the lock less than 1 hour
								If getTimeStamp() - currNode.childNodes.Item(1).Text < 6000  Then
									lockingUser = currNode.childNodes.Item(0).Text
								End If
							End If
						Next
					End If
				End If
			Next
		End If
	End If
	
	If lockingUser <> "" Then
		xmlNode = xmlNode & "<action success='false' lockingUser='" & lockingUser & "' />"
	Else
		xmlNode = xmlNode & "<action success='true' />"
	End If
	
	Set xmlDoc = Nothing
End Sub
%>
<%
Sub checkLockFile(Query)
	Dim strPath, xmlDoc, lockingUser
	Set xmlDoc = Server.CreateObject("MSXML2.DomDocument.3.0")
	xmlDoc.async = False
	
	strPath = Query.FilePath
	strPath = Left(strPath, Len(strPath)-3)
	strPath = strPath & "lck"
	
	lockingUser = ""
	
	' check if .lck file exists
	If xmlDoc.Load(Server.MapPath(strPath)) Then
		' exists, get username that locks the file
		Set root = xmlDoc.documentElement
		For i = 0 To (root.childNodes.length - 1)
			Set currNode = root.childNodes.Item(i)
			' if user is currently locking the file, just update the time
			If UCase(Query.Username) = UCase(currNode.childNodes.Item(0).Text) Then
				currNode.childNodes.Item(1).Text = getTimeStamp()
			ElseIf lockingUser = "" Then
				' only consider the lock less than 1 hour
				If getTimeStamp() - currNode.childNodes.Item(1).Text < 6000  Then
					lockingUser = currNode.childNodes.Item(0).Text
				End If
			End If
		Next
		If lockingUser <> "" Then
			xmlNode = xmlNode & "<action success='false' lockingUser='" & lockingUser & "' />"
		Else
			xmlNode = xmlNode & "<action success='true' />"
		End If
		
	' .lck file not found, not locked, return node
	Else
		xmlNode = xmlNode & "<action success='true' />"
	End If
	
	Set xmlDoc = Nothing
End Sub
%>
<%
Sub releaseFile(Query)
	Dim strPath, xmlDoc
	Set xmlDoc = Server.CreateObject("MSXML2.DomDocument.3.0")
	xmlDoc.async = False
	
	strPath = Query.FilePath
	strPath = Left(strPath, Len(strPath)-3)
	strPath = strPath & "lck"

	' check if .lck file exists
	If xmlDoc.Load(Server.MapPath(strPath)) Then
		Dim i, root, currNode
		Set root = xmlDoc.documentElement
		' remove all the lock nodes of this user
		For i = (root.childNodes.length - 1) To 0 Step -1
			Set currNode = root.childNodes.Item(i)
			If UCase(Query.Username) = UCase(currNode.childNodes.Item(0).Text) Then
				root.removeChild(currNode)
			End If
		Next
		' delete the .lck file if there's no node in it
		If root.childNodes.length = 0 Then
			Dim FSO
			Set FSO = Server.CreateObject("Scripting.FileSystemObject")
			FSO.DeleteFile Server.MapPath(strPath), True
			Set FSO = Nothing
		' save the .lck file as there are still some other users using it
		Else
			xmlDoc.Save(Server.MapPath(strPath))
		End If
		Set root = Nothing
		Set currNode = Nothing
	End If
	
	Set xmlDoc = Nothing

	' return node
	xmlNode = xmlNode & "<action success='true' />"
End Sub
%>
<%
Sub editCourseXMLForExport(tempFolder, Query)
	' ******
	' v6.5.1 This function is not used any more
	Dim xmlDOM, courseList, course, subFolder, match
	Set xmlDOM = Server.CreateObject("MSXML2.DomDocument.3.0")
	xmlDOM.preserveWhiteSpace = True
	xmlDOM.async = False
	'xmlNode = xmlNode & "<note msg='start editCourse' />"
	
	If xmlDOM.Load(tempFolder & "\course.xml") Then
		'xmlNode = xmlNode & "<note msg='can load course.xml for editing' />"
		Set courseList = xmlDOM.documentElement
		'xmlNode = xmlNode & "<note nodes='" & courseList.childNodes.length & "' />"
		For Each course In courseList.childNodes
			'xmlNode = xmlNode & "<note msg='hi' />"
			' v6.4.2.4 only match against real course nodes (otherwise #text nodes screw things up)
			If course.nodename = "course" then
				xmlNode = xmlNode & "<note course='" & course.getAttribute("subFolder") & "' />"
				match = False
				For Each subFolder In Query.SubFolders
					If subFolder <> "" Then
						If subFolder = course.getAttribute("subFolder") Then
							'xmlNode = xmlNode & "<note msg='match subFolder " & subFolder & "' />"
							match = True
						End If
					End If
				Next
				If Not match Then
					'xmlNode = xmlNode & "<note msg='remove " & course.nodename & "' />"
					course.parentNode.removeChild(course)
				Else
					' v6.4.2, DL: get course id for SCORM
					'v6.4.2.1 AR done separately
					'Query.CID = course.getAttribute("id")
					'Query.CName = course.getAttribute("name")
				End If
			End If
		Next
		Set courseList = Nothing
		xmlDOM.Save(tempFolder & "\course.xml")
		xmlNode = xmlNode & "<note msg='save course.xml after editing' />"
	Else
		xmlNode = xmlNode & "<note err='cannot load course.xml for editing' />"
	End If
	Set xmlDOM = Nothing
End Sub

' v6.4.3 New function to build a fresh course.xml for the export
Sub createCourseXMLForExport(tempFolder, Query)
	Dim xmlDOM, courseList, course, subFolder, match
	Set xmlDOM = Server.CreateObject("MSXML2.DomDocument.3.0")
	xmlDOM.preserveWhiteSpace = True
	xmlDOM.async = False
	'xmlNode = xmlNode & "<note msg='start createCourse for " & Query.CName & "' />"
	
	xmlDOM.loadXML("<courseList></courseList>")
	Set courseList = xmlDOM.documentElement
	Set course = xmlDOM.createElement("course")
	course.setAttribute("id") = Query.CID
	' v6.5.0.1 For special cases where ID doesn't equal subfolder
	course.setAttribute("subFolder") = Query.CSubFolder
	course.setAttribute("name") = Query.CName
	course.setAttribute("scaffold") = "menu.xml"
	course.setAttribute("courseFolder") = "Courses"
	course.setAttribute("version") = "6.5.0"
	course.setAttribute("program") = "Author Plus"
	course.setAttribute("enabledFlag") = "3"
	
	courseList.appendChild(course)
	xmlDOM.Save(tempFolder & "\course.xml")
	'xmlNode = xmlNode & "<note msg='save " & tempFolder & "\course.xml after editing' />"
	Set course = Nothing
	Set courseList = Nothing
	Set xmlDOM = Nothing

		'xmlNode = xmlNode & "<note nodes='" & courseList.childNodes.length & "' />"
		'For Each course In courseList.childNodes
		'	'xmlNode = xmlNode & "<note msg='hi' />"
		'	' v6.4.2.4 only match against real course nodes (otherwise #text nodes screw things up)
		'	If course.nodename = "course" then
		'		xmlNode = xmlNode & "<note course='" & course.getAttribute("subFolder") & "' />"
		'		match = False
		'		For Each subFolder In Query.SubFolders
		'			If subFolder <> "" Then
		'				If subFolder = course.getAttribute("subFolder") Then
		'					'xmlNode = xmlNode & "<note msg='match subFolder " & subFolder & "' />"
		'					match = True
		'				End If
		'			End If
		'		Next
		'		If Not match Then
		'			'xmlNode = xmlNode & "<note msg='remove " & course.nodename & "' />"
		'			course.parentNode.removeChild(course)
		'		Else
		'			' v6.4.2, DL: get course id for SCORM
		'			'v6.4.2.1 AR done separately
		'			'Query.CID = course.getAttribute("id")
		'			'Query.CName = course.getAttribute("name")
		'		End If
		'	End If
		'Next
	'Else
	'	xmlNode = xmlNode & "<note err='cannot load course.xml for editing' />"
	'End If
	
End Sub

'v6.4.2.1 This can fail, in which case you need to know so you don't go on zipping
'Sub editMenuXMLForExport(tempFolder, subFolder, Query)
Function editMenuXMLForExport(tempFolder, subFolder, Query)
	Dim tempCourseFolder
	tempCourseFolder = tempFolder & "\Courses\" & subFolder

	Dim ErrNo
	ErrNo = 0
	
	Dim xmlDOM, rootNode, unit, exercise, file, match
	Set xmlDOM = Server.CreateObject("MSXML2.DomDocument.3.0")
	xmlDOM.preserveWhiteSpace = True
	xmlDOM.async = False
	
	If xmlDOM.Load(tempCourseFolder & "\menu.xml") Then
		'xmlNode = xmlNode & "<note msg='can load menu.xml for editing' />"
		Set rootNode = xmlDOM.documentElement
		For Each unit In rootNode.childNodes
			If unit.hasChildNodes Then
				'v6.4.3 After export all enabledFlags should be 3
				unit.setAttribute("enabledFlag")=3
				'xmlNode = xmlNode & "<note unit='" & unit.getAttribute("caption") & "' />"
				For Each exercise In unit.childNodes
					' v6.4.1, DL: debug:
					' for handmade xml files, a #text node is added in front of every node (because of the tabs?)
					' so better check to see if the nodeName is item, and if not, remove the node
					If exercise.nodeName = "item" Then
						'v6.4.3 After export all enabledFlags should be 3
						exercise.setAttribute("enabledFlag")=3
						match = False
						For Each file In Query.Files
							If file <> "" Then
								file = Replace(file, "&amp;", "&")
								file = Mid(file, InStrRev(file, "\") + 1)
								If file = exercise.getAttribute("fileName") Then
									'xmlNode = xmlNode & "<match exercise='" & file & "' />"
									match = True
									Exit For
								End If
							End If
						Next
						If Not match Then
							unit.removeChild(exercise)
						End If
					Else
						unit.removeChild(exercise)
					End If
				Next
			End If
			If Not unit.hasChildNodes Then
				unit.parentNode.removeChild(unit)
			Else
				' v6.4.2, DL: add unit id & name for SCORM
				'v6.4.2 AR; not needed as SCORM output done separately
				'Query.addUnitForSCORM unit.getAttribute("id"), unit.getAttribute("caption")
			End If
		Next
		Set rootNode = Nothing
		xmlDOM.Save(tempCourseFolder & "\menu.xml")
		'xmlNode = xmlNode & "<note msg='save menu.xml after editing' />"
	Else
		xmlNode = xmlNode & "<note err='cannot load " & tempCourseFolder & "\menu.xml for editing' />"
		errNo = 1
	End If
	
	Set xmlDOM = Nothing
	'xmlNode = xmlNode & "<note msg='leave editMenu, err=" & errNo & "' />"
	editMenuXMLForExport = errNo
	
End Function

' v6.4.2, DL: edit manifest file for SCORM exporting
'v6.4.2 AR edited for different query parameters
Sub editManifestForExport(manifestFile, Query)
	Dim xmlDOM, rootNode, organizationsNode, organizationNode, titleNode, itemNode, adlcpNode
	Dim resourcesNode, resourceNode, fileNode
	Dim unit, i
	
	Set xmlDOM = Server.CreateObject("MSXML2.DomDocument.3.0")
	' ar v6.4.2 Try setting preserveWhiteSpace to false and use proper counting - seems safer
	'xmlDOM.preserveWhiteSpace = True
	xmlDOM.preserveWhiteSpace = False
	xmlDOM.async = False
	
	If xmlDOM.Load(manifestFile) Then
		xmlNode = xmlNode & "<note manifest='" & manifestFile & "' units='" & UBound(Query.UIDs) & "' />"
		Set rootNode = xmlDOM.documentElement
		' v6.4.2.7 I have no idea what was going on here...
		' ar v6.4.2 Try setting preserveWhiteSpace to false and use proper counting - seems safer
		'Set organizationsNode = rootNode.childNodes.Item(1)
		'Set organizationNode = organizationsNode.childNodes.Item(1)
		'Set titleNode = organizationNode.childNodes.Item(1)
		' v6.4.2.7 Tidy up
		'Set organizationsNode = rootNode.childNodes.Item(0)
		'Set organizationNode = organizationsNode.childNodes.Item(0)
		'Set titleNode = organizationNode.childNodes.Item(0)
		Set organizationsNode = rootNode.firstChild
		Set organizationNode = organizationsNode.firstChild
		Set titleNode = organizationNode.firstChild
		' v6.4.2.7 You could use nodeTypedValue directly on titleNode, but it is not supported in msxml.6, apparently
		Set titleNodeValue = titleNode.firstChild
		'xmlNode = xmlNode & "<note titleNodeName='" & titleNode.nodeName & "' titleNodeType='" & titleNode.nodeTypedValue & "' titleNodeValue='" & titleNodeValue.nodeValue & "' />"
		titleNodeValue.nodeValue = Query.CName
		'xmlNode = xmlNode & "<note newTitle='" & titleNode.text & "' />"
		' the item node is just used as a placeholder, remove what is there
		' Due to white space (?) it seems that nodelists have extra items (0,2 etc). So count from 1 and next is 3
		' ar v6.4.2 Try setting preserveWhiteSpace to false and use proper counting - seems safer
		'Set itemNode = organizationNode.childNodes.Item(0)
		Set itemNode = organizationNode.childNodes.item(1)
		'xmlNode = xmlNode & "<note itemNode='" & itemNode.text &"' />"
		organizationNode.removeChild(itemNode)
		
		' v6.5 Updated SCORM
		' v6.5.1 using createElement will add an empty xmlns attribute which stops import into SumTotal
		' so instead use the original node (clone it)
		For i = 0 To UBound(Query.UIDs)-1
			'xmlNode = xmlNode & "<note i='" & i &"' />"
			Set newItemNode = itemNode.cloneNode(true)
			'Set itemTitleNode = xmlDOM.createElement("title")
			'Set adlcpNode = xmlDOM.createElement("adlcp:datafromlms")
			'itemNode.setAttribute "xmlns", "http://www.imsproject.org/xsd/imscp_rootv1p1p2"
			' itemNode.setAttribute "identifier", Query.UIDs(i)
			newItemNode.setAttribute "identifier", "ITEM_" & (i+1)
			'itemNode.setAttribute "isvisible", "true"
			'itemNode.setAttribute "identifierref", "RESOURCE-1"
			'itemNode.setAttribute "identifierref", "RESOURCE_1"
			Set itemTitleNode = newItemNode.childNodes.item(0)
			itemTitleNode.text = Query.UNames(i)
			xmlNode = xmlNode & "<note itemTitleNode='" & itemTitleNode.text &"' />"
			Set adlcpNode = newItemNode.childNodes.item(1)
			adlcpNode.text = "course=" & Query.CID & ",unit=" & Query.UIDs(i)
			xmlNode = xmlNode & "<note adlcpNode='" & adlcpNode.text & "' />"
			'itemNode.appendChild itemTitleNode
			'itemNode.appendChild adlcpNode
			organizationNode.appendChild newItemNode
			Set adlcpNode = Nothing
			Set itemTitleNode = Nothing
			Set newItemNode = Nothing
		Next
		'xmlNode = xmlNode & "<note manifestUIDs='" & UBound(Query.UIDs)-1 & "' />"
		xmlDOM.Save(manifestFile)
		xmlNode = xmlNode & "<note manifestSaved='true' />"
		
		Set adlcpNode = Nothing
		Set itemNode = Nothing
		Set titleNode = Nothing
		Set organizationNode = Nothing
		Set organizationsNode = Nothing
		Set rootNode = Nothing
		
	End If
	
	Set xmlDOM = Nothing
End Sub

Function zipByDynaZIP(theFiles, theZip)
	Dim errNo
	errNo = 0
	
	If theFiles = "" Or theZip = "" Then
		' if files to be zipped or the target zip file is empty, do nothing
		errNo = -1
	End If
	'xmlNode = xmlNode & "<note at='inZip' />"
	
	If errNo = 0 Then
		Dim objZip
		' Create an instance of DynaZIP ZIP object
		Set objZip = CreateObject("dzactxctrl.dzactxctrl.1")
		'xmlNode = xmlNode & "<note at='madeZip' />"
		
		' Set zipping parameters
		' Prevent display of errors
		objZip.QuietFlag = True
		objZip.AllQuiet = True
		' Name of the zip file
		objZip.ZIPFile = theZip
		' Name of item as it will appear in the ZIP File (the Drive and Base path followed by \*.*)
		objZip.ItemList = """" & theFiles & """"
		' Recurse through directories
		objZip.RecurseFlag = True
		' Include any directory items in the zip file
		objZip.noDirectoryEntriesFlag = False
		' Prefix the items with any path information
		objZip.noDirectoryNamesFlag = False
		' Set folder naming restrictions associated with relative path zipping
		objZip.ZipSubOptions = objZip.ZipSubOptions + 1
		
		' Action! - zip the files
		objZip.ActionDZ = 4
		
		' See if it has any error
		If objZip.ErrorCode <> 0 Then
			' error
			errNo = CStr(objZip.ErrorCode)
		End If
		
		Set objZip = Nothing
	End If
	
	' return error number (0 for no error)
	zipByDynaZIP = errNo
End Function

'v6.4.2 AR No SCORM output in this anymore
Sub exportFiles(Query)
	Dim errNo, FSO, F, tempFolder, file, subFolder, out, newFile, newFolder
	errNo = 0
	Set FSO = Server.CreateObject("Scripting.FileSystemObject")
	
	' create temp folder to hold zip contents
	tempFolder = Query.BasePath & "\" & getCurrentServerTime()
	Set F = FSO.CreateFolder(tempFolder)
	'xmlNode = xmlNode & "<note tempFolder='" & tempFolder & "' subFolder='" & Query.CSubFolder & "'/>"
	
	' create courses folder and copy course.xml
	Set F = FSO.CreateFolder(tempFolder & "\Courses")
	' create folder for individual courses
	' also copy a mainfest.xml for each course if required
	' v6.4.3 Just one course
	'For Each subFolder In Query.SubFolders
	'	If subFolder <> "" Then
	'		Set F = FSO.CreateFolder(tempFolder & "\Courses\" & subFolder)
	'		Set F = FSO.CreateFolder(tempFolder & "\Courses\" & subFolder & "\Exercises")
	'		Set F = FSO.CreateFolder(tempFolder & "\Courses\" & subFolder & "\Media")
	'	End If
	'Next
	' v6.5.0.1 Note that for courses like Tense Buster, Query.CID doesn't equal Query.SubFolder
	' In which case the query for export will have the subFolder name instead of the ID in CID
	Set F = FSO.CreateFolder(tempFolder & "\Courses\" & Query.CSubFolder)
	Set F = FSO.CreateFolder(tempFolder & "\Courses\" & Query.CSubFolder & "\Exercises")
	Set F = FSO.CreateFolder(tempFolder & "\Courses\" & Query.CSubFolder & "\Media")

	' v6.4.3 Surely it is simpler to just build a new course.xml file since we know it is just one course
	'FSO.CopyFile Query.BasePath & "\course.xml", tempFolder & "\course.xml", True
	createCourseXMLForExport tempFolder, Query

	' v6.4.3 For MGS use
	dim originalContentFolder
	'xmlNode = xmlNode & "<note originalContentPath='" & Query.OriginalContentPath & "'/>"
	originalContentFolder = Server.MapPath(Query.OriginalContentPath)
	'xmlNode = xmlNode & "<note original='" & originalContentFolder & "' />"
	
	' copy files to temp folder
	For Each file In Query.Files
		If file <> "" Then
			file = Replace(file, "&amp;", "&")
			If FSO.FileExists(file) Then
				'v6.4.3 But you don't know whether the file you are copying came from the original or MGS.
				' BasePath will be MGS if you are in one. If they are different, try replacing both paths, clumsy but should work fine
				'xmlNode = xmlNode & "<note copyFrom='" & file & "' base='" & Query.BasePath & "' to='" & tempFolder & "' />"
				newFile = Replace(file, Query.BasePath, tempFolder)
				if Query.BasePath <> originalContentFolder then
					newFile = Replace(newFile, originalContentFolder, tempFolder)
				end if
				newFolder = Left(newFile, InStrRev(newFile, "\") - 1)
				'xmlNode = xmlNode & "<note copyFrom='" & file & "' to folder='" & newFolder & "' file='" & newFile & "' />"
				If FSO.FolderExists(newFolder) Then
					'xmlNode = xmlNode & "<note getting='" & newFile & "' />"
					FSO.CopyFile file, newFile, True
				else 
					'xmlNode = xmlNode & "<note missingFolder='" & newFolder & "' />"
				End If
			Else
				'xmlNode = xmlNode & "<note missingFile='" & file & "' />"
			End If
		End If
	Next
	
	' edit the course.xml according to the selected exercises
	'xmlNode = xmlNode & "<note err='before editCourseXML is " & errNo & "' />"
	' v6.4.3 Surely it is better to just build a new course.xml file since we know it is just one course
	'editCourseXMLForExport tempFolder, Query
	'xmlNode = xmlNode & "<note err='after editCourseXML is " & errNo & "' />"
	
	' edit the menu.xml for each course according to the selected exercises
	' v6.5.0.1 But there is only one course, right?
	'xmlNode = xmlNode & "<note subFolder='" & Query.CSubFolder & "' />"
	'For Each subFolder In Query.SubFolders
	'	If subFolder <> "" Then
			'errNo = editMenuXMLForExport(tempFolder, subFolder, Query)
			errNo = editMenuXMLForExport(tempFolder, Query.CSubFolder, Query)
	'	End If
	'Next
	'xmlNode = xmlNode & "<note msg='back from editMenu' />"
	
	' v6.4.2, DL: add SCORM files
	'v6.4.2 AR No SCORM output in this anymore
	'If Query.SCORM Then
	'	Dim SCORMFiles, SCORMFilesStr
	'	SCORMFilesStr = "adlcp_rootv1p2.xsd,APIWrapper.js,ims_xml.xsd,imscp_v1p1.xsd,imsmanifest.xml,imsmd_v1p2p2.xsd,SCORMScripts.js,SCORMStart-" & Query.Product & ".html"
	'	SCORMFiles = Split(SCORMFilesStr, ",")
	'	For Each file In SCORMFiles
	'		If FSO.FileExists(Query.SoftwarePath & "\SCORM\" & file) Then
	'			FSO.CopyFile Query.SoftwarePath & "\SCORM\" & file, tempFolder & "\" & file
	'		End If
	'	Next
	'	
	'	editManifestForExport tempFolder & "\imsmanifest.xml", Query
	'End If
	
	If errNo = 0 Then
		' zip the files up
		errNo = zipByDynaZIP(tempFolder & "\*.*", tempFolder & ".zip")
	End If
	'xmlNode = xmlNode & "<note at='afterZip' />"
	
	' delete temp folder after zipping
	FSO.DeleteFolder tempFolder, True
	
	Set F = Nothing
	Set FSO = Nothing
	
	' return node
	If errNo = 0 Then
		xmlNode = xmlNode & "<action success='true' file='" & tempFolder & ".zip' />"
	Else
		xmlNode = xmlNode & "<action error='true' code='" & errNo & "' />"
	End If
End Sub

'v6.4.2 AR Function to output SCORM pack
Sub createSCO(Query)
	xmlNode = xmlNode & "<note line='startCreateSCO' />"
	Dim errNo, FSO, F, tempFolder, file
	Set FSO = Server.CreateObject("Scripting.FileSystemObject")
	xmlNode = xmlNode & "<note basePath='" & Query.BasePath & "' />"
	
	' create temp folder to hold zip contents
	tempFolder = Query.BasePath & "\" & getCurrentServerTime()
	xmlNode = xmlNode & "<note tempFolder='" & tempFolder & "' />"
	Set F = FSO.CreateFolder(tempFolder)
		
	Dim SCORMFiles, SCORMFilesStr
					' these moved to common ground
					'"APIWrapper.js,SCORMScripts.js," &_
	' v6.5.1 New files
	'SCORMFilesStr ="adlcp_rootv1p2.xsd,ims_xml.xsd,imscp_v1p1.xsd,imsmd_v1p2p2.xsd," &_
	' v6.5.1 Read SCORMStart.html from the UDP so that you can customise it for customer and product
	'				"imsmanifest.xml,SCORMStart.html"
	SCORMFilesStr ="adlcp_rootv1p2.xsd,ims_xml.xsd,imscp_rootv1p1p2.xsd,imsmd_rootv1p2p1.xsd," &_
					"imsmanifest.xml"
	SCORMFiles = Split(SCORMFilesStr, ",")
	' v6.4.2.1 Find the folder now, rather than earlier
	' But this STILL doesn't work on some servers, presumably you can't do any kind of relative path
	' Yes see note about IIS6.0 on Windows 2003 server - cannot access parent path. So need to get this
	' send in the Query from Flash.
	' v6.4.2.7 It is passed as ServerPath
	'Dim SoftwarePath
	'SoftwarePath = Server.MapPath("..\SCORM")
	Dim tempPath
	'xmlNode = xmlNode & "<note udp='" & Query.UserDataPath & "' />"
	'xmlNode = xmlNode & "<note serverPath='" & Query.ServerPath & "' />"
	tempPath = Query.ServerPath + "/SCORM"
	xmlNode = xmlNode & "<note mapPath='" & tempPath & "' />"
	'tempPath = "/Fixbench/Software/AuthorPlusPro/Software/SCORM"
	SoftwarePath = Server.MapPath(tempPath)
	'SoftwarePath = tempPath
	xmlNode = xmlNode & "<note SCORMPath='" & SoftwarePath & "' />"	
	'xmlNode = xmlNode & "<note tempFolder='" & tempFolder & "' />"	
	'xmlNode = xmlNode & "<note templates='" & SoftwarePath & "' />"
	For Each file In SCORMFiles
		'If FSO.FileExists(Query.SoftwarePath & "\SCORM\" & file) Then
		'	FSO.CopyFile Query.SoftwarePath & "\SCORM\" & file, tempFolder & "\" & file
		'End If
		If FSO.FileExists(SoftwarePath & "\" & file) Then
			FSO.CopyFile SoftwarePath & "\" & file, tempFolder & "\" & file
			' v6.5.1 The manifest MUST be writeable, lets just make them all writeable
			Set F=FSO.GetFile(tempFolder & "\" & file)
			F.Attributes = 0
		End If
	Next
	' v6.5.1 Then get SCORMStart.html from userDataPath
	SoftwarePath = Server.MapPath(Query.UserDataPath)
	xmlNode = xmlNode & "<note SCORMPathAfter='" & SoftwarePath & "' />"	
	file = "SCORMStart.html"
	If FSO.FileExists(SoftwarePath & "\" & file) Then
		FSO.CopyFile SoftwarePath & "\" & file, tempFolder & "\" & file
	End If	
	
	'xmlNode = xmlNode & "<note copiedFiles='true' />"
	editManifestForExport tempFolder & "\imsmanifest.xml", Query
	'xmlNode = xmlNode & "<note editedManifest='true' />"
	
	' zip the files up
	errNo = zipByDynaZIP(tempFolder & "\*.*", tempFolder & ".zip")
	
	' delete temp folder after zipping
	FSO.DeleteFolder tempFolder, True
	
	Set F = Nothing
	Set FSO = Nothing
	
	' return node
	If errNo = 0 Then
		xmlNode = xmlNode & "<action success='true' file='" & tempFolder & ".zip' />"
	Else
		xmlNode = xmlNode & "<action error='true' code='" & errNo & "' />"
	End If
End Sub

Sub checkFileForDownload(Query)
	' check if the file exists
	Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
	If objFSO.FileExists(Query.FilePath) Then
		xmlNode = xmlNode & "<action success='true' file='" & Query.FilePath & "' />"
	Else
		xmlNode = xmlNode & "<action error='" & Query.FilePath & " does not exist for downloading' />"
	End If
	Set objFSO = Nothing
End Sub
%>
<%
Function unzipByDynaZIP(theZip, theDest)
	Dim errNo
	errNo = 0
	
	If theZip = "" Or theDest = "" Then
		' if the source zip file or the destination is empty, do nothing
		errNo = -1
	End If
	
	If errNo = 0 Then
		Dim FSO
		Set FSO = CreateObject("scripting.filesystemobject")
		If Not FSO.FileExists(theZip) Then
			' if file not exists, do nothing
			errNo = -2
		End If
		xmlNode = xmlNode & "<note msg='theZIP is missing' />"
	End If
	
	'v6.4.2.1 If you did half an import earlier, the unzip folder might still exist. If it does, then the dynazip overwrite
	' flag seems not to work and you get error 28. Since it is most unlikely that you will have done anything
	' to this folder, it is safe enough to just assume it is fine - at least until you get to overwrite properly.
	If errNo = 0 Then
		If FSO.FolderExists(theDest) Then
			' if folder exists, simply use it, so nothing more to do
			set FSO = nothing
			unzipByDynaZIP = errNo
			Exit Function
		End If
	End If
	
	If errNo = 0 Then
		Dim objZip
		' Create an instance of DynaZIP UNZIP object
		Set objZip = CreateObject("duzactxctrl.duzactxctrl.1")
		
		' Set unzipping parameters
		' Prevent display of errors
		objZip.QuietFlag = True
		objZip.AllQuiet = True
		' Overwrite existing files
		objZip.OverwriteFlag = True
		' Name of the zip file
		objZip.ZIPFile = theZip
		' Files to be unzipped (all)
		objZip.Filespec = "*.*"
		' Recurse through directories
		objZip.RecurseFlag = True
		' Destination of decompressed files
		objZip.Destination = theDest
		
		' Action! - unzip & extract the files
		objZip.ActionDZ = 8
		
		' See if it has any error
		If objZip.ErrorCode <> 0 Then
			' error
			errNo = CStr(objZip.ErrorCode)
		End If
		
		Set objZip = Nothing
	End If
	set FSO = nothing
	
	' return error number (0 for no error)
	unzipByDynaZIP = errNo
End Function

Sub unzipFile(Query)
	Dim dir, file, errNo
	dir = Server.MapPath(Query.BasePath)
	file = dir & "\" & Query.ZipFile
	
	' unzip the files
	errNo = unzipByDynaZIP(file, dir & "\unzip_" & Left(Query.ZipFile, Len(Query.ZipFile) - 4))
	
	' return node
	If errNo = 0 Then
		xmlNode = xmlNode & "<action success='true' folder='" & Query.BasePath & "/unzip_" & Left(Query.ZipFile, Len(Query.ZipFile) - 4) & "' />"
	Else
		xmlNode = xmlNode & "<action error='true' code='" & errNo & "' />"
	End If
End Sub
%>
<%
Sub importFiles(Query)
	Dim FSO, userFolder, unzipFolder, zipFile, subFolder, file, filename
	Dim newCourseID, newCourseFolder, newExerciseID
	Dim xmlDoc, courseList, courseName, course, newNode, unit, exercise, rootNode, match
	
	Set FSO = Server.CreateObject("Scripting.FileSystemObject")
	
	' get userDataPath from base path
	' v6.4.2.1 AR Query.BasePath is like /Content/AuthorPlus/unzip_1239827349723
	' Surely it would have been much better to pass the courses folder and full ZIP file separately??
	unzipFolder = Query.BasePath
	userFolder = Left(unzipFolder, InStrRev(unzipFolder, "\") - 1)
	zipFile = userFolder & "\" & Mid(unzipFolder, InStrRev(unzipFolder, "\") + 7) & ".zip"
	
	' add new courses one by one
	' v6.5.0.1 Again, surely there will only be one
	For Each subFolder In Query.SubFolders
		If subFolder <> "" Then
			xmlNode = xmlNode & "<note subfolder='" & subFolder & "' />"
			' create new folder for a course
			newCourseID = getCurrentServerTime()
			newCourseFolder = userFolder & "\Courses\" & newCourseID
			Set F = FSO.CreateFolder(newCourseFolder)
			Set F = FSO.CreateFolder(newCourseFolder & "\Exercises")
			Set F = FSO.CreateFolder(newCourseFolder & "\Media")
			
			FSO.CopyFile unzipFolder & "\Courses\" & subFolder & "\menu.xml", newCourseFolder & "\menu.xml", True
			
			' copy media files in the course
			' v6.4.2.1 AR This section should copy all the /Media files. You might not need them all since you are
			' perhaps not importing the whole course, but without reading each exercise file I don't know which you
			' do need.
			For Each file In Query.Files
				If file <> "" Then
					file = Replace(file, "&amp;", "&")
					If FSO.FileExists(file) Then
						If InStr(file, unzipFolder & "\Courses\" & subFolder) > 0 Then
							'v6.4.2.1 AR correct the condition
							'If InStr(LCase(file), ".xml") > 0 Then
							If InStr(LCase(file), ".xml") <= 0 Then
								FSO.CopyFile file, Replace(file, unzipFolder & "\Courses\" & subFolder, newCourseFolder), True
							End If
						End If
					End If
				End If
			Next
			
			' get course name from the unzipped course.xml
			Set xmlDoc = Server.CreateObject("MSXML2.DomDocument.3.0")
			xmlDoc.preserveWhiteSpace = True
			xmlDoc.async = False
			If xmlDoc.Load(unzipFolder & "\course.xml") Then
				courseName = ""
				Set courseList = xmlDoc.documentElement
				For Each course In courseList.childNodes
					If subFolder = course.getAttribute("subFolder") Then
						courseName = course.getAttribute("name")
					End If
				Next
				Set courseList = Nothing
				
				' edit course.xml to include new course after getting the course name
				If FSO.FolderExists(newCourseFolder) Then
					IF xmlDoc.Load(userFolder & "\course.xml") Then
						Set courseList = xmlDoc.documentElement
						Set newNode = xmlDoc.createElement("course")
						newNode.setAttribute "author", "Clarity"
						newNode.setAttribute "edition", "1"
						newNode.setAttribute "version", "1.0"
						newNode.setAttribute "courseFolder", "Courses\"
						newNode.setAttribute "id", newCourseID
						newNode.setAttribute "name", courseName
						newNode.setAttribute "scaffold", "menu.xml"
						newNode.setAttribute "subFolder", newCourseID
						courseList.appendChild newNode
						xmlDoc.Save(userFolder & "\course.xml")
						Set newNode = Nothing
						Set courseList = Nothing
					End If
				End If
			End If
			
			' edit the menu.xml file and copy exercise xml files
			dim totalNoOfUnits, thisUnitPos
			totalNoOfUnits=0
			If xmlDoc.Load(newCourseFolder & "\menu.xml") Then
				Set rootNode = xmlDoc.documentElement
				For Each unit In rootNode.childNodes
					If unit.nodeName = "item" Then
						For Each exercise In unit.childNodes
							If exercise.nodeName = "item" Then
								match = False
								For Each file In Query.Files
									If file <> "" Then
										file = Replace(file, "&amp;", "&")
										filename = Mid(file, InStrRev(file, "\") + 1)
										If filename = exercise.getAttribute("fileName") Then
											match = True
											
											' copy the exercise xml file
											If FSO.FileExists(file) Then
												If InStr(file, unzipFolder & "\Courses\" & subFolder) > 0 Then
													' v6.4.0.1, DL: debug - change all exercise filenames (attributes id, action, fileName, exerciseID)
													newExerciseID = getCurrentServerTime()
													FSO.CopyFile file, Replace(Replace(file, unzipFolder & "\Courses\" & subFolder, newCourseFolder), filename, newExerciseID & ".xml"), True
													exercise.setAttribute "id", newExerciseID
													exercise.setAttribute "action", newExerciseID
													exercise.setAttribute "fileName", newExerciseID & ".xml"
													exercise.setAttribute "exerciseID", newExerciseID
												End If
											End If
											' Since you have found a match for this file, jump out of the loop
											Exit For
										End If
									End If
								Next
								If Not match Then
									unit.removeChild(exercise)
								End If
							Else
								unit.removeChild(exercise)
							End If
						Next
						' Did we copy any exercises in this unit?
						If Not unit.hasChildNodes Then
							unit.parentNode.removeChild(unit)
						Else
							totalNoOfUnits = totalNoOfUnits + 1
							' change the unit numbering
							'v6.4.2.1 Do it with the coordinates resetting below
							'unit.setAttribute "picture", "Menu-APL-" & CInt(totalNoOfUnits)
							'unit.setAttribute "unit", totalNoOfUnits
						End If
					Else
						unit.parentNode.removeChild(unit)
					End If
				Next
				' once all units are in, can set the new x and y coordinates (you have to know how many there will be in total)
				thisUnitPos=0
				For Each unit In rootNode.childNodes
					If unit.nodeName = "item" Then
						thisUnitPos = thisUnitPos + 1
						unit.setAttribute "x", calUnitXPos(thisUnitPos, totalNoOfUnits)
						unit.setAttribute "y", calUnitYPos(thisUnitPos, totalNoOfUnits)
						unit.setAttribute "picture", "Menu-APL-" & thisUnitPos
						unit.setAttribute "unit", thisUnitPos
						' at this point you should also go into the exercises of this node and change their unitID
					End If
				Next
				Set rootNode = Nothing
				xmlDoc.Save(newCourseFolder & "\menu.xml")
			End If
			Set xmlDoc = Nothing
		End If
	Next
	
	' delete the uploaded zip file and the temp unzip folder
	' AR v6.4.2.1 No, save the zip file for future importing
	'If FSO.FileExists(zipFile) Then
	'	FSO.DeleteFile zipFile, True
	'End If
	If FSO.FolderExists(unzipFolder) Then
		FSO.DeleteFolder unzipFolder, True
	End If
	
	Set FSO = Nothing
	
	xmlNode = xmlNode & "<action success='true' />"
End Sub
%>
<%
Function Floor(n)
	Dim r
	r = Round(n)
	If r > n Then
		r = r - 1
	End If
	Floor = r
End Function
Function calUnitXPos(pos, total)
	Dim n
	'v6.4.2.1 AR Three layouts, 4, 6, more
	If total > 6 Then
		n = 24
		n = n + ((pos-1) mod 5) * 132
	ElseIf total > 4 Then
		n = 156
		n = n + ((pos-1) mod 3) * 132
	Else
		n = 156
		n = n + ((pos-1) mod 2) * 132
	End If
	calUnitXPos = n
End Function
Function calUnitYPos(pos, total)
	Dim n
	n = 70
	If total > 6 Then
		n = n + Floor(pos / 6) * 160
	ElseIf total > 4 Then
		n = n + Floor(pos / 4) * 160
	Else
		n = n + Floor(pos / 3) * 160
	End If
	calUnitYPos = n
End Function
Sub importFilesToCurrentCourse(Query)
	Dim FSO, userFolder, unzipFolder, zipFile, subFolder, file, filename
	Dim newCourseFolder, newCourseMenuXml, newFilename
	Dim xmlDoc, rootNode, newNode, unit, exercise, match
	Dim newCourseXmlDoc, newRootNode, newUnitPos, totalNoOfUnits, newExerciseID

	Set FSO = Server.CreateObject("Scripting.FileSystemObject")
	
	' get userDataPath from base path
	' v6.4.2.1 AR Query.BasePath is like /Content/AuthorPlus/unzip_1239827349723
	' v6.4.3 Or it will be in the MGS if you are
	' Surely it would have been much better to pass the courses folder and full ZIP file separately??
	unzipFolder = Query.BasePath
	userFolder = Left(unzipFolder, InStrRev(unzipFolder, "\") - 1)
	zipFile = userFolder & "\" & Mid(unzipFolder, InStrRev(unzipFolder, "\") + 7) & ".zip"
	
	' get newCourseFolder from MenuXmlPath
	newCourseMenuXml = Server.MapPath(Query.MenuXmlPath)
	newCourseFolder = Left(newCourseMenuXml, InStrRev(newCourseMenuXml, "\") - 1)
	xmlNode = xmlNode & "<copy from='" & unzipFolder & "' to='" & newCourseFolder & "' />"
	
	' add new courses one by one
	' v6.4.3 There should only be one, which is already embedded in the newCourseFolder name
	For Each subFolder In Query.SubFolders
		If subFolder <> "" Then
		'subFolder = Query.SubFolders(1)
		
			' create exercises/media folder in the destination course if not exists
			If Not FSO.FolderExists(newCourseFolder & "\Exercises") Then
				Set F = FSO.CreateFolder(newCourseFolder & "\Exercises")
			End If
			If Not FSO.FolderExists(newCourseFolder & "\Media") Then
				Set F = FSO.CreateFolder(newCourseFolder & "\Media")
			End If
			
			' copy media files in the course
			' v6.4.2.1 AR This section should copy all the /Media files. You might not need them all since you are
			' perhaps not importing the whole course, but without reading each exercise file I don't know which you
			' do need.
			For Each file In Query.Files
				' v6.4.3 The Files array lists all files, not just media, so get rid of xml files immediately (messy)
				If InStr(LCase(file), ".xml") <= 0 Then
					If file <> "" Then
						file = Replace(file, "&amp;", "&")
						xmlNode = xmlNode & "<copy file='" & file & "' />"
						If FSO.FileExists(file) Then
							' ar How could I have a file listed that isn't in the right folder? Or is this a kind of double-check
							' where we ignore anything that doesn't fit, no matter how it got there?
							If InStr(file, unzipFolder & "\Courses\" & subFolder) > 0 Then
								'v6.4.2.1 AR correct the condition
								'If InStr(LCase(file), ".xml") > 0 Then
								'If InStr(LCase(file), ".xml") <= 0 Then
									newFilename = Replace(file, unzipFolder & "\Courses\" & subFolder, newCourseFolder)
									'xmlNode = xmlNode & "<copy replace='"& unzipFolder & "\Courses\" & subFolder & "' />"
									'xmlNode = xmlNode & "<copy with='"& newCourseFolder & "' />"
									FSO.CopyFile file, newFilename, True
								'End If
							End If
						End If
					End If
				End If
			Next
			
			' Task with the following code is to merge the unit/exercise nodes from the menu.xml in the unzip folder
			' that you have selected for import into the menu.xml of the existing course, and copy the appropriate
			' exercise files. Complicated by the fact that not all of the units/exercises will be copied, only those
			' whose names are in our files array.
			' You can get the name of the menu.xml from this list of files (though it probably shouldn't be there)
			' or by assuming it will be called menu.xml and be in the approrpiate place in the unzip folder. Choose the 
			' latter for now.
			' Go through the menu.xml from the zip copying all unit nodes and each item node that matches
			' an exercise in our list (also actually copy the file). 
			' Then go through the XML again removing any units that have no exercises. This
			' leaves an XML that needs to be appended to the one in the target course.
			xmlNode = xmlNode & "<note MGSEnabled='" & Query.MGSEnabled & "' />"
			totalNoOfUnits = 0
			Set xmlDoc = Server.CreateObject("MSXML2.DomDocument.3.0")
			xmlDoc.preserveWhiteSpace = True
			xmlDoc.async = False
			If xmlDoc.Load(unzipFolder & "\Courses\" & subFolder & "\menu.xml") Then
				Set rootNode = xmlDoc.documentElement
				For Each unit In rootNode.childNodes
					If unit.nodeName = "item" Then
						For Each exercise In unit.childNodes
							If exercise.nodeName = "item" Then
								match = False
								' loop through files we want copied to see if it matches this item
								For Each file In Query.Files
									If file <> "" Then
										file = Replace(file, "&amp;", "&")
										filename = Mid(file, InStrRev(file, "\") + 1)
										If filename = exercise.getAttribute("fileName") Then
											match = True
											
											' copy the exercise xml file
											If FSO.FileExists(file) Then
												If InStr(file, unzipFolder & "\Courses\" & subFolder) > 0 Then
													' v6.4.0.1, DL: debug - change all exercise filenames (attributes id, action, fileName, exerciseID)
													newExerciseID = getCurrentServerTime()
													' debug, don't change names to make sure the right files are copied
													'newExerciseID = exercise.getAttribute("id")
													newFilename = Replace(Replace(file, unzipFolder & "\Courses\" & subFolder, newCourseFolder), filename, newExerciseID & ".xml")
													xmlNode = xmlNode & "<copy from='" & file & "' to='"&newFilename&"' oldEF='"&exercise.getAttribute("enabledFlag")&"' />"
													FSO.CopyFile file, newFilename, True
													exercise.setAttribute "id", newExerciseID
													exercise.setAttribute "action", newExerciseID
													exercise.setAttribute "fileName", newExerciseID & ".xml"
													exercise.setAttribute "exerciseID", newExerciseID
													' v6.4.3 This will be dependent on being in MGS or not
													If Query.MGSEnabled = "true" then
														exercise.setAttribute "enabledFlag", CInt(exercise.getAttribute("enabledFlag")) + 16
													Else
														exercise.setAttribute "enabledFlag", 3
													End If
												End If
											End If
											' Since you have found a match for this file, jump out of the loop
											Exit For
										End If
									End If
								Next
								If Not match Then
									unit.removeChild(exercise)
								End If
							Else
								' should be no nodes that are not items, but just to be sure
								' (might it not be more in the spirit of XML to just ignore anything unexpected?)
								unit.removeChild(exercise)
							End If
						Next
					End If
					' Did we copy any exercises in this unit?
					If Not unit.hasChildNodes Then
						unit.parentNode.removeChild(unit)
					Else
						totalNoOfUnits = totalNoOfUnits + 1
					End If
				Next
			End If
			'xmlNode = xmlNode & "<oldXML units='" & totalNoOfUnits & "' />"
			' at this point rootNode.childNodes should have the unit nodes to be appended to the new course

			' open the menu.xml in newCourseFolder for appending new units
			newUnitPos = 0
			Set newCourseXmlDoc = Server.CreateObject("MSXML2.DomDocument.3.0")
			newCourseXmlDoc.preserveWhiteSpace = True
			newCourseXmlDoc.async = False
			If newCourseXmlDoc.Load(newCourseMenuXml) Then
				Set newRootNode= newCourseXmlDoc.documentElement
				' get the largest number of the "unit" attribute for incrementation
				' v6.4.2.1 Don't really need to do this anymore as we are simply going to renumber all
				' units anyway. Just count up the number of units you are adding. Better as you won't jump numbers
				For Each unit In newRootNode.childNodes
					If unit.nodeName = "item" Then
						'If CInt(unit.getAttribute("unit")) >= newUnitPos Then
						'	newUnitPos = CInt(unit.getAttribute("unit"))
						'End If
						totalNoOfUnits = totalNoOfUnits + 1
					Else
						' again, remove anything unexpected 
						' (might it not be more in the spirit of XML to just ignore anything unexpected?)
						unit.parentNode.removeChild(unit)
					End If
				Next
				
				' v6.4.2.1 Since you are adding in units, you might need to change menu positions of existing ones
				' Plus updating the unit number used - well, where is it used?
				' You can't do this until you know the total number of units in the menu.
				dim thisUnitPos
				thisUnitPos=0
				For Each unit In newRootNode.childNodes
					If unit.nodeName = "item" Then
						thisUnitPos = thisUnitPos + 1
						unit.setAttribute "picture", "Menu-APL-" & thisUnitPos
						unit.setAttribute "x", calUnitXPos(thisUnitPos, totalNoOfUnits)
						unit.setAttribute "y", calUnitYPos(thisUnitPos, totalNoOfUnits)
						unit.setAttribute "unit", thisUnitPos
						For Each exercise In unit.childNodes
							exercise.setAttribute "unit", thisUnitPos
						Next
					end if
				Next
				
				' now we can iterate through the unit nodes that are gonna be appended
				'v6.4.2.1 base on the count you just did
				newUnitPos = thisUnitPos
				For Each unit In RootNode.childNodes
					If unit.nodeName = "item" Then
						newUnitPos = newUnitPos + 1
						Set newNode = newCourseXmlDoc.createElement("item")
						newNode.setAttribute "picture", "Menu-APL-" & CInt(newUnitPos) 
						newNode.setAttribute "caption-position", "bc"
						' v6.4.3 Note that different products have different interfaces. This isn't going to cut it.
						' However, all you have to do is some unit editing within AP after the import and it will correct itself.
						newNode.setAttribute "x", calUnitXPos(newUnitPos, totalNoOfUnits)
						newNode.setAttribute "y", calUnitYPos(newUnitPos, totalNoOfUnits)
						newNode.setAttribute "enabledFlag", unit.getAttribute("enabledFlag")
						newNode.setAttribute "unit", newUnitPos
						newNode.setAttribute "caption", unit.getAttribute("caption")
						newNode.setAttribute "id", getCurrentServerTime()
						For Each exercise In unit.childNodes
							exercise.setAttribute "unit", newUnitPos
							newNode.appendChild exercise.cloneNode(true)
						Next
						newRootNode.appendChild newNode.cloneNode(true)
						Set newNode = Nothing
					End If
				Next
			
				newCourseXmlDoc.Save(newCourseMenuXml)
			End If
			
			Set RootNode = Nothing
			Set NewRootNode = Nothing
			Set newCourseXmlDoc = Nothing
			Set xmlDoc = Nothing
		End If
	Next
	
	' delete the uploaded zip file and the temp unzip folder - no keep the ZIP file for future importing
	'If FSO.FileExists(zipFile) Then
	'	FSO.DeleteFile zipFile, True
	'End If
	If FSO.FolderExists(unzipFolder) Then
		FSO.DeleteFolder unzipFolder, True
	End If

	Set FSO = Nothing
	
	xmlNode = xmlNode & "<action success='true' />"
End Sub
%>
<%
Sub deleteFile(Query)
	On Error Resume Next
	Dim path, FSO
	path = Query.FilePath
	Set FSO = Server.CreateObject("Scripting.FileSystemObject")
	If FSO.FileExists(path) Then
		FSO.DeleteFile path, True
		xmlNode = xmlNode & "<action success='true' />"
	Else
		xmlNode = xmlNode & "<action error='no such file exists for deletion' file='" & path & "' />"
	End If
	Set FSO = Nothing
End Sub
%>