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
		// Getting issues with this on some servers
		// simplexml_load_file(): php_network_getaddresses: getaddrinfo failed: Name or service not known
		// So try a fileget and load the xml from string.
		//$this->menu = simplexml_load_file($file);
		$fileContents = file_get_contents($file);
		$this->menu = simplexml_load_string($fileContents);
	}
	
	/**
	 * This method merges the progress records with XML at the summary level
	 */
	function mergeXMLAndDataSummary($rs) {
	
		// We will return an XML object, so start building it
		$build = new SimpleXMLElement('<progress />');
		
		//foreach ($this->menu->xpath('//course') as $course) {
		foreach ($this->menu->head->script->menu->course as $course) {
			$course->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
			// Get the number of completed exercises from the recordset for this courseID
			// Trac #137.
			$count = 0;
			$averageScore = 0;
			$averageDuration = 0;
			$totalDuration = 0;
			foreach ($rs as $record) {
				if ($record['F_CourseID']==$course['id']) {
					// my data gives the number of distinct exercises I have done in this course
					$count = $record['Count'];
					$averageScore = $record['AverageScore'];
					$averageDuration = $record['AverageDuration'];
					if (isset($record['TotalDuration']))
						$totalDuration = $record['TotalDuration'];
					break 1;
				}
			}
			// And count the number of exercises that are in the menu for this course
			$exercises = $course->xpath('.//xmlns:exercise');
			$total = count($exercises);
			$coverage = floor($count*100/$total);
			
			// Put it all into a node in the return object
			$newCourse = $build->addChild('course');
			$newCourse->addAttribute('id', strtolower($course['id']));
			$newCourse->addAttribute('class', strtolower($course['caption']));
			$newCourse->addAttribute('caption',(string) $course['caption']);
			$newCourse->addAttribute('coverage',(string) $coverage);
			$newCourse->addAttribute('count',(string) $count);
			$newCourse->addAttribute('of',(string) $total);
			$newCourse->addAttribute('averageScore',$averageScore);
			$newCourse->addAttribute('averageDuration',$averageDuration);
			$newCourse->addAttribute('duration',$totalDuration);
		}
		return $build;

	}
	/**
	 * This method merges the progress records with XML at the detail level
	 * The rs contains a record(s) for each exercise that has been done.
	 * It will include records for exercises that are no longer in the menu.xml and should be ignored.
	 * Build an XML data provider for the charts that contains everything, done or not.
	 */
	function mergeXMLAndDataDetail($rs) {
	
		$menu = $this->menu->head->script->menu;
		$menu->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
		
		// $rs is likely to contain less records than the XML, so loop through rs adding the records
		// into the XML. Though there will be duplicates in $rs
		foreach ($rs as $record) {
			// There should only be one node in menu.xml for each unique exercise ID
			$exercise = $menu->xpath('.//xmlns:exercise[@id="'.$record['F_ExerciseID'].'"]');
			
			if (count($exercise)>1) {
				// I could use other parts of the UID to confirm which one we want, though it would also be good to throw an error
				throw new Exception('The menu xml has more than one exercise node with id='.$record['F_ExerciseID']);
			} else if (count($exercise)<1) {
				// Whilst we are mixing up old and new IDs, this might happen. Just ignore the record.
				//throw new Exception('The menu xml contains no exercise node with id='.$record['F_ExerciseID']);
			} else {
				// Set the attribute to done for exercises in all units
				// TODO. It would be almost cost free to count them and could be used in Flex charts?
				if ($exercise[0]['done']) {
					$exercise[0]['done'] += 1; 
				} else {
					$exercise[0]->addAttribute('done', 1);
				}
				
				// And add a score node as a child IF this is a practice-zone exercise
				$unit = $exercise[0]->xpath('..');
				if (isset($unit[0]['class']) && $unit[0]['class']=='practice-zone') {
					$score = $exercise[0]->addChild('score');
					$score->addAttribute('score',$record['F_Score']);
					$score->addAttribute('duration',$record['F_Duration']);
					$score->addAttribute('datetime',$record['F_DateStamp']);
				}
			}
		}
		
		// This XML is not good as a dataprovider. It contains too much that is irrelevant (slow to transfer to the client)
		// and it does not have captions done well.
		// So transform it using xslt.
		// BUT, since it is exactly the same XML as we are already using on the client, it will be easier to merge.
		// So just transfer the whole thing. If this ever looked like being a problem, we could presumably find a way to xslt so that it is 
		// just a shell with IDs and our new information.

		// Fake data
/*		
-- Create a fake record for writing eBook
insert into T_Score values
('27639', '2011-11-24 18:57:10', '1287130410001', '50', '1287130410000', '180', '0', '0', '0', '2227356', NULL, '1287130400000', '52', null);
*/	

		// Try to return the whole xml file, with additions, not just the menu bit
		//return $menu->asXML();
		return $this->menu->asXML();
		
	}
	/**
	 * 
	 * Take an exercise record and return is a bookmark XML
	 * @param recordset $rs
	 */
	function formatBookmark($rs) {
		$score = new Score();
		$score->fromDatabaseObj($rs);
		$bookmark = new SimpleXMLElement('<bookmark />');
		$bookmark->addAttribute('uid', $score->getUID());
		$bookmark->addAttribute('date', $score->dateStamp);
		return $bookmark->asXML();		
	}
	/**
	 * This method gets one user's progress records at the summary level.
	 * It is extremely efficent to use SQL to do this, but it means that if we change
	 * menu.xml we will still count old exercise IDs from T_Score. So we should switch
	 * to getting the summary from the detail directly.
	 * 
	 * This method now obsolete.
	 */
	function getMySummary($userID, $productCode) {
		
		// Only average the score for 'scored' records, but count them all
		$sql = 	<<<EOD
			SELECT F_CourseID, 
					ROUND(AVG(IF(F_Score<0, NULL, F_Score))) as AverageScore, 
					ROUND(AVG(F_Duration)) as AverageDuration, 
					COUNT(DISTINCT F_ExerciseID) AS Count, 
					SUM(F_Duration) AS TotalDuration 
			FROM T_Score
			WHERE F_UserID=?
			AND F_ProductCode=?
			GROUP BY F_CourseID
			ORDER BY F_CourseID;
EOD;
		$bindingParams = array($userID, $productCode);
		$rs = $this->db->GetArray($sql, $bindingParams);
		return $rs;
	}
	/**
	 * This method gets all users' progress records at the summary level
	 */
	function getEveryoneSummary($productCode) {
			
		// For want of anywhere better to put it for the moment, this is the SQL to populate the cache table
		/*
		USE global_r2iv2;
		SET @productCode = 52;
		INSERT INTO T_ScoreCache (F_ProductCode, F_CourseID, F_AverageScore, F_AverageDuration, F_Count, F_DateStamp, F_Country)
		SELECT @productCode, F_CourseID, AVG(F_Score) as AverageScore, AVG(F_Duration) as AverageDuration, COUNT(F_UserID) as Count, now(), 'Worldwide' 
		FROM T_Score
		WHERE F_ProductCode = @productCode
		AND F_Score>=0
		GROUP BY F_CourseID;
		*/
		
		// Start working off cached results
		// It would be safest if we could ensure that we only read the record with the latest datestamp
		$sql = 	<<<EOD
			SELECT F_CourseID, F_AverageScore as AverageScore, F_AverageDuration as AverageDuration, F_Count as Count FROM T_ScoreCache
			WHERE F_ProductCode = ?
			ORDER BY F_CourseID;
EOD;
		// Temporarily use old product code so that you get some data
		//if ($productCode==52)
		//	$productCode=12;
		$bindingParams = array($productCode);
		$rs = $this->db->GetArray($sql, $bindingParams);
		return $rs;
	}
	/**
	 * This method gets all this users' progress records for this title
	 */
	function getMyDetails($userID, $productCode) {
			
		$sql = 	<<<SQL
			SELECT s.*
			FROM T_Score as s
			WHERE s.F_UserID=?
			AND s.F_ProductCode=?
			ORDER BY s.F_CourseID, s.F_UnitID, s.F_ExerciseID;
SQL;
		$bindingParams = array($userID, $productCode);
		$rs = $this->db->GetArray($sql, $bindingParams);
		return $rs;
		
	}
	/**
	 * This method gets the user's last record
	 */
	function getMyLastExercise($userID, $productCode) {
			
		$sql = 	<<<SQL
			SELECT s.*
			FROM T_Score as s
			WHERE s.F_UserID=?
			AND s.F_ProductCode=?
			ORDER BY s.F_DateStamp DESC
			LIMIT 1;
SQL;
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
			$dateNow = date('Y-m-d h:m:s', time());
		
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
		$bindingParams = array($dateNow, $dateNow, $sessionID);
		$rs = $this->db->Execute($sql, $bindingParams);
		return $rs;
		
	}
	/**
	 * This method is called to insert a score record to the database 
	 */
	function insertScore($score) {

		// Write anonymous records to an ancilliary table that will not slow down reporting
		if ($score->userID < 1) {
			$tableName = 'T_ScoreAnonymous';
		} else {
			$tableName = 'T_Score';
		}

		$dbObj = $score->toAssocArray();
		$rc = $this->db->AutoExecute($tableName, $dbObj, "INSERT");
		if (!$rc)
			throw new Exception($this->db->ErrorMsg(), $this->db->ErrorNo());
				
	}
}
?>
