<?php

class CourseOps {
	
	var $accountFolder;
	
	function CourseOps($accountFolder = null) {
		$this->accountFolder = $accountFolder;
		$this->courseFilename = $this->accountFolder."/courses.xml";
	}
	
	public function courseCreate($course) {
		$this->rewriteCourseXml(function($xml) use($course) {
			$courseNode = $xml->courses->addChild("course");
			
			foreach ($course as $key => $value)
				$courseNode->addAttribute($key, $value);
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
	 * TODO: formatOutput doesn't seem to be doing anything
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