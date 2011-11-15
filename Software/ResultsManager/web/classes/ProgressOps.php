<?php
class ProgressOps {

	var $db;
	var $menu;
	
	function ProgressOps($db) {
		$this->db = $db;
	}
	
	/**
	 * 
	 * This method loads a menu xml file for future use.
	 * TODO. Is it worth caching somehow?
	 * @param string $file
	 */
	function getMenuXML($file) {
		$this->menu = simplexml_load_file($file);
	}
	
	/**
	 * This method merges the progress records with XML at the summary level
	 */
	function mergeXMLAndDataSummary($rs) {
	
		// We will return an array, so start building it
		$build = array();
		//foreach ($this->menu->xpath('//course') as $course) {
		foreach ($this->menu->head->script->menu->course as $course) {
			// Get the number of completed exercises from the recordset for this courseID
			foreach ($rs as $record) {
				if ($record['F_CourseID']==$course['id']) {
					// my data gives the number of distinct exercises I have done in this course
					if (isset($record['Done']))
						$count = $record['Done'];
					if (isset($record['Count']))
						$count = $record['Count'];
					$averageScore = $record['AverageScore'];
					$averageDuration = $record['AverageDuration'];
					break 1;
				}
			}
			// And count the number of exercises that are in the menu for this course
			$course->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
			// But this syntax seems to find all exercises in all courses, not just the current one
			// Need to add the relative path indicator '.'
			//$exercises = $course->xpath('//xmlns:exercise');
			$exercises = $course->xpath('.//xmlns:exercise');
			$total = count($exercises);
			// Note that whilst you are mixing up old and new productCodes, you might get values >100%
			// so just ignore them
			//$value = floor($count*100/$total);
			$coverage = rand(0,100);
			
			// Put it all into the return object
			$build[] = array('caption' => (string) $course['caption'], 
							'value' => $coverage, 
							'count' => $count,
							'of' => $total, 
							'averageScore' => $averageScore,
							'averageDuration' => $averageDuration,
						);
		}
		return $build;

	}
	/**
	 * This method merges the progress records with XML at the details level
	 * The rs contains a record(s) for each exercise that has been done.
	 * Build an XML data provider for the charts that contains everything, done or not.
	 */
	function mergeXMLAndDataDetail($rs) {
	
		$menu = $this->menu->head->script->menu;
		$menu->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
		
		// $rs is likely to contain less records than the XML, so loop through rs adding the records
		// into the XML, then xsl out the whole lot
		foreach ($rs as $record) {
			// There should only be one node with a unique exercise ID
			$exercise = $menu->xpath('.//exercise[@id='.$record['F_ExerciseID'].']');
			
			if (count($exercise)>1) {
				throw new Exception('The menu xml has more than one exercise node with id='.$record['F_ExerciseID']);
			}
			// Set the attribute to done for exercises in all units
			$exercise[0]->addAttribute('done', '1');
			
			// And add a score node as a child IF this is a practice-zone exercise
			$unit = $exercise[0]->xpath('..');
			if (isset($unit[0]['class']) && $unit[0]['class']=='practice-zone') {
				$score = $exercise[0]->addChild('score');
				$score->addAttribute('score',$record['F_Score']);
				$score->addAttribute('duration',$record['F_Duration']);
			}
		}
		
		// Fake data
		$fakeData = <<<XML
<course caption="Reading">
	<unit caption="1">
		<exercise caption="Academic reading passage (1)" done="1">
			<score score="65" duration="60" />
		</exercise>
		<exercise caption="Academic reading passage (2)" done="1">
			<score score="55" duration="120" />
		</exercise>
	</unit>
</course>
XML;
		return $fakeData;
		//return $menu->asXML();
		
	}
	/**
	 * This method gets one user's progress records at the summary level
	 */
	function getMySummary($userID, $productCode) {
		
		// Only average the score for 'scored' records, but count them all
		$sql = 	<<<EOD
			SELECT F_CourseID, 
					ROUND(AVG(IF(F_Score<0, NULL, F_Score))) as AverageScore, 
					ROUND(AVG(F_Duration)) as AverageDuration, 
					COUNT(DISTINCT F_ExerciseID) AS Done 
			FROM T_Score
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
	function getEveryoneSummary($productCode) {
			
		// Start working off cached results
		$sql = 	<<<EOD
			SELECT F_CourseID, F_AverageScore as AverageScore, F_AverageDuration as AverageDuration, F_Count as Count FROM T_ScoreCache
			WHERE F_ProductCode = ?
			ORDER BY F_CourseID;
EOD;
		// Temporarily use old product code so that you get some data
		if ($productCode==52)
			$productCode=12;
		$bindingParams = array($productCode);
		$rs = $this->db->GetArray($sql, $bindingParams);
		return $rs;
	}
	/**
	 * This method gets all the users' progress records for this title
	 */
	function getMyDetails($userID, $productCode) {
			
		$sql = 	<<<EOD
			SELECT F_CourseID, F_UnitID, F_ExerciseID, F_Score, F_ScoreCorrect, F_ScoreWrong, F_ScoreMissed, F_Duration, F_DateStamp 
			FROM T_Score
			WHERE F_UserID=?
			AND F_ProductCode=?
			ORDER BY F_CourseID, F_UnitID, F_ExerciseID;
EOD;
		// Temporarily use old product code so that you get some data
		if ($productCode==52)
			$productCode=12;
		$bindingParams = array($userID, $productCode);
		$rs = $this->db->GetArray($sql, $bindingParams);
		return $rs;
	}
}
?>
