<?php
require_once(dirname(__FILE__)."/Content.php");

class Exercise extends Content {

	/*
	 * AMFPHP Custom Class mapping
	 */
	var $_explicitType = 'com.clarityenglish.common.vo.content.Exercise';

	// Not clear if I have to set this if I want to send it back as an exercise attribute
	// It seems not. You can simply add properties to the class as you like. However surely
	// it is clearer to declare it here.
	var $trackableID;
	var $maxScore;
	
	// v3.4.1 Editing Clarity Content. Bug #132. Need to know the filename in case it is not the default;
	var $filename;
	
	/**
	 * Return the children (for operations which operate on Content without knowing what kind it is and need to get children)
	 */
	function getChildren() {
		return array();
	}
	
	//static function getReportBuilderOpts($forClass) {
	static function getReportBuilderOpts($forClass, $reportOpts, $template='standard') {
		// These are the fields to include in a report for an exercise.
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
