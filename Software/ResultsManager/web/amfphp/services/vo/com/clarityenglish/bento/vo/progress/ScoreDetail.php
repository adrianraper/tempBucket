<?php

/** 
 * @author Adrian Raper
 * 
 * Class for holding progress information from database and XML
 * Orchid used this for holding PPT and LELT details and some other special certificate things
 * Bento has not used this
 * Couloir will use this for CTP to hold test item answer details.
 */
class ScoreDetail {

	var $_explicitType = 'com.clarityenglish.bento.vo.progress.ScoreDetail';
	
	public $userID;
	public $sessionID;
	public $dateStamp;
	public $courseID;
	public $unitID;
	public $exerciseID;
	public $itemID;
    public $detail;
    public $score;
	public $uid;
    public $group;

    // gh#1496 Create a standard score from a passed object
	function ScoreDetail($answerObj = null, $score = null, $clientTimezoneOffset = null) {
	    // Set product, course, unit, exercise from the UID
        if ($score) {
            if (isset($score->uid))
                $this->setUID($score->uid);
            if (isset($score->sessionID))
                $this->sessionID = $score->sessionID;
        }

        if ($answerObj) {
            if (isset($answerObj->id))
                $this->itemID = $answerObj->id;
            if (isset($answerObj->score))
                $this->score = $answerObj->score;
            if (isset($answerObj->group))
                $this->group = $answerObj->group;

            // Merge other answer attributes into a detail json object
            // "{'type':".$answerObj->type.", 'state':".$answerObj->state.", 'tags:'".$answerObj->tags."}"
            $detailString = array();
            $detailString['questionType'] = $answerObj->questionType;
            $detailString['state'] = $answerObj->state;
            $detailString['tags'] = $answerObj->tags;
            $this->detail = json_encode($detailString);
        }

        // ctp#216 Write the time sent by the device for when the answer was selected  - null means not answered
        $this->dateStamp = (isset($answerObj->answerTimestamp)) ? $answerObj->answerTimestamp : null;
    }
	
	public function setUID($value) {
		$UIDArray = explode('.', $value);
		//if (count($UIDArray)>0)
		//	$this->productCode = $UIDArray[0];
		if (count($UIDArray)>1)
			$this->courseID = $UIDArray[1];
		if (count($UIDArray)>2)
			$this->unitID = $UIDArray[2];
		if (count($UIDArray)>3)
			$this->exerciseID = $UIDArray[3];
		$this->uid = $this->getUID();
	}
	public function getUID() {
		//$build = $this->productCode;
        $build = '';
		if (isset($this->courseID))
			$build .= '.'.$this->courseID;
		if (isset($this->unitID))
			$build .= '.'.$this->unitID;
		if (isset($this->exerciseID))
			$build .= '.'.$this->exerciseID;
		return $build; 
	}

    /**
     * Pull out sections of the detail
     */
    public function getTags() {
        $detail = json_decode($this->detail);
        return $detail->tags;
    }
    public function getQuestionType() {
        $detail = json_decode($this->detail);
        return $detail->questionType;
    }
    public function getState() {
        $detail = json_decode($this->detail);
        return $detail->state;
    }

	/**
	 * Convert this object to an associative array ready to pass to AutoExecute.
	 */
	function toAssocArray() {
		$array = array();
		
		$array['F_UserID'] = $this->userID;
		$array['F_SessionID'] = $this->sessionID;
		$array['F_DateStamp'] = $this->dateStamp;
		$array['F_CourseID'] = $this->courseID;
		$array['F_UnitID'] = $this->unitID;
		$array['F_ExerciseID'] = $this->exerciseID;
		$array['F_Score'] = $this->score;
		$array['F_Detail'] = $this->detail;
		$array['F_ItemID'] = $this->itemID;
        $array['F_Group'] = $this->group;

		return $array;
	}
		
	/**
	 * Copied from RM, but most likely not used in Bento
	 * Take the information out of $obj (generated by AdoDB FetchNextObject()) and set the attributes of this object based on it
	 *
	 * @param obj The object returned for the record by FetchNextObject()
	 */
	function fromDatabaseObj($obj, $db = null) {
	
		// Simple properties from the database
		$this->userID = $obj->F_UserID;
		$this->sessionID = $obj->F_SessionID;
		$this->dateStamp = $obj->F_DateStamp;
		$this->courseID = $obj->F_CourseID;
		$this->unitID = $obj->F_UnitID;
		$this->exerciseID = $obj->F_ExerciseID;
		$this->score = $obj->F_Score;
		$this->itemdID = $obj->F_ItemID;
		$this->detail = $obj->F_Detail;
        $this->group = $obj->F_Group;

	}
	
}