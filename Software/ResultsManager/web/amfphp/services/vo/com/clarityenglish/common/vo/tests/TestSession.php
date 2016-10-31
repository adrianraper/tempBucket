<?php
class TestSession {
	
	/*
	 * AMFPHP Custom Class mapping
	 */
	var $_explicitType = 'com.clarityenglish.common.vo.tests.TestSession';

    var $sessionId;
    var $userId;
	var $testId;
    var $rootId;
	var $productCode;
	var $readyDateStamp;
    var $startedDateStamp;
    var $completedDateStamp;
    var $result;
    var $db;
	
	function TestSession($dbObj = null) {
        if ($dbObj)
            $this->fromDatabaseObj($dbObj);
    }


    /*
     * Take the information out of $obj (generated by AdoDB FetchNextObject()) and set the attributes of this object based on it
     *
     * @param obj The object returned for the record by FetchNextObject()
     */
	function fromDatabaseObj($obj) {
        $this->sessionId = intval($obj->F_SessionID);
        $this->userId = intval($obj->F_UserID);
		$this->testId = intval($obj->F_TestID);
		$this->rootId = intval($obj->F_RootID);
        $this->productCode = intval($obj->F_ProductCode);
        if ($obj->F_ReadyDateStamp && strtotime($obj->F_ReadyDateStamp) > 0) $this->readyDateStamp = $obj->F_ReadyDateStamp;
        if ($obj->F_StartedDateStamp && strtotime($obj->F_StartedDateStamp) > 0) $this->startedDateStamp = $obj->F_StartedDateStamp;
        if ($obj->F_CompletedDateStamp && strtotime($obj->F_CompletedDateStamp) > 0) $this->completedDateStamp = $obj->F_CompletedDateStamp;
        $this->result = ($obj->F_Result) ? json_decode($obj->F_Result) : null;
	}
	
	/**
	 * Convert this object to an associative array ready to pass to AutoExecute
	 *
	 * @param for_update If this array is destined for an update AutoExecute don't include the identity column as this breaks MSSQL
	 */
	function toAssocArray() {
		$array = array();
        $array['F_SessionID'] = $this->sessionId;
        $array['F_UserID'] = $this->userId;
	    $array['F_TestID'] = $this->testId;
		$array['F_RootID'] = $this->rootId;
		$array['F_ProductCode'] = $this->productCode;
        $array['F_ReadyDateStamp'] = $this->readyDateStamp;
        $array['F_StartedDateStamp'] = $this->startedDateStamp;
        $array['F_CompletedDateStamp'] = $this->completedDateStamp;
        $array['F_Result'] = ($this->result) ? json_encode($this->result) : null;

		return $array;
	}
}
