<?php
class ProgressOps {

	var $db;

	function ProgressOps($db) {
		$this->db = $db;
	}
	
	/**
	 * This method gets progress records and merges with XML at the summary level
	 */
	function getMySummary($userID, $productCode, $href) {
		
		// First get the records from the database
		$rs = $this->getMySummaryRecords($userID, $productCode);
		
		// Next get the menu.xml.
		// Should we be using contentOps.php with all of its hiddenContent, parseContent etc?
		// $menu = 
		
		// Finally merge and summarise
		
		// Return
		return $rs;
	}
	/* 
	 * v3.5 For progress reports in Bento
	 */
	function getMySummaryRecords($userID, $productCode) {
		
		$sql = 	<<<EOD
			SELECT F_CourseID, COUNT(DISTINCT F_ExerciseID) AS ExercisesDone FROM T_Score
			WHERE F_UserID=?
			AND F_ProductCode=?
			GROUP BY F_CourseID
			ORDER BY F_CourseID;
EOD;
		$bindingParams = array($userID, $productCode);
		$rs = $this->db->Execute($sql, $bindingParams);
		return $rs;
	}
}
?>
