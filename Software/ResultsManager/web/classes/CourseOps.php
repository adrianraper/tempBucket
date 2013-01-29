<?php
require_once(dirname(__FILE__)."/xml/XmlUtils.php");
require_once(dirname(__FILE__)."/crypto/UniqueIdGenerator.php");
require_once(dirname(__FILE__)."/CopyOps.php");

class CourseOps {
	
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
		$this->accountFolder = $accountFolder;
		$this->courseFilename = $this->accountFolder."/courses.xml";
		
		$this->copyOps = new CopyOps();
		$this->manageableOps = new ManageableOps($db);
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
			foreach ($courseObj as $key => $value)
				if (strtolower($key) != "id") $courseNode->addAttribute($key, $value);
			
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
		
		// TODO: it would be rather nice to validate $xml against an xsd
		return XmlUtils::overwriteXml($menuXMLFilename, $menuXml, function($xml) use($courseId, $accountFolder, $db) {
			// SimpleXML doesn't like default namespaces in xpath expressions so define the XHTML namespace explicitly
			$xml->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
			
			$courses = $xml->xpath("//xmlns:course");
			
			// Sanity checks
			if (sizeof($courses) != 1)
				throw new Exception("Rotterdam menu.xml files must have exactly one course node");
			
			$course = $courses[0];
			
			// If the course is missing an id then add it in
			if (!isset($course['id'])) $course['id'] = $courseId;
			
			// If the units or exercises are missing ids then generate them
			foreach ($course->unit as $unit) {
				if (!isset($unit['id'])) $unit['id'] = UniqueIdGenerator::getUniqId();
				foreach ($unit->exercise as $exercise) {
					if (!isset($exercise['id'])) $exercise['id'] = UniqueIdGenerator::getUniqId();
				}
			}
			
			// This stuff should really go into a transform (fromXML()?), but for now hardcode it here
			
			// 1. Write publication data to the database
			foreach ($course->publication->group as $group) {
				// 1.1 First write the T_CourseStart row
				$fields = array(
					"F_GroupID" => (string)$group['id'],
					"F_RootID" => Session::get('rootID'),
					"F_CourseID" => (string)$course['id'],
					"F_StartMethod" => "group"
				);
				
				if (isset($group['unitInterval']) && $group['unitInterval'] != "") $fields["F_UnitInterval"] = $group['unitInterval'];
				if (isset($group['seePastUnits']) && $group['seePastUnits'] != "") $fields["F_SeePastUnits"] = ($group['seePastUnits'] == "true") ? 1 : 0;
				if (isset($group['startDate']) && $group['startDate'] != "") $fields["F_StartDate"] = $group['startDate'];
				if (isset($group['endDate']) && $group['endDate'] != "") $fields["F_EndDate"] = $group['endDate'];
				
				$db->Replace("T_CourseStart", $fields, array("F_GroupID", "F_RootID", "F_CourseID"), true);
				
				// 2.2 Next delete and rewrite any rows in T_UnitStart relating to this course
				$db->Execute("DELETE FROM T_UnitStart WHERE F_GroupID = ? AND F_RootID = ? AND F_CourseID = ?", array((string)$group['id'], Session::get('rootID'), (string)$course['id']));
				
				// Currently we figure this out here, but this may be better calculated on the client since at some point it will be editable anyway
				if (isset($group['startDate']) && $group['startDate'] != "" && isset($group['unitInterval']) && $group['unitInterval'] != "") {
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
			}
			
			// 2. Remove publication data so it doesn't get saved
			unset($course->publication);
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
			$sql = "SELECT F_GroupID, F_UnitInterval, F_SeePastUnits, ".$this->db->SQLDate("Y-m-d", "F_StartDate")." F_StartDate, ".$this->db->SQLDate("Y-m-d", "F_EndDate")." F_EndDate ".
			   	   "FROM T_CourseStart ".
			   	   "WHERE F_GroupID = ? ".
			  	   "AND F_RootID = ? ".
			  	   "AND F_CourseID = ?";
			$results = $this->db->GetArray($sql, array($groupID, Session::get('rootID'), $id));
			$result = (sizeof($results) == 0) ? null : $results[0];
			$groupID = $this->manageableOps->getGroupParent($groupID);
			
			// It is possible to have a result which doesn't contain all the bits we need (e.g. a start date, end date and unit interval) so only count if we have all
			$gotResult = !(is_null($result)) && $result['F_UnitInterval'] && $result['F_StartDate'] && $result['F_EndDate'];
		} while (!$gotResult && !is_null($groupID));
		
		return $result;
	}
	
}