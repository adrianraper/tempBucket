<?php
require_once(dirname(__FILE__)."/XmlTransform.php");

class ProgressCourseSummaryTransform extends XmlTransform {
	
	var $_explicitType = 'com.clarityenglish.bento.vo.content.transform.ProgressCourseSummaryTransform';
	
	public function transform($db, $xml, $options = array()) {
		// Now that we have @done and <score> nodes we can calculate summary stats for each course
		$courses = $xml->xpath('/xmlns:bento/xmlns:head/xmlns:script[@id="model"]//xmlns:course');
		foreach ($courses as $course) {
			$course->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
			
			$stats = array("of" => 0, "count" => 0, "totalDone" => 0, "totalScore" => 0, "scoredCount" => 0, "durationCount" => 0, "duration" => 0, "averageScore" => 0, "averageDuration" => 0, "coverage" => 0);
			foreach ($course->xpath('.//xmlns:exercise') as $exercise) {
				$exercise->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
				
				$stats['of'] += 1;
				if ($exercise['done'] > 0) {
					$stats['count'] += 1;
					$stats['totalDone'] += $exercise['done'];
				}
				
				foreach ($exercise->xpath('score') as $score) {
					// #232. #161. Don't let non-marked exercise scores impact the average
					if ($score['score'] >= 0) {
						$stats['totalScore'] += $score['score'];
						$stats['scoredCount'] += 1;
					}
					// #318. 0 duration is for offline exercises (downloading a pdf for instance) so ignore it.
					if ($score['duration'] > 0) {
						$stats['durationCount'] += 1;
						$stats['duration'] += $score['duration'];
					}
				}
				
				if ($stats['scoredCount'] > 0) $stats['averageScore'] = floor($stats['totalScore'] / $stats['scoredCount']);
				if ($stats['durationCount'] > 0) $stats['averageDuration'] = floor($stats['duration'] / $stats['durationCount']);
				if ($stats['of'] > 0) $stats['coverage'] = floor(100 * $stats['count'] / $stats['of']);
			}
			
			// Merge the statistics into the course node
			$this->setAttributes($course, $stats);
		}
	}
	
}