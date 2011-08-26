<%
function getLicenceSlot (mQ)
	dim liT, liN, rC, sT, mode
	liT = mQ.licences
	if CInt(liT) <= 0 then
		getLicenceSlot = 1 
		xmlNode = xmlNode & "<err code='201'>your licence is invalid (0 users)</err>"
		exit function
	end if
	if CLng(mQ.licenceID) > 0 then
		mode=0
		sT = Licence.countLicences(mQ, mode, null)
		if sT > 0 then
			getLicenceSlot = 0
			exit function
		else
		end if
	end if		
	mode=1
	liN = Licence.countLicences(mQ, mode, null)

	'xmlNode = xmlNode & "<note>compare liN and liT=" & CStr(liN) & ", " & CStr(liT) & "</note>"
	if CInt(liN) < CInt(liT) then
	' v6.3.3 Use rootID in connection table
		rC = insertLicenceRecord(mQ, liN, liT)
	else
		dim rN, jN, oRd
		rN = Now
		jN = DateAdd("n", timeDelay, rN)
		xmlNode = xmlNode & "<note>any licences not updated since " & CStr(jN) & "?</note>"
		mode=2
		oRd = Licence.countLicences(mQ, mode, jN)

		if oRd > 0 then
			Licence.deleteLicencesOld jN
			liN = CInt(liN) - CInt(oRd)
			xmlNode = xmlNode & "<warning>" & CStr(oRd) & " licence(s) released</warning>"
			if CInt(liN) < CInt(liT) then
				' v6.3.3 Use rootID in connection table
				rC = insertLicenceRecord(mQ, liN, liT)
			else 
				xmlNode = xmlNode & "<err code='201'>no free licences (" & liN & ")</err>"
				rC = 1
			end if
		else 
			xmlNode = xmlNode & "<err code='201'>no free licences (" & liN & " are not too old)</err>"
			rC = 1
		end if
	end if
	if rC = 0 then
		getLicenceSlot = 0
	else
		getLicenceSlot = 1
	end if
	'Licence.closeRS
end function
%>
<%
' v6.3.3 Use rootID in connection table
function insertLicenceRecord (mQ, liN, liT)
	dim rN, siL
	rN = Now
	Licence.insertLicence mQ, rN
	siL = Licence.selectInsertedLicence(rN)
	if siL >= 0 then
		xmlNode = xmlNode &_
				"<licence host='" & Request.ServerVariables("REMOTE_ADDR") & "' " &_ 
				"ID='" & siL & "' " &_ 
				"note='" & CStr(CInt(liN) + 1) & " of " & liT & "' />"
		insertLicenceRecord = 0
	else
		xmlNode = xmlNode & "<err code='202'>failed to insert licence record</err>"
		insertLicenceRecord = 1
	end if
	'Licence.closeRS
end function
%>
<%
function updateLicence (mQ)
	dim saveNow
	saveNow = Now
	Licence.updateLicence mQ.licenceID, saveNow
	if not Err.Number = 0 then
		xmlNode = xmlNode & "<err code='205'>your licence is not being updated</err>"
		updateLicence = 1
	else
		xmlNode = xmlNode & "<licence id='" & CStr(mQ.licenceID) & "'>updated</licence>"
		updateLicence = 0
	end if
	on error goto 0
	'Licence.closeRS
end function
%>
<%
function dropLicence (mQ)
	'dim saveNow
	'saveNow = Now
	Licence.deleteLicencesID mQ.licenceID
	if not Err.Number = 0 then
		xmlNode = xmlNode & "<err code='205'>your licence is not being updated</err>"
		dropLicence = 1
	else
		xmlNode = xmlNode & "<licence id='" & CStr(mQ.licenceID) & "'>dropped</licence>"
		dropLicence = 0
	end if
	on error goto 0
	'Licence.closeRS
end function
%>
<%
' v6.3.3 Use rootID in connection table
function failLicenceSlot (mQ)
	dim rN
	rN = Now
	on error resume next
	Licence.insertFail mQ, rN
	xmlNode = xmlNode & "<note>licence failure recorded</note>"
	failLicenceSlot = 0
	on error goto 0
	'Licence.closeRS
end function
%>
