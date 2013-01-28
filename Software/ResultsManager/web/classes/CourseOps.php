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
				$fields = array(
					"F_GroupID" => $group['id'],
					"F_RootID" => Session::get('rootID'),
					"F_CourseID" => $course['id'],
					"F_StartMethod" => "group"
				);
				
				if (isset($group['unitInterval'])) $fields["F_UnitInterval"] = $group['unitInterval'];
				if (isset($group['seePastUnits'])) $fields["F_SeePastUnits"] = ($group['seePastUnits'] == "true") ? 1 : 0;
				if (isset($group['startDate'])) $fields["F_StartDate"] = $group['startDate'];
				
				$db->Replace("T_CourseStart", $fields, array("F_GroupID", "F_RootID", "F_CourseID"), true);
			}
			
			// 2. Remove publication data so it doesn't get saved
			unset($course->publication);
		});
	}
	
	public function courseDelete($courseXmlString) {
		// Turn the XML string into SimpleXML
		$course = simplexml_load_string($courseXmlString);
		$accountFolder = $this->accountFolder;
		
		XmlUtils::rewriteXml($this->courseFilename, function($xml) use($course, $accountFolder) {
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
		});
	}
	
}