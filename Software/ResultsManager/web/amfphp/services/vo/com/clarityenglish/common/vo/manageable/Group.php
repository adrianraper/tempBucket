<?php
require_once(dirname(__FILE__)."/Manageable.php");

class Group extends Manageable {

	/*
	 * AMFPHP Custom Class mapping
	 */
	var $_explicitType = 'com.clarityenglish.common.vo.manageable.Group';
	
	var $description;
	
	var $enableMyGroups;
	
	var $manageables = array();

    // gh#1118
    const SELF_REGISTER_GROUP_NAME = ' self registered';

    /*
     * Concatenate the parameter array onto our current array
     * gh#1424 option to add after other manageables not before
     */
	function addManageables($m, $atEnd=false) {
		$this->manageables = ($atEnd) ? array_merge($this->manageables, $m) : array_merge($m, $this->manageables);
	}
	
	/**
	 * Recursively get all the ids of the subgroups below this level.  This is used when deleting manageables.
	 */
	function getSubGroupIds() {
		$subGroupIds = array();
		
		foreach ($this->manageables as $m)
			if (get_class($m) == "Group") {
				$subGroupIds[] = $m->id;
				$subGroupIds = array_merge($subGroupIds, $m->getSubGroupIds());
			}
			
		return $subGroupIds;
	}
	/**
	 * Recursively get all the ids of the parent groups above this level.  This is used when checking edited content
	 */
	function getParentGroupIds() {
		$parentGroupIds = array();
		
		foreach ($this->manageables as $m)
			if (getParent($m) == "Group") {
				$subGroupIds[] = $m->id;
				$subGroupIds = array_merge($subGroupIds, $m->getSubGroupIds());
			}
			
		return $subGroupIds;
	}
	
	/**
	 * Recursively get all the ids of the users below this level. This is used when authenticating manageables.
	 */
	function getSubUserIds() {
		$subUserIds = array();
		
		foreach ($this->manageables as $m)
			$subUserIds = array_merge($m->getSubUserIds(), $subUserIds);

		return $subUserIds;
	}
	/**
	 * Recursively get all the users below this level.  This is used when deleting manageables.
	 */
	function getSubUsers() {
		$subUsers = array();
		
		foreach ($this->manageables as $m)
			$subUsers = array_merge($m->getSubUsers(), $subUsers);
			
		return $subUsers;
	}
	
	/*
	 * Take the information out of $obj (generated by AdoDB FetchNextObject()) and set the attributes of this object based on it
	 *
	 * @param obj The object returned for the record by FetchNextObject()
	 */
	function fromDatabaseObj($obj) {
		// In SQLServer, this comes back as integer. In MySQL it comes back as string.
		// Can I fix this in adodb? I can't see where. Hmmm.
		//NetDebug::trace('group: $obj->F_GroupID.type='.gettype(intval($obj->F_GroupID)));
		//$this->id = $obj->F_GroupID;
		$this->id = intval($obj->F_GroupID);
		//$this->name = $this->apos_decode($obj->F_GroupName);
		$this->name = $obj->F_GroupName;
		$this->description = $obj->F_GroupDescription;
		$this->enableMyGroups = (boolean)$obj->F_EnableMGS;
		// v3.3 OK - whilst the database does have these fields we have never used them.
		$this->custom1 = $obj->F_custom1name;
		$this->custom2 = $obj->F_custom2name;
		$this->custom3 = $obj->F_custom3name;
		$this->custom4 = $obj->F_custom4name;
	}
	
	/**
	 * Convert this object to an associative array ready to pass to AutoExecute
	 *
	 * @param for_update If this array is destined for an update AutoExecute don't include the identity column as this breaks MSSQL
	 */
	function toAssocArray() {
		$array = array();
		
		//$array['F_GroupName'] = $this->apos_encode($this->name);
		$array['F_GroupName'] = $this->name;
		$array['F_GroupDescription'] = ($this->description) ? $this->description : ""; // Not null
		$array['F_EnableMGS'] = (boolean)$this->enableMyGroups;
		$array['F_custom1name'] = ($this->custom1) ? $this->custom1 : ""; // Not null
		$array['F_custom2name'] = ($this->custom2) ? $this->custom2 : ""; // Not null
		$array['F_custom3name'] = ($this->custom3) ? $this->custom3 : ""; // Not null
		$array['F_custom4name'] = ($this->custom4) ? $this->custom4 : ""; // Not null
		
		return $array;
	}
	
	private static function getXMLSerializableFields() {
		return	array("name",
					  "description",
					  "enableMyGroups",
					  "custom1",
					  "custom2",
					  "custom3",
					  "custom4");
	}
	
	static function getSelectFields($db, $prefix = "g") {
		$fields = array("F_GroupParent",
						"F_GroupID",
						"F_GroupName",
						"F_GroupDescription",
						"F_EnableMGS",
						"F_custom1name",
						"F_custom2name",
						"F_custom3name",
						"F_custom4name");
						
		// Add the prefix
		if ($prefix && $prefix != "") 
			for ($n = 0; $n < sizeof($fields); $n++)
				$fields[$n] = $prefix.".".$fields[$n];
		
		return implode(",", $fields);
	}
	
	/**
	 * Serialize this manageable to an xml node
	 */
	function toXMLNode() {
		$dom = new DOMDocument();
		$element = $dom->createElement("group");
		
		foreach ($this->getXMLSerializableFields() as $attribute)
			if (trim($this->$attribute) != "") $element->setAttribute($attribute, $this->$attribute);
		
		foreach ($this->manageables as $m) {
			$node = $dom->importNode($m->toXMLNode(), true);
			$element->appendChild($node);
		}
			
		return $element;
	}
	
	/**
	 * Unserialize a manageable from an xml document and return it
	 */
	static function createFromXML($node) {
		$group = new Group();
		
		foreach (Group::getXMLSerializableFields() as $attribute)
			if ($node->getAttribute($attribute))
				$group->$attribute = $node->getAttribute($attribute);
		
		return $group;
	}
	
	//static function getReportBuilderOpts($forClass) {
	static function getReportBuilderOpts($forClass, $reportOpts, $template='standard') {
		// These are the fields to include in a report for a group.
		$opts = array();
		
		$opts[ReportBuilder::GROUPED] = true;
		$opts[ReportBuilder::SHOW_GROUPNAME] = true; // and I do want to see the group name (at least for multi group reports)
		$opts[ReportBuilder::SHOW_USERNAME] = true;
		$opts[ReportBuilder::SHOW_AVERAGE_SCORE] = true;
		$opts[ReportBuilder::SHOW_COMPLETE] = true;
		$opts[ReportBuilder::SHOW_AVERAGE_TIME] = true;
		$opts[ReportBuilder::SHOW_TOTAL_TIME] = true;
					  
		switch ($forClass) {
			case "Title":
				// At present there isn't really a way to get statistics on more than one title at a time... ask Adrian about this
				// Set title to group differently from course. Except that there isn't really a show_title.
				// show_course will automagically show title (see ReportOps.processRowFields)
				// gh#797
				$opts[ReportBuilder::SHOW_TITLE] = true;
				$opts[ReportBuilder::WITHIN_COURSE] = true;
				//$opts[ReportBuilder::SHOW_COURSE] = true;
				break;
			case "Course":
				$opts[ReportBuilder::SHOW_COURSE] = true;
				// gh#23
				$opts[ReportBuilder::WITHIN_COURSE] = true;
				break;
			case "Unit":
				$opts[ReportBuilder::SHOW_UNIT] = true;
				break;
			case "Exercise":
				$opts[ReportBuilder::SHOW_EXERCISE] = true;
				break;
			// gh#1470
			case "Licence":
				// Override defaults as they are not wanted
				$opts[ReportBuilder::SHOW_USERNAME] = false;
				$opts[ReportBuilder::SHOW_AVERAGE_SCORE] = false;
				$opts[ReportBuilder::SHOW_COMPLETE] = false;
				$opts[ReportBuilder::SHOW_AVERAGE_TIME] = false;
				
				$opts[ReportBuilder::SHOW_LICENCES_USED] = true;
				$opts[ReportBuilder::SHOW_SESSIONS_USED] = true;
				break;
			default:
				throw new Exception("Class not implemented");
		}
		//echo "Group.showCourse=".$opts[ReportBuilder::SHOW_COURSE]."         ";		
		
		return $opts;
	}
	
}
