<?php
require_once(dirname(__FILE__)."/XmlTransform.php");

class PublicationDatesTransform extends XmlTransform {
	
	var $_explicitType = 'com.clarityenglish.bento.vo.content.transform.PublicationDatesTransform';
	
	public function transform($db, $xml, $options = array()) {
		// Register the namespace for menu xml so we can run xpath queries against it
		$xml->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
		
		// First get a flat array of all the groups (including subgroups) that the logged in user can access
		$groupIDs = array();
		foreach (Session::get('groupIDs') as $groupID) {
			$groupIDs = array_merge($groupIDs, $options['manageableOps']->getGroupSubgroups($groupID));
		}
		
		// Now look in the database for publication data on each of these groups
		$groupIdInString = join(",", $groupIDs);
		$sql = "SELECT F_GroupID, F_UnitInterval, F_SeePastUnits ".
			   "FROM T_CourseStart ".
			   "WHERE F_GroupID IN (".$groupIdInString.") ".
			   "AND F_RootID = ? ".
			   "AND F_CourseID = ?";
		
		$courseStartObjs = $db->GetArray($sql, array(Session::get('rootID'), $options['href']->options['courseId']));
		
		// Create a <publications> node to hold the data
		$course = $xml->xpath('/xmlns:bento/xmlns:head/xmlns:script[@id="model"]//xmlns:course[@id="'.$options['href']->options['courseId'].'"]');
		$publicationNode = $course[0]->addChild("publication");
		
		// Go through the results from the database populating the <publication> node
		foreach ($courseStartObjs as $courseStartObj) {
			$groupNode = $publicationNode->addChild("group");
			$groupNode->addAttribute("id", $courseStartObj['F_GroupID']);
			$groupNode->addAttribute("unitInterval", $courseStartObj['F_UnitInterval']);
			$groupNode->addAttribute("seePastUnits", ($courseStartObj['F_SeePastUnits'] == 1) ? "true" : "false");
			$groupNode->addAttribute("startDate", time());
		}
	}
	
}