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
	 * This method gets progress records and merges with XML at the summary level
	 */
	function getMySummary($userID, $productCode) {
		
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
		$rs = $this->db->GetArray($sql, $bindingParams);
		return $rs;
	}
}
?>
