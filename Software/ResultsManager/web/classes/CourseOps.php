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
	
	function __construct($accountFolder = null) {
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

			// The course node is basically the same as $courseNode above minus the href
			$courseNode = $menuXml->head->script->menu->addChild("course");
			$courseNode->addAttribute("id", $id);
			foreach ($courseObj as $key => $value)
				if (strtolower($key) != "id") $courseNode->addAttribute($key, $value);
			
			// Add a default unit
			$unitNode = $courseNode->addChild("unit");
			$unitNode->addAttribute("caption", "My unit");
			$unitNode->addAttribute("description", "My unit description");
			
			file_put_contents($accountFolder."/".$id."/menu.xml", $menuXml->saveXML());
		});
		
		// Return the href of the new course
		return $id."/menu.xml";
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
		
		// TODO: it would be rather nice to validate $xml against an xsd
		return XmlUtils::overwriteXml($menuXMLFilename, $menuXml, function($xml) use($courseId, $accountFolder) {
			$courses = $xml->xpath("//course");
			
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
		});
	}
	
	public function courseDelete($courseXmlString) {
		// Turn the XML string into SimpleXML
		$course = simplexml_load_string($courseXmlString);
		$accountFolder = $this->accountFolder;
		
		XmlUtils::rewriteXml($this->courseFilename, function($xml) use($course, $accountFolder) {
			// SimpleXML doesn't like default namespaces in xpath expressions so define the XHTML namespace explicitly
			$xml->registerXPathNamespace('xhtml', 'http://www.w3.org/1999/xhtml');
			
			// Find the course node in the xml and delete it
			$courseId = $course['id'];
			foreach ($xml->xpath("//xhtml:course[@id='$courseId']") as $courseNode) {
				unset($courseNode[0]);
			}
			
			// Rename the folder such that it is prefixed with "deleted_"
			if (!rename($accountFolder."/".$courseId,  $accountFolder."/deleted_".$courseId))
				throw new Exception("Unable to rename folder and so could not delete course");
		});
	}
	
}