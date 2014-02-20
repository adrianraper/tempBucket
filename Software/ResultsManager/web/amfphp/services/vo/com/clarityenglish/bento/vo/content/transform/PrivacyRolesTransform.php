<?php
require_once(dirname(__FILE__)."/XmlTransform.php");

/**
 * This transform adds in all privacy information about roles for a course. It is used by Rotterdam builder.
 */
class PrivacyRolesTransform extends XmlTransform {
	
	var $_explicitType = 'com.clarityenglish.bento.vo.content.transform.PrivacyRolesTransform';
	
	public function transform($db, $xml, $href, $service) {
		// Register the namespace for menu xml so we can run xpath queries against it
		$xml->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
		
		// Initialise and prepare
		$courseID = $href->options['courseId'];
		$course = $xml->xpath('/xmlns:bento/xmlns:head/xmlns:script[@id="model"]//xmlns:course[@id="'.$courseID.'"]');
		
		// Create a <privacy> node to hold the data
		$privacyNode = $course[0]->addChild("privacy");
		
		// Do the data retrieval in courseOps or here?
		// $courseEditableObj = $service->courseOps->getEditablePermission($href->options['courseId']);
		// Get data for the <editable> node
		$editableNode = $privacyNode->addChild("editable");
		$sql = <<<EOD
				SELECT F_Editable as editable
				FROM T_CoursePermission 
				WHERE F_CourseID = ?
EOD;
		$rs = $db->Execute($sql, array($courseID));
		switch ($rs->RecordCount()) {
			case 1:
				// One record, good.
				$dbObj = $rs->FetchNextObj();
				break;
			default:
				return false;
		}
		$editableNode->addAttribute("value", ($dbObj->editable == 1) ? 'true' : 'false');

		// Get data for the <collaborators> node
		$collaboratorsNode = $privacyNode->addChild("collaborators");
		// first the users
		$sql = <<<EOD
				SELECT c.F_Role, c.F_UserID as id, u.F_Username as name
				FROM T_CourseRoles c, T_User u
				WHERE c.F_CourseID = ?
				AND c.F_UserID is not null
				AND u.F_UserID = c.F_UserID
				AND c.F_Role = ?
EOD;
		$rs = $db->Execute($sql, array($courseID, 2));
		if ($rs) {
			foreach ($rs as $courseRoleObj) {
				$roleNode = $collaboratorsNode->addChild("user");
				$roleNode->addAttribute("id", $courseRoleObj['id']);
				$roleNode->addAttribute("name", $courseRoleObj['name']);
			}
		}
		// TODO repeat for group
		// then the root
		$sql = <<<EOD
				SELECT c.F_Role, c.F_RootID as id, a.F_Name as name
				FROM T_CourseRoles c, T_AccountRoot a
				WHERE c.F_CourseID = ?
				AND c.F_RootID is not null 
				AND a.F_RootID = c.F_RootID
				AND c.F_Role = ?
EOD;
		$rs = $db->Execute($sql, array($courseID, 2));
		if ($rs) {
			foreach ($rs as $courseRoleObj) {
				$roleNode = $collaboratorsNode->addChild("root");
				$roleNode->addAttribute("id", $courseRoleObj['id']);
				$roleNode->addAttribute("name", $courseRoleObj['name']);
			}
		}
		
		// TODO repeat for publishers
	}
	
}