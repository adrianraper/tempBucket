<?php
	
	$user_email=$_POST['IYJreg_uEmail'];
	$user_password=$_POST['IYJreg_uPassword'];

	require_once('../db_login.php');
	//$resultset = $db->Execute("select F_Email from T_User where F_Email=?",array($user_email));
	$resultset = $db->Execute("SELECT U.F_UserName, U.F_Password as db_pwd FROM T_USER U JOIN T_MEMBERSHIP M ON U.F_USERID=M.F_USERID JOIN T_ACCOUNTS T ON M.F_ROOTID=T.F_ROOTID WHERE T.F_PRODUCTCODE=1001 AND U.F_Email=?",array($user_email));
	
	if (!$resultset) {
		$errorMsg = $db->ErrorMsg();
	} else {
		If ($resultset->RecordCount()==1) {
			If ($user_password==$resultset->fields['db_pwd'])
				echo "yes";
			else
				echo "no";
		} else {
			echo "no";
		}
	}
	$resultset->Close();
	// NOTE can we also close the connection?
	$db->Close();
?>