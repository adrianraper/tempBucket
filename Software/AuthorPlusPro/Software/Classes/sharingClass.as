import Classes.xmlUpdateUnitClass;

class Classes.sharingClass {
	
	var control:Object;
	
	// v0.16.1, DL: export tree XML
	var exportTree:XML;
	// v0.16.1, DL: import tree XML
	var importTree:XML;
	// v6.4.1, DL: share base for export/import
	// if in course screen, export works for all courses and import means import selected courses
	// if in menu screen, export works for that course only and import means import selected units
	var shareBase:String;
	
	// v6.4.1.3, DL: variables used in loading menu.xml and exercises xml files
	var treeDpXml:XML;
	var menuPaths:Array;
	var exPaths:Array;
	var menuCnt:Number;
	var exCnt:Number;
	var action:String;
	
	var menuXml:xmlUpdateUnitClass;

	// v6.4.2.5 A new ZIP extension
	//var zincZIP:Zip;	
	// v6.4.2.5 For use with zincZIP
	//var exporting:Object;
	
	function sharingClass(c:Object) {
		control = c;
		
		exportTree = new XML();
		importTree = new XML();
		// v6.4.3 We always import directly into one course now
		//shareBase = "course";
		shareBase = "menu";
		// v6.4.2.5 A new ZIP extension
		//zincZIP = new Zip();
		
		menuXml = new xmlUpdateUnitClass(this);
	}
	
	function myTrace(s:String) : Void {
		_global.myTrace(s);
	}
	
	function readAllXml() {
		myTrace("readAllXML in sharing class");
		exportTree = new XML();
		if (control.__server) {
			var x1 = new XML();
			x1.master = this;
			x1.onLoad = function(success) {
				_global.myTrace("got XML back " + this.firstChild.nodeName);
				//_global.myTrace("got XML back " + this.toString());
				if (success&&this.firstChild.nodeName=="courseList") {

					if (this.firstChild.hasChildNodes()) {
						//_global.myTrace("got courses");
						// v6.4.0.1, DL: debug - should only show the currently selected course if in menu screen
						// v6.4.3 Only one course will come back now
						/*
						if (this.master.shareBase=="menu") {
							for (var i=this.firstChild.childNodes.length-2; i>=0; i--) {
								var courseNode = this.firstChild.childNodes[i];
								//_global.myTrace("node=" + courseNode.toString());
								var attr = courseNode.attributes;
								if (attr.id!=this.master.control.data.currentCourse.id) {
									courseNode.removeNode();
								} else {
									//_global.myTrace("keep course node " + courseNode.toString());
								}
							}
						}
						*/
						// v6.4.2.1 At this point you have XML read from file - so you need to unescape some attributes
						// before you put it into the tree. 
						// v6.5.1 Double check??
						//if (this.firstChild.hasChildNodes()) {
							for (var i in this.firstChild.childNodes) {
								var courseNode = this.firstChild.childNodes[i];
								//_global.myTrace("courseNode=" + courseNode.toString());
								var attr = courseNode.attributes;
								for (var j in attr) {
									//_global.myTrace("sharing.readAll course." + j + "=" + attr[j]);
									attr[j] = unescape(attr[j]);
								}
								// But that is just at the course level - you need to go deeper to unit level as well
								if (courseNode.hasChildNodes()) {
									for (var k in courseNode.childNodes) {
										var unitNode = courseNode.childNodes[k];
										var attr = unitNode.attributes;
										for (var j in attr) {
											attr[j] = unescape(attr[j]);
										}
										// and to the exercise level
										if (unitNode.hasChildNodes()) {
											for (var m in unitNode.childNodes) {
												var exNode = unitNode.childNodes[m];
												var attr = exNode.attributes;
												for (var j in attr) {
													attr[j] = unescape(attr[j]);
												}
											}
										}
									}
								}
							}
						//}						
						// clone a copy in export tree for use
						this.master.exportTree = this.cloneNode(true);
						// remove the medias node
						this.firstChild.lastChild.removeNode();
						// move the courses nodes up to document
						for (var i=0; i<this.firstChild.childNodes.length; i++) {
							this.appendChild(this.firstChild.childNodes[i].cloneNode(true));
						}
						// remove the courseList node
						this.firstChild.removeNode();
						
					} else {
						_global.myTrace("no courses!");
						/*_global.myTrace("no courses for export");
						this.master.control.view.showPopup("noCoursesForExportError");*/
					}
					
					// now we can fill in the XML to the tree - why is exportTree not traceable??
					//_global.myTrace("tree is " + this);
					this.master.control.view.fillInExportTreeDataProvider(this);
				} else {
					_global.myTrace("cannot load xml files from course.xml");
					this.master.control.view.showPopup("loadCoursesForExportError");
				}
			}
			// v6.4.1, DL: if inside menu screen, share base set to menu
			shareBase = (control.view.screens.scnUnit._visible) ? "menu" : "course";
			
			// v6.4.2.1 AR instead of just showing the mask, add the progress bar in
			//control.view.showMask();
			//myTrace("start pbar from sharingClass");
			control.view.setupPBar("sharing");
			// By the time you get back to the XML onLoad above, you have practically finished the action
			// it seems to be the actual readCourses in scripting that takes time. Can you call back from
			// scripting to the progress bar?
			
			// v6.4.1.2, DL: prepare to add PHP scripting
			if (control.login.licence.scripting.toLowerCase()=="php") {
				var readCoursesXmlPage:String = control.paths.serverPath+"/readCoursesXML.php";
			} else {
				var readCoursesXmlPage:String = control.paths.serverPath+"/readCoursesXML.asp";
			}
			// v6.4.2.6 If you are running a script related to files, you need userDataPath for new getRootDir 
			var udp = _global.NNW.paths.userDataPath;
			// v6.4.3 The scripts will read every course, unit and exercise into the return, which we then always
			// weed out to get the current course. So pass the current course id to make it so much better.
			//x1.load(readCoursesXmlPage+"?prog=NNW&path="+control.xmlCourse.XMLfile);
			//x1.load(readCoursesXmlPage+"?prog=NNW&path="+control.xmlCourse.XMLfile+"&userDataPath="+udp);
			// v6.4.3 Also pass scaffold and subFolder so that you don't need to read course.xml at all.
			// If we are working in an MGS, then the course.xml is from MGS. But we might need to copy some original exercises, so need to pass
			// the original path too.
			//x1.load(readCoursesXmlPage+"?prog=NNW&path="+control.xmlCourse.XMLfile+"&userDataPath="+udp+"&courseID=" + control.data.currentCourse.id);
			//control.data.originalContentFolder = "/Fixbench/Content/MyCanada";
			x1.load(readCoursesXmlPage+"?prog=NNW&path="+control.xmlCourse.XMLfile+"&userDataPath="+udp+
										"&action=export"+
										"&originalContentFolder=" + _global.NNW.paths.content+
										"&courseName=" + escape(control.data.currentCourse.name)+
										"&courseID=" + control.data.currentCourse.id+
										"&scaffold=" + control.data.currentCourse.scaffold+
										"&subFolder=" + control.data.currentCourse.subFolder);
			myTrace(readCoursesXmlPage+"?prog=NNW&path="+control.xmlCourse.XMLfile+"&userDataPath="+udp+
										"&action=export"+
										"&originalContentFolder=" + _global.NNW.paths.content+
										"&courseName=" + escape(control.data.currentCourse.name)+
										"&courseID=" + control.data.currentCourse.id+
										"&scaffold=" + control.data.currentCourse.scaffold+
										"&subFolder=" + control.data.currentCourse.subFolder);
			//myTrace(readCoursesXmlPage+"?prog=NNW&path="+control.xmlCourse.XMLfile);
			
		// v6.4.1.3
		} else {
			treeDpXml = new XML();
			menuPaths = new Array();
			exPaths = new Array();
			menuCnt = 0;
			exCnt = 0;
			action = "export";
			
			var x2 = new XML();
			x2.master = this;
			// v6.4.3 No longer read course.xml, just build it for the one course we are in
			/*
			x2.onLoad = function(success) {
				this.xmlDecl = '<?xml version="1.0" encoding="UTF-8"?>';

				// v6.4.3 You need to recurse for course trees until you match the course ID
				if (success&&this.firstChild.nodeName=="courseList") {
					if (this.firstChild.hasChildNodes()) {
						// v6.4.0.1, DL: debug - should only show the currently selected course if in menu screen
						if (this.master.shareBase=="menu") {
							for (var i=this.firstChild.childNodes.length-2; i>=0; i--) {
								var courseNode = this.firstChild.childNodes[i];
								//_global.myTrace("node=" + courseNode.toString());
								var attr = courseNode.attributes;
								if (attr.id!=this.master.control.data.currentCourse.id) {
									courseNode.removeNode();
								} else {
									_global.myTrace("keep course node " + courseNode.toString());
									// v6.4.2.5 There can only be one course in menu screen
									break;
								}
							}
						}
						var courseList = this.firstChild.childNodes;
						
						// v6.4.0.1, DL: debug - should only show the currently selected course if in menu screen
						// v6.4.2.3 Isn't this duplicating the loop above? Yes it is!
						if (this.master.shareBase=="menu") {
							for (var i=courseList.length-1; i>=0; i--) {
								var courseNode = courseList[i];
								if (courseNode.attributes.id!=this.master.control.data.currentCourse.id) {
									courseNode.removeNode();
								}
							}
						}
						
						// v6.4.2.1 At this point you have XML read from file - so you need to unescape some attributes
						// before you put it into the tree. 
						for (var i=0; i<courseList.length; i++) {
							var courseNode = courseList[i];
							var attr = courseNode.attributes;
							//attr.label = attr.name;
							attr.label = unescape(attr.name);
							// How am I getting the unit and exercise names from .name into .label (I need to unescape them)
							attr.check = "2";
							attr.folderPath = _global.getPath(this.master.control.xmlCourse.XMLfile);
							_global.myTrace("set folderPath=" + attr.folderPath);
							// v6.4.2.6 add slash for courseFolder
							attr.filePath = _global.addSlash(attr.folderPath)+_global.addSlash(attr.courseFolder)+_global.addSlash(attr.subFolder)+attr.scaffold;
							this.master.menuPaths.push(attr.filePath);
						}
						//_global.myTrace("node to tree=" + this.firstChild.toString());
						
						// clone a copy in export tree for use
						this.master.exportTree.appendChild(this.firstChild.cloneNode(true));
						
						// move the courses nodes to treeDpXml
						for (var i=0; i<courseList.length; i++) {
							this.master.treeDpXml.appendChild(courseList[i].cloneNode(true));
						}
						
					} else {
						//_global.myTrace("no courses for export");
						//this.master.control.view.showPopup("noCoursesForExportError");
					}
					
					// load menu files
					this.master.loadMenuFiles();
				} else {
					_global.myTrace("cannot load courses xml files (course.xml)");
					this.master.control.view.showPopup("loadCoursesForExportError");
				}
			}
			*/
			// v6.4.1, DL: if inside menu screen, share base set to menu
			shareBase = (control.view.screens.scnUnit._visible) ? "menu" : "course";
			
			// v6.4.2.1 AR instead of just showing the mask, add the progress bar in
			//control.view.showMask();
			//myTrace("start pbar from sharingClass");
			control.view.setupPBar("sharing");
			
			// v6.4.2.5 Surely you already have course.xml in data[Courses]? Why read it again?
			// v6.4.3 With course tree we don't want to read the course.xml, we simply know all about the current course already			
			// So instead of reading course.xml, I am going to build it, then read menu.xml
			//x2.load(control.xmlCourse.XMLfile+"?nocache="+random(999999));
			var courseFolder = "Courses";
			var courseID = control.data.currentCourse.id;
			var subFolder = control.data.currentCourse.subFolder;
			var scaffold = control.data.currentCourse.scaffold;
			// v6.4.3 Causing some problems with the apostrophe
			var courseName = control.data.currentCourse.name;
			// v6.4.3 But if I unescape I end up with a pure apostrophe and quotes.
			//courseName = _global.replace(unescape(courseName),"'","&apos;");
			courseName = unescape(courseName);
			var path=control.xmlCourse.XMLfile;
			var folderPath = _global.getPath(path);
			var filePath = _global.addSlash(folderPath) + _global.addSlash(courseFolder) + _global.addSlash(subFolder) + scaffold;
			var originalContentFolder=_global.NNW.paths.content;
			
			var thisCourseNode="<courseList>";
			thisCourseNode+="<course name=\"" + courseName + "\" " + 
							"id=\"" + courseID + "\" " + 
							"subFolder=\"" + subFolder + "\" " + 
							"filePath=\"" + filePath + "\" " + 
							"folderPath=\"" + folderPath + "\" " + 
							"check=\"2\" /></courseList>";
			_global.myTrace("build courseList=" + thisCourseNode);
			x2.xmlDecl = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
			x2.parseXML(thisCourseNode);
			// copy the functions from the x2 loading function above
			this.menuPaths.push(filePath);
			// clone a copy in export tree for use
			//_global.myTrace("x2.firstChild=" + x2.firstChild);
			//_global.myTrace("x2.firstChild.firstChild=" + x2.firstChild.firstChild);
			this.exportTree.appendChild(x2.firstChild.cloneNode(true));
						
			// move the courses nodes to treeDpXml
			//for (var i=0; i<courseList.length; i++) {
			this.treeDpXml.appendChild(x2.firstChild.firstChild.cloneNode(true));
			//}
			// load the menu file
			this.loadMenuFiles();

			//myTrace("read courses xml");
			//myTrace(control.xmlCourse.XMLfile);
		}
	}
	
	// v6.4.1.3, DL: load menu.xml files for FSP version
	function loadMenuFiles() : Void {
		if (menuCnt<menuPaths.length) {
			exPaths = new Array();
			exCnt = 0;
			
			var m = new XML();
			m.master = this;
			m.path = _global.getPath(menuPaths[menuCnt]);
			// v6.4.2.5 Original path if MGS has mixed things UP
			m.originalPath = _global.replace(m.path, _global.NNW.paths.MGSPath, _global.NNW.paths.content);

			m.onLoad = function(success) {
				if (success&&this.firstChild.nodeName=="item") {
					if (this.firstChild.hasChildNodes()) {
						var menulist = this.firstChild.childNodes;
						for (var i=0; i<menulist.length; i++) {
							var un = menulist[i];
							// v6.4.2.3 unescape captions
							//un.attributes.label = un.attributes.caption;
							// v6.4.3 Use name rather than label
							//un.attributes.label = unescape(un.attributes.caption);
							// v6.4.3 But if I unescape I end up with a pure apostrophe and quotes.
							//un.attributes.name = _global.replace(unescape(un.attributes.caption),"'","&apos;");
							un.attributes.name = unescape(un.attributes.caption);
							//un.attributes.name = un.attributes.caption;
							un.attributes.check = "2";
							for (var j=0; j<un.childNodes.length; j++) {
								var ex = un.childNodes[j];
								// v6.4.2.3 unescape captions
								//ex.attributes.label = ex.attributes.caption;
								// v6.4.3 Use name rather than label
								//ex.attributes.label = unescape(ex.attributes.caption);
								ex.attributes.name = unescape(ex.attributes.caption);
								ex.attributes.check = "2";
								// v6.4.2.5 Read the file from where? MGS or original. Only go for the original if you are in MGS, but not this exercise
								// But only do this for exporting. For importing the path will all be fine
								//_global.myTrace("this ex has flag " + ex.attributes.enabledFlag);
								if (	this.master.control._enableMGS==true && 
									!(ex.attributes.enabledFlag & this.master.control.enabledFlag.MGS) &&
									(this.master.action=="export")) {
									//_global.myTrace("so use " + this.originalPath);
									ex.attributes.filePath = _global.addSlash(this.originalPath)+_global.addSlash("Exercises")+ex.attributes.fileName;
								} else {
									ex.attributes.filePath = _global.addSlash(this.path)+_global.addSlash("Exercises")+ex.attributes.fileName;
								}
								// v6.4.2.5 Need to have the enabledFlag to let you know where to read the file from when searching for media
								//this.master.exPaths.push({i:ex.attributes.id,p:ex.attributes.filePath});
								this.master.exPaths.push({i:ex.attributes.id,p:ex.attributes.filePath,eF:ex.attributes.enabledFlag});
							}
							
							if (this.master.action=="export") {
								this.master.exportTree.firstChild.childNodes[this.master.menuCnt].appendChild(un.cloneNode(true));
							} else {
								this.master.importTree.firstChild.childNodes[this.master.menuCnt].appendChild(un.cloneNode(true));
							}
							this.master.treeDpXml.childNodes[this.master.menuCnt].appendChild(un.cloneNode(true));
						}
					}
				}
				// no exercise, can go to next menu file
				if (this.master.exPaths.length==0) {
					this.master.menuCnt++;
					this.master.loadMenuFiles();
				} else {
					// add a medias node to export/import tree
					if (this.master.action=="export") {
						var medias:XMLNode = this.master.exportTree.createElement("medias");
						this.master.exportTree.firstChild.appendChild(medias);
					} else {
						var medias:XMLNode = this.master.importTree.createElement("medias");
						this.master.importTree.firstChild.appendChild(medias);
					}
					// load exercise xml files
					this.master.loadExFiles();
				}
			}
			m.load(menuPaths[menuCnt]+"?nocache="+random(999999));
		} else {
			if (action=="export") {
				control.view.fillInExportTreeDataProvider(treeDpXml);
				//_global.myTrace("export tree:");
				//_global.myTrace(exportTree.toString());
			} else {
				control.view.fillInImportTreeDataProvider(treeDpXml);
				//_global.myTrace("import tree:");
				//_global.myTrace(importTree.toString());
			}
		}
	}
	
	// v6.4.1.3, DL: load exercise xml files for FSP version
	function loadExFiles() : Void {
		if (exCnt<exPaths.length) {
			var e = new XML();
			e.master = this;
			e.path = _global.getPath(menuPaths[menuCnt]);
			e.id = exPaths[exCnt].i;
			// v6.4.2.5 Where to read this file (and its media) from?
			e.enabledFlag = exPaths[exCnt].eF;
			e.originalPath = _global.replace(e.path, _global.NNW.paths.MGSPath, _global.NNW.paths.content);
			
			e.onLoad = function(success) {
				this.xmlDecl = '<?xml version="1.0" encoding="UTF-8"?>';
				if (success) {
					//_global.myTrace("ex open OK");
					var root = this.firstChild;
					for (var i in root.childNodes) {
						// v6.4.2.4 But you might have media nodes outside of the body, they also need to be exported
						//if (root.childNodes[i].nodeName=="body") {
							//_global.myTrace("check for media in " + root.childNodes[i].nodeName);
							var bodyNode = root.childNodes[i];
							for (var j=bodyNode.childNodes.length-1; j>=0; j--) {
								var subNode = bodyNode.childNodes[j];
								if (subNode.nodeName=="media") {
									//_global.myTrace("media found");
									// v6.4.2.5 You should not touch URL locations either
									if (subNode.attributes.location!="shared" && subNode.attributes.location!="URL") {
										subNode.attributes.exID = this.id;
										// v6.4.2.5 Read the file from where? MGS or original. Only go for the original if you are in MGS, but not this exercise
										//subNode.attributes.filePath =  _global.addSlash(this.path)+_global.addSlash("Media")+subNode.attributes.filename;
										//_global.myTrace("this ex has flag " + this.enabledFlag);
										// But only do this for exporting. For importing the path will all be fine
										// if (this.master.control._enableMGS==true && !(this.enabledFlag & this.master.control.enabledFlag.MGS)) {
										if (	this.master.control._enableMGS==true && 
											!(this.enabledFlag & this.master.control.enabledFlag.MGS) &&
											(this.master.action=="export")) {
											//_global.myTrace("switch-a " + subNode.attributes.filename + " from " + this.path + " to " + this.originalPath);
											subNode.attributes.filePath = _global.addSlash(this.originalPath)+_global.addSlash("Media")+subNode.attributes.filename;
										} else {
											// v6.4.2.6 AR But if you have an MGS exercise that references the original media, do a switch the other way
											if (subNode.attributes.location=="original") {
											//	_global.myTrace("switch-b " + subNode.attributes.filename + " from " + this.path + " to " + this.originalPath);
												subNode.attributes.filePath = _global.addSlash(this.originalPath)+_global.addSlash("Media")+subNode.attributes.filename;
											} else {
												subNode.attributes.filePath = _global.addSlash(this.path)+_global.addSlash("Media")+subNode.attributes.filename;
											}
										}
										if (this.master.action=="export") {
											this.master.exportTree.firstChild.lastChild.appendChild(subNode.cloneNode(false));
										} else {
											this.master.importTree.firstChild.lastChild.appendChild(subNode.cloneNode(false));
										}
									}
								}
							}
						//}
					}
				}
				this.master.exCnt++;
				this.master.loadExFiles();
			}
			e.load(exPaths[exCnt].p+"?nocache="+random(999999));
			//_global.myTrace("ex path: "+exPaths[exCnt]);
		} else {
			menuCnt++;
			loadMenuFiles();
		}
	}

	// v6.4.2 Try to simply use the XML that went into the tree to create SCORM from - don't need all the files	
	function createSCO(userSelectXML:XML) : Void {
		//myTrace("sharing.createSCO");
		// first check that they are only selecting one course for SCORM SCO creation
		var noOfCoursesSelected = 0;
		for (var i in userSelectXML.childNodes) {
			if (userSelectXML.childNodes[i].attributes.check!="0") {
				noOfCoursesSelected++;
			}
		}
		if (noOfCoursesSelected > 1) {
			control.view.showPopup("moreThanOneCourseForSCORMExportError");
			return;
		} else if (noOfCoursesSelected < 1) {
			control.view.showPopup("noSelectedCoursesForExportError");
			return;
		}
		// Then get all the information for that node
		for (var i in userSelectXML.childNodes) {
			if (userSelectXML.childNodes[i].attributes.check!="0") {
				//var rootNode = userSelectXML.firstChild;
				var rootNode = userSelectXML.childNodes[i];
				var basePath:String = rootNode.attributes.folderPath;
				var cid:Number = rootNode.attributes.id;
				var cname:String = rootNode.attributes.name;
				var uids:Array = new Array();
				var unames:Array = new Array();
				for (var i=0; i<rootNode.childNodes.length; i++) {
					var unitNode = rootNode.childNodes[i];
					if (unitNode.attributes.check!="0") {
						uids.push(unitNode.attributes.id);
						unames.push(unitNode.attributes.caption);
					}
				}
				//v6.4.2.4 This break was outside the loop, so always pulled you up
				// if there was more than one course
				break;
			}
			//break;
		}

		myTrace("rootnode=" + rootNode.toString());
		myTrace("course id=" + cid + " and name=" + cname + " first unit=" + unames[0]);
		if (uids.length>0) {
			control.runCreateSCO(basePath, cid, cname, uids, unames);
		} else {
			// This should really be a different error - no units - but then again it is not possible anyway
			control.view.showPopup("noSelectedCoursesForExportError");
		}
	}
	
	function exportFiles(userSelectXML:XML, SCORM:Boolean) : Void {
		var files:Array = new Array();
		var folders:Array = new Array();
		var exIDs:Array = new Array();
		var rootNode = exportTree.firstChild;
		//myTrace("exportFiles, XML=" + rootNode.toString());
		for (var i=0; i<rootNode.childNodes.length; i++) {
			var courseNode = rootNode.childNodes[i];
			// for media node
			if (courseNode.nodeName=="medias") {
				for (var k=0; k<courseNode.childNodes.length; k++) {
					var mediaNode = courseNode.childNodes[k];
					for (var n=0; n<exIDs.length; n++) {
						if (mediaNode.attributes.exID==exIDs[n]) {
							//myTrace("keep mediaNode.exID=" + mediaNode.attributes.exID + " file=" + mediaNode.attributes.filePath);
							//v6.4.2.1 This doesn't cover question based and anchored media
							// I think you should simply be taking any media (except linked, which means location="URL")
							//var mediaType = mediaNode.attributes.type;
							//if (mediaType=="m:picture" || mediaType=="m:audio" || mediaType=="m:video") {
							var mediaLocation = mediaNode.attributes.location;
							if (mediaLocation<>"URL") {
								files.push(mediaNode.attributes.filePath);
							}
						}
					}
				}
			// for real course nodes
			} else if (userSelectXML.childNodes[i].attributes.check!="0") {
				if (courseNode.attributes.filePath!=undefined) {
					files.push(courseNode.attributes.filePath);
					folders.push(courseNode.attributes.subFolder);
					for (var j=0; j<courseNode.childNodes.length; j++) {
						var unitNode = courseNode.childNodes[j];
						if (userSelectXML.childNodes[i].childNodes[j].attributes.check!="0") {
							for (var k=0; k<unitNode.childNodes.length; k++) {
								var exNode = unitNode.childNodes[k];
								if (userSelectXML.childNodes[i].childNodes[j].childNodes[k].attributes.check!="0") {
									files.push(exNode.attributes.filePath);
									exIDs.push(exNode.attributes.id);
								}
							}
						}
					}
				}
			}
		}
		if (SCORM) {
			var noOfCoursesSelected = 0;
			for (var i in userSelectXML.childNodes) {
				if (userSelectXML.childNodes[i].attributes.check!="0") {
					noOfCoursesSelected++;
				}
			}
			if (noOfCoursesSelected > 1) {
				control.view.showPopup("moreThanOneCourseForSCORMExportError");
				return;
			}
		}
		if (files.length>0) {
			myTrace("call runExportFiles, folders.len=" + folders.length + " [0]=" + folders[0]);
			control.runExportFiles(rootNode.firstChild.attributes.folderPath, files, folders, SCORM);
		} else {
			control.view.showPopup("noSelectedCoursesForExportError");
		}
	}
	
	function importFiles(userSelectXML:XML) : Void {
		var files:Array = new Array();
		var folders:Array = new Array();
		var exIDs:Array = new Array();
		var rootNode = importTree.firstChild;
		for (var i=0; i<rootNode.childNodes.length; i++) {
			var courseNode = rootNode.childNodes[i];
			// for media node
			if (courseNode.nodeName=="medias") {
				for (var k=0; k<courseNode.childNodes.length; k++) {
					var mediaNode = courseNode.childNodes[k];
					for (var n=0; n<exIDs.length; n++) {
						if (mediaNode.attributes.exID==exIDs[n]) {
							files.push(mediaNode.attributes.filePath);
						}
					}
				}
			// for real course nodes
			} else if (userSelectXML.childNodes[i].attributes.check!="0") {
				if (courseNode.attributes.filePath!=undefined) {
					files.push(courseNode.attributes.filePath);
					folders.push(courseNode.attributes.subFolder);
					for (var j=0; j<courseNode.childNodes.length; j++) {
						var unitNode = courseNode.childNodes[j];
						if (userSelectXML.childNodes[i].childNodes[j].attributes.check!="0") {
							for (var k=0; k<unitNode.childNodes.length; k++) {
								var exNode = unitNode.childNodes[k];
								if (userSelectXML.childNodes[i].childNodes[j].childNodes[k].attributes.check!="0") {
									files.push(exNode.attributes.filePath);
									exIDs.push(exNode.attributes.id);
								}
							}
						}
					}
				}
			}
		}
		//myTrace("import:" + userSelectXML.toString());
		//myTrace("files:" + files.toString());
		//myTrace("folders:" + folders.toString());
		if (files.length>0) {
			control.runImportFiles(rootNode.firstChild.attributes.folderPath, files, folders);
		} else {
			control.view.showPopup("noSelectedCoursesForImportError");
		}
	}
	
	function loadImportFiles(folder:String) : Void {
		importTree = new XML();
		
		if (control.__server) {
			var x1 = new XML();
			x1.master = this;
			x1.onLoad = function(success) {
				if (success&&this.firstChild.nodeName=="courseList") {
					if (this.firstChild.hasChildNodes()) {
						// clone a copy in import tree for use
						this.master.importTree = this.cloneNode(true);
						// remove the medias node
						this.firstChild.lastChild.removeNode();
						// move the courses nodes up to document
						for (var i=0; i<this.firstChild.childNodes.length; i++) {
							this.appendChild(this.firstChild.childNodes[i].cloneNode(true));
						}
						// remove the courseList node
						this.firstChild.removeNode();
						// v6.4.2.1 At this point you have XML read from file - so you need to unescape some attributes
						// before you put it into the tree. 
						for (var i in this.childNodes) {
							var courseNode = this.childNodes[i];
							var attr = courseNode.attributes;
							for (var j in attr) {
								attr[j] = unescape(attr[j]);
							}
							// But that is just at the course level - you need to go deeper to unit level as well
							if (courseNode.hasChildNodes()) {
								for (var k in courseNode.childNodes) {
									var unitNode = courseNode.childNodes[k];
									var attr = unitNode.attributes;
									for (var j in attr) {
										attr[j] = unescape(attr[j]);
									}
									// and to the exercise level
									if (unitNode.hasChildNodes()) {
										for (var m in unitNode.childNodes) {
											var exNode = unitNode.childNodes[m];
											var attr = exNode.attributes;
											for (var j in attr) {
												attr[j] = unescape(attr[j]);
											}
										}
									}
								}
							}
						}
						// now we can fill in the XML to the tree
						this.master.control.view.fillInImportTreeDataProvider(this);
					} else {
						_global.myTrace("no courses for import");
						this.master.control.view.showPopup("noCoursesForImportError");
					}
				} else {
					_global.myTrace("cannot load courses xml files (course.xml)");
					this.master.control.view.showPopup("loadCoursesForImportError");
				}
				this.master.control.view.showImportScreen();
			}
			// v6.4.1.2, DL: prepare to add PHP scripting
			if (control.login.licence.scripting.toLowerCase()=="php") {
				var readCoursesXmlPage:String = control.paths.serverPath+"/readCoursesXML.php";
			} else {
				var readCoursesXmlPage:String = control.paths.serverPath+"/readCoursesXML.asp";
			}
			// v6.4.2.6 If you are running a script related to files, you need userDataPath for new getRootDir 
			var udp = _global.NNW.paths.userDataPath;
			
			// v6.4.3 readCoursesXML behaves differently for import and export, so send the action to it
			//x1.load(readCoursesXmlPage+"?prog=NNW&path="+folder+"/course.xml");
			// v6.5.4.7 Do I still need the udp - yes we do?
			//+"&userDataPath="+udp+
			x1.load(readCoursesXmlPage+"?prog=NNW&path="+folder+"/course.xml"+
									"&userDataPath="+udp+
									"&action=import");
			myTrace(readCoursesXmlPage+"?prog=NNW&path="+folder+"/course.xml"+
									"&userDataPath="+udp+
									"&action=import");
			
		// v6.4.1.3
		} else {
			treeDpXml = new XML();
			menuPaths = new Array();
			exPaths = new Array();
			menuCnt = 0;
			exCnt = 0;
			action = "import";
			
			var x2 = new XML();
			x2.master = this;
			x2.folder = folder;
			x2.onLoad = function(success) {
				this.xmlDecl = '<?xml version="1.0" encoding="UTF-8"?>';
				
				if (success&&this.firstChild.nodeName=="courseList") {
					if (this.firstChild.hasChildNodes()) {
						var courseList = this.firstChild.childNodes;
						
						for (var i=0; i<courseList.length; i++) {
							var courseNode = courseList[i];
							var attr = courseNode.attributes;
							// v6.4.2.1 At this point you have XML read from file - so you need to unescape some attributes
							// before you put it into the tree. 
							//attr.label = attr.name;
							// v6.4.3 Using name not label
							//attr.label = unescape(attr.name);
							attr.name = unescape(attr.name);
							attr.check = "2";
							attr.folderPath = this.folder;
							//attr.filePath = attr.folderPath+"/"+attr.courseFolder+attr.subFolder+"/"+attr.scaffold;
							// v6.4.2.6 add slash for courseFolder
							// v6.5 But you shouldn't be adding it to the menu! This stops the menu reading, so the import tree is empty after the coursename
							//attr.filePath = _global.addSlash(attr.folderPath) +_global.addSlash(attr.courseFolder) +_global.addSlash(attr.subFolder)+_global.addSlash(attr.scaffold);
							attr.filePath = _global.addSlash(attr.folderPath) +_global.addSlash(attr.courseFolder) +_global.addSlash(attr.subFolder)+attr.scaffold;
							_global.myTrace("from course get menu=" + attr.filePath);
							this.master.menuPaths.push(attr.filePath);
						}
						
						// clone a copy in import tree for use
						this.master.importTree.appendChild(this.firstChild.cloneNode(true));
						
						// move the courses nodes to treeDpXml
						for (var i=0; i<courseList.length; i++) {
							this.master.treeDpXml.appendChild(courseList[i].cloneNode(true));
						}
						
						// load menu files
						this.master.loadMenuFiles();
					} else {
						_global.myTrace("no courses for export");
						this.master.control.view.showPopup("noCoursesForImportError");
					}
				} else {
					_global.myTrace("cannot load courses xml files (course.xml)");
					this.master.control.view.showPopup("loadCoursesForImportError");
				}
			}
			myTrace("read import list from " + folder+"\\course.xml");
			x2.load(_global.addSlash(folder)+"course.xml?nocache="+random(999999));
		}
	}
	
	/*
		v6.4.1.4, DL: DEBUG - importing courses doesn't get the appropriate Clarity's program interface
		after importing course by course, we need to update all the menu xml files of the imported courses
	*/
	function updateMenuXmlFiles() : Void {
		_global.myTrace("sharing.updateMenuXMLFiles");
		var controlObj = control;
		var thisObj = this;
		var xpath = control.xmlCourse.XMLfile;
		var cx = new XML();
		cx.onLoad = function(success) {
			var oldTotal = controlObj.data.getNoOfCourses();
			var newTotal = this.firstChild.childNodes.length;
			if (!success || newTotal<=oldTotal) {
				// go straight back to course screen
				controlObj.xmlCourse.loadXML();
			} else {
				thisObj.menuPaths = new Array();
				thisObj.menuCnt = 0;
				for (var i=oldTotal; i<newTotal; i++) {
					var attr = this.firstChild.childNodes[i].attributes;
					// v6.4.3 Change name from paths.userPath to paths.content
					//var mxpath = _global.NNW.paths.userPath + "/" + attr.courseFolder + "/" + attr.subFolder + "/" + attr.scaffold;
					// AR v6.4.2.5 And on to MGS path
					//var mxpath = _global.addSlash(_global.NNW.paths.content) + _global.addSlash(attr.courseFolder) + _global.addSlash(attr.subFolder) + attr.scaffold;
					var mxpath = _global.addSlash(_global.NNW.paths.MGSPath) + _global.addSlash(attr.courseFolder) + _global.addSlash(attr.subFolder) + attr.scaffold;
					thisObj.menuPaths.push(mxpath);
				}
				thisObj.updateMenuOneByOne();
			}
		}
		cx.load(xpath);
	}
	
	function updateMenuOneByOne() : Void {
		if (menuCnt<menuPaths.length) {
			menuXml.setXmlFile(menuPaths[menuCnt]);
			menuXml.loadXMLAfterLocking();
			
		} else {
			control.xmlCourse.loadXML();
		}
	}
}
