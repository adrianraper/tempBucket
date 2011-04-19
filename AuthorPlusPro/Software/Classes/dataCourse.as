import Classes.dataUnit;

class Classes.dataCourse {
	var author:String;
	var edition:String;
	var version:String;
	var id:String;
	var name:String;
	var scaffold:String;
	var subFolder:String;
	var courseFolder:String;
	// v6.4.4, RL: editedCourseFolder is no longer used.
	//var editedCourseFolder:String;
	var program:String;
	//var enabledFlag:String;	// v6.4.1.5, DL
	var enabledFlag:Number;	// v6.4.2.5 AR
	var privacyFlag:Number; // v6.5.5.7 Wei
	var userID:String; // v6.5.5.7 Wei
	var groupID:String; // v6.5.5.7 Wei
	var Units:Array = new Array();
	
	function dataCourse() {
		initAttr();
		
		// v0.16.0, DL: debug - a new course should have a new list of units
		Units = new Array();
	}
	
	private function initAttr() : Void {
		author = _global.NNW.control._username;
		edition = "1.0";
		version = _global.NNW.control.__version;
		id = "";
		// Ar v6.4.2.6 If light, then add a course name right away as it is possible not to write and save it
		if (_global.NNW.control._lite) {
			_global.myTrace("for lite preset name");
			name = "Author Plus Light";
		} else {
			name = "";
		}
		scaffold = "";
		subFolder = "";
		// Ar v6.4.2.6 Don't need added slash any more
		//courseFolder = "Courses\\";
		courseFolder = "Courses";
		//editedCourseFolder = "";
		// AR v6.4.2.5
		//enabledFlag = "3";	// v6.4.1.5, DL
		enabledFlag = _global.NNW.control.enabledFlag.menuOn + _global.NNW.control.enabledFlag.navigateOn;
		privacyFlag = _global.NNW.control.privacyFlag.publicOn;
		program = "AuthorPlus";
		userID = _global.NNW.userID;
		groupID = _global.NNW.groupID;
	}
	
	/* fill in units to this data object */
	function fillInUnits(nodes:Array) : Void {
		Units = new Array();
		var c = 0;
		var i = 0;
		while (i < nodes.length) {
			var attr = nodes[i].attributes;
			var children = nodes[i].childNodes;
			if (attr.caption!=undefined) {
				Units[c] = new dataUnit();
				Units[c].fillInAttributes(attr);
				// AR v6.4.2.5a change the name
				Units[c].fillInExerciseNodes(children);
				c++;
			}
			i++;
		}
	}
	
	/* fill in course attributes */
	function fillInAttributes(attr:Object) : Void {
		for (var i in attr) {
			// AR v6.4.2.5 convert enabledFlag to number
			if (i=="enabledFlag" || i=="privacyFlag") {
				this[i] = Number(attr[i]);
			} else if (typeof this[i] == "string") {
				//v6.4.2.1 If you have escaped attributes, you should unescape here
				this[i] = (attr[i]!=undefined) ? unescape(attr[i]) : this[i];
			}
		}
	}
	
	/* set currentUnit in data to the one indicated by id */
	function setCurrentUnit(id:String) : dataUnit {
		for (var i in Units) {
			if (Units[i].unit == id) {
				return Units[i];
			}
		}
		return Units[Number(id)];
	}
	
	/* rename this course */
	function renameCourse(n:String) : Void {
		_global.myTrace("dataCourse:renameCourse.name=" + n);
		name = (n!=undefined) ? n : "";
	}
	
	/*change the enabledFlag */
	// AR v6.4.2.5 use number for enabledFlag
	//function setEnabledFlag(s:String, v:Boolean) : Void {
	function setEnabledFlag(flag:Number, v:Boolean) : Void {
		if (v) {	
			enabledFlag|=flag;
			_global.myTrace("dataCourse.setEnabledFlag +" + flag +" = "+enabledFlag);
		}
		else {
			//enabledFlag = chr(int(enabledFlag) - int(s));
			enabledFlag &=~flag;
			_global.myTrace("dataCourse.setEnabledFlag -" + flag +" = "+enabledFlag);
		}
	}
	function setPrivacyFlag(flag:Number, v:Boolean) : Void {
		if (v) {	
			privacyFlag|=flag;
			_global.myTrace("dataCourse.setPrivacyFlag +" + flag +" = "+privacyFlag);
		}
		else {
			privacyFlag &=~flag;
			_global.myTrace("dataCourse.setPrivacyFlag -" + flag +" = "+privacyFlag);
		}
	}	
	/* add new unit */
	function addNewUnit() : Void {
		var newUnit:dataUnit = new dataUnit();
		// v0.16.1, DL: use ClarityUniqueID
		//var newID = getMaxUnitID() + 1;
		var newID = _global.NNW.control.time.getCurrentClarityUniqueID();
		newUnit.caption = "";
		// something special for unit to be incremental for coping with some LMSes
		var incID = getMaxUnitID() + 1;
		//newUnit.unit = newID.toString();
		newUnit.unit = incID.toString();
		//newUnit.id = "u"+newUnit.unit;
		newUnit.id = newID.toString();
		Units.push(newUnit);
		setCurrentUnit(newID.toString());
	}
	
	/* get max unit ID */
	function getMaxUnitID() : Number {
		var maxID:Number = 0;
		for (var i in Units) {
			if (Number(Units[i].unit) > maxID) {
				maxID = Number(Units[i].unit);
			}
		}
		return maxID;
	}
	
	/* get new exercise ID */
	function getMaxExerciseID() : Number {
		var maxID:Number = 0;
		for (var i in Units) {
			var e = Units[i].Exercises;
			for (var j in e) {
				if (Number(e[j].id.substr(1)) > maxID) {
					maxID = Number(e[j].id.substr(1));
				}
			}
		}
		return maxID;
	}
	
	/* remove unit with the index */
	function delUnit(index:Number) : Void {
		if (index < Units.length) {
			delete Units[index];
			if (index!=Units.length-1) {
				for (var i=index; i<Units.length-1; i++) {
					Units[i] = Units[i+1];
				}
			}
			Units.pop();
		}
	}
	
	/* swap the 2 units indicated by indexes (positions in array) */
	function swapUnits(i:Number, j:Number) {
		var t1 = Units[i];
		var t2 = Units[j];
		Units[i] = t2;
		Units[j] = t1;
	}
	
	/* move unit up/down by loop-swapping */
	function moveUnit(oldIndex:Number, newIndex:Number)  : Void {
		if (oldIndex>newIndex) {
			for (var i=oldIndex; i>newIndex; i--) {
				swapUnits(i, i-1);
			}
		} else if (oldIndex < newIndex) {
			for (var i=oldIndex; i<newIndex; i++) {
				swapUnits(i, i+1);
			}
		}
	}
	
	/* check if this course has any units */
	function hasUnits() : Boolean {
		return (Units.length>0) ? true : false;
	}
}
