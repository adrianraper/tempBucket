<%
Option Explicit
On Error Resume Next

' if this file is called from somewhere outside APO, give no response
If Request.QueryString("prog") <> "NNW" Then
	Response.End
End If

' declare variables
Dim strPath, strFile, FSO
Dim XMLDoc, returnValue

' start response
Response.ContentType="text/xml"
Response.Write "<sR>"

' load XML document from request
Set XMLDoc = Server.CreateObject("MSXML2.DOMDocument")
XMLDoc.async = False
returnValue = XMLDoc.Load(Request)

' error in loading
If returnValue = False Then
	Response.ContentType = "text/xml"
	Response.Write "<sR save='error' code='" & XMLDoc.parseError.ErrorCode & "'>" & XMLDoc.parseError.reason & "</sR>"
	
' success in loading
Else
	' see if path exists. if not, create it
	strPath = Request.QueryString("path")
	If Len(strPath) > 0 Then
		Set FSO = Server.CreateObject("Scripting.FileSystemObject")
		returnValue = FSO.FolderExists(Server.MapPath(strPath))
		' if FSO error, stop the script
		If Err.Number <> 0 Then
			Response.ContentType = "text/xml"
			Response.Write "<sR save='error' code='" & Err.Number & "'>" & Err.Description & "</sR>"
			Response.Write "</sR>"
			Response.End
		End If
		
		If Not returnValue Then
			Dim F
			Set F = FSO.CreateFolder(Server.MapPath(strPath))
			Set F = Nothing
		End If
		Set FSO = Nothing
	End If
	
	' save file
	strFile = Request.QueryString("file")
	If Len(strFile) > 0 Then
	
		' v0.2.0, DL: Flash doesn't support CDATA so we'll have to do it in ASP
		Dim root, nl1, nl2, nl3, nl4, n1, n2, n3, n4, cSection
		Set root = XMLDoc.documentElement
		Set nl1 = root.childNodes
		For Each n1 In nl1
			Set nl2 = n1.childNodes
			For Each n2 In nl2
				Set nl3 = n2.childNodes
				For Each n3 In nl3
					If n3.nodeName = "CDATA" Then
						Set cSection =XMLDoc.createCDATASection(n3.text)
						n2.appendChild(cSection)
						n2.removeChild(n3)
					Else
						Set nl4 = n3.childNodes
						For Each n4 In nl4
							If n4.nodeName = "CDATA" Then
								Set cSection =XMLDoc.createCDATASection(n4.text)
								n3.appendChild(cSection)
								n3.removeChild(n4)
							End If
						Next
					End If
				Next
			Next
		Next	
		XMLDoc.save Server.MapPath(strFile)
	Else
		Response.Write "<sR save='error' code='-1'>No filename given.</sR>"
	End If
		
	' error in saving file
	If Err.Number <> 0 Then
		Response.ContentType = "text/xml"
		Response.Write "<sR save='error' code='" & Err.Number & "'>" & Err.Description & "</sR>"
		
	' success in saving file
	Else
		Response.ContentType="text/xml"
		Response.Write "<sR save='success' />"
	End If
End If

Set XMLDoc = Nothing

' end response
Response.Write "</sR>"
%>