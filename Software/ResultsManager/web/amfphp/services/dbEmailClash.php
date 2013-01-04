<?php
/*
 * To run code on the database
 */
require_once(dirname(__FILE__)."/MinimalService.php");
$thisService = new MinimalService();

if (isset($_GET['email'])) {
	$email = $_GET['email'];
} else {
	$email = '';
}
if (isset($_GET['update'])) {
	$update = true;
} else {
	$update = false;
}

header('Content-Type: text/plain; charset=utf-8');
$newLine = "\n";

/*
 * Action for the script
 */
try {
	// Do you want to just see the user?
	if ($email && !$update) {
		$sql = 	<<<EOD
			select * from T_User
			where F_Email = ?
EOD;
		$rs = $thisService->db->Execute($sql, array($email));
		if ($rs) {
			if ($rs->RecordCount() == 0) {
				echo "no such email$newLine";
			} else {
				while ($dbObj = $rs->FetchNextObj()) {
					echo $dbObj->F_UserName.', '.$dbObj->F_Email.', '.$dbObj->F_StudentID.', '.$newLine;
				}
			}			
		} else {
			echo "Select failed";		
		}
		
	} else if ($email && $update) {
		$sql = 	<<<EOD
			update T_User
			set F_Email = ?
			where F_Email = ?
EOD;
		$rs = $thisService->db->Execute($sql, array('xx-'.$email, $email));
		if ($rs) {
			if ($thisService->db->Affected_Rows() == 0) {
				echo "no such email$newLine";
			} else {
				$sql = 	<<<EOD
					select * from T_User
					where F_Email = ?
EOD;
				$rs = $thisService->db->Execute($sql, array('xx-'.$email));
				if ($rs) {
					if ($rs->RecordCount() == 0) {
						echo "Update failed$newLine";
					} else {
						while ($dbObj = $rs->FetchNextObj()) {
							echo $dbObj->F_UserName.', '.$dbObj->F_Email.', '.$dbObj->F_StudentID.', '.$newLine;
						}
					}			
				} else {
					echo "Update failed";		
				}
			}
		} else {
			echo "Update failed";		
		}
		
	}
		
} catch (Exception $e) {
	echo $e->getMessage();
}	

flush();
exit(0);
