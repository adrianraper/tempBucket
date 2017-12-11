<?php
/*
 * This script is run by the cronjob on a 1 minute basis.
 */
/*
 * The only job this runs is to run transforms queued in the T_PendingTransforms table
 */
$batchLoad = 4;
date_default_timezone_set('UTC');

// Parameters you can use to pause the sending of emails, or manually send x at once
$paused = false;
if (isset($_REQUEST["id"])) {
	$specificID = intval($_REQUEST["id"]);
    $batchLoad = 1;
    $paused = false;
}

require_once(dirname(__FILE__)."/CouloirService.php");
$thisService = new CouloirService();
set_time_limit(360);

// v3.0.6 This script may be run by CRON too, in which case skip authentication. How to tell?
if (isset($_SERVER["SERVER_NAME"]) && stristr($_SERVER["SERVER_NAME"], 'clarityenglish') !== FALSE) {
    echo "<h2>You are not logged in</h2>";
    exit(0);
}
// Set up line breaks for whether this is outputting to html page or a text file
if (isset($_SERVER["SERVER_NAME"])) {
	$newLine = '<br/>';
} else {
	$newLine = "\n";
}

function runPendingTransforms() {
	global $batchLoad;
	global $thisService;
	global $newLine;
	global $specificID;
    $dateStampNow = new DateTime('now', new DateTimeZone(TIMEZONE));
    $dateNow = $dateStampNow->format('Y-m-d H:i:s');
    $dateSoon = $dateStampNow->modify('+20 seconds')->format('Y-m-d H:i:s');

    // Read a few of the waiting transforms
	$sql = <<<SQL
		SELECT p.* FROM T_PendingTransforms p 
		WHERE p.F_RunTimestamp IS NULL
SQL;

	if (isset($specificID) && $specificID > 0) {
		$sql .= " AND F_TransformID = $specificID ";
	} else {
		$sql .= " AND (p.F_DelayUntil IS NULL OR p.F_DelayUntil < '$dateNow') ";
	}
		
	$sql .= <<<SQL
		AND p.F_Attempts < 3
		ORDER by p.F_RequestTimestamp ASC
		LIMIT ?
SQL;
	$rs = $thisService->db->Execute($sql, array($batchLoad));

	// Loop round the recordset of transforms
	if ($rs->RecordCount() > 0) {
		while ($dbObj = $rs->FetchNextObj()) {
			$transformId = $dbObj->F_TransformID;
			$data = $dbObj->F_Data;

			// gh#226 Before trying to run the transform, use the F_Attempts column to count how many times we've tried
			$attempts = intval($dbObj->F_Attempts) + 1;
			$sqlUpdate = <<<SQL
				UPDATE T_PendingTransforms
				SET F_Attempts = ? 
				WHERE F_TransformID = ?
SQL;
			$rc = $thisService->db->Execute($sqlUpdate, array($attempts, $transformId));
				
			if (isset($_REQUEST['run']) || !isset($_SERVER["SERVER_NAME"])) {
				try {
					$rc = $thisService->transformCops->callTransform($data);
				} catch (Exception $e) {
					AbstractService::$debugLog->info("Transform $transformId caused exception ".$e->getMessage());
					//$rc = array($e->getMessage());
				}
				
			} else {
				echo "<b>Transform ".$data."$newLine";
				//$rc = array();
			}
			
			// If the transfrom appears to have been run, update the timestamp in the table
			if ($rc === array()) {
				$sqlUpdate = <<<SQL
					UPDATE T_PendingTransforms
					SET F_RunTimestamp = ? 
					WHERE F_TransformID = ?
SQL;
				$rc = $thisService->db->Execute($sqlUpdate, array($dateNow, $transformId));
				
			} else {
				// We failed to run this transform, so delay by xx before trying again. Will have no impact on fatal errors.
				$sqlUpdate = <<<SQL
					UPDATE T_PendingTransforms
					SET F_DelayUntil = ? 
					WHERE F_TransformID = ?
SQL;
				$rc = $thisService->db->Execute($sqlUpdate, array($dateSoon, $transformId));
			}
		}
	}
	echo "Ran ".$rs->RecordCount()." pending transforms. $newLine";
}

// Action
if ($paused) {
	echo "running transforms is paused.$newLine";
} else {
	runPendingTransforms();
}

flush();
exit(0);
