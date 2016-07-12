<?php

/** 
 * @author Adrian Raper
 * 
 * Class for holding progress information from database and XML
 */
class Score {

	var $_explicitType = 'com.clarityenglish.bento.vo.progress.Score';
	
	public $userID;
	public $sessionID;
	public $dateStamp;
	public $productCode;
	public $courseID;
	public $unitID;
	public $exerciseID;
	public $score;
	public $scoreCorrect;
	public $scoreWrong;
	public $scoreMissed;
	public $duration;
	public $uid;

    // gh#1496 Create a standard score from a passed object
	function Score($scoreObj = null, $clientTimezoneOffset = null) {
	    // Set product, course, unit, exercise from the UID
        if (isset($scoreObj['UID']))
            $this->setUID($scoreObj['UID']);

        if (isset($scoreObj['correctCount'])) {
            $this->scoreCorrect = $scoreObj['correctCount'];
        } elseif (isset($scoreObj['scoreCorrect'])) {
            $this->scoreCorrect = $scoreObj['scoreCorrect'];
        }
        if (isset($scoreObj['incorrectCount'])) {
            $this->scoreWrong = $scoreObj['incorrectCount'];
        } elseif (isset($scoreObj['scoreWrong'])) {
            $this->scoreWrong = $scoreObj['scoreWrong'];
        }
        if (isset($scoreObj['missedCount'])) {
            $this->scoreMissed = $scoreObj['missedCount'];
        } elseif (isset($scoreObj['scoreMissed'])) {
            $this->scoreMissed = $scoreObj['scoreMissed'];
        }

        $totalQuestions = $this->scoreCorrect + $this->scoreWrong + $this->scoreMissed;
        if ($totalQuestions > 0) {
            $this->score = intval(100 * $this->scoreCorrect / $totalQuestions);
        } else {
            $this->score = -1;
        }

        // gh#1231 Reasonableness test on durations from the client (upper limit 14400 = 4 hours, 60 seconds is default if actual is -ve)
        $this->duration = ($scoreObj['duration'] > 14400) ? 14400 : ($scoreObj['duration'] < 0) ? 60 : $scoreObj['duration'];

        // gh#156 If we know a timezoneOffset, use server time (UTC) + this to get an accurate local time and ignore the sent time
        // php version differences have big impact on -ve passed integer from amfphp, so split into number and sign
        // How about tablets?
        $serverDateStampNow = new DateTime('now', new DateTimeZone(TIMEZONE));
        if ($clientTimezoneOffset !== null && isset($clientTimezoneOffset['minutes'])) {
            $offset = $clientTimezoneOffset['minutes'];
            $negative = (boolean)$clientTimezoneOffset['negative'];
            $clientDifference = new DateInterval('PT'.strval($offset).'M');
            if ($negative) {
                $dateNow = $serverDateStampNow->add($clientDifference)->format('Y-m-d H:i:s');
            } else {
                $dateNow = $serverDateStampNow->sub($clientDifference)->format('Y-m-d H:i:s');
            }
        } else {
            $dateNow = (isset($scoreObj['dateStamp'])) ? $scoreObj['dateStamp'] : $serverDateStampNow->format('Y-m-d H:i:s');
        }
        $this->dateStamp = $dateNow;
    }
	
	public function setUID($value) {
		$UIDArray = explode('.', $value);
		if (count($UIDArray)>0)
			$this->productCode = $UIDArray[0];
		if (count($UIDArray)>1)
			$this->courseID = $UIDArray[1];
		if (count($UIDArray)>2)
			$this->unitID = $UIDArray[2];
		if (count($UIDArray)>3)
			$this->exerciseID = $UIDArray[3];
		$this->uid = $this->getUID();
	}
	public function getUID() {
		$build = $this->productCode;
		if (isset($this->courseID))
			$build .= '.'.$this->courseID;
		if (isset($this->unitID))
			$build .= '.'.$this->unitID;
		if (isset($this->exerciseID))
			$build .= '.'.$this->exerciseID;
		return $build; 
	}
	/**
	 * Convert this object to an associative array ready to pass to AutoExecute.
	 */
	function toAssocArray() {
		$array = array();
		
		$array['F_UserID'] = $this->userID;
		$array['F_SessionID'] = $this->sessionID;
		$array['F_DateStamp'] = $this->dateStamp;
		$array['F_ProductCode'] = $this->productCode;
		$array['F_CourseID'] = $this->courseID;
		$array['F_UnitID'] = $this->unitID;
		$array['F_ExerciseID'] = $this->exerciseID;
		$array['F_Score'] = $this->score;
		$array['F_ScoreCorrect'] = $this->scoreCorrect;
		$array['F_ScoreWrong'] = $this->scoreWrong;
		$array['F_ScoreMissed'] = $this->scoreMissed;
		$array['F_Duration'] = $this->duration;
		
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
		$this->productCode = $obj->F_ProductCode;
		$this->courseID = $obj->F_CourseID;
		$this->unitID = $obj->F_UnitID;
		$this->exerciseID = $obj->F_ExerciseID;
		$this->score = $obj->F_Score;
		$this->scoreCorrect = $obj->F_ScoreCorrect;
		$this->scoreWrong = $obj->F_ScoreWrong;
		$this->scoreMissed = $obj->F_ScoreMissed;
		$this->duration = $obj->F_Duration;
		
	}
	
	/**
	 * 
	 * Copied from RM, but most likely not used in Bento
	 */
	static function getSelectFields($prefix = "s", $db = null) {
		$fields = array("$prefix.F_UserID",
						"$prefix.F_SessionID",
						"$prefix.F_DateStamp",
						"$prefix.F_ProductCode",
						"$prefix.F_CourseID",
						"$prefix.F_UnitID",
						"$prefix.F_ExerciseID",
						"$prefix.F_Score",
						"$prefix.F_ScoreCorrect",
						"$prefix.F_ScoreWrong",
						"$prefix.F_ScoreMissed",
						"$prefix.F_Duration",
						);
		
		return implode(",", $fields);
	}
	
}