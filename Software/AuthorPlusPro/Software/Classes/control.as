/*
	an instance of this class would be the controller of NNW
*/
import mx.utils.Delegate;

import Classes.xmlCourseClass;
import Classes.xmlUnitClass;
import Classes.xmlExerciseClass;
import Classes.dataClass;
import Classes.testCasesClass;
//import Classes.dbConn;	// v6.4.1.4, DL: moved into loginClass
import Classes.actionRun;
import Classes.errorCheckClass;	// v0.6.0, DL: error checking
//import Classes.licenceClass; // v0.7.2, DL: check user's licence	// v6.4.1.4, DL: moved into loginClass
import Classes.timeConvert;	// v0.16.1, DL: local & server time convert
import Classes.xmlCompareClass;	// v6.4.0.1, DL: load & hold the latest xml file from server for comparsion
import Classes.previewClass;	// v6.4.1.2, DL: preview functions (reduce size of control class)
import Classes.sharingClass;	// v6.4.1.3, DL: XML manipulation functions for files sharing (reduce size of control class)
import Classes.uploadClass;		// v6.4.1.4, DL: upload functions (reduce size of control class)
import Classes.loginClass;		// v6.4.1.4, DL: login functions (reduce size of control class)
import Classes.editClarityProgramsClass;	// v6.4.1.4, DL: import Clarity programs for editing

class Classes.control {
	
	// lite version
	var _lite:Boolean;
	// v6.4.2.4 And for using APP with a single product
	var _productRestriction:Boolean;
	
	// version number
	var __version:String;
	
	// local or server
	var __local:Boolean;
	var __server:Boolean;
	
	// v6.4.1.4, DL: edit Clarity's courses
	var _editClarity:Boolean;
	
	// v6.4.4, RL: non-editable courses
	// AR v6.4.2.5 no such thing as a noneditable course
	//var _nonEditable:Boolean;
	
	//v6.4.4, RL: has MGS or not
	var _enableMGS:Boolean;
	
	// test mode
	var _testMode:Boolean;
	
	// security issues
	var _username:String;
	var _password:String;
	var _rootID:Number;
	var _passedCodeCheck:Boolean = false;
	// v6.5.4.6 to stop double login
	var _licenceID:Number;

	var _course:String;
	var _startingPoint:String;
	
	// These two flags are used for course and ex loading judgement.
	// if it is the first time loading the course and ex from direct link, their are true;
	// and then their are set to false, so the "menu" and "back" buttons will work well.
	var _isFirstLoadCourse:Boolean;
	var _isFirstLoadEx:Boolean;

	// v0.15.0, DL: full name & email address
	var _fullname:String;
	var _emailaddress: String;
	
	// constants
	var __maxNoOfCourses:Number = 1;
	var __maxNoOfUnits:Number = 6;
	var __maxNoOfExercises:Number = 5;
	var __maxNoOfQuestions:Number = 10;
	
	// xml & data
	var xmlCourse:xmlCourseClass;
	var xmlUnit:xmlUnitClass;
	var xmlExercise:xmlExerciseClass;
	var data:dataClass;
	
	// error checking
	var errorCheck:errorCheckClass;	// v0.6.0, DL: error checking
	// v0.16.1, DL: local & server time convert
	var time:timeConvert;

	// AR v6.4.2.5 constants
	var enabledFlag = {menuOn:1, navigateOn:2, randomOn:4, disabled:8, MGS:16, nonEditable:32};
	
	// Wei v6.5.5.7 constants
	var privacyFlag = {privateOn:1, groupOn:2, publicOn:4};

	// references
	var view:Object;
	var paths:Object;
	
	// variables
	var showUnitScreenAfterLoad:Boolean=false;
	var delIndex:Number;
	var emailSubject:String;
	var emailBody:String;
	// v6.4.3 Mirror the delIndex, but I am sure there is a better way
	var delNode:XML;
	// v6.4.3 And for course name (goes through compareXML)
	var renameName:String;
	
	// test cases
	var testCases;
	
	// v6.4.1, DL: event after saving actions
	var eventAfter:String;

	// v6.4.1.2, DL: preview class
	var preview:previewClass;
	
	// v6.4.1.2, DL: file type for browsing
	var fileType:String;
	
	// v6.4.1.3, DL: files sharing class
	var sharing:sharingClass;
	
	// v6.4.1.4, DL: uploading class
	var upload:uploadClass;
	// v6.4.1.4, DL: login class
	var login:loginClass;
	// v6.4.1.4, DL: edit Clarity's programs class
	var edit:editClarityProgramsClass;
	
	//v6.4.3 Running with mdmScript 2.0
	var mdm:Object;
	var delayedHolder:Object; // used to handle messy image handling
	var cx; // debugging only
	
	// v6.4.3 For moving items on menus when you need to use compareClass first
	var moveIndexFrom:Number;
	var moveIndexTo:Number;
	
	var displayCourseNodes:XML; // for compare when saving course;
	var hideCourseNodes:XMLNode;
	
	function control() {

		mdm = _global.mdm; // reference to mdm
		delayedHolder = new Object();
		delayedHolder.master = this;
		
		// get lite version setting
		// v6.2.4.6 We don't know this yet (until licence has been read) - so assume it is false
		//_lite = _global.NNW.__lite;
		_lite = false;
		
		// get version number
		var v:Object = _global.NNW.main.version;
		__version = v.major.toString()+"."+v.minor.toString()+"."+v.revision.toString()+"."+v.build.toString();
		
		// get local or server setting
		__local = _global.NNW.__local;
		__server = _global.NNW.__server;
		
		// get test mode setting
		_testMode = _global.NNW.__testMode;
		
		// get username & password
		_username = _global.NNW._username;
		_password = _global.NNW._password;

		// get course id & unit or exercise id
		_course = _global.NNW._course;
		_startingPoint = _global.NNW._startingPoint;
		_isFirstLoadCourse = true;
		_isFirstLoadEx = true;

		// v0.15.0, DL: full name and email of user
		_fullname = "";
		_emailaddress = "";
		
		//v6.4.4 init _enableMGS
		_enableMGS = false;
		
		// set up xml & data
		xmlCourse = new xmlCourseClass();
		xmlUnit = new xmlUnitClass();
		xmlExercise = new xmlExerciseClass();
		data = new dataClass();
		errorCheck = new errorCheckClass();	// v0.6.0, DL: error checking
		// v6.4.1.4, DL: licenceClass moved into loginClass
		//licence = new licenceClass();			// v0.7.2, DL: check user's licence
		time = new timeConvert();				// v0.16.1, DL: local & server time convert
		
		// set up references
		view = _global.NNW.view;
		paths = _global.NNW.paths;
		
		// set up test cases
		testCases = new testCasesClass();
		
		// refer itself to xmlFunc
		xmlCourse.control = this;
		xmlUnit.control = this;
		xmlExercise.control = this;
		
		// variables
		delIndex = -1;
		delNode = undefined;
		
		// v6.4.1, DL: event after saving actions
		eventAfter = "";
		
		// v6.4.1.2, DL: file type for browsing
		fileType = "";
		// v6.4.1.2, DL: preview class
		preview = new previewClass(this);
		
		// v6.4.1.3, DL: sharing class
		sharing = new sharingClass(this);
		
		// v6.4.1.4, DL: uploading class
		upload = new uploadClass(this);
		// v6.4.1.4, DL: login class
		login = new loginClass(this);
		
		// v6.4.1.4, DL: will we edit Clarity's programs?
		// v6.4.2.5 Only do this when you know we need to - it depends on the userSettings too
		/*
		_editClarity = false;
		for (var i in _global.NNW.paths) {
			if (i.indexOf("Location")>0) {
				myTrace("control.edit." + i);
				_editClarity = true;
			}
		}
		myTrace("(control) - _editClarity = "+_editClarity);
		if (_editClarity) {
			edit = new editClarityProgramsClass(this);
		}
		*/
		
		//v6.4.4, RL: init _nonEditable
		//_nonEditable = false;
	}
	
	function myTrace(s:String) : Void {
		_global.myTrace(s);
	}
	
	/* v0.11.0, DL: on logged in, load course.xml and things */
	function onLoggedIn() : Void {
		//myTrace("(control) - onLoggedIn");
		//view.setVisible("btnEmail", true); // v6.5.4.2 Yiu, this code is no needed, Bug ID 1320
		//view.setVisible("btnUpgrade", true);
		// v6.4.1.4, DL: import Clarity's courses if necessary
		_global.myTrace("control.onLoggedIn - userSettings = "+_global.NNW._userSettings);
		_editClarity = false;
		// v6.4.2.5 You have found a program to edit, but is this teacher allowed to?
		// v6.4.2.5 and are we running in MGS as this is the only time you are allowed to edit TB
		// Actually, leave it up to RM to choose whether you can edit TB outside an MGS. Here we will simply check userSettings
		// AR v6.4.2.5 No - too difficult as MGS and teacher details not linked there. So the rule is you can only edit within MGS
		// v6.4.3 At this point we know the user is in an MGS path and is allowed to edit, we don't know about products yet.
		// We have also read the licence, so if the licence is Kit, it means that the single program isn't Author Plus but is actually
		// something else, and this should not be edited without MGS
		if (!errorCheck.passLicenceProductTypeCheck()) {
			// this is an error that should stop you in your tracks
			// doing nothing is probably fine
			// except that we need to unfreeze the screen
			view.hideMask();
		} else {
			// v6.4.3 Move this into here when you know you are moving ahead
			// v6.5.5.7 If Author Plus Pro start from Results Manager, it should not display the first time screen.
			if (getShowFirstTime() || _global.NNW._previewMode) {
				_global.myTrace("preview, so no on first time screen from onCheckLogin");
			} else {
				_global.myTrace("Show first time screen.");
				view.showFirstTimeScreen();
			}
			// v6.4.3 If this is a kit licence, then do not allow editing of anything other than the default course
			// v6.5.0.1 Actually, the last thing we will want is to edit Author Plus with a kit - so we do need to read the other
			// courses that are listed. Then we will pick just the one that matches then branding specified in the licence.
			var productType = _global.NNW.control.login.licence.productType.toLowerCase();
			var branding = _global.NNW.control.login.licence.branding.toLowerCase();
			//if (productType=="kit") {
			//} else {
				if ((_global.NNW._userSettings=="1") && _enableMGS) {
				//if ((_global.NNW._userSettings=="1")) {
					for (var i in _global.NNW.paths) {
						if (i.indexOf("Location")>0) {
							_editClarity = true;
							break;
						}
					}
				}
			//}
			//myTrace("(control) - _editClarity = "+_editClarity);
			//if ( (!_editClarity)||(_global.NNW._userSettings=="0") ) {
			// Am I just editing one product, or many?
			// v6.5.0.1 But to pick up the correct paths, we do need to read any location files, even for kit
			// we'll then to this bit later
			if (!_editClarity) {
			/*
			if (productType.toLowerCase()=="kit") {
				_global.myTrace("load editing kit");
				// v6.4.3 So we are only loading the default product (Author Plus). But what about branding if this isn't Author Plus?
				// v6.5.0.1 Including Clarity programs. Note that code for this is embedded in screen.swf:scnCourse
				if (branding.toLowerCase().indexOf("nas/myc")>=0) {
					var kitTitle = "MyCanada_mc";
					var kitProgram = "MyCanada";
				} else if (branding.toLowerCase().indexOf("nas/ldt")>=0) {
					var kitTitle = "Lamour_mc"; 
					var kitProgram = "Lamour";
				} else if (branding.toLowerCase().indexOf("clarity/tb")>=0) {
					var kitTitle = "TenseBuster_mc"; 
					var kitProgram = "TenseBuster";
				} else if (branding.toLowerCase().indexOf("clarity/sss")>=0) {
					var kitTitle = "StudySkillsSuccess_mc"; 
					var kitProgram = "StudySkillsSuccess";
				} else if (branding.toLowerCase().indexOf("clarity/ro")>=0) {
					var kitTitle = "Reactions_mc"; 
					var kitProgram = "Reactions";
				} else if (branding.toLowerCase().indexOf("clarity/bw")>=0) {
					var kitTitle = "BusinessWriting_mc"; 
					var kitProgram = "BusinessWriting";
				}
				var y = 150;
				view.screens.scnCourse[kitTitle]._visible = true;
				view.screens.scnCourse[kitTitle]._y = y;
				_global.NNW.interfaces.setInterface(kitProgram);
				view.screens.scnCourse.showProgramSelection(kitTitle);
				// Once it is displayed, we don't want to do anything when you click it.
				// and it shouldn/t have a fat finger...
				view.screens.scnCourse[kitTitle].onRelease = undefined;
			*/
				xmlCourse.loadXML();
			} else {
				// v6.4.2.5 If I am going to edit other programs, save the default (Author Plus) details in the paths Array
				// This is done in the class
				//_global.myTrace("save " + _global.NNW.paths.userApp + " paths");
				//_global.NNW.paths[_global.NNW.paths.userApp+"Content"] = _global.NNW.paths.content;
				//_global.NNW.paths[_global.NNW.paths.userApp+"MGSPath"] = _global.NNW.paths.MGSPath;
				//_global.NNW.paths[_global.NNW.paths.userApp+"Location"] = _global.NNW.paths.userDataPath;
				edit = new editClarityProgramsClass(this);
				edit.getPaths();
				_global.myTrace("load with other Clarity Programs");
			}
		}
	}
	
	/* v0.11.0, DL: set to show first time screen */
	function setShowFirstTime(dontShow:Boolean) : Void {
		var notFound = true;
		var o:SharedObject = SharedObject.getLocal("NNW");
		if (o.data.notFirstTime==undefined) {
			o.data.notFirstTime = new Array();
		}
		var a = o.data.notFirstTime;
		if (a.length>0) {
			for (var i in a) {
				if (a[i]==_username) {
					notFound = false;
					if (!dontShow) {
						a.splice(i, 0);
					}
				}
				break;
			}
		}
		if (notFound && dontShow) {
			o.data.notFirstTime.push(_username);
		}
		o.flush(1000);
	}
	
	/* v0.11.0, DL: get show first time screen setting */
	function getShowFirstTime() : Boolean {
		var showFirstTime = true;
		var o:SharedObject = SharedObject.getLocal("NNW");
		var a = o.data.notFirstTime;
		if (a.length>0) {
			for (var i in a) {
				if (a[i]==_username) {
					showFirstTime = false;
				}
				break;
			}
		}
		return showFirstTime;
	}
	
	// v6.4.0.1, DL: load unit xml file
	function loadUnitXML() : Void {
		//myTrace("control:loadUnitXML: courseFolder=" + data.currentCourse.courseFolder);
		xmlUnit.formURL(data.currentCourse.courseFolder, data.currentCourse.subFolder, data.currentCourse.scaffold);
		xmlUnit.loadXML("");
		//v6.4.4,RL: set the course.xml enabledFlag into edited
		/*
		if (_enableMGS==true) {
			setCourseEnabledFlag("16", true);
		}
		*/
	}
	
	// read course.xml and fill in courses into data and list on UI
	function readCourseXML() : Void {
		// v6.4.3 Just send the whole course xml object to the model
		//var nodes = xmlCourse.firstChild.childNodes;
		//  - drop the courseList node
		// v6.4.3 Unescape first - this will never be so very big so just do it via a string
		var nodes = new XML(unescape(xmlCourse.toString())).firstChild;
		//originalCourseNodes = nodes.cloneNode(true); // for compare when saving course.
		displayCourseNodes = new XML();
		hideCourseNodes = new XML();
		for( var i=0; i < nodes.childNodes.length; i++){
			//var isDelete = true;
			var childNode = nodes.childNodes[i];
			var attr = childNode.attributes;
			// import the old exercise xml
			if( attr.privacyFlag == null ){
				myTrace("Add default privacy");
				attr.privacyFlag = "4";
				attr.userID = _global.NNW.userID;
				attr.groupID = _global.NNW.groupID;
			}
			// v6.5.6 AR The administrator can see ALL content
			if (_global.NNW.userType == 2) {
				displayCourseNodes.appendChild(childNode.cloneNode(true));
			}else if( attr.privacyFlag == "1" && attr.userID == _global.NNW.userID ){
				displayCourseNodes.appendChild(childNode.cloneNode(true));
				//isDelete = false;
			}else if( attr.privacyFlag == "2" && attr.groupID == _global.NNW.groupID ){
				displayCourseNodes.appendChild(childNode.cloneNode(true));
				//isDelete = false;
			}else if( attr.privacyFlag == "4" ){
				displayCourseNodes.appendChild(childNode.cloneNode(true));
				//isDelete = false;
			}else{
				hideCourseNodes.appendChild(childNode.cloneNode(true));
				//isDelete = true;
			}
			
			//if(isDelete){
			//	var hideNode = childNode.cloneNode(true);
			//	hideCourseNodes.appendChild(hideNode);
			//	myTrace("hideCourseNodes=" + hideCourseNodes.toString());
			//	childNode.removeNode();
			//}
		}
		myTrace("hide nodes=" + hideCourseNodes.toString());
		myTrace("control.readCourseXML.nodes=" + displayCourseNodes.toString());
		data.fillInCourses(displayCourseNodes);
		// v6.4.3 And send it to the interface since that will use the XML not the array
		//view.fillInCourseList(data.Courses);
		view.fillInCourseList(displayCourseNodes);
	}
	
	// read unit xml file and fill in units into data and list on UI
	function readUnitXML(nextAction:String) : Void {
		//_global.myTrace("control.readUnitXML.nextAction="+nextAction);
		
		var nodes = xmlUnit.firstChild.childNodes;
		data.currentCourse.fillInUnits(nodes);
		if (showUnitScreenAfterLoad) {
			view.fillInUnitList(data.currentCourse.Units);
			// v6.4.1.5, DL: show the enabled flag status for the course on the screen
			//_global.myTrace("control.readUnitXML.currentCourse.enabledFlag=" + data.currentCourse.enabledFlag);
			view.fillInCourseEnabled(data.currentCourse.enabledFlag);
			view.screens.setCoursePrivacy(data.currentCourse.privacyFlag);
		}
		
		if (nextAction!=undefined && nextAction==="save") {
			saveUnit("");
		}
		
		/* just for tracing purpose */
		/*for (var i = 0; i<data.currentCourse.Units.length; i++) {
			trace(data.currentCourse.Units[i].caption);
		}*/
	}
	
	// read exercise xml file and fill into data
	function readExerciseXML() : Void {
		//myTrace("control.readExerciseXML - now going to read the XML");
		data.currentExercise.fillInDetails(xmlExercise.firstChild);
		view.fillInExerciseDetails(data.currentExercise);
		//v6.4.4, RL: when open the exercise in MGS, change the enabledFlag.			
		/* can cause problems to orginal menu.xml, so try do it when saving exercise.
		if (_enableMGS) {
			data.currentExercise.setEnabledFlag("16", true);
			//saveUnit("showExercise");			
		}
		*/
	}
	
	// v0.16.1, DL: lock file before loading
	function lockFile(t:String) : Void {
		myTrace("control.lockFile." + t);
		var action = new actionRun();
		switch (t) {
		case "Course" :
			action.lockCoursesFile(xmlCourse.XMLfile);
			break;
		case "Unit" :
			action.lockMenuFile(xmlUnit.XMLfile);
			break;
		case "Exercise" :
			// AR v6.4.2.5 If you are running in MGS and open an exercise from the original, you will end up saving it 
			// in the MGS path anyway. So don't lock the original. Since the new one can't exist, not much point locking that either.
			// Actually, I would lock it if I could find the name, but doesn't see easy to do.
			// v6.4.3 Also, you may be opening an existing and well used one within the MGS, so you should lock it
			if (_enableMGS) {
				_global.myTrace("reading ex from MGS, eF=" + _global.NNW.control.data.currentExercise.enabledFlag + ", file=" + xmlExercise.XMLfile);
				// So, you are working in an MGS, but is this exercise coming from the original or the MGS?
				if (_global.NNW.control.data.currentExercise.enabledFlag & _global.NNW.control.enabledFlag.MGS) {
					action.lockExerciseFile(xmlExercise.XMLfile);
				} else {
					// just pretend that you have
					xmlExercise.loadXMLAfterLocking();
				}
			} else {
				action.lockExerciseFile(xmlExercise.XMLfile);
			}
			break;
		case "SaveExercise" :
			action.lockFile(xmlExercise.XMLfile);
			break;
		}
		delete action;		
		//myTrace("end of control.lockFile");
	}
	// v0.16.1, DL: release file after using
	function releaseCourseFile() : Void {
		var action = new actionRun();
		action.releaseFile(xmlCourse.XMLfile);
		delete action;
	}
	function releaseCourseFileToMenu() : Void {
		var action = new actionRun();
		action.releaseCourseFileToMenu(xmlCourse.XMLfile);
		delete action;
	}
	function releaseUnitFile() : Void {
		var action = new actionRun();
		action.releaseFile(xmlUnit.XMLfile);
		delete action;
	}
	function releaseUnitFileToCourse() : Void {
		var action = new actionRun();
		action.releaseMenuFileToCourse(xmlUnit.XMLfile);
		delete action;
	}
	function releaseUnitFileToExercise() : Void {
		var action = new actionRun();
		action.releaseMenuFileToExercise(xmlUnit.XMLfile);
		delete action;
	}
	function releaseExerciseFile() : Void {
		var action = new actionRun();
		action.releaseFile(xmlExercise.XMLfile);
		delete action;
	}
	function releaseExerciseFileToMenu() : Void {
		var action = new actionRun();
		action.releaseExerciseFileToMenu(xmlExercise.XMLfile);
		delete action;
	}
	
	// add data to course.xml
	function addCoursesToXML() : Void {
		xmlCourse.addCoursesToXML();
	}
	// generate course.xml
	function generateCourseXML() : Void {
		//myTrace("Generate course xml file.");
		// v6.4.0.1, DL: should not have any checking on saving
		/*var action = new actionRun();
		action.checkLockCourses(xmlCourse.XMLfile);
		delete action;*/
		writeCourseXML();
	}
	function writeCourseXML() : Void {
		xmlCourse.generateFile();
	}
	// add data to units xml file
	function addUnitsToXML() : Void {
		xmlUnit.addUnitsToXML();
		//data.currentUnit.noChange = false;
	}
	// generate menu.xml file
	function saveUnit(nextAction:String) : Void {
		//v6.4.2.2, RL: generate xml if only needs to change;
		//v6.4.4, RL: the if statement will affect others operations, e.g add new Unit, so better bar that out.
		//myTrace("DEBUG msg - data.currentUnit.noChange="+data.currentUnit.noChange);
		//myTrace("eventAfter="+eventAfter);
		//myTrace("nextAction="+nextAction);
		/*
		if (!data.currentUnit.noChange) {
		*/
			//_global.myTrace("DEBUG trace - nextAction in saveUnit = "+nextAction);
		// AR v6.4.2.5 Hasn't this just been done in saveExercise? Or not need to be done if called from other places?
		//if (_enableMGS) {
		//	// AR v6.4.2.5 use constant
		//	//setExerciseEnabledFlag("16", true);
		//	_global.myTrace("control.saveUnit call setExerciseEnabledFlag");
		//	// This call will set the flag in the dataExercise object
		//	setExerciseEnabledFlag(enabledFlag.MGS, true)
		//}
		addUnitsToXML();
		generateUnitXML(nextAction);
		/*
		} else {
			readUnitXML();
		}
		*/
	}
		// 6.4.2.2, RL: write into menu.xml only if save.
	function generateUnitXML(nextAction:String) : Void {
		_global.myTrace("control.generateUnitXML.nextAction="+nextAction + ", eventAfter=" + eventAfter);
		//myTrace("Generate menu.xml file.");
		if (eventAfter!="saveExercise"&&eventAfter!="previewExercise"&&nextAction!="createNewMenuXml") {
			view.setupPBar("saveUnit"+nextAction);
		} else if (eventAfter!="saveExerciseExit") {
			// do nothing
		}
		//if (eventAfter!="saveExercise" || eventAfter!="saveExerciseExit") {
		writeUnitXML();
		//}
	}
	function writeUnitXML() : Void {
		myTrace("control.writeUnitXML");
		xmlUnit.generateFile();
	}
	// add current exercise to xml
	function addCurrentExerciseToXML() : Void {
		xmlExercise.addExerciseToXML(data.currentExercise);
	}
	// generate exercise xml file
	function saveExercise(nextAction:String) : Void {
		// v6.4.4, RL: change the value of enabledFlag of exercise level.
		if (_enableMGS) {
			// v6.4.2.6 Surely we only need to do this if this exercise was originally outside the MGS but we are about to save it inside.
			// In which case we also want to either copy any media files, or set <media location="original" />
			// v6.4.2.8 This seems to always be true, even when we have saved many times
			_global.myTrace("ex, current eF=" + data.currentExercise.enabledFlag);
			if (data.currentExercise.enabledFlag & enabledFlag.MGS) {
				_global.myTrace("save this ex in MGS, it was already in MGS")
			} else {
				_global.myTrace("first time to save this exercise in MGS")
				// AR v6.4.2.5 use constant
				//setExerciseEnabledFlag("16", true);
				//_global.myTrace("control.saveExercise call setExerciseEnabledFlag");
				setExerciseEnabledFlag(enabledFlag.MGS, true)
				// AR v6.4.2.5 Don't save the unit here, but note that you need to
				//saveUnit();
				onMenuChanged();
			}
		}		
		view.updateExerciseBeforeSaving();
		if (errorCheck.passSaveExerciseTest()) {	// v0.6.0, DL: error checking
			myTrace("control.saveExercise.nextAction=" + nextAction);
			addCurrentExerciseToXML();
			generateExerciseXML(nextAction);
		} else {
			//myTrace("no, just go back to menu");
		}
	}
	function generateExerciseXML(nextAction:String) : Void {
		//myTrace("Generate exercise xml file.");
		// it is wrong. should change the MGS menu.xml but not the orginial menu.xml
		//myTrace("(control) _enableMGS = "+_enableMGS);
		/*
		if (_enableMGS) {
			//data.currentExercise.setEnabledFlag("16", true);			
			data.currentExercise.setMGSEnable(true);
		}
		*/
		//myTrace(data.currentCourse.courseFolder);
		//myTrace(data.currentCourse.subFolder);
		//myTrace(data.currentExercise.fileName);
		xmlExercise.formURL(data.currentCourse.courseFolder, data.currentCourse.subFolder, data.currentExercise.fileName);
		view.setupPBar("saveExercise"+nextAction);
		var action = new actionRun();
		action.checkLockExercise(xmlExercise.XMLfile);
		delete action;
	}
	function writeExerciseXML() : Void {
		// v6.4.1, DL: if the user is not closing the file after saving, we need to lock the file
		if (eventAfter==""||eventAfter=="previewExercise"||eventAfter=="saveExercise"||eventAfter=="saveExerciseExit") {
			lockFile("SaveExercise");
		} else {
			releaseExerciseFile();
		}
		xmlExercise.generateFile();
	}
	// v6.4.0.1, DL: add/edit exercise, used for saving exercise
	function addExerciseToMenu() : Void {
		// AR v6.4.2.5 This currently leaps straight to next function anyway, no point to compare.
		//var c = new xmlCompareClass(xmlUnit);
		//c.loadXML("AddExercise");
		//_global.myTrace("skip compare, go to check unit")
		onComparedXmlAddExercise(xmlUnit);
	}
	function onComparedXmlAddExercise(newXML:XML) : Void {
		// AR v6.4.2.5 Now - at this point I am about to use data model for units to write out an updated menu.
		// But I believe the data model is right up to date anyway. So just skip all this??

		// v6.4.2.5 AR If you are in MGS, all exercises that you save will have the MGS flag set
		// v6.4.2.6 But ONLY if you are in an MGS, so add the check here
		if (_enableMGS) {
			_global.myTrace("you are in MGS, onComparedXML, so make sure that all eF are MGS");
			data.currentExercise.enabledFlag |= enabledFlag.MGS;
		}
		
		/*
		// get required information from data.currentUnit and data.currentExericse
		var unitID = data.currentUnit.id;
		var exID = data.currentExercise.id;
		// v6.4.3 Pick up the caption from the exercise as it might have changed
		var caption:String = (data.currentExercise.caption!="") ? data.currentExercise.caption : "";
		// v6.4.3 Pick up the enabled flag from the exercise as it might have been altered with exercise settings
		var thisEnabledFlag:Number = data.currentExercise.enabledFlag;
		// v6.4.2.5 AR If you are in MGS, all exercises that you save will have the MGS flag set
		if (_enableMGS) {
			thisEnabledFlag|=enabledFlag.MGS;
		}
		//_global.myTrace("onComparedXMLAddExercise, eF=" + enabledFlag);
		var match:Boolean = false;
		
		//_global.myTrace("unitID= "+unitID+" ; exID= "+exID+" ; caption="+caption+"/");
		//_global.myTrace("xml = "+newXML.firstChild.toString());
		
		// add/edit the exercise to current unit xml
		if (_global.trim(caption)!="" && _global.trim(caption).length>0) {
			var rootNode = newXML.firstChild;
			for (var i in rootNode.childNodes) {
				var unitNode = rootNode.childNodes[i];
				if (unitNode.attributes.id==unitID) {
					for (var j in unitNode.childNodes) {
						var exNode = unitNode.childNodes[j];
						if (exNode.attributes.id==exID) {
							exNode.attributes.caption = caption;
							exNode.attributes.enabledFlag = thisEnabledFlag;
							match = true;
							// AR v6.4.2.5 you can only match on one node (I hope!)
							break;
						}
					}
					// If there are no nodes for this exercise, it is new so you must add it
					if (!match) {
						var newNode:XMLNode = newXML.createElement("item");
						newNode.attributes.id = exID;
						newNode.attributes.caption = caption;
						newNode.attributes.enabledFlag = thisEnabledFlag;
						// v6.4.4, RL : add 32 for course whcih is non-editable
						// v6.4.2.5 AR use constant - but you will never set this
						//if (_nonEditable) {
						//	//newNode.attributes.enabledFlag|=32;
						//	_global.myTrace("control.onComparedXMLAddExercise.2 add enabledFlag = " + enabledFlag.nonEditable);
						//	newNode.attributes.enabledFlag|=enabledFlag.nonEditable;
						//}
						newNode.attributes.unit = unitNode.attributes.unit;
						newNode.attributes.fileName = exID + ".xml"
						newNode.attributes.action = exID;
						newNode.attributes.exerciseID = exID;
						unitNode.appendChild(newNode);
					}
					break;
				}
			}
		}
		
		//_global.myTrace("xml = "+newXML.firstChild.toString());
		
		// load the up-to-date unit xml
		var nodes = newXML.firstChild.childNodes;
		data.currentCourse.fillInUnits(nodes);
		*/		
		
		// v6.4.0.1, DL: debug - if it's saving exercise then don't reload unit
		if (eventAfter=="saveExercise" || eventAfter=="previewExercise") {
			saveUnit("");
		// v6.4.1.2, DL: debug - if it's exit then byebye
		} else if (eventAfter=="saveExerciseExit") {
			saveUnit("Exit");
		} else {
			// regenerate the updated unit xml
			saveUnit("ReloadUnit");
		}
	}
	function onFinishSavingMenuXMLBackUnit() : Void {
		// v6.4.0.1, DL: no need to delete ghost exercises, it'll be handled by addExerciseToMenu()
		// v0.5.2, DL: delete newly created (not saved) exercises out from current unit
		//data.currentUnit.delNewlyCreatedExercises();
		//view.fillInUnitList(data.currentCourse.Units);
		//view.fillInExerciseList(data.currentUnit.Exercises);
		// v0.12.0, DL: make the comment & upgrade buttons visible
		//view.setVisible("btnEmail", true); /// v6.5.4.2 Yiu, this code is no needed, Bug ID 1320
			
		view.setVisible("btnUpgrade", true);
		// v0.16.1, DL: release exercise file after use
		// v6.4.0.1, DL: not just release exercise, but lock menu afterwards
		releaseExerciseFileToMenu();
	}
	
	// v6.4.0.1, DL: check if the exercise is locked
	function checkLockOnExercise() : Void {
		// v6.5.4.6 At this point check to see if you are still the latest user (licenceID)
		// Lets do it in the login class since it is related
		// V6.5.4.7 Lets not do this just yet!
		//login.checkLicence(this._licenceID);
		// and then you can only continue with the rest of this on getting a successful response...
		
		xmlExercise.formURL(data.currentCourse.courseFolder, data.currentCourse.subFolder, data.currentExercise.fileName);
		//view.setupPBar("saveExercise"+eventAfter);
		var action = new actionRun();
		action.checkLockExerciseForOpening(xmlExercise.XMLfile);
		delete action;
	}
	
	// on finish filling in lists
	function onFinishFillInCourseList() : Void {
		view.showPleaseWait(false);
		if (_lite) {
			// show unit screen after loading xml
			showUnitScreenAfterLoad = true;
			if (data.getNoOfCourses()>=1) {
				// select course[0] (as default currentCourse)
				view.selectCourseByIndex(0);
				// change current course
				data.setCurrentCourseByIndex(0);
				// load unit xml
				loadUnitXML();
			} else {
				_global.myTrace("1395:control.as:make new course.xml")
				// add new course
				// v6.5.4.1 Call the new function for adding a course which does more stuff.
				//data.addNewCourse();
				addCourseSafe();
				// v6.4.1.5, DL: enter menu after adding the first course (for Lite version)
				//_global.myTrace("1395:control.as:call saveCourse"); 
				saveCourse("addCourseFillMenu");
			}
		} else {
			// don't show unit screen after loading xml
			//showUnitScreenAfterLoad = false;
			// load unit XML
			//xmlUnit.formURL(data.currentCourse.courseFolder, data.currentCourse.subFolder, data.currentCourse.scaffold);
			//xmlUnit.loadXML();
			// show course screen
			view.showCourseScreen();
		}
	}
	
	// v0.16.0, DL: debug - if we don't wait for the unit list to be filled up, the user will see the units changing from course to course
	function onFinishFillInUnitList() : Void {
		// v0.9.0, DL: there may not be any units in this course
		if (data.currentCourse.Units.length>0) {
			// v6.4.1, DL: select current unit if there should be any
			if (data.currentUnit!=undefined) {
				view.selectUnitByField("unit", data.currentUnit.unit);
				// v6.4.1, DL: debug - although current unit is not undefined, it doesn't point to the unit anymore
				// it lost its reference to the unit after saving
				data.setCurrentUnit(data.currentUnit.unit);
			} else {
				data.setCurrentUnit(data.currentCourse.Units[0].unit);
				view.selectUnitByIndex(0);	// 0.9.0, DL: set default unit to 0
			}
		}
		
		if (showUnitScreenAfterLoad) {
			// v0.16.0, DL: debug - if there's no units in this course, it's no use to fill in exercise list
			if (data.currentCourse.Units.length>0) {
				view.fillInExerciseList(data.currentUnit.Exercises);
			} else {
				onFinishFillInExerciseList();
			}
		}
	}
	
	function onFinishFillInExerciseList() : Void {
		var b:Boolean = (data.currentCourse.editedCourseFolder!="");
		if (_global.NNW.interfaces.getInterface()=="AuthorPlus") { b = false; }
		view.setVisible("btnReset", b);
		view.showUnitScreen();
	}
	
	function onFinishFillInExerciseDetails() : Void {
		view.showExerciseScreen();
	}
	
	// v6.4.1.5, DL: add enabledFlag to a course
	function updateCourseEnabled(b:Boolean) : Void {
		//v6.4.4, RL: updated enableFlag to a course.
		// but how about randomOn, disableOn, edited and noneditable?
		// shall this function be rewrited?
		//data.currentCourse.enabledFlag = (b) ? "3" : "0";
		// AR v6.4.2.5 use constants
		if (b) {
			// switch off the disabled flag
			data.currentCourse.enabledFlag &=~enabledFlag.disabled;
		} else {
			// switch on the disabled flag
			data.currentCourse.enabledFlag |= enabledFlag.disabled;
		}
		//_global.myTrace("control.updateCourseEnabled.enabledFlag=" + data.currentCourse.enabledFlag);
		saveCourse("saveCourseName");
	}
	
	function updateCoursePrivacy(f:Number) : Void {
		data.currentCourse.privacyFlag = f;
		saveCourse("saveCourseName");
	}
	
	// email
	function sendEmail(subject:String, body:String) : Void {
		/* pass subject & body to send email */
		// v6.5.0.1 Yiu Skip checking because the subject and body will be null now
		//if (errorCheck.passEmailCheck(subject, body)) {
		if(1){
			emailSubject = subject;
			emailBody = body;
			var action = new actionRun();
			action.sendEmail(subject, body);
			delete action;
			view.clearEmailScreen();
			view.hideEmailScreen();
		}
	}
	function sendEmailByProgram() : Void {
		// fail to send via server, use user's own email program
		getURL("mailto:support@clarity.com.hk?subject="+emailSubject+"&body="+emailBody);
	}
	
	// v0.16.1, DL: share files
	function shareFiles() : Void {
		// AR v6.4.2.5 Stop importing at the course level.
		if (view.screens.scnUnit._visible) {
			view.setVisible("btnUploadImport", true);
		} else {
			view.setVisible("btnUploadImport", false);
		}
		// v6.4.1.3, DL: XML manipulation for files sharing is now in sharing class
		sharing.readAllXml();
	}
	function exportFiles(userSelectXML:XML, SCORM:Boolean) : Void {
		// v6.4.2.1 Show the mask while you do this
		view.showMask();
			
		// v6.4.1.3, DL: XML manipulation for files sharing is now in sharing class
		sharing.exportFiles(userSelectXML, SCORM);
	}
	function runExportFiles(folderPath:String, files:Array, folders:Array, SCORM:Boolean) : Void {
		// rootNode.firstChild.attributes.folderPath holds the mapped physical path on server of userDataPath
		// so we don't have to mappath anymore
		// v6.4.2 AR SCORM SCO creation is not the same as file export
		var action = new actionRun();
		//myTrace("export:folderPath=" + folderPath + " files=" + files.toString() + " folders=" + folders.toString());
		action.exportFiles(folderPath, files, folders, SCORM);
		delete action;
	}
	function createSCO(userSelectXML:XML) : Void {
		// v6.4.1.3, DL: XML manipulation for files sharing is now in sharing class
		//_global.myTrace("control.createSCO");
		// v6.4.2.1 Show the mask while you do this
		view.showMask();
		sharing.createSCO(userSelectXML);
	}
	function runCreateSCO(folderPath:String, cid:Number, cname:String, uids:Array, unames:Array) : Void {
		// v6.4.2 AR SCORM SCO creation is not the same as file export
		var action = new actionRun();
		action.createSCO(folderPath, cid, cname, uids, unames);
		delete action;
	}
	function onExportFilesSuccess(file:String) : Void {
		_global.myTrace("onExportFileSuccess=" + file);
		// check to see if the file exists, if so, prompt the user to download the newly created zip file
		var action = new actionRun();
		action.checkFileForDownload(file);
		delete action;
		// v6.4.2.1 Now safe to remove the mask
		view.hideMask();

	}
	//v6.4.2.1 AR We know that this file exists now, so display a window that lets the user click to download it
	// But the filename we know is physical, and we want to put a URL into the window. We know that the
	// file is in the same folder as course.xml
	function promptFileDownload(file) : Void {
		if (__server) {
			// v6.4.1.2, DL: prepare for PHP scripting
			if (login.licence.scripting.toLowerCase()=="php") { 
				// AR v6.5.4.7 PHP Also needs this - at least when running on Windows.
				file = _global.replace(file, "\\", "/");
				var downloadScriptPath:String = paths.serverPath+"/downloadFile.php";
			} else {
				file = _global.replace(file, "\\", "/");
				var downloadScriptPath:String = paths.serverPath+"/downloadFile.asp";
			}
			//v6.4.2.1 The html page needs to know the URL of the file as well as the physical path
			// so send it the folder that we know has been used so that it can sort out the physical itself
			// v6.4.3 Change the name from paths.userPath to paths.content, as that is what it is!
			//var folderURL = _global.NNW.paths.content;
			//v6.4.4, RL: change the path into MGS path
			/*
			if (_enableMGS==true) {
				var folderURL = _global.NNW.paths.MGSPath;
			} else if (_enableMGS==false){
				var folderURL = _global.NNW.paths.content;
			}*/	
			//v6.4.4, RL: re-edited. the paths.MGSPath is already equals to paths.content if there's no MGS
			var folderURL = _global.NNW.paths.MGSPath;

			// v6.4.2.6 If you are running a script related to files, you need userDataPath for new getRootDir 
			var udp = _global.NNW.paths.userDataPath;
			//downloadScriptPath += "?prog=NNW&file="+file+"&folderURL="+folderURL;
			downloadScriptPath += "?prog=NNW&file="+file+"&folderURL="+folderURL+"&userDataPath="+udp;
			getURL("javascript: openWindowForNNW('" + downloadScriptPath + "', 'dlPrompt', 420, 200, 0 ,0 ,0 ,0 ,0 ,1 ,20 ,20 );");
			myTrace(downloadScriptPath);
		}
	}
	// v6.4.2, DL: now we are informed that the download is completed, we can delete the zip file on the server
	function onDownloadComplete() : Void {
		_global.myTrace("on download complete in control");
		// v6.4.2, DL: not sure if this will work on all platforms, better not do it now
		/*var action = new actionRun();
		action.deleteFile(upload.file);
		delete action;*/
	}
	// v6.4.3 It is wrong to only have one error message for export errors. Might be permissions, corrupt .xml files OR zip
	function onExportFilesFail() : Void {
		view.showPopup("exportError");
	}
	function unzipFile(file:String) : Void {
		//v6.4.4, RL: Change the path into MGS path
		//var path = paths.content;
		/*
		if (_enableMGS==true) {
			var path = _global.NNW.paths.MGSPath;
		} else if (_enableMGS==false){
			var path = _global.NNW.paths.content;
		} */
		//v6.4.4,RL: use MGSPath is enough in both cases.
		var path = _global.NNW.paths.MGSPath;
		
		if (__server) {
			path = _global.replace(path, "\\", "/");
			path= _global.replace(path, "//", "/");
		}
		
		// unzip the uploaded zip file
		var action = new actionRun();
		action.unzipFile(file, path);
		delete action;
	}
	function onUnzipFail() : Void {
		view.showPopup("unzipError");
	}
	function loadImportFiles(folder:String) : Void {
		// v6.4.1.3, DL: XML manipulation for files sharing is now in sharing class
		sharing.loadImportFiles(folder);
	}
	function importFiles(userSelectXML:XML) : Void {
		// v6.4.1.3, DL: XML manipulation for files sharing is now in sharing class
		sharing.importFiles(userSelectXML);
	}
	function runImportFiles(folderPath:String, files:Array, folders:Array) : Void {
		// rootNode.firstChild.attributes.folderPath holds the mapped physical path on server of userDataPath
		// so we don't have to mappath anymore
		var action = new actionRun();
		// v6.4.3 You never import to the course folder - just into a course
		//if (sharing.shareBase=="course") {
		//	//myTrace("control:importFiles");
		//	action.importFiles(folderPath, files, folders);
		//} else {	// shareBase = "menu"
			//myTrace("control:importFilesToCurrentCourse ");
			//myTrace("existing XML=" + xmlUnit.XMLfile.toString());
			action.importFilesToCurrentCourse(folderPath, files, folders, xmlUnit.XMLfile);
		//}
		delete action;
	}
	function onImportFilesSuccess() : Void {
		//_global.myTrace("sharing.onImportFilesSuccess.shareBase=" + sharing.shareBase);
		if (sharing.shareBase=="course") {
			// v6.4.1.4, DL: DEBUG - importing doesn't cope with more than 1 Clarity's program interfaces
			// we need to update menu xml files before showing the new course xml to user
			// therefore, reload the course.xml only after we've finished all the menu.xml files
			//xmlCourse.loadXML();
			sharing.updateMenuXmlFiles();
		}
	}
	function onImportFilesToCurrentCourseSuccess() : Void {
		//_global.myTrace("sharing.onImportFilesToCurrentSuccess.shareBase=" + sharing.shareBase);
		if (sharing.shareBase!="course") {
			// reload the menu.xml
			// v6.4.1.4, DL: DEBUG - importing doesn't cope with more than 1 Clarity's program interfaces
			// let's save it again
			xmlUnit.loadXML("save");
			// v6.4.2.5 This doesn't seem  to get to the bit that resets the interface, try different one
			//saveUnit(""); - no
		}
	}
	function onImportFilesFail() : Void {
		view.showPopup("importError");
	}
	
	// upload functions
	/*function upload() : Void {
		view.showPopup("funcNA");
	}*/
	// v0.16.1, DL: upload image
	function uploadImage() : Void {
		upload.uploadType = "image";
		var action = new actionRun();
		action.uploadImage(formMediaPath());
		delete action;
	}	
	// v0.16.1, DL: upload audio (AutoPlay/Embed/AfterMarking), question audio with qNo
	function uploadAudio(t:String) : Void {
		// v0.10.0, DL: no adding audio in APL
		//if (errorCheck.passAddAudioCheck(_lite)) {
			upload.uploadType = "audio"+t;
			var action = new actionRun();
			action.uploadAudio(formMediaPath());
			delete action;
		//}
	}
	// v0.16.1, DL: upload question audio with qNo
	function uploadMultipleAudio(t:String, qNo:Number) : Void {
		// v0.10.0, DL: no adding audio in APL
		//if (errorCheck.passAddAudioCheck(_lite)) {
			upload.uploadType = "audio"+t;
			upload.uploadQuestionNo = qNo;
			var action = new actionRun();
			action.uploadMultipleAudio(formMediaPath());
			delete action;
		//}
	}
	// v6.4.3 Add images to question media
	function uploadMultipleImage(t:String, qNo:Number) : Void {
		// v0.10.0, DL: no adding audio in APL
		//if (errorCheck.passAddAudioCheck(_lite)) {
			upload.uploadType = "image"+t;
			upload.uploadQuestionNo = qNo;
			var action = new actionRun();
			action.uploadMultipleImage(formMediaPath());
			delete action;
		//}
	}
	// v0.16.1, DL: upload video (embed/floating)
	function uploadVideo(t:String) : Void {
		upload.uploadType = "video"+t;
		var action = new actionRun();
		action.uploadVideo(formMediaPath());
		delete action;
	}
	// v0.16.1, DL: upload zip file for import
	function uploadImport() : Void {
		//var path = paths.content;		//v6.4.4, RL: Change the path into MGS path
		//var path = paths.content;
		/*
		if (_enableMGS==true) {
			var path = _global.NNW.paths.MGSPath;
		} else if (_enableMGS==false){
			var path = _global.NNW.paths.content;
		} */
		//v6.4.4,RL: use MGSPath is enough in both cases.
		var path = _global.NNW.paths.MGSPath;
		if (__server) {
			path = _global.replace(path, "\\", "/");
			path= _global.replace(path, "//", "/");
		}
		
		upload.uploadType = "import";
		var action = new actionRun();
		action.uploadImport(path);
		delete action;
	}
	// v0.16.1, DL: form media path for uploading
	function formMediaPath() : String {
		/* pass current course's media path for upload */
		//v6.4.4, RL: Change the path into MGS path
		//var f = _global.addSlash(paths.content)+_global.addSlash(data.currentCourse.courseFolder)+_global.addSlash(data.currentCourse.subFolder)+"Media";
		/*
		if (_enableMGS==true) {
			var f = _global.addSlash(_global.NNW.paths.MGSPath)+_global.addSlash(data.currentCourse.courseFolder)+_global.addSlash(data.currentCourse.subFolder)+"Media";
		} else if (_enableMGS==false){
			var f = _global.addSlash(_global.NNW.paths.content)+_global.addSlash(data.currentCourse.courseFolder)+_global.addSlash(data.currentCourse.subFolder)+"Media";
		} */
		//v6.4.4,RL -05Feb07: use MGS path is enough
		var f = _global.addSlash(_global.NNW.paths.MGSPath)+_global.addSlash(data.currentCourse.courseFolder)+_global.addSlash(data.currentCourse.subFolder)+"Media";
		if (__server) {
			f = _global.replace(f, "\\", "/");
			f = _global.replace(f, "//", "/");
		}
		myTrace("formMediaPath=" + f);
		return f;
	}
	// v6.4.2, DL: form import path for uploading
	function formImportPath() : String {
		//v6.4.4, RL: Change the path into MGS path
		//var f = paths.content;
		/*
		if (_enableMGS==true) {
			var f = _global.NNW.paths.MGSPath;
		} else if (_enableMGS==false){
			var f = _global.NNW.paths.content;
		}*/
		var f = _global.NNW.paths.MGSPath;
		if (__server) {
			f = _global.replace(f, "\\", "/");
			f = _global.replace(f, "//", "/");
		}
		return f;
	}
	
	// v0.16.1, DL: browse media files
	function getMediaFilenames(t:String) : Void {
		fileType = t;
		
		var x = new XML();
		x.master = this;
		x.fileType = fileType;
		x.onLoad = function(success) {
			var a = new Array();
			if (success) {
				var listNode = this.firstChild;
				for (var i in listNode.childNodes) {
					var fileNode = listNode.childNodes[i];
					a.push(fileNode.firstChild);
				}
			}
			this.master.view.fillInBrowseFileList(a, this.fileType);
		}
		
		// clear file list on screen first
		view.clearBrowseFileList();
		
		// v6.4.1.2, DL: fix coursePath (esp. for FSP)
		//v6.4.4, RL: Change the path into MGS path
		//var coursePath = paths.content;
		/*
		if (_enableMGS==true) {
			var coursePath = _global.NNW.paths.MGSPath;
		} else if (_enableMGS==false){
			var coursePath = _global.NNW.paths.content;
		} */
		var coursePath = _global.NNW.paths.MGSPath;
		//v6.4.2.1 ZIP files will be found in a different place from media files
		// Since the script should be generic, make sure you pass full folder from here
		if (fileType!="zip") {
			//myTrace("addSlash=" + _global.addSlash(""));
			coursePath += _global.addSlash("") + _global.addSlash(data.currentCourse.courseFolder);
			//if (coursePath.substr(-1, 1)!="/" && coursePath.substr(-1, 1)!="\\") {
			//	coursePath += "/";
			//}
			//coursePath += data.currentCourse.subFolder ;
			coursePath += _global.addSlash(data.currentCourse.subFolder)+"Media" ;
		}
		// v6.4.1.2, DL: prepare to add PHP scripting
		//myTrace("look for " + fileType + " files in " + coursePath);
		if (__server) {
			if (login.licence.scripting.toLowerCase()=="php") {
				var getMediaFilenamesPage:String = paths.serverPath+"/getMediaFilenames.php";
			} else {
				var getMediaFilenamesPage:String = paths.serverPath+"/getMediaFilenames.asp";
			}
			// v6.4.2.6 If you are running a script related to files, you need userDataPath for new getRootDir 
			// v6.4.2.7 this was missed from the main release.
			var udp = _global.NNW.paths.userDataPath;
			//x.load(getMediaFilenamesPage+"?prog=NNW&type="+fileType.substr(0, 5)+"&path="+coursePath);
			_global.myTrace(getMediaFilenamesPage+"?prog=NNW&type="+fileType.substr(0, 5)+"&path="+coursePath+"&userDataPath="+udp);
			x.load(getMediaFilenamesPage+"?prog=NNW&type="+fileType.substr(0, 5)+"&path="+coursePath+"&userDataPath="+udp);
		// v6.4.1.2, DL: add FSP support for network version
		} else {
			//coursePath += _global.addSlash("") + "Media";
			//_root.mdm.getfilelist_del(coursePath,"*.*","%",Delegate.create(this, this.getMediaFilenamesByFSP));
			// v6.4.3 Not obvious why you get all files instead of using the type mask here.
			var searchMask:String = "*.*";
			this.getMediaFilenamesByFSP(mdm.FileSystem.getFileList(coursePath, searchMask));
		}
	}
	// v6.4.1.2, DL: browse media files by FSP
	// v6.4.3 ZINC now gives you an array
	//function getMediaFilenamesByFSP(file:String) : Void {
		//if (file=="undefined"||file=="") {
		//	var a:Array = new Array();
		//	view.fillInBrowseFileList(a, fileType);
		//} else {
		//	var a:Array = file.split("%");
	function getMediaFilenamesByFSP(a:Array) : Void {
		//myTrace("got files " + a.toString());
		if (a=="undefined"||a.length==0) {
			var b:Array = new Array();
			view.fillInBrowseFileList(b, fileType);
		} else {
			//var a:Array = file.split("%");
			switch (fileType.substr(0, 5)) {
			case "image" :
			case "imageQuestion" :
				for (var i in a) {
					if (a[i].substr(-4,4).toUpperCase()!=".JPG") {
						a[i] = "";
					} else {
						a[i] = _global.fixTags(a[i]);
					}
				}
				break;
			case "audio" :
				for (var i in a) {
					if (a[i].substr(-4,4).toUpperCase()!=".MP3"&&a[i].substr(-4,4).toUpperCase()!=".FLS") {
						a[i] = "";
					} else {
						a[i] = _global.fixTags(a[i]);
					}
				}
				break;
			case "video" :
				for (var i in a) {
					if (a[i].substr(-4,4).toUpperCase()!=".FLV"&&a[i].substr(-4,4).toUpperCase()!=".SWF") {
						a[i] = "";
					} else {
						a[i] = _global.fixTags(a[i]);
					}
				}
				break;
			case "zip" :
				for (var i in a) {
					if (a[i].substr(-4,4).toUpperCase()!=".ZIP") {
						a[i] = "";
					} else {
						a[i] = _global.fixTags(a[i]);
					}
				}
				break;
			}
			view.fillInBrowseFileList(a, fileType);
		}
	}
	
	// upgrade
	function upgrade() : Void {
		getURL(_global.NNW.literals.getLiteral("lblUpgradeURL"), "_blank");
	}
	
	// show guide
	function showGuide() : Void {
		var l:String = (_lite) ? "APL" : "APP";
		var s:String = _global.addSlash(paths.main)+l+_global.addSlash("Help") + "UserGuide.pdf";
		if (__local) {
			//s = "\""+s+"\"";
			// v6.5.0.1 Changed to internet version guide
			s = "http://www.clarity.com.hk/support/user/pdf/ap/AP_Authoring_Guide.pdf";
			// v6.4.3 mdm.script.2
			//_root.mdm.exec(s);
			mdm.System.exec(s);
		} else {
			getURL(s, "_blank");
		}
	}
	
	// show help
	function showHelp() : Void {
		var l:String = (_lite) ? "APL" : "APP";
		getURL(_global.addSlash(paths.main)+l+"Help/index.htm", "_blank");
	}
	
	// v0.9.0, DL: show what do i do now?
	function showWhatDo(t:String, n:Number) : Void {
		var l:String = (_lite) ? "APL" : "APP";
		switch (t) {
		case "Course" :
			getURL(_global.addSlash(paths.main)+l+"Help/Screen-Course.htm?language="+_global.NNW.literals.SelectedLanguage, "_blank");
			break;
		case "Unit" :
			getURL(_global.addSlash(paths.main)+l+"Help/Screen-Menu.htm?language="+_global.NNW.literals.SelectedLanguage, "_blank");
			break;
		case "Exercise" :
			if (n==1) {
				getURL(_global.addSlash(paths.main)+l+"Help/Screen-Settings.htm?exercise="+data.currentExercise.exerciseType+"&language="+_global.NNW.literals.SelectedLanguage, "_blank");
			} else {
				getURL(_global.addSlash(paths.main)+l+"Help/Screen-Content.htm?exercise="+data.currentExercise.exerciseType+"&language="+_global.NNW.literals.SelectedLanguage, "_blank");
			}
			break;
		}
	}
	
	// v0.16.0, DL: preview courses
	function onPreviewCourses() : Void {
		// v6.4.1.2, DL: preview functions moved into previewClass
		preview.previewCourses();
	}
	
	// preview menu
	function onPreviewMenu() : Void {
		// v6.4.1.2, DL: preview functions moved into previewClass
		preview.previewMenu();
	}
	
	// preview exercise
	function onPreviewExercise() : Void {
		if (!data.currentExercise.noChange||data.currentExercise.newlyCreated) {
			saveExercise("Preview");
			eventAfter = "previewExercise";	// v6.4.1, DL
			preview.previewAction = "previewExercise";	// v6.4.1.2, DL
		} else {
			// v6.4.1.2, DL: preview functions moved into previewClass
			preview.previewExercise();
		}
	}
	function setPreviewSessionVariables(purpose:String) : Void {
		var action = new actionRun();
		/* pass course id and exercise id for preview */
		action.preview(purpose);
		delete action;
	}
	function previewByLocalConn() : Void {
		eventAfter = preview.previewAction;
		preview.previewByLocalConn();
	}
	function loadPreview() : Void {
		// v6.4.1.2, DL: preview functions moved into previewClass
		preview.loadPreview();
	}
	
	// save course
	function saveCourse(nextAction:String) : Void {
		//myTrace("control.saveCourse then " + nextAction);
		if (errorCheck.passMenuTest()) {	// v0.6.0, DL: error checking
			if (nextAction!=undefined) {
				view.setupPBar(nextAction);
			} else {
				view.setupPBar("saveFiles");
			}
			if (_enableMGS==true) {
				// AR v6.4.2.5 use constants
				//setCourseEnabledFlag("16", true);
				//_global.myTrace("control.saveCourse call setCourseEnabledFlag");
				setCourseEnabledFlag(enabledFlag.MGS, true);
			}
			/* get data format them into XML */
			addCoursesToXML();
			/* generate the XML file */
			generateCourseXML();
		}
	}
	
	function saveCourseName(n:String) : Void {
		//_global.myTrace("control.saveCourseName as " + n);
		renameCourse(n);
		saveCourse("saveCourseName");
	}
	
	//v6.4.4, RL: set course.xml enabledFlag value
	// AR v6.4.2.5 enabledFlag is a number
	//function setCourseEnabledFlag(s:String, v:Boolean) : Void {
	function setCourseEnabledFlag(flag:Number, v:Boolean) : Void {
		//_global.myTrace("control.setCourseEnabledFlag flag=" + flag + " to " + v);
		data.currentCourse.setEnabledFlag(flag, v);
		//saveCourse();
	}

	function setCoursePrivacyFlag(flag:Number, v:Boolean) : Void {
		_global.myTrace("control.setCoursePrivacyFlag flag=" + flag + " to " + v);
		data.currentCourse.setPrivacyFlag(flag, v);
	}
		
	//v6.4.4, RL: set menu.xml enabledFlag value in Exercise class
	// AR v6.4.2.5 enabledFlag is a number
	// AR v6.4.2.5 This is a request to update the node in the menu, nothing to do in the actual exercise
	//function setExerciseEnabledFlag(s:String, v:Boolean) : Void {
	function setExerciseEnabledFlag(flag:Number, v:Boolean) : Void {
		//_global.myTrace("control.setExerciseEnabledFlag flag=" + flag + " to " + v);
		data.currentExercise.setEnabledFlag(flag, v);
		//saveUnit();
	}	
	
	// show settings
	function showSettings() : Void {
		view.showPopup("funcNA");
	}
	
	// exit program
	function exitProgram(onExerciseScreen:Boolean) : Void {
		/*
		// for projector (Flash)
		fscommand("quit");
		// for Zinc
		fscommand("mdm.exit");
		// for browser (requires special JavaScript in HTML file)
		fscommand("browserExit");
		*/
		
		// v6.4.0.1, DL: now combine codes from onExerciseExit() to here
		if (onExerciseScreen) {
			if (!data.currentExercise.noChange) {
				view.showPopup("promptExitSavingExercise");
			} else {
				if (__local) {
					byebye();
				} else {
					view.showPopup("promptExit");
				}
			}
		} else {
			// v6.4.0.1, DL: no need to prompt saving from now on
			// just ask if user really wants to exit if on other screens
			//view.showPopup("promptExitSaving");
			if (__local) {
				byebye();
			} else {
				view.showPopup("promptExit");
			}
		}
	}
	
	function byebye() : Void {
		releaseCourseFile();
		releaseUnitFile();
		releaseExerciseFile();
		
		// v6.4.2.5 A new Zip extension
		//myTrace("zip.Free");
		//_root.zipHolder.zincZip.Free();
		
		// v6.4.3 Change name of final file
		var creditsMovie = _global.addSlash(paths.main)+"credits.swf";
		myTrace("load " + creditsMovie);
		//var creditsHolder = _root.createEmptyMovieClip("creditsMovie", 2);
		//myTrace("holder=" + creditsHolder);
		//creditsHolder.loadMovie(creditsMovie);
		//_root.loadMovie(_global.addSlash(paths.main)+"credits.swf");
		// Try the main loading technique - replacing screens.swf
		var no:Number = _root["screensHolder"].getDepth()-11;
		loadMovieNum(creditsMovie, no+1);
	}
	
	function convertSelectExType():Void
	{
	}
			
	// select exercise type
	function selectExType() : Void {
		//*****
		if (errorCheck.passSelectExerciseTypeCheck(_lite, view.getSelectedExType())) {
			// create a new exercise according to selected exercise type
			myTrace("control:selectExType=" + view.getSelectedExType());
			// If start from ResultsManager, use the exercise ID from parameter.
			data.setCurrentExercise(data.currentUnit.addNewExercise(data.currentCourse).id);
			data.currentExercise.setExerciseType(view.getSelectedExType());
			data.currentExercise.setDefaultTitle();
			data.currentExercise.setDefaultSettings();
			view.fillInExerciseDetails(data.currentExercise);
			break;
		}
	}
	
	// update exercise details
	function onChangeQuestionNo(qNo:Number) {
		view.fillInQuestionDetails(data.currentExercise, qNo);
	}
	
	// v0.16.0, DL: on change selection of score-based feedback
	function onChangeScore(score:Number) {
		view.fillInScoreBasedFeedback(data.currentExercise, score);
	}
	
	//v6.4.3 Try to stop unnecessary generation of menu.xml
	function onMenuChanged() {
		data.currentUnit.noChange = false;
	}
	function onExerciseChanged() {
		data.currentExercise.noChange = false;
	}
	function updateExerciseCaption(s:String) {
		data.currentExercise.renameExercise(s);
		onExerciseChanged();
		//myTrace("update exercise caption now, last char= " + s.charCodeAt(s.length-1));
		//onMenuChanged(); 	//v6.4.2.2, RL: this should change the menu.xml;
		// if onMenuChanged() the xml will still save even choose not to be saved...
		// Ar v6.4.2.5 This will also mean that the menu needs to be saved
		onMenuChanged();
	}
	function updateExerciseSettings(node:String, attr:String, value) {
		var settings = data.currentExercise.settings;
		settings[node][attr] = value;
		onExerciseChanged();
	}
	function updateExerciseTitle(s:String) {
		data.currentExercise.title.value = (s.length>0) ? s : " ";
		onExerciseChanged();
	}
	function updateExerciseText(s:String) {
		//_global.myTrace("control.updateExText " + s);
		data.currentExercise.text.value = (s.length>0) ? s : " ";
		onExerciseChanged();
	}
	/* v0.16.0, DL: image position */
	function updateExerciseImagePosition(pos:String) : Void {
		data.currentExercise.image.position = pos;
		onExerciseChanged();
	}
	
	// v6.5.1 Yiu fix upload photo keep popup problem, the third parameter added
	function updateExerciseImage(attr:String, s:String, bSkipPopUpUploadPhoto:Boolean) {
		//myTrace("control:updateExerciseImage for " + s);
		if (errorCheck.passExerciseImageCheck(_lite, s)) {
			/* v0.10.1, DL: random image only on selecting category */
			var ex = data.currentExercise;
			ex.image[attr] = s;
			
			/* v0.16.0, DL: add the NoGraphic & YourGraphic options */
			if (ex.settings.misc.splitScreen) {
				ex.image.width = "250";
				ex.image.height = "165";
			} else {
				// Yiu v6.5.1 Remove Banner
				/*
				if (ex.image.position=="banner") {
					ex.image.width = "405";
					ex.image.height = "70";
				} else {
				*/
					ex.image.width = "165";
					ex.image.height = "250";
				//}
				// End Yiu v6.5.1 Remove Banner
			}
			if (s=="NoGraphic") {
				ex.image.filename = "";
				ex.image.position = "top-right";
			} else if (s=="YourGraphic") {
				// v6.4.3 Bug in processing here - due to very messy handling of images.
				// When online (or old network) this function will finish (clearing out the existing graphic) before
				// you get back a new name from the browse. But with ZINC 2.5 the asynchronicity stops this and 
				// the rest of this function happens afterwards, which clears out what you just uploaded.
				// So, don't call this upload for a fraction of a second.
				//uploadImage();	// v0.16.1, DL: upload image
				delayedHolder.delayedUploadImage = function() {
					//_global.myTrace("clear int=" + this.delayedUploadInt);
					clearInterval(this.delayedUploadInt);
					// I need to add this in for mdm as the mask is cleared otherwise - only coming after it is too late!!
					//this.master.view.showMask();
					// When this comes back I do not clear the mask, even though the hideMask function is being called correctly.
					this.master.uploadImage();
				}
				
				// v6.5.1 Yiu fix upload photo keep popup problem, the third parameter added
				if(!bSkipPopUpUploadPhoto)
					delayedHolder.delayedUploadInt = setInterval(delayedHolder, "delayedUploadImage", 1000);
				//myTrace("int=" + delayedHolder.delayedUploadInt);
				ex.image.filename = "";
				ex.image.position = "top-right";
			} else {
				var dim = ex.image.width + "x" + ex.image.height;
				var pic = _global.NNW.photos.randFileFromCategory(dim, s);
				ex.image.filename = (pic.path!=undefined && pic.path.length>0) ? _global.addSlash(pic.path)+pic.name : pic.name;
				
				// if video is embedded, set it to be floating
				// (this is done after uploading a picture as well)
				// v6.4.3 Simplify name
				//if (data.currentExercise.videos[0].mode=="1") {
				//	updateExerciseVideo(data.currentExercise.videos[0].filename, "16", "");
				if (ex.videos[0].mode=="1") {
					updateExerciseVideo(ex.videos[0].filename, "16", "");
				}
			}
			
			ex.image.category = s;	// v0.16.1, DL: debug - should also update the category
			
			// v6.4.3 Simplify name
			//view.fillInImage(data.currentExercise.image);
			view.fillInImage(ex.image);
			onExerciseChanged();
		}
	}

	function updateExerciseInstructionsAudio(shared:Boolean, selected:Boolean) {
		if (selected) {
			data.currentExercise.addInstructionsAudio(shared);
			// if not shared then need to upload
			//if (!shared) { uploadAudio("AutoPlay"); }
		} else {
			data.currentExercise.deleteInstructionsAudio(shared);
		}
		view.fillInAudios(data.currentExercise.audios);
		onExerciseChanged();
	}
	// v0.16.1, DL: update embed audio
	function updateExerciseEmbedAudio(n:String) : Void {
		data.currentExercise.addEmbedAudio(n);
		view.fillInAudios(data.currentExercise.audios);
		onExerciseChanged();
	}
	// v0.16.1, DL: update after marking audio
	function updateExerciseAfterMarkingAudio(n:String) : Void {
		data.currentExercise.addAfterMarkingAudio(n);
		view.fillInAudios(data.currentExercise.audios);
		onExerciseChanged();
	}
	// v6.4.2.7 Adding URLs
	function updateExerciseURL(idx:Number, url:String, caption:String, floating:Boolean) : Void {
		// make sure that if any of the parameters are undefined that they don't go through to addURL
		//_global.myTrace("control.updateExURL["+idx+"] url=" + url); 
		//var urlObj = {idx:idx, url:url, caption:caption, mode:mode};
		var urlObj = new Object();
		if (idx>=0) urlObj.idx = idx;
		if (url!="undefined" || url!=undefined) urlObj.url=url;
		if (caption!="undefined" || caption!=undefined) urlObj.caption=caption;
		if (floating!="undefined" || floating!=undefined) urlObj.floating=floating;
		data.currentExercise.addURL(urlObj);
		// v6.4.2.7 You don't need to update the screen at this point
		//view.fillInURLs(data.currentExercise.URLs);
		onExerciseChanged();
	}
	
	// v0.16.1, DL: update video
	function updateExerciseVideo(n:String, mode:String, pos:String) : Void {
		//_global.myTrace("updateExerciseVideo:mode=" + mode);
		data.currentExercise.addVideo(n, mode, pos);
		view.fillInVideos(data.currentExercise.videos);
		onExerciseChanged();
	}
	// v0.16.1, DL: update question audio with question number
	function updateExerciseQuestionAudio(n:String, mode:String, qNo:Number) : Void {
		if (n!=undefined) {
			data.currentExercise.addQuestionAudio(n, mode, qNo);
			if (n=="") {
				view.setAudioCheckbox("Question", false);
			}
		} else {
			data.currentExercise.addQuestionAudio(undefined, mode, qNo);
		}
		onExerciseChanged();
	}
	
	function updateExercise(fieldName:String, qNo:Number, value:String, optionNo:Number, checked:Boolean) {
		var ex = data.currentExercise;
		//value = str_replace(value, "<", "&lt;");
		//value = str_replace(value, ">", "&gt;");
		//_global.myTrace("update value is " + value);
		switch (fieldName) {
		case "question" :
			ex.setQuestion(qNo - 1, value);
			break;
		case "feedback" :
			ex.setFeedback(qNo-1, value);
			break;
		case "hint" :
			ex.setHint(qNo-1, value);
			break;
		case "option" :
			ex.setOption(qNo, optionNo, value, checked);
			break;
		case "answer" :
			ex.setAnswer(qNo, optionNo, value, checked);
			break;
		case "scoreBasedFeedback" :	// v0.16.0, DL
			ex.setScoreBasedFeedback(qNo, value);
			break;
		case "differentFeedback" :	// v0.16.0, DL
			ex.setDifferentFeedback(qNo, optionNo, value);
			break;
		// v6.5.1 Yiu new default gap length check box and slider 
		case "gapLength" :
			ex.setGapLength(qNo - 1, Number(value));
			break;
		// End v6.5.1 Yiu new default gap length check box and slider 
		}
		//debug_show("	", ex);
		onExerciseChanged();
	}
		/* Debug function*/
	function debug_show(tabindex, parentObject): Void {
		var pChild;
		tabindex = tabindex + "	";
		for( pChild in parentObject ){
			_global.myTrace(tabindex + pChild + " : " + parentObject[pChild]);
			if( pChild != "ex" && typeof(parentObject[pChild]) == "object" ) { // ex is self point.
				debug_show(tabindex, parentObject[pChild]);
			}
		}
	}
	/* v0.16.0, DL: change target correctness to true/neutral (for target spotting) */
	function updateExerciseTargetsCorrectness(s:String) : Void {
		var ex = data.currentExercise;
		ex.changeTargetsCorrectness(s);
	}
	// v6.4.1.4, DL: update exercise quiz options
	function updateExerciseQuizOption(b:Boolean, v:String) : Void {
		var ex = data.currentExercise;
		ex.setQuizOption(b, v);
		onExerciseChanged();
	}

	/* 
	*	v6.5.5.10 WZ: functions for question's copy and paste
	*/
	function cutExercise(fieldName:String, qNo:Number){
		var ex = data.currentExercise;
		switch (fieldName){
		case "question" :
			myTrace("Try to start delete question");
			ex.cutQuestion(qNo - 1);
			break;
		}
		onExerciseChanged();
	}
	function copyExercise(fieldName:String, qNo:Number){
		var ex = data.currentExercise;
		switch (fieldName){
		case "question" :
			myTrace("Try to start copy question");
			ex.copyQuestion(qNo - 1);
			break;
		}
	}
	function pasteExercise(fieldName:String, qNo:Number){
		var ex = data.currentExercise;
		switch (fieldName){
		case "question" :
			myTrace("Try to start paste question");
			ex.pasteQuestion(qNo - 1);
			break;
		}
		onExerciseChanged();
	}

	// save exercise
	function onExerciseSave() : Void {
		_global.myTrace("control.onExerciseSave");
		saveExercise("");
		eventAfter = "saveExercise";	// v6.4.1, DL
	}
	function onExerciseBack() : Void {
		if (!data.currentExercise.noChange) {
			view.showPopup("promptSavingExercise");
		} else {
			view.onExerciseBack();
		}
		eventAfter = "backUnit";	// v6.4.1, DL
	}
	
	/* actions on course list */
	// v6.4.3 The button and the right click menu item use the tree to add the interface element, then trigger to here
	// Actually, we should do the XML checking before we add in the interface, so for now make a separate function.
	function addCourseSafe() : Void {
		//myTrace("addCourseSafe");
		// And we need to actually go and create the course
		// v6.4.3 Return the new id from the data function
		//data.addNewCourse();
		var newID:String = data.addNewCourse();
		myTrace("got new ID for course=" + newID);
		xmlUnit.formURL(data.currentCourse.courseFolder, data.currentCourse.subFolder, data.currentCourse.scaffold);
		// Update the tree structure with the new ID
		view.screens.trees.setSelectedID("Course", newID);
		// This will leave us on the tree renaming the new course. This will trigger an event to save with next event
		// saveCourse("addCourseShowMenu");
	}
	function addCourse() : Void {
		_global.myTrace("control.addCourse, off to compareClass");
		// v6.4.2.4 Single product editing doesn't let you add new courses
		// v6.4.3 Yes it does. The 'kit' will now mean that you can only edit this one product with this licence
		//if (errorCheck.passNewCourseCheck()) {				
			var c = new xmlCompareClass(xmlCourse);
			c.loadXML("AddCourse");
		//}
	}
	
	// v6.4.0.1, DL: before letting the user add a course (enter a name)
	// we check if the xml is up-to-date first, which is done by xmlCompareClass
	// then we do the adding
	function onComparedXmlAddCourse(pass:Boolean, newXML:XML) : Void {
		// v6.4.0.1, DL: if not up-to-date, refill data from the newly loaded xml
		_global.myTrace("onComparedXmlAddCourse with pass=" + pass);
		// use the error handling
		//if (!pass) {
		if (errorCheck.passCourseChangedCheck(pass)) {
			if (errorCheck.passMaxCourseCheck()) {	// v0.6.0, DL: error checking
				// v6.4.3 Pull this into a function outside of the error checking
				addCourseSafe();
				//data.addNewCourse();
				//xmlUnit.formURL(data.currentCourse.courseFolder, data.currentCourse.subFolder, data.currentCourse.scaffold);
				
				// v6.4.3. No, we can let the dnd tree do the tree updating
				// v6.4.3 We do need to update the screen, but not from data.Courses
				//view.fillInCourseList(data.Courses);
				//view.addToCourseList(data.Courses);
				//view.onAddCourse();
			}
		} else {
		// v6.4.3 I really think you should stop here, tell the user what happened and ask them to do it again
			// How to stop the tree functions?
			_global.myTrace("got new data:");
			//_global.myTrace(newXML.firstChild.childNodes.toString());
			xmlCourse.replaceXML(newXML);
			//var nodes = newXML.firstChild.childNodes;
			//data.fillInCourses(nodes);
			// v6.4.3 Do you have to do the view.fillInCourseList too?
			//view.fillInCourseList(nodes);
		}
	}
		
	function renameCourse(name:String) : Void {
		// AR v6.4.3 Why aren't we comparingXML here if we do it with add? Surely it should be the same (and delete and move)
		//_global.myTrace("control.renameCourse");
		// v6.4.3 Yes, I should compare, but add course does a compare then it ends up in rename and by then compare fails
		// so for now drop compare on rename
		//var c = new xmlCompareClass(xmlCourse);
		//c.loadXML("RenameCourse");
		//renameName=name;
		//_global.myTrace("renameCourse to " + name);
		data.currentCourse.renameCourse(name);
	}
	function renameCourseFolder() : Void {
		// AR v6.4.3 Why aren't we comparingXML here if we do it with add? Surely it should be the same (and delete and move)
		// Just need to save the xml to file
		// v6.4.3 Yes, I should compare, but renameFolder uses the tree to rename before it comes here anyway. so odd.
		//var c = new xmlCompareClass(xmlCourse);
		//c.loadXML("RenameCourseFolder");
		//_global.myTrace("renameCourseFolder");
		saveCourse();
	}
	// v6.4.0.1, DL: before letting the user delete a course we check if the xml is up-to-date first, which is done by xmlCompareClass
	// then we do the deleting
	function onComparedXmlRenameCourse(pass:Boolean, newXML:XML) : Void {
		// v6.4.0.1, DL: if not up-to-date, refill data from the newly loaded xml
		_global.myTrace("onComparedXmlRenameCourse with pass=" + pass);
		// use the error handling
		//if (!pass) {
		if (errorCheck.passCourseChangedCheck(pass)) {
			data.currentCourse.renameCourse(renameName);
		} else {
			// You have been stopped, so refresh the tree
			xmlCourse.replaceXML(newXML);
		}
	}
	// v6.4.0.1, DL: before letting the user delete a course we check if the xml is up-to-date first, which is done by xmlCompareClass
	// then we do the deleting
	function onComparedXmlRenameCourseFolder(pass:Boolean, newXML:XML) : Void {
		// v6.4.0.1, DL: if not up-to-date, refill data from the newly loaded xml
		_global.myTrace("onComparedXmlRenameCourseFolder with pass=" + pass);
		// use the error handling
		//if (!pass) {
		if (errorCheck.passCourseChangedCheck(pass)) {
			saveCourse();
		} else {
			// You have been stopped, so refresh the tree
			xmlCourse.replaceXML(newXML);
		}
	}
	
	function onDelCourse(index:Number) : Void {
		myTrace("control.onDelCourse");
		if (index!=undefined) {
			// v6.4.3 Check if the course.xml has changed first of all
			var c = new xmlCompareClass(xmlCourse);
			c.loadXML("DelCourse");
			delIndex = index;
			// This now goes in the onCompared event
			//view.showPopup("promptDelCourse");
			
			// v6.4.2, DL: DEBUG - don't care whether it has units or not anymore!
			//if (!data.currentCourse.hasUnits()) {
			//	// v6.4.0.1, DL: check lock before delete lock
			//	//delCourse();
			//	checkLockBeforeDelCourse();
			//} else {
		}
	}
	function onDelCourseFolder(thisNode:XML) : Void {
		// v6.4.3 You can now have a course hiearchy - so if you come here without an ID it means you are going to 
		// delete a course folder
		myTrace("control.onDelCourseFolder");
		// v6.4.3 Check if the course.xml has changed first of all
		var c = new xmlCompareClass(xmlCourse);
		c.loadXML("DelCourseFolder");
		delNode = thisNode;
		// This now goes in the onCompared event
		//view.showPopup("promptDelCourseFolder");
	}
	// v6.4.0.1, DL: before letting the user delete a course we check if the xml is up-to-date first, which is done by xmlCompareClass
	// then we do the deleting
	function onComparedXmlDelCourse(pass:Boolean, newXML:XML) : Void {
		// v6.4.0.1, DL: if not up-to-date, refill data from the newly loaded xml
		_global.myTrace("onComparedXmlDelCourse with pass=" + pass);
		// use the error handling
		//if (!pass) {
		if (errorCheck.passCourseChangedCheck(pass)) {
			view.showPopup("promptDelCourse");
		} else {
			// You have been stopped, so refresh the tree
			xmlCourse.replaceXML(newXML);
		}
	}
	// v6.4.0.1, DL: before letting the user delete a course we check if the xml is up-to-date first, which is done by xmlCompareClass
	// then we do the deleting
	function onComparedXmlDelCourseFolder(pass:Boolean, newXML:XML) : Void {
		// v6.4.0.1, DL: if not up-to-date, refill data from the newly loaded xml
		_global.myTrace("onComparedXmlDelCourseFolder with pass=" + pass);
		// use the error handling
		//if (!pass) {
		if (errorCheck.passCourseChangedCheck(pass)) {
			view.showPopup("promptDelCourseFolder");
		} else {
			// You have been stopped, so refresh the tree
			xmlCourse.replaceXML(newXML);
		}
	}

	function checkLockBeforeDelCourse() : Void {
		myTrace("checkLockBeforeDelCourse " + xmlUnit.XMLfile);
		var action = new actionRun();
		// v6.4.3 I am not really sure that this is the right file to be checking?? It might be, because what you need to check
		// is if anyone is locking the menu.xml for this course. But it doesn't work. I would guess because I don't know the menu.xml filename.
		action.checkLockForDelCourse(xmlUnit.XMLfile);
		delete action;		
	}
	function checkLockBeforeDelCourseFolder() : Void {
		var action = new actionRun();
		// v6.4.3 If this is going to work you need to check the menu.xml locks for each course in the folder/subfolders.
		// For now this is purely an empty function.
		action.checkLockForDelCourseFolder(xmlUnit.XMLfile);
		delete action;		
	}
	function delCourse() : Void {
		myTrace("control.delCourse");
		if (delIndex <> undefined) {
			data.delCourse(delIndex);
		}
		// v6.4.3 We do need to update the screen, but not from data.Courses
		//view.fillInCourseList(data.Courses);
		view.screens.delCourseFromList();			
		delIndex = -1;
		saveCourse();
	}
	// v6.4.3 bigger deleting
	function delCourseFolder() : Void {
		myTrace("control.delCourseFolder");
		// v6.4.3 You can now have a course hiearchy - so if you come here without an ID it means you are going to 
		// delete a course folder
		if (delNode <> undefined) {
			// So need to get all the course IDs within this folder and delete each one
			data.delCourseFolder(delNode);
		}
		// v6.4.3 We do need to update the screen, but not from data.Courses
		//view.fillInCourseList(data.Courses);
		view.screens.delCourseFromList();			
		delNode = undefined;
		saveCourse();
	}

	// v6.4.3 Old functions superseeded by dnd tree
	/*
	function moveCourse(oldIndex:Number, newIndex:Number) : Void {
		data.moveCourse(oldIndex, newIndex);
		data.currentCourse = data.Courses[newIndex];	// v0.5.2, DL: debug - reset current course
		view.fillInCourseList(data.Courses);
		view.selectCourseByIndex(newIndex);
		saveCourse();	// v0.16.1, DL: we cannot save here as it'll overwrite the courses' content
	}
	*/
	// v6.4.3 Now, all we need to do is call saveCourse. The dnd tree takes care of the XML structure and the Courses
	// array will not need to change as it is order indifferent.
	function moveCourse() : Void {
		_global.myTrace("control.move course");
		saveCourse();
	}
	
	/* actions on unit list */
	// v6.4.0.1, DL: split into 2 functions to make sure we're adding to the most up-to-date file
	function addUnit() : Void {
		var c = new xmlCompareClass(xmlUnit);
		c.loadXML("AddUnit");
	}
	
	function onComparedXmlAddUnit(pass:Boolean, newXML:XML) : Void {
		// AR v6.4.2.5a Change so that if the menu has changed you will stop the action and alert them. Much safer.
		//if (!pass) {
		//	var nodes = newXML.firstChild.childNodes;
		//	data.currentCourse.fillInUnits(nodes);
		//}
		if (errorCheck.passMenuChangedCheck(pass)) {		
			if (errorCheck.passMaxUnitCheck()) {	// v0.6.0, DL: error checking
				data.currentCourse.addNewUnit();
				view.fillInUnitList(data.currentCourse.Units);
				view.clearExerciseList();
				view.onAddUnit();
			}
		} else {
			// You could just use the XML you have read from the compare - or you could simply start again
			//var nodes = newXML.firstChild.childNodes;
			//data.currentCourse.fillInUnits(nodes);
			//view.fillInUnitList(data.currentCourse.Units);
			loadUnitXML();
		}
	}

	// v6.4.3 This is not used from the menu screen, which uses onDoubleClickingItemOnList
	function renameUnit(name:String) : Void {
		data.currentUnit.renameUnit(name);
	}
	
	function onComparedXmlRenameUnit(pass:Boolean, newXML:XML) : Void {
		// AR v6.4.2.5a Change so that if the menu has changed you will stop the action and alert them. Much safer.
		//if (!pass) {
		//	var nodes = newXML.firstChild.childNodes;
		//	data.currentCourse.fillInUnits(nodes);
		//}		
		if (errorCheck.passMenuChangedCheck(pass)) {
			view.onRenameUnit();
		} else {
			// You could just use the XML you have read from the compare - or you could simply start again
			//var nodes = newXML.firstChild.childNodes;
			//data.currentCourse.fillInUnits(nodes);
			//view.fillInUnitList(data.currentCourse.Units);
			loadUnitXML();
		}
	}
	
	function onDelUnit(index:Number) : Void {
		if (index!=undefined) {
			delIndex = index;
			if (!data.currentUnit.hasExercises()) {
				// v6.4.0.1, DL: check if the file is locked
				//delUnit();
				checkLockBeforeDelUnit();
			} else {
				view.showPopup("promptDelUnit");
			}
		}
	}
	function checkLockBeforeDelUnit() : Void {
		var action = new actionRun();
		action.checkLockMenuForDelUnit(xmlUnit.XMLfile);
		delete action;		
	}
	function delUnit() : Void {
		data.currentCourse.delUnit(delIndex);
		
		// v6.4.1, DL: debug - should select the 1st unit for refreshing of exercise list
		if (data.currentCourse.Units.length>0) {
			data.currentUnit = data.currentCourse.Units[0];
		} else {
			data.currentUnit = undefined;
		}
		
		view.fillInUnitList(data.currentCourse.Units);
		view.clearExerciseList();
		delIndex = -1;
		// v6.4.0.1, DL: delete unit no need to save course now
		//saveCourse();
		saveUnit("");
	}
	
	function moveUnitUp(index:Number) : Void {
		//myTrace("moveUnitUp");
		if (index > 0) {
			data.currentCourse.swapUnits(index-1, index);
			view.fillInUnitList(data.currentCourse.Units);
			view.selectUnitByIndex(index-1);
		}
		//view.onMoveUnitUp();
		saveUnit("");
	}
	
	function moveUnitDown(index:Number) : Void {
		//myTrace("moveUnitDown");
		if (index < data.getNoOfUnits() - 1) {
			data.currentCourse.swapUnits(index, index+1);
			view.fillInUnitList(data.currentCourse.Units);
			view.selectUnitByIndex(index+1);
		}
		//view.onMoveUnitDown();
		saveUnit("");
	}

	// v6.4.3 We need to add the checking for unit changing here as well
	function moveUnit(oldIndex:Number, newIndex:Number) : Void {
		// This will move to the onCompared event
		//myTrace("moveUnit from " + oldIndex + " to " + newIndex);
		/*
		data.currentCourse.moveUnit(oldIndex, newIndex);
		data.currentUnit = data.currentCourse.Units[newIndex];	// v0.5.2, DL: debug - reset current unit
		view.fillInUnitList(data.currentCourse.Units);
		view.selectUnitByIndex(newIndex);
		view.fillInExerciseList(data.currentUnit.Exercises);
		// v6.4.0.1, DL: move unit no need to save course now
		//saveCourse();
		saveUnit("");
		*/
		this.moveIndexFrom = oldIndex;
		this.moveIndexTo = newIndex;
		var c = new xmlCompareClass(xmlUnit);
		c.loadXML("MoveUnit");
	}
	
	function onComparedXmlMoveUnit(pass:Boolean, newXML:XML) : Void {
		if (errorCheck.passMenuChangedCheck(pass)) {		
			var oldIndex = this.moveIndexFrom;
			var newIndex = this.moveIndexTo;
			myTrace("onMoveUnit from " + oldIndex + " to " + newIndex);
			data.currentCourse.moveUnit(oldIndex, newIndex);
			data.currentUnit = data.currentCourse.Units[newIndex];	// v0.5.2, DL: debug - reset current unit
			view.fillInUnitList(data.currentCourse.Units);
			view.selectUnitByIndex(newIndex);
			view.fillInExerciseList(data.currentUnit.Exercises);
			// v6.4.0.1, DL: move unit no need to save course now
			//saveCourse();
			saveUnit("");
		} else {
			// You could just use the XML you have read from the compare - or you could simply start again
			//var nodes = newXML.firstChild.childNodes;
			//data.currentCourse.fillInUnits(nodes);
			//view.fillInUnitList(data.currentCourse.Units);
			loadUnitXML();
		}
	}
	
	
	
	/* actions on exercise list */
	function addExercise() : Void {
		//myTrace("control.addExercise");
		if (errorCheck.passSelectedUnitCheck()) {	// v0.6.0, DL: error checking
			if (errorCheck.passMaxExerciseCheck()) {	// v0.6.0, DL: error checking
				// AR v6.4.2.5 Don't save the course - simply start the new exercise process
				//saveCourse("showExTypeScreen");
				view.setupPBar("showExTypeScreen");
				view.setProgressOnPBar(2, 2);
			}
		}
		// AR v6.4.2.5 Nothing has changed in the menu yet - you might not save the exercise.
		//onMenuChanged(); 	//v6.4.2.2, RL: this should change the menu.xml;
	}
	
	function renameExercise(name:String) : Void {
		data.currentExercise.renameExercise(name);
		//myTrace("rename exercise now - onMenuChanged");
		onMenuChanged(); 	//v6.4.2.2, RL: this should change the menu.xml;
	}
	
	function onDelExercise(index:Number) : Void {
		if (index!=undefined) {
			delIndex = index;
			view.showPopup("promptDelExercise");
		}
	}
	function delExercise() : Void {
		data.currentUnit.delExercise(delIndex);
		view.fillInExerciseList(data.currentUnit.Exercises);
		delIndex = -1;
		// v6.4.0.1, DL: save exercise no need to save course now
		//saveCourse();
		//myTrace("delete exercise now - onMenuChanged");
		//onMenuChanged(); 	//v6.4.2.2, RL: this should change the menu.xml;
		saveUnit("");
	}
	
	function moveExerciseUp(index:Number) : Void {
		if (index > 0) {
			data.currentUnit.swapExercises(index-1, index);
			// v6.4.2.5 Move this inside the condition, no need to save if there was no selected item
			saveUnit("");
			view.fillInExerciseList(data.currentUnit.Exercises);
			view.selectExerciseByIndex(index-1);
		}
		//view.onMoveExerciseUp();
		//myTrace("moveUp exercise now - onMenuChanged");
		//onMenuChanged(); 	//v6.4.2.2, RL: this should change the menu.xml;
	}
	
	function moveExerciseDown(index:Number) : Void {
		if (index < data.getNoOfExercises() - 1) {
			data.currentUnit.swapExercises(index, index+1);
			// v6.4.2.5 Move this inside the condition, no need to save if there was no selected item
			saveUnit("");
			view.fillInExerciseList(data.currentUnit.Exercises);
			view.selectExerciseByIndex(index+1);
		}
		//view.onMoveExerciseDown();
		//myTrace("moveDown exercise now - onMenuChanged");
		//onMenuChanged(); 	//v6.4.2.2, RL: this should change the menu.xml;
	}
	
	function moveExercise(oldIndex:Number, newIndex:Number) : Void {
		data.currentUnit.moveExercise(oldIndex, newIndex);
		data.currentExercise = data.currentUnit.Exercises[newIndex];	// v0.5.2, DL: debug - reset current exercise
		view.fillInExerciseList(data.currentUnit.Exercises);
		view.selectExerciseByIndex(newIndex);
		// v6.4.0.1, DL: move exercise no need to save course now
		//saveCourse();
		//myTrace("move exercise now - onMenuChanged");
		//onMenuChanged(); 	//v6.4.2.2, RL: this should change the menu.xml;
		saveUnit("");
	}
	
	// v0.8.1, DL: move exercise to another unit by drag & drop
	function moveExerciseToUnit(exIndex:Number, oldUnitIndex:Number, newUnitIndex:Number) : Void {
		if (oldUnitIndex!=newUnitIndex) {
			// set current unit to new unit
			data.currentUnit = data.currentCourse.Units[newUnitIndex];
			view.selectUnitByIndex(newUnitIndex);
			// fill in exercise list
			view.fillInExerciseList(data.currentUnit.Exercises);
			if (errorCheck.passMaxExerciseCheck()) {
				// add to new unit
				/*_global.myTrace("in move exercise to unit");
				_global.myTrace(exIndex);
				_global.myTrace(oldUnitIndex);
				_global.myTrace(newUnitIndex);*/
				data.currentCourse.Units[newUnitIndex].addMovedExercise(data.currentCourse.Units[oldUnitIndex].Exercises[exIndex]);
				// delete from old unit
				data.currentCourse.Units[oldUnitIndex].delExercise(exIndex);
				// v6.4.0.1, DL: move exercise no need to save course now
				//saveCourse();
				//myTrace("moveToUnit exercise now - onMenuChanged");
				//onMenuChanged(); 	//v6.4.2.2, RL: this should change the menu.xml;
				saveUnit("");
			}
			// fill in exercise list
			view.fillInExerciseList(data.currentUnit.Exercises);
		}
	}
	
	// v6.4.3 on clicking on trees
	// This should really be called editCourse
	function onDoubleClickingOnTree(selectedItem:XML) : Void {
		var thisID = selectedItem.attributes.id;
		myTrace("course id=" + thisID);
		// v6.4.3 Only take action if this is a real course, not a folder
		if (thisID <> undefined) {
			// v0.16.0, DL: debug - clear unit & exercise lists before loading
			// this is done in fillInUnitList() & fillInExerciseList() but it's better to clear them earlier
			view.clearUnitList();
			view.clearExerciseList();
			// show unit screen after loading xml
			showUnitScreenAfterLoad = true;
			// change current course
			//data.setCurrentCourse(dg.selectedItem.id);
			data.setCurrentCourse(thisID);
			myTrace("currentCourse.name=" + data.currentCourse.name);
			// v6.4.0.1, DL: release the course file first, then load unit file
			/*// load unit XML
			xmlUnit.formURL(data.currentCourse.courseFolder, data.currentCourse.subFolder, data.currentCourse.scaffold);
			xmlUnit.loadXML();*/
			// v6.4.1, DL: debug - reset current unit
			data.currentUnit = undefined;
			releaseCourseFileToMenu();
		}
	}
	// on clicking on lists
	function onDoubleClickingItemOnList(dg) : Void {
		if (dg.selectedItem!=undefined) {
			switch (dg._name) {
			// v 6.4.3 The course is not a list anymore
			/*
				case "dgCourse" :
				// Very clumsy
				var thisID = dg.selectedItem.id;
				myTrace("control.onDoubleClicking on " + dg._name);
				// v0.16.0, DL: debug - clear unit & exercise lists before loading
				// this is done in fillInUnitList() & fillInExerciseList() but it's better to clear them earlier
				view.clearUnitList();
				view.clearExerciseList();
				// show unit screen after loading xml
				showUnitScreenAfterLoad = true;
				// change current course
				//data.setCurrentCourse(dg.selectedItem.id);
				data.setCurrentCourse(thisID);
				// v6.4.0.1, DL: release the course file first, then load unit file
				// load unit XML
				//xmlUnit.formURL(data.currentCourse.courseFolder, data.currentCourse.subFolder, data.currentCourse.scaffold);
				//xmlUnit.loadXML();
				// v6.4.1, DL: debug - reset current unit
				data.currentUnit = undefined;
				releaseCourseFileToMenu();
				break;
			*/
			case "dgUnit" :
				// change current unit
				data.setCurrentUnit(dg.selectedItem.unit);
				// rename unit
				// v6.4.0.1, DL: load the most up-to-date menu xml before rename unit
				// response will call onComparedXmlRenameUnit()
				//view.onRenameUnit();
				var c = new xmlCompareClass(xmlUnit);
				c.loadXML("RenameUnit");
				break;
			case "dgExercise" :
				// change current exercise
				data.setCurrentExercise(dg.selectedItem.id);
				//_global.myTrace("currentExercise.enabledFlag=" + data.currentExercise.enabledFlag);
				// load exercise XML
				//xmlExercise.formURL(data.currentCourse.courseFolder, data.currentCourse.subFolder, data.currentExercise.fileName);
				// v0.4, DL: not to load now, wait until course & units are saved
				//xmlExercise.loadXML();
				//saveCourse("showExercise");
				// v6.4.1.4, DL: check enabledFlag first
				if (errorCheck.passExerciseEnabledFlagCheck()) {
					// v6.4.0.1, DL: no saving anymore, release the menu.xml
					// if so, tell the user; if not, open it
					checkLockOnExercise();
				}
				break;
			case "dgOption" :
				view.onRenameOption();
				break;
			}
		}
	}
	
	function onSingleClickingItemOnList(dg) : Void {
		if (dg.selectedItem!=undefined) {
			switch (dg._name) {
			case "dgCourse" :
				// AR v6.4.2.5a Remove all this action
				/*
				// change current course
				data.setCurrentCourse(dg.selectedItem.id);
				// don't show unit screen after loading xml - AR huh?
				showUnitScreenAfterLoad = false;
				// load unit XML
				// AR v6.4.2.5a This just creates xmlUnit.xmlFile string only. I can't see why you do it. Any of it in this click action!
				xmlUnit.formURL(data.currentCourse.courseFolder, data.currentCourse.subFolder, data.currentCourse.scaffold);
				// v0.16.0, DL: debug - better not load XML otherwise might crash with double click's loading
				//xmlUnit.loadXML();
				*/
				break;
			case "dgUnit" :
				// change current unit
				data.setCurrentUnit(dg.selectedItem.unit);
				// fill in exercise list
				view.fillInExerciseList(data.currentUnit.Exercises);
				break;
			case "dgExercise" :
				// change current exercise
				data.setCurrentExercise(dg.selectedItem.id);
				break;
			}
		}
	}
	
	// on finish editing on lists
	function onFinishRename(dg, index) : Void {
		switch (dg._name) {
		// v6.4.3 But you can't rename courses!
		// Except that this is used when you have the initial data edit box to type in the name
		// Now skip that as adding a new course takes you directly to the menu screen where you can rename it.
		// This is much neater I think. Maybe the course name should be focussed and selected when you get to the next screen?
		case "treeCourse" :
			// change current course
			myTrace("control.onFinishRename, id=" + dg.selectedNode.attributes.id);
			//data.setCurrentCourse(dg.selectedNode.id);
			// v6.4.3 Not used
			//data.setCurrentCourse(dg.selectedNode.attributes.id);
			
			// v6.4.1.4, DL: DEBUG - network version student side cannot handle apostrophe in course name
			// v6.4.2 AR: fixed in student side and RM
			//if (__local) {
			//	dg.selectedItem.label = _global.replace(dg.selectedItem.label, "'", "");
			//}
			
			// rename course
			//_global.myTrace("control.onFinishRename");
			//renameCourse(dg.selectedItem.label);
			// save course
			// v6.4.3 Not used
			//saveCourse("addCourseShowMenu");
			break;
		case "dgUnit" :
			// change current unit
			data.setCurrentUnit(dg.selectedItem.unit);
			if (dg.selectedItem.label!=undefined && dg.selectedItem.label!="") {
				// rename unit
				renameUnit(dg.selectedItem.label);
				// fill in exercise list
				//view.fillInExerciseList(data.currentUnit.Exercises);
				
			// v0.5.2, DL: entered empty string for new unit name, so we've gotta delete that unit
			} else {
				delIndex = index;
				// v6.4.0.1, DL: check if the file is locked
				delUnit();
			}
			// save course
			// v6.4.0.1, DL: edit unit name no need to save course now
			//saveCourse();
			saveUnit("");
			break;
		case "dgExercise" :
			// change current exercise
			data.setCurrentExercise(dg.selectedItem.id);
			// rename exercise
			renameExercise(dg.selectedItem.label);
			break;
		case "dgOption" :
			if (dg.selectedItem.label!=undefined && _global.trim(dg.selectedItem.label)!="") {
				// update options in data
				view.updateOptionsList();
			} else {
				// remove the empty option (update afterwards)
				view.deleteSelectedOption();
			}
			break;
		}
	}
	
	// error in loading (exercise)
	function onLoadingError() : Void {
		view.showPopup("loadingError");
	}
	
	// error in saving
	function onSavingError() : Void {
		view.showPopup("savingError");
	}
	
	// connection fail
	function onConnFail() : Void {
		view.showPopup("connFail");
		myTrace("Test connection to server: Failed");
	}
	
	// v0.16.1, DL: prompt the user to overwrite locked file
	function promptOverwrite(file:String, user:String) : Void {
		view.showPopup("promptOverwrite"+file, user);
	}
	// gh#922 
	function promptTryLater(file:String) : Void {
		//myTrace("prompt try later " + file + " please");
		view.showPopup("promptTryLater"+file, null);
	}
	
	// on popup button click
	function onPopupResponse(popupReason:String, btn:String) {
		switch (popupReason) {
		case "licenceError" :
			myTrace("Error in processing licence.ini.");
			byebye();
			break;
		// v6.4.3 New errors
		case "licenceAltered" :
		case "licenceExpired" :
		case "noLicences" :
			myTrace("The licence blocks your access");
			byebye();
			break;
		case "blockAccess" :
			myTrace("Blocked access: Serial number not match.");
			byebye();
			break;
		case "unregisteredUser" :
			myTrace("No registration date available in licence.ini.");
			byebye();
			break;
		case "loadingError" :
			myTrace("File cannot be loaded.");
			break;
		case "connFail" :
			myTrace("No response from server.");
			byebye();
			break;
		case "promptDelCourse" :
			if (btn=="yes") {
				// v6.4.0.1, DL: check if the file is locked
				//delCourse();
				checkLockBeforeDelCourse();
			}
			break;
		// v6.4.3 Bigger deleting
		case "promptDelCourseFolder" :
			if (btn=="yes") {
				// v6.4.0.1, DL: check if the file is locked
				//delCourse();
				checkLockBeforeDelCourseFolder();
			}
			break;
		case "promptDelUnit" :
			if (btn=="yes") {
				// v6.4.0.1, DL: check if the file is locked
				//delUnit();
				checkLockBeforeDelUnit();
			}
			break;
		case "promptDelExercise" :
			if (btn=="yes") {
				// v6.4.0.1, DL: check if the file is locked
				//delExercise();
				var ex = data.currentUnit.Exercises[delIndex];
				xmlExercise.formURL(data.currentCourse.courseFolder, data.currentCourse.subFolder, ex.fileName);
				var action = new actionRun();
				action.checkLockExerciseForDelExercise(xmlExercise.XMLfile);
				delete action;
			}
			break;
		case "promptExit" :	// v6.4.0.1, DL
			if (btn=="yes") {
				byebye();
			}
			break;
		case "promptExitSaving" :
			if (btn=="yes") {
				saveCourse("byebye");
			} else if (btn=="no") {
				byebye();
			}
			break;
		case "promptExitSavingExercise" :
			if (btn=="yes") {
				saveExercise("Exit");
				saveUnit(""); //v6.4.2.2 also check if there's any change of menu.xml
				eventAfter = "saveExerciseExit";
			} else if (btn=="no") {
				byebye();
			}
			break;
		case "promptSavingExercise" :
			if (btn=="yes") {
				//myTrace("yes btn, so saveExericse(backunit)");
				//("saveFiles");
				// AR v6.4.2.5 use consistent case
				//saveExercise("BackUnit");
				saveExercise("backUnit");
			// AR v6.4.2.5 Add cancel as an option to this request
			} else if (btn=="no") {
				//myTrace("no btn, so onExerciseBack");
				// v6.4.2 AR - why are you doing anything here? The user has just said they don't want to save
				// the exercise, so we shouldn't be saving anything. Well, you do need to unlock the file, so 
				// I think we should go through the process as it checks to see if xml is different and doesn't 
				// bother saving exercise if not. But PHP has a bug that adds exercise to menu anyway.
				// v6.4.0.1, DL: debug - if user chooses not to update, copy the caption from xml back to data
				data.currentExercise.caption = xmlExercise.firstChild.attributes.name;				
				view.onExerciseBack();
			} else {
				//myTrace("do nothing");
			}
			break;
		case "weblink" :
			if (btn=="ok") {
				_global.NNW.screens.setWebLink();
			}
			break;
		case "promptOverwriteCourse" :
			if (btn=="yes") {
				writeCourseXML();
			}
			break;
		case "promptOverwriteExercise" :
			if (btn=="yes") {
				writeExerciseXML();
			}
			break;
		// gh#xxx
		case "promptTryLaterExercise" :
			break;
		
		case "importError" :
			if (btn=="ok") {
				// reload the course.xml
				xmlCourse.loadXML();
			}
			break;
		case "promptReset" :
			if (btn=="yes") {
				reset(true);
			}
		}
	}
	
	// v0.9.0, DL: show tip when selecting exercise type
	function showTip(t:String, x:Number, y:Number) : Void {
		errorCheck.showExerciseTypeTip(t, x, y);
	}
	
	// v0.9.0, DL: hide tip when selecting exercise type
	function hideTip(t:String) : Void {
		errorCheck.hideExerciseTypeTip(t);
	}
	
	// v0.13.0, DL: raise max. no. of question error
	function raiseMaxNoOfQuestionsError() : Void {
		errorCheck.raiseMaxNoOfQuestionsError(_lite);
	}
	
	// v6.4.1.4, DL: reset a Clarity's course
	function reset(run:Boolean) : Void {
		if (run) {
			// set current unit to undefined, so that it'll be set to the first unit after reset
			data.currentUnit = undefined;
			
			// reset course by editClarityPrograms class
			var c = data.currentCourse;
			//v6.4.4,RL: if MGS is used, no need to do this.
			//edit.resetCourse(c.scaffold, _global.addSlash(c.courseFolder)+c.subFolder, _global.addSlash(c.editedCourseFolder)+c.subFolder);
		} else {
			view.showPopup("promptReset");
		}
	}
	
	// v6.4.3 A function to save a file (using MDM), triggered by an event. Originally came from XMLFunc, but also used for import and export
	// so should be in control as not just an XML function. Used because you need to release the XML before writing, or something. It doesn't
	// do any kind of failure reporting.
	// v6.4.2.5 This save fails to save Chinese characters correctly on Ellen's and Kenix's computers if I run with ZINC 2.5.0.21 or .27
	// it seems to be fine with .16
	//function onSaveFile(thisFile:String, contents:String) : Void {
	// v6.4.2.7 Add new object for broadcasting success
	function onSaveFile(thisFile:String, contents:String, xmlFuncObj:Object) : Void {
		// set attributes of file to be writable
		var attrib = "-R";
		if (mdm.System.winVerString.indexOf("98")>0) {
			myTrace("onSaveFile using " + mdm.System.winVerString + ":" + thisFile);		
			mdm.FileSystem.saveFile(thisFile, contents);
		} else {
			myTrace("onSaveFileUnicode using " + mdm.System.winVerString + ":" + thisFile);		
			mdm.FileSystem.saveFileUnicode(thisFile, contents);	
		}
		mdm.FileSystem.setFileAttribs(thisFile, attrib);
		
		// v6.4.2.7 After saving a file, tell the object that asked you to do it to broadcast success
		if (xmlFuncObj <> undefined) {
			//_global.myTrace("control.onSaveFile.broadcast.onSavingSuccess");
			xmlFuncObj.dispatchEvent({type:"onSavingSuccess"});
		}
	}
	// v6.4.3 A function to save a file, triggered by an event
	// Need to work out how to call several of these quite quickly - need an array of interval IDs 
	// or some much smarter event handler. And you do need this on exit when you rapidly delete all the lock files.
	function onDeleteFile(thisFile:String) : Void {
		//clearInterval(this.mdmInterval);
		//var thisFile = this.mdmFileName;
		//var contents = this.mdmFileContents;
		myTrace("onDeleteFile " + thisFile);		
		if (mdm.System.winVerString.indexOf("98")>0) {
			mdm.FileSystem.deleteFile(thisFile);
		} else {
			mdm.FileSystem.deleteFileUnicode(thisFile);
		}
	}
}
