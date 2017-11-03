<?php
/*
 * This script extracts data for a specialised report.
 * In this case, VAS account, grouping by class with some filtering.
 */

require_once(dirname(__FILE__)."/MinimalService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");

ini_set('max_execution_time', 300); // 5 minutes

// Don't get fooled by old session variables
if (isset($_SESSION['dbHost'])) unset($_SESSION['dbHost']);
if (isset($_REQUEST['dbHost'])) $_SESSION['dbHost']=$_REQUEST['dbHost'];
$fromDate = (isset($_REQUEST['fromDate'])) ? new DateTime($_REQUEST['fromDate']) : new DateTime();
$toDate = (isset($_REQUEST['toDate'])) ? new DateTime($_REQUEST['toDate']) : new DateTime();

$thisService = new MinimalService();

date_default_timezone_set('UTC');
if (!Authenticate::isAuthenticated()) {
	// TODO: Replace with text from literals
	// v3.0.6 This script may be run by CRON too, in which case skip authentication. How to tell?
	/*
	if (isset($_SERVER["SERVER_NAME"])) {
		echo "<h2>You are not logged in</h2>";
		exit(0);
	}
	*/
}
// Set up line breaks for whether this is outputting to html page or a text file
if (isset($_SERVER["SERVER_NAME"])) {
	$newLine = '<br/>';
} else {
	$newLine = "\n";
}

// NOTE: Sometime convert all away from timestamps to DateTime objects
function addDaysToTimestamp($timestamp, $days) {
	//return date("Y-m-d", $timestamp + ($days * 86400));
	return $timestamp + ($days * 86400);
}

// Maybe I will want to be able to pass an array of triggers to this as well as getting all of them
function generateSpecialReport($reportCode, $fromDate, $toDate) {
	global $thisService;
	global $newLine;
	
	switch ($reportCode) {
        case 1:
            $topGroupId = 10379; // 48263;
            echo "Group usage report from ".$fromDate->format('Y-m-d')." to " . $toDate->format('Y-m-d')."$newLine";
            $campusIds = $thisService->manageableOps->getSubgroupsOfThisGroup($topGroupId);
            foreach ($campusIds as $campusId) {
                $campus = $thisService->manageableOps->getGroup($campusId);
                echo "$newLine" . $campus->name . " campus $newLine";
                echo "group,title,exercises,minutes $newLine";
                $classIds = $thisService->manageableOps->getSubgroupsOfThisGroup($campusId);
                if (count($classIds) > 0) {
                    $classIdsList = implode(',', $classIds);
                    $sql = <<< SQL
                        SELECT g.F_GroupName groupName,s.F_ProductCode productCode,
                        COUNT(distinct(u.F_UserID)) users,
                        AVG(CASE s.F_Score WHEN -1 THEN NULL ELSE s.F_Score END) average_score,
                        COUNT(s.F_Score) complete,
                        AVG(s.F_Duration) average_time,
                        SUM(s.F_Duration) total_time 
                        FROM T_Score s 
                        INNER JOIN T_User u ON s.F_UserID=u.F_UserID 
                        INNER JOIN T_Membership m ON s.F_UserID=m.F_UserID 
                        INNER JOIN T_Groupstructure g on g.F_GroupID = m.F_GroupID 
                        WHERE g.F_GroupID IN ($classIdsList) 
                        AND u.F_UserType=0
                        and (s.F_Score >= 50 OR s.F_Score = -1) 
                        and s.F_DateStamp >= ?
                        and s.F_DateStamp <= ?
                        and s.F_ProductCode > 0
                        GROUP BY s.F_ProductCode,g.F_GroupName
                        ORDER BY s.F_ProductCode,total_time desc; 
SQL;
                    $bindingParams = array($fromDate->format('Y-m-d'), $toDate->format('Y-m-d'));
                    $rs = $thisService->db->Execute($sql, $bindingParams);

                    switch ($rs->RecordCount()) {
                        case 0:
                            echo "-$newLine";
                        default:
                            while ($record = $rs->FetchNextObj()) {
                                switch ($record->productCode) {
                                    case 52:
                                    case 53:
                                        $titleName = "R2I";
                                        break;
                                    case  56:
                                        $titleName = "AR";
                                        break;
                                    default:
                                        $titleName = $record->productCode;
                                        break;
                                }

                                echo $record->groupName . "," . $titleName . "," . $record->complete . "," . round($record->total_time/60) . "$newLine";
                            }
                    }
                } else {
                    echo "-$newLine";
                }
            }
            break;
        default:
    }
}

// Action
// $reportCode = 0; // xxx
$reportCode = 1; // VAS group totals report
generateSpecialReport($reportCode, $fromDate, $toDate);

flush();
exit(0);
