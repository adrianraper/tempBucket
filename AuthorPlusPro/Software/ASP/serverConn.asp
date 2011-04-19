<%
' if this file is called from somewhere outside APO, give no response
If Request.QueryString("prog") <> "NNW" Then
	Response.End

' otherwise, return ok!
Else
	' v6.4.1.2, DL: set the the code page used when encoding the HTTP response to the client to UTF-8 (65001)
	' v6.4.2.6 This generates an error on the MGM server. It seems that they don't have this codepage installed in their IIS.
	' But if I remove it, it may be causing the browser to go blank on me.
	Session.codePage = 65001

	Response.ContentType="text/xml"
	Response.Write "<sR><sR conn='ok' /></sR>"
End If
%>