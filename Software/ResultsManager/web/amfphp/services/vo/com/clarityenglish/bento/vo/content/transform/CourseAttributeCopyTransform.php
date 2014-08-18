<?php
require_once(dirname(__FILE__)."/XmlTransform.php");
/**
 * This transform goes through each course listed and gets information about it to be used in course list screen.
 * It is used by Builder and Player.
 */
class CourseAttributeCopyTransform extends XmlTransform {
	
	var $_explicitType = 'com.clarityenglish.bento.vo.content.transform.CourseAttributeCopyTransform';
	
	public function transform($db, $xml, $href, $service) {
		// gh#84 - for each course open the relevant menu.xml, find the course node and merge in any attributes. Since there is only ever
		// a single <course> node in Rotterdam menu.xml files we don't need to search on the @id.
		
		foreach ($xml->courses->course as $course) {
			// gh#324 To avoid occasional 'CDATA not finished' errors, try to ignore complex stuff since we only want the attributes
			$menuXML = simplexml_load_file($href->currentDir."/".$course['href'], null, LIBXML_NOCDATA);
			$menuXML->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
			
			foreach ($menuXML->head->script->menu->course->attributes() as $key => $value) {
				if (!isset($course[$key])) $course->addAttribute($key, $value);
			}
			
			// gh#619 Also get information about this course usage stats from the database
			$courseID = XmlUtils::xml_attribute($course, 'id', 'string');
			//$timesPublished = $service->courseOps->countPublishedSchedules($courseID);
			//$course->addAttribute('timesPublished', $timesPublished);
			
			// timesUsed is an array of 12 session counts.
			$timesUsed = $service->courseOps->countSessions($courseID);
			$course->addChild('timesUsed', $timesUsed);
			
			// gh#954 Some course attributes need processing for the sort to work
			$totalTimesUsed = array_sum(explode(',', $timesUsed));
			$course->addAttribute('totalTimesUsed', $totalTimesUsed);
				
			// Count the number of exercise nodes as a 'size' estimate
			$exercises = $menuXML->xpath("//xmlns:exercise");
			$size = count($exercises);
			$course->addAttribute('size', $size);
				
		}
	}
}