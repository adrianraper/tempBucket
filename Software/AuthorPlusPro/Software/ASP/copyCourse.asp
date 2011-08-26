<%
Option Explicit
On Error Resume Next

' if this file is called from somewhere outside APO, give no response
If Request.QueryString("prog") <> "NNW" Then
	Response.End
End If

Function getFilename(f)
	getFilename = Mid(f, InStrRev(f, "\")+1)
End Function

' declare variables
Dim userPath, folderPath, destPath, menu, sourceFile, destFile
Dim FSO

userPath = Server.MapPath(Request.QueryString("userPath"))
folderPath = Server.MapPath(Request.QueryString("folder"))
destPath = userPath & "\Courses\" & getFilename(folderPath)
menu = Request.QueryString("menu")

Set FSO = Server.CreateObject("Scripting.FileSystemObject")
Response.ContentType = "text/xml"

If FSO.FileExists(folderPath & "\" & menu) Then
	sourceFile = folderPath & "\" & menu
	destFile = Left(sourceFile, Len(sourceFile) - 4) & "-original.xml"
	If Not FSO.FileExists(destFile) Then
		FSO.CopyFile sourceFile, destFile, True
	End If
End If

' copy the folder content if not exists
'If Not FSO.FolderExists(destPath) Then
'	Set F = FSO.CreateFolder(destpath)
'	Set F = Nothing
'	FSO.CopyFolder folderPath & "\Exercises", destPath & "\Exercises", True
'	FSO.CopyFolder folderPath & "\Media", destPath & "\Media", True
'	
'	' add the course into the course.xml
'	Dim XMLDoc, CNDoc, MenuDoc, cL, uL, unit, ex, eF
'	
'	Set XMLDoc = Server.CreateObject("MSXML2.DOMDocument")
'	XMLDoc.preserveWhiteSpace = True
'	XMLDoc.async = False
'	Set CNDoc = Server.CreateObject("MSXML2.DOMDocument")
'	CNDoc.preserveWhiteSpace = True
'	CNDoc.async = False
'	
'	CNDoc.Load(Request)
'	If Not XMLDoc.Load(userPath & "\course.xml") Then
'		Set cL = XMLDoc.createElement("courseList")
'		XMLDoc.appendChild(cL)
'	Else
'		Set cL = XMLDoc.documentElement
'	End If
'	cL.appendChild(CNDoc.documentElement)
'	XMLDoc.Save userPath & "\course.xml"
'	
'	Set CNDoc = Nothing
'	Set XMLDoc = Nothing
'	
'	' edit menu.xml of this course (set enabledFlag to +16+32)
'	If FSO.FileExists(folderPath & "\" & menu) Then
'		Set MenuDoc = Server.CreateObject("MSXML2.DOMDocument")
'		MenuDoc.preserveWhiteSpace = True
'		MenuDoc.async = False
'		If MenuDoc.Load(folderPath & "\" & menu) Then
'			Set uL = MenuDoc.documentElement
'			For Each unit In uL.childNodes
'				eF = unit.getAttribute("enabledFlag") + 48
'				unit.setAttribute "enabledFlag",  eF
'				If unit.hasChildNodes() Then
'					For Each ex In unit.childNodes
'						eF = ex.getAttribute("enabledFlag") + 48
'						ex.setAttribute "enabledFlag",  eF
'					Next
'				End If
'			Next
'			Set root = Nothing
'			MenuDoc.Save destPath & "\" & Request.QueryString("menu")
'		End If
'		Set MenuDoc = Nothing
'	End If
'End If

Response.Write "<sR success='true' />"

Set FSO = Nothing
%>