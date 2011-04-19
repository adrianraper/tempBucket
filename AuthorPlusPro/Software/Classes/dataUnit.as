import Classes.dataExercise;

class Classes.dataUnit {
	
	var picture:String = "";
	var captionPosition:String = "";
	//var x:String = 
	//var y:String = "";
	//var width:String = "";
	//var height:String = "";
	//v6.4.2.4 AR I had made changes to an unchecked out copy and lost them. At least it included enabledFlag change to number.
	// But I don't know what else. Lost on 10/10/2006
	//var enabledFlag:String = "";
	var enabledFlag:Number;	// v6.4.2.5 AR
	var unit:String;
	var caption:String;
	var id:String;
	var Exercises:Array;

	// v6.4.2.2, RL: unit not changed since loaded/saved
	var noChange:Boolean;
	
	// v6.4.2.7 AR Add customised attribute to protect the other settings
	//var customised:Boolean;
	var customised:String;
	
	function dataUnit() {
		picture = "";
		captionPosition = "bc";
		// AR v6.4.2.5
		//enabledFlag = "3";	// v6.4.1.5, DL
		enabledFlag = _global.NNW.control.enabledFlag.menuOn + _global.NNW.control.enabledFlag.navigateOn;	
		unit = "";
		caption = "";
		id = "";
		Exercises = new Array();
		noChange = true; //v6.4.2.2, RL: true when not changed since load/saved of unit. 
		// v6.4.2.7 I can't get the xmlCompare to work when customised is boolean. The dataModel seems to hold a String
		// whears the file correctly holds Boolean. So make it all string.
		//customised = false; //v6.4.2.7
		customised = "false"; //v6.4.2.7
	}
	
	/* fill in exercises to this data object */
	// AR v6.4.2.5a Change the name - these are the exercise nodes in the menu, NOT the actual exercises. 
	// Though the same object will later be used to hold the exercise data too.
	function fillInExerciseNodes(nodes:Array) : Void {
		Exercises = new Array();
		var c = 0;
		var i = 0;
		while (i < nodes.length) {
			var exAttr = nodes[i].attributes;
			if (exAttr.caption!=undefined) {
				Exercises[c] = new dataExercise();
				Exercises[c].fillInAttributes(exAttr);
				c++;
			}
			i++;
		}
	}
	
	/* fill in unit attributes */
	function fillInAttributes(attr:Object) : Void {
		for (var i in attr) {
			if (i=="caption-position") {
				this["captionPosition"] = (attr[i]!=undefined) ? attr[i] : this["captionPosition"];
			// AR v6.4.2.5 convert enabledFlag to number
			} else if (i=="enabledFlag") {
				this["enabledFlag"] = Number(attr[i]);
			// AR v6.4.2.7 convert customised to boolean. Or rather convert all to string. Odd.
			} else if (i=="customised") {
				//if (attr[i] == "true" || attr[i] == true) {
				//	this["customised"] = true;
				//} else {
				//	this["customised"] = false;
				//}
				if (attr[i] == true) {
					this["customised"] = "true";
				} else {
					this["customised"] = "false";
				}
				//_global.myTrace("dataUnit made customised=" + (typeof this.customised));
			} else {
				// v6.4.2.1 If you have escaped attributes, you should unescape too
				//this[i] = (attr[i]!=undefined) ? attr[i] : this[i];
				this[i] = (attr[i]!=undefined) ? unescape(attr[i]) : this[i];
			}
		}
	}
	
	/* set currentUnit in data to the one indicated by id */
	function setCurrentExercise(id:String) : dataExercise {
		for (var i in Exercises) {
			if (Exercises[i].id == id) {
				return Exercises[i];
			}
		}
		return Exercises[Number(id)];
	}
	
	/* rename this unit */
	function renameUnit(n:String) : Void {
		caption = (n!=undefined) ? n : "";
	}

	/* add new exercise */
	function addNewExercise(currentCourse:Object) : dataExercise {
		var newExercise:dataExercise = new dataExercise();
		// v0.16.1, DL: use ClarityUniqueID
		//var newID = (currentCourse.getMaxExerciseID() < 100) ? 100 : currentCourse.getMaxExerciseID() + 1;
		if(_global.NNW._previewMode){
			var startingPointInfo = _global.NNW.control._startingPoint.split(":");
			var startingType = startingPointInfo[0];
			var startingID = startingPointInfo[1];
			_global.myTrace("Add new exercise " + startingID);
			var newID = startingID;
		}else{
			var newID = _global.NNW.control.time.getCurrentClarityUniqueID();
		}
		newExercise.initWithID(newID.toString());
		// v0.5.2, DL: set exercise to be newly created
		newExercise.newlyCreated = true;
		Exercises.push(newExercise);
		return Exercises[Exercises.length-1];
	}
	
	/* remove exercise with the index */
	function delExercise(index:Number) : Void {
		if (index < Exercises.length) {
			delete Exercises[index];
			if (index!=Exercises.length-1) {
				for (var i=index; i<Exercises.length-1; i++) {
					Exercises[i] = Exercises[i+1];
				}
			}
			Exercises.pop();
		}
	}
	
	/* swap the 2 exercises indicated by indexes (positions in array) */
	function swapExercises(i:Number, j:Number) {
		var t1 = Exercises[i];
		var t2 = Exercises[j];
		Exercises[i] = t2;
		Exercises[j] = t1;
	}
	
	/* move exercise up/down by loop-swapping */
	function moveExercise(oldIndex:Number, newIndex:Number)  : Void {
		if (oldIndex>newIndex) {
			for (var i=oldIndex; i>newIndex; i--) {
				swapExercises(i, i-1);
			}
		} else if (oldIndex < newIndex) {
			for (var i=oldIndex; i<newIndex; i++) {
				swapExercises(i, i+1);
			}
		}
	}
	
	/* check if this unit has any exercises */
	function hasExercises() : Boolean {
		return (Exercises.length>0) ? true : false;
	}
	
	/* delete newly created exercise out from this unit */
	function delNewlyCreatedExercises() : Void {
		for (var i=0; i<Exercises.length; i++) {
			if (Exercises[i].newlyCreated) {
				delExercise(i);
			}
		}
	}
	
	/* add the moved exercise (from other units )*/
	function addMovedExercise(ex:dataExercise) : Void {
		Exercises.push(ex);
	}
	
	// AR v6.4.2.5 Change to numbers
	// v6.4.4, RL: this function set the enabledFlag status
	//function setEnabledFlag(s:String, v:Boolean) : Void {
	function setEnabledFlag(flag:Number, v:Boolean) : Void {
		if (v) {	
			enabledFlag|=flag;
			//_global.myTrace("dataUnit.setEnabledFlag +" + flag +" = "+enabledFlag);
		}
		else {
			enabledFlag &=~flag;
			//_global.myTrace("dataUnit.setEnabledFlag -" + flag +" = "+enabledFlag);
		}
	}
}