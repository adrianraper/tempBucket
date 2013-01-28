<?php
require_once(dirname(__FILE__)."/XmlTransform.php");

/**
 * This transform removes any unpublished courses for this user from courses.xml.  It is used by Rotterdam player.
 */
class PublicationCourseTransform extends XmlTransform {
	
	var $_explicitType = 'com.clarityenglish.bento.vo.content.transform.PublicationCourseTransform';
	
	public function transform($db, $xml, $options = array()) {
		// Register the namespace for menu xml so we can run xpath queries against it
		$xml->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
		
		$user = $options['manageableOps']->getUserById($options['userID']);
		
		// Look up the appropriate course settings
		var_dump($user);
	}
	
}