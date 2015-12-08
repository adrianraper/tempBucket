<?php
require_once(dirname(__FILE__)."/XmlTransform.php");

class ProgressExerciseScoresTransform extends XmlTransform {
	
	var $_explicitType = 'com.clarityenglish.bento.vo.content.transform.ProgressExerciseScoresTransform';
	
	// gh#1223
	public function transform($db, $xml, $href, $service) {
		// #341 No need for any of this if anonymous access
		if (Session::get('userID') > 0) {
			$user = $service->manageableOps->getUserById(Session::get('userID'));

			// Register the namespace for menu xml so we can run xpath queries against it
			$xml->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
			
			// Firstly fetch all the scores for this user and product
			$sql = <<<SQL
				SELECT s.*
				FROM T_Score as s
				WHERE s.F_UserID=?
				AND s.F_ProductCode=?
				ORDER BY s.F_CourseID, s.F_UnitID, s.F_ExerciseID;
SQL;
			$bindingParams = array($user->userID, Session::get('productCode'));
			$rs = $db->GetArray($sql, $bindingParams);
		
			// For each matching exercise add in a @done counter and child <score> nodes
			foreach ($rs as $record) {
				// Only output a score if the exercise that the score refers to exists in the main xml document, otherwise we don't care
				$existingExerciseXPath = $xml->xpath('/xmlns:bento/xmlns:head/xmlns:script[@id="model"]//xmlns:exercise[@id="'.$record['F_ExerciseID'].'"]');
				if (count($existingExerciseXPath) == 0) {
					// I could use other parts of the UID to confirm which one we want, though it would also be good to throw an error
					// gh#165 this is now stopping me - it will have to be that we ignore any score that no longer has an id in the menu 
					//throw $service->copyOps->getExceptionForId("errorNoExerciseWithId", array("exerciseID" => $record['F_ExerciseID']));
				} else if (count($existingExerciseXPath) > 1) {
					// Whilst we are mixing up old and new IDs, this might happen.  Just ignore the record.
					//throw $service->copyOps->getExceptionForId("errorMultipleExerciseWithSameId", array("exerciseID" => $record['F_ExerciseID']));
				} else {
					$exercise = $existingExerciseXPath[0];
					
					// Add the <score> node as a child of the approriate exercise (if it exists)
					if ($exercise) {
						$score = $exercise->addChild('score');
						$score->addAttribute('score', $record['F_Score']);
						$score->addAttribute('duration', $record['F_Duration']);
						$score->addAttribute('datetime', $record['F_DateStamp']);
						
						// Increment the @done attribute
						$exercise['done'] = ($exercise['done']) ? $exercise['done'] + 1 : 1;
					}
				}
			}
			
			foreach ( $xml->head->script->menu->course->unit as $unit ) {
				foreach ( $unit->exercise as $exercise ) {
					// gh#238
					if ($exercise ['contentuid']) {
						$uid = explode ( ".", $exercise ['contentuid'] );
						// gh#684
						if (count($uid) < 4) {						
							$sql = <<<SQL
							SELECT SUM(F_Duration) as duration, AVG(F_Score) as score, MIN(F_DateStamp) as dateStamp
								FROM T_Score s
								WHERE s.F_UserID=?
								AND s.F_ProductCode=?
SQL;
							if (count($uid) > 2) $sql .= ' AND s.F_CourseID='.$uid[1];
							if (count($uid) > 3) $sql .= ' AND s.F_UnitID='.$uid[2];
							$bindingParams = array($user->userID, $uid[0]);
									
						} else {
							$sql = <<<SQL
							SELECT SUM(F_Duration) as duration, MAX(F_Score) as score, MIN(F_DateStamp) as dateStamp
								FROM T_Score s
								WHERE s.F_UserID=?
								AND s.F_ProductCode=?
								AND s.F_CourseID=?
								AND s.F_UnitID=?
								AND s.F_ExerciseID=?;
SQL;
							$bindingParams = array($user->userID, $uid[0], $uid[1], $uid[2], $uid[3]);
						}
						$rs2 = $db->Execute($sql, $bindingParams);
						
						foreach ($rs2 as $record2) {
							$score = $exercise->addChild('score');
							$score->addAttribute('score', $record2['score']);
							$score->addAttribute('duration', $record2['duration']);
							$score->addAttribute('datetime', $record2['dateStamp']);
							
							// Increment the @done attribute
							if ($record2['duration'] > 0) {
								$exercise['done'] = ($exercise['done']) ? $exercise['done'] + 1 : 1;
							}						
						}
					}
				}			
			}
		}
	}
}