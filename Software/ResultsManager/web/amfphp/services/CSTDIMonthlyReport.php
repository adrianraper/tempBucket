<?php
/*
 * This script will run once a month on specific accounts and generate a specific report
 */

require_once(dirname(__FILE__)."/MinimalService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");

$minimalService = new MinimalService();

/*
 * This is for CSTDI who want a csv report for their learners activity that month
 */

 // The script will be run on the first of the month, reporting on the last month
 // It needs to be added to AWS cron to get the monthly triggering.
if (isset($_GET['month'])) {
	$m = $_GET['month']+1;
 	if ($m > 12)
 		$m = 1;
} else {
	$m = date('n'); 
}
if (isset($_GET['year'])) {
	$y = $_GET['year'];
} else {
	$y = date('Y');
}
$startDate = date('Y-m-d', mktime(1,1,1,$m-1,1,$y)); 
$endDate = date('Y-m-d', mktime(1,1,1,$m,0,$y));
$rootID = 14449;

$outputText = '';
$outputDevice = 'file';
//$outputDevice = 'screen';

writeOutHeader();
runQuery($rootID, $startDate, $endDate);
writeOutFooter();
exit(0);

function writeOut($text, $mode = '') {
	global $outputDevice;
	global $outputText;
	global $m;
	global $y;
	
	$outputText.=$text;
	if ($outputDevice == 'screen') {
		echo $outputText;
	} else {
		if ($mode == 'stop') {
			// workout the filename and open it
			$datePart = $y.$m;
			$baseDir = $GLOBALS['logs_dir'];
			$baseFolder = realpath($baseDir);
			if (!$baseFolder)
				throw new Exception("Can't get file path for $baseDir");
			$filename = $baseFolder.'/CSTDI/'."163-$datePart.csv";
			$fh = fopen($filename, 'wb');
			if (!$fh)
				throw new Exception("Can't open the file for writing $filename");
			
			// write out the text
			fwrite($fh, $outputText);
			
			// close and flush the file
			fclose($fh);
			
			echo "written file $filename";
		}
	}
}
function writeOutHeader() {
	$string = '"user_id","third_course_id","eval_complete_date","eval_result","quiz_complete_date","score"'."\n";
	writeOut($string);
}
function writeOutFooter() {
	$string = "\n";
	writeOut($string, 'stop');
}
function writeOutRecord($row) {
	if ($row[2]=='') {
		$evalFormattedDate = '';
	} else {
		$evalFormattedDate = strftime("%m/%d/%Y", strtotime($row[2]));
	}
	if ($row[4]=='') {
		$quizFormattedDate = '';
	} else {
		$quizFormattedDate = strftime("%m/%d/%Y", strtotime($row[4]));
	}
	$string = '"'.substr($row[0],0,30).'","'.substr($row[1],0,12).'","'.$evalFormattedDate.'","'.$row[3].'","'.$quizFormattedDate.'","'.$row[5].'"'."\n";
	writeOut($string);
}

function initRecord(&$row) {
	$row['user_id'] = '';
	$row['third_course_id'] = '';
	$row['eval_complete_date'] = '';
	$row['eval_result'] = '';
	$row['quiz_complete_date'] = '';
	$row['score'] = '';
}

function runQuery($rootID, $startDate = null, $endDate = null) {
	global $minimalService;
	
	if (!$startDate)
		$startDate = date('Y-m-01');
	if (!$endDate)
		$endDate = date('Y-m-d');
	
	// The complexity here comes from needing to get records for exerciseID 51 and/or 52.
	
	// Option 1)
	//   Just get userIDs first
	//   Then for each product and user, get the detail records
	// That seems it will be a lot of separate SQL calls. However it has one great advantage in that 
	// it will be easier to get previous month's records, which we might have to do.
	$sql = 	<<< EOD
				SELECT u.F_UserID as userID, u.F_StudentID as cstdi_id, d.F_UnitID as productCode
				FROM T_ScoreDetail d, T_User u 
				WHERE d.F_DateStamp >= ?
				AND d.F_DateStamp <= ?
				AND d.F_RootID = ?
				AND d.F_UserID = u.F_UserID
				AND d.F_ExerciseID IN (51,52)
				GROUP BY d.F_UserID, d.F_UnitID
				ORDER BY UserID
EOD;
	$bindingParams_1 = array($startDate, $endDate, $rootID);
	$rs_1 = $minimalService->db->GetArray($sql, $bindingParams_1);
	foreach ($rs_1 as $row_1) {
	
		$user_id = $row_1['cstdi_id'];
		$userID = $row_1['userID'];
		$productCode = $row_1['productCode'];
		
		// Now you have a user who needs a record this month
		// So get ALL records that they have done.
		// Certificates should only ever have one record per title
		// Evaluations can be many, but we are supposed to just take the first.
		// Bugs: You will get a record if an evaluation is repeated this month, even if you shouldn't
		// Bugs: If a user completes BW, this is going to generate a record for their CP stuff too, even though it shouldn't
		//		 This can be fixed by passing unitID from the original record to this query.
		$sql = 	<<< EOD
					SELECT d.F_UserID, F_UnitID, F_ExerciseID, MIN(F_DateStamp) as firstDate, F_ItemID, F_Score, F_Detail
					FROM T_ScoreDetail d
					WHERE d.F_UserID = ?
					AND d.F_UnitID = ?
					AND ((d.F_ExerciseID = 51 AND d.F_ItemID=0)
					OR (d.F_ExerciseID = 52 AND d.F_ItemID=6 AND d.F_Score=1))
					GROUP BY d.F_UserID, F_UnitID, F_ExerciseID
					ORDER BY d.F_UnitID, d.F_ExerciseID
EOD;
		$bindingParams_2 = array($userID, $productCode);
		$rs_2 = $minimalService->db->GetArray($sql, $bindingParams_2);
		
		// Loop round each record for this user - there might be 2 for each title
		$lastTitle = 0;
		foreach ($rs_2 as $row_2) {
			
			// Fill up this user's record for this title
			$third_Course_id = $row_2['F_UnitID'];

			// If this is a different title from the last record, write out the last record
			if ($lastTitle != $third_Course_id) {
				
				// But first time, just set the id
				if($lastTitle > 0) {
					writeOutRecord($reportRecord);
					// Then ready for this new record
					initRecord($reportRecord);
				}
				//RESET THE RECORDS
				$lastTitle = $third_Course_id;	
				$quiz_complete_date = '';
				$score = '';			
				$eval_complete_date = '';
				$eval_result = '';					
			}

			// Have they completed the quiz (means got a certificate?)
			if ($row_2['F_ExerciseID'] == 51) {
				$quiz_complete_date = $row_2['firstDate'];
				$score = $row_2['F_Score'];
			} else {
				$quiz_complete_date = '';
				$score = '';
			}
			// Have they completed the evaluation (and got a score of 1 for question 6)
			if ($row_2['F_ExerciseID'] == 52) {
				$eval_complete_date = $row_2['firstDate'];
				
				// The detail is saved as the text of the mc answer - CSTDI needs this as a number
				$eval_long_result = $row_2['F_Detail'];
				switch (strtolower($eval_long_result)) {
					case 'outstanding':
						$eval_result = 0;
						break;
					case 'very effective':
						$eval_result = 1;
						break;
					case 'effective':
						$eval_result = 2;
						break;
					case 'moderate':
						$eval_result = 3;
						break;
					case 'poor':
						$eval_result = 4;
						break;
					default:
						$eval_result = -1;
						break;
				}
			} else {
				$eval_complete_date = '';
				$eval_result = '';
			}
			// Build up the report record
			$reportRecord[0] = $user_id;
			$reportRecord[1] = $third_Course_id;
			// Add whatever detail you have
			if ($eval_complete_date) {
				$reportRecord[2] = $eval_complete_date;
				$reportRecord[3] = $eval_result;
			} else {
				$reportRecord[2] = '';
				$reportRecord[3] = '';
			}
			if ($quiz_complete_date) {
				$reportRecord[4] = $quiz_complete_date;
				$reportRecord[5] = $score;
			} else {
				$reportRecord[4] = '';
				$reportRecord[5] = '';
			}				
		}
		// Then write out the final record
		writeOutRecord($reportRecord);
		
	}
}
	
