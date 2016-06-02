<?php
class TestDetailOps {

	var $db;

	function TestDetailOps($db) {
		$this->db = $db;
	}
	function changeDB($db) {
		$this->db = $db;
	}
	
	// Return all tests that this groups is scheduled to take
	// TODO I do know the testId as well, since it is fixed for (this RM?)
	function getTestDetails($groupId) {
		
		$bindingParams = array($groupId);
		
		$sql = <<<SQL
			SELECT * FROM T_TestDetail WHERE F_GroupID=?
SQL;
		$rs = $this->db->Execute($sql, $bindingParams);
		//AbstractService::$debugLog->info("got ". $rs->RecordCount()." records for group " . $group->id);
		switch ($rs->RecordCount()) {
			case 0:
				// There are no records
				return false;
			default:
				$testDetails = array();
				while ($dbObj = $rs->FetchNextObj())
					$testDetails[] = new TestDetail($dbObj);
		}
		return $testDetails;
	}
	
	function addTestDetail($testDetail) {
		$dbObj = $testDetail->toAssocArray();
		$rs = $this->db->AutoExecute("T_TestDetail", $dbObj, "INSERT");
	}
	function updateTestDetail($testDetail) {
		$dbObj = $testDetail->toAssocArray();
		$this->db->AutoExecute("T_TestDetail", $dbObj, "UPDATE", 'F_TestDetailID='.$testDetail->testDetailId);
	}
	function deleteTestDetail($testDetail) {
		$bindingParams = array($testDetail->testDetailId);
		$sql = <<<SQL
			DELETE FROM T_TestDetail WHERE F_TestDetailID=?
SQL;
		$rc = $this->db->Execute($sql, $bindingParams);
	}
}
