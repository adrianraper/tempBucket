<%
Sub getDecryptKey(Query)
	Dim sql, userID, groupType, rootID
	sql = "SELECT F_KeyBase FROM T_Encryptkey WHERE F_KeyID=" & Clng(Query.eKey) & ";"
	rsProgress.open sql, connProgress, , adLockOptimistic
	
	If Not rsProgress.eof Then
		xmlNode = xmlNode & "<decrypt success='true' key='" & rsProgress.fields("F_KeyBase") & "' />"
	Else
		xmlNode = xmlNode & "<decrypt success='false' />"
	End If
	rsProgress.close
End Sub
%>
<%
Sub checkLogin(Query)
	Dim sql, userID, fullname, email, groupType, rootID, groupDominant
	'sql = "SELECT F_UserID, F_Password, F_FullName, F_Email FROM T_User WHERE F_UserName='" & Query.Username & "' AND F_Password='" & Query.Password & "' AND (F_UserType=1 OR F_UserType=2)"
	'sql = "SELECT F_UserID, F_Password, F_FullName, F_Email FROM T_User WHERE F_UserName='" & Query.Username & "' AND (F_UserType=1 OR F_UserType=2)"
	'v6.4.2.1 RootID should be passed, but isn't. So until then, allow any root
	'v6.4.3 Now it is
	'sql = "SELECT T_User.* FROM T_User, T_Membership WHERE F_UserName='" & Query.Username & "';"
	'sql = "SELECT T_User.* FROM T_User, T_Membership WHERE F_UserName='" & Query.Username & "' " &_
	sql = "SELECT T_User.* FROM T_User, T_Membership WHERE F_UserName= ?" &_
		" AND T_User.F_UserID = T_Membership.F_UserID " &_
		" AND T_Membership.F_RootID=" & CLng(Query.RootID) & ";"
		
	' v6.5.3 Parameters
	Dim ADOCmd
	Set ADOCmd= CreateObject("ADODB.Command")
	ADOCmd.ActiveConnection= connProgress
	ADOCmd.CommandType= adCmdText
	ADOCmd.CommandText= sql

	Dim PName
	Set PName= CreateObject("ADODB.Parameter")
	PName.Type= adVarWChar
	PName.Size= 64
	PName.Direction= adParamInput
	PName.Value= Query.Username
	ADOCmd.Parameters.Append PName
	Set rsProgress= ADOCmd.Execute
	Set ADOCmd = nothing
		
	'xmlNode = xmlNode & "<note>" & sql & "</note>"
	'rsProgress.open sql, connProgress, , adLockOptimistic
	
	If rsProgress.bof and rsProgress.eof Then
		xmlNode = xmlNode & "<login success='false' info='no such user' />"
	Else

		' v0.6.0, DL: case-sensitive password checking
		If rsProgress.fields("F_Password") <> Query.Password Then
			xmlNode = xmlNode & "<login success='false' info='invalid password' />"
		ElseIf rsProgress.fields("F_UserType")=0 Then
			xmlNode = xmlNode & "<login success='false' info='user is only a student' />"
		Else
			dim thisName, userName
			userID = rsProgress.fields("F_UserID")
			userName = rsProgress.fields("F_UserName")
			fullname = rsProgress.fields("F_FullName")
			email = rsProgress.fields("F_Email")
			' AR v6.4.2.6 Just ignore fullname
			'if (fullname <> "") then
			'	thisName = fullName
			'Else
				thisName = userName
			'End If
			' AR v6.4.2.6 Also need userSettings for editing TB
			'xmlNode = xmlNode & "<login success='true' name='" & thisName & "' userID='" & userID & "' email='" & email & "' />"
			dim userSettings
			userSettings = rsProgress.fields("F_UserSettings")
			xmlNode = xmlNode & "<login success='true' name='" & thisName & "' userID='" & userID & "' email='" & email & "' userSettings='" & userSettings & "' />"
		End If
	End If
	rsProgress.close
End Sub
%>
<%
' v6.4.2.5 Functions for MGS checking
Sub checkMGS(Query)
	on error goto 0
	Dim sql, groupID
	' v6.4.2.6 Use UserID rather than UserName
	'sql = "SELECT F_EnableMGS, F_MGSName, T_Groupstructure.F_GroupParent " &_
	'	" FROM T_Groupstructure, T_Membership, T_User " &_
	'	" WHERE T_User.F_Username='" & Query.Username & "'" &_
	'	" AND T_User.F_UserID=T_Membership.F_UserID AND T_Membership.F_GroupID=T_Groupstructure.F_GroupID;"
	sql = "SELECT F_EnableMGS, F_MGSName, F_GroupParent " &_
		" FROM T_Groupstructure, T_Membership " &_
		" WHERE T_Membership.F_UserID=" & Query.UserID &_
		" AND T_Membership.F_GroupID=T_Groupstructure.F_GroupID;"
		
	'xmlNode = xmlNode & "<note>" & sql & "</note>"
	rsProgress.open sql, connProgress, , adLockOptimistic
	
	If rsProgress.bof and rsProgress.eof Then
		xmlNode = xmlNode & "<checkMGS success='false' />"
	Else
		' query success
		' if we found it directly, go back, otherwise need to check the parent
		'xmlNode = xmlNode & "<note>" & "enableMGS=" & rsProgress.fields("F_EnableMGS") & " parent=" & rsProgress.fields("F_GroupParent") & "</note>"
		' v6.4.2.6 Handle nulls
		dim myEnableMGS
		myEnableMGS = rsProgress.fields("F_EnableMGS")
		if IsNull(myEnableMGS) then 
			myEnableMGS=0
		end if
		If myEnableMGS >0 Then
			xmlNode = xmlNode & "<checkMGS success='true' enableMGS='1' name='" & rsProgress.fields("F_MGSName") & "' />"
			rsProgress.close
		else
			'xmlNode = xmlNode & "<note>go deeper</note>"
			' pass the parent group
			groupID = rsProgress.fields("F_GroupParent")
			rsProgress.close
			getParentGroup(groupID)
		end if
	End If
End Sub
%>
<%
' v6.4.2.5 Functions for MGS checking
Sub getParentGroup(groupID)
	on error goto 0
	Dim sql
	sql = "SELECT F_GroupID, F_EnableMGS, F_MGSName, F_GroupParent from T_Groupstructure WHERE F_GroupID=" & CLng(groupID) & ";"
	'xmlNode = xmlNode & "<note>" & sql & "</note>"
		
	rsProgress.open sql, connProgress, , adLockOptimistic
	
	If rsProgress.bof and rsProgress.eof Then
		' no rows should be impossible
		xmlNode = xmlNode & "<checkMGS success='false' />"
		rsProgress.close
	else 
		' we found the group, does it have MGS enabled?
		'xmlNode = xmlNode & "<note>" & "enableMGS=" & rsProgress.fields("F_EnableMGS") & " parent=" & rsProgress.fields("F_GroupParent") & "</note>"
		dim myEnableMGS, myMGSName, myGroupParent
		myGroupParent = rsProgress.fields("F_GroupParent")
		myEnableMGS = rsProgress.fields("F_EnableMGS")
		if IsNull(myEnableMGS) then 
			myEnableMGS=0
		end if
		'xmlNode = xmlNode & "<note>got a row here</note>"
		if myEnableMGS > 0 Then
			myMGSName = rsProgress.fields("F_MGSName")
			if IsNull(myMGSName) then 
				myMGSName=""
			end if
			xmlNode = xmlNode & "<checkMGS success='true' enableMGS='" & myEnableMGS & "' name='" & myMGSName & "' />"
			rsProgress.close
		' no, is it the top level
		elseif rsProgress.fields("F_GroupID") = myGroupParent then
			xmlNode = xmlNode & "<checkMGS success='true' enableMGS='0' MGSName='' />"
			rsProgress.close
		else 
			' recurse to check it's parent Group has MGS enable or not
			rsProgress.close
			'xmlNode = xmlNode & "<note>go deeper</note>"
			getParentGroup(myGroupParent)
		end if
	End If
End Sub
%>


<%
Class XMLQuery

	Public dbPath
	Public Purpose
	
	Public Username
	Public UserID
	Public Password
	Public RootID
	
	Public eKey
	
	Public Sub parseXMLQuery(root)
		Dim queryNode, node
		Set queryNode = root.childNodes
		For Each node In queryNode
			fillInAttributes node
		Next
	End Sub

	Private Sub fillInAttributes(node)
		' v6.4.3 Default value
		RootID = 1
		dbPath = ""
		Select Case Ucase(node.nodeName)
			Case "PURPOSE"
				Purpose = node.firstChild.nodeValue
			Case "USERNAME"
				Username = node.firstChild.nodeValue
			Case "USERID"
				UserID = node.firstChild.nodeValue
			Case "PASSWORD"
				Password = node.firstChild.nodeValue
			Case "ROOTID"
				RootID = node.firstChild.nodeValue
			Case "EKEY"
				eKey = node.firstChild.nodeValue
		End Select
	End Sub

End Class
%>