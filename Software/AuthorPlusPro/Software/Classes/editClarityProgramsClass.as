class Classes.editClarityProgramsClass {
	// v6.4.3 No need to copy or edit any files as MGS is used
	
	private var control:Object;
	private var paths:Array;
	private var programs:Array;
	public var courseXml:XML; 
		
	private var _userPath:String;
	private var _serverPath:String;
	private var _serverWriteFilePath:String;
	private var _serverCopyCoursePath:String;
	private var _serverCopyMenuPath:String;
	private var copyCourseResponse:XML;
	private var copyMenuResponse:Object;
	
	private var progCnt:Number;
	private var progPath:String;
	
	private var courseCnt:Number;
	private var coursePaths:Array;
	private var totalCourseCnt:Number;
	
	private var loadContentInterval:Number;
	
	/*
		init
	*/
	function editClarityProgramsClass(c:Object) {
		control = c;
		paths = new Array();
		programs = new Array();
		// v6.4.2.5 To save putting Author Plus in its own location file, preset it here
		paths.push(_global.addSlash(_global.NNW.paths.userDataPath) + _global.NNW._locationFile);
		programs.push("AuthorPlus");
		_global.NNW.paths[_global.NNW.paths.userApp+"Content"] = _global.NNW.paths.content;
		_global.NNW.paths[_global.NNW.paths.userApp+"MGSPath"] = _global.NNW.paths.MGSPath;
		// This is not the full location file, just the folder name. So really the udp
		_global.NNW.paths[_global.NNW.paths.userApp+"Location"] = _global.NNW.paths.userDataPath;
		
		// v6.4.3 No need to copy or edit any files as MGS is used
		/*
		courseXml = new XML("<courseList />");
		
		copyCourseResponse = new XML();
		var thisObj = this;
		copyCourseResponse.onLoad = function(success) {
			if (success && this.firstChild.nodeName=="sR" && this.firstChild.firstChild.attributes.save!="error") {
				// saving success
				_global.myTrace("saving external course xml success:");
				//_global.myTrace(this.toString());
				
				// copy files from this program
				//this.master.copyFilesFromProgram();
				thisObj.copyFilesFromProgram();
				
			} else {
				// error in saving
				_global.myTrace("error: saving external course xml fail");
				// can't save file for this program, load next program
				//this.master.progCnt++;
				//this.master.loadPrograms();
				thisObj.progCnt++;
				thisObj.loadPrograms();
			}
		}
		
		copyMenuResponse = new XML();
		copyMenuResponse.master = this;
		copyMenuResponse.onLoad = function(success) {
			if (success && this.firstChild.nodeName=="sR" && this.firstChild.firstChild.attributes.save!="error") {
				// saving success
				_global.myTrace("response: "+this.firstChild.toString());
				_global.myTrace("copy menu xml success:");
			} else {
				// error in saving
				_global.myTrace("error: copy menu xml fail");
			}
			this.master.control.loadUnitXML();
		}
		*/
	}
	
	/*
		public functions
	*/
	public function getPaths() : Void {
		// v6.4.3 Change name from paths.userPath to paths.content
		//_userPath = _global.NNW.paths.userPath;
		// v6.4.2.5 Shouldn't userpath be _global.addSlash(NNW.paths.userDataPath)??
		// Oh, we don't actually use it anymore
		//_userPath = _global.NNW.paths.content;
		
		// v6.4.3 No need to copy or edit any files as MGS is used
		/*
		_serverPath = _global.NNW.paths.serverPath;
		if (control.login.licence.scripting.toLowerCase()=="php") {
			_serverWriteFilePath = _serverPath+"/XMLWrite.php";
			_serverCopyCoursePath = _serverPath+"/copyCourse.php";
			_serverCopyMenuPath = _serverPath+"/copyMenu.php";
		} else {
			_serverWriteFilePath = _serverPath+"/XMLWrite.asp";
			_serverCopyCoursePath = _serverPath+"/copyCourse.asp";
			_serverCopyMenuPath = _serverPath+"/copyMenu.asp";
		}
		*/
		for (var i in _global.NNW.paths) {
			if (i.indexOf("Location")>0) {
				var p = _global.NNW.paths[i];
				_global.myTrace("edit: paths[i]=" + p);
				if (p!=undefined && p!="undefined" && _global.trim(p)!="") {					
					var n = i.substr(0, i.indexOf("Location"));
					// v6.4.2.5 No need to do anything for Author Plus as it is the default and handled already
					if (n<>"AuthorPlus") {
						paths.push(p);
						programs.push(n);
					}
					// v6.4.1.4, DL: not sure if this is a good way, think about it again later
					// change the interface setting to this program's
					//_global.NNW.interfaces.setInterface(n);
				}
			}
		}
		
		_global.myTrace("edit.getPaths.progs=" + programs.toString());
		progCnt = 0;
		totalCourseCnt = 0;
		
		getContentPaths();
	}
	
	// v6.4.3 No need to copy or edit any files as MGS is used
	/*
	public function resetCourse(menu:String, source:String, dest:String) : Void {
		source = _global.replace(source, "\\", "/");
		source = _global.replace(source, "//", "/");
		dest = _global.replace(dest, "\\", "/");
		dest = _global.replace(dest, "//", "/");
		
		//for (var i in coursePaths) {
		//	if (coursePaths[i].toLowerCase().indexOf(source.toLowerCase())>-1) {
		//		var sF = coursePaths[i]+"/"+menu;
		//		var dF = dest+"/"+menu;
				var sF = _global.NNW.paths[_global.NNW.interfaces.getInterface()+"Content"]+"/"+source+"/"+menu.substr(0, -4)+"-original.xml";
				var dF = _global.NNW.paths[_global.NNW.interfaces.getInterface()+"Content"]+"/"+source+"/"+menu;
				copyMenuResponse.load(_serverCopyMenuPath+"?prog=NNW&sF="+sF+"&dF="+dF);
				_global.myTrace(_serverCopyMenuPath+"?prog=NNW&sF="+sF+"&dF="+dF);
		//		break;
		//	}
		//}
	}
	*/
	public function getNoOfPrograms() : Number {
		return programs.length;
	}
	
	public function getProgramsCodes() : Array {
		return programs;
	}
	
	/*public function editCourseXml() : Void {
		var n = _global.NNW.interfaces.getInterface();
		var x = new XML();
		x.load(paths[n+"Content"]);
	}*/
	
	/*
		private functions
	*/
	private function getContentPaths() : Void {
		//_global.myTrace("getContentPath progCnt=" + progCnt + " prog=" + programs[progCnt]);
		if (progCnt<programs.length) {
			// Don't do anything for Author Plus, just go to the next prog
			if (programs[progCnt]=="AuthorPlus") {
				progCnt++;
				getContentPaths();
			} else {
				// This creates empty mcs on a dummy screen and then loads the contents of each location.ini into the mc
				// Yikes.
				_global.myTrace("edit.getContentPaths.load " + paths[progCnt]);
				_global.NNW.screens.scnTest.createEmptyMovieClip("load"+programs[progCnt]+"Content_mc", _global.NNW.screens.scnTest.getNextHighestDepth());
				loadVariables(paths[progCnt], _global.NNW.screens.scnTest["load"+programs[progCnt]+"Content_mc"]);
				// v6.4.2.6 To stop infinite loop
				_global.NNW.screens.scnTest["load"+programs[progCnt]+"Content_mc"].loadCounter=0;
				loadContentInterval = setInterval(this, "loadContentPath", 100);
			}
		} else {
			progCnt = 0;
			// v6.4.2.5 I don't think I need to do this as I am not copying anything anymore			
			//loadPrograms();
			loadingComplete();
		}
	}
	
	private function loadContentPath() : Void {
		_global.myTrace("edit.loadContentPath.progCnt=" + progCnt);
		// Test to see if we have a variable called Content loaded yet
		if (_global.NNW.screens.scnTest["load"+programs[progCnt]+"Content_mc"]["content"]==undefined) {
			// not yet loaded
			// v6.4.2.6 You don't want to run this loop unchecked. If it hasn't loaded within x seconds, give up.
			// It means you can't edit this program. This is a very clumsy way to work if you want to put all the
			// programs into the location file to save them editing as it will lead to a long pause. Should be elegantly
			// programmed with events adding each program as and when it loads.
			if (_global.NNW.screens.scnTest["load"+programs[progCnt]+"Content_mc"].loadCounter++ > 20) {
				_global.myTrace("cannot read loaction file for " + programs[progCnt] + " so give up");
				// delete this entry from the arrays (you can't take it out as we are already counting the loop)
				programs[progCnt]=undefined;
				paths[progCnt]=undefined;
				_global.NNW.paths[programs[progCnt]+"Location"] = undefined;
				_global.NNW.paths[programs[progCnt]+"Content"] = undefined;
				_global.NNW.paths[programs[progCnt]+"MGSPath"] = undefined;
				clearInterval(loadContentInterval);
				progCnt++;
				getContentPaths();
			}
		} else {
			// If we do, then save it in the paths object along with the location - strip to just the folder
			// Why do we strip to just the folder? Surely it is useful to know the location filename? Or are we treating the location
			// path as the userdatapath?
			//_global.myTrace("location already=" + _global.NNW.paths[programs[progCnt]+"Location"] + " new=" + _global.getPath(paths[progCnt]));
			_global.NNW.paths[programs[progCnt]+"Location"] = _global.getPath(paths[progCnt]);
			_global.NNW.paths[programs[progCnt]+"Content"] = _global.NNW.screens.scnTest["load"+programs[progCnt]+"Content_mc"]["content"];
			// v6.4.2.5 Also add the MGS path at this point
			_global.NNW.paths[programs[progCnt]+"MGSPath"] = control.login.addMGStoPath(_global.NNW.paths[programs[progCnt]+"Content"]);
			_global.myTrace("this MGSPath=" + _global.NNW.paths[programs[progCnt]+"MGSPath"]);
			paths[progCnt] = _global.NNW.screens.scnTest["load"+programs[progCnt]+"Content_mc"]["content"];
			_global.myTrace("this content path="+paths[progCnt]);
			
			clearInterval(loadContentInterval);
			progCnt++;
			getContentPaths();
		}
	}
	// v6.4.2.5 Not called anymore
	private function loadPrograms() : Void {
		_global.myTrace("edit.loadPrograms.progCnt=" + progCnt);
		//_global.myTrace(paths.length);
		
		if (progCnt<paths.length) {
			progPath = paths[progCnt];
			
			coursePaths = new Array();
			
			// load course.xml of that program
			var px = new XML();
			px.master = this;
			px.onLoad = function(success) {
				// v6.4.3 No need to copy or edit any files as MGS is used
				/*
				if (success) {
					_global.myTrace("edit.loadCourseXML." + this.master.progPath + " set editedCourseFolder to " + this.master.paths[this.master.progCnt]+"/Courses");
					var cL = this.firstChild;
					if (cL.hasChildNodes()) {
						for (var i=0; i<cL.childNodes.length; i++) {
							if (cL.childNodes[i].nodeName=="course") {
								var cN = cL.childNodes[i];
								
								// get its path
								var cF = this.master.progPath+"/"+cN.attributes.courseFolder+"/"+cN.attributes.subFolder;
								cF = _global.replace(cF, "\\", "/");
								cF = _global.replace(cF, "//", "/");
								this.master.coursePaths.push(cF);
								
								// edit the node's attribute
								cN.attributes.editedCourseFolder = this.master.paths[this.master.progCnt]+"/Courses";
								cN.attributes.program = this.master.programs[this.master.progCnt];
								
								// copy the node
								var n = cN.cloneNode(true);
								n.attributes.courseFolder = "Courses\\";
								this.master.courseXml.firstChild.appendChild(n);
							}
						}
					}
					// write editedCourseFolder to each course node
					this.master.writeCourseXML(this);
				} else {
					// no courses in this program, load next program
					this.master.progCnt++;
					this.master.loadPrograms();
				}
				*/
				// v6.4.3 So just trigger the next stage in the loop
				this.master.progCnt++;
				this.master.loadPrograms();
			}
			px.load(progPath+"/course.xml?cache="+random(99999));
			
		} else {
			// finish loading all program's course.xml
			loadingComplete();
		}
	}
	
	// v6.4.3 No need to copy or edit any files as MGS is used
	/*
	// write editedCourseFolder to each course node
	private function writeCourseXML(x:XML) : Void {
		x.sendAndLoad(_serverWriteFilePath+"?prog=NNW&file="+progPath+"/course.xml", copyCourseResponse);
		_global.myTrace("copying course.xml for "+programs[progCnt]);
		_global.myTrace(_serverWriteFilePath+"?prog=NNW&file="+progPath+"/course.xml");
	}
	*/
	
	private function loadingComplete() : Void {
		for (var i in _global.NNW.paths) {
			if (i.indexOf("Location")>0 || i.indexOf("Content")>0 || i.indexOf("MGSPath")>0) {
				var p = _global.NNW.paths[i];
				_global.myTrace("** " + i + ":" + p);
			}
		}
		// v6.5.0.1 At this point, if it is a kit licence, we will only show 1 title and auto select it. This code was in control.as
		var productType = _global.NNW.control.login.licence.productType.toLowerCase();
		var branding = _global.NNW.control.login.licence.branding.toLowerCase();
		if (productType=="kit") {
			_global.myTrace("eCP:load editing kit for " + branding);
			// v6.4.3 So we are only loading the default product (Author Plus). But what about branding if this isn't Author Plus?
			// v6.5.0.1 Including Clarity programs. Note that code for this is embedded in screen.swf:scnCourse
			if (branding.indexOf("nas/myc")>=0) {
				var kitTitle = "MyCanada_mc";
				var kitProgram = "MyCanada";
			} else if (branding.indexOf("nas/ldt")>=0) {
				var kitTitle = "Lamour_mc"; 
				var kitProgram = "Lamour";
			} else if (branding.indexOf("clarity/tb")>=0) {
				var kitTitle = "TenseBuster_mc"; 
				var kitProgram = "TenseBuster";
			} else if (branding.indexOf("clarity/sss")>=0) {
				var kitTitle = "StudySkillsSuccess_mc"; 
				var kitProgram = "StudySkillsSuccess";
			} else if (branding.indexOf("clarity/ro")>=0) {
				var kitTitle = "Reactions_mc"; 
				var kitProgram = "Reactions";
			} else if (branding.indexOf("clarity/bw")>=0) {
				var kitTitle = "BusinessWriting_mc"; 
				var kitProgram = "BusinessWriting";
			}
			var y = 150;
			_global.NNW.screens.scnCourse[kitTitle]._visible = true;
			_global.NNW.screens.scnCourse[kitTitle]._y = y;
			// act as if this button had been clicked. 
			_global.NNW.screens.scnCourse[kitTitle].onRelease();
			//_global.NNW.interfaces.setInterface(kitProgram);
			//_global.NNW.screens.scnCourse.showProgramSelection(kitTitle);
			//_global.NNW.screens.refillCourses();
			
			// Once it is displayed, we don't want to do anything when you click it.
			// and it shouldn/t have a fat finger...
			_global.NNW.screens.scnCourse[kitTitle].onRelease = undefined;
		} else {
			_global.NNW.screens.showClarityPrograms();
		}
		
		//_global.myTrace(courseXml.toString());
		control.xmlCourse.loadXML();
	}
	
	// v6.4.3 No need to copy or edit any files as MGS is used
	/*
	private function copyFilesFromProgram() : Void {
		courseCnt = 0;
		copyCourse();
	}
	
	private function copyCourse() : Void {
		if (courseCnt<coursePaths.length) {
			// copy course folder
			var x = new XML();
			x.master = this;
			x.onLoad = function(success) {
				this.master.courseCnt++;
				this.master.totalCourseCnt++;
				this.master.copyCourse();
			}
			
			var y = new XML(courseXml.firstChild.childNodes[totalCourseCnt].toString());
			var p = _serverCopyCoursePath+"?prog=NNW&userPath="+_userPath+"&folder="+coursePaths[courseCnt]+"&menu="+y.firstChild.attributes.scaffold;
			y.sendAndLoad(p, x);
			_global.myTrace(p);
			
		} else {
			// end of copying folders, load next program
			progCnt++;
			loadPrograms();
		}
	}
	*/
}