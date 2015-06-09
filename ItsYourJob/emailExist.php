<?php
	
	$user_email=$_POST['IYJ_ForgetEmail'];

	require_once('../db_login.php');
	$resultset = $db->Execute("select F_UserName, F_StudentID, F_Password from T_User where F_Email=?",array($user_email));
	
	if (!$resultset) {
		echo "-1";
		break;
	} else {
		/*switch ($resultset->RecordCount()) {
			case 0:
				echo "0";
				break;
			case 1:
				echo "1";
				break;
			default:
				echo "-1";
				break;
		} */
		echo $resultset->RecordCount();
	}
	$resultset->Close();
	// NOTE can we also close the connection?
	$db->Close();

?>