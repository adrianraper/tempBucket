<%
Option Explicit
On Error Resume Next

' if this file is called from somewhere outside APO, give no response
If Request.QueryString("prog") <> "NNW" Then
	Response.End
End If

' declare variables
Dim source, dest, FSO

source = Server.MapPath(Request.QueryString("sF"))
dest = Server.MapPath(Request.QueryString("dF"))

Set FSO = Server.CreateObject("Scripting.FileSystemObject")
Response.ContentType = "text/xml"

If FSO.FileExists(source) Then
	FSO.CopyFile source, dest, True
End If

Response.Write "<sR success='true' />"

Set FSO = Nothing

' edit menu.xml of this course (set enabledFlag to +16+32)
'If FSO.FileExists(sourceMenuFile) Then
'	Dim MenuDoc, unit, ex, uL, eF
'	Set MenuDoc = Server.CreateObject("MSXML2.DOMDocument")
'	MenuDoc.preserveWhiteSpace = True
'	MenuDoc.async = False
'	If MenuDoc.Load(sourceMenuFile) Then
'		Set uL = MenuDoc.documentElement
'		For Each unit In uL.childNodes
'			eF = unit.getAttribute("enabledFlag") + 48
'			unit.setAttribute "enabledFlag",  eF
'			If unit.hasChildNodes() Then
'				For Each ex In unit.childNodes
'					eF = ex.getAttribute("enabledFlag") + 48
'					ex.setAttribute "enabledFlag",  eF
'				Next
'			End If
'		Next
'		MenuDoc.Save destMenuFile
'	End If
'	Set MenuDoc = Nothing
'End If
%>