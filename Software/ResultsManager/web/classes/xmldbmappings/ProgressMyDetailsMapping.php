<?php
class ProgressMyDetailsMapping {
	
	public function transform($db, $xml, $options = array()) {
		// Register the namespace for menu xml so we can run xpath queries against it
		$xml->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
		
		$user = $options['manageableOps']->getUserById($options['userID']);
		
		// Firstly fetch all the scores for this user and product
		$sql = <<<SQL
			SELECT s.*
			FROM T_Score as s
			WHERE s.F_UserID=?
			AND s.F_ProductCode=?
			ORDER BY s.F_CourseID, s.F_UnitID, s.F_ExerciseID;
SQL;
		$bindingParams = array($user->userID, $options['productCode']);
		$rs = $db->GetArray($sql, $bindingParams);
		
		// For each matching exercise add in a @done counter and child <score> nodes
		foreach ($rs as $record) {
			// Only output a score if the exercise that the score refers to exists in the main xml document, otherwise we don't care
			$existingExerciseXPath = $xml->xpath('/xmlns:bento/xmlns:head/xmlns:script[@id="model"]//xmlns:exercise[@id="'.$record['F_ExerciseID'].'"]');
			if (count($existingExerciseXPath) == 0) {
				// I could use other parts of the UID to confirm which one we want, though it would also be good to throw an error
				throw $this->copyOps->getExceptionForId("errorMultipleExerciseWithSameId", array("exerciseID" => $record['F_ExerciseID']));
			} else if (count($existingExerciseXPath) > 1) {
				// Whilst we are mixing up old and new IDs, this might happen.  Just ignore the record.
			} else {
				$exercise = $existingExerciseXPath[0];
				
				// Now add the score node and increment the done counter
				$score = $exercise->addChild("score");
				$score->addAttribute('score', $record['F_Score']);
				$score->addAttribute('duration', $record['F_Duration']);
				$score->addAttribute('datetime', $record['F_DateStamp']);
				
				$exercise['done'] = ($exercise['done']) ? $exercise['done'] + 1 : 1;
			}
		}
		
		// Now that we have @done and <score> nodes we can calculate summary stats for each course
		$courses = $xml->xpath('/xmlns:bento/xmlns:head/xmlns:script[@id="model"]//xmlns:course');
		foreach ($courses as $course) {
			$course->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
			
			$stats = array("of" => 0, "count" => 0, "totalDone" => 0, "totalScore" => 0, "scoredCount" => 0, "durationCount" => 0, "duration" => 0, "averageScore" => 0, "averageDuration" => 0, "coverage" => 0);
			foreach ($course->xpath('.//xmlns:exercise') as $exercise) {
				$exercise->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
				
				$stats['of'] += 1;
				if ($exercise['done'] > 0) {
					$stats['count'] += 1;
					$stats['totalDone'] += $exercise['done'];
				}
				
				foreach ($exercise->xpath('xmlns:score') as $score) {
					// #232. #161. Don't let non-marked exercise scores impact the average
					if ($score['score'] >= 0) {
						$stats['totalScore'] += $score['score'];
						$stats['scoredCount'] += 1;
					}
					// #318. 0 duration is for offline exercises (downloading a pdf for instance) so ignore it.
					if ($score['duration'] > 0) {
						$stats['durationCount'] += 1;
						$stats['duration'] += $score['duration'];
					}
				}
				
				if ($stats['scoredCount'] > 0) $stats['averageScore'] = floor($stats['totalScore'] / $stats['scoredCount']);
				if ($stats['durationCount'] > 0) $stats['averageDuration'] = floor($stats['duration'] / $stats['durationCount']);
				if ($stats['of'] > 0) $stats['coverage'] = floor(100 * $stats['count'] / $stats['of']);
			}
			
			// Merge the statistics into the course node
			foreach ($stats as $attribute => $value) {
				$course->addAttribute($attribute, $value);
			}
		}
	}
	
}