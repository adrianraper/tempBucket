<?php
require_once(dirname(__FILE__)."/XmlTransform.php");

class ExerciseGenerateTransform extends XmlTransform {
	
	var $_explicitType = 'com.clarityenglish.bento.vo.content.transform.ExerciseGenerateTransform';
	
	public function transform($db, $xml, $href, $service) {
		// Register the namespace for menu xml so we can run xpath queries against it - THIS ISN'T GETTING THROUGH!
		//$xml->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
		$xml->registerXPathNamespace('def', 'http://www.w3.org/1999/xhtml');
		
		$useCache = false;
		
		// Get the template
		switch ($xml->head->script->settings->exerciseType) {
			case "MultipleChoiceQuestion":
				$template = "exercise_generator/multiple_choice.xml";
				break;
			case "GapFillQuestion":
				$template = "exercise_generator/gap_fill.xml";
				break;
		}
		
		$result = $service->templateOps->fetchTemplate($template, array("xml" => $xml->head->script, "rootXml" => $xml), $useCache);
		
		// Replace the contents of $xml with $result
		return simplexml_load_string($result);
	}
	
}
