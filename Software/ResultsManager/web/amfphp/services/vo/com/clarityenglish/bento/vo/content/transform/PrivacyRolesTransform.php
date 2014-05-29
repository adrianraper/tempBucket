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
		
		// Create a <permission> node to hold the data
		$permissionNode = $course[0]->addChild("permission");
		
		// TODO Do the data retrieval in courseOps or here?
		// $courseEditableObj = $service->courseOps->getEditablePermission($href->options['courseId']);
		// Get data for the <editable> attribute
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
				$editable = $dbObj->editable;
				break;
			// gh#911
			case 0:
				// Zero records, bad. Take it to mean locked, and let courseSave fix it.
				$editable = 0;
				break;
			default:
				return false;
		}
		$permissionNode->addAttribute("editable", ($editable == 1) ? 'true' : 'false');
		$role = $service->courseOps->getUserRole($courseID);
		$permissionNode->addAttribute("role", $role);
		
		// Create a <privacy> node to hold the data
		$privacyNode = $course[0]->addChild("privacy");
		
		// Get data for the <owner> node (who must be a teacher)
		$ownerNode = $privacyNode->addChild("owner");
		$sql = <<<EOD
				SELECT c.F_Role, c.F_UserID as id, u.F_Username as name
				FROM T_CourseRoles c, T_User u
				WHERE c.F_CourseID = ?
				AND c.F_UserID is not null
				AND u.F_UserID = c.F_UserID
				AND c.F_Role = ?
				AND u.F_UserType <> ?
EOD;
		$rs = $db->Execute($sql, array($courseID, Course::ROLE_OWNER, User::USER_TYPE_STUDENT));
		switch ($rs->RecordCount()) {
			case 1:
				// One record, good.
				$dbObj = $rs->FetchNextObj();
				break;
			case 0:
				// No records suggests that the owner has been deleted, or turned into a student
				// So IF you are the admin, set yourself to be the owner
				if (Session::get('userType') == User::USER_TYPE_ADMINISTRATOR) {
					// Delete the old one
					$sql = <<<SQL
						DELETE FROM T_CourseRoles 
						WHERE F_CourseID = ?
						AND F_Role = ?
SQL;
					$bindingParams = array($courseID, Course::ROLE_OWNER);
					$rs = $db->Execute($sql, $bindingParams);
					
					$sql = <<<SQL
						INSERT INTO T_CourseRoles 
						(F_CourseID, F_UserID, F_Role, F_DateStamp)
						VALUES (?,?,?,?)
SQL;
					$now = new DateTime();
					$bindingParams = array($courseID, Session::get('userID'), Course::ROLE_OWNER, $now->format('Y-m-d H:i:s'));
					$rc = $db->Execute($sql, $bindingParams);
					// and build a record for 
					$sql = <<<EOD
							SELECT c.F_Role, c.F_UserID as id, u.F_Username as name
							FROM T_CourseRoles c, T_User u
							WHERE c.F_CourseID = ?
							AND c.F_UserID is not null
							AND u.F_UserID = c.F_UserID
							AND c.F_Role = ?
EOD;
					$rs = $db->Execute($sql, array($courseID, Course::ROLE_OWNER));
					$dbObj = $rs->FetchNextObj();
				}
				break;				
			default:
				return false;
		}
		$roleNode = $ownerNode->addChild("user");
		$roleNode->addAttribute("id", $dbObj->id);
		$roleNode->addAttribute("name", $dbObj->name);
				
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
		$rs = $db->Execute($sql, array($courseID, Course::ROLE_COLLABORATOR));
		if ($rs) {
			foreach ($rs as $courseRoleObj) {
				$roleNode = $collaboratorsNode->addChild("user");
				$roleNode->addAttribute("id", $courseRoleObj['id']);
				$roleNode->addAttribute("name", $courseRoleObj['name']);
			}
		}
		// repeat for groups
		$sql = <<<EOD
			SELECT c.F_Role, c.F_GroupID as id, g.F_GroupName as name
			FROM T_CourseRoles c, T_Groupstructure g
			WHERE c.F_CourseID = ?
			AND c.F_GroupID is not null 
			AND g.F_GroupID = c.F_GroupID
			AND c.F_Role = ?
EOD;
		$rs = $db->Execute($sql, array($courseID, Course::ROLE_COLLABORATOR));
		if ($rs) {
			foreach ($rs as $courseRoleObj) {
				$roleNode = $collaboratorsNode->addChild("group");
				$roleNode->addAttribute("id", $courseRoleObj['id']);
				$roleNode->addAttribute("name", $courseRoleObj['name']);
				// If this is the current user's group, note that in the node attribute
				if ($courseRoleObj['id'] == Session::get('groupID'))
					$collaboratorsNode->addAttribute("group", "true");
			}
		}
		
		// then the root
		$sql = <<<EOD
				SELECT c.F_Role, c.F_RootID as id, a.F_Name as name
				FROM T_CourseRoles c, T_AccountRoot a
				WHERE c.F_CourseID = ?
				AND c.F_RootID is not null 
				AND a.F_RootID = c.F_RootID
				AND c.F_Role = ?
EOD;
		$rs = $db->Execute($sql, array($courseID, Course::ROLE_COLLABORATOR));
		if ($rs) {
			foreach ($rs as $courseRoleObj) {
				$roleNode = $collaboratorsNode->addChild("root");
				$roleNode->addAttribute("id", $courseRoleObj['id']);
				$roleNode->addAttribute("name", $courseRoleObj['name']);
				// If this is the current user's root, note that in the node attribute
				if ($courseRoleObj['id'] == Session::get('rootID'))
					$collaboratorsNode->addAttribute("root", "true");
			}
		}
		
		// Get data for the <publishers> node
		$publishersNode = $privacyNode->addChild("publishers");
		// first the users
		$sql = <<<EOD
			SELECT c.F_Role, c.F_UserID as id, u.F_Username as name
			FROM T_CourseRoles c, T_User u
			WHERE c.F_CourseID = ?
			AND c.F_UserID is not null
			AND u.F_UserID = c.F_UserID
			AND c.F_Role = ?
EOD;
		$rs = $db->Execute($sql, array($courseID, Course::ROLE_PUBLISHER));
		if ($rs) {
			foreach ($rs as $courseRoleObj) {
				$roleNode = $publishersNode->addChild("user");
				$roleNode->addAttribute("id", $courseRoleObj['id']);
				$roleNode->addAttribute("name", $courseRoleObj['name']);
			}
		}
		// repeat for groups
		$sql = <<<EOD
			SELECT c.F_Role, c.F_GroupID as id, g.F_GroupName as name
			FROM T_CourseRoles c, T_Groupstructure g
			WHERE c.F_CourseID = ?
			AND c.F_GroupID is not null 
			AND g.F_GroupID = c.F_GroupID
			AND c.F_Role = ?
EOD;
		$rs = $db->Execute($sql, array($courseID, Course::ROLE_PUBLISHER));
		if ($rs) {
			foreach ($rs as $courseRoleObj) {
				$roleNode = $publishersNode->addChild("group");
				$roleNode->addAttribute("id", $courseRoleObj['id']);
				$roleNode->addAttribute("name", $courseRoleObj['name']);
				// If this is the current user's group, note that in the node attribute
				if ($courseRoleObj['id'] == Session::get('groupID'))
					$publishersNode->addAttribute("group", "true");
			}
		}
		
		// then the root
		$sql = <<<EOD
				SELECT c.F_Role, c.F_RootID as id, a.F_Name as name
				FROM T_CourseRoles c, T_AccountRoot a
				WHERE c.F_CourseID = ?
				AND c.F_RootID is not null 
				AND a.F_RootID = c.F_RootID
				AND c.F_Role = ?
EOD;
		$rs = $db->Execute($sql, array($courseID, Course::ROLE_PUBLISHER));
		if ($rs) {
			foreach ($rs as $courseRoleObj) {
				$roleNode = $publishersNode->addChild("root");
				$roleNode->addAttribute("id", $courseRoleObj['id']);
				$roleNode->addAttribute("name", $courseRoleObj['name']);
				// If this is the current user's root, note that in the node attribute
				if ($courseRoleObj['id'] == Session::get('rootID'))
					$publishersNode->addAttribute("root", "true");
			}
		}
	}
}