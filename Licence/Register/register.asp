<%
'  Response.redirect doesn't preserve POST data
' Server.Transfer only works if you are going to another asp page
' Make a page that has a fake form with the request data in a field
'<body onload="document.form1.submit()">
' Whilst I do seem to go to that page, it is the html of this page that is sent back to my original sendAndLoad
	dim a, b
	a=Request.TotalBytes
	if a>0 then
		b=Request.BinaryRead(a)
	else
		b=""
	end if

	Dim http 'As New MSXML2.XMLHTTP
	
	Set http = CreateObject("MSXML2.ServerXMLHTTP")
	
	'Open URL As POST request
	http.Open "POST", "http://www.ClarityEnglish.com/Software/Common/Source/SQLServer/runFunctionsQuery.php", False
	
	'Send the form data To URL As POST binary request
	http.send b
	
	' send back the result
	response.write http.responseText

%>
