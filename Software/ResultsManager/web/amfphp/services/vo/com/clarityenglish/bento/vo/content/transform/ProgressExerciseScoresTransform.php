<?php
require_once(dirname(__FILE__)."/XmlTransform.php");

class ProgressExerciseScoresTransform extends XmlTransform {
	
	var $_explicitType = 'com.clarityenglish.bento.vo.content.transform.ProgressExerciseScoresTransform';
	
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
		
		$done = array();
		
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
				
				// Add the <score> node as a child of the approriate exercise
				$this->addChild($exercise, "<score score='{$record['F_Score']}' duration='{$record['F_Duration']}' datetime='{$record['F_DateStamp']}' />");
				
				// Build up the $done values through the loop (we don't want to set the attributes until they are all ready)
				if ($done[$record['F_ExerciseID']]) {
					$done[$record['F_ExerciseID']]['count'] += 1;
				} else {
					$done[$record['F_ExerciseID']] = array("xml" => $exercise, "count" => 1);
				}
			}
			
			// Now set all the done attributes
			foreach ($done as $exerciseId => $value)
				$this->setAttribute($value['xml'], "done", $value['count']);
		}
	}
	
}