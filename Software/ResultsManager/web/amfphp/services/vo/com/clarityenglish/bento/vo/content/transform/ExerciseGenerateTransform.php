<?php
require_once(dirname(__FILE__)."/XmlTransform.php");

class ExerciseGenerateTransform extends XmlTransform {
	
	var $_explicitType = 'com.clarityenglish.bento.vo.content.transform.ExerciseGenerateTransform';
	
	public function transform($db, $xml, $href, $service) {
		// Register the namespace for menu xml so we can run xpath queries against it
		$xml->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
		
		$useCache = false;
		$result = $service->templateOps->fetchTemplate("exercise_generator/multiple_choice.xml", array("xml" => $xml->head->script), $useCache);
		
		// Replace the contents of $xml with $result
		return simplexml_load_string($result);
	}
	
}
