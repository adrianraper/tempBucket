/*
this class fires queries in XML:
<query>
	<node>value</node>
</query>
*/

import Classes.actionResponse;
import Classes.mdmActionRunClass;

class Classes.actionRun extends XML {
	
	var actionPurpose:String;
	var _serverPath:String;
	
	// 6.4.1.2, DL: local or use server
	var __server:Boolean;
	
	// v6.4.1.2, DL: create an mdmActionRunClass object
	var mdmActionRun:mdmActionRunClass;
	
	function actionRun() {
		actionPurpose = "";
		_serverPath = _global.NNW.paths.serverPath;
		__server = _global.NNW.__server;
		if (__server) {
		// v6.4.3 Surely we don't want to init this class if we are not in MDM?
		} else {
			mdmActionRun = new mdmActionRunClass();
		}
	}

	function myTrace(s:String) : Void {
		_global.myTrace(s);
	}
	
	function formQuery(obj:Object) : Void {
		if (__server) {
			removeAllNodes();
			var queryNode:XMLNode = this.createElement("query");
			this.appendChild(queryNode);
			// v6.4.2.6 If you are running a script related to files, you need userDataPath for new getRootDir 
			// This is many, so simply add it to all queries - cannot do any harm. Hijack basePath parameter?
			// This is used in lots of import/export type scripts already so don't overwrite. Might not be smart.
			if (obj.userDataPath==undefined) {
				obj.userDataPath = _global.NNW.paths.userDataPath;
			}
			var thisValue="";
			for (var i in obj) {
				var objNode:XMLNode = this.createElement(i);
				// v6.5.4.7 PHP running on Windows is not tolerant of backslashes
				// No, not true, it was confusion over CID and SubFolder in the course.xml
				//if (_global.NNW.paths.scripting.toLowerCase()=="php") {
				//	thisValue = _global.replace(obj[i], "\\", "\\\\");
				//} else {
					thisValue = obj[i];
				//}
				var objValue:XMLNode = this.createTextNode(thisValue);
				objNode.appendChild(objValue);
				queryNode.appendChild(objNode);
			}
		} else {
			delete mdmActionRun;
			mdmActionRun = new mdmActionRunClass();
			mdmActionRun.actionPurpose = actionPurpose;
			for (var attr in obj) {
				mdmActionRun[attr] = obj[attr];
			}
		}
	}
	
	function addParameter(name:String, value:String) : Void {
		var objNode:XMLNode = this.createElement(name);
		// v6.5.4.7 PHP running on Windows is not tolerant of backslashes
				// No, not true, it was confusion over CID and SubFolder in the course.xml
		//if (_global.NNW.paths.scripting.toLowerCase()=="php") {
		//	var thisValue = _global.replace(value, "\\", "\\\\");
		//} else {
			var thisValue = value;
		//}
		var objValue:XMLNode = this.createTextNode(thisValue);
		objNode.appendChild(objValue);
		this.firstChild.appendChild(objNode);
	}
	
	function sendQuery() : Void {
		if (__server) {
			var actionResponse = new actionResponse();
			actionResponse.actionPurpose = actionPurpose;

			// v6.4.1.2, DL: handle both scripting language (ASP/PHP)
			// refresh the _serverPath to ensure it has been updated after reading the licence
			_serverPath = _global.NNW.paths.serverPath;
			// default as ASP as the moment
			if (_serverPath.substr(-3, 3).toLowerCase()=="php") {
				var runActionPath:String = _serverPath+"/runAction.php";
			} else {
				var runActionPath:String = _serverPath+"/runAction.asp";
			}
			
			this.sendAndLoad(runActionPath+"?prog=NNW", actionResponse);
			//myTrace("Query XML = "+this.firstChild.toString());
			//myTrace("path = "+runActionPath+"?prog=NNW");
		} else {
			mdmActionRun.runAction();
		}
	}
	
	/* remove all nodes in this */
	function removeAllNodes() : Void {
		if (this.hasChildNodes()) {
			for (var i in this.childNodes) {
				this.childNodes[i].removeNode();
			}
		}
	}
	
	function preview(purpose:String) : Void {
		var _username = _global.NNW.control._username;
		var _password = _global.NNW.control._password;
		// v6.4.3 Change name
		//var _contentPath = _global.NNW.paths.userPath;
		// AR v6.4.2.5 And on to MGS path - although I don't think you actually use this parameter here
		//var _contentPath = _global.NNW.paths.content;
		var _contentPath = _global.NNW.paths.MGSPath;
		actionPurpose = purpose;
		formQuery({purpose:actionPurpose, username:_username, password:_password, contentPath:_contentPath});
		sendQuery();
	}
	
	function sendEmail(subject:String, body:String) : Void {
		// v0.15.0, DL: send email with full name and email of the user
		var _username = _global.NNW.control._username;
		if (_global.NNW.control._fullname!="") {
			_username = _global.NNW.control._fullname;
		}
		var _email = _global.NNW.control._emailaddress;
		actionPurpose = "sendEmail";
		formQuery({purpose:actionPurpose, sender:_username, email:_email, subject:subject, body:body});
		sendQuery();
	}
	
	// v0.16.1, DL: upload image
	function uploadImage(currentCoursePath:String) : Void {
		actionPurpose = "setUploadSettings";
		formQuery({purpose:actionPurpose, uploadPath:currentCoursePath, uploadType:"image"});
		sendQuery();
	}
	// v0.16.1, DL: upload audio
	function uploadAudio(currentCoursePath:String) : Void {
		actionPurpose = "setUploadSettings";
		formQuery({purpose:actionPurpose, uploadPath:currentCoursePath, uploadType:"audio"});
		sendQuery();
	}
	function uploadMultipleAudio(currentCoursePath:String) : Void {
		actionPurpose = "setUploadSettings";
		formQuery({purpose:actionPurpose, uploadPath:currentCoursePath, uploadType:"audio", uploadMultiple:"true"});
		sendQuery();
	}
	// v0.16.1, DL: upload video
	function uploadVideo(currentCoursePath:String) : Void {
		actionPurpose = "setUploadSettings";
		formQuery({purpose:actionPurpose, uploadPath:currentCoursePath, uploadType:"video"});
		sendQuery();
	}
	// v0.16.1, DL: upload zip file for import
	function uploadImport(userPath:String) : Void {
		actionPurpose = "setUploadSettings";
		formQuery({purpose:actionPurpose, uploadPath:userPath, uploadType:"zip"});
		sendQuery();
	}
	
	// v0.16.1, DL: lock courses file
	function lockCoursesFile(path:String) : Void {
		var _username = _global.NNW.control._username;
		actionPurpose = "lockCoursesFile";
		formQuery({purpose:"lockFile", filePath:path, username:_username, account:""});
		sendQuery();
	}
	// v0.16.1, DL: lock menu file
	function lockMenuFile(path:String) : Void {
		var _username = _global.NNW.control._username;
		actionPurpose = "lockMenuFile";
		formQuery({purpose:"lockFile", filePath:path, username:_username, account:""});
		sendQuery();
	}
	// v0.16.1, DL: lock exercise file
	function lockExerciseFile(path:String) : Void {
		var _username = _global.NNW.control._username;
		actionPurpose = "lockExerciseFile";
		formQuery({purpose:"lockFile", filePath:path, username:_username, account:""});
		sendQuery();
	}
	// v0.16.1, DL: lock file
	function lockFile(path:String) : Void {
		var _username = _global.NNW.control._username;
		actionPurpose = "lockFile";
		formQuery({purpose:"lockFile", filePath:path, username:_username, account:""});
		sendQuery();
	}
	// v0.16.1, DL: check courses file locking
	function checkLockCourses(path:String) : Void {
		var _username = _global.NNW.control._username;
		actionPurpose = "checkLockCourses";
		formQuery({purpose:"checkLockFile", filePath:path, username:_username, account:""});
		sendQuery();
	}
	// v0.16.1, DL: check exercise file locking
	function checkLockExercise(path:String) : Void {
		var _username = _global.NNW.control._username;
		actionPurpose = "checkLockExercise";
		formQuery({purpose:"checkLockFile", filePath:path, username:_username, account:""});
		sendQuery();
	}
	// v6.4.0.1, DL: check exercise file locking (before opening it)
	function checkLockExerciseForOpening(path:String) : Void {
		var _username = _global.NNW.control._username;
		actionPurpose = "checkLockExerciseForOpening";
		formQuery({purpose:"checkLockFile", filePath:path, username:_username, account:""});
		sendQuery();
	}
	// v6.4.0.1, DL: check unit file locking for deleting unit
	function checkLockMenuForDelUnit(path:String) : Void {
		var _username = _global.NNW.control._username;
		actionPurpose = "checkLockMenuForDelUnit";
		formQuery({purpose:"checkLockFile", filePath:path, username:_username, account:""});
		sendQuery();
	}
	// v6.4.0.1, DL: check exercise file locking for deleting exercise
	function checkLockExerciseForDelExercise(path:String) : Void {
		var _username = _global.NNW.control._username;
		actionPurpose = "checkLockExerciseForDelExercise";
		formQuery({purpose:"checkLockFile", filePath:path, username:_username, account:""});
		sendQuery();
	}
	// v6.4.0.1, DL: check menu & exercise files locking for deleting course
	function checkLockForDelCourse(path:String) : Void {
		var _username = _global.NNW.control._username;
		actionPurpose = "checkLockForDelCourse";
		formQuery({purpose:"checkLockCourse", filePath:path, username:_username, account:""});
		sendQuery();
	}
	// v6.4.3 Added for bigger deleting
	function checkLockForDelCourseFolder(path:String) : Void {
		var _username = _global.NNW.control._username;
		actionPurpose = "checkLockForDelCourseFolder";
		formQuery({purpose:"checkLockCourse", filePath:path, username:_username, account:""});
		sendQuery();
	}
	// v0.16.1, DL: release file
	function releaseFile(path:String) : Void {
		var _username = _global.NNW.control._username;
		actionPurpose = "releaseFile";
		formQuery({purpose:actionPurpose, filePath:path, username:_username});
		sendQuery();
	}
	// v6.4.0.1, DL: release course file and then go to unit screen
	function releaseCourseFileToMenu(path:String) : Void {
		var _username = _global.NNW.control._username;
		actionPurpose = "releaseCourseFileToMenu";
		formQuery({purpose:"releaseFile", filePath:path, username:_username});
		sendQuery();
	}
	// v6.4.0.1, DL: release menu file and then go to course screen
	function releaseMenuFileToCourse(path:String) : Void {
		var _username = _global.NNW.control._username;
		actionPurpose = "releaseMenuFileToCourse";
		formQuery({purpose:"releaseFile", filePath:path, username:_username});
		sendQuery();
	}
	// v6.4.0.1, DL: release menu file and then go to exercise screen
	function releaseMenuFileToExercise(path:String) : Void {
		var _username = _global.NNW.control._username;
		actionPurpose = "releaseMenuFileToExercise";
		formQuery({purpose:"releaseFile", filePath:path, username:_username});
		sendQuery();
	}
	// v6.4.0.1, DL: release exercise and then go to unit screen
	function releaseExerciseFileToMenu(path:String) : Void {
		var _username = _global.NNW.control._username;
		actionPurpose = "releaseExerciseFileToMenu";
		formQuery({purpose:"releaseFile", filePath:path, username:_username});
		sendQuery();
	}
	
	// v6.4.2 AR separate function for SCORM SCO and regular export
	// v6.5.5.3 Need to pass the prefix for SCORMStart.html customisation
	function createSCO(basePath:String, cid:Number, cname:String, uids:Array, unames:Array) : Void {
		actionPurpose = "createSCO";
		if (__server) {
			//v6.4.2 AR I don't think that you CAN send arrays as arguments outside FSP, so it is done
			//by passing the first and then adding each extra as a new node.
			//formQuery({purpose:actionPurpose, uids:uids, unames:unames, basePath:basePath, cid:cid, cname:cname});
			formQuery({purpose:actionPurpose, uid:uids[0], uname:unames[0], basePath:basePath, cid:cid, cname:cname});
			if (uids.length>1) {
				for (var i=1; i<uids.length; i++) {
					addParameter("UID", uids[i]);
				}
			}
			if (unames.length>1) {
				for (var i=1; i<unames.length; i++) {
					addParameter("UNAME", unames[i]);
				}
			}
			// v6.4.2.7 I need to pass the serverPath so that asp doesn't have to try and get a parent path for SCORM files
			//myTrace("serverPath=" + _global.NNW.paths.main);
			// I am going to add userDataPath if it is relative
			if (_global.NNW.paths.main.indexOf("..")>=0) {
				// break the udp into folders
				//myTrace("userDataPath=" + _global.NNW.paths.userDataPath);
				var rootFolders = _global.addSlash(_global.NNW.paths.userDataPath).split("/");
				// since we know paths.root ends in a slash, the array starts one too long
				rootFolders.pop(); 
				// do the same for the server folder
				var serverFolders = _global.NNW.paths.main.split("/");
				// if the first folder is a parent navigator, drop it and the matching root one
				while (serverFolders[0] == ".." && serverFolders.length>1 && rootFolders.length>1) {
					//trace(contentFolders[0]);
					myTrace("drop " + rootFolders[rootFolders.length-1]);
					rootFolders.pop();
					serverFolders.shift();
				}
				var fullServerPath = _global.addSlash(rootFolders.join("/")) + serverFolders.join("/");
			// Just use as is if it is absolute
			} else if (_global.NNW.paths.main.indexOf("/")==0) {
				var fullServerPath = _global.NNW.paths.main;
			// I am going to add userDataPath if it is relative
			} else {
				var fullServerPath = _global.addSlash(_global.NNW.paths.userDataPath) + _global.NNW.paths.main;
			}
			addParameter("SERVERPATH", fullServerPath);
			//myTrace("Adrian - about to run SCORM query:");
			// v6.5.5.3 Need to pass the prefix for SCORMStart.html customisation
			if (_global.NNW._accountPrefix!=undefined && _global.NNW._accountPrefix!="") {
				addParameter("prefix", _global.NNW._accountPrefix);
			}

			myTrace("actionRun.createSCO:" + this.toString());
		} else {
			// v6.4.3 Send the software path
			//formQuery({purpose:actionPurpose, uids:uids, unames:unames, basePath:basePath, cid:cid, cname:cname});
			formQuery({purpose:actionPurpose, uids:uids, unames:unames, basePath:basePath, cid:cid, cname:cname, serverPath:_global.NNW.paths.main});
		}
		sendQuery();
	}
	
	// v0.16.1, DL: zip files
	function exportFiles(basePath:String, files:Array, folders:String, SCORM:Boolean) : Void {
		// v6.4.2, DL: add SCORM
		var product = "AP";
		if (SCORM) {
			switch (_global.NNW.interfaces.getInterface().toUpperCase()) {
			case "BUSINESSWRITING" :
			case "BW" :
				product = "BW";
				break;
			case "REACTIONS" :
			case "RO" :
				product = "RO";
				break;
			case "TENSEBUSTER" :
			case "TBO" :
			case "TB" :
				product = "TB";
				break;
			case "STUDYSKILLSSUCCESS" :
			case "SSSO" :
			case "SSS" :
				product = "SSS";
				break;
			}
		}
		
		actionPurpose = "exportFiles";
		if (__server) {
			// v6.4.3 Pass the course attributes to make a course node
			var cid:Number = _global.NNW.control.data.currentCourse.id;
			var cname:String = escape(_global.NNW.control.data.currentCourse.name);
			//myTrace("actionRun.cname=" + cname);
			//var originalContentPath:String = _global.NNW.control.data.originalContentFolder;
			// v6.5.0.1 You might need subFolder as well as courseID for things like Tense Buster where they are different
			if (_global.NNW.control.data.currentCourse.subFolder<> cid) {
				var csubfolder:String = _global.NNW.control.data.currentCourse.subFolder;
			} else {
				// v6.5.1 Well, if they are the same, it might be easier to pass it anyway
				var csubfolder:String = String(cid);
			}
			//formQuery({purpose:actionPurpose, file:files[0], folder:folders[0], basePath:basePath, SCORM:SCORM, cid:cid, cname:cname, originalContentPath:_global.NNW.paths.content});
			formQuery({purpose:actionPurpose, file:files[0], folder:folders[0], basePath:basePath, SCORM:SCORM, cid:cid, csubfolder:csubfolder, cname:cname, originalContentPath:_global.NNW.paths.content});
			if (files.length>1) {
				for (var i=1; i<files.length; i++) {
					// v6.5.4.7 I don't know if ASP is tolerant of either slashes?
					//if (_global.NNW.control.login.licence.scripting.toLowerCase()=="php") {
					//	addParameter("file", _global.replace(files[i], "\\", "/"));
					//} else {
						addParameter("file", files[i]);
					//}
				}
			}
			if (folders.length>1) {
				for (var i=1; i<folders.length; i++) {
					addParameter("folder", folders[i]);
				}
			}
			// v6.4.2, DL: add SCORM to PHP version
			//if (SCORM) {
			//	addParameter("product", product);
			//}
			// I am here after clicking on SCORM button
			//myTrace("Adrian - about to run export query");
			myTrace("actionRun.exportFiles:" + this.toString());
		} else {
			formQuery({purpose:actionPurpose, files:files, folders:folders, basePath:basePath, SCORM:SCORM});
		}
		sendQuery();
	}
	// v0.16.1, DL: download file
	function checkFileForDownload(file:String) : Void {
		myTrace("checkFileForDownload=" + file);
		actionPurpose = "checkFileForDownload";
		formQuery({purpose:actionPurpose, filePath:file});
		sendQuery();
	}
	// v0.16.1, DL: unzip file
	function unzipFile(file:String, path:String) : Void {
		actionPurpose = "unzipFile";
		formQuery({purpose:actionPurpose, zipFile:file, basePath:path});
		sendQuery();
	}
	// v0.16.1, DL: move the files for importing
	function importFiles(basePath:String, files:Array, folders:String) : Void {
		actionPurpose = "importFiles";
		if (__server) {
			formQuery({purpose:actionPurpose, file:files[0], folder:folders[0], basePath:basePath});
			if (files.length>1) {
				for (var i=1; i<files.length; i++) {
					addParameter("file", files[i]);
				}
			}
			if (folders.length>1) {
				for (var i=1; i<folders.length; i++) {
					addParameter("folder", folders[i]);
				}
			}
		} else {
			formQuery({purpose:actionPurpose, files:files, folders:folders, basePath:basePath});
		}
		sendQuery();
	}
	// v6.4.0.1, DL: move the files to the current course
	function importFilesToCurrentCourse(basePath:String, files:Array, folders:String, menuXmlPath:String) : Void {
		actionPurpose = "importFilesToCurrentCourse";
		if (__server) {
			// v6.4.3 Pass the original content folder - oh, surely you don't need this? 
			// But you do need to know if you are in an MGS so that you can set the enabledFlags
			//var originalContentPath:String = _global.NNW.control.data.originalContentFolder;
			var MGSEnabled:String = String(_global.NNW.control._enableMGS);
			//formQuery({purpose:actionPurpose, file:files[0], folder:folders[0], basePath:basePath, menuXmlPath:menuXmlPath});
			//_global.myTrace("basePath=" + basePath);
			//_global.myTrace("menuXmlPath=" + menuXmlPath);
			//_global.myTrace("files[0]=" + files[0]);
			//_global.myTrace("folders[0]=" + folders[0]);
			formQuery({purpose:actionPurpose, file:files[0], folder:folders[0], basePath:basePath, menuXmlPath:menuXmlPath, MGSEnabled:MGSEnabled});
			if (files.length>1) {
				for (var i=1; i<files.length; i++) {
					addParameter("file", files[i]);
				}
			}
			if (folders.length>1) {
				for (var i=1; i<folders.length; i++) {
					addParameter("folder", folders[i]);
				}
			}
		} else {
			formQuery({purpose:actionPurpose, files:files, folders:folders, basePath:basePath, menuXmlPath:menuXmlPath});
		}
		sendQuery();
	}
	// v6.4.2, DL: delete a file
	function deleteFile(file:String) : Void {
		actionPurpose = "deleteFile";
		formQuery({purpose:actionPurpose, filePath:file});
		sendQuery();
	}
}