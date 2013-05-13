<?php
require_once(dirname(__FILE__)."/../../../../../bento/vo/content/transform/XmlTransform.php");

// gh#294
class SingleVideoNodeTransform extends XmlTransform {
	
	var $_explicitType = 'com.clarityenglish.rotterdam.player.vo.content.transform.SingleVideoNodeTransform';
	
	public function transform($db, $xml, $href, $service) {
		// Register the namespace for menu xml so we can run xpath queries against it
		$xml->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
		
		foreach ($xml->head->script->menu->course->unit as $unit) {
			$atLeastOneExercise = false;
			foreach ($unit->exercise as $exercise) {
				if ($exercise["type"] == "video") {
					if ($atLeastOneExercise) {
						unset($exercise["src"]);
						$exercise["type"] = "text";
						$text = '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>'.$service->copyOps->getCopyForId("errorSingleVideoIOS").'</span></p></TextFlow>';
						
						if (isset($exercise->text)) {
							$textDom = dom_import_simplexml($exercise->text);
        					$textDom->parentNode->removeChild($textDom);
						}
						
						$textNode = $exercise->addChild("text");
						
						$textDom = dom_import_simplexml($textNode); 
						$textDom->appendChild($textDom->ownerDocument->createCDATASection($text)); 
					}
					
					$atLeastOneExercise = true;
				}
			}
		}
	}
	
}