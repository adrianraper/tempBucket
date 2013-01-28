<?php
require_once(dirname(__FILE__)."/XmlTransform.php");

class ProgressExerciseScoresTransform extends XmlTransform {
	
	var $_explicitType = 'com.clarityenglish.bento.vo.content.transform.ProgressExerciseScoresTransform';
	
	public function transform($db, $xml, $href, $service) {
		// Register the namespace for menu xml so we can run xpath queries against it
		$xml->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
		
		if (Session::get('userID') > 0) {
			$user = $service->manageableOps->getUserById(Session::get('userID'));
			
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
		} else {
			// #341 No need for much of this if anonymous access
			$rs = array();
		}
		
		$done = array();
		
		// For each matching exercise add in a @done counter and child <score> nodes
		foreach ($rs as $record) {
			// Only output a score if the exercise that the score refers to exists in the main xml document, otherwise we don't care
			$existingExerciseXPath = $xml->xpath('/xmlns:bento/xmlns:head/xmlns:script[@id="model"]//xmlns:exercise[@id="'.$record['F_ExerciseID'].'"]');
			if (count($existingExerciseXPath) == 0) {
				// I could use other parts of the UID to confirm which one we want, though it would also be good to throw an error
				throw $service->copyOps->getExceptionForId("errorNoExerciseWithId", array("exerciseID" => $record['F_ExerciseID']));
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
	}
	
}