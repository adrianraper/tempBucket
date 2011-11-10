<?php
class ProgressOps {

	var $db;
	var $menu;
	
	function ProgressOps($db) {
		$this->db = $db;
	}
	
	/**
	 * 
	 * This method loads a menu xml file for future use
	 * @param string $file
	 */
	function getMenuXML($file) {
		$this->menu = simplexml_load_file($file);
	}
	
	/**
	 * This method merges the progress records with XML at the summary level
	 */
	function mergeXMLDataMySummary($rs) {
	
		// We will return an array, so start building it
		$build = array();
		//foreach ($this->menu->xpath('//course') as $course) {
		foreach ($this->menu->head->script->menu->course as $course) {
			// Get the number of completed exercises from the recordset for this courseID
			foreach ($rs as $record) {
				if ($record['F_CourseID']==$course['id']) {
					$done = $record['ExercisesDone'];
					break 1;
				}
			}
			// And count the number of exercises that are in the menu for this course
			$course->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
			// But this syntax seems to find all exercises in all courses, not just the current one
			$exercises = $course->xpath('.//xmlns:exercise');
			$total = count($exercises);
			
			// Put it all into the return object
			$build[] = array('name' => (string) $course['caption'], 'value' => floor($done*100/$total), 'done' => $done, 'of' => $total);
		}
		return $build;
		/*
			$progress->dataProvider = array(
							(object) array('name' => 'Writing', 'value' => '23'),
							(object) array('name' => 'Speaking', 'value' => '39'),
							(object) array('name' => 'Reading', 'value' => '68'),
							(object) array('name' => 'Listening', 'value' => '65'),
							(object) array('name' => 'Exam tips', 'value' => '100'),
							);
		*/
	}
	/**
	 * This method gets one user's progress records at the summary level
	 */
	function getMySummary($userID, $productCode) {
			
		$sql = 	<<<EOD
			SELECT F_CourseID, COUNT(DISTINCT F_ExerciseID) AS ExercisesDone FROM T_Score
			WHERE F_UserID=?
			AND F_ProductCode=?
			GROUP BY F_CourseID
			ORDER BY F_CourseID;
EOD;
		// Temporarily use old product code so that you get some data
		if ($productCode==52)
			$productCode=12;
		$bindingParams = array($userID, $productCode);
		$rs = $this->db->GetArray($sql, $bindingParams);
		return $rs;
	}
	/**
	 * This method gets all users' progress records at the summary level
	 */
	function getEveryoneSummary($userID, $rootID, $productCode) {
			
		// Whilst we would prefer to exclude your scores, that isn't feasible
		// as the score table is so large.
		//	-- AND F_UserID != ?
		$sql = 	<<<EOD
			SELECT F_CourseID, AVG(F_Score) AS Average FROM T_Score
			WHERE F_ProductCode = ?
			GROUP BY F_CourseID
			ORDER BY F_CourseID;
EOD;
		$bindingParams = array($productCode);
		$rs = $this->db->GetArray($sql, $bindingParams);
		return $rs;
	}}
?>
