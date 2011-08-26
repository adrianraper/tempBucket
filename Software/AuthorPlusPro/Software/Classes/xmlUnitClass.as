import Classes.xmlFunc;

class Classes.xmlUnitClass extends Classes.xmlFunc {

	var unitAttr:Array;
	var exAttr:Array;
	
	var nextAction:String;	// v6.4.1.4
	
	function xmlUnitClass() {
		XMLfile = "";
		// AR v6.4.2.5 It would be better to accept all attributes, not to prelist them here.
		unitAttr = new Array("unit", "caption", "id", "picture", "enabledFlag", "customised", "x", "y", "width", "height", "caption-position");
		exAttr = new Array("id", "caption", "fileName", "action", "exerciseID", "enabledFlag");
	}
	
	// v6.4.1.5, DL: DEBUG - to get rid of the infinite loop after importing for serveral times
	function loadXMLAfterLocking() : Void {
		nextAction = "";
		super.loadXMLAfterLocking();
	}
	
	function formURL(courseFolder:String, subFolder:String, filename:String) : Void {
		// v6.4.4, RL: Change the Path into MGS path
		// v6.4.3 Change name from paths.userPath to paths.content
		//XMLfile = _global.NNW.paths.userPath + "/" + courseFolder + "/" + subFolder + "/" + filename;
		//XMLfile = _global.addSlash(_global.NNW.paths.content) + _global.addSlash(courseFolder) + _global.addSlash(subFolder) + filename;
		/*
		myTrace("(xmlUnitClass) - control._enableMGS = "+control._enableMGS);
		if (control._enableMGS) {
			XMLfile = _global.addSlash(_global.NNW.paths.MGSPath) + _global.addSlash(courseFolder) + _global.addSlash(subFolder) + filename;
			myTrace("(xmlUnitClass) - reading xml file from path : "+XMLfile);
		} else {
			XMLfile = _global.addSlash(_global.NNW.paths.content) + _global.addSlash(courseFolder) + _global.addSlash(subFolder) + filename;
			myTrace("(xmlUnitClass) - reading xml file from path : "+XMLfile);
		}	
		*/
		// v6.4.4, re-edited: the MGS path will be the original one if its not in MyGroup
		XMLfile = _global.addSlash(_global.NNW.paths.MGSPath) + _global.addSlash(courseFolder) + _global.addSlash(subFolder) + filename;
		if (_global.NNW.control.__server) {
			XMLfile = _global.replace(XMLfile, "\\", "/");
			XMLfile = _global.replace(XMLfile, "//", "/");
		}
		myTrace("xmlUnit.XMLFile." + XMLfile);
	}

	// AR v6.4.2.5 This doesn't seem to be called from anywhere
	function isEdited() : Boolean {
		// AR v6.4.2.5 use numbers
		/*
		var n:Number = int(control.data.currentExercise.enabledFlag);
		if (n>32) {n-=32};
		if (n>16) {
			return true;
		} else {
			return false;
		}
		*/
		if (_global.NNW.control.data.currentExercise.enabledFlag & _global.NNW.control.enabledFlag.MGS) {
			return true;
		} else {
			return false;
		}
	}

	function loadXML(s:String) : Void {
		//_global.myTrace("DEBUG trace - s in loadXML = "+s);
		//myTrace("xmlUnit: content=" + _global.addSlash(_global.NNW.paths.content) + " s=" + s);
		// v6.4.1.4
		if (s!=undefined && s==="save") {
			nextAction = "save";
		} else {
			nextAction = "";
		}
		
		/*
		//maybe put into the wrong place. leave it alone.
		if (control._enableMGS==true) {
			//control.dataCourse.enabledFlag += 16;
			myTrace("(xmlUnitClass) - now should edit Flag to +16 @1 = "+control.dataCourse.enabledFlag);
		} else if (control._enableMGS==false){
			myTrace("(xmlUnitClass) - no need to edit the Flag in @1 = "+control.dataCourse.enabledFlag);
		}
		*/		
		//_global.myTrace("DEBUG trace - nextAction in loadXML = "+nextAction);
		super.loadXML("Unit");
	}
	
	function onLoadingSuccess() : Void {
		myTrace("menu.xml loaded.");
		// AR v6.4.2.5a correct the names
		var menuListNode = this.firstChild;
		var isExExist = false;
		if (menuListNode.nodeName=="item" && menuListNode.hasChildNodes()) {
			// unit list found, read them
			control.readUnitXML(nextAction);
			// if startingPoint is specified, it will open the unit directly. V6.5.5.7 add by WZ
			if( _global.NNW.control._startingPoint.length > 0 && _global.NNW.control._isFirstLoadEx == true ){
				var startingPointInfo = _global.NNW.control._startingPoint.split(":");
				var startingType = startingPointInfo[0];
				var startingID = startingPointInfo[1];
				if(startingType == "unit" && startingID.length > 0){
					_global.NNW.screens.dgs.setSelectedItem("Unit", startingID - 1);
					_global.NNW.control.onSingleClickingItemOnList(_global.NNW.screens.dgs.dgUnit);
				} else if(startingType == "ex" && startingID.length > 0){
					var lCourse = _global.NNW.control.data.currentCourse;
					for(var i=0; i < lCourse.Units.length; i++){
						var lUnit = lCourse.Units[i];
						for(var j=0; j < lUnit.Exercises.length; j++){
							if(startingID == lUnit.Exercises[j].id){
								isExExist = true;
								_global.NNW.screens.dgs.setSelectedItem("Unit", i);
								_global.NNW.control.onSingleClickingItemOnList(_global.NNW.screens.dgs.dgUnit);
								break;
							}
						}
					}
					if(isExExist){
						_global.NNW.screens.dgs.setSelectedItemByField("Exercise", "id", startingID);
						_global.NNW.control.onDoubleClickingItemOnList(_global.NNW.screens.dgs.dgExercise);
					}else{
						// Start from ResultsManager, do the new exercise click.
						myTrace("Don't get the existing exercsie.");
						if(_global.NNW._previewMode){
							myTrace("Try to add new exercise automatelly, new exercise id is " + startingID);
							_global.NNW.screens.dgs.setSelectedItem("Unit", 1);
							_global.NNW.control.onSingleClickingItemOnList(_global.NNW.screens.dgs.dgUnit);
							//_global.NNW.screens.dgs.setSelectedItemByField("Exercise", "id", startingID);
							_global.NNW.control.addExercise();
						}
					}
				}
				_global.NNW.control._isFirstLoadEx = false;
			}
			//nextAction = "";
		} else {
			// file corrupt or no units, go to onLoadingError
			onLoadingError();
		}
	}
	
	function onLoadingError() : Void {
		_global.myTrace("on loading error in xmlUnitClass, so build a new one");
		// no unit found, add one (w/ default values)
		addDefaultNewUnit();
		// set initial saving to true (to trigger reading the newly generated file)
		initSave = true;
		// generate unit xml file
		control.generateUnitXML("createNewMenuXml");
	}
	
	function onSavingSuccess() : Void {
		myTrace("menu.xml saved.");
		if (initSave) {
			// toggle initial saving to false
			initSave = false;
			// unitlist generated, read them
			control.readUnitXML("");
			
		// v6.4.1, DL: debug - if saving is raised for going back to unit
		// we need to wait until the locking of menu.xml is finished
		// before giving back control to user
		} else if (control.eventAfter=="backUnit") {
			/* update progress bar */
			control.view.setProgressOnPBar(1, 2);
			//_global.myTrace("*** setting 1/2 in xmlUnit");
			
			control.releaseExerciseFileToMenu();
		} else {
			/* update progress bar */
			control.view.setProgressOnPBar(2, 2);
			//_global.myTrace("*** setting 2/2 in xmlUnit");
			
			// v6.4.1.5, DL: DEBUG - to get rid of the infinite loop after importing for serveral times
			nextAction = "";
		}
		control.data.currentUnit.noChange = true;
		// v6.4.2.2, RL: change back nochange into true, cause it's saved now.
	}
	
	/* 3 functions to add units & exercises to this from data object */
	function addUnitsToXML() : Void {
		_global.myTrace("xmlUnit.addUnitsToXML");
		resetDoc();
		var u = control.data.currentCourse.Units;
		for (var i=0; i<u.length; i++) {
			addUnit(u[i]);
			var e = u[i].Exercises;
			//_global.myTrace("no. of exercises in unit #"+i+"="+u[i].Exercises.length);
			for (var j=0; j<e.length; j++) {
				addExercise(this.firstChild.childNodes[i], e[j]);
			}
			
			// v6.4.3 Why change anything to do with the enabled flag here?
			//if (_global.haveComponent(u[i]["enabledFlag"], 16) || _global.haveComponent(u[i]["enabledFlag"], 32)) {
			//	// do nothing for enabledFlag with 16 or 32
			//} else {
			//	u[i]["enabledFlag"] = "3";
			//}
		}
		setInterfaceAttributes();
	}
	/* add unit to this from an dataUnit object */
	function addUnit(obj:Object) : Void {
		var unitNode:XMLNode = this.createElement("item");
		// v6.4.2.8 What happens if I just write out everything in the object?
		//for (var i in unitAttr) {
		//	var thisAttr = unitAttr[i];
		//	var v = obj[thisAttr];
		for (var i in obj) {
			var thisAttr = i;
			var v = obj[i];
			// I certainly don't want anything not a string, number or boolean. And there may be some specific
			// attributes that I know are internal to the program as well
			if (((typeof v == "string") || (typeof v == "number") || (typeof v == "boolean")) 
				&& ((i <> "noChange"))) {
				//_global.myTrace("write out attribute " + thisAttr);
				//v6.4.2.1 Try escaping the name instead of changing characters.
				//v = _global.replace(v, '"', " ");
				// v6.4.2 Allow apostrophe in course name
				//v = _global.replace(v, "'", " ");
				//v = _global.replace(v, "<", " ");
				//v = _global.replace(v, ">", " ");
				// v6.4.2 and allow &
				//v = _global.replace(v, "&", "+");
				//obj[unitAttr[i]] = v;
				//obj[unitAttr[i]] = escape(v);
				//if (unitAttr[i]=="caption-position") {
				if (v=="caption-position") {
					unitNode.attributes[thisAttr] = obj.captionPosition;
				} else if (v!=undefined && v!="undefined" && v!="") {
					//unitNode.attributes[thisAttr] = obj[thisAttr];
					//v6.4.2.1 How about only escaping some attributes?
					switch (thisAttr) {
						case "caption":
						//case "picture":
						//case "fileName":
							unitNode.attributes[thisAttr] = escape(v);
							break;
						default:
							unitNode.attributes[thisAttr] = v;
					}
				}
			}
		}
		this.firstChild.appendChild(unitNode);
	}
	/* add exercise to the unitNode from an dataExercise object */
	function addExercise(unitNode:XMLNode, obj:Object) : Void {
		var exNode:XMLNode = this.createElement("item");
		for (var i in exAttr) {
			var v = obj[exAttr[i]];
			//if (v.indexOf("'",0)>=0){
			//	_global.myTrace("ex:found apostrophe in " + exAttr[i] + ":" + v);
			//}
			//v6.4.2.1 Try escaping the name instead of changing characters.
			//v = _global.replace(v, '"', " ");
			// v6.4.2 Allow apostrophe in exercise name
			//v = _global.replace(v, "'", " ");
			//v = _global.replace(v, "<", " ");
			//v = _global.replace(v, ">", " ");
			// v6.4.2 and allow &
			//v = _global.replace(v, "&", "+");
			//obj[exAttr[i]] = v;
			//obj[exAttr[i]] = escape(v);
			if (v!=undefined && v!="undefined" && v!="") {
				//exNode.attributes[exAttr[i]] = v;
				//v6.4.2.1 How about only escaping some attributes?
				switch (exAttr[i]) {
					case "caption":
					//case "picture":
					//case "fileName": ' too complex when you are exporting as ASP and PHP unescape differently
						exNode.attributes[exAttr[i]] = escape(v);
						break;
					default:
						//_global.myTrace("ex:attr " + exAttr[i] + ":" + v);
						exNode.attributes[exAttr[i]] = v;
				}
			}
		}
		//_global.myTrace("xmlUnit:add ex name=" + exAttr["caption"] + " id=" + exAttr["id"]);
		unitNode.appendChild(exNode);
		/* add static attributes to exercise node */
		exNode.attributes.unit = unitNode.attributes.unit;
		//_global.myTrace("added exNode.enabledFlag="+exNode.attributes.enabledFlag + " for " + exNode.attributes.caption);
	}
	
	/* add root node (with the course name as caption) */
	function addRootNode() : Void {
		var rootNode:XMLNode = this.createElement("item");
		// this is always 0!
		// v6.5.6.6 Can't we put in the courseID here?
		//rootNode.attributes.id = "0";	
		rootNode.attributes.id = control.data.currentCourse.id;	
		//v6.4.2.1 Try escaping the name instead of changing characters.
		rootNode.attributes.caption = escape(control.data.currentCourse.name);
		// v0.16.1, DL: add version no. to menu.xml as well
		rootNode.attributes.version = "6.5.6";	// v0.16.1, DL: version no. of menu.xml is now v6.4
		this.appendChild(rootNode);
	}
	
	/* 3 functions to add a default new unit */
	function addDefaultNewUnitNode() : Void {
		// v0.16.1, DL: use ClarityUniqueID (YYYYMMDDHHMMSSnnn)
		//var obj = {unit:"1", caption:"New Unit", id:"u1"};
		var uniqueID = control.time.getCurrentClarityUniqueID();
		// AR v6.4.2.5 use numbers
		//var obj = {unit:"1", caption:"New Unit", id:uniqueID, enabledFlag:"3"};
		var thisEnabledFlag = _global.NNW.control.enabledFlag.menuOn + _global.NNW.control.enabledFlag.navigateOn;
		// v6.4.2.7 wrong type for customised
		var obj = {unit:"1", caption:"New Unit", id:uniqueID, enabledFlag:thisEnabledFlag, customised:"false"};
		//var obj = {unit:"1", caption:"New Unit", id:uniqueID, enabledFlag:thisEnabledFlag, customised:false};
		addUnit(obj);
	}
	function addDefaultNewExerciseNode() : Void {
		//var obj = {id:"e100", caption:"New Exercise", fileName:"e100.xml", action:"e100", exerciseID:"100"};
		//var obj = {id:"e100", caption:"", fileName:"e100.xml", action:"e100", exerciseID:"100"};
		// v0.16.1, DL: use ClarityUniqueID (YYYYMMDDHHMMSSnnn)
		var uniqueID = control.time.getCurrentClarityUniqueID();
		//var obj = {id:uniqueID, caption:"", fileName:uniqueID+".xml", action:uniqueID, exerciseID:uniqueID, enabledFlag:"3"};
		// AR v6.4.2.5 use numbers
		var thisEnabledFlag = _global.NNW.control.enabledFlag.menuOn + _global.NNW.control.enabledFlag.navigateOn;
		var obj = {id:uniqueID, caption:"", fileName:uniqueID+".xml", action:uniqueID, exerciseID:uniqueID, enabledFlag:thisEnabledFlag};
		addExercise(this.firstChild.firstChild, obj);
	}
	function addDefaultNewUnit() : Void {
		resetDoc();
		// add default new unit node
		// v0.4.3, DL: not add new unit
		//addDefaultNewUnitNode();
		// add default new exercise node
		// v0.3, DL: better not add a default exercise, who knows which type to add anyways?
		//addDefaultNewExerciseNode();
	}
	
	// private functions for setting positions and other static attributes of unit nodes
	private function setInterfaceAttributes() : Void {
		var u = this.firstChild.childNodes;
		var l = u.length;
		for (var i=0; i<l; i++) {
			_global.NNW.interfaces.setNodeAttr(u[i], i, l);
		}
	}
}