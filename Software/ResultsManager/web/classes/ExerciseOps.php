<?php
require_once(dirname(__FILE__)."/xml/XmlUtils.php");

class ExerciseOps {
	
	function __construct($accountFolder = null) {
		$this->accountFolder = $accountFolder;
		
		$this->copyOps = new CopyOps();
	}
	
	public function exerciseSave($courseID, $filename, $exerciseXml) {
		// Protect again directory traversal attacks; the course id must be a hex value (actually probably an integer, but anyway)
		if (preg_match("/^([0-9a-f]+)$/", $courseID, $matches) != 1) {
			throw $this->copyOps->getExceptionForId("errorSavingExercise", array("reason" => "corrupt course id"));
		}
		
		// Protect again directory traversal attacks; the filename *must* be in the form exercises/<some hex value>.xml otherwise we are being fiddled with
		if (preg_match("/^exercises\/([0-9a-f]+)\.xml$/", $filename, $matches) != 1) {
			throw $this->copyOps->getExceptionForId("errorSavingExercise", array("reason" => "corrupt file name"));
		}
		
		$exerciseXMLFilename = "{$this->accountFolder}/$courseID/$filename";
		
		return XmlUtils::overwriteXml($exerciseXMLFilename, $exerciseXml);
	}
	
}