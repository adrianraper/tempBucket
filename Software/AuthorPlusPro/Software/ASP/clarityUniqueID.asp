<%
' v0.16.1, DL:
' This file contains functions for forming strings of time stamp and ClarityUniqueID
' getTimeStamp() - returns YYYYMMDDHHmmss
' getClarityUniqueID() - returns YYYYMMDDHHmmssnnn
' v6.4.0.1, DL:
' getCurrentServerTime() is now used for generating IDs
' ClarityUniqueID is found to be too long to fit in an integer field in databases
' use "milliseconds since 1 Jan 1970" instead
' however in ASP it is difficult to find the diff % now and and 1 Jan 1970 in milliseconds
' so i use seconds + 3 random integers instead
Randomize()

Function padZeros(s, n)
	Dim noOfZeros, i
	noOfZeros = n - len(s)
	If noOfZeros > 0 Then
		For i = 1 To noOfZeros
			s = "0" & s
		Next
	End If
	padZeros = s
End Function

Function getYear()
	Dim intY, strY
	intY = Year(now)
	strY = CStr(intY)
	getYear = padZeros(strY, 4)
End Function

Function getMonth()
	Dim intM, strM
	intM = Month(now)
	strM = CStr(intM)
	getMonth = padZeros(strM, 2)
End Function

Function getDay()
	Dim intD, strD
	intD = Day(now)
	strD = CStr(intD)
	getDay = padZeros(strD, 2)
End Function

Function getHour()
	Dim intH, strH
	intH = Hour(now)
	strH = CStr(intH)
	getHour = padZeros(strH, 2)
End Function

Function getMinute()
	Dim intM, strM
	intM = Minute(now)
	strM = CStr(intM)
	getMinute = padZeros(strM, 2)
End Function

Function getSecond()
	Dim intS, strS
	intS = Second(now)
	strS = CStr(intS)
	getSecond = padZeros(strS, 2)
End Function

Function getDate()
	getDate = getYear() & getMonth() & getDay()
End Function

Function getTime()
	getTime = getHour() & getMinute() & getSecond()
End Function

Function getRnd()
	Dim intR, strR
	intR = Int(1000 * Rnd)
	strR = CStr(intR)
	getRnd = padZeros(strR, 3)
End Function

Function getTimeStamp()
	getTimeStamp = getDate() & getTime()
End Function

Function getClarityUniqueID()
	getClarityUniqueID = getDate() & getTime() & getRnd()
End Function

Function getCurrentServerTime()
	Dim DateNow, DateStart
	DateNow = Now()
	DateStart = DateValue("01/01/1970")
	getCurrentServerTime = DateDiff("s", DateStart, DateNow) & getRnd()
End Function
%>