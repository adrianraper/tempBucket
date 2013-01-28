<?php
require_once(dirname(__FILE__)."/XmlTransform.php");

/**
 * This transform removes any unpublished courses for this user from courses.xml.  It is used by Rotterdam player.
 */
class CourseAttributeCopyTransform extends XmlTransform {
	
	var $_explicitType = 'com.clarityenglish.bento.vo.content.transform.CourseAttributeCopyTransform';
	
	public function transform($db, $xml, $options = array()) {
		// GH #84 - for each course open the relevant menu.xml, find the course node and merge in any attributes.  Since there is only ever
		// a single <course> node in Rotterdam menu.xml files we don't need to search on the @id.
		foreach ($xml->courses->course as $course) {
			$menuXML = simplexml_load_file($options['href']->currentDir."/".$course['href']);
			foreach ($menuXML->head->script->menu->course->attributes() as $key => $value) {
				if (!isset($course[$key])) $course->addAttribute($key, $value);
			}
		}
	}
	
}