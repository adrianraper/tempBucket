<?php
	
	$user_email=$_POST['userEmail'];

	require_once('db_login.php');
	//$resultset = $db->Execute("select F_Email from T_User where F_Email=?",array($user_email));
	//$resultset = $db->Execute("SELECT distinct U.F_Email FROM T_USER U JOIN T_MEMBERSHIP M ON U.F_USERID=M.F_USERID JOIN T_ACCOUNTS A ON A.F_ROOTID=M.F_ROOTID WHERE U.F_Email=? AND A.F_LICENCETYPE=5",array($user_email));
	//3 Nov 10 RL: do the checking same as RM ManageableOps
	// AR Just a little easier to read
	//$resultset = $db->Execute("SELECT U.F_USERID FROM T_USER U JOIN T_MEMBERSHIP M ON U.F_USERID=M.F_USERID JOIN T_ACCOUNTS A ON A.F_ROOTID=M.F_ROOTID WHERE U.F_Email=? AND A.F_LICENCETYPE=5",array($user_email));
	$sql = <<<EOD
				SELECT distinct(u.F_UserID)
				FROM T_User u 
				JOIN T_Membership m ON u.F_UserID = m.F_UserID 
				JOIN T_Accounts t ON m.F_RootID = t.F_RootID 
				WHERE u.F_Email = ?
				AND t.F_LicenceType = 5
EOD;

	$resultset = $db->Execute($sql,array($user_email));
	if (!$resultset) {
		$rtn = $db->ErrorMsg();
	} else {
		if ($resultset->RecordCount() > 1)
			$rtn = '2';
		else
			$rtn = ($resultset->RecordCount());
	}
	echo $rtn;
	$resultset->Close();
	// NOTE can we also close the connection?
	$db->Close();

?>