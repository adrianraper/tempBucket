<?php
session_start();

date_default_timezone_set('UTC');
require_once("Variables.php");
$rootPath= $_SERVER['DOCUMENT_ROOT'];
$dbPath= $rootPath.'/Database';
$adodbPath= $rootPath.'/Software/Common';
require_once($adodbPath."/adodb5/adodb-exceptions.inc.php");
require_once($adodbPath."/adodb5/adodb.inc.php");
require_once($dbPath."/dbDetails.php");

$id=$_REQUEST['id'];
$pwd=$_REQUEST['pwd'];
//error_log("IYJOnline.com:	id is ".$id." password is $pwd \n", 3, "../Debug/debug_iyj.log");
#main action
checkUser($id,$pwd);

if ( ( $_SESSION['USERID'] > 0 ) AND ( $_SESSION['ROOTID'] > 0 ) )
	echo 'yes:'.$_SESSION['PREFIX'];
else
	echo $_SESSION['FAILREASON'];
	
function showDate($ts) {
	return date("j M Y",strtotime($ts));
}	

function checkUser($id, $password){
	$dbDetails = new DBDetails(2);
	$db = &ADONewConnection($dbDetails->dsn);
	if (!$db) error_log("IYJOnline.com:	Connect db failed".$dbDetails->dsn."\n", 3, "../Debug/debug_iyj.log");
	$ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
	$sql = "SELECT *
			FROM T_User u, T_Membership m, T_Accounts a, T_AccountRoot r
			WHERE u.F_UserName=? AND u.F_Password=? AND m.F_UserID=u.F_UserID 
			AND a.F_ProductCode='1001' AND m.F_RootID=a.F_RootID
			AND r.F_RootID = a.F_RootID";

			$rq = $db->Execute( $sql, array($id, $password) );
	if(isset($_SESSION['FAILREASON'])){
		unset($_SESSION['FAILREASON']);
	}
	
	switch($rq->RecordCount()) {
		case 0:
			$_SESSION['FAILREASON'] = 101;
			break;
		
		case 1:
			//error_log("IYJOnline.com:	Result user id is ".$rq->fields['F_UserID']."\n", 3, "../Debug/debug_iyj.log");
			$_SESSION['USERID'] = $rq->fields['F_UserID'];
			$_SESSION['ROOTID'] = $rq->fields['F_RootID'];
			$_SESSION['EMAIL'] = $rq->fields['F_Email'];
			$_SESSION['USERTYPE'] = $rq->fields['F_UserType'];
			$_SESSION['USERNAME'] = $rq->fields['F_UserName'];
			$_SESSION['COUNTRY'] = $rq->fields['F_Country'];
			$_SESSION['STARTDATE'] = $rq->fields['F_StartDay'];
			$_SESSION['USEREXPIRYDATE'] = $rq->fields['F_ExpiryDate'];
			$_SESSION['PREFIX'] = $rq->fields['F_Prefix'];
			break;
			
		default:
			$_SESSION['FAILREASON'] = 203;
	}
	
	$rq->Close();
	$db->Close();

}

?>
