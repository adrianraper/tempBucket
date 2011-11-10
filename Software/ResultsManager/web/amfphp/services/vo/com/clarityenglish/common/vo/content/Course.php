<?php
require_once(dirname(__FILE__)."/Content.php");

class Course extends Content {

	/*
	 * AMFPHP Custom Class mapping
	 */
	var $_explicitType = 'com.clarityenglish.common.vo.content.Course';

	var $units = array();
	var $author;
	
	/*
	 * Properties for CCB course
	 */
	var $contact;
	var $description;
	var $userID;
	var $groupID;
	/**
	 * Get the array of objects that make up a report if a report is generated on this Course
	 */
	function getReportables() {
		return $this->$units;
	}
	
	/**
	 * Return the children (for operations which operate on Content without knowing what kind it is and need to get children)
	 */
	function getChildren() {
		return $this->units;
	}
	
	//static function getReportBuilderOpts($forClass) {
	static function getReportBuilderOpts($forClass, $reportOpts, $template='standard') {
		// These are the fields to include in a report for a course.
		$opts = array();
		
		$opts[ReportBuilder::GROUPED] = true;
		
		$opts[ReportBuilder::SHOW_GROUPNAME] = true;
		$opts[ReportBuilder::SHOW_USERNAME] = true;
		
		$opts[ReportBuilder::SHOW_AVERAGE_SCORE] = true;
		$opts[ReportBuilder::SHOW_COMPLETE] = true;
		$opts[ReportBuilder::SHOW_AVERAGE_TIME] = true;
		$opts[ReportBuilder::SHOW_TOTAL_TIME] = true;
		
		return $opts;
	}
}
?>
