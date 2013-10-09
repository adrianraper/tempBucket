<?php
require_once(dirname(__FILE__)."/XmlTransform.php");

/**
 * This transform removes any unpublished courses for this user from courses.xml.  It is used by Rotterdam player.
 */
class CourseAttributeCopyTransform extends XmlTransform {
	
	var $_explicitType = 'com.clarityenglish.bento.vo.content.transform.CourseAttributeCopyTransform';
	
	public function transform($db, $xml, $href, $service) {
		// gh#84 - for each course open the relevant menu.xml, find the course node and merge in any attributes. Since there is only ever
		// a single <course> node in Rotterdam menu.xml files we don't need to search on the @id.
		
		// gh#689 Start with making it easy to remove courses from the iterator. Or use a later filter transform.
		$coursesToRemove = array();
		foreach ($xml->courses->course as $course) {
			// gh#689 A corrupt course should be *marked*deleted*logged* but not stop the rest loading
			try {
				// gh#324 To avoid occasional 'CDATA not finished' errors, try to ignore complex stuff since we only want the attributes
				$menuXML = simplexml_load_file($href->currentDir."/".$course['href'], null, LIBXML_NOCDATA);
				foreach ($menuXML->head->script->menu->course->attributes() as $key => $value) {
					if (!isset($course[$key])) $course->addAttribute($key, $value);
				}
			} catch (Exception $e) {
				// Filter this course so it can't be run, and log it?
				//$course->addAttribute('enabledFlag', 8);
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