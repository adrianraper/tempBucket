<%
Option Explicit
On Error Resume Next

Session.codePage = 65001 ' this is utf-8

' if this file is called from somewhere outside APO, give no response
If Request.QueryString("prog") <> "NNW" Then
	Response.End
End If

Function getFolderPathFromFile(f)
	getFolderPathFromFile = Server.MapPath(Left(f, instrRev(f, "/")-1))
End Function
Function getFolderPath(f)
	getFolderPath = Server.MapPath(f)
End Function

' declare variables
Dim filePath, folderPath, xmlDOM, menuDOM, exDOM

filePath = Request.QueryString("path")
folderPath = getFolderPathFromFile(filePath)

Set xmlDOM = Server.CreateObject("Msxml2.DomDocument")
xmlDOM.preserveWhiteSpace = True
xmlDOM.async = False
Set menuDOM = Server.CreateObject("Msxml2.DomDocument")
menuDOM.preserveWhiteSpace = True
menuDOM.async = False
Set exDOM = Server.CreateObject("Msxml2.DomDocument")
exDOM.preserveWhiteSpace = True
exDOM.async = False

Response.ContentType = "text/xml"

' v6.4.3 If you are exporting you know what course node you want to create, then you read each menu.xml to find which 
' exercises and media are in it ready for copying.
' If you are importing, you read the course.xml from the unzip folder you have just made, then the menu.xml files.
' You can also get the exercises and media to make it easier later to copy them.
' It used to be just one function, but due to course tree we don't want to read the course.xml for exporting
dim action
action = Request.QueryString("action")
dim subFolder, scaffold, courseName, courseFolder, courseID, originalContentFolder
dim courseList, course, unitRoot, unit, exercise, exRoot, node, subNode, medias, enabledFlag, contentFolder
if action = "export" then

	' v6.4.3 You only want to find a particular course ID
	' v6.4.3 We can pass all the information we need so that we don't need to read course.xml anymore
	courseID = Request.QueryString("courseID")
	scaffold = Request.QueryString("scaffold")
	subFolder = Request.QueryString("subFolder")
	courseName = Request.QueryString("courseName")
	courseFolder = "Courses"
	originalContentFolder = getFolderPath(Request.QueryString("originalContentFolder"))
	
	' v6.4.3 Build an empty XML node to hold the courseList and course
	Set courseList = xmlDOM.createElement("courseList")
	Set course = xmlDOM.createElement("course")
	courseList.appendChild(course)
	Set medias = xmlDOM.createElement("medias")

	' v6.4.3 Why are we sending back label instead of name?
	'course.setAttribute "label", courseName
	course.setAttribute "name", courseName
	course.setAttribute "check", "2"
	' v6.5.1 And why not send back the ID?
	course.setAttribute "id", courseID
	'v6.4.2.1 Try using course attribute - but worry about the \ on the end at some point and if it is \ or /
	' v6.4.3 Not much point as AP hard codes course folder
	'courseFolder = course.getAttribute("courseFolder")
	'subFolder =  course.getAttribute("subFolder")
	'subFolder = thisSubFolder
	'scaffold = course.getAttribute("scaffold")
	'filePath = folderPath & "\" & courseFolder & subFolder & "\" & course.getAttribute("scaffold")
	' v6.4.3 No slash on the end of courseFolder
	filePath = folderPath & "\" & courseFolder & "\" & subFolder & "\" & scaffold
	course.setAttribute "filePath", filePath
	course.setAttribute "folderPath", folderPath
	' v6.4.3 You have to set the subFolder in the XML
	course.setAttribute "subFolder", subFolder

	' v6.4.3 The menu will always be in the MGS if that is where you are.
	If menuDOM.Load(filePath) Then
		Set unitRoot = menuDOM.documentElement
		For Each unit In unitRoot.childNodes
			' v6.4.3 Why are we sending back label instead of name?
			'unit.setAttribute "label", unit.getAttribute("caption")
			unit.setAttribute "name", unit.getAttribute("caption")
			unit.setAttribute "check", "2"
			For Each exercise In unit.childNodes
				' v6.4.3 Why are we sending back label instead of name?
				'exercise.setAttribute "label", exercise.getAttribute("caption")
				exercise.setAttribute "name", exercise.getAttribute("caption")
				exercise.setAttribute "check", "2"
				' v6.4.3 We need to work out whether the exercise is in the MGS or the original
				' So we check the enabledFlag from the menu, then build the filepath appropriately
				' Medias will be read from the file, then their path also stored appropriately
				' The enabledFlag (called check for some reason) will always to back as 2 I think as everything is 
				' put together for the export.
				enabledFlag =  CInt(exercise.getAttribute("enabledFlag"))
				if CBool(enabledFlag AND 16) then
					'Response.write "mgs for " & exercise.getAttribute("caption")
					contentFolder = folderPath
				else
					'Response.write "pure for " & exercise.getAttribute("caption")
					contentFolder = originalContentFolder
				end if
				' v6.4.3 No slash on the end of courseFolder
				'filePath = folderPath & "\" & courseFolder & subFolder & "\Exercises\" & exercise.getAttribute("fileName")
				' v6.4.3 Use different folders based on MGS
				'filePath = folderPath & "\" & courseFolder & "\" & subFolder & "\Exercises\" & exercise.getAttribute("fileName")
				filePath = contentFolder & "\" & courseFolder & "\" & subFolder & "\Exercises\" & exercise.getAttribute("fileName")
				exercise.setAttribute "filePath", filePath
				
				If exDOM.Load(filePath) Then
					Set exRoot = exDOM.documentElement
					For Each node In exRoot.childNodes
						' v6.4.2.4 Need to get media from all nodes, not just body
						' but ignore "false" media nodes, such as examTips
						'If node.nodeName = "body" Then
							For Each subNode In node.childNodes
								If subNode.nodeName = "media" Then
									If subNode.getAttribute("location") = "shared" Or IsNull(subNode.getAttribute("filename")) Then
										' ignore shared media
										' and media nodes that don't relate to a file
									Else
										subNode.setAttribute "exID", exercise.getAttribute("id")
										' v6.4.3 No slash on the end of courseFolder
										'subNode.setAttribute "filePath", folderPath & "\" & courseFolder & subFolder & "\Media\" & subNode.getAttribute("filename")
										' v6.4.3 Use different folders based on MGS
										'subNode.setAttribute "filePath", folderPath & "\" & courseFolder & "\" & subFolder & "\Media\" & subNode.getAttribute("filename")
										subNode.setAttribute "filePath", contentFolder & "\" & courseFolder & "\" & subFolder & "\Media\" & subNode.getAttribute("filename")
										medias.appendChild(subNode)
									End if
								End If
							Next
						'End If
					Next
					Set exRoot = Nothing
				End If
				
			Next
			course.appendChild(unit)
		Next
		Set unitRoot = Nothing
	End If
else 	
	' v6.4.3 Read the course.xml (the one you unzipped on import)
	If xmlDOM.Load(Server.MapPath(filePath)) Then
		' v6.4.3 Build an empty XML node to hold the courseList and course
		Set courseList = xmlDOM.documentElement
		Set medias = xmlDOM.createElement("medias")

		' There should only be one
		For Each course In courseList.childNodes
		'	If course.getAttribute("id") = thisCourseID Then
				' v6.4.3 We have found the (only) course
				' v6.4.3 Why are we sending back label instead of name?
				course.setAttribute "label", course.getAttribute("name")
				'course.setAttribute "label", courseName
				'course.setAttribute "name", courseName
				course.setAttribute "check", "2"
				'v6.4.2.1 Try using course attribute - but worry about the \ on the end at some point and if it is \ or /
				' v6.4.3 Not much point as AP hard codes course folder
				'courseFolder = course.getAttribute("courseFolder")
				subFolder =  course.getAttribute("subFolder")
				'subFolder = thisSubFolder
				scaffold = course.getAttribute("scaffold")
				courseFolder = "Courses"
				'filePath = folderPath & "\" & courseFolder & subFolder & "\" & course.getAttribute("scaffold")
				' v6.4.3 No slash on the end of courseFolder
				filePath = folderPath & "\" & courseFolder & "\" & subFolder & "\" & scaffold
				course.setAttribute "filePath", filePath
				course.setAttribute "folderPath", folderPath
	
				' v6.4.3 The menu will always be in the MGS if that is where you are.
				If menuDOM.Load(filePath) Then
					Set unitRoot = menuDOM.documentElement
					For Each unit In unitRoot.childNodes
						' v6.4.3 Why are we sending back label instead of name?
						'unit.setAttribute "label", unit.getAttribute("caption")
						unit.setAttribute "name", unit.getAttribute("caption")
						unit.setAttribute "check", "2"
						For Each exercise In unit.childNodes
							' v6.4.3 Why are we sending back label instead of name?
							'exercise.setAttribute "label", exercise.getAttribute("caption")
							exercise.setAttribute "name", exercise.getAttribute("caption")
							exercise.setAttribute "check", "2"
							' v6.4.3 No slash on the end of courseFolder
							'filePath = folderPath & "\" & courseFolder & subFolder & "\Exercises\" & exercise.getAttribute("fileName")
							' v6.4.3 Use different folders based on MGS
							' No, not for importing
							'filePath = contentFolder & "\" & courseFolder & "\" & subFolder & "\Exercises\" & exercise.getAttribute("fileName")
							filePath = folderPath & "\" & courseFolder & "\" & subFolder & "\Exercises\" & exercise.getAttribute("fileName")
							exercise.setAttribute "filePath", filePath
							
							If exDOM.Load(filePath) Then
								Set exRoot = exDOM.documentElement
								For Each node In exRoot.childNodes
									' v6.4.2.4 Need to get media from all nodes, not just body
									' but ignore "false" media nodes, such as examTips
									'If node.nodeName = "body" Then
										For Each subNode In node.childNodes
											If subNode.nodeName = "media" Then
												If subNode.getAttribute("location") = "shared" Or IsNull(subNode.getAttribute("filename")) Then
													' ignore shared media
													' and media nodes that don't relate to a file
												Else
													subNode.setAttribute "exID", exercise.getAttribute("id")
													' v6.4.3 No slash on the end of courseFolder
													'subNode.setAttribute "filePath", folderPath & "\" & courseFolder & subFolder & "\Media\" & subNode.getAttribute("filename")
													' v6.4.3 Use different folders based on MGS
													' No, not for importing
													'subNode.setAttribute "filePath", contentFolder & "\" & courseFolder & "\" & subFolder & "\Media\" & subNode.getAttribute("filename")
													subNode.setAttribute "filePath", folderPath & "\" & courseFolder & "\" & subFolder & "\Media\" & subNode.getAttribute("filename")
													medias.appendChild(subNode)
												End if
											End If
										Next
									'End If
								Next
								Set exRoot = Nothing
							End If
							
						Next
						course.appendChild(unit)
					Next
					Set unitRoot = Nothing
				'End If
				' v6.4.3 We have found the (only) course so break outside
				'exit loop
			End If
		Next
	'Else
		'Response.Write "<courseList></courseList>"
	End If
end if

courseList.appendChild(medias)

Response.Write courseList.xml

Set medias = Nothing
Set courseList = Nothing
Set exDOM = Nothing
Set menuDOM = Nothing
Set xmlDOM = Nothing
%>