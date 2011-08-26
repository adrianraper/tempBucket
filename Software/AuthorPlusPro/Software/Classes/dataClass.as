/*
	an instance of this class would be holding all data in NNW
	this class should only communicate with:
		1. control : the controller
*/

import Classes.dataCourse;
//import Classes.control;

class Classes.dataClass {
	
	// current course/unit/exercise id
	var _currentCourseID:String;
	var _currentUnitID:String;
	var _currentExerciseID:String;
	// reference to current course/unit/exercise
	var currentCourse:Object;
	var currentUnit:Object;
	var currentExercise:Object;
	// array for holding all data
	var Courses:Array;
	
	function dataClass() {
		_currentCourseID = "0";
		_currentUnitID = "0";
		_currentExerciseID = "0";
		Courses = new Array();
	}
	
	/* fill in courses to this data object */
	// v6.4.3 This will change for Courses to be an XML object
	//function fillInCourses(nodes:Array) : Void {
	function fillInCourses(node:XML) : Void {
		
		Courses = new Array();
		// v6.4.3 We need to go through copying each node from the XML we have read and 
		// copy the real course nodes into our array. Ignore the hierarchy.
		extractCourseData(node);
		
		/*
		var nodes = node.childNodes;
		var c = 0;
		var i = 0;
		while (i<nodes.length) {
			var attr = nodes[i].attributes;
			if (attr.name != undefined) {
				Courses[c] = new dataCourse();
				Courses[c].fillInAttributes(attr);
				//_global.myTrace("fillInCourses: courseFolder=" + Courses[c].courseFolder);
				c++;
			}
			i++;
		}
		*/
	}
	
	/* set currentCourse to the id specified */
	// v6.4.3 This will change for Courses to be an XML object
	function setCurrentCourse(id:String) : Void {
		var found = false;
		_currentCourseID = id;
		for (var i in Courses){
			if (Courses[i].id == id) {
				currentCourse = Courses[i];
				found = true;
			}
		}
		if (!found) {
			currentCourse = Courses[Number(id)];
		}
		_global.myTrace("setCurrentCourse to " + id + " currentCourse.name=" + currentCourse.name);
	}
	
	/* set currentUnit to the id specified */
	function setCurrentUnit(id:String) : Void {
		_currentUnitID = id;
		currentUnit = currentCourse.setCurrentUnit(id);
	}
	
	/* set currentExercise to the id specified */
	function setCurrentExercise(id:String) : Void {
		_currentExerciseID = id;
		currentExercise = currentUnit.setCurrentExercise(id);
	}
	
	/* set currentCourse by Index */
	// v6.4.3 This will change for Courses to be an XML object
	// This is safe to leave as only called on first entry, at which point you know that the first course in Courses
	// is going to be the first in the interface. Actually I think it is irrelevant as an action can only happen after you click something.
	function setCurrentCourseByIndex(index:Number) {
		currentCourse = Courses[index];
	}
	
	/* get current no of courses */
	// v6.4.3 This will change for Courses to be an XML object
	function getNoOfCourses() : Number {
		return Courses.length;
	}
	
	/* get current no of units */
	function getNoOfUnits() : Number {
		return currentCourse.Units.length;
	}
	
	/* get current no of exercises */
	function getNoOfExercises() : Number {
		return currentUnit.Exercises.length;
	}
	
	/* add new course */
	function addNewCourse() : String {
		var newCourse:dataCourse = new dataCourse();
		// v0.16.1, DL: use ClarityUniqueID
		//var newID = getMaxCourseID() + 1;
		var newID = _global.NNW.control.time.getCurrentClarityUniqueID();
		newCourse.id = newID.toString();
		newCourse.scaffold = "menu.xml"; //"Course"+newID.toString()+".xml";
		newCourse.subFolder = newID.toString();	//newCourse.subFolder = "Course"+newID.toString();
		
		// v6.4.1.4, DL: support for more than 1 Clarity's student programs
		if (_global.NNW.control._editClarity) {
			// v6.4.3 Change the name from paths.userPath to paths.content, as that is what it is!
			//newCourse.editedCourseFolder = _global.NNW.paths.userPath+"/Courses";
			/*if (control._enableMGS==true) {
					newCourse.editedCourseFolder = "/Content/"+_global.addSlash(_global.NNW.paths.MGSPath)+"Course";
					_global.myTrace("(dataClass): "+newCourse.editedCourseFolder);
			} else if (control._enableMGS==false) {
					// v6.4.4, RL: editedCourseFolder is no longer used.
					newCourse.editedCourseFolder = _global.NNW.paths.content+"/Courses";
					_global.myTrace("(dataClass): "+newCourse.editedCourseFolder);
			}*/
			newCourse.program = _global.NNW.interfaces.getInterface();
		}
		
		// v0.16.0, DL: debug - this messes up courses' units and exercises
		//Courses[Courses.length] = newCourse;
		// v6.4.3 This will change for Courses to be an XML object
		Courses.push(newCourse);
		setCurrentCourse(newID.toString());
		// We need to tell the tree what the id is that we have just come up with for this course
		return newCourse.id;
	}
	
	/* get new course ID */
	// v6.4.3 This will change for Courses to be an XML object
	function getMaxCourseID() : Number {
		var maxID:Number = 0;
		for (var i in Courses) {
			if (Number(Courses[i].id) > maxID) {
				maxID = Number(Courses[i].id);
			}
		}
		return maxID;
	}
	
	
	/* delete the index */
	function delCourse(id) : Void {
		var delOK = false;
		var index = Courses.length;
		for (var i=0; i<Courses.length; i++) {
			if (Courses[i].id==id) {
				delOK = true;
				index = i;
			}
		}
		if (delOK && index < Courses.length) {
			delete Courses[index];
			if (index!=Courses.length-1) {
				for (var i=index; i<Courses.length-1; i++) {
					Courses[i] = Courses[i+1];
				}
			}
			Courses.pop();
		}
		// v6.4.3 debug
		//_global.myTrace("data.delCourse.after deleting");
		//for (var i in Courses) {
		//	_global.myTrace("course[" + i + "].id=" + Courses[i].id);
		//}
	}
	// v6.4.3 A bigger function to delete all courses within a folder
	function delCourseFolder(thisNode) : Void {
		// From the interface get this node and find all ids in it. Then delete each in turn
		//_global.myTrace("data.delCorseFolder.find all ids in " + thisNode);
		var listOfIDs = new Array();
		// A recursive function to go through the node
		var getIDsFromNode = function(myNode) {
			for (var i in myNode.childNodes) {
				if (myNode.childNodes[i].hasChildNodes()) {
					getIDsFromNode(myNode.childNodes[i]);
				} else {
					//_global.myTrace("actual course, id=" + myNode.childNodes[i].attributes.id)
					listOfIDs.push(myNode.childNodes[i].attributes.id);
				}
			}
		}
		// trigger it
		getIDsFromNode(thisNode);
		//_global.myTrace("list of ids=" + listOfIDs.toString());
		for (var i in listOfIDs) {
			var id = listOfIDs[i];
			//_global.myTrace("try to delete id=" + id);
			var delOK = false;
			var index = Courses.length;
			for (var i=0; i<Courses.length; i++) {
				if (Courses[i].id==id) {
					delOK = true;
					index = i;
				}
			}
			if (delOK && index < Courses.length) {
				delete Courses[index];
				if (index!=Courses.length-1) {
					for (var i=index; i<Courses.length-1; i++) {
						Courses[i] = Courses[i+1];
					}
				}
				Courses.pop();
			}
		}
		// v6.4.3 debug
		//_global.myTrace("data.delCourse.after deleting");
		//for (var i in Courses) {
		//	_global.myTrace("course[" + i + "].id=" + Courses[i].id);
		//}
	}
	
	
	/* swap the 2 courses indicated by indexes (positions in array) */
	// v6.4.3 This will change for Courses to be an XML object
	function swapCourses(i:Number, j:Number) {
		var t1 = Courses[i];
		var t2 = Courses[j];
		Courses[i] = t2;
		Courses[j] = t1;
	}
	
	/* move course up/down by loop-swapping */
	function moveCourse(oldIndex:Number, newIndex:Number)  : Void {
		if (oldIndex>newIndex) {
			for (var i=oldIndex; i>newIndex; i--) {
				swapCourses(i, i-1);
			}
		} else if (oldIndex < newIndex) {
			for (var i=oldIndex; i<newIndex; i++) {
				swapCourses(i, i+1);
			}
		}
	}
	
	// v6.4.3 Function to extract course data from the XML file into the Courses array
	function extractCourseData(xmlNode):Void {
		//extractData = function(xmlNode) {
			for (var i in xmlNode.childNodes) {
				var thisNode = xmlNode.childNodes[i];
				if (thisNode.hasChildNodes()) {
					//_global.myTrace("extractData ignore=" + thisNode.attributes.name);
					//Courses.push({name:thisNode.attributes.name, id:thisNode.attributes.id, parentID:thisNode.parentNode.attributes.id});
					//extractData(thisNode);
					extractCourseData(thisNode);
				} else {
					var isShow = false;
					var attr = thisNode.attributes;
					// v6.5.6 AR The administrator can see ALL content
					if (_global.NNW.userType == 2) {
						isShow = true;
					}else if( attr.privacyFlag == "1" && attr.userID == _global.NNW.userID ){
						isShow = true;
					}else if( attr.privacyFlag == "2" && attr.groupID == _global.NNW.groupID ){
						isShow = true;
					}else if( attr.privacyFlag == "4" ){
						isShow = true;
					}else{
						isShow = false;
					}
					if (attr.name != undefined && isShow) {
						_global.myTrace("extractData dataCourse=" + thisNode.attributes.name);
						var thisCourse = new dataCourse();
						thisCourse.fillInAttributes(attr);
						Courses.push(thisCourse);
						//_global.myTrace("fillInCourses: courseFolder=" + Courses[c].courseFolder);
					}
				}
			}
		//}
		// start the recursion
		//extractData(xmlNode);
	}
}
