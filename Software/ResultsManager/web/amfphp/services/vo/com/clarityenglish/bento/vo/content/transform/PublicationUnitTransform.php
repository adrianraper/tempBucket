<?php
require_once(dirname(__FILE__)."/XmlTransform.php");

/**
 * This transform removes any unpublished units for this user from menu.xml.  It is used by Rotterdam player.
 */
class PublicationUnitTransform extends XmlTransform {
	
	var $_explicitType = 'com.clarityenglish.bento.vo.content.transform.PublicationUnitTransform';
	
	public function transform($db, $xml, $href, $service) {
		// #154 - only do the transform for students
		$user = $service->manageableOps->getUserById(Session::get('userID'));
		if ($user->userType > User::USER_TYPE_STUDENT) return;
		
		// Register the namespace for menu xml so we can run xpath queries against it
		$xml->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
		
		// Get the course
		$course = $xml->head->script->menu->course[0];
		
		// Get the course start object for this course
		$courseStartObj = $service->courseOps->getCourseStart($course['id']);
		
		if (is_null($courseStartObj)) {
			// TODO: This shouldn't be possible!  Throw some kind of error.
		} else {
			if (time() > strtotime($courseStartObj['F_EndDate'])) {
				// If we are here then we are passed the end date and the course has finished, so there are no valid unit ids.
				$validUnitIds = array();
			} else {
				// Get the unit ids and start dates from T_UnitStart for all units that are before the current date (use SQL to strip out the time component)
				$sql = <<<EOD
					SELECT F_UnitID
						FROM T_UnitStart
						WHERE F_GroupID = ?
						AND F_RootID = ?
						AND F_CourseID = ?
						AND F_StartDate <= DATE(NOW())
						ORDER BY F_StartDate
EOD;
				
				// gh#144 Remember that it is not necessarily the user's group that we are basing this on, but the
				// most relevant group in the hierarchy
				//$results = $db->GetArray($sql, array(Session::get('groupID'), Session::get('rootID'), $course['id']));
				$results = $db->GetArray($sql, array($courseStartObj['F_GroupID'], Session::get('rootID'), $course['id']));
				
				// If see past units is off, then we are only interested in the last available unit (if there is one)
				if (!$courseStartObj['F_SeePastUnits'])
					$results = (sizeof($results) == 0) ? array() : array(array_pop($results));
				
				// Turn $results into a flat array of ids
				$validUnitIds = array();
				foreach ($results as $result)
					$validUnitIds[] = $result['F_UnitID'];
			}
			
			// Now go through the XML setting the enabled flag for any unit that isn't in $validUnitIds
			foreach ($course->unit as $unit) {
				if (!in_array($unit['id'], $validUnitIds)) {
					$unit->addAttribute("enabledFlag", ($unit['enabledFlag'] || 0) | 8);
				}
			}
		}
	}
	
}