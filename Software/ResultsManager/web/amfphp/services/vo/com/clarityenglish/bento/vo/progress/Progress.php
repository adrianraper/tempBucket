<?php

/** 
 * @author Adrian Raper
 * 
 * Class for holding progress information from database and XML
 */
class Progress {

	var $_explicitType = 'com.clarityenglish.bento.vo.progress.Progress';
	
	const PROGRESS_MY_SUMMARY = "progress_my_summary";
	const PROGRESS_EVERYONE_SUMMARY = "progress_everyone_summary";
	const PROGRESS_MY_DETAILS = "progress_my_details";

	public $href;
	public $type;
	public $dataProvider;
	
	function Progress() {
	}
	/*
	 * Take the information out of $obj (generated by AdoDB FetchNextObject()) and set the attributes of this object based on it
	 *
	 * @param obj The object returned for the record by FetchNextObject()
	 */
	function fromDatabaseObj($obj, $db = null) {
	
		// Simple properties from the database
		$this->triggerID = $obj->F_TriggerID;
		$this->name = $obj->F_Name;
		$this->rootID = $obj->F_RootID;
		$this->groupID = $obj->F_GroupID;
		$this->templateID = $obj->F_TemplateID;
		$this->validFromDate = $obj->F_ValidFromDate;
		$this->validToDate = $obj->F_ValidToDate;
		$this->executor = $obj->F_Executor;
		$this->frequency = $obj->F_Frequency;
		$this->messageType = $obj->F_MessageType;
		
		// Property that needs interpreting
		$this->parseCondition($obj->F_Condition);
	}
	
	static function getSelectFields($db, $prefix = "t") {
		$fields = array("$prefix.F_TriggerID",
						"$prefix.F_Name",
						"$prefix.F_RootID",
						"$prefix.F_GroupID",
						"$prefix.F_TemplateID",
						"$prefix.F_Condition",
						"$prefix.F_ValidFromDate",
						"$prefix.F_ValidToDate",
						"$prefix.F_Frequency",
						"$prefix.F_MessageType",
						"$prefix.F_Executor");
		
		return implode(",", $fields);
	}
	
}
?>