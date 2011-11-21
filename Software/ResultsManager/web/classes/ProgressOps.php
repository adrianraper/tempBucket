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
	
		// We will return an XML object, so start building it
		$build = new SimpleXMLElement('<progress />');
		
		//foreach ($this->menu->xpath('//course') as $course) {
		foreach ($this->menu->head->script->menu->course as $course) {
			// Get the number of completed exercises from the recordset for this courseID
			foreach ($rs as $record) {
				if ($record['F_CourseID']==$course['id']) {
					// my data gives the number of distinct exercises I have done in this course
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
			//$coverage = floor($count*100/$total);
			$coverage = rand(25,100);
			$averageScore = rand(25,100);
			
			// Put it all into a node in the return object
			$newCourse = $build->addChild('course');
			$newCourse->addAttribute('caption',(string) $course['caption']);
			$newCourse->addAttribute('coverage',(string) $coverage);
			$newCourse->addAttribute('count',(string) $count);
			$newCourse->addAttribute('of',(string) $total);
			$newCourse->addAttribute('averageScore',$averageScore);
			$newCourse->addAttribute('averageDuration',$averageDuration);
		}
		return $build;

	}
	/**
	 * This method merges the progress records with XML at the detail level
	 * The rs contains a record(s) for each exercise that has been done.
	 * Build an XML data provider for the charts that contains everything, done or not.
	 */
	function mergeXMLAndDataDetail($rs) {
	
		$menu = $this->menu->head->script->menu;
		$menu->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
		
		// $rs is likely to contain less records than the XML, so loop through rs adding the records
		// into the XML
		foreach ($rs as $record) {
			// There should only be one node in menu.xml for each unique exercise ID
			$exercise = $menu->xpath('.//exercise[@id='.$record['F_ExerciseID'].']');
			
			if (count($exercise)>1) {
				throw new Exception('The menu xml has more than one exercise node with id='.$record['F_ExerciseID']);
			} else if (count($exercise)<1) {
				// Whilst we are mixing up old and new IDs, this might happen. Best just ignore the record.
				//throw new Exception('The menu xml contains no exercise node with id='.$record['F_ExerciseID']);
			} else {
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
		}
		
		// This XML is not good as a dataprovider. It contains too much that is irrelevant (slow to transfer to the client)
		// and it does not have captions done well.
		// So transform it using xslt
		
		// Fake data
		$fakeData = <<<XML
<progress>
	<course caption="Reading">
		<unit caption="question-zone">
			<exercise caption="Reading eBook" done="1" />
		</unit>
		<unit caption="Unit 1">
			<exercise caption="Academic reading passage (1)" done="1">
				<score score="65" duration="60" />
			</exercise>
			<exercise caption="Academic reading passage (2)" done="1">
				<score score="55" duration="120" />
				<score score="56" duration="185" />
			</exercise>
		</unit>
	</course>
	<course caption="Writing">
		<unit caption="Unit 1 task 1">
			<exercise caption="How can I write well?" done="1">
				<score score="65" duration="60" />
			</exercise>
			<exercise caption="Sample answer" done="1">
				<score score="-1" duration="10" />
			</exercise>
		</unit>
	</course>
</progress>	
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
					COUNT(DISTINCT F_ExerciseID) AS Count 
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
	
	/**
	 * This method is called to insert a session record when a user starts a program
	 */
	function startSession($userID, $rootID, $productCode, $dateNow) {

		// Check that the date is valid
		$dateStampNow = strtotime($dateNow);
		if (!$dateStampNow) {
			$dateStampNow = time();
			$dateNow = date('Y-m-d H:i:s',$dateStampNow);
		}
		$dateSoon = date('Y-m-d H:i:s',strtotime("+15 seconds", $dateStampNow));
		
		// CourseID is in the db for backwards compatability, but no longer used. All sessions are across one title.
		// StartDateStamp is usually sent so that we can record a user's local time. It might be better to send a time-zone if we could.
		// EndDateStamp and Duration are different views of the same data. It might be better to just focus on Duration.
		// When you start a session, the minimum duration is 15 seconds.
		$sql = <<<SQL
			INSERT INTO T_Session (F_UserID, F_StartDateStamp, F_EndDateStamp, F_Duration, F_RootID, F_ProductCode)
			VALUES (?, ?, ?, 15, ?, ?)
SQL;

		// We want to return the newly created F_SessionID (or the SQL error)
		$bindingParams = array($userID, $dateNow, $dateSoon, $rootID, $productCode);
		$rs = $this->db->Execute($sql, $bindingParams);
		if ($rs) {
			$sessionID = $this->db->Insert_ID();
			if ($sessionID) {
				return $sessionID;
			} else {
				// The database probably doesn't support the Insert_ID function
				throw new Exception("Database can't find auto-increment session id", 100);
			}
		} else {
			return $rs;
		}
		
	}
	/**
	 * This method is called to update a session record.
	 * This is used both when a user exits the program, and regularly whilst the connection is still going.
	 */
	function updateSession($sessionID, $dateNow) {

		// Check that the date is valid
		$dateStampNow = strtotime($dateNow);
		if (!$dateStampNow)
			$dateStampNow = time();
		
		// Calculate F_Duration as well as setting F_EndDateStamp
		// We can either do it one call, with different SQL for different databases, or
		// do two calls and make it common.
		if (strpos($GLOBALS['dbms'],"mysql")!==false) {
			$sql = <<<EOD
				UPDATE T_Session
				SET F_EndDateStamp=?,
				F_Duration=TIMESTAMPDIFF(SECOND,F_StartDateStamp,?)
				WHERE F_SessionID=?
EOD;
		} else if (strpos($GLOBALS['dbms'],"sqlite")!==false) {
			$sql = <<<EOD
				UPDATE T_Session
				SET F_EndDateStamp=?,
				F_Duration=strftime('%s',?) - strftime('%s',F_StartDateStamp)
				WHERE F_SessionID=?
EOD;
		} else {
			$sql = <<<EOD
				UPDATE T_Session
				SET F_EndDateStamp=?,
				F_Duration=DATEDIFF(s,F_StartDateStamp,?)
				WHERE F_SessionID=?
EOD;
		}
		$bindingParams = array($dateStampNow, $dateStampNow, $sessionID);
		$rs = $this->db->Execute($sql);
		return $rs;
		
	}
	/**
	 * This method is called to insert a score record 
	 * @param userID, date, sessionID
	 * @param productCode, courseID, unitID, itemID - these form the UID
	 * @param score (%), correct, wrong, skipped
	 * @param coverage (%)
	 * @param duration (seconds)
	 */
	function insertScore($userID, $dateNow, $sessionID, $productCode, $courseID, $unitID, $exerciseID, $score, $correct, $wrong, $skipped, $coverage, $duration) {

		// Check that the data is valid

		$bindingParams = array(
				$userID, $dateNow, $sessionID, 
				$productCode, $courseID, $unitID, $exerciseID,
				$score, $correct, $wrong, $skipped,
				$coverage,
				$duration,
				 );
		// Write anonymous records to an ancilliary table that will not slow down reporting
		if ($userID<1) {
			$tableName = 'T_ScoreAnonymous';
		} else {
			$tableName = 'T_Score';
		}
		
		$sql = <<<SQL
			INSERT INTO $tableName (
						F_UserID, F_DateStamp, F_SessionID, 
						F_ProductCode, F_CourseID, F_UnitID, F_ExerciseID,
						F_Score, F_ScoreCorrect, F_ScoreWrong, F_ScoreMissed,
						F_Duration 
						) VALUES (
						?, ?, ?, 
						?, ?, ?, ?,
						?, ?, ?, ?,
						?,
						? )
SQL;
		$rs = $this->db->Execute($sql);
		return $rs;
		
	}
}
?>
