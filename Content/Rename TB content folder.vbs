Set objFSO = CreateObject("Scripting.FileSystemObject")
TBFolder = "TenseBuster-NAmerican"
FolderWithCourses = TBFolder + "\Courses\"
If objFSO.FolderExists(FolderWithCourses) Then
	If objFSO.FolderExists(FolderWithCourses + "TB ADV NAmEng") Then
		objFSO.MoveFolder FolderWithCourses + "TB ADV NAmEng",FolderWithCourses + "1196935701119"
	End if
	If objFSO.FolderExists(FolderWithCourses + "TB UI NAmEng") Then
		objFSO.MoveFolder FolderWithCourses + "TB UI NAmEng",FolderWithCourses + "1190277377521"
	End if
	If objFSO.FolderExists(FolderWithCourses + "TB INT NAmEng") Then
		objFSO.MoveFolder FolderWithCourses + "TB INT NAmEng",FolderWithCourses + "1195467488046"
	End if
	If objFSO.FolderExists(FolderWithCourses + "TB LI NAmEng") Then
		objFSO.MoveFolder FolderWithCourses + "TB LI NAmEng",FolderWithCourses + "1189060123431"
	End if
	If objFSO.FolderExists(FolderWithCourses + "TB ELE NAmEng") Then
		objFSO.MoveFolder FolderWithCourses + "TB ELE NAmEng",FolderWithCourses + "1189057932446"
	End if
    Wscript.Echo TBFolder + " renamed"
Else
    Wscript.Echo FolderWithCourses + " does not exist"
End If
TBFolder = "TenseBuster-Turkish"
FolderWithCourses = TBFolder + "\Courses\"
If objFSO.FolderExists(FolderWithCourses) Then
	If objFSO.FolderExists(FolderWithCourses + "TB ADV") Then
		objFSO.MoveFolder FolderWithCourses + "TB ADV",FolderWithCourses + "1196935701119"
	End if
	If objFSO.FolderExists(FolderWithCourses + "TB UI") Then
		objFSO.MoveFolder FolderWithCourses + "TB UI",FolderWithCourses + "1190277377521"
	End if
	If objFSO.FolderExists(FolderWithCourses + "TB INT") Then
		objFSO.MoveFolder FolderWithCourses + "TB INT",FolderWithCourses + "1195467488046"
	End if
	If objFSO.FolderExists(FolderWithCourses + "TB LI") Then
		objFSO.MoveFolder FolderWithCourses + "TB LI",FolderWithCourses + "1189060123431"
	End if
	If objFSO.FolderExists(FolderWithCourses + "TB ELE") Then
		objFSO.MoveFolder FolderWithCourses + "TB ELE",FolderWithCourses + "1189057932446"
	End if
    Wscript.Echo TBFolder + " renamed"
Else
    Wscript.Echo FolderWithCourses + " does not exist"
End If
