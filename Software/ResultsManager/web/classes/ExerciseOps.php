<?php
require_once(dirname(__FILE__)."/xml/XmlUtils.php");

class ExerciseOps {
	
		var $defaultXML = '
<?xml version="1.0"?>
<bento xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <script id="authoring" type="application/xml">
      <settings>
        <param name="exerciseType" value="MultipleChoiceQuestion" />
        <param name="questionNumberingEnabled" value="true" />
        <param name="questionNumbering" value="1" />
        <param name="questionStartNumber" value="1" />
        <param name="markingType" value="instant" />
        <param name="exerciseFeedbackEnabled" value="true" />
        <param name="exerciseFeedbackText"></param>
        <param name="testMode" value="false" />
        <param name="timerEnabled" value="false" />
        <param name="timerMinutes" value="3.5" />
        <param name="showFirstNQuestions" value="3" />
        <param name="questionByQuestionEnabled" value="false" />
      </settings>
      <questions>
      </questions>
    </script>
  </head>
</bento>
';
	
	function __construct($accountFolder = null) {
		$this->accountFolder = $accountFolder;
		
		$this->copyOps = new CopyOps();
	}
	
	public function exerciseCreate($courseID, $filename) {
		$this->validateCourseIDAndFilename($courseID, $filename);
		
		$exerciseXMLFilename = "{$this->accountFolder}/$courseID/$filename";
		
		// TODO: Needs to take into account question type and update the XML instead of having hardcoded MultipleChoiceQuestion
		
		$result = file_put_contents($exerciseXMLFilename, $this->defaultXML);
		
		if ($result === false) {
			throw $this->copyOps->getExceptionForId("errorSavingExercise", array("reason" => "unable to create exercise file"));
		} else {
			return true;
		}
	}
	
	public function exerciseSave($courseID, $filename, $exerciseXml) {
		$this->validateCourseIDAndFilename($courseID, $filename);
		
		$exerciseXMLFilename = "{$this->accountFolder}/$courseID/$filename";
		
		return XmlUtils::overwriteXml($exerciseXMLFilename, $exerciseXml);
	}
	
	protected function validateCourseIDAndFilename($courseID, $filename) {
		// Protect again directory traversal attacks; the course id must be a hex value (actually probably an integer, but anyway)
		if (preg_match("/^([0-9a-f]+)$/", $courseID, $matches) != 1) {
			throw $this->copyOps->getExceptionForId("errorSavingExercise", array("reason" => "corrupt course id"));
		}
		
		// Protect again directory traversal attacks; the filename *must* be in the form exercises/<some hex value>.xml otherwise we are being fiddled with
		if (preg_match("/^exercises\/([0-9a-f]+)\.xml$/", $filename, $matches) != 1) {
			throw $this->copyOps->getExceptionForId("errorSavingExercise", array("reason" => "corrupt file name"));
		}
	}
	
}