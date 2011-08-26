import mx.utils.Delegate;

class Classes.fspImportFilesClass {
	
	// parameters to be set before function is called
	var userPath:String;
	var files:Array;
	var folders:Array;
	var menuXmlPath:String;
	var mdmActionRun:Object;
	
	// private variables used in this class
	private var unzipFolder:String;
	
	private var courseCnt:Number;
	private var newCID:String;
	private var destCFolder:String;
	private var sourceCFolder:String;
	private var newCNodes:XML;
	private var menuXml:XML;
	private var exFilenames:Array;
	private var exNodes:Array;
	//private var exCnt:Number;
	private var menuFilename:String;
	private var newUnitPos:Number;
	private var unitNodes:Array;
	//private var unitCnt:Number;
	private var exIdPairs:Array;
	private var copyMediaCnt:Number;
	private var mediaFilenames:Array;
	private var newEID:String;
	private var thisSubFolder:String;
	
	private var action:String;
	private var intID:Number;
	
	//v6.4.3 Running with mdmScript 2.0
	var mdm:Object;
	
	function fspImportFilesClass() {
		mdm = _global.mdm; // v6.4.3 mdm Script 2.0
	}
	
	// public functions
	public function importFiles() : Void {
		init();
		action = "copyMenu";
		importCourse();
	}
	public function importFilesToCurrentCourse() : Void {
		init();
		action = "appendMenu";
		openMenuXml();
	}
	
	// private functions
	private function myTrace(s:String) : Void {
		_global.myTrace(s);
	}
	
	private function getCurrentClarityUniqueID() : String {
		return _global.NNW.control.time.getCurrentClarityUniqueID();
	}
	
	private function init() : Void {
		unzipFolder = _root.unzip_folder;
		newCNodes = new XML();
		courseCnt = 0;
		menuFilename = "";
		newUnitPos = 0;
		unitNodes = new Array();
		exIdPairs = new Array();
	}

	// v6.4.2.5 This must be too soon, it doesn't work, but the command is fine. Try it outside this class
	// No that fails too. Fire it to happen in a few seconds time?
	private function delUnzipFolder() : Void {
		myTrace("delete unzip folder: "+_root.unzip_folder);
		//v6.4.3 mdm script 2
		//_root.mdm.deletefolder(_root.unzip_folder,"noask");
		//mdm.FileSystem.deleteFolderUnicode(_root.unzip_folder);
		//mdm.FileSystem.deleteFolderUnicode(_root.zip_folder);
		var builtCommand = "cmd.exe /K RMDIR /S /Q \"" + _root.unzip_folder + "\"";
		var command = mdm.System.Paths.system + builtCommand;
		myTrace(command);
		mdm.System.execStdOut(command);
	}
	
	private function onQueryFinish() : Void {
		delUnzipFolder();
		mdmActionRun.onQueryFinish();
	}
	
	private function onQueryError() : Void {		
		delUnzipFolder();
		mdmActionRun.onQueryError();
	}
	
	private function importCourse() : Void {
		exFilenames = new Array();
		exNodes = new Array();

		// v6.4.3 New loop (since async now) Oh no it isn't , still have some xml.loads in here
		//for (var courseCnt in folders) {
		if (folders.length>courseCnt && folders[courseCnt]!=undefined && folders[courseCnt]!="undefined" && folders[courseCnt]!="") {
			// create new folder for a course
			//thisSubFolder = _global.getFilename(folders[courseCnt]);
			newCID = getCurrentClarityUniqueID();
			destCFolder = _global.addSlash(userPath)+_global.addSlash("Courses")+newCID;
			sourceCFolder = _global.addSlash(_root.unzip_folder)+_global.addSlash("Courses")+folders[courseCnt];
			// v6.4.3 Update to mdm script 2
			//_root.mdm.makefolder(destCFolder);
			//_root.mdm.makefolder(_global.addSlash(destCFolder)+"Exercises");
			//_root.mdm.makefolder(_global.addSlash(destCFolder)+"Media");
			if (mdm.System.winVerString.indexOf("98")>0) {
				mdm.FileSystem.makeFolder(destCFolder);
				// v6.4.3 Error checking.
				var folderExists = mdm.FileSystem.folderExists(destCFolder);
			} else {
				mdm.FileSystem.makeFolderUnicode(destCFolder);
				// v6.4.3 Error checking.
				var folderExists = mdm.FileSystem.folderExistsUnicode(destCFolder);
			}

			//myTrace("folder exists=" + folderExists);
			if (!_global.NNW.control.errorCheck.passMDMPermissionsCheck(folderExists)) {
				//myTrace("error: unable to create the folders you need to - permission?");
				mdmActionRun.onQueryError();
				return;
			}
			if (mdm.System.winVerString.indexOf("98")>0) {
				mdm.FileSystem.makeFolder(_global.addSlash(destCFolder)+"Exercises");
				mdm.FileSystem.makeFolder(_global.addSlash(destCFolder)+"Media");
			} else {
				mdm.FileSystem.makeFolderUnicode(_global.addSlash(destCFolder)+"Exercises");
				mdm.FileSystem.makeFolderUnicode(_global.addSlash(destCFolder)+"Media");
			}
			myTrace("create folders for course: "+destCFolder);
			
			// check if folders are created
			//checkIfMediaFolderExists();
			processFiles();
			
		// finish importing all courses
		} else {
			//myTrace("writeToCourseXml");
			writeToCourseXml();
		}
	}
	
	private function importUnitsToCurrentCourse() : Void {
		myTrace("import to current course");
		exFilenames = new Array();
		exNodes = new Array();
		
		// v6.4.3 New loop (since async now) Er, no
		//for (var courseCnt in folders) {
		if (folders.length>courseCnt && folders[courseCnt]!=undefined && folders[courseCnt]!="undefined" && folders[courseCnt]!="") {
			// create new folder for a course
			//myTrace("iUTCC:menuxmlpath=" + menuXmlPath);
			destCFolder = _global.getPath(menuXmlPath);
			sourceCFolder = _global.addSlash(_root.unzip_folder)+_global.addSlash("Courses")+folders[courseCnt];
			//_root.mdm.makefolder(_global.addSlash(destCFolder)+"Exercises");
			//_root.mdm.makefolder(_global.addSlash(destCFolder)+"Media");
			if (mdm.System.winVerString.indexOf("98")>0) {
				mdm.FileSystem.makeFolder(_global.addSlash(destCFolder)+"Exercises");
				mdm.FileSystem.makeFolder(_global.addSlash(destCFolder)+"Media");
			} else {
				mdm.FileSystem.makeFolderUnicode(_global.addSlash(destCFolder)+"Exercises");
				mdm.FileSystem.makeFolderUnicode(_global.addSlash(destCFolder)+"Media");
			}
			myTrace("create folders for course: "+destCFolder);
			
			// check if folders are created
			//checkIfMediaFolderExists();				
			processFiles();
		} else {
		// finish importing all courses
			writeToMenuXml();
		}
	}
	
	private function getCourseName() : Void {
		// get course name from the unzipped course.xml
		var cx = new XML();
		cx.master = this;
		cx.f = _global.getFilename(folders[courseCnt]);
		cx.onLoad = function(success) {
			var cN = "";
			var cList = this.firstChild;
			for (var i=0; i<cList.childNodes.length; i++) {
				var c = cList.childNodes[i];
				if (this.f==c.attributes.subFolder) {
					// v6.4.2.3 unescape names
					//cN = c.attributes.name;
					cN = unescape(c.attributes.name);
					break;
				}
			}
			this.master.addNewCourseNode(cN);
		}
		myTrace("getCourseName, load " + _global.addSlash(unzipFolder)+"course.xml");
		cx.load(_global.addSlash(unzipFolder)+"course.xml?nocache="+random(999999));
	}
	
	private function addNewCourseNode(name:String) : Void {
		myTrace("add course node for: "+name);
		
		var cNode = newCNodes.createElement("course");
		cNode.attributes.author = "Clarity";
		cNode.attributes.edition = "1";
		cNode.attributes.version = "1.0";
		cNode.attributes.courseFolder = _global.addSlash("Courses");
		cNode.attributes.id = newCID;
		cNode.attributes.name = name;
		cNode.attributes.scaffold = "menu.xml";
		cNode.attributes.subFolder = newCID;
		newCNodes.appendChild(cNode);
		
		// edit menu xml
		openMenuXml();
	}
	
	private function writeToCourseXml() : Void {
		var cx = new XML();
		cx.master = this;
		cx.newNodes = newCNodes;
		cx.onLoad = function(success) {
			this.xmlDecl = '<?xml version="1.0" encoding="UTF-8"?>';
			if (success) {
				var cList = this.firstChild;
				for (var i=0; i<this.newNodes.childNodes.length; i++) {
					var n = this.newNodes.childNodes[i];
					if (n.nodeName=="course") {
						cList.appendChild(n.cloneNode(true));
					}
				}
				// v6.4.3 mdm script 2. As the xml is open, you can't do anything to it until you close it
				// use the delayed onSaveFile in mdmActionRun
				var intID:Number = _global['setTimeout'](this.master.mdmActionRun, "onSaveFile", 100, _global.addSlash(this.master.userPath)+"course.xml", this.toString());
				//_root.mdm.saveutf8_filename(_global.addSlash(this.master.userPath)+"course.xml");
					
				// set attributes of file to be writable
				//var attrib = "-R";
				//_root.mdm.setfileattribs(_global.addSlash(this.master.userPath)+"course.xml", attrib);
					
				//fscommand("mdm.saveutf8", this.toString());
			}
			
			// finish importing
			//_root.mdm.deletefolder(this.master.unzipFolder,"noask");
			this.master.onQueryFinish();
		}
		cx.load(_global.addSlash(userPath)+"course.xml?nocache="+random(999999));
	}

	//private function checkIfMediaFolderExists() : Void {
	//	//myTrace("check if media folder exists");
	//	//clearInterval(intID);
	//	//_root.mdm.folderexists(_global.addSlash(destCFolder)+"Media", Delegate.create(this, this.onGetMediaFolderExists));
	//	if (mdm.FileSystem.folderExistsUnicode(_global.addSlash(destCFolder)+"Media") {
	//		processFiles();
	//	}
	//}

	// v6.4.3 mdm script 2
	//private function onGetMediaFolderExists(b) : Void {
	//	//myTrace("exists? "+b);
	//	if (b.indexOf("true")>-1) {
	//		/*if (action=="copyMenu") {
	//			// copy menu.xml
	//			menuXmlPath = destCFolder+"\\menu.xml";
	//			_root.mdm.fileexists(sourceCFolder+"\\menu.xml", Delegate.create(this, this.onGetMenuFileExists));
	//			// we need to check if the file exists before copying,
	//			// as we have no way to suspend the error message from popping up
	//		} else {
	//			// process files list 
	//			processFiles();
	//		}*/
	//		processFiles();
	//	} else {
	//		intID = setInterval(this, "checkIfMediaFolderExists", 1000);
	//	}
	//}
	
	//private function onGetMenuFileExists(b) : Void {
	//	if (b.indexOf("true")>-1) {
	//		menuXmlPath = _global.addSlash(destCFolder)+"menu.xml";
	//		_root.mdm.copyfile(menuFilename, menuXmlPath);
	//		// get course name
	//		getCourseName();
	//	} else {
	//		// if menu file is not found, just error
	//		myTrace("menu file is not found");
	//		onQueryError();
	//	}
	//}
	
	private function processFiles() : Void {
		mediaFilenames = new Array();
		
		// copy media files in the course
		for (var i=0; i<files.length; i++) {
			var f = files[i];
			if (f!="") {
				f = _global.replace(f, "&amp;", "&");
				f = _global.replace(f, "//", "\\");
				f = _global.replace(f, "/", "\\");
				//f = _global.replace(f, "\\\\", "\\");
				files[i] = f;
				//myTrace("in: "+f);
				//myTrace("find: "+_global.getFilename(sourceCFolder));
				
				// only work on  files of current course
				if (f.indexOf(_global.getFilename(sourceCFolder))>-1) {
					var t = _global.getFilename(_global.getPath(f));
					//myTrace("t: "+t);
					// store media filenames
					if (t.toLowerCase()=="media") {
						mediaFilenames.push(f);
						//myTrace("media file: "+f);
						
					// save filenames of exercises
					} else if (t.toLowerCase()=="exercises") {
						exFilenames.push(f);
						//myTrace("ex file: "+f);
					} else {
						menuFilename = f;
						myTrace("menu.xml: "+f);
					}
				}
			}
		}
		//copyMediaCnt = 0;
		copyMediaFiles();
	}
	
	private function copyMediaFiles() : Void {
		// v6.4.3 different loop
		//if (copyMediaCnt<mediaFilenames.length) {
		for (var copyMediaCnt in mediaFilenames) {
			var f = mediaFilenames[copyMediaCnt];
			//_root.mdm.fileexists(f, Delegate.create(this, this.onGetMediaFileExists));
			if (mdm.System.winVerString.indexOf("98")>0) {
				if (mdm.FileSystem.fileExists(f)) {
					mdm.FileSystem.copyFile(f, _global.addSlash(destCFolder)+_global.addSlash("Media")+_global.getFilename(f));
				}  else {
					myTrace("could not copy file " + f);
				}
			} else {
				if (mdm.FileSystem.fileExistsUnicode(f)) {
					mdm.FileSystem.copyFileUnicode(f, _global.addSlash(destCFolder)+_global.addSlash("Media")+_global.getFilename(f));
				}  else {
					myTrace("could not copy file " + f);
				}
			}
		}
		// v6.4.3 Take this section out of the loop
		if (action=="copyMenu") {
			// copy menu file
			myTrace("copy menu file, check file exists: "+menuFilename);
			//_root.mdm.fileexists(menuFilename, Delegate.create(this, this.onGetMenuFileExists));
			if (mdm.System.winVerString.indexOf("98")>0) {
				if (mdm.FileSystem.fileExists(menuFilename)) {
					mdm.FileSystem.copyFile(menuFilename, _global.addSlash(destCFolder)+"menu.xml");
					getCourseName();
				} else {
					// if menu file is not found, just error
					// v6.4.3 And break??
					myTrace("menu file is not found");
					onQueryError();
				}
			} else {
				if (mdm.FileSystem.fileExistsUnicode(menuFilename)) {
					mdm.FileSystem.copyFileUnicode(menuFilename, _global.addSlash(destCFolder)+"menu.xml");
					getCourseName();
				} else {
					// if menu file is not found, just error
					// v6.4.3 And break??
					myTrace("menu file is not found");
					onQueryError();
				}
			}
		} else {
			// open menu.xml file for this course (get nodes to plug into destination's one)
			myTrace("import from: "+menuFilename);
			openMenuToBeImported();				
		}
	}
	
	//private function onGetMediaFileExists(b) : Void {
	//	// copy the media file if found
	//	// if a media file is not found, simply ignore
	//	if (b.indexOf("true")>-1) {
	//		var f = mediaFilenames[copyMediaCnt];
	//		_root.mdm.copyfile(f, _global.addSlash(destCFolder)+_global.addSlash("Media")+_global.getFilename(f));
	//	}
	//	copyMediaCnt++;
	//	copyMediaFile();
	//}
	
	private function openMenuXml() : Void {
		var mx = new XML();
		mx.master = this;
		mx.onLoad = function(success) {
			this.xmlDecl = '<?xml version="1.0" encoding="UTF-8"?>';
			if (success) {
				this.master.menuXml.xmlDecl = '<?xml version="1.0" encoding="UTF-8"?>';
				this.master.menuXml = this.cloneNode(true);
				//_global.myTrace("open menu xml: "+this.toString());
				this.master.editMenuXml();
			} else {
				_global.myTrace("load xml not success: "+this.master.menuXmlPath);
				this.master.onQueryError();
			}
		}
		myTrace("openMenuXML:" + menuXmlPath);
		mx.load(menuXmlPath+"?nocache="+random(999999));
	}
	
	private function editMenuXml() : Void {
		myTrace("editMenuXml");
		if (action=="copyMenu") {
			// if the exercise is chosen, keep it, otherwise remove it
			// remove units which has no exercises in it
			var root = menuXml.firstChild;
			for (var i=root.childNodes.length-1; i>=0; i--) {
				var unit = root.childNodes[i];
				for (var j=unit.childNodes.length-1; j>=0; j--) {
					var ex = unit.childNodes[j];
					var match = false;
					for (var k=0; k<exFilenames.length; k++) {
						var fn = _global.getFilename(exFilenames[k]);
						if (fn==ex.attributes.fileName) {
							exNodes[k] = ex;
							match = true;
						}
					}
					if (!match) {
						ex.removeNode();
					}
				}
				if (!unit.hasChildNodes()) {
					unit.removeNode();
				}
			}
			//exCnt = 0;
			//intID = setInterval(this, "editExNode", 250);
			editExNode();
		} else {
			// get new unit pos for incrementation
			var root = menuXml.firstChild;
			for (var i=root.childNodes.length-1; i>=0; i--) {
				var unit = root.childNodes[i];
				var pos = Number(unit.attributes.unit)
				if (pos>=newUnitPos) {
					newUnitPos = pos;
				}
			}
			importUnitsToCurrentCourse();
		}
	}
	
	private function editExNode() : Void {
		// v6.4.3
		//clearInterval(intID);
		//if (exCnt>=exFilenames.length) {
		for (var exCnt in exFilenames) {
			newEID = getCurrentClarityUniqueID();
			var ex = exNodes[exCnt];
			if (action=="copyMenu") {
				ex.attributes.id = newEID;
				ex.attributes.action = newEID;
				ex.attributes.fileName = newEID+".xml";
				ex.attributes.exerciseID = newEID+".xml";
			} else {
				// for action=="appendMenu"
				// those attributes settings won't affect unitNodes
				// so we need to redo the settings in menuXml afterwards
				var oldEID = ex.attributes.id;
				exIdPairs.push({o:oldEID, n:newEID});
			}
			//_root.mdm.fileexists(exFilenames[exCnt], Delegate.create(this, this.onGetExFileExists));			
			if (mdm.System.winVerString.indexOf("98")>0) {
				if (mdm.FileSystem.fileExists(exFilenames[exCnt])) {
					mdm.FileSystem.copyFile(exFilenames[exCnt], _global.addSlash(destCFolder)+_global.addSlash("Exercises")+newEID+".xml");
				}  else {
					myTrace("could not copy file " + exFilenames[exCnt]);
				}
			} else {
				if (mdm.FileSystem.fileExistsUnicode(exFilenames[exCnt])) {
					mdm.FileSystem.copyFileUnicode(exFilenames[exCnt], _global.addSlash(destCFolder)+_global.addSlash("Exercises")+newEID+".xml");
				}  else {
					myTrace("could not copy file " + exFilenames[exCnt]);
				}
			}
		}
		if (action=="copyMenu") {
			//_root.mdm.saveutf8_filename(menuXmlPath);
			// set attributes of file to be writable
			var attrib = "-R";
			//_root.mdm.setfileattribs(menuXmlPath, attrib);
			//fscommand("mdm.saveutf8", menuXml.toString());			
			if (mdm.System.winVerString.indexOf("98")>0) {
				mdm.FileSystem.saveFile(menuXmlPath, menuXml.toString());
			} else {
				mdm.FileSystem.saveFileUnicode(menuXmlPath, menuXml.toString());
			}
			mdm.FileSystem.setFileAttribs(menuXmlPath, attrib);

			// finish processing a course, move to next one
			// v6.4.3 running in a proper loop now. No
			courseCnt++;
			importCourse();
		} else {
			// finish processing a course, move to next one
			// v6.4.3 running in a proper loop now. No
			courseCnt++;
			importUnitsToCurrentCourse();
		}
	}
	
	//private function onGetExFileExists(b) : Void {
	//	if (b.indexOf("true")>-1) {
	//		_root.mdm.copyfile(exFilenames[exCnt], _global.addSlash(destCFolder)+_global.addSlash("Exercises")+newEID+".xml");
	//	}
	//	exCnt++;
	//	intID = setInterval(this, "editExNode", 250);
	//}
	
	private function openMenuToBeImported() : Void {
		myTrace("open menu to be imported: "+menuFilename);
		var mx = new XML();
		mx.master = this;
		mx.onLoad = function(success) {
			if (success) {
				myTrace("got menu");
				var root = this.firstChild;
				for (var i=root.childNodes.length-1; i>=0; i--) {
					var unit = root.childNodes[i];
					for (var j=unit.childNodes.length-1; j>=0; j--) {
						var ex = unit.childNodes[j];
						var match = false;
						for (var k=0; k<this.master.exFilenames.length; k++) {
							var fn = _global.getFilename(this.master.exFilenames[k]);
							if (fn==ex.attributes.fileName) {
								//this.master.exNodes[k] = ex.cloneNode(true);
								match = true;
							}
						}
						if (!match) {
							ex.removeNode();
						}
					}
					if (!unit.hasChildNodes()) {
						unit.removeNode();
					}
				}
				for (var i=0; i<root.childNodes.length; i++) {
					var unit = root.childNodes[i];
					myTrace("got unit " + unit.attributes.caption);
					var l = this.master.unitNodes.length;
					this.master.unitNodes[l] = root.childNodes[i].cloneNode(true);
					for (var j=0; j<unit.childNodes.length; j++) {
						var ex = unit.childNodes[j];
						for (var k=0; k<this.master.exFilenames.length; k++) {
							var fn = _global.getFilename(this.master.exFilenames[k]);
							if (fn==ex.attributes.fileName) {
								this.master.exNodes[k] = ex;
							}
						}
					}
				}
			}
			//this.master.exCnt = 0;
			//this.master.intID = setInterval(this.master, "editExNode", 250);
			this.master.editExNode();
		}
		mx.load(menuFilename+"?nocache="+random(999999));
	}
	
	//private function writeToMenuXml() : Void {
	//	// the get clarity id thing is working too fast!
	//	// implement an interval loop
	//	unitCnt = 0;
	//	intID = setInterval(this, "writeUnitNode", 250);
	//}
	
	private function writeToMenuXml() : Void {
	//private function writeUnitNode() : Void {
		// v6.4.3 Change loop
		for (var unitCnt in unitNodes) {
		//if (unitCnt>=unitNodes.length) {
			var oldTotal = menuXml.firstChild.childNodes.length;
			var newTotal = oldTotal + unitNodes.length;
			
			var n = unitNodes[unitCnt];
			//_global.myTrace("n=" + n.caption);
			if (n.nodeName=="item") {
				newUnitPos++;
				
				// v6.4.1.4, DL: after importing the menu xml will be rewritten to ensure the interface is updated
				//n.attributes["picture"] = "";	//_global.NNW.interfaces.getUnitPicture(oldTotal+unitCnt); //"Menu-APL-" + calUnitPicture(oldTotal+unitCnt);
				//n.attributes["caption-position"] = "";	//_global.NNW.interfaces.getCaptionPosition();
				//n.attributes["x"] = "";	//calUnitXPos(oldTotal+unitCnt, newTotal);
				//n.attributes["y"] = "";	//calUnitYPos(oldTotal+unitCnt, newTotal);
				// thus there is no need to get a correct interface at this moment
				// AR v6.4.2.5 I don't see this being done anywhere. So the attributes end up empty.
				
				n.attributes["unit"] = newUnitPos;
				n.attributes["id"] = getCurrentClarityUniqueID();
				for (var j in n.childNodes) {
					var ex = n.childNodes[j];
					ex.attributes.unit = newUnitPos;
					for (var k=0; k<exIdPairs.length; k++) {
						if (ex.attributes.id==exIdPairs[k].o) {
							var newEID = exIdPairs[k].n;
							ex.attributes.id = newEID;
							ex.attributes.action = newEID;
							ex.attributes.fileName = newEID+".xml";
							ex.attributes.exerciseID = newEID+".xml";
							// v6.4.2.5 If you are importing to an MGS, all exercises will be copied here so set their enabledFlags
							if (_global.NNW.control._enableMGS) {
								_global.myTrace("in MGS so change enabledFlag from " + ex.attributes.enabledFlag);
								ex.attributes.enabledFlag|=_global.NNW.control.enabledFlag.MGS;
							}
						}
					}
				}
				menuXml.firstChild.appendChild(n.cloneNode(true));
			}			
			//unitCnt++;
		}
		//clearInterval(intID);
		// v6.4.2.5 Until you do the interfaces correctly in the main body, you will need to do a second loop here once you know the total
		var finalTotal = menuXml.firstChild.childNodes.length;
		var counter=0;
		//_global.myTrace("final total units=" + finalTotal);
		for (var thisNode in menuXml.firstChild.childNodes) {
			var n = menuXml.firstChild.childNodes[thisNode];
			if (n.nodeName=="item") {
				// For now, at least do this here.
				n.attributes["picture"] = _global.NNW.interfaces.getUnitPicture(counter); //"Menu-APL-" + calUnitPicture(oldTotal+unitCnt);
				n.attributes["caption-position"] = _global.NNW.interfaces.getCaptionPosition();
				n.attributes["x"] = _global.NNW.interfaces.getUnitXPos(counter, finalTotal);
				n.attributes["y"] = _global.NNW.interfaces.getUnitYPos(counter, finalTotal);
				counter++;
			}
		}
		
		// save menu xml file
		//_root.mdm.saveutf8_filename(menuXmlPath);
		// set attributes of file to be writable
		var attrib = "-R";
		//_root.mdm.setfileattribs(menuXmlPath, attrib);
		//fscommand("mdm.saveutf8", menuXml.toString());
		if (mdm.System.winVerString.indexOf("98")>0) {
			mdm.FileSystem.saveFile(menuXmlPath, menuXml.toString());
		} else {
			mdm.FileSystem.saveFileUnicode(menuXmlPath, menuXml.toString());
		}
		mdm.FileSystem.setFileAttribs(menuXmlPath, attrib);
		
		// finish importing
		onQueryFinish();
	}
}