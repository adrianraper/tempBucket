<?php
require_once(dirname(__FILE__)."/Manageable.php");

class User extends Manageable {

	var $_explicitType = 'com.clarityenglish.common.vo.manageable.User';
	
	var $userID;
	var $password;
	var $userType;
	var $studentID;
	var $expiryDate;
	var $email;
	var $birthday;
	var $country;
	var $city;
	// #319 Change fields in the table 
	//var $company;
	var $startDate;
	var $contactMethod;
	// v3.3 New data from special imports
	var $fullName;
	var $custom1;
	var $custom2;
	var $custom3;
	var $custom4;
	// v3.5 For R2IV2
	var $registrationDate;
	var $userProfileOption;
	var $registerMethod;
	
	const USER_TYPE_DMS_VIEWER = -2;
	const USER_TYPE_DMS = -1;
	const USER_TYPE_STUDENT = 0;
	const USER_TYPE_TEACHER = 1;
	const USER_TYPE_ADMINISTRATOR = 2;
	const USER_TYPE_AUTHOR = 3;
	const USER_TYPE_REPORTER = 4;
	
	// gh#281 These should really be in a Config class, if we had one
	const LOGIN_BY_NAME = 1;
	const LOGIN_BY_ID = 2;
	const LOGIN_BY_NAME_AND_ID = 4;
	const LOGIN_BY_ANONYMOUS = 8;
	const LOGIN_BY_EMAIL = 128;
	
	/**
	 * Get all the ids of the users below this level.  This is used when deleting manageables.
	 */
	function getSubUserIds() {
		// v3.4 Multi-group users
		//return array($this->id);
		return array($this->userID);
	}

	/**
	 * Return the user type as a string. Literals????
	*/
	function getTypeName() {
		switch ($this->userType) {
			case User::USER_TYPE_TEACHER:
				return "Teacher";
			case User::USER_TYPE_REPORTER:
				return "Reporter";
			case User::USER_TYPE_AUTHOR:
				return "Author";
			default:
				return "Student";
		}
	}

	/**
	 * Return the id for the purposes of making an IDObject.  Usually this is just the ID, 
	 * but if we want duplicate userIDs in the tree, we need to append the group ID to it.
	 * v3.3 Multi-group users. Can't make this work when I want. Not sure that we are calling setParent for users in groups.
	 * done in _getManageables now.
	 */
	//function getIDForIDObject() {
	//	$parent = $this->getParent();
	//	$parentID = $parent->getIDForIDObject();
	//	return (string)$parentID.'.'.$this->userID;
	//}
	
	/*
	 * Take the information out of $obj (generated by AdoDB FetchNextObject()) and set the attributes of this object based on it
	 *
	 * @param obj The object returned for the record by FetchNextObject()
	 */
	function fromDatabaseObj($obj, $db = null) {
		// We hold userID for multi-user purpose, but simple id as part of reportables
		// userID will get the groupID appended at some point, id won't.
		$this->id = intval($obj->F_UserID);
		$this->userID = intval($obj->F_UserID);
		//$this->name = $this->apos_decode($obj->F_UserName);
		$this->name = $obj->F_UserName;
		$this->email = $obj->F_Email;
		$this->password = $obj->F_Password;
		$this->userType = $obj->F_UserType;
		$this->studentID = $obj->F_StudentID;
		if ($obj->F_ExpiryDate && strtotime($obj->F_ExpiryDate) > 0) $this->expiryDate = $obj->F_ExpiryDate;
		if ($obj->F_Birthday && strtotime($obj->F_Birthday) > 0) $this->birthday = $obj->F_Birthday;
		$this->country = $obj->F_Country;
		// v3.6.2 New field, but always been in the database
		$this->city = $obj->F_City;
		//$this->company = $obj->F_Company;
		// BUG. The database has small c for these fields!
		$this->custom1 = $obj->F_custom1;
		$this->custom2 = $obj->F_custom2;
		$this->custom3 = $obj->F_custom3;
		$this->custom4 = $obj->F_custom4;
		// v3.3 Extra data for special imports
		$this->fullName = $obj->F_FullName;
		$this->contactMethod = $obj->F_ContactMethod;
		if ($obj->F_StartDate && strtotime($obj->F_StartDate) > 0) $this->startDate = $obj->F_StartDate;
		if ($obj->F_RegistrationDate && strtotime($obj->F_RegistrationDate) > 0) $this->registrationDate = $obj->F_RegistrationDate;
		$this->userProfileOption = $obj->F_UserProfileOption;
		$this->registerMethod = $obj->F_RegisterMethod;
	}
	
	/**
	 * Convert this object into an SQL UPDATE statement
	 */
	function toSQLUpdate($userID) {
		$this->setDefaultValues();
		
		$sql = <<<EOD
			UPDATE T_User 
			SET F_UserName=?,F_Email=?,F_Password=?,F_StudentID=?,F_UserType=?,
					F_ExpiryDate=?,F_StartDate=?,F_RegistrationDate=?,F_Birthday=?,
					F_Countryv,F_City=?,
					F_custom1=?,F_custom2=?,F_custom3=?,F_custom4=?,
					F_FullName=?,F_ContactMethod=?,F_UserProfileOption=?,F_RegisterMethod=?
			WHERE F_UserID=$userID
EOD;
		return $sql;
	}
	
	/**
	 * Convert this object into an SQL INSERT statement
	 */
	function toSQLInsert() {
		$this->setDefaultValues();
		
		$sql = <<<EOD
			INSERT INTO T_User (F_UserName,F_Email,F_Password,F_StudentID,F_UserType,
					F_ExpiryDate,F_StartDate,F_RegistrationDate,F_Birthday,
					F_Country,F_City,
					F_custom1,F_custom2,F_custom3,F_custom4,
					F_FullName,F_ContactMethod,F_UserProfileOption,F_RegisterMethod)
			VALUES (?,?,?,?,?, 
					?,?,?,?,
					?,?,
					?,?,?,?,
					?,?,?,?)
EOD;
		return $sql;
	}
	
	function toBindingParams() {
		return array($this->name, $this->email, $this->password, $this->studentID, $this->userType, 
					$this->expiryDate, $this->startDate, $this->registrationDate, $this->birthday,
					$this->country, $this->city,
					$this->custom1, $this->custom2, $this->custom3, $this->custom4, 
					$this->fullName, $this->contactMethod, $this->userProfileOption,
					$this->registerMethod);
	}
	
	/**
	 * Convert this object to an associative array ready to pass to AutoExecute.
	 */
	function toAssocArray() {
		$array = array();
		
		//$array['F_UserName'] = $this->apos_encode($this->name);
		$array['F_UserName'] = $this->name;
		$array['F_Email'] = $this->email;
		$array['F_Password'] = $this->password;
		$array['F_UserType'] = ($this->userType) ? $this->userType : User::USER_TYPE_STUDENT; // Student type USER_TYPE_STUDENT gets encoded as 0 (== null) so set specifically if null
		$array['F_StudentID'] = $this->studentID;
		$array['F_ExpiryDate'] = $this->expiryDate;
		$array['F_StartDate'] = $this->startDate;
		$array['F_RegistrationDate'] = $this->registrationDate;
		$array['F_Birthday'] = $this->birthday;
		$array['F_Country'] = ($this->country) ? $this->country : ""; // Not null
		$array['F_City'] = ($this->city) ? $this->city : ""; // Not null
		//$array['F_Company'] = ($this->company) ? $this->company : ""; // Not null
		$array['F_custom1'] = ($this->custom1) ? $this->custom1 : ""; // Not null
		$array['F_custom2'] = ($this->custom2) ? $this->custom2 : ""; // Not null
		$array['F_custom3'] = ($this->custom3) ? $this->custom3 : ""; // Not null
		$array['F_custom4'] = ($this->custom4) ? $this->custom4 : ""; // Not null
		// v3.3 Extra data for special imports
		$array['F_FullName'] = ($this->fullName);
		$array['F_ContactMethod'] = ($this->contactMethod) ? $this->contactMethod : ""; // Not null
		$array['F_UserProfileOption'] = $this->userProfileOption;
		$array['F_RegisterMethod'] = $this->registerMethod;
		
		return $array;
	}
	
	static function getSelectFields($db, $prefix = "u") {
		$fields = array("$prefix.F_UserID",
						"$prefix.F_UserName",
						"$prefix.F_StudentID",
						"$prefix.F_Email",
						"$prefix.F_Password",
						"$prefix.F_UserType",
						$db->SQLDate("Y-m-d H:i:s", "$prefix.F_ExpiryDate")." F_ExpiryDate",
						$db->SQLDate("Y-m-d H:i:s", "$prefix.F_StartDate")." F_StartDate",
						$db->SQLDate("Y-m-d H:i:s", "$prefix.F_RegistrationDate")." F_RegistrationDate",
						$db->SQLDate("Y-m-d H:i:s", "$prefix.F_Birthday")." F_Birthday",
						"$prefix.F_Country",
						"$prefix.F_City",
						"$prefix.F_custom1",
						"$prefix.F_custom2",
						"$prefix.F_custom3",
						"$prefix.F_custom4",
						"$prefix.F_FullName",
						"$prefix.F_UserProfileOption",
						"$prefix.F_RegisterMethod",
						"$prefix.F_ContactMethod");
						//"$prefix.F_Company",
		
		return implode(",", $fields);
	}
	
	function setDefaultValues() {
		$this->userType = ($this->userType) ? $this->userType : User::USER_TYPE_STUDENT;
		$this->country = ($this->country) ? $this->country : "";
		$this->city = ($this->city) ? $this->city : "";
		$this->custom1 = ($this->custom1) ? $this->custom1 : "";
		$this->custom1 = ($this->custom2) ? $this->custom2 : "";
		$this->custom1 = ($this->custom3) ? $this->custom3 : "";
		$this->custom1 = ($this->custom4) ? $this->custom4 : "";
		$this->contactMethod = ($this->contactMethod) ? $this->contactMethod : "";
		if (!$this->expiryDate || $this->expiryDate=='')
			$this->expiryDate = NULL;
		$this->startDate = ($this->startDate) ? $this->startDate : NULL;
		$this->registrationDate = ($this->registrationDate) ? $this->registrationDate : NULL;
	}
	
	private static function getXMLSerializableFields() {
		return	array("name",
					  "email",
					  "password",
					  "userType",
					  "studentID",
					  "expiryDate",
					  "startDate",
					  "registrationDate",
					  "birthday",
					  "country",
					  "city",
					  "custom1",
					  "custom2",
					  "custom3",
					  "custom4",
					  "fullName",
					  "userProfileOption",
					  "registerMethod",
					  "contactMethod");
					 // "company",
	}
	
	/**
	 * Serialize this manageable to an xml node
	 */
	function toXMLNode() {
		$dom = new DOMDocument();
		$element = $dom->createElement("user");
		
		foreach ($this->getXMLSerializableFields() as $attribute) {
			// AR I want to change date format for XML to Y/m/d
			if (trim($this->$attribute) != "") $element->setAttribute($attribute, $this->serializeAttribute($attribute));
		}
		
		return $element;
	}
	
	private function serializeAttribute($attribute) {
		switch ($attribute) {
			/*case "birthday":
			case "expiryDate":
				return date("d-m-Y", $this->$attribute / 1000);*/
			// The date format will be m/d/Y h:m:s (because this is the standard way of communicating with ActionScript.
			// I want to change it to Y/m/d (no time).
			case "birthday":
			case "startDate":
			case "expiryDate":
			case "registrationDate":
				return date("Y/m/d", strtotime($this->$attribute));
			default:
				return $this->$attribute;
		}
	}
	
	private static function unserializeAttribute($attribute, $value) {
		switch ($attribute) {
			/*case "birthday":
			case "expiryDate":
				$date = explode("-", $value);
				return mktime(0, 0, 0, $date[1], $date[0], $date[2]) * 1000;*/
			// We will, currently, force XML date input format to be Y/m/d. I need to change it to m/d/Y 23:59:59.
			// It would be nice to be able to test for and select a number of formats. At least Y-m-d.
			// No no. If I look at the SQL that adodb.autoExecute creates, it has date as 'YYYY-MM-DD". So lets do that.
			case "birthday":
			case "startDate":
			case "expiryDate":
			case "registrationDate":
				if (strpos($value, "-", 0)>0) {
					$date = explode("-", $value);
				//} elseif (strpos($value, "/", 0)>0) {
				} else {
					$date = explode("/", $value);
				}
				//NetDebug::trace("unserialize date .$value to ".date("m/d/Y G:i:s", mktime(23, 59, 59, $date[1], $date[2], $date[0])));
				//return date("m/d/Y G:i:s", mktime(23, 59, 59, $date[1], $date[2], $date[0]));
				return date("Y-m-d H:i:s", mktime(23, 59, 59, $date[1], $date[2], $date[0]));
			default:
				return $value;
		}
	}
	
	/**
	 * Unserialize a manageable from an xml document and return it
	 */
	static function createFromXML($node) {
		$user = new User();
		
		foreach (User::getXMLSerializableFields() as $attribute)
			if ($node->getAttribute($attribute))
				$user->$attribute = User::unserializeAttribute($attribute, $node->getAttribute($attribute));
		
		return $user;
	}
	
	//static function getReportBuilderOpts($forClass) {
	// v3.2 You can change the reportOpts if you have to
	static function getReportBuilderOpts($forClass, &$reportOpts, $template='standard') {
		// These are the fields to include in a report for a user.  For a user report these are always the same no matter what $forClass is.
		$opts = array();

		// AR Can you have two types of student report - detailed which gives everything
		// === AR start
		//$detailedReport = false;
		if ($reportOpts['detailedReport']) {
			// in which case I need all columns, right?
			$opts[ReportBuilder::SHOW_EXERCISE] = true; // This automatically adds units and courses columns
			$opts[ReportBuilder::SHOW_SCORE] = true;
			$opts[ReportBuilder::SHOW_DURATION] = true;
			$opts[ReportBuilder::SHOW_STARTDATE] = true;
		} else {
		
			switch ($forClass) {
				case "Title":
					// At present there isn't really a way to get statistics on more than one title at a time... ask Adrian about this
					// Set title to group differently from course
					$opts[ReportBuilder::SHOW_COURSE] = true;
					break;
				case "Course":
					$opts[ReportBuilder::SHOW_COURSE] = true;
					//issue:#23
					$opts[ReportBuilder::WITHIN_COURSE] = true;
					break;
				case "Unit":
					$opts[ReportBuilder::SHOW_UNIT] = true; // This automatically adds courses column
					break;
				case "Exercise":
					$opts[ReportBuilder::SHOW_EXERCISE] = true; // This automatically adds units and courses columns
					break;
				default:
					throw new Exception("Class not implemented");
			}

			// or summarised which uses grouped results. 
			$opts[ReportBuilder::GROUPED] = true;
			$opts[ReportBuilder::SHOW_AVERAGE_SCORE] = true;
			$opts[ReportBuilder::SHOW_COMPLETE] = true;
			$opts[ReportBuilder::SHOW_AVERAGE_TIME] = true;
			$opts[ReportBuilder::SHOW_TOTAL_TIME] = true;
			
			// A user report should not show student ID in the table, just in the header no matter what the opts say
			$reportOpts['includeStudentID'] = false;
		}					  
		// === AR end
		return $opts;
	}
	
}
?>
