<?php
require_once(dirname(__FILE__)."/Content.php");

class Title extends Content {

	/*
	 * AMFPHP Custom Class mapping
	 */
	var $_explicitType = 'com.clarityenglish.common.vo.content.Title';

	const LICENCE_TYPE_LT = 1;
	const LICENCE_TYPE_AA = 2;
	const LICENCE_TYPE_NETWORK = 3;
	const LICENCE_TYPE_SINGLE = 4;
	const LICENCE_TYPE_I = 5;
	const LICENCE_TYPE_TT = 6;
	const LICENCE_TYPE_CT = 7;
		
	// gh#987
	const FULL_VERSION = 'FV';
	const DEMO_VERSION = 'DEMO';
	
	// gh#1090
	const SIGNIN_TRACKING = 1;
	const SIGNIN_ANONYMOUS = 2;
	// sss#224
	const SIGNIN_BLOCKED = 1;
		
	var $courses = array();
	
	var $productCode;
	
	var $maxStudents;
	var $maxTeachers;
	var $maxReporters;
	var $maxAuthors;
	
	var $expiryDate;
	var $licenceStartDate;
	
	var $languageCode;
	var $productVersion;
	var $startPage;
	var $licenceFile;
	var $contentLocation;
	// v3.5 contentLocation is the place to look for the content. But it is not a direct db field as usually comes from T_ProductLanguage.
	// So I need to maintain a db content location too that is purely for the database field. This is then only field that is ever updated
	// and I only use it for displaying on DMS.
	var $dbContentLocation;
	// v3.3. What am I using this for?
	// v3.3 I don't see we are using this for anything. And if we are it should surely go in T_ProductLanguage
	//var $softwareLocation;
	
	var $licenceType;
	// v3.6.5 Adding licence clearance date
	var $licenceClearanceDate;
	var $licenceClearanceFrequency;
	
	// v3.1 For emus and courses - not used for database storage
	var $indexFile;
	// v3.3 For getting information from T_Product in ContentOps._buildTitle
	var $name;
	// v3.1 For emus to specify other titles that they include - not used for database storage
	var $licencedProductCodes;
	var $deliveryFrequency;
	
	var $checksum;
	
	// gh#1090
	var $loginModifier;
	
	function __construct($existingTitle = null) {
		
		if ($existingTitle) {
			foreach (get_object_vars($existingTitle) as $prop=>$val) {
				$this->$prop = $val;
			}
		}
		
	}
	// m#175 Assume all new titles are/will be Couloir
	public function isTitleCouloir() {
        if ($this->productCode > 62 && $this->productCode < 1000)
            return true;
        return false;
    }
    public function isTitleOrchid() {
        if ($this->productCode < 52 || $this->productCode > 1000)
        	return true;
        return false;
    }

	/**
	 * Get the array of objects that make up a report if a report is generated on this Title
	 */
	function getReportables() {
		return $this->courses;
	}
	
	/**
	 * Return the children (for operations which operate on Content without knowing what kind it is and need to get children)
	 */
	function getChildren() {
		return $this->courses;
	}
	
	/**
	 * Return the id for the purposes of making an IDObject.  Usually this is just the ID, but since Titles actually use their
	 * productCode as an id (and php doesn't implement getter functions) make a method so we can override it in Title.
	 */
	function getIDForIDObject() {
		return (string)$this->productCode;
	}
	
	/**
	 * Returns an array of the ids of the courses within this title
	 */
	function getCourseIDs() {
		$courseIDs = array();
		
		//NetDebug::trace("TITLE: productCode=".$this->productCode.", name=".$this->caption);
		foreach ($this->courses as $course) {
			//NetDebug::trace("TITLE: courseID=".$course->id);
			$courseIDs[] = $course->id;
		}
		
		return $courseIDs;
	}

	// v3.5 Edited Content. You need to search through a title to find an exercise with a UID.
	// And then return the next exercise - or, rather clumsily, the uid of the one before if you are at the end.
	function getNextExercise($uid) {
		$uidArray = explode(".", $uid);
		//$titleID=$uidArray[0];
		$courseID=$uidArray[1];
		//$unitID=$uidArray[2];
		//$exerciseID=$uidArray[3];
		// It might be more efficent to use each rather than foreach
		while (list(, $course) = each($this->courses)) {
			if ($courseID == $course->id) {
				while (list(, $unit) = each($course->units)) {
					while (list(, $exercise) = each($unit->exercises)) {
						if ($exercise->uid == $uid) {							
							// found this uid in the tree, so return the next one
							// remember that each will have already pushed the iterator forward
							// see if we have found it as the last exercise
							if (current($unit->exercises) === false) {
								// we need to back up two items to get the one before the one we moved
								end($unit->exercises);
								prev($unit->exercises);
								// this is really clumsy, but you can't just return the exercise as you won't know that it is a before rather than after one
								// so send back the UID on its own if this is the case
								//NetDebug::trace("getNext, found the uid AFTER in the title tree");
								return prev($unit->exercises)->uid;
							} else {
								//NetDebug::trace("getNext, found the uid BEFORE in the title tree");
								return current($unit->exercises);
							}
						}
					}
				}
			}
		}
		//NetDebug::trace("getNext, didn't find the UID");
		return false;
	}
	function getPrevExercise($uid) {
		$uidArray = explode(".", $uid);
		//$titleID=$uidArray[0];
		$courseID=$uidArray[1];
		//$unitID=$uidArray[2];
		//$exerciseID=$uidArray[3];
		// It might be more efficent to use each rather than foreach
		while (list(, $course) = each($this->courses)) {
			if ($courseID == $course->id) {
				while (list(, $unit) = each($course->units)) {
					while (list(, $exercise) = each($unit->exercises)) {
						if ($exercise->uid == $uid) {							
							// found this uid in the tree, so return the previous one
							// remember that each will have already pushed the iterator forward
							// so lets immediately go back one
							prev($unit->exercises);
							// see if we have found it as the first exercise
							if (prev($unit->exercises) === false) {
								// we need to get the first
								// this is really clumsy, but you can't just return the exercise as you won't know that it is a before rather than after one
								// so send back the UID on its own if this is the case
								//NetDebug::trace("getPrev, found the uid BEFORE in the title tree");
								return first($unit->exercises)->uid;
							} else {
								//NetDebug::trace("getPrev, found the uid AFTER in the title tree");
								return current($unit->exercises);
							}
						}
					}
				}
			}
		}
		return false;
	}
	/*
	 * Take the information out of $obj (generated by AdoDB FetchNextObject()) and set the attributes of this object based on it
	 *
	 * @param obj The object returned for the record by FetchNextObject()
	 */
	public function fromDatabaseObj($obj, $db = null) {
		$this->productCode = $obj->F_ProductCode;
		$this->maxStudents = $obj->F_MaxStudents;
		$this->maxTeachers = $obj->F_MaxTeachers;
		$this->maxReporters = $obj->F_MaxReporters;
		$this->maxAuthors = $obj->F_MaxAuthors;
		
		// Ticket #95 - ignore timezones so return date as an ANSI string
		//$title->expiryDate = $this->db->UnixTimeStamp($titleObj->F_EXPIRYDATE) * 1000;
		// Check the account expiryDate. This is going to be something like 2009-06-30 00:00:000.
		// But we really want to let people use the program all day on the expiry date, so should set the time to the end of the day
		// we know the format of the date coming back from the db, so safe to just chop it to get the date
		$this->expiryDate = substr($obj->F_ExpiryDate,0,10).' 23:59:59';
		
		// AR This might be null - meaning start date is one year ago as it is a perpetual licence
		// Is it better to sort that out here or back in .as?
		// Or maybe best done directly in UsageOps.
		/*$title->licenceStartDate = $titleObj->F_LICENCESTARTDATE;
		if (is_null($title->licenceStartDate)) {
			$aYearAgo = time() - 365.25*24*60*60; // seconds in an average year
			$title->licenceStartDate = date('Y-m-d H:i:s', $aYearAgo);
		}*/
		// Ditto, start date is from the beginning of the day
		$this->licenceStartDate = substr($obj->F_LicenceStartDate,0,10).' 00:00:00';
		$this->languageCode = $obj->F_LanguageCode;
		$this->productVersion = $obj->F_ProductVersion;
		$this->startPage = $obj->F_StartPage;
		$this->licenceFile = $obj->F_LicenceFile;
		//$this->contentLocation = $obj->F_ContentLocation;
		$this->dbContentLocation = $obj->F_ContentLocation;
		$this->licenceType = $obj->F_LicenceType;
		$this->checksum = $obj->F_Checksum;
		$this->deliveryFrequency = $obj->F_DeliveryFrequency;
		// v3.6.5 Licence clearance date		
		if (isset($obj->F_LicenceClearanceDate))
			$this->licenceClearanceDate = substr($obj->F_LicenceClearanceDate, 0, 10).' 00:00:00';
		if (isset($obj->F_LicenceClearanceFrequency))
			$this->licenceClearanceFrequency = $obj->F_LicenceClearanceFrequency;

		// gh#1090
		$this->loginModifier = $obj->F_LoginModifier;
		
		// data that doesn't come from the database, but might have been added to the object before this method called
		if (isset($obj->indexFile)) $this->indexFile = $obj->indexFile;
		if (isset($obj->name)) $this->name = $obj->name;
	}
	
	/**
	 * Convert this object to an associative array ready to pass to AutoExecute.
	 */
	function toAssocArray() {
		$array = array();
		
		$array['F_ProductCode'] = $this->productCode;
		$array['F_MaxStudents'] = $this->maxStudents;
		$array['F_MaxTeachers'] = $this->maxTeachers;
		$array['F_MaxReporters'] = $this->maxReporters;
		$array['F_MaxAuthors'] = $this->maxAuthors;
		// v3.3 Always write the end of the day to the database. And the start.
		$array['F_ExpiryDate'] = substr($this->expiryDate,0,10).' 23:59:59';
		$array['F_LicenceStartDate'] = substr($this->licenceStartDate,0,10).' 00:00:00';
		$array['F_LanguageCode'] = $this->languageCode;
		$array['F_ProductVersion'] = $this->productVersion;
		$array['F_StartPage'] = $this->startPage;
		$array['F_LicenceFile'] = $this->licenceFile;
		// v3.3 We want empty content locations to be saved as null
		//if ($this->contentLocation && !$this->contentLocation=="") {
		if ($this->dbContentLocation && !$this->dbContentLocation=="") {
			$array['F_ContentLocation'] = $this->dbContentLocation;
		}
		// 3.5 Default content location is never saved
		$array['F_LicenceType'] = $this->licenceType;
		$array['F_Checksum'] = $this->checksum;
		$array['F_DeliveryFrequency'] = $this->deliveryFrequency;

		// v3.6 Licence clearance date
		if (isset($this->licenceClearanceDate)) {
			$array['F_LicenceClearanceDate'] = substr($this->licenceClearanceDate, 0, 10).' 00:00:00';
		} else {
			$array['F_LicenceClearanceDate'] = null;
		}
		if (isset($this->licenceClearanceFrequency))
			$array['F_LicenceClearanceFrequency'] = $this->licenceClearanceFrequency;

		// gh#1090
		if (isset($this->loginModifier) && $this->loginModifier > 0) 
			$array['F_LoginModifier'] = $this->loginModifier;
		
		return $array;
	}
	
	//					$db->SQLDate("m/d/Y H:i:s", "$prefix.F_ExpiryDate")." F_ExpiryDate",
	//					$db->SQLDate("m/d/Y H:i:s", "$prefix.F_LicenceStartDate")." F_LicenceStartDate",
	static function getSelectFields($db, $prefix = "a") {
		$fields = array("$prefix.F_RootID",
						"$prefix.F_ProductCode",
						"$prefix.F_ContentLocation",
						"$prefix.F_MaxStudents",
						"$prefix.F_MaxAuthors",
						"$prefix.F_MaxReporters",
						"$prefix.F_MaxTeachers",
						$db->SQLDate("Y-m-d H:i:s", "$prefix.F_ExpiryDate")." F_ExpiryDate",
						$db->SQLDate("Y-m-d H:i:s", "$prefix.F_LicenceStartDate")." F_LicenceStartDate",
						"$prefix.F_LanguageCode",
						"$prefix.F_ProductVersion",
						"$prefix.F_StartPage",
						"$prefix.F_LicenceFile",
						"$prefix.F_LicenceType",
						"$prefix.F_Checksum",
						"$prefix.F_DeliveryFrequency",
						$db->SQLDate("Y-m-d H:i:s", "$prefix.F_LicenceClearanceDate")." F_LicenceClearanceDate",
						"$prefix.F_LicenceClearanceFrequency",
						"$prefix.F_LoginModifier",
						);
		
		return implode(",", $fields);
	}
	
	//static function getReportBuilderOpts($forClass) {
	static function getReportBuilderOpts($forClass, $reportOpts, $template='standard') {
		// These are the fields to include in a report for a title.
		$opts = array();
		
		// Special processing for some templates
		// Test summaries
		if ($template == 'CEFSummary' || strpos($template,'TestSummary')!==false) {
			$opts[ReportBuilder::SHOW_GROUPNAME] = true;
			$opts[ReportBuilder::SHOW_USERNAME] = true;
			$opts[ReportBuilder::SHOW_EXERCISE] = true; // this automatically gives unit name (and course, title)
			$opts[ReportBuilder::SHOW_SCORE_CORRECT] = true;
			$opts[ReportBuilder::SHOW_SCORE_WRONG] = true;
			$opts[ReportBuilder::SHOW_SCORE_MISSED] = true;
			$opts[ReportBuilder::SHOW_DURATION] = true;
			$opts[ReportBuilder::SHOW_STARTDATE] = true;
			
			$opts[ReportBuilder::ORDERBY_USERS] = true;
			$opts[ReportBuilder::ORDERBY_UNIT] = true;
			
		} else if ($template == 'LKHTSummary') {
			$opts[ReportBuilder::SHOW_USERNAME] = true;
			$opts[ReportBuilder::SHOW_EXERCISE] = true; // this automatically gives unit name (and course, title)
			$opts[ReportBuilder::SHOW_SCORE_CORRECT] = true;
			$opts[ReportBuilder::SHOW_SCORE_MISSED] = true;
			$opts[ReportBuilder::SHOW_SCORE_OF] = true; // number of questions
			$opts[ReportBuilder::SHOW_DURATION] = true;
			$opts[ReportBuilder::SHOW_STARTDATE] = true;
			
			$opts[ReportBuilder::ORDERBY_USERS] = true;
			$opts[ReportBuilder::ORDERBY_UNIT] = true;
			
		} else {
			$opts[ReportBuilder::GROUPED] = true;
			
			$opts[ReportBuilder::SHOW_GROUPNAME] = true;
			$opts[ReportBuilder::SHOW_USERNAME] = true;
			
			// for a title report I don't want to show or group by course, so try setting that to false here
			//$opts[ReportBuilder::SHOW_COURSE] = false;
			//$opts[ReportBuilder::SHOW_UNIT] = false;
			//$opts[ReportBuilder::SHOW_EXERCISE] = false;
			//echo "Title.showCourse=".$opts[ReportBuilder::SHOW_COURSE]."         ";
			
			$opts[ReportBuilder::SHOW_AVERAGE_SCORE] = true;
			$opts[ReportBuilder::SHOW_COMPLETE] = true;
			$opts[ReportBuilder::SHOW_AVERAGE_TIME] = true;
			$opts[ReportBuilder::SHOW_TOTAL_TIME] = true;
		}		
		return $opts;
	}
	
}
?>
