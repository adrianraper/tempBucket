<?php
require_once(dirname(__FILE__)."/XmlTransform.php");

/**
 * This transform removes any unpublished/hidden courses for this student from courses.xml. It is used by Rotterdam player.
 * For the builder it also removes anything that is private.
 */
class CourseEnabledTransform extends XmlTransform {
	
	var $_explicitType = 'com.clarityenglish.bento.vo.content.transform.CourseEnabledTransform';
	
	public function transform($db, $xml, $href, $service) {
		
		$coursesToRemove = array();
		foreach ($xml->courses->course as $course) {
			// gh#689 A corrupt course should be *marked*deleted*logged* but not stop the rest loading
			try {
				$menuXML = simplexml_load_file($href->currentDir."/".$course['href'], null, LIBXML_NOCDATA);
				$attributes = $menuXML->head->script->menu->course->attributes();
				if (!isset($attributes['id']))
					throw new Exception('corrupt course');
					
				// gh#91 match the user to the permissions for the course to set an overall enabledFlag
				// gh#882
				$eF = 0;
				$userID = Session::get('userID');
				$userType = Session::get('userType');
				$courseID = XmlUtils::xml_attribute($course, 'id', 'string');
				
				if ($userType == User::USER_TYPE_STUDENT) {
					if ($service->courseOps->getCourseStart($courseID)) {
						$eF = $eF | Course::EF_VIEWER;
					} else {
						$coursesToRemove[] = $course;
					}

				// gh#913
				} elseif ($userType == User::USER_TYPE_ADMINISTRATOR) {
					$eF = $eF | Course::EF_OWNER;
					
				} else {
					// get the highest role for this user on this course
					$role = $service->courseOps->getUserRole($courseID);
					switch ($role) {
						case Course::ROLE_OWNER:
							$eF = $eF | Course::EF_OWNER;
							break;
						case Course::ROLE_COLLABORATOR:
							$eF = $eF | Course::EF_COLLABORATOR;
							break;
						case Course::ROLE_PUBLISHER:
							$eF = $eF | Course::EF_PUBLISHER;
							break;
						case Course::ROLE_VIEWER:
							$eF = $eF | Course::EF_VIEWER;
							break;
					}
				}
				$course->addAttribute('enabledFlag', $eF);
					
			} catch (Exception $e) {
				// Filter this course so it can't be run, and log it?
				$course->addAttribute('enabledFlag', 0);
				AbstractService::$log->crit('failed to load menu.xml from '.$href->currentDir."/".$course['href']);
				$coursesToRemove[] = $course;
			}
		}
		
		// gh#689 Remove the corrupt courses from the XML.
		foreach ($coursesToRemove as $courseToRemove) {
			$dom = dom_import_simplexml($courseToRemove);
        	$dom->parentNode->removeChild($dom);
		}
	}

	
}