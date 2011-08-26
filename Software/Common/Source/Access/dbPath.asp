<%
' *****
' * just change this start of this line if you use a webshare name other than Clarity
' *****
%>
<!--#include virtual="/Fixbench/Database/dbDetails-Access.asp"--> 
<% 
' a function for turning a real date into a database expected formatted string
' for SQL Server use YYYYMMDD HH:MM:SS - assume hours are 1-24 and that numbers are zero padded
'    and pad with single quote characters
' for Access, just pad with #
function dateFormat (thisDate)
'	dateFormat = "'" & ZeroPad(Year(thisDate)) & "" & ZeroPad(Month(thisDate)) & "" & ZeroPad(Day(thisDate)) & " " & ZeroPad(Hour(thisDate)) & ":" & ZeroPad(Minute(thisDate)) & ":" & ZeroPad(Second(thisDate)) & "'"
	dateFormat = "#" & thisDate & "#"
end function
function ZeroPad (num)
	if num < 10 then
		ZeroPad = "0" + CStr(num)
	else
		ZeroPad = CStr(num)
	end if
end function
%>
