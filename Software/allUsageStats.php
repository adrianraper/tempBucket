<?php
global $node;
global $Db;
$node = "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\" /><title>Usage Statistics</title></head><body>";

$vars = array('DBHOST');
$thisPath = '../Database/dbDetails-MySQL.php';

if(!@file_exists($thisPath) ) {
   echo 'cannot find dbDetails file ' .$thisPath;
} else {
   include($thisPath);
}

function setHost($hostNum) {
	global $Db;
    global $node;

	$vars['DBHOST']=$hostNum;
	//echo 'dbHost=' .$vars['DBHOST'];
	//$node .= "Running with dbHost=" . $vars['DBHOST'] ."";
	//$node .= "<br>";
	$Db = new DB($vars);
}

function getStats($startDate) {
	global $Db;
    global $node;

	countStudents();
	if ($Db->num_rows > 0)  {
		foreach($Db->result as $row) {
		    $node .= "Students " .$row[STU] ." ";
		}
	} else {
	    $node .= "No students";
	}
	countTeachers();
	if ($Db->num_rows > 0)  {
		foreach($Db->result as $row) {
		    $node .= "Teachers " .$row[TEACH] ." ";
		}
	} else {
	    $node .= "No teachers";
	}
	countSessions($startDate);
	if ($Db->num_rows > 0)  {
		foreach($Db->result as $row) {
		    $node .= "Sessions " .$row[SESSIONS] ." ";
		}
	} else {
	    $node .= "No sessions";
	}
}
function countStudents() {
	global $Db;
	$sql = "SELECT COUNT(T_User.F_UserID) AS STU
   FROM T_User 
   WHERE T_User.F_UserType=0;";
	$Db->query($sql);
}
function countTeachers() {
	global $Db;
	$sql = "SELECT COUNT(T_User.F_UserID) AS TEACH
   FROM T_User 
   WHERE T_User.F_UserType=1;";
	$Db->query($sql);
}
function countSessions($startDate) {
	global $Db;
	$sql = "SELECT COUNT(T_Session.F_UserID) AS SESSIONS
   FROM T_Session WHERE F_StartDateStamp>='$startDate';"; 
	$Db->query($sql);
}

// The report
$node .= "<usageStats>";
$startDate = $_GET["startDate"];
if ($startDate=='' || $startDate==undefined) $startDate = '2006-11-24';
$node .= "Since $startDate";
$node .= "<br>";

// For AAM
$node .= "AAM ";
setHost(13);
$Db->open("score");
getStats($startDate);
$Db->disconnect();
$node .= "<br>";

// For AAW
$node .= "AAW ";
setHost(2);
$Db->open("score");
getStats($startDate);
$Db->disconnect();
$node .= "<br>";

// For ADM
$node .= "ADM ";
setHost(3);
$Db->open("score");
getStats($startDate);
$Db->disconnect();
$node .= "<br>";

// For ADW
$node .= "ADW ";
setHost(4);
$Db->open("score");
getStats($startDate);
$Db->disconnect();
$node .= "<br>";

// For DBM
$node .= "DBM ";
setHost(5);
$Db->open("score");
getStats($startDate);
$Db->disconnect();
$node .= "<br>";

// For DBW
$node .= "DBW ";
setHost(6);
$Db->open("score");
getStats($startDate);
$Db->disconnect();
$node .= "<br>";

// For FJM
$node .= "FJM ";
setHost(7);
$Db->open("score");
getStats($startDate);
$Db->disconnect();
$node .= "<br>";

// For FJW
$node .= "FJW ";
setHost(8);
$Db->open("score");
getStats($startDate);
$Db->disconnect();
$node .= "<br>";

// For RKM
$node .= "RKM ";
setHost(9);
$Db->open("score");
getStats($startDate);
$Db->disconnect();
$node .= "<br>";

// For RKW
$node .= "RKW ";
setHost(10);
$Db->open("score");
getStats($startDate);
$Db->disconnect();
$node .= "<br>";

// For SJM
$node .= "SJM ";
setHost(11);
$Db->open("score");
getStats($startDate);
$Db->disconnect();
$node .= "<br>";

// For SJW
$node .= "SJW ";
setHost(12);
$Db->open("score");
getStats($startDate);
$Db->disconnect();
$node .= "<br>";

//$node .= "</usageStats>";
$node .= "</body></html>";

print($node);
?>
