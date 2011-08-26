<?php

class Trigger {

	// I think this is only for AMFPHP - not needed here
	var $_explicitType = 'com.clarityenglish.dms.vo.trigger.Trigger';
	
	var $triggerID;
	var $name;
	var $rootID;
	var $groupID;
	var $templateID;
	var $condition;
	var $validFromDate;
	var $validToDate;
	var $executor;
	var $frequency;
	var $timeStamp; // used if we want to run the trigger against a date that is not today
	var $messageType;

	function Trigger($timeStamp = null) {
		//echo "build trigger for $timeStamp";
		$this->timeStamp = $timeStamp;
	}
	/*
	 * Parse the condition into an object
	 *
	*/
	function parseCondition($conditionString) {
		//echo "parse condition for $this->timeStamp";
		$this->condition = New Condition($conditionString, $this->timeStamp);
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
	
	/**
	 * Convert this object to an associative array ready to pass to AutoExecute.
	 */
	function toAssocArray() {
		$array = array();
		
		$array['F_TriggerID'] = $this->triggerID;
		$array['F_Name'] = $this->name;
		$array['F_RootID'] = $this->rootID;
		$array['F_GroupID'] = $this->groupID;
		$array['F_TemplateID'] = $this->templateID;
		$array['F_ValidFromDate'] = $this->validFromDate;
		$array['F_ValidToDate'] = $this->validToDate;
		$array['F_Executor'] = $this->executor;
		$array['F_Frequency'] = $this->frequency;
		$array['F_MessageType'] = $this->messageType;

		$array['F_Condition'] = $this->condition->toString();

		return $array;
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
