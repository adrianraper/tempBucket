import mx.utils.Delegate;

// v6.4.2.5 A new ZIP extension
//import Classes.Zip;

class Classes.fspExportFilesClass {
	
	// parameters to be set before function is called
	var files:Array;
	var folders:Array;
	var basePath:String;
	// v6.4.2.5 Alternative path
	var originalContentPath:String;
	//var SCORM:Boolean;
	var mdmActionRun:Object;
	
	// private variables used in this class
	private var tempFolder:String;
	private var coursesFolder:String;
	private var courseXMLPath:String;
	private var newCFolder:String;
	// v6.4.3 For ZIP processing
	private var currentPath:String;
	
	private var menuCnt:Number;
	private var copyFileCnt:Number;
	private var menuFilenames:Array;
	
	var intID:Number;
	
	//v6.4.3 Running with mdmScript 2.0
	var mdm:Object;
	
	// v6.4.2.5 A new ZIP extension
	//var zincZIP:Zip;
	//var zipSuccess:Boolean;
	
	function fspExportFilesClass() {
		mdm = _global.mdm; // v6.4.3 mdm Script 2.0
		// v6.4.2.5 A new ZIP extension
		//zincZIP = new Zip();
		//zincZIP = _global.NNW.control.sharing.zincZIP;
		//zincZIP.master = this;
		//_global.NNW.control.sharing.exporting = this;
	}
	
	// public functions
	public function exportFiles() : Void {
		// AR v6.4.2.5 Make sure that all slashes are the same
		//basePath = _global.replace(basePath, "//", "\\");
		basePath = _global.replace(basePath, "/", "\\");
		//originalContentPath = _global.replace(originalContentPath, "//", "\\");
		originalContentPath = _global.replace(originalContentPath, "/", "\\");
		myTrace("exportFiles.basePath=" + basePath);
		myTrace("exportFiles.originalContentPath=" + originalContentPath);
		
		tempFolder = _global.addSlash(basePath)+getCurrentClarityUniqueID();
		coursesFolder = _global.addSlash(tempFolder)+"Courses";
		courseXMLPath = _global.addSlash(tempFolder)+"course.xml";
		myTrace("exportFiles.courseXML=" + courseXMLPath);
		// v6.4.3 Update to mdm script 2
		//_root.mdm.makefolder(tempFolder);
		//_root.mdm.makefolder(coursesFolder);
		//_root.mdm.copyfile(basePath+"\\course.xml", courseXMLPath);
		if (mdm.System.winVerString.indexOf("98")>0) {
			mdm.FileSystem.makeFolder(tempFolder);
			// v6.4.3 Error checking.
			var folderExists = mdm.FileSystem.folderExists(tempFolder);
		} else {
			mdm.FileSystem.makeFolderUnicode(tempFolder);
			// v6.4.3 Error checking.
			var folderExists = mdm.FileSystem.folderExistsUnicode(tempFolder);
		}
		//myTrace("folder exists=" + folderExists);
		if (!_global.NNW.control.errorCheck.passMDMPermissionsCheck(folderExists)) {
			//myTrace("error: unable to create the folders you need to - permission?");
			mdmActionRun.onQueryError();
			return;
		}
		// v6.4.3 I don't want to copy the original course.xml as there is only course, I might as well make a new node
		var thisCourseXML = "<?xml version='1.0' encoding='UTF-8'?><courseList>";
		var courseID = _global.NNW.control.data.currentCourse.id;
		var subFolder = _global.NNW.control.data.currentCourse.subFolder;
		var scaffold = _global.NNW.control.data.currentCourse.scaffold;
		var courseName = escape(_global.NNW.control.data.currentCourse.name);
		thisCourseXML +="<course name='" + courseName + "' " + 
							"id='" + courseID + "' " + 
							"subFolder='" + subFolder + "' " + 
							"scaffold='" + scaffold + "' " + 
							"courseFolder='Courses' " + 
							"version='6.4.3' program='Author Plus' enabledFlag='3' />";
		thisCourseXML+="</courseList>";

		// write the above info rather than copying the old file
		if (mdm.System.winVerString.indexOf("98")>0) {
			mdm.FileSystem.makeFolder(coursesFolder);
			mdm.FileSystem.saveFile(courseXMLPath, thisCourseXML);

		} else {
			mdm.FileSystem.makeFolderUnicode(coursesFolder);
			mdm.FileSystem.saveFileUnicode(courseXMLPath, thisCourseXML);
		}
		for (var i in folders) {
			var f = folders[i];
			if (f!="") {
				f = _global.replace(f, "&amp;", "&");
				f = _global.replace(f, "//", "\\");
				f = _global.replace(f, "/", "\\");
				//f = _global.replace(f, "\\\\", "\\");
				folders[i] = f;
				newCFolder = _global.addSlash(tempFolder)+_global.addSlash("Courses")+f;
				//_root.mdm.makefolder(newCFolder);
				//_root.mdm.makefolder(newCFolder+"\\Exercises");
				//_root.mdm.makefolder(newCFolder+"\\Media");
				if (mdm.System.winVerString.indexOf("98")>0) {
					mdm.FileSystem.makeFolder(newCFolder);
					mdm.FileSystem.makeFolder(_global.addSlash(newCFolder)+"Exercises");
					mdm.FileSystem.makeFolder(_global.addSlash(newCFolder)+"Media");
				} else {
					mdm.FileSystem.makeFolderUnicode(newCFolder);
					mdm.FileSystem.makeFolderUnicode(_global.addSlash(newCFolder)+"Exercises");
					mdm.FileSystem.makeFolderUnicode(_global.addSlash(newCFolder)+"Media");
				}
				
				//myTrace("make folder for course: "+newCFolder);
				
				//if (SCORM) {
				//	// not yet implemented
				//}
			}
		}
		// v6.4.3 mdm script 2
		//checkIfMediaFolderExists();
		if (mdm.System.winVerString.indexOf("98")>0) {
			if (mdm.FileSystem.folderExists(_global.addSlash(newCFolder)+"Media")) {
				processFiles();
			}
		} else {
			if (mdm.FileSystem.folderExistsUnicode(_global.addSlash(newCFolder)+"Media")) {
				processFiles();
			}
		}
	}
	
	// private functions
	private function myTrace(s:String) : Void {
		_global.myTrace(s);
	}
	
	private function getCurrentClarityUniqueID() : String {
		return _global.NNW.control.time.getCurrentClarityUniqueID();
	}
	
	// v6.4.3 mdm script 2
	//private function checkIfMediaFolderExists() : Void {
	//	clearInterval(intID);
	//	_root.mdm.folderExists(newCFolder+"\\Media", Delegate.create(this, this.onGetMediaFolderExists));
	//}
	//private function onGetMediaFolderExists(b) : Void {
	//	if (b.indexOf("true")>-1) {
	//		processFiles();
	//	} else {
	//		intID = setInterval(this, "checkIfMediaFolderExists", 1000);
	//	}
	//}

	// v6.4.3 This whole process seems a bit unnecessary - checking continuously if we have 
	// already copied a file. There won't be much duplication I wouldn't have thought. 
	private function processFiles() : Void {
		menuFilenames = new Array();
		
		// copy files to temp folder
		for (var i in files) {
			var f = files[i];
			if (f!="") {
				var match = false;
				// v6.4.3 We are replacing all & in file names, what about other characters that could cause problems?
				// And is this still necessary with mdm script 2.0 unicode functions?
				//f = _global.replace(f, "&amp;", "&");
				f = _global.replace(f, "//", "\\");
				f = _global.replace(f, "/", "\\");
				//f = _global.replace(f, "\\\\", "\\");
				for (var j in folders) {
					if (f.toLowerCase().indexOf(folders[j].toLowerCase())>-1) {
						match = true;
						break;
					}
				}
				if (match) {
					files[i] = f;	// put it back to files array so that we don't have to do it again
					
					// DEBUG - we need to check if the file exists before copying,
					// as we have no way to suspend the error message from popping up
					
					//var nf = _global.replace(f, basePath, tempFolder);
					//_root.mdm.copyfile(f, nf);
					//myTrace("file: "+nf);
					var t = _global.getFilename(_global.getPath(f));
					if (t.toLowerCase()!="exercises" && t.toLowerCase()!="media") {
						menuFilenames.push(f);
					}
				} else {
					files.splice(i, 1);
				}
			}
		}
		copyFileCnt = 0;
		copyFiles();
	}
	
	private function copyFiles() : Void {
		for (var f in files) {
			//myTrace("copy file " + files[f]);
			// v6.4.2.5 The file has the full path, which might be from original or MGS folder
			// This is now very clumsy code as you are changing folder and filenames so much
			if (mdm.System.winVerString.indexOf("98")>0) {
				if (mdm.FileSystem.fileExists(files[f])) {
					// so, which path does this filename contain?
					if (files[f].indexOf(basePath)>=0) {
						var nf = _global.replace(files[f], basePath, tempFolder);
					} else {
						var nf = _global.replace(files[f], originalContentPath, tempFolder);
					}
					mdm.FileSystem.copyFile(files[f], nf);
				} else {
					// v6.4.2.5 Check in original path too
					//if (originalContentPath <> basePath && originalContentPath != undefined) {
					//	var originalFile = _global.replace(files[f], basePath, originalContentPath);
					//	if (mdm.FileSystem.fileExists(originalFile)) {
					//		var nf = _global.replace(originalFile, originalContentPath, tempFolder);
					//		mdm.FileSystem.copyFile(originalFile, nf);
					//	} else {
					//		myTrace("tried to copy non-exist " + originalFile);
					//	}
					//} else {
						myTrace("tried to copy non-exist " + files[f]);
					//}
				}
			} else {
				if (mdm.FileSystem.fileExistsUnicode(files[f])) {
					// so, which path does this filename contain?
					if (files[f].indexOf(basePath)>=0) {
						var nf = _global.replace(files[f], basePath, tempFolder);
					} else {
						var nf = _global.replace(files[f], originalContentPath, tempFolder);
					}
					mdm.FileSystem.copyFileUnicode(files[f], nf);
				} else {
					// v6.4.2.5 Check in original path too
					//if (originalContentPath <> basePath && originalContentPath != undefined) {
					//	var originalFile = _global.replace(files[f], basePath, originalContentPath);
					//	if (mdm.FileSystem.fileExistsUnicode(originalFile)) {
					//		var nf = _global.replace(originalFile, originalContentPath, tempFolder);
					//		mdm.FileSystem.copyFileUnicode(originalFile, nf);
					//	} else {
					//		myTrace("tried to copy non-exist " + originalFile);
					//	}
					//} else {
					myTrace("tried to copy non-exist " + files[f]);
					//}
				}
			}
		}
		// proceed to edit the new course xml
		//myTrace("to editCourseXML from copyfiles");
		// v6.4.3 I don't need to do this since I made my own course.xml
		//editCourseXml();
		_global.myTrace("call to editMenuXml");
		this.menuCnt = 0;
		editMenuXml();
	}
	
	// v6.4.3 mdm script 2
	//private function onGetFileExists(b) : Void {
	//	if (b.indexOf("true")>-1) {
	//		var f = files[copyFileCnt];
	//		var nf = _global.replace(f, basePath, tempFolder);
	//		_root.mdm.copyfile(f, nf);
	//		//_global.myTrace("basePath:"+basePath);
	//		//_global.myTrace("tempFolder:"+tempFolder);
	//	}
	//	copyFileCnt++;
	//	copyFiles();
	//}
	
	private function editCourseXml() : Void {
		myTrace("editCourseXML");
		var cx = new XML();
		cx.master = this;
		cx.onLoad = function(success) {
			this.xmlDecl = '<?xml version="1.0" encoding="UTF-8"?>';
			if (success) {
				var cList = this.firstChild;
				var folders = this.master.folders;
				for (var i=cList.childNodes.length-1; i>=0; i--) {
					var course = cList.childNodes[i];
					var match = false;
					for (var j=folders.length-1; j>=0; j--) {
						if (course.attributes.subFolder==folders[j]) {
							match = true;
							break;
						}
					}
					if (!match) {
						course.removeNode();
					}
				}
				// v6.4.3 mdm script 2. As the xml is open, you can't do anything to it until you close it
				// use the delayed onSaveFile in mdmActionRun
				var intID:Number = _global['setTimeout'](this.master.mdmActionRun, "onSaveFile", 100, this.master.courseXMLPath, this.toString());
				//_root.mdm.saveutf8_filename(this.master.courseXMLPath);
				
				// set attributes of file to be writable
				//var attrib = "-R";
				//_root.mdm.setfileattribs(this.master.courseXMLPath, attrib);
				
				//fscommand("mdm.saveutf8", this.toString());
			}
			this.master.menuCnt = 0;
			this.master.editMenuXml();
		}
		cx.load(courseXMLPath);
	}
	
	private function editMenuXml() : Void {
		_global.myTrace("in editMenuXml, folders=" + folders.length);
		if (menuCnt<folders.length) {
			var mx = new XML();
			mx.master = this;
			mx.onLoad = function(success) {
				this.xmlDecl = '<?xml version="1.0" encoding="UTF-8"?>';
				_global.myTrace("load menu.xml? "+success);
				if (success) {
					var uList = this.firstChild;
					var files = this.master.files;
					for (var i=uList.childNodes.length-1; i>=0; i--) {
						var unit = uList.childNodes[i];
						for (var j=unit.childNodes.length-1; j>=0; j--) {
							var ex = unit.childNodes[j];
							var match = false;
							for (var k=files.length-1; k>=0; k--) {
								if (ex.attributes.fileName==_global.getFilename(files[k])) {
									match = true;
									break;
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
					// v6.4.3 mdm script 2. As the xml is open, you can't do anything to it until you close it
					// use the delayed onSaveFile in mdmActionRun
					var menuFileName = _global.addSlash(this.master.newCFolder)+this.mName;
					//var attrib = "-R";
					//mdm.FileSystem.setFileAttribs(menuFileName, attrib);
					//myTrace("save " + menuFileName + " with " + this.toString());
					//mdm.FileSystem.saveFileUnicode(menuFileName, this.toString());
					//_root.mdm.saveutf8_filename(_global.addSlash(this.master.newCFolder)+this.mName);
					// set attributes of file to be writable
					//var attrib = "-R";
					//_root.mdm.setfileattribs(_global.addSlash(this.master.newCFolder)+this.mName, attrib);
					//fscommand("mdm.saveutf8", this.toString());
					var intID:Number = _global['setTimeout'](this.master.mdmActionRun, "onSaveFile", 100, menuFileName, this.toString());
				}
				this.master.menuCnt++;
				this.master.editMenuXml();
			}
			newCFolder = _global.addSlash(tempFolder)+_global.addSlash("Courses")+folders[menuCnt];
			var mName = "menu.xml";
			for (var i in menuFilenames) {
				if (menuFilenames[i].toLowerCase().indexOf(folders[menuCnt].toLowerCase()) > -1) {
					mName = _global.getFilename(menuFilenames[i]);
				}
			}
			mx.mName = mName;
			_global.myTrace("menu.xml=" + _global.addSlash(newCFolder)+mName);
			mx.load(_global.addSlash(newCFolder)+mName);
		} else {
			// zip the folder content up. You do need to wait a while as the above loop will have triggered many
			// filecopy commands to be run on the interval
			intID = setInterval(this, "zipFolder", 500);
		}
	}
	
	private function zipFolder() : Void {
		clearInterval(intID);
		// v6.4.3 The following will NOT work, or rather it adds too many levels of folder to the zip
		// So you need to manipulate the path to get rid of ..
		// But it works for 6.4.2.7! OK This is because the manipulation to get rid of the relative .. is done in APcontrol.swf
		// BUT it doesn't work if the location.ini has / instead of \. I have no edited APcontrol.swf so that it changes one to the other
		//tempFolder = "D:\\Workbench\\AuthorPlusNetwork\\..\\Content\\AuthorPlus\\1153911435718";
		// Try to temporarily make the current folder to be tempFolder. No, this has no effect.
		
		//var setFolder = tempFolder;
		//var setFolder = "D:\\Fixbench\\Content\\Spaces\\Disturbing\\MyCanada\\";
		//if (mdm.System.winVerString.indexOf("98")>0) {
		//	this.currentPath = mdm.FileSystem.getCurrentDir();
		//	mdm.FileSystem.setCurrentDir(setFolder);
		//} else {
		//	this.currentPath = mdm.FileSystem.getCurrentDirUnicode();
		//	mdm.FileSystem.setCurrentDirUnicode(setFolder);
		//}
		// The above doesn'work to reset the path, do I need to wait?
		//_global.myTrace("current path was=" + this.currentPath);
		//_global.myTrace("current path is=" + mdm.FileSystem.getCurrentDirUnicode());
		//_root.zip_file="myZIP"+".zip";
		_root.zip_file=tempFolder+".zip";
		_root.zip_folder=tempFolder;
		_root.zip_ext="*.*";
		_root.zip_pwd="none";
		myTrace("zip folder: "+_root.zip_folder);
		myTrace("zip file: "+_root.zip_file);
		// v6.4.2.5 New ZIP extension
		
		//fscommand("flashvnn.ZipFolder","zip_file,zip_folder,zip_ext,zip_pwd");
		mdm.Extensions.flashvnn.ZIPFolder(_root.zip_file,_root.zip_folder,_root.zip_ext,_root.zip_pwd);		
		// Is it safe to do this immediately? Or better to wait for a little while?
		intID = setInterval(this, "checkZipFolder", 1000);
		
		/*
		var user="Adrian Raper";
		var serial="263082341957793057-1834082842";
		zincZIP = new Zip(user, serial);
		//zincZIP.debugName = "zincZIP";
		var zipFile:String=_root.zip_file;
		var zipFolder:String=_root.zip_folder;
		var zipMask:String = "*.*";
		var zipPassword:String = "";
		var zipCompressMethod:Number = 2; // normal compression
		var zipSpanSize:Number = 0;
		var zipComment:String = "ZIP pack created by Author Plus";
		var zipOverwrite:Boolean = true;
		var zincZip = _root.zipHolder.zincZip
		_root.zipHolder.callBack = this;
		zipSuccess = false;
		//zincZIP.Event.onEnd = function(success:Boolean) {
		//	_global.NNW.control.sharing.exporting.checkZipFolder();
		//};
		_global.myTrace("stopMyTrace");
		zincZip.CompressFolder(zipFile, zipFolder, zipMask, zipPassword, zipCompressMethod, zipSpanSize, zipComment);
		myTrace("after compressFolder");
		intID = setInterval(this, "failsafeCheckZipFolder", 5000);
		*/
	}
	/*
	// v6.4.3.5 new ZIP extension
	public function onZipProcessing(percent:Number):Void {
		myTrace("onZipProcessing=" + percent + "%");
	}
	public function onZipEnd(success:Boolean):Void {
		myTrace("onZipEnd=" + success);
		zipSuccess = true;
		checkZipFolder();
	}
	private function failsafeCheckZipFolder() : Void {
		myTrace("failsafe");
		clearInterval(intID);
		if (!zipSuccess) {
			myTrace("which is needed on no onZipEnd");
			checkZipFolder();
		}
	}
	*/
	public function checkZipFolder() : Void {
		clearInterval(intID);
		_global.myTrace("checkZipFolder");
		if (mdm.System.winVerString.indexOf("98")>0) {
			//mdm.FileSystem.setCurrentDir(this.currentPath);
			var thisExists = mdm.FileSystem.fileExists(_root.zip_file);
		} else {
			//mdm.FileSystem.setCurrentDirUnicode(this.currentPath);
			var thisExists = mdm.FileSystem.fileExistsUnicode(_root.zip_file);
		}
		//_global.myTrace("calling to zip.Free " + zincZIP.Free);
		//zincZIP.Free();
		if (thisExists) {
			myTrace("zip created, so delete " + tempFolder);
			// At this point we want to delete the temp folder (and all in it)
			//mdm.FileSystem.deleteFolderUnicode(tempFolder);
			// But this ZINC command doesn't delete a folder with stuff in it!!! forums recommend using windows commands
			// Hope this isn't too dangerous!!!
			var builtCommand = "cmd.exe /K RMDIR /S /Q \"" + tempFolder + "\"";
			var command = mdm.System.Paths.system + builtCommand;
			myTrace(command);
			mdm.System.execStdOut(command);
			mdmActionRun.onQueryFinish();
		} else {
			myTrace("error: unable to create the zip file");
			mdmActionRun.onQueryError();
		}		
	}
}