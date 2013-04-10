<?php
require_once(dirname(__FILE__)."/xml/XmlUtils.php");
require_once(dirname(__FILE__)."/crypto/UniqueIdGenerator.php");
require_once(dirname(__FILE__)."/CopyOps.php");

class CourseOps {
	
	var $db;

	var $accountFolder;
	
	var $defaultXML = '
<bento xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<script id="model" type="application/xml">
			<menu />
		</script>
	</head>
</bento>
';
	
	function __construct($db, $accountFolder = null) {
		$this->db = $db;
		if ($accountFolder) 
			$this->setAccountFolder($accountFolder);
			
		$this->copyOps = new CopyOps();
		$this->manageableOps = new ManageableOps($db);
	}
	
	/**
	 * If you changed the db, you'll need to refresh it here
	 * Not a very neat function...
	 */
	function changeDB($db) {
		$this->db = $db;
	} 
	
	// gh#122	
	public function setAccountFolder($accountFolder) {
		$this->accountFolder = $accountFolder;
		$this->courseFilename = $this->accountFolder."/courses.xml";
	}
	
	public function courseCreate($courseObj) {
		$accountFolder = $this->accountFolder;
		$defaultXML = $this->defaultXML;
		$id = UniqueIdGenerator::getUniqId();
		
		XmlUtils::rewriteXml($this->courseFilename, function($xml) use($courseObj, $accountFolder, $defaultXML, $id) {
			// Create a new course passing in the properties as XML attributes
			$courseNode = $xml->courses->addChild("course");
			$courseNode->addAttribute("id", $id);
			$courseNode->addAttribute("href", $id."/menu.xml");
			foreach ($courseObj as $key => $value) {
				// gh#184 Don't duplicate caption in course and menu
				switch (strtolower($key)) {
					case 'id':
					case 'caption':
						break;
					default:
						$courseNode->addAttribute($key, $value);
				}
			}
			// Make a folder for the course
			mkdir($accountFolder."/".$id);
			
			// Make a default menu.xml file
			$menuXml = simplexml_load_string($defaultXML);

			// The course node in menu.xml is basically the same as $courseNode above minus the href
			$menuCourseNode = $menuXml->head->script->menu->addChild("course");
			$menuCourseNode->addAttribute("id", $id);
			$menuCourseNode->addAttribute("class", ""); // In order for progress to work the course needs an empty class
			foreach ($courseObj as $key => $value)
				if (strtolower($key) != "id") $menuCourseNode->addAttribute($key, $value);
			
			// Add a default unit
			$unitNode = $menuCourseNode->addChild("unit");
			$unitNode->addAttribute("caption", "My unit");
			$unitNode->addAttribute("description", "My unit description");
			
			file_put_contents($accountFolder."/".$id."/menu.xml", $menuXml->saveXML());
		});
		
		// Return the id and filename of the new course
		return array("id" => $id, "filename" => $id."/menu.xml");
	}
	
	public function courseSave($filename, $menuXml) {
		// Protect again directory traversal attacks; the filename *must* be in the form <some hex value>/menu.xml otherwise we are being fiddled with
		if (preg_match("/^([0-9a-f]+)\/menu\.xml$/", $filename, $matches) != 1) {
			throw $this->copyOps->getExceptionForId("errorSavingCourse");
		}
		
		// Get the course id
		$courseId = $matches[1];
		
		// Check the file exists
		$menuXMLFilename = "$this->accountFolder/$filename";
		if (!file_exists($menuXMLFilename)) {
			throw $this->copyOps->getExceptionForId("errorSavingCourse");
		}
		
		$db = $this->db;
		$copyOps = $this->copyOps;
		$accountFolder = $this->accountFolder;
		
		// TODO: it would be rather nice to validate $xml against an xsd
		return XmlUtils::overwriteXml($menuXMLFilename, $menuXml, function($xml) use($courseId, $accountFolder, $db, $copyOps) {
			$db->StartTrans();
			
			// SimpleXML doesn't like default namespaces in xpath expressions so define the XHTML namespace explicitly
			$xml->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
			
			$courses = $xml->xpath("//xmlns:course");
			
			// Sanity checks
			if (sizeof($courses) != 1)
				throw new Exception("Rotterdam menu.xml files must have exactly one course node");
			
			$course = $courses[0];
			
			// If the course is missing an id then add it in
			if (!isset($course['id'])) $course['id'] = $courseId;
			
			// If the units or exercises are missing ids then generate them.  At the same time if any unit has a tempid attribute, remove it.
			foreach ($course->unit as $unit) {
				if (!isset($unit['id'])) $unit['id'] = UniqueIdGenerator::getUniqId();
				foreach ($unit->exercise as $exercise) {
					if (!isset($exercise['id'])) $exercise['id'] = UniqueIdGenerator::getUniqId();
					if (isset($exercise['tempid'])) unset($exercise['tempid']); // gh#90
				}
			}
			
			// This stuff should really go into a transform (fromXML()?), but for now hardcode it here
			
			// gh#148 If you have just removed publication data for a group, that will NOT exist here
			// but we do need to delete it. So first step is to delete ALL records for groups in the list
			// then you can add them back below.
			$groupIDs = implode(',', Session::get('groupTreeIDs'));
			$db->Execute("DELETE FROM T_CourseStart WHERE F_GroupID in ($groupIDs) AND F_CourseID = ?", array((string)$course['id']));
			$db->Execute("DELETE FROM T_UnitStart WHERE F_GroupID in ($groupIDs) AND F_CourseID = ?", array((string)$course['id']));
			
			// 1. Write publication data to the database
 			foreach ($course->publication->group as $group) {
				// If we are missing any required data then throw an exception
				if (!isset($group['unitInterval']) || $group['unitInterval'] == "" ||
					!isset($group['seePastUnits']) || $group['seePastUnits'] == "" ||
					!isset($group['startDate']) || $group['startDate'] == "" //||
					//!isset($group['endDate']) || $group['endDate'] == ""
					)
					throw $copyOps->getExceptionForId("errorSavingCourseDates");
				
				// 1.1 First write the T_CourseStart row
				$fields = array(
					"F_GroupID" => (string)$group['id'],
					"F_RootID" => Session::get('rootID'),
					"F_CourseID" => (string)$course['id'],
					"F_StartMethod" => "group",
					"F_UnitInterval" => $group['unitInterval'],
					"F_SeePastUnits" => (($group['seePastUnits'] == "true") ? 1 : 0),
					"F_StartDate" => $group['startDate'],
					"F_EndDate" => $group['endDate']
				);
				
				// gh#148 PrimaryKey is just groupID and courseID
				//$db->Replace("T_CourseStart", $fields, array("F_GroupID", "F_RootID", "F_CourseID"), true);
				$db->Replace("T_CourseStart", $fields, array("F_GroupID", "F_CourseID"), true);
				
				// 2. Next rewrite any rows in T_UnitStart relating to this course
				// Currently we figure this out here, but this may be better calculated on the client since at some point it will be editable anyway
				$startTimestamp = strtotime($group['startDate']);
				foreach ($course->unit as $unit) {
					$fields = array(
						"F_GroupID" => (string)$group['id'],
						"F_RootID" => Session::get('rootID'),
						"F_CourseID" => (string)$course['id'],
						"F_UnitID" => (string)$unit['id'],
						"F_StartDate" => $startTimestamp
					);
					
					$db->AutoExecute("T_UnitStart", $fields, "INSERT");
					
					$startTimestamp += $group['unitInterval'] * 86400;
				}
			}
			
			// 3. Remove publication data so it doesn't get saved
			// gh#191 If you have iterated round the publication loop, you can't now unset it (at least with my PHP)
			//unset($course->publication);
			$dom = dom_import_simplexml($course->publication);
       		$dom->parentNode->removeChild($dom);
			
			$db->CompleteTrans();
		});
	}
	
	public function courseDelete($courseXmlString) {
		// Turn the XML string into SimpleXML
		$course = simplexml_load_string($courseXmlString);
		$accountFolder = $this->accountFolder;
		$db = $this->db;
		
		XmlUtils::rewriteXml($this->courseFilename, function($xml) use($course, $accountFolder, $db) {
			$db->StartTrans();
			
			// SimpleXML doesn't like default namespaces in xpath expressions so define the XHTML namespace explicitly
			$xml->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
			
			// Find the course node in the xml and delete it
			$courseId = $course['id'];
			foreach ($xml->xpath("//xmlns:course[@id='$courseId']") as $courseNode) {
				unset($courseNode[0]);
			}
			
			// Rename the folder such that it is prefixed with "deleted_"
			if (!rename($accountFolder."/".$courseId,  $accountFolder."/deleted_".$courseId))
				throw new Exception("Unable to rename folder and so could not delete course");
			
			// #155
			$db->Execute("DELETE FROM T_CourseStart WHERE F_RootID = ? AND F_CourseID = ?", array(Session::get('rootID'), $courseId));
			$db->Execute("DELETE FROM T_UnitStart WHERE F_RootID = ? AND F_CourseID = ?", array(Session::get('rootID'), $courseId));
			
			$db->CompleteTrans();
		});
	}
	
	public function getCourseStart($id) {
		$groupID = Session::get('groupID');
		do {
			$sql = "SELECT F_GroupID, F_UnitInterval, F_SeePastUnits, ".$this->db->SQLDate("Y-m-d", "F_StartDate")." F_StartDate, ".$this->db->SQLDate("Y-m-d 23:59:59", "F_EndDate")." F_EndDate ".
			   	   "FROM T_CourseStart ".
			   	   "WHERE F_GroupID = ? ".
			  	   "AND F_RootID = ? ".
			  	   "AND F_CourseID = ?";
			$results = $this->db->GetArray($sql, array($groupID, Session::get('rootID'), $id));
			$result = (sizeof($results) == 0) ? null : $results[0];
			$groupID = $this->manageableOps->getGroupParent($groupID);
			
			// It is possible to have a result which doesn't contain all the bits we need (e.g. a start date, end date and unit interval) so only count if we have all
			// gh#118 But unitInterval might be 0 - which is fine
			$gotResult = !(is_null($result)) && ($result['F_UnitInterval'] >=0 ) && $result['F_StartDate'] && $result['F_EndDate'];
		} while (!$gotResult && !is_null($groupID));
		
		return $result;
	}

	// gh#122
	public function getCourse($id) {
		$xml = simplexml_load_file($this->accountFolder."/".$id."/menu.xml");
		return $xml->head->script->menu->course;
	}

	// gh#122
	public function getCourseUsersFromGroup($courseID, $groupID, $today){

		$groupArray = $this->getGroupSubgroups($groupID, $courseID);
		$groupList = implode(',', $groupArray);
		
		// Using the list of all groups, get the users in them
		$sql = <<<SQL
			SELECT u.* FROM T_User u, T_Membership m 
			WHERE u.F_UserID = m.F_UserID
			AND m.F_GroupID in ($groupList)
			AND (u.F_ExpiryDate >= ? OR u.F_ExpiryDate IS NULL)
SQL;
		$bindingParams = array($today);
		
		return $this->db->Execute($sql, $bindingParams);
	}
	
	// gh#122 Recursive function to get all subgroups of this group
	// that do NOT have their own course publication date
	private function getGroupSubgroups($startGroupID, $courseID) {
		$subGroupIDs = array($startGroupID);
		$sql = <<<EOD
				SELECT F_GroupID
				FROM T_Groupstructure
				WHERE F_GroupParent = ?
				AND F_GroupParent <> F_GroupID
EOD;
		$groupRS = $this->db->Execute($sql, array($startGroupID));
		
		if ($groupRS->recordCount()>0) {		
			foreach ($groupRS->GetArray() as $group) {
				// Only include this group if it doesn't have its own publication for this course
				$sql = <<<EOD
						SELECT *
						FROM T_CourseStart
						WHERE F_GroupID = ?
						AND F_CourseID = ?
EOD;
				$courseRS = $this->db->Execute($sql, array($group['F_GroupID'], $courseID));
				
				if ($courseRS->recordCount() == 0) {		
					$subGroupIDs = array_merge($subGroupIDs, $this->getGroupSubgroups($group['F_GroupID'], $courseID));
					
				}
			}
		} 
		
		return $subGroupIDs;
	}
		
}