<?php
class ProgressMyDetailsMapping {
	
	public function toXML($db, $xml, $options = array()) {
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
		
		$mappingXml = new SimpleXMLElement('<progress_my_details />');
		
		foreach ($rs as $record) {
			// Only output a score if the exercise that the score refers to exists in the main xml document, otherwise we don't care
			$existingExerciseCount = count($xml->xpath('.//xmlns:exercise[@id="'.$record['F_ExerciseID'].'"]'));
			if ($existingExerciseCount == 0) {
				// I could use other parts of the UID to confirm which one we want, though it would also be good to throw an error
				throw $this->copyOps->getExceptionForId("errorMultipleExerciseWithSameId", array("exerciseID" => $record['F_ExerciseID']));
			} else if ($existingExerciseCount > 1) {
				// Whilst we are mixing up old and new IDs, this might happen.  Just ignore the record.
			} else {
				// Get the exercise node in our 4mappingXml, creating a new one if it doesn't yet exist
				$exerciseXPath = $mappingXml->xpath('exercise[@id="'.$record['F_ExerciseID'].'"]');
				if (count($exerciseXPath) == 0) {
					$exercise = $mappingXml->addChild("exercise");
					$exercise->addAttribute("id", $record['F_ExerciseID']);
					$exercise->addAttribute("done", 0);
				} else {
					$exercise = $exerciseXPath[0];
				}
				
				// Now add the score node and increment the done counter
				$score = $exercise->addChild("score");
				$score->addAttribute('score', $record['F_Score']);
				$score->addAttribute('duration', $record['F_Duration']);
				$score->addAttribute('datetime', $record['F_DateStamp']);
				
				$exercise["done"] = $exercise["done"] + 1;
			}
		}
		
		return $mappingXml;
	}
	
}