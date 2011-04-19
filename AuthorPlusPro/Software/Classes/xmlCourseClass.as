import Classes.xmlFunc;
import mx.xpath.XPathAPI;

class Classes.xmlCourseClass extends Classes.xmlFunc {
	
	var courseAttr:Array;
	
	function xmlCourseClass() {
		courseAttr = new Array( "author",
								"edition",
								"version",
								"id",
								"name",
								"scaffold",
								"subFolder",
								"courseFolder",
								"editedCourseFolder",
								"program",
								"enabledFlag",
								"userID",
								"groupID",
								"privacyFlag");
	}
	
	function loadXML() : Void {
		//v6.4.4 switch the path between MGS and original one
		// v6.4.3 Change name from paths.userPath to paths.content
		//XMLfile = _global.addSlash(_global.NNW.paths.content)+"course.xml";
		//XMLfile = _global.NNW.paths.userPath+"/"+"course.xml";
		//myTrace("(xmlCourseClass) - control._enableMGS = "+control._enableMGS);
		/*
		if (control._enableMGS==true) {
			XMLfile = _global.addSlash(_global.NNW.paths.MGSPath)+"course.xml";
			myTrace("(xmlCourseClass) - reading xml file from path : "+XMLfile);
		} else if (control._enableMGS==false){
			XMLfile = _global.addSlash(_global.NNW.paths.content)+"course.xml";
			myTrace("(xmlCourseClass) - reading xml file from path : "+XMLfile);
		} else {
			onLoadingError();
		}*/
		XMLfile = _global.addSlash(_global.NNW.paths.MGSPath)+"course.xml";
		myTrace("xmlCourse.XMLFile:" + XMLfile);
		super.loadXML("Course");
	}

	// v6.4.3 Add in a function that will use the XML you just loaded from compareClass to replace
	// the course contents. Saves reading the XML again.
	function replaceXML(newXML:XML) : Void {
		this.parseXML(newXML.toString());
		control.readCourseXML();
	}
	function onLoadingSuccess() : Void {
		myTrace("course.onLoadingSuccess");
		var courseListNode = this.firstChild;
		if (courseListNode.nodeName=="courseList" && courseListNode.hasChildNodes()) {
			// course list found, read them
			control.readCourseXML();
			// if the parameter have courseID or startPoint,
			// go to the unit or exercse edit directly. V6.5.5.7 add by WZ
			if( _global.NNW.control._course.length > 0 && _global.NNW.control._isFirstLoadCourse == true){
				// It need related the courseID and the selectNode
				for(var i =0; i < _global.NNW.screens.trees.treeCourse.length; i++ ){
					var lNode = _global.NNW.screens.trees.treeCourse.getItemAt(i);
					if(_global.NNW.control._course == lNode.attributes.id){
						_global.NNW.screens.trees.treeCourse.selectedNode = lNode;
						_global.NNW.control.onDoubleClickingOnTree(_global.NNW.screens.trees.treeCourse.selectedNode);
						_global.NNW.control._isFirstLoadCourse = false;
						break;
					}
				}
			}
		} else {
			// file corrupt or no course, go to onLoadingError
			onLoadingError();
		}
	}
	
	function onLoadingError() : Void {
		myTrace("course.onLoadingError");
		// no course found, save course.xml as new file
		resetDoc();
		
		// v6.4.1.5, DL: DEBUG - no, if we simply add a course in the xml, we'll create a course id for no course!
		/*if (_global.NNW.control._lite) {
			// add one (w/ default values) for lite version
			addDefaultNewCourse();
		}*/
		
		// set initial saving to true (to trigger reading the newly generated file)
		initSave = true;
		// generate course.xml
		control.generateCourseXML();
	}
	
	function onSavingSuccess() : Void {
		myTrace("course.onSavingSuccess");
		if (initSave) {
			// toggle initial saving to false
			initSave = false;
			// course list generated, read them
			control.readCourseXML();
		} else {
			/* update progress bar */
			control.view.setProgressOnPBar(2, 2);
			//_global.myTrace("*** setting 2/2 in xmlCourse");
			/* get data format them into XML */
			//control.addUnitsToXML();
			/* generate the XML file */
			//control.generateUnitXML();
		}
	}
	
	/* add courses to this from Courses array in data object */
	// v6.4.3 This will change to read from data.Courses as an XML object
	// We will use the dataProvider linked to the interface to create the XML, then go through the Courses
	// array to set the parameters of each course (not parent).
	function addCoursesToXML() : Void {
		// v6.4.3. Don't do this as I don't want to add the root node, because it is in the tree already
		// just do the clearing out part
		//resetDoc();
		removeAllNodes();
		
		// First just copy the dataProvider from the interface (am I allowed to?)
		// We already have a root node of courseList (from addRootNode), so just need the children
		// v6.5.4.1 Problem as the tree is not setup for APL
		if (control._lite) {
			// So pick up the new course ID and kind of hardcode the XML node
			var newCourseID = control.data.Courses[0].id;
			//myTrace("1395:got id=" + newCourseID);
			var thisDp = new XML('<courseList><course id="' + newCourseID + '" subFolder="' + newCourseID + '" name="Author Plus Light" scaffold="menu.xml" courseFolder="Courses" enabledFlag="3" privacyFlag="4"/></course></courseList>');
		} else {
			//var thisDp:XMLNode = control.view.screens.trees.getDataProvider("Course").cloneNode(true);
			var thisDp:XML = new XML("<courseList></courseList>");
			var hideCourse:XMLNode = control.hideCourseNodes.cloneNode(true);
			_global.myTrace("hideCourse is " + hideCourse.toString());
			var newCourseXML:XMLNode = control.view.screens.trees.getDataProvider("Course").cloneNode(true);
			
			//thisDp.firstChild = control.view.screens.trees.getDataProvider("Course").cloneNode(true);
			_global.myTrace("newCourseXML is " + newCourseXML.toString());
			for(var i=0; i<newCourseXML.childNodes.length; i++){
				_global.myTrace("i = " + i);
				_global.myTrace("length = " + newCourseXML.childNodes.length);
				var cNode = newCourseXML.childNodes[i].cloneNode(true);
				thisDp.firstChild.appendChild(cNode);
			}
			for(var j=0; j<hideCourse.childNodes.length; j++){
				var hideNode = hideCourse.childNodes[j].cloneNode(true);
				thisDp.firstChild.appendChild(hideNode);
			}
		}
		//this.appendChild(thisDp);
		_global.myTrace("saved course xml is " + thisDp.toString());
		this.appendChild(thisDp.firstChild);
		
		// then go through this XML and add in details from the data model
		getDataFromModel(this.firstChild);
	}
	
	// v6.4.3 Old array version
	// add course to this from an dataCourse object
	function addCourse(obj:Object) : Void {
		var courseNode:XMLNode = this.createElement("course");
		
		// v6.4.1.4, DL: no more static attributes
		for (var i in courseAttr) {
			var v = obj[courseAttr[i]];
			if (v!=undefined && v!="undefined" && v!="") {
				// v6.4.2 Allow apostrophe in course name
				//if (v.indexOf("'",0)>=0){
				//	_global.myTrace("found apostrophe in " + courseAttr[i] + ":" + v);
				//}
				//v = _global.replace(v, "'", " ");
				//v6.4.2.1 Try escaping the name instead of changing characters.
				//v = _global.replace(v, '"', " ");
				//v = _global.replace(v, "<", " ");
				//v = _global.replace(v, ">", " ");
				//v = _global.replace(v, "&", "+");
				//obj[courseAttr[i]] = v;
				//obj[courseAttr[i]] = escape(v);
				//myTrace("course attr = " + obj[courseAttr[i]]);
				//courseNode.attributes[courseAttr[i]] = obj[courseAttr[i]];
				//v6.4.2.1 How about only escaping some attributes?
				switch (courseAttr[i]) {
					case "author":
					case "name":
					//case "subFolder":
					//case "courseFolder":
					//case "editedCourseFolder":
						courseNode.attributes[courseAttr[i]] = escape(v);
						break;
					default:
						courseNode.attributes[courseAttr[i]] = v;
				}
			}
		}
		
		this.firstChild.appendChild(courseNode);
	}
	
	// add root node (courseList node)
	function addRootNode() : Void {
		var rootNode:XMLNode = this.createElement("courseList");
		this.appendChild(rootNode);
	}
	
	/* add a default new course to this */
	function addDefaultNewCourse() : Void {
		// add default new course node
		//var obj = {id:"1", name:"New Course", scaffold:"menu.xml", subFolder:"Course1", courseFolder:"courses\\"};
		//var obj = {id:"1", name:"", scaffold:"menu.xml", subFolder:"Course1", courseFolder:"courses\\"};
		// v0.16.1, DL: use ClarityUniqueID (YYYYMMDDHHMMSSnnn)
		var uniqueID = control.time.getCurrentClarityUniqueID();
		//v6.4.2.1 Don't write ending slash anymore - except have to for RM, so do later
		//var obj = {id:uniqueID, name:"", scaffold:"menu.xml", subFolder:uniqueID, courseFolder:"Courses\\"};
		// v6.4.2.6 Do it now
		var obj = {id:uniqueID, name:"", scaffold:"menu.xml", subFolder:uniqueID, courseFolder:"Courses"};
		addCourse(obj);
	}

	// v6.4.3 Function to read each node in the XML and update it with information from the model
	// Actually, if we stop the course rename from the unit screen, we can assume that the XML will always have
	// updated name information and so go from XML to array with the name.
	// No, don't want to do that. We will assume that the model holds the best name always.
	function getDataFromModel(xmlNode) : Void {
		for (var i in xmlNode.childNodes) {
			var thisNode = xmlNode.childNodes[i];
			if (thisNode.hasChildNodes()) {
				//_global.myTrace("go deeper to =" + thisNode.attributes.name);
				getDataFromModel(thisNode);
			} else {
				//_global.myTrace("updating =" + thisNode.attributes.name);
				var id = thisNode.attributes.id;
				var a = control.data.Courses;
				for (var i in a) {
					var obj = a[i];
					if (obj.id == id) {
						// Then update all the attributes from the model
						for (var j in courseAttr) {
							var v = obj[courseAttr[j]];
							if (v!=undefined && v!="undefined" && v!="") {
								switch (courseAttr[j]) {
									case "author":
									// v6.4.3 See note above about where is the master name
									case "name":
										thisNode.attributes[courseAttr[j]] = escape(v);
										break;
									// v6.4.3 See note above about where is the master name
									//case "name":
									//	v = unescape(thisNode.attributes[courseAttr[j]]);
									//	break;
									default:
										thisNode.attributes[courseAttr[j]] = v;
								}
							}
						}
						break;
					}
				}
			}
		}
	}
}