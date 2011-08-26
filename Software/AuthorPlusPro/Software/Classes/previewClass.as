/*
	previewClass has functions for previewing purpose only
	it is created to reduce the size of control class
	
	v6.5.5.7 It also needs to be adapted so that Results Manager can remotely start Author Plus too.
*/

class Classes.previewClass {
	
	var control:Object;
	var __popupForPreview:Boolean;
	var __server:Boolean;
	var previewAction:String;
	
	// sender for local connection to Orchid for previewing
	var preview_lc:Object;
	var receiveConn:Object;
	
	//v6.4.3 Running with mdmScript 2.0
	var mdm:Object;
	
	function previewClass(c:Object) {
		control = c;
		mdm = _global.mdm; // v6.4.3 mdm Script 2.0
		
		__popupForPreview = true;
		__server = control.__server;
		previewAction = "";
		
		// set up sender for local connection to send preview requests to Orchid
		preview_lc = new LocalConnection();
		preview_lc.master = this;
		preview_lc.__server = __server;
		preview_lc.onReceiveCommand = function(success:Boolean) {
			if (success) {
				// just refocus the preview window, the exercise is now displayed
				this.master.myTrace("--- Preview localConn: refocus");
				if (this.__server) {
					getURL("javascript: previewEx.focus();");
				}
			} else {
				// need to do the current full APO startup as it is not running yet
				this.master.myTrace("--- Preview localConn: got reply, but failed");
				this.master.control.loadPreview();
			}
		}
		// v6.5.3 Now we will not pass the password, but Orchid will wait after logging in until you tell it again where to go
		// If Orchid tells you that it is now ready, then resend your last command which contains the navigation details
		preview_lc.onOrchidReady = function(success:Boolean) {
			this.master.myTrace("--- Preview localConn: previewByLocalConn please");
			if (success) {
				this.master.previewByLocalConn();
			}
		}
		preview_lc.onStatus = function(infoObject:Object) {
			_global.myTrace("arthur.lc.onStatus.level=" + infoObject.level);
			if (infoObject.level=="status") {	// connection found
				// we don't really have to do anything here, just leave onReceiveCommand to handle it
			} else {	// no connection found
				this.master.myTrace("--- Preview localConn: no connection found, start new APO");
				this.master.control.loadPreview();
			}
		}
		preview_lc.connect("OrchidResponse");
		
		// And add similar for RM to AP, but this time we are at the receiving end.
		_global.myTrace("see if we need RM to AP preview");
		if (_global.NNW._preview) {
			_global.myTrace("We do");
			this.receiveConn = new LocalConnection();
			this.receiveConn = this;
			this.receiveConn.displayExercise = function(courseID:String, exerciseID:String) {
				_global.myTrace("RM is asking you to go to course " + courseID + " and exercise " + exerciseID);
				// Call whatever functions you need to in regular AP code to navigate to this exercise
				
				// See if you can get yourself to have the focus
				getURL("javascript:window.focus()");
				// Send back a response
				this.send("ArthurResponse", "onReceiveCommand", true);
			}
			// Send out an immediate message that you are now up and running, in case RM is listening.
			var connectSuccess = this.receiveConn.connect("ArthurCommand");
		}
	}
	
	function myTrace(s:String) : Void {
		_global.myTrace(s);
	}
	
	function previewCourses() : Void {
		// v6.4.0.1, DL: no need saving course before previewing from now on
		//saveCourse("saveCoursesPreview");
		previewAction = "previewCourses";
		setPreviewSessionVariables();
	}
	
	function previewMenu() : Void {
		//saveCourse("saveMenuPreview");
		previewAction = "previewMenu";
		setPreviewSessionVariables();
	}
	
	function previewExercise() : Void {
		previewAction = "previewExercise";
		setPreviewSessionVariables();
	}
	
	function setPreviewSessionVariables() : Void {
		control.setPreviewSessionVariables(previewAction);
	}
	
	function previewByLocalConn() : Void {
		myTrace("preview by local conn: "+previewAction);
		
		var data = control.data;
		var cid = data.currentCourse.id;
		var eid = data.currentExercise.id;
		
		switch (previewAction) {
		case "previewCourses" :
			preview_lc.send("OrchidCommand", "displayExercise", undefined, undefined);
			break;
		case "previewMenu" :
			preview_lc.send("OrchidCommand", "displayExercise", cid, undefined);
			break;
		case "previewExercise" :
			preview_lc.send("OrchidCommand", "displayExercise", cid, eid);
			break;
		}
	}
	
	function loadPreview() : Void {
		var scripting = control.login.licence.scripting;
		var usr = _global.NNW.control._username;
		var pwd = _global.NNW.control._password;
		var paths = control.paths;
		var data = control.data;
		var cid = data.currentCourse.id;
		var eid = data.currentExercise.id;
		
		// v6.4.1.4, DL: Start.asp/Start.php may not be in the same directory with licence.ini
		// it can be a variable which varies from program to program!
		var productType = _global.NNW.control.login.licence.productType.toLowerCase();
		_global.myTrace("preview: no of progs=" + control.edit.getNoOfPrograms() + " getInterface=" + _global.NNW.interfaces.getInterface());
		//if (control.edit.getNoOfPrograms() > 1) {
		if (control.edit.getNoOfPrograms() > 1 || productType.toLowerCase()=="kit") {
			var path = _global.addSlash(paths[_global.NNW.interfaces.getInterface()+"Location"]);
		} else {
			// v6.4.1.3, DL: Start.asp/Start.php/Start.exe doesn't have to be in userPath
			// assume it to be in the same directory with licence.ini
			// v6.4.3 No - assume it to be in userDataPath
			//var path = _global.addSlash(_global.getPath(paths.licence));
			var path = _global.addSlash(paths.userDataPath);
		}
		// v6.4.3
		//if (path!="") {
		//	path += "/";
		//}
		
		// build up preview parameters string
		if (__server) {
			// v6.4.1.2, DL: prepare to add PHP scripting
			// v6.4.3 Now the Orchid is called Learner.exe
			// But if we do this for online, it means so much existing (especially CE.com) has to change
			// So keep Start with webserver version and Learner.exe for network
			// v6.5.0.1 If you are running on CE.com, you will have a prefix before each start page name. It will have been sent to you
			// v6.5.0.2 But, AP doesn't use this (/ap/Clarity/Start.asp) - so need to check the program you are editing first
			// v6.5.4.7 AP now also uses this, but in a different way. In fact they all do it in a different way on CE.com now
			//if (_global.NNW._accountPrefix!=undefined &&
			//	_global.NNW.interfaces.getInterface().toLowerCase().indexOf("authorplus")<0) {
			_global.myTrace("prefix for preview=" + _global.NNW._accountPrefix);
			if (_global.NNW._accountPrefix!=undefined) {
				var thisPrefix = "&prefix="+_global.NNW._accountPrefix;
			} else {
				var thisPrefix = "";
			}
			if (scripting.toLowerCase()=="php") {
				//var previewPage = path+"Start.php?s_preview=true";
				//var previewPage = path+"Learner.php?s_preview=true";
				//var previewPage = path+thisPrefix+"Start.php?s_preview=true";
				var previewPage = path+"Start.php?s_preview=true" + thisPrefix;
			} else {
				//var previewPage = path+"Start.asp?s_preview=true";
				//var previewPage = path+"Learner.asp?s_preview=true";
				//var previewPage = path+thisPrefix+"Start.asp?s_preview=true";
				var previewPage = path+"Start.asp?s_preview=true"+thisPrefix;
			}
			//v6.4.2.6 Why aren't I sending the username and password to the server version?
			// Ahh, you are in actionFunctions.php.  But this is not getting picked up by this.username in control.swf for some reason!!
			// So add to the parameters going to the php file - but this doesn't work either.
			//previewPage +="&s_username="+escape(usr)+"&s_password="+escape(pwd);
			// v6.4.3 Still not getting, just send on command line
			// v6.5.3 I don't want to pass the password anymore, it is too easy to see it from the browser. So ideally Orchid
			// will tell you when it is started and then you can run previewByLocalConnection again to get it to the right place.
			// But for now, it is more important to simply not pass the password.
			//previewPage +="&username="+escape(usr)+"&password="+escape(pwd);
			// v6.5.5.7 This fails if you have an apostrohe in the name, even if you have escaped it to %27. I suppose it has to go to &apos;
			//previewPage +="&username="+escape(usr);
			previewPage +="&username="+safeQuotes(usr);
		} else {
			// v6.4.2.5 Escape the name and password otherwise spaces stop preview working properly
			//var para = "username="+usr+"&password="+pwd+"&action=login&preview=true";
			var para = "preview=true&username="+safeQuotes(usr)+"&password="+safeQuotes(pwd)+"&action=login";
			
			// v6.4.1.2, DL: set action=anonymous if no username is provided in network version
			if (usr=="") {
				para += "&action=anonymous";
			}
		}
		if (previewAction=="previewMenu"||previewAction=="previewExercise") {
			if (__server) {
				// v6.5.3 For first time loading, always send courseID=0 - this lets Orchid know that you will send navigation by lc request
				//previewPage += "&s_courseid="+cid;
				previewPage += "&s_courseid=0";
			} else {
				para += "&course="+cid;
			}
			
			if (previewAction=="previewExercise") {
				if (__server) {
					// v6.5.3 For first time loading, no need to send any exID
					//previewPage += "&s_exerciseid=ex:"+eid;
				} else {
					para += "&startingPoint=ex:"+eid;
				}
			}
		}
		
		// call APO for preview
		if (__server) {
			if (__popupForPreview) {
				/* this will show preview in popup window */
				// ar v6.4.2.6 Adjust for borders, base size = 760x509 with margin of 4 all around - for some reason in Firefox/PHP it needs to be deeper
				//getURL("javascript: openWindowForNNW('" + previewPage + "', 'previewEx', 770, 515, 0 ,0 ,0 ,0 ,0 ,1 ,20 ,20 );");
				//getURL("javascript: openWindowForNNW('" + previewPage + "', 'previewEx', 768, 521, 0 ,0 ,0 ,0 ,0 ,1 ,20 ,20 );");
				// v6.4.3 Deeper screen
				// v6.5.5.7 This fails if you have an apostrohe in the name, even if you have escaped it to %27. I suppose it has to go to &apos;
				//myTrace("javascript: openWindowForNNW('" + previewPage + "', 'previewEx', 768, 654, 0 ,0 ,0 ,0 ,0 ,1 ,20 ,20 );");
				getURL("javascript: openWindowForNNW('" + previewPage + "', 'previewEx', 768, 654, 0 ,0 ,0 ,0 ,0 ,1 ,20 ,20 );"); 
			} else {
				/* this will show preview in new browser window */
				getURL(previewPage, "_blank");
			}
			myTrace("server preview path = "+previewPage);
		// v6.4.1.2, DL: add support to network version (FSP)
		} else {
			// v6.4.3 Now the Orchid is called Learner.exe
			//var preview_exe = path+"Start.exe"+" "+para;
			// v6.4.2.7 Different programs have different names
			switch (_global.NNW.interfaces.getInterface().toUpperCase()) {
			case "BUSINESSWRITING" :
				var progName = "BusinessWriting.exe";
				break;
			case "STUDYSKILLSSUCCESS" :
				var progName = "StudySkillsSuccess.exe";
				break;
			case "TENSEBUSTER" :
				var progName = "TenseBuster.exe";
				break;
			case "REACTIONS" :
				var progName = "Reactions.exe";
				break;
			default:
				// v6.4.3 Add some specialisation
				if (_global.NNW.control.login.licence.branding.toLowerCase().indexOf("nas/myc")>=0){
					var progName = "MyCanada.exe";
				} else {
					var progName = "Learner.exe";
				}
			}
			//var preview_exe = path+"Learner.exe"+" "+para;
			var preview_exe = path+progName+" "+para;
			var preview_folder = path;
			// v6.4.3 mdm.Script 2.0
			//_root.mdm.exec_adv("","0","0","100","100","",preview_exe,preview_folder,"3","4");
			mdm.Process.create("", 100, 100, 100, 100, "", preview_exe, preview_folder, 2, 4);
			//myTrace("userDataPath=" + paths.userDataPath + " root=" + paths.root);
			myTrace("MDM preview path = "+preview_exe);
		}
	}
	
	// v6.5.5.6 Functions that should be somewhere already - maybe they are. I need them for escaping names passed to preview
	function safeQuotes(text):String {
		var part1 = findReplace(text, String.fromCharCode(39), "&apos;");
		var part2 = findReplace(part1, String.fromCharCode(43), "&#043;");
		var part3 = findReplace(part2, String.fromCharCode(60), "&lt;");
		var part4 = findReplace(part3, String.fromCharCode(62), "&gt;");
		return findReplace(part4, String.fromCharCode(34), "&quot;");
	}
	function findReplace(myString, find, replace, occurence):String {
	//	trace("looking for " + find);
		if (!occurence) {
			return myString.split(find).join(replace);
		} else {
			var n:Array = myString.split(find);
			for (var j in n) {
				if (j == occurence-1) {
					n[j] += replace;
				} else if (j!=n) {
					n[j] += find;
				}
			}
			return n.join("");
		}
	};

}