<%@ Language=VBScript %>
<%
option explicit
Response.Expires = -1
Server.ScriptTimeout = 600
%>
<!-- #include file="freeASPUpload.asp" -->
<%
' ****************************************************
' Change the value of the variable below to the pathname
' of a directory with write permissions, for example "C:\Inetpub\wwwroot"
  Dim uploadsDirVar
  uploadsDirVar = Session("s_uploadPath")
' ****************************************************

' v0.16.1, DL: variable - upload more than 1 file
Dim MultipleFiles
MultipleFiles = Session("s_multipleFiles")

' v0.16.1, DL: variable - file type to upload
Dim FileType
FileType = Session("s_fileType")

' v0.16.1, DL: use a file name string to pass the names to finishUploadHandler.swf
Dim n, filenamesStr

' Note: this file uploadTester.asp is just an example to demonstrate
' the capabilities of the freeASPUpload.asp class. There are no plans
' to add any new features to uploadTester.asp itself. Feel free to add
' your own code. If you are building a content management system, you
' may also want to consider this script: http://www.webfilebrowser.com/

function OutputForm()
    response.write "<form name=""frmSend"" method=""POST"" enctype=""multipart/form-data"" action=""uploadForm.asp"" onSubmit=""return onSubmitForm();"">"
'   If Not MultipleFiles Then
'ar v6.4.2.1 make small changes to interface
	    response.write "File: <input name=""attach1"" type=""file"" size=""40"" /><br>"
	    response.write "File type(s) accepted: "& Replace(Replace(Replace(FileType, """.", "*."), ",", ", "), """", "")

' v0.16.1, DL: had difficulty in handling multiple files, skip this part at this moment
 '   Else
'	    response.write "If you want to upload more than one files, please rename the files to prefix_xxxx.jpg where xxxx is a number.<br><br>"
'	    response.write "First file: <input name=""attach1"" type=""file"" size=""35"" onChange=""onFileEntered();"" /><br>"
'	    response.write "Increment until: <input type=""text"" name=""endNo"" size=""4"" maxlength=""4"" />"
'    End If
    response.write "<br>"
    response.write "<input style=""margin-top:4"" type=""submit"" value=""Upload"">"
    response.write "<br>"
    response.write "<br>"
    response.write "Click Browse to search for a file, then click Upload"
    response.write "<br>"
    response.write "to send that file to your course."
    response.write "<br>"
    response.write "</form>"
end function

function TestEnvironment()
    Dim fso, fileName, testFile, streamTest
    TestEnvironment = ""
    Set fso = Server.CreateObject("Scripting.FileSystemObject")
    if not fso.FolderExists(uploadsDirVar) then
        'TestEnvironment = "<B>Folder " & uploadsDirVar & " does not exist.</B><br>The value of your uploadsDirVar is incorrect. Open uploadForm.asp in an editor and change the value of uploadsDirVar to the pathname of a directory with write permissions."
	TestEnvironment = "<B>Sorry, the folder can't be opened. ( " & uploadsDirVar & " )</B><br>Please save your work and reload Author Plus before uploading."
        exit function
    end if
    fileName = uploadsDirVar & "\test.txt"
    on error resume next
    Set testFile = fso.CreateTextFile(fileName, true)
    If Err.Number<>0 then
        TestEnvironment = "<B>Folder " & uploadsDirVar & " does not have write permission.</B><br>Please save your work, change the permissions and reload Author Plus before uploading again."
        exit function
    end if
    Err.Clear
    testFile.Close
    fso.DeleteFile(fileName)
    If Err.Number<>0 then
        TestEnvironment = "<B>Folder " & uploadsDirVar & " does not have delete permissions, but it does have write permissions.</B><br>Please save your work, change the permissions and reload Author Plus before uploading again."
        exit function
    end if
    Err.Clear
    Set streamTest = Server.CreateObject("ADODB.Stream")
    If Err.Number<>0 then
        TestEnvironment = "<B>The ADODB object <I>Stream</I> is not available in your server.</B><br>Please talk to your support team about this."
        exit function
    end if
    Set streamTest = Nothing
end function

function SaveFiles()
    Dim Upload, fileName, fileSize, ks, i, fileKey
    Dim thisFileSize

    Set Upload = New FreeASPUpload
    Upload.Save(uploadsDirVar)

	SaveFiles = ""
	
	' If something fails inside the script, but the exception is handled
	If Err.Number<>0 Then 
		dim objErr
		set objErr=Server.GetLastError()
		SaveFiles = "&>" & objErr.Description
		Exit function
	end if

    ' v0.16.1, DL: use a file name string to pass the names to finishUploadHandler.swf
    n = 0
    filenamesStr = ""
    
    ks = Upload.UploadedFiles.keys
    if (UBound(ks) <> -1) then
        'SaveFiles = "<B>Files uploaded:</B> "
        for each fileKey in Upload.UploadedFiles.keys
		' ar v6.4.2.1 Nicer file reporting
		thisFileSize = CInt(Upload.UploadedFiles(fileKey).Length / 1000)
		SaveFiles = SaveFiles & "<br>" & Upload.UploadedFiles(fileKey).FileName & " (" & thisFileSize & "kb) "
	    
	    ' v0.16.1, DL: use a file name string to pass the names to finishUploadHandler.swf
	    ' debug - use Replace() function to get rid of & characters (which ruin filenames with & characters)
	    if (n<>0) then
		    filenamesStr = filenamesStr & "&filename" & CStr(n) & "=" & Replace(Upload.UploadedFiles(fileKey).FileName, "&", "%26")
	    else
		    filenamesStr = filenamesStr & "filename" & CStr(n) & "=" & Replace(Upload.UploadedFiles(fileKey).FileName, "&", "%26")
	    end if
	    n = n + 1
	    
         next
	'else
	'	SaveFiles = "The file name specified in the upload form does not correspond to a valid file in the system."
    end if
end function
%>

<HTML>
<HEAD>
<TITLE>Upload a file</TITLE>
<style>
BODY {background-color:white;font-family:arial;font-size:12}
</style>
<SCRIPT LANGUAGE="JavaScript"> 
<!--
// ar v6.4.2.1 Not sure the purpose of setting this here. You want to set it to false only once the submit has been called
var closing=false;

function finishUploadHandler_DoFSCommand(command, args) {
	//alert("uploadForm:fs command = " + command)
	if (command == "closeWindow") {
		//alert("close myself");
		self.close();
	}
}
extArray = new Array(<%=FileType%>);
function limitFileType(file) {
	var form = document.frmSend;
	allowSubmit = false;
	if (!file) return;
	while (file.indexOf("\\") != -1)
		file = file.slice(file.indexOf("\\") + 1);
		ext = file.slice(file.indexOf(".")).toLowerCase();
	for (var i=0; i<extArray.length; i++) {
		if (extArray[i] == ext) { allowSubmit = true; break; }
	}
	if (allowSubmit) {
		return true;
	} else {
		var extList="";
		for (var i=0; i<extArray.length; i++) {
			extList += "*" + extArray[i] + " ";
		}
		alert("For this upload you can only select files that\nend in:  " + extList + ". Please try again.");
		return false;
	}
}
function onSubmitForm() {
	var formDOMObj = document.frmSend;
	var notEmpty = false;
	<%
		'Dim i
		'For i = 1 to NoOfFiles
		'	response.write "if (formDOMObj.attach" & CStr(i) & ".value!="""") { notEmpty = true; }"
		'Next
		response.write "if (formDOMObj.attach1.value!="""") { notEmpty = true; }"
	%>
	if (!notEmpty) {
		alert("Please click the browse button and pick a file.");
		return false;
	} else {
		<%
		'    For i = 1 to NoOfFiles
		'		response.write "if (!limitFileType(formDOMObj.attach" & CStr(i) & ".value)) { return false; }"
		'    Next
		response.write "if (!limitFileType(formDOMObj.attach1.value)) { return false; }"
		%>
	}
	// ar v6.4.2.1 endNo was part of sequential uploading - now not present and causes IE errors
	/*
	if (formDOMObj.endNo.value!="") {
		var endNo = parseInt(formDOMObj.endNo.value);
		if (isNaN(endNo)) {
			alert("Unexpected error, please try to save your work then try again.");
			return false;
		} else {
			var f1 = formDOMObj.attach1.value;
			var a1 = f1.split(".");
			var s1 = a1[a1.length-2];
			var a2 = s1.split("_");
			var s2 = a2[a2.length-1];
			var startNo = parseInt(s2);
			var noOfFiles = endNo - startNo + 1;
			var suffixLen = a1[a1.length-1].length + a2[a2.length-1].length + 2;
			var prefix = f1.substring(0, f1.length - suffixLen);
			if (endNo<startNo) {
				alert("Unexpected error, please try to save your work then try again.");
				return false;
			}
		}
	}
	*/
	// v6.4.2.1 AR Try to stop the unload from calling any special closing functions as we are simply going to reopen
	//alert("set closing to " + closing);
	closing=false;
	return true;
}
function onFileEntered() {
	var formDOMObj = document.frmSend;
	// ar v6.4.2.1 endNo was part of sequential uploading - now not present and causes IE errors
	//formDOMObj.endNo.disabled = false;
}
//-->
</SCRIPT>
<SCRIPT LANGUAGE="VBScript">
// Catch FS Commands in IE, and pass them to the corresponding JavaScript function.
Sub finishUploadHandler_FSCommand(ByVal command, ByVal args)
    call finishUploadHandler_DoFSCommand(command, args)
End Sub
</SCRIPT>
</HEAD>

<%
Dim diagnostics
if Request.ServerVariables("REQUEST_METHOD") <> "POST" then
    diagnostics = TestEnvironment()

	' ar v6.4.2.1 This unload is calling onCloseForm from the main html window of APP.
    response.write "<BODY onLoad=""closing=true;"" onUnload=""if (closing) window.opener.onCloseForm();"">"
    response.write "<div style=""border-bottom:#A91905 2px solid;font-size:16"">Upload a file</div>"

    if diagnostics<>"" then
        response.write "<div style=""margin-left:20; margin-top:30; margin-right:30; margin-bottom:30"">"
        response.write diagnostics
        'response.write "<p>After you correct this problem, reload the page."
        response.write "</div>"
    else
        response.write "<div style=""margin-left:20""><br>"
        OutputForm()
        response.write "</div>"
    end if
    
else
	' ar v6.4.2.1 Why not have the same onUnload function as the first instance?
    response.write "<BODY>"
    response.write "<div style=""border-bottom: #A91905 2px solid;font-size:16"">File uploaded</div>"
    response.write "<div style=""margin-left:40"">"
	dim saveFilesOutput
	saveFilesOutput = SaveFiles()
	response.write saveFilesOutput
	response.write "<br><br>"
    
	' v0.16.1, DL: close button
	' v6.4.2.1 AR: since close button doesn't work, simply take out the visible side of it
	response.write "<!--url's used in the movie-->"
	response.write "<!--text used in the movie-->"
	response.write "<object classid=""clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"" codebase=""http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=7,0,0,0"" "
	'response.write " width=""80"" height=""22"" id=""finishUploadHandler"" align=""middle"">"
	response.write " width=""2"" height=""2"" id=""finishUploadHandler"" align=""middle"">"
	response.write "<param name=""allowScriptAccess"" value=""sameDomain"" />"
	response.write "<param name=""movie"" value=""../finishUploadHandler.swf?" & filenamesStr & """ />"
	response.write "<param name=""quality"" value=""high"" />"
	response.write "<param name=""bgcolor"" value=""#ffffff"" />"
	response.write "<embed src=""../finishUploadHandler.swf?" & filenamesStr & """ swLiveConnect=""true"" quality=""high"" bgcolor=""#ffffff"" "
	'response.write "width=""80"" height=""22"" "
	response.write "width=""2"" height=""2"" "
	response.write " name=""finishUploadHandler"" align=""middle"" allowScriptAccess=""sameDomain"" type=""application/x-shockwave-flash"" pluginspage=""http://www.macromedia.com/go/getflashplayer"" />"
	response.write "</object>"
	response.write "<br><br>"
	
	if saveFilesOutput = "" then
		response.write "Sorry, that file cannot be opened for uploading."
		response.write "<br><br>"
	elseif Instr(saveFilesOutput,"&>")=1 then
		response.write "Sorry, something has gone wrong uploading your file."
		response.write "<br>"
		response.write "Please close this window and try again. If it still fails"
		response.write "<br>"
		response.write "please ask your support team to check the permission"
		response.write "<br>"
		response.write "to upload files of this size or type to the server."
		response.write "<br>"
	else
		response.write "Your file has been uploaded, you can now close this window."
		response.write "<br><br>"
	end if
	response.write "If Author Plus stays locked after you close this window,"
	response.write "<br>"
	response.write "press the Esc key to release it."
	response.write "<br>"
	response.write "</div>"
end if
%>

</BODY>
</HTML>
