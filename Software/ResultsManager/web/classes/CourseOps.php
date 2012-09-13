<?php
require_once(dirname(__FILE__)."/xml/XmlUtils.php");

class CourseOps {
	
	var $accountFolder;
	
	var $defaultXML = <<<XML
<bento xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<script id="model" type="application/xml">
			<menu>
				<course />
			</menu>
		</script>
	</head>
</bento>
XML;
	
	function CourseOps($accountFolder = null) {
		$this->accountFolder = $accountFolder;
		$this->courseFilename = $this->accountFolder."/courses.xml";
	}
	
	public function courseCreate($course) {
		$accountFolder = $this->accountFolder;
		$defaultXML = $this->defaultXML;
		XmlUtils::rewriteCourseXml($this->courseFilename, function($xml) use($course, $accountFolder, $defaultXML) {
			$id = uniqid();
			
			// Create a new course passing in the properties as XML attributes
			$courseNode = $xml->courses->addChild("course");
			$courseNode->addAttribute("id", $id);
			$courseNode->addAttribute("href", $id."/menu.xml");
			foreach ($course as $key => $value)
				if (strtolower($key) != "id") $courseNode->addAttribute($key, $value);
			
			// Make a folder for the course
			mkdir($accountFolder."/".$id);
			
			// Make a default menu.xml file
			file_put_contents($accountFolder."/".$id."/menu.xml", $defaultXML);
		});
	}
	
	public function courseUpdate() {
		
	}
	
	public function courseDelete() {
		
	}
	
}