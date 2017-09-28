<?php
class Licence {

	/*
	 * AMFPHP Custom Class mapping
	 */
	var $_explicitType = 'com.clarityenglish.dms.vo.account.Licence';

	// The id for the record in the licence control table
	public $id;
	
	// Whilst most data in this class is picked up from title, it makes it easier to keep it altogether
	public $maxStudents;
	public $licenceClearanceDate;
	public $expiryDate;
	public $licenceStartDate;
	public $licenceClearanceFrequency;
	public $licenceType;
	// gh#1090
	public $signInAs;
	
	public $licenceControlStartDate;
		
	public function Licence($id = null) {
		
		if ($id)
			$this->id = $id;
		
	}
	
	// gh#125 needs to be called from LicenceOps, as least temporarily
	public function findLicenceClearanceDate() {
		// The from date for counting licence use is calculated as follows:
		// If there is no licenceClearanceDate, then use licenceStartDate.
		// If there is no licenceClearanceFrequency, then use +1y
		// Take licenceClearanceDate and add the frequency to it until we get a date in the future.
		// The previous date is our fromDate.
		if (!$this->licenceClearanceDate) 
			$this->licenceClearanceDate = $this->licenceStartDate;
		// Just in case dates have been put in wrongly. 
		// First, if clearance date is in the future, use the start date
        $now = AbstractService::getNow();
		if ($this->licenceClearanceDate > $now->getTimestamp())
			$this->licenceClearanceDate = $this->licenceStartDate;
		// If clearance date is before the start date, it doesn't much matter
		// Turn the string into a timestamp
		$fromDateStamp = strtotime($this->licenceClearanceDate);
		
		// You mustn't have a negative frequency otherwise the loop will be infinite
		if (!$this->licenceClearanceFrequency)
			$this->licenceClearanceFrequency = '1 year';
		if (stristr($this->licenceClearanceFrequency, '-')!==FALSE) 
			$this->licenceClearanceFrequency = str_replace('-', '', $this->licenceClearanceFrequency);
		// Check that the frequency is valid
		if (!strtotime($this->licenceClearanceFrequency, $fromDateStamp) > 0)
			$this->licenceClearanceFrequency = '1 year';
		// Just in case we still have invalid data
		$safetyCount=0;
		while ($safetyCount<99 && strtotime($this->licenceClearanceFrequency, $fromDateStamp) < $now->getTimestamp()) {
			$fromDateStamp = strtotime($this->licenceClearanceFrequency, $fromDateStamp);
			$safetyCount++;
		}
		
		// We want a formatted date
		$this->licenceControlStartDate = date('Y-m-d 00:00:00', $fromDateStamp);
	}

	/**
	 * Grab the relevant bits of information from the title object to save here
	 * @param Title $title
	 */
	public function fromDatabaseObj($title) {
		$this->licenceType = (int)$title->licenceType;
		$this->maxStudents = (int)$title->maxStudents;
		$this->licenceClearanceDate = $title->licenceClearanceDate;
		$this->licenceClearanceFrequency = $title->licenceClearanceFrequency;
		$this->expiryDate = $title->expiryDate;
		$this->licenceStartDate = $title->licenceStartDate;
		$this->findLicenceClearanceDate();
	}

    public function fromDbRecordset($dbObj) {
        $this->licenceType = (int)$dbObj->F_LicenceType;
        $this->maxStudents = (int)$dbObj->F_MaxStudents;
        $this->licenceClearanceDate = $dbObj->F_LicenceClearanceDate;
        $this->licenceClearanceFrequency = $dbObj->F_LicenceClearanceFrequency;
        $this->expiryDate = $dbObj->F_ExpiryDate;
        $this->licenceStartDate = $dbObj->F_LicenceStartDate;
        $this->findLicenceClearanceDate();
    }
    
	// Just in case you got licence from JSON and it became an array instead of a Licence
	public function fromArray($array) {
	    if (isset($array['licenceType']))
            $this->licenceType = $array['licenceType'];
        if (isset($array['maxStudents']))
            $this->maxStudents = $array['maxStudents'];
        if (isset($array['licenceClearanceDate']))
            $this->licenceClearanceDate = $array['licenceClearanceDate'];
        if (isset($array['licenceClearanceFrequency']))
            $this->licenceClearanceFrequency = $array['licenceClearanceFrequency'];
        if (isset($array['expiryDate']))
            $this->expiryDate = $array['expiryDate'];
        if (isset($array['licenceStartDate']))
            $this->licenceStartDate = $array['licenceStartDate'];
        $this->findLicenceClearanceDate();
    }

    /**
     * Utility to help with testing dates and times
     */
    private function getNow() {
        $nowString = (isset($GLOBALS['fake_now'])) ? $GLOBALS['fake_now'] : 'now';
        $now = new DateTime($nowString, new DateTimeZone(TIMEZONE));
        return $now->getTimestamp();
    }
}	
