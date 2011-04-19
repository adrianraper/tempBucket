<%
Option Explicit
On Error Resume Next

' if this file is called from somewhere outside APO, give no response
If Request.QueryString("prog") <> "NNW" Then
	Response.End
End If

' declare variables
Dim folderPath, fileType, FSO, FO, file, ext

folderPath = Request.QueryString("path")
folderPath = Replace(folderPath, "\", "/")
folderPath = Replace(folderPath, "//", "/")
'v6.4.2.1 Now the full folder will be passed
'folderPath = folderPath & "/Media"
folderPath = Server.MapPath(folderPath)
'Response.write("path=" & folderPath)

fileType = Request.QueryString("type")

Set FSO = Server.CreateObject("Scripting.FileSystemObject")

Response.ContentType = "text/xml"
Response.Write "<fileList>"

If FSO.FolderExists(folderPath) Then
	Set FO = FSO.GetFolder(folderPath)
	For Each file In FO.Files
		ext = UCase(FSO.GetExtensionName(file.Path))
		Select Case Ucase(fileType)
			Case "IMAGE"
				If ext = "JPG" Then
					Response.Write "<file>" & file.Name & "</file>"
				End If
			Case "AUDIO"
				If ext = "MP3" Or ext = "FLS" Then
					Response.Write "<file>" & file.Name & "</file>"
				End If
			Case "VIDEO"
				If ext = "FLV" Or ext = "SWF" Then
					Response.Write "<file>" & file.Name & "</file>"
				End If
			Case "ZIP"
				If ext = "ZIP" Then
					Response.Write "<file>" & file.Name & "</file>"
				End If
			Case Else
				Response.Write "<file>" & file.Name & "</file>"
		End Select
	Next
End If

Set FO = Nothing
Set FSO = Nothing

Response.Write "</fileList>"
%>