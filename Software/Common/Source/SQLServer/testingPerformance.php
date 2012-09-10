 <?php
 header("Content-Type: text/html");
 
// v6.5.6.4 Needs to be moved before XMLQuery which uses dates
// v6.5.5.4 If you use server time, ensure it is UTC
date_default_timezone_set("UTC");
$adodbPath= "../..";
require_once($adodbPath."/adodb5/adodb-exceptions.inc.php");
require_once($adodbPath."/adodb5/adodb.inc.php");
require_once(dirname(__FILE__)."/dbPath.php");

	// make the database connection
	global $db;
	if (isset($_REQUEST['dbHost'])) {
		$dbHost = intval($_REQUEST['dbHost']);
	} else {
		$dbHost = 248;
	}
	$dbDetails = new DBDetails($dbHost);
	// make the database connection
	// You shouldn't display the full details, but what is it safe to display?
	$db = ADONewConnection($dbDetails->dsn);
	echo $dbDetails->driver.'://'.$dbDetails->user.':'.'********'.'@'.$dbDetails->host.'/'.$dbDetails->dbname."</br>";
	if (!$db) die("Connection failed");
	//$db->debug = true;
	// v3.6 UTF8 character mismatch between PHP and MySQL
	if ($dbDetails->driver == 'mysql') {
		$charSetRC = mysql_set_charset('utf8');
	}
	$ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
	
 
	// Variables for testing the SQL calls
	$rootID = 1;
	$prefix= 'Clarity';
	$userID= 244580;
	$username= 'adrian raper';
	$groupID= 22150;

	$startTime = microtime(true);
	$startLoop = 1900;
	$endLoop = 1901;
	for ($year = $startLoop; $year <= $endLoop; $year++) {
	for ($i = 1; $i <= 27; $i++) {
		$select = true;
		$dateStamp = $year.date('-m-d H:i:s');
		switch ($i) {
		case 1:
			$sql = <<< SQL
					SELECT F_RootID AS rootID 
					FROM T_AccountRoot
					WHERE LOWER(F_Prefix)='$prefix';
SQL;
			break;
		case 2:
			$sql = <<< SQL
					SELECT r.*, t.* 
					FROM T_AccountRoot r, T_Accounts t
					WHERE r.F_RootID = $rootID
					AND r.F_RootID = t.F_RootID
					AND t.F_ProductCode = 52;
SQL;
		break;
		case 3:
			$sql = <<< SQL
					SELECT F_Key licenceKey, F_Value licenceValue, F_ProductCode productCode 
					FROM T_LicenceAttributes WHERE F_RootID=$rootID;
SQL;
		break;
		case 4:
			$sql = <<< SQL
					SELECT F_ContentLocation 
					FROM T_ProductLanguage
					WHERE F_ProductCode = 52
					AND F_LanguageCode = 'R2IFV';
SQL;
		break;
		case 6:
			$sql = <<< SQL
			   SELECT *
			   FROM T_Groupstructure g
			   WHERE g.F_GroupID=$groupID;
SQL;
		break;
		case 7:
			$sql = <<< SQL
				SELECT MAX(F_VersionNumber) as versionNumber 
				FROM T_DatabaseVersion;
SQL;
		break;
		case 8:
			$sql = <<< SQL
				SELECT g.F_GroupID as groupID,m.F_RootID,u.*				
				FROM T_User u LEFT JOIN 
				T_Membership m ON m.F_UserID = u.F_UserID LEFT JOIN
				T_Groupstructure g ON m.F_GroupID = g.F_GroupID 				
				WHERE u.F_UserName = '$username'
				AND (u.F_UserType=1 OR u.F_UserType=2 OR u.F_UserType=3 OR u.F_UserType=0 OR u.F_UserType=4)
				AND m.F_RootID=$rootID;
SQL;
		break;
		case 9:
			$sql = <<< SQL
					DELETE FROM T_Licences 
					WHERE F_ProductCode=52 
					AND F_RootID=$rootID
					AND (F_LastUpdateTime<'2012-08-29 04:00:16' OR F_LastUpdateTime is null);
SQL;
			$select = false;
		break;
		case 10:
			$sql = <<< SQL
					SELECT COUNT(F_LicenceID) as i FROM T_Licences 
					WHERE F_ProductCode=52
					AND F_RootID=$rootID;
SQL;
		break;
		case 11:
			$sql = <<< SQL
					INSERT INTO T_Licences (F_UserHost, F_StartTime, F_LastUpdateTime, F_RootID, F_ProductCode, F_UserID) VALUES
					('127.0.0.1', '2012-08-29 04:02:16', '2012-08-29 04:02:16', $rootID, 52, $userID);
SQL;
			$select = false;
			break;
		case 12:
			$sql = <<< SQL
					SELECT LAST_INSERT_ID();
SQL;
		break;
		case 13:
			$sql = <<< SQL
			   SELECT *
			   FROM T_Groupstructure g
			   WHERE g.F_GroupID=$groupID;
SQL;
		break;
		case 14:
			$sql = <<< SQL
				SELECT u.F_InstanceID as control
				FROM T_User u					
				WHERE u.F_UserID=$userID;
SQL;
		break;
		case 15:
			$sql = <<< SQL
				UPDATE T_User
				SET F_UserIP='127.0.0.1', 
					F_InstanceID='{"52":"1346212903197","53":1335853260375,"9":"1340690881828","0":"1340691353437","39":"1340691353437"}' 
				WHERE F_UserID=$userID;
SQL;
			$select = false;
			break;
		case 16:
			$sql = <<< SQL
				SELECT F_GroupID, F_ProductCode, F_CourseID, F_UnitID, F_ExerciseID, F_EnabledFlag
				FROM T_HiddenContent
				WHERE F_GroupID IN ($groupID)
				AND F_ProductCode=52 
				ORDER BY F_GroupID
SQL;
		break;
		case 17:
			$sql = <<< SQL
				SELECT s.*
				FROM T_Score as s
				WHERE s.F_UserID=$userID
				AND s.F_ProductCode=52
				ORDER BY s.F_CourseID, s.F_UnitID, s.F_ExerciseID;
SQL;
		break;
		case 18:
			$sql = <<< SQL
			   SELECT g.F_GroupID as groupID
			   FROM T_User u LEFT JOIN 
			   T_Membership m ON m.F_UserID = u.F_UserID LEFT JOIN
			   T_Groupstructure g ON m.F_GroupID=g.F_GroupID
			   WHERE u.F_UserID=$userID;
SQL;
		break;
		case 19:
			$sql = <<< SQL
				SELECT F_HiddenContentUID UID, F_EnabledFlag eF 
				FROM T_HiddenContent
				WHERE F_GroupID=$groupID
				AND F_ProductCode=52
				ORDER BY UID ASC;
SQL;
		break;
		case 20:
			$sql = <<< SQL
				INSERT INTO T_Session (F_UserID, F_StartDateStamp, F_EndDateStamp, F_Duration, F_RootID, F_ProductCode)
				VALUES ($userID, '$dateStamp','$dateStamp',60,$rootID,52);
SQL;
			$select = false;
			break;
		case 21:
			$sql = <<< SQL
				INSERT INTO T_Score (F_UserID,F_ProductCode,F_CourseID,F_UnitID,F_ExerciseID,
					F_Duration,F_Score,F_ScoreCorrect,F_ScoreWrong,F_ScoreMissed,
					F_DateStamp,F_SessionID)
				VALUES ($userID,52,1287130100000,1287130110000,1287130110003,5,-1,0,0,0,'$dateStamp',2228990)
SQL;
			$select = false;
			break;
		case 23:
		case 24:
		case 25:
			$sql = <<< SQL
				UPDATE T_Session
				SET F_EndDateStamp='2012-08-29 04:02:38',
				F_Duration=TIMESTAMPDIFF(SECOND,F_StartDateStamp,'2012-08-29 04:02:38')
				WHERE F_SessionID=2228990;
SQL;
			$select = false;
			break;
		case 26:
			$sql = <<< SQL
				SELECT F_CourseID, F_AverageScore as AverageScore, F_AverageDuration as AverageDuration, F_Count as Count FROM T_ScoreCache
				WHERE F_ProductCode = 52
				ORDER BY F_CourseID;
SQL;
			break;
		case 27:
			$sql = <<< SQL
				DELETE FROM T_Licences 
				WHERE F_LicenceID=193243;
SQL;
			$select = false;
			break;
		case 5:
		default:
			$sql = <<< SQL
			   SELECT g.F_GroupID as groupID
			   FROM T_User u LEFT JOIN 
			   T_Membership m ON m.F_UserID = u.F_UserID LEFT JOIN
			   T_Groupstructure g ON m.F_GroupID=g.F_GroupID
			   WHERE u.F_UserID=$userID;
SQL;
		break;
		}
		//echo $sql."</br>";
		$rs = $db->Execute($sql);
		if ($select)
			$rs->GetRows();
	}
	}
	$endTime = microtime(true);
	echo 'time taken for '.($endLoop - $startLoop + 1).' loops = '.($endTime - $startTime)."</br>";
	
