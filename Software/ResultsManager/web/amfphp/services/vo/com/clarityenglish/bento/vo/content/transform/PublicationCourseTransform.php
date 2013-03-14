<?php
require_once(dirname(__FILE__)."/XmlTransform.php");

/**
 * This transform removes any unpublished courses for this user from courses.xml.  It is used by Rotterdam player.
 */
class PublicationCourseTransform extends XmlTransform {
	
	var $_explicitType = 'com.clarityenglish.bento.vo.content.transform.PublicationCourseTransform';
	
	public function transform($db, $xml, $href, $service) {
		// #154 - only do the transform for students
		$user = $service->manageableOps->getUserById(Session::get('userID'));
		if ($user->userType > User::USER_TYPE_STUDENT) return;
		
		// Register the namespace for menu xml so we can run xpath queries against it
		$xml->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
		
		$coursesToRemove = array();
		foreach ($xml->courses->course as $course)
			if (!$service->courseOps->getCourseStart((string)$course['id']))
				$coursesToRemove[] = $course;
		
		// Remove the unpublished courses from the XML.  Note that SimpleXML doesn't provide an easy way to remove a node,
		// so translate to a DOMElement for this operation.
		foreach ($coursesToRemove as $courseToRemove) {
			$dom = dom_import_simplexml($courseToRemove);
        	$dom->parentNode->removeChild($dom);
		}
	}
	
}