import mx.utils.Delegate;
//import mx.events.EventDispatcher;
import Classes.fspImportFilesClass;
import Classes.fspExportFilesClass;
import Classes.fspScormExportClass;

import Classes.actionResponse;
// v6.4.2.5 A new ZIP extension
//import Classes.Zip;

class Classes.mdmActionRunClass extends XML {

	var control:Object;
	var actionPurpose:String;
	
	// query parameters
	var subject:String;
	var body:String;
	var filePath:String;
	var username:String;
	var account:String;
	
	//v6.4.2.3 DK, add query parameters for SCORM export
	var uids:Array;
	var unames:Array;
	var cid:String;
	var cname:String;	
	
	var totalLck:Number;	// total no. of exericses lock file (for looping)
	var lckCnt:Number;		// no. of lock file opened
	var lckUser:String;		// locking user
	
	var basePath:String;
	var zipFile:String;
	var files:Array;
	var folders:Array;
	var menuXmlPath:String;
	var SCORM:Boolean;

	// v6.4.2.7 Path to avoid get parent paths
	var serverPath:String;
	var UserDataPath:String;
	// v6.4.3 Path if you are in MGS pointing to original content, saves reading location.ini
	var OriginalContentPath:String;
	// v6.4.3 Need to know what to do with enabledFlags
	var MGSEnabled:Boolean;	
	
	// other variables
	var intCnt:Number;
	var intID:Number;
	
	//v6.4.3 Running with mdmScript 2.0
	var mdm:Object;
	//var mdmFileName:String;
	//var mdmFileContents:String;
	//var mdmInterval:Number;
	
	// v6.4.2.5 A new ZIP extension
	//var zincZIP:Zip;
	
	private var newZipFile:String;

	function mdmActionRunClass() {
		control = _global.NNW.control;
		mdm = _global.mdm; // v6.4.3 mdm Script 2.0
		actionPurpose = "";
		
		// error exception handler
		//_root.onMDMScriptException = function(errorMessage,errorFormType,errorFrameNumber,errorParameter,errorParameterValue) {
			//fscommand("mdm.exceptionhandler_reset");
		// I think this is already done globally
		//mdm.Application.onMDMScriptException = function(myObject){
		//	myTrace("mdm script exception: command: " + myObject.command);
		//	myTrace("mdm script exception: message: " + myObject.message);
		//	mdm.Exception.resetHandler();
		//}
	}

	function myTrace(s:String) : Void {
		_global.myTrace(s);
	}

	// v6.4.3 A function to save a file, triggered by an event
	// Probably should be in control as got nothing to do with the XML in this class
	// Duplicated there for the moment.
	function onSaveFile(thisFile:String, contents:String) : Void {
		//clearInterval(this.mdmInterval);
		//var thisFile = this.mdmFileName;
		//var contents = this.mdmFileContents;
		myTrace("onSaveFile " + thisFile);
		
		// set attributes of file to be writable
		var attrib = "-R";
		// v6.4.3 mdm script 2.0
		//_root.mdm.setfileattribs(this.lckPath, attrib);
		
		// v6.4.3 mdm script 2.0
		//fscommand("mdm.saveutf8", this.toString());
		// v6.4.3 You can't save a file that already exists - you have to delete then save.
		// No, this was caused by the file being locked as within XML.onLoad at the time for the very same file.
		//if (mdm.FileSystem.fileExistsUnicode(thisFile)) {
		//	myTrace("already exists, so delete it first");
		//	mdm.FileSystem.deleteFileUnicode(thisFile);
		//}
		// v6.4.2.4
		if (mdm.System.winVerString.indexOf("98")>0) {
			mdm.FileSystem.saveFile(thisFile, contents);
		} else {
			mdm.FileSystem.saveFileUnicode(thisFile, contents);
		}
		mdm.FileSystem.setFileAttribs(thisFile, attrib);
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
	
	function runAction() : Void {

		// v6.4.3 mdm.script.2
		//_root.mdm.setmousecursor("HourGlass");
		mdm.Input.Mouse.setCursor("HourGlass");
		myTrace("running FSP action: "+actionPurpose);
		if (control._lite) {
			//myTrace("calling onQueryFinish.73");
			onQueryFinish();
		} else {
			switch (actionPurpose) {
			case "lockCoursesFile" :
			case "lockMenuFile" :
			case "lockExerciseFile" :
			case "lockFile" :
				var lckPath = filePath.substring(0, filePath.length-3) + "lck";				
				var x = new XML();
				x.master = this;
				x.lckPath = lckPath;
				//x.onData = function(src:String) : Void {
				//	_global.myTrace("in onData with " + src);
				//}				
				
				x.onLoad = function(success:Boolean) : Void {
					//_global.myTrace("open lock file " + this.lckPath);
					var lockingUser:String = "";
					var thisUserLocking:Boolean = false;
					
					if (success) {
						//_global.myTrace("exists already " + this.lckPath);
						// exists, get username that locks the file
						var root = this.firstChild;
						for (var i=0; i<root.childNodes.length; i++) {
							var c = root.childNodes[i];
							// if user is currently locking the file, just update the time
							if (this.master.username.toUpperCase() == c.childNodes[0].firstChild.nodeValue.toUpperCase()) {
								_global.myTrace("and " + this.master.username + " already has a lock");
								thisUserLocking = true;
								c.childNodes[1].firstChild.nodeValue = this.master.control.time.getPaddedDateTime();
							// otherwise get one of the user that locks the file
							} else if (lockingUser=="") {
								// only consider the lock less than 1 hour
								if (Number(this.master.control.time.getPaddedDateTime()) - Number(c.childNodes[1].firstChild.nodeValue) < 6000) {
									lockingUser = c.childNodes[0].firstChild.nodeValue;
								}
							}
						}
						
					//.lck file not found, not locked, create the root element in xmlDoc
					} else {
						//_global.myTrace("doesn't exist " + this.lckPath);
						var c:XMLNode = this.createElement("locks");
						this.appendChild(c);
						var root = this.firstChild;
					}
					
					// if this user doesnt have a lock yet, add it
					if (!thisUserLocking && this.master.username!="") {
						_global.myTrace("add lock for " + this.master.username);
						var l:XMLNode = this.createElement("lock");
						var n:XMLNode = this.createElement("user");
						var t:XMLNode = this.createTextNode(this.master.username);
						n.appendChild(t);
						l.appendChild(n);
						n = this.createElement("time");
						t = this.createTextNode(this.master.control.time.getPaddedDateTime());
						n.appendChild(t);
						l.appendChild(n);
						n = this.createElement("account");
						t = this.createTextNode(this.master.account);
						n.appendChild(t);
						l.appendChild(n);
						root.appendChild(l);
					} else {
						// v6.4.3 where am I coping with the fact that someone else might be locking the file??
						//_global.myTrace("no new lock: thisUserLocking=" + thisUserLocking + " or this.master.username=" + this.master.username);
					}
					
					// save lck file
					if (root.childNodes.length>0) {						
						// v6.4.3 mdm script 2.0
						//_root.mdm.saveutf8_filename(this.lckPath);
						//this.master.mdmFileName = this.lckPath;
						//this.master.mdmFileContents = this.toString();
						//_global.myTrace("interval onSaveFile"); 
						//Delegate.create(this.master, mdmSaveFile); //No this doesn't work
						//this.master.dispatchEvent({type:"onSaveFile"}); // Nor this, still happens immediately
						//this.master.mdmInterval = setInterval(this.master, "onSaveFile", 100, this.lckPath, this.toString());
						// Why doesn't this compile? main.fla is using actionscript 2 ok.
						// See FlashGuru.com - due to the function being left out of intrinsic class definition - or something
						// v6.4.2.7 Pass the object that will broadcast the end event to this function as you simply cannot do it from here!
						// But we don't care too much about lock files, so don't bother
						//var intID:Number = _global['setTimeout'](this.master, "onSaveFile", 100, this.lckPath, this.toString());
						var intID:Number = _global['setTimeout'](this.master, "onSaveFile", 100, this.lckPath, this.toString(), undefined);
					}
					
					// query finish
					//_global.myTrace("calling onQueryFinish.154");
					this.master.onQueryFinish();
				}
				
				//myTrace("try to load lock file " + lckPath);
				x.load(lckPath+"?nocache="+random(999999));
				
				break;
				
			case "releaseFile" :
			case "releaseCourseFileToMenu" :
			case "releaseMenuFileToCourse" :
			case "releaseMenuFileToExercise" :
			case "releaseExerciseFileToMenu" :
				var lckPath = filePath.substring(0, filePath.length-3) + "lck";
				myTrace("release " + lckPath);
				
				var x = new XML();
				x.master = this;
				x.lckPath = lckPath;
				x.onLoad = function(success:Boolean) : Void {
					//_global.myTrace("onLoad " + success);
					// check if .lck file exists
					if (success) {
						var root = this.firstChild;
						for (var i=root.childNodes.length-1; i>=0; i--) {
							var c = root.childNodes[i];
							// remove all the lock nodes of this user
							if (this.master.username.toUpperCase() == c.childNodes[0].firstChild.nodeValue.toUpperCase()) {
								c.removeNode();
							}
						}
						
						// delete the .lck file if there's no node in it
						if (root.childNodes.length==0) {
							// v6.4.3 mdm script 2.0
							//_root.mdm.deletefile(this.lckPath);
							//_global.myTrace("delete lock file as empty");
							//this.master.mdm.FileSystem.deleteFileUnicode(this.lckPath);
							//this.master.mdmFileName = this.lckPath;
							//_global.myTrace("interval onDeleteFile"); 
							//Delegate.create(this.master, mdmSaveFile); //No this doesn't work
							//this.master.dispatchEvent({type:"onSaveFile"}); // Nor this, still happens immediately
							// NOTE. There is a problem here in that you can't call these several times in a row
							// as it will remove the previous intervals, so you will end up running some too much.
							//this.master.mdmInterval = setInterval(this.master, "onDeleteFile", 100, this.lckPath);
							var intID:Number = _global['setTimeout'](this.master, "onDeleteFile", 100, this.lckPath);
							
						// save the .lck file as there are still some other users using it
						} else {
							// v6.4.3 mdm script 2.0
							//_root.mdm.saveutf8_filename(this.lckPath);
							
							// set attributes of file to be writable
							//var attrib = "-R";
							//_root.mdm.setfileattribs(this.lckPath, attrib);							
							//fscommand("mdm.saveutf8", this.toString());
							//_global.myTrace("save shrunken lock file");
							//this.master.mdmFileName = ;
							//this.master.mdmFileContents = ;
							//_global.myTrace("interval onSaveFile"); 
							//this.master.mdmInterval = setInterval(this.master, "onSaveFile", 100, this.lckPath, this.toString());
							// But we don't care too much about lock files, so don't bother
							//var intID:Number = _global['setTimeout'](this.master, "onSaveFile", 100, this.lckPath, this.toString());
							var intID:Number = _global['setTimeout'](this.master, "onSaveFile", 100, this.lckPath, this.toString(), undefined);
						}
					}
					
					// query finish
					//_global.myTrace("calling onQueryFinish.206");
					this.master.onQueryFinish();
				}
				x.load(lckPath+"?nocache="+random(999999));
				
				break;
				
			// check lock on a single file
			case "checkLockCourses" :
			case "checkLockExercise" :
			case "checkLockExerciseForOpening" :
			case "checkLockMenuForDelUnit" :
			case "checkLockExerciseForDelExercise" :
				var lckPath = filePath.substring(0, filePath.length-3) + "lck";
				
				var x = new XML();
				x.master = this;
				x.lckPath = lckPath;
				x.onLoad = function(success:Boolean) : Void {
					var lockingUser:String = "";
					
					//check if .lck file exists
					if (success) {
						// exists, get username that locks the file
						var root = this.firstChild;
						for (var i=0; i<root.childNodes.length; i++) {
							var c = root.childNodes[i];
							// if user is currently locking the file, just update the time
							if (this.master.username.toUpperCase() == c.childNodes[0].firstChild.nodeValue.toUpperCase()) {
								c.childNodes[1].firstChild.nodeValue = this.master.control.time.getPaddedDateTime();
							// otherwise get one of the user that locks the file
							} else if (lockingUser=="") {
								// only consider the lock less than 1 hour
								if (Number(this.master.control.time.getPaddedDateTime()) - Number(c.childNodes[1].firstChild.nodeValue) < 6000) {
									lockingUser = c.childNodes[0].firstChild.nodeValue;
								}
							}
						}
						
						// after checking, if there's a locking user, error
						if (lockingUser!="") {
							this.master.onQueryError({lockingUser:lockingUser});
						// otherwise, proceed
						} else {
							//myTrace("calling onQueryFinish.250");
							this.master.onQueryFinish();
						}
						
					// .lck file not found, not locked, proceed
					} else {
						//myTrace("calling onQueryFinish.256");
						this.master.onQueryFinish();
					}
					
				}
				x.load(lckPath+"?nocache="+random(999999));
				
				break;
				
			// check lock on subsequent units & exercises
			case "checkLockForDelCourse" :
				var lckPath = filePath.substring(0, filePath.length-3) + "lck";
				var folderPath = _global.addSlash(_global.getPath(filePath))+"Exercises";
				
				var x = new XML();
				x.master = this;
				x.lckPath = lckPath;
				x.folderPath = folderPath;
				x.onLoad = function(success:Boolean) : Void {
					var lockingUser:String = "";
					
					//check if .lck file exists
					if (success) {
						var root = this.firstChild;
						for (var i=0; i<root.childNodes.length; i++) {
							var c = root.childNodes[i];
							// if user is currently locking the file, just update the time
							if (this.master.username.toUpperCase() == c.childNodes[0].firstChild.nodeValue.toUpperCase()) {
								c.childNodes[1].firstChild.nodeValue = this.master.control.time.getPaddedDateTime();
							// otherwise get one of the user that locks the file
							} else if (lockingUser=="") {
								// only consider the lock less than 1 hour
								if (Number(this.master.control.time.getPaddedDateTime()) - Number(c.childNodes[1].firstChild.nodeValue) < 6000) {
									lockingUser = c.childNodes[0].firstChild.nodeValue;
								}
							}
						}
					}
					
					// if there's no locking user on menu.xml, gotta check each lck file in the exercises folder
					if (lockingUser=="") {
						_global.myTrace(folderPath);
						// v6.4.3 mdm script 2.0
						this.master.onGetLockFileList(this.master.mdm.FileSystem.getFileList(folderPath, "*.lck"));
						//_root.mdm.getfilelist_del(folderPath,"*.lck","%",Delegate.create(this.master, this.master.onGetLockFileList));
					// otherwise, proceed
					} else {
						this.master.onQueryError({lockingUser:lockingUser});
					}
				}
				x.load(lckPath+"?nocache="+random(999999));
				
				break;
				
			case "unzipFile" :
				// unzip the file
				_root.unzip_file=_global.addSlash(basePath)+zipFile;
				_root.unzip_folder=_global.addSlash(basePath)+"unzip_"+zipFile.substr(0,-4);
				_root.unzip_pwd="none";
				
				// v6.4.3 mdm script 2.0
				if (mdm.System.winVerString.indexOf("98")>0) {
					var fileExists = mdm.FileSystem.fileExists(_root.unzip_file);
				} else {
					var fileExists = mdm.FileSystem.fileExistsUnicode(_root.unzip_file);
				}
				//myTrace("does the zip file exist? " + fileExists);
				
				// v6.4.2.5 New ZIP extension
				myTrace("try to unzip " + _root.unzip_file + " to " + _root.unzip_folder);
				//fscommand("flashvnn.ExtractZip","unzip_file,unzip_folder,unzip_pwd");
				mdm.Extensions.flashvnn.ExtractZIP(_root.unzip_file,_root.unzip_folder,_root.unzip_pwd);
				/*
				var thisZipFile:String=_root.unzip_file;
				var thisZipFolder:String=_root.unzip_folder;
				var thisZipPassword:String = "";
				var zincZip = _root.zipHolder.zincZip
				_root.zipHolder.callBack = this;
				//_root.zipHolder.currentFolder = thisZipFolder;
				//zipSuccess = false;
				//zincZip.ExtractDirect(thisZipFile, thisZipFolder, thisZipPassword);
				_global.myTrace("stopMyTrace");
				zincZip.openAndExtract(thisZipFile, thisZipFolder, thisZipPassword);
				*/
				
				//_global.myTrace("file: "+_root.unzip_file);
				//_global.myTrace("folder: "+_root.unzip_folder);
				
				// wait until the folder exists
				// v6.4.3 mdm script 2.0
				// v6.4.3 Even though mdm is asynch, perhaps this isn't extended to the unzip extension. So perhaps you have
				// to wait for that to happen.
				//_root.mdm.folderexists(_root.unzip_folder,"unzip_result");
				intCnt = 0;
				// v6.4.2.5 Base the time you will wait on the file size - guess at 1MB=2 seconds?
				var allowedTime:Number = 2*mdm.FileSystem.getFileSize(_root.unzip_file)/1000000;
				_global.myTrace("zip filesize = " + mdm.FileSystem.getFileSize(_root.unzip_file) + " so allow " + allowedTime);
				intID = setInterval(this, "checkUnzipFile", 5000, 2);
				//myTrace("test if folder has been created");
				/*
				var folderExists = mdm.FileSystem.folderExistsUnicode(_root.unzip_folder);				
				if (folderExists) {
					myTrace("it has");
					onQueryFinish();
				} else {
					myTrace("it hasn't");
					onQueryError();
				}
				//myTrace("delete the zip file");
				// V6.4.3 I don't think you should delete the ZIP file, it might be wanted again
				//mdm.FileSystem.deleteFileUnicode(_root.unzip_file);
				*/
				break;
				
			
			case "importFiles" :
				if (folders.length>0) {
					//_global.myTrace("folders:");
					//_global.myTrace(folders.toString());
					//_global.myTrace("files:");
					//_global.myTrace(files.toString());
					var importing:fspImportFilesClass = new fspImportFilesClass();
					importing.mdmActionRun = this;
					// v6.4.3 Change name from paths.userPath to paths.content
					//importing.userPath = control.paths.userPath;
					// AR v6.4.2.5 And onto MGS Path
					//importing.userPath = control.paths.content;
					importing.userPath = control.paths.MGSPath;
					importing.files = files;
					importing.folders = folders;
					importing.importFiles();
				} else {
					onQueryError();
				}
				break;
				
			case "importFilesToCurrentCourse" :
				if (folders.length>0) {
					//_global.myTrace("folders:");
					//_global.myTrace(folders.toString());
					//_global.myTrace("files:");
					//_global.myTrace(files.toString());
					var importing:fspImportFilesClass = new fspImportFilesClass();
					importing.mdmActionRun = this;
					// v6.4.3 Change name from paths.userPath to paths.content
					//importing.userPath = control.paths.userPath;
					// AR v6.4.2.5 And onto MGS Path
					//importing.userPath = control.paths.content;
					importing.userPath = control.paths.MGSPath;
					importing.files = files;
					importing.folders = folders;
					importing.menuXmlPath = menuXmlPath;
					importing.importFilesToCurrentCourse();
					// v6.4.3 Send MGSEnabled
					//importing.MGSEnabled = String(control._enableMGS);
				} else {
					onQueryError();
				}
				break;
				
			case "exportFiles" :
				if (folders.length>0) {
					var exporting:fspExportFilesClass = new fspExportFilesClass();
					exporting.mdmActionRun = this;
					exporting.files = files;
					exporting.folders = folders;
					exporting.basePath = basePath;
					// v6.4.2.5 Also send original path
					if (control._enableMGS) {
						exporting.originalContentPath = _global.NNW.paths.content;
						_global.myTrace("export to basepath = " + basePath);
						_global.myTrace("export from MGS, so also send original path = " + exporting.originalContentPath);
					}
					// v6.4.3 done separately
					//exporting.SCORM = SCORM;
					// Why don't I set exporting.cid and exporting.cname? Are they sent in mdmActionRun?
					exporting.exportFiles();
				} else {
					onQueryError();
				}
				break;
				
			//v6.4.2.3 DK, SCORM export
			case "createSCO" :
				myTrace("in createSCO");
				var createSCORM:fspScormExportClass = new fspScormExportClass();
				createSCORM.uids = uids;
				createSCORM.unames = unames;
				createSCORM.cid = cid;
				createSCORM.cname = cname;
				createSCORM.mdmActionRun = this;
				createSCORM.basePath = basePath;
				createSCORM.SCORM = SCORM;
				// v6.4.3 Add the software path
				createSCORM.serverPath = serverPath;
				createSCORM.createSCO();				
				break;				
				
			
			case "checkFileForDownload" :
				if (filePath.length>0) {
					intCnt = 0;
					checkFileExists();
				} else {
					onQueryError();
				}
				break;
			
			// all other actions
			default:				
				//myTrace("calling onQueryFinish.428");
				onQueryFinish();
				break;
			}
		}
		//myTrace("drop out of mdmActionRun.runAction")
	}
	
	function checkFileExists() : Void {
		// v6.4.3 You won't need this interval stuff anymore
		//clearInterval(intID);
		myTrace("checkFileExists for " + filePath);
		// v6.4.3 mdm script 2.0
		//_root.mdm.fileexists(filePath,Delegate.create(this, this.onGetFileExists));
		if (mdm.System.winVerString.indexOf("98")>0) {
			var fileExists = mdm.FileSystem.fileExists(filePath);
		} else {
			var fileExists = mdm.FileSystem.fileExistsUnicode(filePath);
		}
		if (fileExists) {
			//myTrace("calling onQueryFinish.443");
			onQueryFinish();
		} else {
			onQueryError();
			//myTrace("can't find file, so delete folder");
			//mdm.FileSystem.deleteFolderUnicode(_root.zip_folder);
		}
		// v6.4.3 mdm script 2.0
		//mdm.FileSystem.deleteFolderUnicode(_root.zip_folder);
		var builtCommand = "cmd.exe /K RMDIR /S /Q \"" + _root.zip_folder + "\"";
		var command = mdm.System.Paths.system + builtCommand;
		myTrace(command);
		mdm.System.execStdOut(command);
	}

	// rewritten so not need with mdm script 2.0
	/*
	function onGetFileExists(b) : Void {
		myTrace("onGetFileExists");
		// v6.4.3 mdm script 2.0
		//if (b.indexOf("true")>-1) {
		if (b) {
			onQueryFinish();
			// v6.4.3 mdm script 2.0
			//_root.mdm.deletefolder(_root.zip_folder,"noask");
			mdm.FileSystem.deleteFolderUnicode(_root.zip_folder);
		// v6.4.3 You won't need this interval stuff anymore
		//} else if (intCnt<5) {
		//	intID = setInterval(this, "checkFileExists", 1000);
		//	// v6.4.3 This was not set
		//	intCnt++;
		} else {
			onQueryError();
			myTrace("can't find file, so delete folder");
			// v6.4.3 mdm script 2.0
			//_root.mdm.deletefolder(_root.zip_folder,"noask");
			mdm.FileSystem.deleteFolderUnicode(_root.zip_folder);
		}
	}
	*/	
	// v6.4.2.5 A new ZIP extension
	/*
	public function onZipOpen(zipInfo:String):Void {
		myTrace("onZipOpen=" + zipInfo);
	}
	public function onZipProcessing(percent:Number):Void {
		myTrace("onZipProcessing=" + percent + "%");
	}
	public function onZipExtractComplete(success:Boolean):Void {
		myTrace("onZipExtractComplete=" + success);
		//zipSuccess = true;
		checkUnzipFile();
	}
	*/
	// v6.4.3 rewrite for synchronous result
	// v6.4.3 But might still need is as flashvnn is probably not asynch
	// 5 seconds is not enough for a large file. Can we find file size and base the count on that?
	// Ahh. No it was going on because the ZIP was empty. So need some error checking on the ZIP.
	// Again, I thought it was too big, but this time it had an invalid structure if I tried to use WinZIP to delete a file.
	function checkUnzipFile(allowedTime:Number) : Void {
		_global.myTrace("startMyTrace");
		_global.myTrace("checkUnzip for " + _root.unzip_folder);
		if (mdm.System.winVerString.indexOf("98")>0) {
			var folderExists = mdm.FileSystem.folderExists(_root.unzip_folder);
		} else {
			var folderExists = mdm.FileSystem.folderExistsUnicode(_root.unzip_folder);
		}
		// v6.4.2.5 Still failing if slow, need to allow more time
		//if (intCnt<5) {
		if (allowedTime == undefined || allowedTime<5) allowedTime=5;
		if (allowedTime>60) allowedTime=60;
		if (intCnt<allowedTime) { // bump to 15 seconds
			// unzip finished
			//if (Boolean(_root.unzip_result)) { // This doesn't work as unzip_result can = "false" or "true"
			if (folderExists) {
				myTrace("unzipped to folder");
				clearInterval(intID);
				//myTrace("calling onQueryFinish.489");
				onQueryFinish();
				// v6.4.3 Don't delete the copied export as you might want to import again
				//_root.mdm.deletefile(_root.unzip_file);
				
			// not yet found, check again
			} else {
				myTrace("not created zip folder yet");
				//_root.mdm.folderexists(_root.unzip_folder,"unzip_result");
				intCnt++;
			}
			
		// time out
		} else {
			myTrace("giving up on unzip to folder");
			clearInterval(intID);
			onQueryError();
			// v6.4.3 Don't delete the copied export as you might want to import again
			//_root.mdm.deletefile(_root.unzip_file);
		}
	}
	
	// this function is specifically written for checking each lck file in the exercises directory
	// v6.4.3 rewritten to accept an arry
	//function onGetLockFileList(file:String) : Void {
	function onGetLockFileList(a:Array) : Void {
		// if no file, proceed
		//if (file==undefined||file=="") {
		if (a == undefined || a.length==0) {
			//myTrace("calling onQueryFinish.519");
			onQueryFinish();
		} else {
			//var a:Array = file.split("%");
			totalLck = a.length;	// total number of files gotta be opened
			if (totalLck>0) {
				// initialize the loop counter
				lckCnt = 0;
				// start looping!
				checkExerciseLckFile(a);
			}
		}
	}
	
	function checkExerciseLckFile(a:Array) : Void {
		if (a[lckCnt]!=undefined && a[lckCnt]!="") {
			var x = new XML();
			x.master = this;
			x.a = a;
			x.onLoad = function(success:Boolean) : Void {
				var lockingUser:String = "";
				
				//check if .lck file exists
				if (success) {
					var root = this.firstChild;
					for (var i=0; i<root.childNodes.length; i++) {
						var c = root.childNodes[i];
						// if user is currently locking the file, just update the time
						if (this.master.username.toUpperCase() == c.childNodes[0].firstChild.nodeValue.toUpperCase()) {
							c.childNodes[1].firstChild.nodeValue = this.master.control.time.getPaddedDateTime();
						// otherwise get one of the user that locks the file
						} else if (lockingUser=="") {
							// only consider the lock less than 1 hour
							if (Number(this.master.control.time.getPaddedDateTime()) - Number(c.childNodes[1].firstChild.nodeValue) < 6000) {
								lockingUser = c.childNodes[0].firstChild.nodeValue;
							}
						}
					}
				}
				
				this.master.lckCnt++;
				if (lockingUser!="") {
					this.master.onQueryError({lockingUser:lockingUser});
				} else if (lckCnt<totalLck) {
					this.master.checkExerciseLckFile(this.a);
				} else {
					//myTrace("calling onQueryFinish.565");
					this.master.onQueryFinish();
				}
			}
			x.load(a[lckCnt]+"?nocache="+random(999999));
		} else {
			//myTrace("calling onQueryFinish.571");
			onQueryFinish();
		}
	}
	
	function promptFileSave() : Void {
		//myTrace("promptFileSave");
		// set upload form's button text
		// v6.4.3 mdm script 2.0
		mdm.Dialogs.BrowseFile.buttonText = "Save"; // why not translated?
		//_root.mdm.browsefile_buttontext("Save");
		
		// set upload form's title
		mdm.Dialogs.BrowseFile.title = "Select a file";  // why not translated?
		//_root.mdm.browsefiletitle("Select a file");
		
		// set filter list
		var filterList = "ZIP Files|*.zip";
		mdm.Dialogs.BrowseFile.filterList = filterList;
		//_root.mdm.browsefile_filterlist(filterList);
		
		// set directory for browsing in upload form
		mdm.Dialogs.BrowseFile.defaultDirectory = mdm.System.Paths.personal;
		//_root.mdm.browsefiledir(_root.mdm_personal);
		
		// show upload form
		this.saveFile(mdm.Dialogs.BrowseFile.show());
		//_root.mdm.browsefile(Delegate.create(this, this.saveFile));
	}
	
	function saveFile(f:String) : Void {
		var fn:String = _global.getFilename(f);
		myTrace("mdmActionRun.saveFile=" + fn);
		if (fn!=undefined && fn!="undefined" && fn!="") {
			if (fn.substr(-4, 4).toLowerCase()!=".zip") {
				f += ".zip";
			}
			newZipFile = f;
			// v6.4.3 mdm script 2.0
			//_root.mdm.copyfile(filePath, newZipFile);
			if (mdm.System.winVerString.indexOf("98")>0) {
				mdm.FileSystem.copyFile(filePath, newZipFile);
			} else {
				mdm.FileSystem.copyFileUnicode(filePath, newZipFile);
			}
			//intCnt = 0;
			//intID = setInterval(this, "getFileSize", 50);
			//mdm.FileSystem.deleteFileUnicode(filePath);
		} else {
			// user cancelled
			//_root.mdm.deletefile(filePath);
			//mdm.FileSystem.deleteFileUnicode(filePath);
		}
		if (mdm.System.winVerString.indexOf("98")>0) {
			mdm.FileSystem.deleteFile(filePath);
		} else {
			mdm.FileSystem.deleteFileUnicode(filePath);
		}
	}

	// written out for synchronous mdm script 2.0
	/*
	private function getFileSize() : Void {
		_root.mdm.getfilesize(newZipFile, Delegate.create(this, this.deleteZipFile));
	}
	
	// written out for synchronous mdm script 2.0
	private function deleteZipFile(n) : Void {
		if (Number(n)>0) {
			_root.mdm.deletefile(filePath);
		} else if (intCnt>10) {
			clearInterval(intID);
		} else {
			intCnt++;
		}		
	}
	*/
	
	function onQueryFinish() : Void {
		//myTrace("called from " + arguments.caller);
		// v6.4.3 mdm script 2.0
		mdm.Input.Mouse.setCursor("Default");

		//_root.mdm.setmousecursor("Default");
		//myTrace("complete FSP action: "+actionPurpose);
		switch (actionPurpose) {
		case "sendEmail" :
			//_root.mdm.sendmail_clientside("comments@clarityenglish.com",subject,body,"");
			mdm.Network.Mail.sendClientSide("support@clarity.com.hk", subject, body, "");
			break;
		case "checkLockCourses" :
			control.writeCourseXML();
			break;
		case "checkLockForDelCourse" :
			control.delCourse();
			break;
		case "checkLockExercise" :
			control.writeExerciseXML();
			break;
		case "checkLockExerciseForOpening" :
			control.releaseUnitFileToExercise();
			break;
		case "checkLockMenuForDelUnit" :
			control.delUnit();
			break;
		case "checkLockExerciseForDelExercise" :
			control.delExercise();
			break;
		case "lockCoursesFile" :
			control.xmlCourse.loadXMLAfterLocking();
			break;
		case "lockMenuFile" :
			control.xmlUnit.loadXMLAfterLocking();
			break;
		case "lockExerciseFile" :
			control.xmlExercise.loadXMLAfterLocking();
			break;
		case "lockFile" :	// this is for locking file that is saved instead of opened
			// do nothing
			break;
		case "releaseExerciseFileToMenu" :
			control.lockFile("Unit");
			break;
		case "releaseMenuFileToExercise" :
			control.lockFile("Exercise");
			break;
		case "releaseMenuFileToCourse" :
			control.xmlCourse.loadXML();
			break;
		case "releaseCourseFileToMenu" :
			control.loadUnitXML();
			break;
		case "releaseFile" :
			// do nothing
			break;
		case "previewCourses" :
		case "previewMenu" :
		case "previewExercise" :
			control.previewByLocalConn();
			break;
		case "setUploadSettings" :
			control.upload.showUploadForm();
			break;
		case "unzipFile" :
			control.loadImportFiles(_root.unzip_folder);
			break;
		case "importFiles" :
			control.onImportFilesSuccess();
			break;
		case "importFilesToCurrentCourse" :
			control.onImportFilesToCurrentCourseSuccess();
			break;
		case "exportFiles" :
			control.onExportFilesSuccess(_root.zip_file);
			break;
		//v6.4.2.3 DK, createSCO success
		case "createSCO" :
			//reuse onExportFilesSuccess()
			control.onExportFilesSuccess(_root.zip_file);
			break;
		case "checkFileForDownload" :
			//control.promptFileDownload(filePath);
			promptFileSave();
			break;
		}
	}
	
	function onQueryError(attr:Object) : Void {
		// v6.4.3 mdm script 2.0
		mdm.Input.Mouse.setCursor("Default");
		//_root.mdm.setmousecursor("Default");
		myTrace("error in FSP action: "+actionPurpose);
		switch (actionPurpose) {
		case "checkLockCourses" :
			myTrace(attr.lockingUser+" is locking the file.");
			control.promptOverwrite("Course", attr.lockingUser);
			break;
		case "checkLockExercise" :
			myTrace(attr.lockingUser+" is locking the file.");
			control.promptOverwrite("Exercise", attr.lockingUser);
			break;
		case "checkLockExerciseForOpening" :
			myTrace(attr.lockingUser+" is locking the file.");
			control.view.showPopup("lockExerciseError", attr.lockingUser);
			break;
		case "checkLockMenuForDelUnit" :
			myTrace(attr.lockingUser+" is locking the file.");
			control.view.showPopup("lockMenuError", attr.lockingUser);
			break;
		case "checkLockExerciseForDelExercise" :
			myTrace(attr.lockingUser+" is locking the file.");
			control.view.showPopup("lockExerciseError", attr.lockingUser);
			break;
		case "checkLockForDelCourse" :
			myTrace(attr.lockingUser+" is locking the file.");
			control.view.showPopup("lockMenuError", attr.lockingUser);
			break;
		case "unzipFile" :
			myTrace("fail to unzip the file");
			control.onUnzipFail();
			break;
		case "importFiles" :
		case "importFilesToCurrentCourse" :
			control.onImportFilesFail();
			break;
		case "exportFiles" :
			control.onExportFilesFail();
			myTrace("fail to export the file");
			break;
		//v6.4.2.3 DK, create SCORM files error
		case "createSCO" :
			control.onCreateSCOFail();
			myTrace("fail to create SCORM file");
			break;
		case "checkFileForDownload" :
			control.onExportFilesFail();
			myTrace("fail to zip the file");
			break;
		}
	}
	
}