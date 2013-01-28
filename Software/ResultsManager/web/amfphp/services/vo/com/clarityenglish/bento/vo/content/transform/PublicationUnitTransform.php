<?php
require_once(dirname(__FILE__)."/XmlTransform.php");

/**
 * This transform removes any unpublished units for this user from menu.xml.  It is used by Rotterdam player.
 */
class PublicationUnitTransform extends XmlTransform {
	
	var $_explicitType = 'com.clarityenglish.bento.vo.content.transform.PublicationUnitTransform';
	
	public function transform($db, $xml, $href, $service) {
		// Register the namespace for menu xml so we can run xpath queries against it
		$xml->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
	}
	
}