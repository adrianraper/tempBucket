<?php

require_once(dirname(__FILE__)."/../../config.php");
require_once($GLOBALS['adodb_libs']."adodb-exceptions.inc.php");
require_once($GLOBALS['adodb_libs']."adodb.inc.php");

	$GLOBALS['db'] = "mysql://AppUser:Sunshine1787@localhost/hct";

	session_start();
	header('Content-Type: text/plain');

	// Force all PHP function to work in UTC
	date_default_timezone_set("UTC");
	
	// Small optimization
	$ADODB_COUNTRECS = false;
	
	// Persistant connections are faster, but on my setup (XP Pro SP2, SQL Server 2008 Express) this causes sporadic crashes.
	// Check on the production server to see if it works with that configuration.
	$db = &ADONewConnection($GLOBALS['db']."?persist");
	
	//$this->db = &ADONewConnection($GLOBALS['db']);
	
	$db->SetFetchMode(ADODB_FETCH_ASSOC);

function addDaysToTimestamp($timestamp, $days) {
	//return date("Y-m-d", $timestamp + ($days * 86400));
	return $timestamp + ($days * 86400);
}
function runQuery($startDate, $endDate) {
	global $db;
	$allTitles = array();
	$colleges = array('aam', 'aaw','adm', 'adw','dbm', 'dbw','fjm', 'fjw','rkm', 'rkw','sjm', 'sjw','mzc', 'ruc', 'ieltsa');
	foreach ($colleges as $collegePrefix) {
		$college = $collegePrefix."_session";
		$sql = 	<<< EOD
				select count(distinct F_UserID) as licences, c.F_ProductCode as title 
				from $college s, t_courses c 
				where F_StartDateStamp >= ? 
				and F_StartDateStamp <= ? 
				and s.F_CourseID = c.F_CourseID 
				group by c.F_ProductCode
				order by c.F_ProductCode;
EOD;
		//$resultObj = $db->GetRow($sql, array(163));
		
		$rs = $db->GetArray($sql, array($startDate, $endDate));
		$collegeTotal=0;
		foreach ($rs as $row) {
			//echo $row['title'].",".$row['licences']."\n";
			if (isset($allTitles[$row['title']])) {
				$allTitles[$row['title']] += $row['licences'];
			} else {
				$allTitles[$row['title']] = $row['licences'];
			}
			$collegeTotal+=$row['licences'];
			//echo "licences=".$row['licences']." for title=".$row['title']."\n";
		}
		echo "$collegePrefix used $collegeTotal\n";
	}
	// Then for the IELTS GT database, which use the same courseIDs as IELTS Academic so you have to do it independently
		$collegePrefix = 'ieltsg';
		$college = $collegePrefix."_session";
		$sql = 	<<< EOD
				select count(distinct F_UserID) as licences, '13' as title 
				from $college s, t_courses c 
				where F_StartDateStamp >= ? 
				and F_StartDateStamp <= ? 
				and s.F_CourseID = c.F_CourseID 
				group by c.F_ProductCode
				order by c.F_ProductCode;
EOD;
		//$resultObj = $db->GetRow($sql, array(163));
		
		$rs = $db->GetArray($sql, array($startDate, $endDate));
		$collegeTotal=0;
		foreach ($rs as $row) {
			//echo $row['title'].",".$row['licences']."\n";
			if (isset($allTitles[$row['title']])) {
				$allTitles[$row['title']] += $row['licences'];
			} else {
				$allTitles[$row['title']] = $row['licences'];
			}
			$collegeTotal+=$row['licences'];
			//echo "licences=".$row['licences']." for title=".$row['title']."\n";
		}
		echo "$collegePrefix used $collegeTotal\n";
	

	echo "\nTotals $startDate to $endDate\n";
	echo "title, licences\n";
	foreach ($allTitles as $key => $value) {
		echo "$key,$value\n";
	}
}

/* 
 * ready for PHP 5.3!
	$startDate = new DateTime('2009-09-01 00:00:00');
	$endDate = new DateTime('2009-09-01 00:00:00');
	$endDate-> add(new DateInterval('P1YT23H59M59S'));
*/
	
	$startYear = array(2005, 2006, 2007, 2008, 2009);
	//$startYear = array(2009);
	foreach ($startYear as $year) {
		$startDate = strtotime($year.'-09-01 00:00:00');
		$endDate = strtotime(($year+1).'-08-31 23:59:59');
		runQuery(date('Y-m-d H:i:s', $startDate), date('Y-m-d H:i:s', $endDate));
		echo "\n=================\n\n";
	}
exit(0)
?>
