<?php

class CourseOps {
	
	var $accountFolder;
	
	function CourseOps($accountFolder = null) {
		$this->accountFolder = $accountFolder;
		$this->courseFilename = $this->accountFolder."/courses.xml";
	}
	
	public function courseCreate($course) {
		$accountFolder = $this->accountFolder;
		$this->rewriteCourseXml(function($xml) use($course, $accountFolder) {
			$id = uniqid();
						
			// Create a new course passing in the properties as XML attributes
			$courseNode = $xml->courses->addChild("course");
			$courseNode->addAttribute("id", $id);
			$courseNode->addAttribute("href", $id."/menu.xml");
			foreach ($course as $key => $value)
				if (strtolower($key) != "id") $courseNode->addAttribute($key, $value);
			
			// Make a folder for the course
			mkdir($accountFolder."/".$id);
		});
	}
	
	public function courseUpdate() {
		
	}
	
	public function courseDelete() {
		
	}
	
	/**
	 * Functionally read, process (using $func) and write the course XML file.  This uses locking to ensure that people can't modify the file
	 * concurrently.
	 * 
	 * TODO: formatOutput doesn't seem to be doing anything - this will quickly get annoying whilst debugging
	 */
	private function rewriteCourseXml($func) {
		$fp = fopen($this->courseFilename, "r+t");
		if (flock($fp, LOCK_EX)) {
			// Read the file
			$contents = fread($fp, filesize($this->courseFilename));
			$xml = simplexml_load_string($contents);
			
			$func($xml);
			
			$dom = new DOMDocument();
			$dom->formatOutput = true;
			/*$domnode = dom_import_simplexml($xml);
			$domnode = $dom->importNode($domnode, true);
			$dom->appendChild($domnode);*/
			$dom->loadXML($xml->asXML());
			
			ftruncate($fp, 0);
			fseek($fp, 0);
			fwrite($fp, $dom->saveXML());
			fflush($fp);
			flock($fp, LOCK_UN);
		} else {
			throw new Exception("Problem whilst locking course.xml");
		}
		
		fclose($fp);
	}
	
}