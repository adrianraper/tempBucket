<?php
class ScheduledTest {
	
	/*
	 * AMFPHP Custom Class mapping
	 */
	var $_explicitType = 'com.clarityenglish.common.vo.tests.ScheduledTest';
	
	var $testId;
	var $productCode;
	var $groupId;
	var $caption;
	var $startType;
	var $startData;
	var $openTime;
	var $closeTime;
	var $language;
	var $showResult;
    // ctp#68
    var $menuFilename;
    // ctp#200
    const DEFAULT_NAME = "menu.json.hbs";
    
    var $status;
    const STATUS_PRERELEASE = 0;
    const STATUS_RELEASED = 1;
    const STATUS_OPEN = 2;
    const STATUS_CLOSED = 3;
    const STATUS_DELETED = 4;

	function ScheduledTest($dbObj = null) {
        if ($dbObj) {
            $this->fromDatabaseObj($dbObj);
        } else {
            // ctp#68 Default, will only be overridden in special cases, like demos or for testing
            $this->menuFilename = ScheduledTest::DEFAULT_NAME;
        }
	}
	
	/*
	 * Take the information out of $obj (generated by AdoDB FetchNextObject()) and set the attributes of this object based on it
	 *
	 * @param obj The object returned for the record by FetchNextObject()
	 */
	function fromDatabaseObj($obj) {
		$this->testId = intval($obj->F_TestID);
		$this->productCode = $obj->F_ProductCode;
		$this->groupId = intval($obj->F_GroupID);
		$this->caption = $obj->F_Caption;
		$this->startType = $obj->F_StartType;
		$this->startData = $obj->F_StartData;
		$this->openTime = $obj->F_OpenTime;
		$this->closeTime = $obj->F_CloseTime;
		$this->language = $obj->F_Language;
		$this->showResult = filter_var($obj->F_ShowResult, FILTER_VALIDATE_BOOLEAN);
        // ctp#68
        $this->menuFilename = (!$obj->F_MenuFilename) ? ScheduledTest::DEFAULT_NAME : $obj->F_MenuFilename;
        $this->status = intval($obj->F_Status);
	}
	
	/**
	 * Convert this object to an associative array ready to pass to AutoExecute
	 *
	 * @param for_update If this array is destined for an update AutoExecute don't include the identity column as this breaks MSSQL
	 */
	function toAssocArray() {
		$array = array();
		
		if ($this->testId)
		    $array['F_TestID'] = $this->testId;
		$array['F_GroupID'] = $this->groupId;
		$array['F_ProductCode'] = $this->productCode;
		$array['F_Caption'] = $this->caption;
		$array['F_StartType'] = $this->startType;
		$array['F_StartData'] = $this->startData;
		$array['F_OpenTime'] = $this->openTime;
		$array['F_CloseTime'] = $this->closeTime;
		$array['F_Language'] = $this->language;
		$array['F_ShowResult'] = intval($this->showResult);
        // ctp#68
        $array['F_MenuFilename'] = ($this->menuFilename == ScheduledTest::DEFAULT_NAME) ? null : $this->menuFilename;
		$array['F_Status'] = $this->status;
        
		return $array;
	}
}
