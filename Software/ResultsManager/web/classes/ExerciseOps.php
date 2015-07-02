<?php
require_once(dirname(__FILE__)."/xml/XmlUtils.php");

class ExerciseOps {
	
		var $defaultXML = '
<?xml version="1.0"?>
<bento xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <script id="authoring" type="application/xml">
      <settings>
        <exerciseType>{type}</exerciseType>
      	<questionNumberingEnabled>true</questionNumberingEnabled>
      	<questionNumbering>1</questionNumbering>
      	<questionStartNumber>1</questionStartNumber>
      	<answerNumbering>3</answerNumbering>
      	<shuffleAnswers>true</shuffleAnswers>
      	<markingType>instant</markingType>
      	<exerciseFeedbackEnabled>false</exerciseFeedbackEnabled>
      	<exerciseFeedbackText></exerciseFeedbackText>
      	<testMode>false</testMode>
      	<timerEnabled>false</timerEnabled>
      	<timerMinutes>5</timerMinutes>
      	<showFirstNQuestions>3</showFirstNQuestions>
      	<questionByQuestionEnabled>false</questionByQuestionEnabled>
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
	
	public function exerciseCreate($courseID, $type, $filename) {
		$this->validateCourseIDAndFilename($courseID, $filename);
		
		// If the exercise folder doesn't exist then create it gh#919
		if (!is_dir("{$this->accountFolder}/$courseID/exercises")) {
			mkdir("{$this->accountFolder}/$courseID/exercises", 0755, true);
		}
		
		$exerciseXMLFilename = "{$this->accountFolder}/$courseID/$filename";
		
		// Replace {type} with the type
		$exerciseXML = preg_replace("/\{type\}/", $type, $this->defaultXML);
		
		$result = file_put_contents($exerciseXMLFilename, $exerciseXML);
		
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
		
		// Protect again directory traversal attacks; the filename *must* be in the form exercises/<some hex value>(.generator)?.xml otherwise we are being fiddled with
		if (preg_match("/^exercises\/([0-9a-f]+)(\.generator)?\.xml$/", $filename, $matches) != 1) {
			throw $this->copyOps->getExceptionForId("errorSavingExercise", array("reason" => "corrupt file name"));
		}
	}
	
}