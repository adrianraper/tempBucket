<HTML>
<HEAD>
<TITLE>Download</TITLE>
</HEAD>
<STYLE TYPE="text/css">
body {font-family: "Verdana", "Arial", "Helvetica", "sans-serif"; font-size: 10px; font-style: normal; line-height: 14px; font-weight: normal; font-variant: normal; color: #000066; text-decoration: none;}
</STYLE>
<BODY>
<%
On Error Resume Next
If Request.QueryString("prog") = "NNW" Then
	Dim file, FSO
	file = Request.QueryString("file")
	Set FSO = Server.CreateObject("Scripting.FileSystemObject")
	If FSO.FileExists(file) Then
		' v6.4.2.1 Change the way you turn the physical filename into a virtual one, to allow mixed roots
		'dim rootDir
		'rootDir = Request.ServerVariables("APPL_PHYSICAL_PATH")
		thisFolder = Request.QueryString("folderURL")
		folderBase = Server.MapPath(thisFolder)
		' Match the physical path of the folder with the path of the file to get at the file name
		' then add this to the url version so that it can be downloaded
		dim fileURL
		fileURL = thisFolder & Mid(file, Len(folderBase)+1)
		'Response.Write "The ZIP file is at " & fileURL
		Response.Write "Your exercises are saved in a ZIP file that you can download, ready to be imported into another course.<br><br>"
		Response.Write "<A HREF='" & fileURL & "'><strong>Click here</strong></A>"
		Response.Write " to let your browser download the file."
	Else
		Response.Write "Sorry, the ZIP file cannot be found."
	End If
	Set FSO = Nothing
End If
%>
</BODY>