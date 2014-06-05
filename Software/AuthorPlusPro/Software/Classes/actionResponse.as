class Classes.actionResponse extends XML {
	
	var control:Object;
	
	var actionPurpose:String;
	
	function actionResponse() {
		control = _global.NNW.control;
		actionPurpose = "";
	}
	
	function myTrace(s:String) : Void {
		_global.myTrace(s);
	}
	
	function onLoad(success:Boolean) : Void {
		myTrace("action response back from "+actionPurpose+":");
		myTrace(this.firstChild.toString());
		//var responseNode = this.firstChild.firstChild;
		if (success) {
			// v6.4.2.4 Be friendly and let the script return <note> nodes if it wants. The only ones that count are <action> nodes
			for (var node in this.firstChild) {
				if (this.firstChild[node].nodeName == "action") {
					//var responseNode = this.firstChild.firstChild;
					var responseNode = this.firstChild[node];
					break;
				}
			}
			var attr = responseNode.attributes;
			if (attr.error=="true") {
				onQueryFail(attr);
			} else {
				switch (actionPurpose) {
				case "sendEmail" :
					if (attr.success!="true") {
						onQueryFail(attr);
					}
					break;
				case "previewCourses" :
				case "previewMenu" :
				case "previewExercise" :
					var v = (attr.success=="true") ? true : false;
					// v6.4.1.2, DL: try preview by local connection first
					//control.loadPreview(actionPurpose);
					control.previewByLocalConn();
					break;
					
				// v0.16.1, DL: upload image, audio, video, zip
				case "setUploadSettings" :
					control.upload.showUploadForm();
					break;
					
				// v0.16.1, DL: file locking
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
				case "checkLockCourses" :
					if (attr.success=="false") {
						myTrace(attr.lockingUser+" is locking the file.");
						control.promptOverwrite("Course", attr.lockingUser);
					} else {
						control.writeCourseXML();
					}
					break;
				case "checkLockForDelCourse" :
					if (attr.success=="false") {
						myTrace(attr.lockingUser+" is locking the file.");
						control.view.showPopup("lockMenuError", attr.lockingUser);
					} else {
						control.delCourse();
					}
					break;
				// v6.4.3 Bigger deleting
				case "checkLockForDelCourseFolder" :
					if (attr.success=="false") {
						myTrace(attr.lockingUser+" is locking the file.");
						control.view.showPopup("lockMenuError", attr.lockingUser);
					} else {
						control.delCourseFolder();
					}
					break;
				case "checkLockMenuForDelUnit" :
					if (attr.success=="false") {
						myTrace(attr.lockingUser+" is locking the file.");
						control.view.showPopup("lockMenuError", attr.lockingUser);
					} else {
						control.delUnit();
					}
					break;
				case "checkLockExerciseForDelExercise" :
					if (attr.success=="false") {
						myTrace(attr.lockingUser+" is locking the file.");
						control.view.showPopup("lockExerciseError", attr.lockingUser);
					} else {
						control.delExercise();
					}
					break;
				case "checkLockExercise" :
					if (attr.success=="false") {
						myTrace(attr.lockingUser+" is locking the file.");
						control.promptOverwrite("Exercise", attr.lockingUser);
					} else {
						control.writeExerciseXML();
					}
					break;
				case "checkLockExerciseForOpening" :
					if (attr.success=="false") {
						myTrace(attr.lockingUser+" is locking the file.");
						control.view.showPopup("lockExerciseError", attr.lockingUser);
					} else {
						control.releaseUnitFileToExercise();
					}
				case "releaseFile" :
					break;
				// v6.4.0.1, DL: actions on screens after releasing files
				case "releaseCourseFileToMenu" :
					control.loadUnitXML();
					break;
				case "releaseMenuFileToCourse" :
					control.xmlCourse.loadXML();
					break;
				case "releaseMenuFileToExercise" :
					control.lockFile("Exercise");
					break;
				case "releaseExerciseFileToMenu" :
					control.lockFile("Unit");
					break;
					
				// v0.16.1, DL: zip files
				// v6.4.2 AR: do the same for SCORM SCO creation
				case "exportFiles" :
				case "createSCO" :
					control.onExportFilesSuccess(attr.file);
					break;
				// v0.16.1, DL: download file
				case "checkFileForDownload" :
					if (attr.success=="true") {
						control.promptFileDownload(attr.file);
					} else {
						onQueryFail(attr);
					}
					break;
				// v0.16.1, DL: unzip file
				case "unzipFile" :
					if (attr.success=="true") {
						_global.myTrace("file unzipped");
						control.loadImportFiles(attr.folder);
					} else {
						onQueryFail(attr);
					}
					break;
				// v0.16.1, move files for importing
				case "importFiles" :
					control.onImportFilesSuccess();
					break;
				// v6.4.0.1, move files for importing to current course
				case "importFilesToCurrentCourse" :
					control.onImportFilesToCurrentCourseSuccess();
					break;
				// v6.4.2, DL: delete a file
				case "deleteFile" :
					break;
				}
			}
		} else {
			onQueryFail();
		}
	}
	
	function onQueryFail(attr:Object) : Void {
		switch(actionPurpose) {
		case "sendEmail" :
			myTrace("fail to send email");
			control.sendEmailByProgram();
			break;
		case "previewCourses" :
			myTrace("fail to preview courses");
			break;
		case "previewMenu" :
			myTrace("fail to preview menu");
			break;
		case "previewExercise" :
			myTrace("fail to preview exercise");
			break;
			
		// v0.16.1, DL: upload image, audio, video, zip
		case "setUploadSettings" :
			myTrace("fail to set upload settings");
			break;
			
		// v0.16.1, DL: file locking
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
			break;
		case "checkLockCourses" :
		case "checkLockMenuForDelUnit" :
		case "checkLockExerciseForDelExercise" :
		case "checkLockForDelCourse" :
		// v6.4.3 Add bigger deleting
		case "checkLockForDelCourseFolder" :
			myTrace("fail to check locking of file");
			break;
		// gh#922
		case "checkLockExercise" :
			myTrace("fail to check lock exercise, warn to try later");
			control.promptTryLater("Exercise");
			break;
		case "checkLockExerciseForOpening" :
			myTrace("fail to check locking of file, opens it");
			control.lockFile("Exercise");
			break;
		case "releaseFile" :
			myTrace("fail to release file");
			break;
		// v6.4.0.1, DL: actions on screens after releasing files
		case "releaseCourseFileToMenu" :
			control.loadUnitXML();
			break;
		case "releaseMenuFileToCourse" :
			myTrace("fail to release menu file, go to course");
			control.xmlCourse.loadXML();
			break;
		case "releaseMenuFileToExercise" :
			myTrace("fail to release menu file, go to exercise");
			control.lockFile("Exercise");
			break;
		case "releaseExerciseFileToMenu" :
			control.lockFile("Unit");
			break;
			
		// v0.16.1, DL: zip files
		case "exportFiles" :
			control.onExportFilesFail();
			myTrace("fail to zip the file");
			break;
		// v0.16.1, DL: download file
		case "checkFileForDownload" :
			control.onExportFilesFail();
			myTrace(attr.error);
			break;
		// v0.16.1, DL: unzip file
		case "unzipFile" :
			control.onUnzipFail();
			myTrace(attr.error);
			break;
		// v0.16.1, move files for importing
		case "importFiles" :
		// v6.4.0.1, move files for importing to current course
		case "importFilesToCurrentCourse" :
			control.onImportFilesFail();
			myTrace("fail to import the files");
			break;
		// v6.4.2, DL: delete a file
		case "deleteFile" :
			break;
		}
	}
}