import mx.utils.Delegate;

class Classes.uploadClass {
	
	var control:Object;
	
	// v0.16.1, DL: receiver for local connection to receive results from uploading
	var receive_lc:Object;
	
	// v0.16.1, DL: upload type
	var uploadType:String;
	var uploadQuestionNo:Number;	// for question audio
	
	//v6.4.3 Running with mdmScript 2.0
	var mdm:Object;
	
	function uploadClass(c:Object) {
		control = c;
		mdm = _global.mdm; // Reference to global object
		
		// v0.16.1, DL: set up receiver for local connection to receive results from uploading
		receive_lc = new LocalConnection();
		receive_lc.master = this;
		receive_lc.onUpload = function(a:Array) {
			var master = this.master;
			master.myTrace("lc_NNW:onUpload with " + a.toString());
			//for (var i in a) {
			//	master.myTrace("receive file name: "+a[i]);
			//}
			switch (master.uploadType) {
				case "image" :
					master.onImageUploaded(a);
					break;
				case "audioAutoPlay" :
				case "audioEmbed" :
				case "audioAfterMarking" :
				case "audioQuestion" :
					master.onAudioUploaded(a);
					break;
				case "videoEmbed" :
				case "videoFloating" :
					master.onVideoUploaded(a);
					break;
				case "import" :
					master.onImportUploaded(a);
					break;
			}
			master.uploadType = "";
		}
		receive_lc.onCloseForm = function(reason) {
			this.master.myTrace("lc_NNW:onCloseForm");
			this.master.onUploadFormClosed(reason);
		}
		receive_lc.connect("lc_NNW");
	}
	
	// v0.16.1, DL: finished image upload
	function onImageUploaded(a:Array) : Void {
		var ex = control.data.currentExercise;
		if (a[0]!=undefined) {
			ex.image.location = "";
			// Start from ResultsManager, we need set the location to the author's group
			if(_global.NNW._previewMode){
				ex.image.location = _global.NNW.groupID;
			}
			ex.image.filename = a[0];
			ex.image.category = "YourGraphic";
			control.view.setImageCategory("YourGraphic");
			_global.NNW.screens.s_bImageSelected	= true;
			
			// if video is embedded, set it to be floating
			if (ex.videos[0].mode=="1") {
				control.updateExerciseVideo(ex.videos[0].filename, "16", "");
			}
			
			control.view.fillInImage(ex.image);
			control.onExerciseChanged();
		}
		control.view.hideMask();
	}

	// v0.16.1, DL: finished audio upload
	function onAudioUploaded(a:Array) : Void {
		if (a[0]!=undefined) {
			switch (uploadType) {
			case "audioAutoPlay" :
				control.view.setAudioCheckBox("Default", false);
				// v0.16.1, DL: del shared instructions audio object
				control.updateExerciseInstructionsAudio(true, false);
				// add non-shared instructions audio object
				control.updateExerciseInstructionsAudio(false, true);
				// edit the instruction audio filename
				control.data.currentExercise.editInstructionsAudio(a[0]);
				break;
			case "audioEmbed" :
				control.updateExerciseEmbedAudio(a[0]);
				break;
			case "audioAfterMarking" :
				control.updateExerciseAfterMarkingAudio(a[0]);
				break;
			case "audioQuestion" :
				control.updateExerciseQuestionAudio(a[0], "1", uploadQuestionNo);
				break;
			}
			control.view.setAudioCheckBox(uploadType.substr(5), true);
			control.view.fillInAudios(control.data.currentExercise.audios);
			control.onExerciseChanged();
		}
		control.view.hideMask();
	}

	// v0.16.1, DL: finished video upload
	function onVideoUploaded(a:Array) : Void {
		if (a[0]!=undefined) {
			_global.myTrace("onVideoUploaded:type=" + uploadType);
			// v6.4.2 AR The type seems to always by embed, not clear why type is important in upload at all
			// We want the default to be floating, so just forcefully change the type at this point.
			// It would probably make more sense to just have one upload 'type' for video though.
			uploadType = "videoFloating";
			switch (uploadType) {
			case "videoEmbed" :
				control.updateExerciseVideo(a[0], "1", "top-right");
				
				// set to no graphic
				control.view.setImageCategory("NoGraphic");
				control.data.currentExercise.image.category = "NoGraphic";
				control.data.currentExercise.image.filename = "";
				control.data.currentExercise.image.position = "top-right";
				
				break;
			case "videoFloating" :
				// v6.4.2 AR - isn't mode 16 for floating?
				//control.updateExerciseVideo(a[0], "4", "");
				control.updateExerciseVideo(a[0], "16", "");
				break;
			}
			control.view.setVideoCheckBox(uploadType.substr(5), true);
			control.onExerciseChanged();
		}
		control.view.hideMask();
	}

	function onImportUploaded(a:Array) : Void {
		if (a[0]!=undefined) {
			control.unzipFile(a[0]);
		}
	}
	
	// v0.16.1, DL: show the upload form after session variables are set for specific file types
	function showUploadForm() : Void {
		if (control.__server) {
			// v6.4.1.4, DL: implementation of PHP version
			if (control.login.licence.scripting.toLowerCase()=="php") {
				getURL("javascript: openWindowForNNW('" + control.paths.serverPath + "/uploadForm.php', 'uploadForm', 420, 200, 0 ,0 ,0 ,0 ,0 ,1 ,20 ,20 );");
				_global.myTrace("getURL = "+"javascript: openWindowForNNW('" + control.paths.serverPath + "/uploadForm.php', 'uploadForm', 420, 200, 0 ,0 ,0 ,0 ,0 ,1 ,20 ,20 );");
			} else {
				getURL("javascript: openWindowForNNW('" + control.paths.serverPath + "/uploadForm.asp', 'uploadForm', 420, 200, 0 ,0 ,0 ,0 ,0 ,1 ,20 ,20 );");
				_global.myTrace("getURL = "+"javascript: openWindowForNNW('" + control.paths.serverPath + "/uploadForm.asp', 'uploadForm', 420, 200, 0 ,0 ,0 ,0 ,0 ,1 ,20 ,20 );");
			}
			
			// v6.4.3 Image upload stuff causing mask problems. And asynch. So just set the mask for webserver
			//myTrace("showmask");
			control.view.showMask();
		// v6.4.1.2, DL: upload for network version (FSP)
		} else {
			// v6.4.1.2, DL: set upload form's button text
			//_root.mdm.browsefile_buttontext(control.view.literals.getLiteral("btnUpload"));
			mdm.Dialogs.BrowseFile.buttonText = control.view.literals.getLiteral("btnUpload");
			
			// v6.4.1.2, DL: set upload form's title
			//_root.mdm.browsefiletitle("Select a file");
			mdm.Dialogs.BrowseFile.title = "Select a file"; // v6.4.3 Why not translated??
			
			// v6.4.1.2, DL: set upload type in upload form
			switch (uploadType) {
			case "image" :
				var filterList = "JPG images|*.jpg";
				break;
			case "audioAutoPlay" :
			case "audioEmbed" :
			case "audioAfterMarking" :
			case "audioQuestion" :
				// AR v6.4.2.5 Add flv instead of fls files
				var filterList = "MP3 audio|*.mp3|Flash audio|*.flv";
				break;
			case "videoEmbed" :
			case "videoFloating" :
				var filterList = "Flash video files, *.flv|*.flv|SWF files|*.swf";
				break;
			 case "import" :
				var filterList = "ZIP files|*.zip";
				break;
			}
			//_root.mdm.browsefile_filterlist(filterList);
			mdm.Dialogs.BrowseFile.filterList = filterList;
			
			// v6.4.1.2, DL: set directory for browsing in upload form
			//_root.mdm.browsefiledir(_root.mdm_personal);
			// v6.4.2.4 You should remember the last one they selected
			if (control.paths.uploadBrowseFolder==undefined) {
				mdm.Dialogs.BrowseFile.defaultDirectory = mdm.System.Paths.personal;
			} else {
				myTrace("use remembered folder " + control.paths.uploadBrowseFolder);
				mdm.Dialogs.BrowseFile.defaultDirectory = control.paths.uploadBrowseFolder;
			}
			
			// v6.4.1.2, DL: show upload form
			// v6.4.3 Updated mdm dialog
			//_root.mdm.browsefile(Delegate.create(this, this.checkFileType));
			var myFile = mdm.Dialogs.BrowseFile.show();
			if (myFile == "false") {
				myTrace("cancelled, so do nothing");
			} else {
				myTrace("you selected file " + myFile);
				this.checkFileType(myFile);
			}
		}
		// v6.4.3 Image upload stuff causing mask problems. And asynch. So don't set the mask for mdm
		//myTrace("showmask");
		//control.view.showMask();
	}
	
	function checkFileType(file:String) : Void {
		// retrieve file name from full path
		var filename:String = _global.getFilename(file);
		// v6.4.2.4 You should remember the last folder they selected from
		control.paths.uploadBrowseFolder = _global.getFolder(file);
		myTrace("remember browse folder " + control.paths.uploadBrowseFolder);
		
		// v6.4.1.2, DL: fix courseMediaPath (esp. for FSP)
		if (uploadType!="import") {
			// v6.4.2.5 Use control to build the path - although you find it there as well!
			/*
			// v6.4.3 Change name from paths.userPath to paths.content
			//var courseMediaPath = control.paths.userPath+"/"+control.data.currentCourse.courseFolder;
			var courseMediaPath = _global.addSlash(control.paths.content)+_global.addSlash(control.data.currentCourse.courseFolder);
			//if (courseMediaPath.substr(-1, 1)!="/" && courseMediaPath.substr(-1, 1)!="\\") {
			//	courseMediaPath += "/";
			//}
			courseMediaPath += _global.addSlash(control.data.currentCourse.subFolder)+"Media";
			*/
			var courseMediaPath = control.formMediaPath();
			//myTrace("media path=" + courseMediaPath);
			// make media folder
			//_root.mdm.makefolder(courseMediaPath);
			if (mdm.System.winVerString.indexOf("98")>0) {
				if (!mdm.FileSystem.folderExists(courseMediaPath)) {
					myTrace("need to make this folder");
					mdm.FileSystem.makeFolder(courseMediaPath);
				} else {
					//myTrace("this folder exists");
				}
			} else {
				if (!mdm.FileSystem.folderExistsUnicode(courseMediaPath)) {
					myTrace("need to make folder " + courseMediaPath);
					mdm.FileSystem.makeFolderUnicode(courseMediaPath);
				} else {
					//myTrace("this folder exists");
				}
			}
		} else {
			// v6.4.3 what about import files - what courseMediaPath do we need for them?
			// AR v6.4.2.5 Use MGS path
			//var courseMediaPath = _global.addSlash(control.paths.content)
			var courseMediaPath = _global.addSlash(control.paths.MGSPath)			
		}
		// MDM uses different form of filecopy now, need full new name
		var fullName = _global.addSlash(courseMediaPath) + filename;
		//myTrace("copyFile(" + file + ", " + fullName + ")");
		myTrace("copy to " + fullName);
		switch (uploadType) {
		case "image" :
			if (filename.substr(-4,4).toUpperCase()==".JPG") {
				// v6.4.3 This was a problem as I was working with a relative path in content and ZINC don't like that.
				//_root.mdm.copyfile(file,courseMediaPath);
				if (mdm.System.winVerString.indexOf("98")>0) {
					mdm.FileSystem.copyFile(file, fullName);
				} else {
					mdm.FileSystem.copyFileUnicode(file, fullName);
				}
				var a:Array = new Array(filename);
				onImageUploaded(a);
			} else {
				onUploadFormClosed();
			}
			break;
		case "audioAutoPlay" :
		case "audioEmbed" :
		case "audioAfterMarking" :
		case "audioQuestion" :
			// v6.4.2.5 Flash audio
			//if (filename.substr(-4,4).toUpperCase()==".MP3"||filename.substr(-4,4).toUpperCase()==".FLS") {
			if (filename.substr(-4,4).toUpperCase()==".MP3"||filename.substr(-4,4).toUpperCase()==".FLV"
														||filename.substr(-4,4).toUpperCase()==".FLS") {
				//_root.mdm.copyfile(file,courseMediaPath);
				if (mdm.System.winVerString.indexOf("98")>0) {
					mdm.FileSystem.copyFile(file, fullName);
				} else {
					mdm.FileSystem.copyFileUnicode(file, fullName);
				}
				var a:Array = new Array(filename);
				onAudioUploaded(a);
			} else {
				onUploadFormClosed();
			}
			break;
		case "videoEmbed" :
		case "videoFloating" :
			if (filename.substr(-4,4).toUpperCase()==".FLV"||filename.substr(-4,4).toUpperCase()==".SWF") {
				if (mdm.System.winVerString.indexOf("98")>0) {
					mdm.FileSystem.copyFile(file, fullName);
				} else {
					mdm.FileSystem.copyFileUnicode(file, fullName);
				}
				//_root.mdm.copyfile(file,courseMediaPath);
				var a:Array = new Array(filename);
				onVideoUploaded(a);
			} else {
				onUploadFormClosed();
			}
			break;
		case "import" :
			if (filename.substr(-4,4).toUpperCase()==".ZIP") {
				// v6.4.3 Change name from paths.userPath to paths.content
				//_root.mdm.copyfile(file,control.paths.userPath);
				if (mdm.System.winVerString.indexOf("98")>0) {
					mdm.FileSystem.copyFile(file, fullName);
				} else {
					mdm.FileSystem.copyFileUnicode(file, fullName);
				}
				//_root.mdm.copyfile(file,control.paths.content);
				var a:Array = new Array(filename);
				onImportUploaded(a);
			} else {
				onUploadFormClosed();
			}
			break;
		}
	}
	// v0.16.1, DL: upload form being closed by user
	function onUploadFormClosed(reason) : Void {
		if (reason == "cancel") {
			myTrace("upload form cancelled");
			control.view.hideMask();
			return;
		}
		myTrace("on upload form closed with type=" + uploadType);
		switch (uploadType) {
		case "image" :
			control.view.setImageCategory("NoGraphic");
			var ex = control.data.currentExercise;
			ex.image.category = "NoGraphic";
			ex.image.filename = "";
			ex.image.position = "top-right";
			control.onExerciseChanged();
			break;
		case "audioAutoPlay" :
			control.data.currentExercise.deleteInstructionsAudio(false);
			control.view.setAudioCheckBox("AutoPlay", false);
			control.view.fillInAudios(control.data.currentExercise.audios);
			control.onExerciseChanged();
			break;
		case "audioEmbed" :
			control.updateExerciseEmbedAudio("");
			control.view.setAudioCheckBox("Embed", false);
			control.view.fillInAudios(control.data.currentExercise.audios);
			control.onExerciseChanged();
			break;
		case "audioAfterMarking" :
			control.updateExerciseAfterMarkingAudio("");
			control.view.setAudioCheckBox("AfterMarking", false);
			control.view.fillInAudios(control.data.currentExercise.audios);
			control.onExerciseChanged();
			break;
		case "audioQuestion" :
			control.updateExerciseQuestionAudio("", "1", uploadQuestionNo);
			control.view.setAudioCheckBox("Question", false);
			control.onExerciseChanged();
			break;
		case "videoEmbed" :
			control.updateExerciseVideo("", "1", "");
			control.view.setVideoCheckBox("Embed", false);
			control.onExerciseChanged();
			break;
		case "videoFloating" :
			control.updateExerciseVideo("", "4", "");
			control.view.setVideoCheckBox("Floating", false);
			control.onExerciseChanged();
			break;
		 case "import" :
			break;
		}
		if (uploadType!="import") {
			control.view.hideMask();
		} else if (!control.__server) {
			control.view.hideMask();
		}
	}
	
	// private functions
	private function myTrace(s:String) : Void {
		_global.myTrace(s);
	}
}