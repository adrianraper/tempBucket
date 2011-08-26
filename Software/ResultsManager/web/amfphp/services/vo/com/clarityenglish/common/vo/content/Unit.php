<?php
require_once(dirname(__FILE__)."/Content.php");

class Unit extends Content {

	/*
	 * AMFPHP Custom Class mapping
	 */
	var $_explicitType = 'com.clarityenglish.common.vo.content.Unit';

	var $exercises = array();
	
	/**
	 * Return the children (for operations which operate on Content without knowing what kind it is and need to get children)
	 */
	function getChildren() {
		return $this->exercises;
	}
	
	//static function getReportBuilderOpts($forClass) {
	static function getReportBuilderOpts($forClass, $reportOpts, $template='standard') {
		// These are the fields to include in a report for a unit.
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
	
	// v3.4 Added to allow Editing of Clarity Content to move exercises from one unit to another.
	public function removeExercise($thisExercise) {
		//$exercises = $this->getChildren();
		$idx=0;
		foreach ($this->exercises as $exercise) {
			if ($exercise-> id == $thisExercise-> id) {
				//echo "found and removed the exercise<br/>";
				array_splice($this->exercises, $idx, 1);
				break;
			}
			$idx++;
		}
		// Do I need to reset or return anything?
	}
	
}
?>
