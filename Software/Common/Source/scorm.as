// ************
// v6.4.3
// Code for scorm handling - taken from scorm.fla to allow better use of source CONTROL
//************

// v6.4.3 Baffled - where is the integration to JavaScriptFlashGateway?
// Ahhh, it was in control.swf. But it would be much better to bring it in here.

// First set up the API to talk to the LMS

// v6.5 See if you can use different communication technologies based on how you are called
// original will have had _global.ORCHID.commandLine.scormCommunication undefined - use JavaScriptFlashGateway
// = extint is the first ExternalInterface method
scormNS.communication = new Object();

// v6.5 Shift to ExternalInterface
if (	_global.ORCHID.commandLine.scormCommunication<>undefined && 
	_global.ORCHID.commandLine.scormCommunication.toLowerCase().indexOf("extint")>=0) {
	import flash.external.*;
	var isAvailable:Boolean = ExternalInterface.available;
	myTrace("ExternalInterface=" + isAvailable);
	scormNS.communication.ExternalInterface = true;
}

// or link to the flashProxy loaded by javascript
if (_global.ORCHID.commandLine.scormCommunication.toLowerCase().indexOf("jsfg")>=0 || 
	_global.ORCHID.commandLine.scormCommunication==undefined) {
	import com.macromedia.javascript.JavaScriptProxy;
	myTrace("proxyID=" + _global.ORCHID.commandLine.flashProxyID + " from " + this);
	var proxy:JavaScriptProxy = new JavaScriptProxy(_global.ORCHID.commandLine.flashProxyID, this.scormNS);
	scormNS.communication.JavaScriptFlashGateway = true;
	//myTrace("proxy=" + proxy);
}
scormNS.LMSTrace = function(msg) {
	//myTrace("call to scormNS.LMSTrace");
	myTrace(msg);
}
// An event called by the LMS through ExternalInterface
scormNS.LMSGetValueReturn = function(data:Array) :Void {
	//myTrace("back to LMSGetValueReturn");
	for (var i in data){
		if (data[i].error == undefined) {
			// v6.5.1 Convert any nulls into empty strings due to ExternalInterface messing it UP
			if (data[i].value==null) {
				myTrace("use empty string to replace null from LMS")
				data[i].value = "";
			}
			// v6.5 AR As a Linux system treats UTF characters differently to Windows, unescape them at this point
			//myTrace("LMSGet." + data[i].variable + " is " + unescape(data[i].value));
			myTrace("LMSGet." + data[i].variable + " is " + data[i].value + ":" + unescape(data[i].value));
			//this[data[i].variable]={value:data[i].value};
			this[data[i].variable]={value:unescape(data[i].value)};
		} else {
			myTrace("LMSGetValue." + data[i].variable + " error " + data[i].value);
			this[data[i].variable]={error:data[i].error};
		}
	}
	// trigger the next event (if there is one)
	if (data.length > 1) {
		var response = data;
	} else {
		var response = data[0];
	}
	// v6.5 Is it safe to use 'this'?
	//this.onLMSCallComplete(response);
	//myTrace("call to onLMSCallComplete - which is a " + scormNS.onLMSCallComplete);
	scormNS.onLMSCallComplete(response);
}
// get a set of values from the LMS
scormNS.LMSGetValue = function(cmiData, callBack) {
	//myTrace("call to ExtInt.LMSGetValue, scormNS=" + scormNS.moduleName);
	// before making the call, tell the dispatcher what to do on return
	// v6.5 Is it safe to use 'this'?
	//this.onLMSCallComplete = function(response) {
	scormNS.onLMSCallComplete = function(response) {
		//myTrace("trigger callBack from onLMSCallComplete.LMSGetValue");
		callBack(response);
	}
	//proxy.call("LMSGetValue", cmiData, "LMSGetValueReturn");
	//ExternalInterface.call("LMSGetValue", cmiData, "LMSGetValueReturn");
	//myTrace("to ExtInterface.LMSGetValue with data:" + cmiData.length);
	if (scormNS.communication.ExternalInterface) {
		var returnArray = ExternalInterface.call("LMSGetValue", cmiData, "LMSGetValueReturn");
		//myTrace("back from ExtInterface.LMSGetValue with data:" + returnArray.length);
		scormNS.LMSGetValueReturn(returnArray);
	} else {
		proxy.call("LMSGetValue", cmiData, "LMSGetValueReturn");
	}
}
// get a set of values from the LMS
scormNS.LMSSetValue = function(cmiData, callBack) {
	//myTrace("call to LMSSetValue");
	// before making the call, tell the dispatcher what to do on return
	this.onLMSCallComplete = function(response) {
		//myTrace("trigger callBack");
		callBack(response);
	}
	//ExternalInterface.call("LMSSetValue", cmiData, "LMSGetValueReturn");
	if (scormNS.communication.ExternalInterface) {
		// v6.5.1 I am getting a 405 (data type error) from Moodle if I use the standard empty string for a normal exit.
		// So maybe I can use "logout" to show that the course is complete. Or edit the javascript to detect a null
		// and interpret it as an empty string since SCORM never wants null?
		// This should be moved to LMSSetValue since there might be other places that send back empty strings.
		// Copied from lessonStatusCallback
		for (var i in cmiData){
			if (cmiData[i].value=="") {
				myTrace("LMSSetValue, found empty string in " + cmiData[i].name + " so set to null");
				cmiData[i].value = null;
			}
		}
		myTrace("go to ExtInterface.LMSSetValue with data:" + cmiData[0].value);
		var returnArray = ExternalInterface.call("LMSSetValue", cmiData, "LMSGetValueReturn");
		//myTrace("back from ExtInterface.LMSSetValue with data:" + returnArray.length);
		scormNS.LMSGetValueReturn(returnArray);
	} else {
		proxy.call("LMSSetValue", cmiData, "LMSGetValueReturn");
	}
}
scormNS.LMSInitialise = function() :Void {
	if (scormNS.communication.ExternalInterface) {
		myTrace("call ExtInterface.LMSInitalize");
		// You can either send the return function, or wait for a return value and pass it on
		//ExternalInterface.call("LMSInitialize", "LMSGetValueReturn");
		// Note that even though the javascript has the return variable as an array, it comes back as an object
		var returnArray = ExternalInterface.call("LMSInitialize", "LMSGetValueReturn");
		//myTrace("back from ExtInterface.LMSInitalize with data:" + typeof returnArray);
		//myTrace("back from ExtInterface.LMSInitalize with data:" + returnArray.length);
		//myTrace("back from ExtInterface.LMSInitalize with data:" + returnArray.toString());
		scormNS.LMSGetValueReturn(returnArray);
	} else {
		myTrace("call proxy.LMSInitalize " + "proxy=" + proxy);
		proxy.call("LMSInitialize", "LMSGetValueReturn");
	}
}
scormNS.LMSTerminate = function(callBack) :Void {
	//myTrace("call to LMSTerminate");
	this.onLMSCallComplete = function(response) {
		//myTrace("trigger callBack");
		callBack(response);
	}
	//ExternalInterface.call("LMSTerminate", "LMSGetValueReturn");
	if (scormNS.communication.ExternalInterface) {
		var returnArray = ExternalInterface.call("LMSTerminate", "LMSGetValueReturn");
		//myTrace("back from ExtInterface.LMSTerminate with data:" + returnArray.length);
		scormNS.LMSGetValueReturn(returnArray);
	} else {
		proxy.call("LMSTerminate", "LMSGetValueReturn");
	}
}
scormNS.LMSCommit = function(callBack) :Void {
	//myTrace("call to LMSCommit");
	this.onLMSCallComplete = function(response) {
		//myTrace("trigger callBack");
		callBack(response);
	}
	//ExternalInterface.call("LMSCommit", "LMSGetValueReturn");
	if (scormNS.communication.ExternalInterface) {
		var returnArray = ExternalInterface.call("LMSCommit", "LMSGetValueReturn");
		//myTrace("back from ExtInterface.LMSCommit with data:" + returnArray.length);
		scormNS.LMSGetValueReturn(returnArray);
	} else {
		proxy.call("LMSCommit", "LMSGetValueReturn");
	}
}
/*
// fetch any variable from the LMS - older code
scormNS.xxLMSGetValue = function(element, watchVariable, callback, justWatch) {
	// You can use the same code to just watch for a variable (like initVar)
	// which will have been auto sent by the LMS rather than requested from here
	if (justWatch != true) {
		// v6.4.3 for EOICampus, don't delete the root variable before you call
		// it as this LMS doesn't set it dynamically, but only once on launching
		// the program.
		if (scormNS.LMS.indexOf("EOICampus")>=0) {
			myTrace("EOICampus, call LMSGetValue " + element);
		} else {
			_root[watchVariable] = undefined;
			myTrace("call LMSGetValue " + element);
		}
		this.addToLog("call LMSGetValue " + element);
		fscommand("LMSGetValue", element+ ";" + watchVariable);
	} else {
		//myTrace("wait from " + this.scope);
		//this.addToLog("waiting for javascript to send " + element);
	}
	var LMSCall = new Object();
	LMSCall.callback = callback;
	LMSCall.variable = watchVariable;
	LMSCall.element = element;
	LMSCall.SEvent = function() {
		if (_root[this.variable] != undefined) {
			//myTrace("caught " + this.variable + " being set to " + _root[this.variable]);
			clearInterval(this.eventInt);
			if (_root[this.variable].indexOf("error:") == 0) {
				myTrace(this.variable + " returned " + _root[this.variable]);
				this.callback({error:_root[this.variable]})
			} else {
				this.callback({value:_root[this.variable]})
			}
		} else {
			//myTrace("waiting for " + this.variable);
			this.count++;
		}
		// there is no point waiting for this for too long
		if (this.count > 10) {
			clearInterval(this.eventInt);
			this.callback({error:"Timeout:No variable from " + this.element});
			//myTrace("give up waiting for " + this.variable);
		}
	}
	//_global.SCORM.getValueInt = setInterval(LMSCall, "SEvent", 500);
	LMSCall.eventInt = setInterval(LMSCall, "SEvent", 500);
}
// set any variable in the LMS - older code
scormNS.xxLMSSetValue = function(element, value, watchVariable, callback) {
	//v6.4.2 It might be safer to maintain a list of things you have set, but
	// not got a value back from so that you don't exit until all have finished.
	if (watchVariable == "SCORMSetExit" && this.waitingValues.length>0) {
		myTrace("cannot exit as waiting for " + this.waitingValues[0],1);
		if (this.waitingInt==undefined){
			// if this is the first time, start the interval
			//myTrace("start waiting Int");
			this.waitingInt = setInterval(this, "LMSSetValue", 1000, element, value, watchVariable, callback)
		}
	} else {
		// v6.4.2 build up the wait list
		this.waitingValues.push(watchVariable);
		//myTrace("add to waitlist=" + watchVariable);
		clearInterval(this.waitingInt);
		
		_root[watchVariable] = undefined;
		myTrace("LMSSetValue " + element + ";" + value,0);
		this.addToLog("LMSSetValue " + element + ";" + value);
		fscommand("LMSSetValue", element+ ";" + value + ";" + watchVariable);
		var LMSCall = new Object();
		LSMCall.count=0;
		LMSCall.callback = callback;
		LMSCall.variable = watchVariable;
		LMSCall.element = element;
		LMSCall.waitingValues = this.waitingValues;
		LMSCall.SEvent = function() {
			if (_root[this.variable] != undefined) {
				//myTrace("caught " + this.variable + " being set to " + _root[this.variable]);
				//v6.4.2 remove from wait list
				for (var i=0;i<this.waitingValues.length;i++) {
					if (this.waitingValues[i]==this.variable) {
						//myTrace("got, so remove from waitlist=" + this.variable);
						this.waitingValues.splice(i,1)
					}
				}
				clearInterval(this.eventInt);
				if (_root[this.variable].indexOf("error:") == 0) {
					myTrace("LMS:" + this.element + " returned " + _root[this.variable],0);
					// v6.4.2.1 Returns error:405, for example
					var errorNum = _root[this.variable].split(":")[1];
					this.callback({error:errorNum});
				} else {
					this.callback({value:_root[this.variable], name:this.variable})
				}
			} else {
				myTrace("waiting for " + this.variable);
				this.count++;
			}
			// there is no point waiting for this for too long
			if (this.count > 10) {
				//v6.4.2 Also remove from wait list after timeout
				for (var i=0;i<this.waitingValues.length;i++) {
					if (this.waitingValues[i]==this.variable) {
						//myTrace("timout from waitlist=" + this.variable);
						this.waitingValues.splice(i,1)
					}
				}
				clearInterval(this.eventInt);
				this.callback({error:"Timeout for setting " + this.element});
			}
		}
		//_global.SCORM.getValueInt = setInterval(LMSCall, "SEvent", 500);
		LMSCall.eventInt = setInterval(LMSCall, "SEvent", 500);;
	}
}

// Call to quit this SCO, one way or another
scormNS.xxLMSTerminate = function(callback) {
	_root.SCORMExitVar = undefined;
	myTrace("call LMSTerminate",0);
	fscommand("LMSTerminate");

	var LMSCall = new Object();
	LMSCall.callback = callback;
	LMSCall.variable = "SCORMExitVar";
	LMSCall.SEvent = function() {
		if (_root[this.variable] != undefined) {
			//myTrace("caught " + this.variable + " being set to " + _root[this.variable]);
			clearInterval(this.eventInt);
			if (_root[this.variable].indexOf("error:") == 0) {
				this.callback({error:_root[this.variable]})
			} else {
				this.callback({value:_root[this.variable]})
			}
		} else {
			//myTrace("waiting for " + this.variable);
			this.count++;
		}
		// there is no point waiting for this for too long
		if (this.count > 10) {
			clearInterval(this.eventInt);
			this.callback({error:"No return from " + this.variable});
		}
	}
	LMSCall.eventInt = setInterval(LMSCall, "SEvent", 500);;
}
// The commit call to the LMS
scormNS.xxLMSCommit = function(callback) {
	_root.SCORMCommit = undefined;
	myTrace("call LMSCommit",0);
	fscommand("LMSCommit");

	var LMSCall = new Object();
	LMSCall.callback = callback;
	LMSCall.variable = "SCORMCommit";
	LMSCall.SEvent = function() {
		if (_root[this.variable] != undefined) {
			//myTrace("caught " + this.variable + " being set to " + _root[this.variable]);
			clearInterval(this.eventInt);
			if (_root[this.variable].indexOf("error:") == 0) {
				this.callback({error:_root[this.variable]})
			} else {
				this.callback({value:_root[this.variable]})
			}
		} else {
			//myTrace("waiting for " + this.variable);
			this.count++;
		}
		// there is no point waiting for this for too long
		if (this.count > 10) {
			clearInterval(this.eventInt);
			this.callback({error:"No return from " + this.variable});
		}
	}
	LMSCall.eventInt = setInterval(LMSCall, "SEvent", 500);;
}
*/
// datamodel names
scormNS.getCMIName = function(purpose, index) {
	switch (purpose) {
		case "studentName":
			myTrace("CMI names from version " + scormNS.version,0);
			if (scormNS.version == "1.3") {
				return "cmi.learner_name";
			} else {
				return "cmi.core.student_name";
			}
			break;
		// v6.5.6 Added to see if useful for HCT
		case "studentID":
			if (scormNS.version == "1.3") {
				return "cmi.learner_id";
			} else {
				return "cmi.core.student_id";
			}
			break;
		case "interfaceLanguage":
			if (scormNS.version == "1.3") {
				return "cmi.learner_preference.language";
			} else {
				return "cmi.student_preference.language";
			}
			break;
		case "version":
			return "cmi._version";
			break;
		case "suspendData":
			return "cmi.suspend_data";
			break;
		case "launchData":
			return "cmi.launch_data";
			break;
		case "bookmark":
			if (scormNS.version == "1.3") {
				return "cmi.location";
			} else {
				return "cmi.core.lesson_location";
			}
			break;
		case "sessionTime":
			if (scormNS.version == "1.3") {
				return "cmi.session_time";
			} else {
				return "cmi.core.session_time";
			}
			break;
		case "lessonStatus":
			if (scormNS.version == "1.3") {
				return "cmi.completion_status";
			} else {
				return "cmi.core.lesson_status";
			}
			break;
		case "exit":
			if (scormNS.version == "1.3") {
				return "cmi.exit";
			} else {
				return "cmi.core.exit";
			}
			break;
		// v6.5.1 Added to help ensure that suspend data is fresh for a re-run of a SCO
		case "entry":
			if (scormNS.version == "1.3") {
				return "cmi.entry";
			} else {
				return "cmi.core.entry";
			}
			break;
		case "rawScore":
			if (scormNS.version == "1.3") {
				return "cmi.score.raw";
			} else {
				return "cmi.core.score.raw";
			}
			break;
		case "maxScore":
			if (scormNS.version == "1.3") {
				return "cmi.score.max";
			} else {
				return "cmi.core.score.max";
			}
			break;
		case "minScore":
			if (scormNS.version == "1.3") {
				return "cmi.score.min";
			} else {
				return "cmi.core.score.min";
			}
			break;
		case "objective.count":
			return "cmi.objectives._count";
			break;
		case "objective.id":
			return "cmi.objectives." + index + ".id";
			break;
		case "objective.score":
			return "cmi.objectives." + index + ".score.raw";
			break;
		case "objective.status":
			return "cmi.objectives." + index + ".status";
			break;
		case "rubbish":
			return "cmi.rubbish";
			break;
		default:
			myTrace("badly called getCMIName with " + purpose);					
	}
}
//
// **************
// Now the events
// **************
// v6.4.3 new code for JSFG handling where you can get multiple values in one go
// First - special calls, the Clarity API to the LMS will send these back in one go
scormNS.initialise = function () {
	myTrace("call to API.initialise");
	scormNS.stillLoading = true;
	// This is now the place where SCORM is initialised;
	scormNS.onLMSCallComplete = function(response) {
		myTrace("LMSCallComplete, trigger initCallback");
		scormNS.initCallback(response);
	}
	// Call the API to talk to the LMS
	scormNS.LMSInitialise();
}
//myTrace("just writing this");
scormNS.terminate = function () {
	//myTrace("call to API.initialise");
	// This is now the place where SCORM is initialised;
	scormNS.onLMSCallComplete = function(response) {
		myTrace("trigger terminateCallback");
		scormNS.terminateCallback(response);
	}
	// Call the API to talk to the LMS
	scormNS.LMSTerminate();
}

// First call to the API
scormNS.initCallback = function(response) {
	//myTrace("initCallback");
	// many variables are coming back, so look at them individually
	if (scormNS.SCORMInitVar.error == undefined) {
		myTrace("SCORM is on!!");
	} else {
		myTrace("SCORM initialisation failed");
		// stop the program running or run on without using SCORM?
		// probably the former.
		// v6.3.6 Switch SCORM off so that the exit process doesn't try to connect to the API
		_global.ORCHID.commandLine.scorm = false;
		// v6.3.6 Don't say the you have initialised if failure
		//_root.controlNS.remoteOnData(scormNS.moduleName);
		_global.ORCHID.root.controlNS.sendError({literal:"notInSCORM"});
		// and that is that
		return;
	}
	if (scormNS.SCORMthisLMS.error == undefined) {
		switch (scormNS.SCORMthisLMS.value) {
			case "CLiKS":
			case "DOKEOS":
			case "Blackboard":
			case "WebCT":
			case "RELOAD":
			case "Lotus":
			case "Ganesha":
			case "EOICampus":
			case "Moodle":
				scormNS.LMS = scormNS.SCORMthisLMS.value;
				break;
			default:
				scormNS.LMS = "generic";
		}
	} else {
		scormNS.LMS = "generic";
	}
	if (scormNS.SCORMjsVersion.error == undefined) {
		scormNS.version = scormNS.SCORMjsVersion.value;
		// this value will let you set the variable names you need for talking to
		// different versions of SCORM (1.2 and 2004)
	} else {
		// we will make an assumption about the version then (in getCMIName)
	}
	myTrace("running from " + scormNS.LMS + " js:SCORM v" + scormNS.SCORMjsVersion.value);
	if (scormNS.SCORMStart.error==undefined) {
		myTrace("LMS start parameter=" + scormNS.SCORMStart.value);
		scormNS.launchStart = scormNS.SCORMStart.value;
	} else {
		//myTrace("no LMS start, " + response.error);
		scormNS.launchStart = undefined;
	}
	// Now do next set of calls, which actually use the SCORM api rather than our own variables
	// v6.5.5.5 Include objectives - are they supported in this LMS?
	var cmiData = [{name:scormNS.getCMIName("studentName"), variable:"SCORMName"},
				   {name:scormNS.getCMIName("studentID"), variable:"SCORMStudentID"},
				   {name:scormNS.getCMIName("interfaceLanguage"), variable:"SCORMLanguage"},
				   {name:scormNS.getCMIName("version"), variable:"SCORMVersion"},
				   {name:scormNS.getCMIName("launchData"), variable:"SCORMLaunchData"},
				   {name:scormNS.getCMIName("entry"), variable:"SCORMEntryData"},
				   {name:scormNS.getCMIName("suspendData"), variable:"SCORMSuspendData"},
				   {name:scormNS.getCMIName("objective.count"), variable:"SCORMObjectives"}];
	myTrace("call to LMSGetValue");
	scormNS.LMSGetValue(cmiData, scormNS.firstDataCallback);
}
scormNS.firstDataCallback = function(response) {
	myTrace("firstDataCallback");
	// Go through all the data you got back, reacting to each variable
	// Get the student's name
	if (scormNS.SCORMName.error == undefined) {
		_global.ORCHID.commandLine.userName = scormNS.SCORMName.value;
	} else {
		// v6.3.6 If no name sent (should be impossible), then better not to go on
		// with getting SCORM information as we will have to login anyway. Or we
		// could assume the user is the anonymous one (set empty name).
		_global.ORCHID.commandLine.userName = "";
		myTrace(scormNS.getCMIName("studentName") + " error=" + scormNS.SCORMName.error);
	}
	myTrace("scorm user is " + _global.ORCHID.commandLine.userName);
	// v6.5.6 And the student ID if there is one
	if (scormNS.SCORMStudentID.error == undefined) {
		// If you have found an ID, then maybe you will use this for login?
		_global.ORCHID.commandLine.studentID = scormNS.SCORMStudentID.value;
		myTrace("with ID " + _global.ORCHID.commandLine.studentID);
	} else {
		// No ID is fine.
	}
	// also ask for other information about the student
	// Oh, this is set by the sco, so presumably I need to display the language selector and
	// then remember it if chosen by the student.
	if (scormNS.SCORMLanguage.error==undefined) {
		// v6.3.6 Need a function to query loaded literals to see if we can use
		// the requested language...
		if (scormNS.SCORMLanguage.value == "EN" || 
			scormNS.SCORMLanguage.value == "ES" || 
			scormNS.SCORMLanguage.value == "FR" || 
			scormNS.SCORMLanguage.value == "TH" || 
			scormNS.SCORMLanguage.value == "SV" || 
			scormNS.SCORMLanguage.value == "ZHO") {
			_global.ORCHID.commandLine.language = scormNS.SCORMLanguage.value;
			myTrace("set language to " + scormNS.SCORMLanguage.value);
		} else if (scormNS.SCORMLanguage.value == "English") {
			_global.ORCHID.commandLine.language = "EN";
			myTrace("set language to EN");
		} else if (scormNS.SCORMLanguage.value == "Thai") {
			_global.ORCHID.commandLine.language = "TH";
			myTrace("set language to TH");
		} else {
			_global.ORCHID.commandLine.language = "EN";
			myTrace("LMS language not recognised (" + scormNS.SCORMLanguage.value + ")");
		}
	} else {
		myTrace(scormNS.getCMIName("interfaceLanguage") + " error=" + scormNS.SCORMLanguage.error);
	}
	//v6.3.6 Also ask for the datamodel version (though I don't use it yet)
	if (scormNS.SCORMVersion.error == undefined) {
		myTrace(scormNS.getCMIName("version") + scormNS.SCORMVersion.value);
		scormNS.dataversion = scormNS.SCORMVersion.value;
	} else {
		myTrace(scormNS.getCMIName("version") + " error=" + scormNS.SCORMVersion.error);
		scormNS.dataversion = undefined;
	}
	// Too many LMS don't do error handling, so we can't rely on that to tell us that
	// launch_data is not supported. Thus assume the launch_data ALWAYS should have a value
	// and if it doesn't you need to try other ways of seeing where to start.
	if (scormNS.SCORMLaunchData.error==undefined && scormNS.SCORMLaunchData.value!="") {
		// debug with preset launch_data - Blackboard does not seem to pass this through
		// likewise, Dokeos does not support this variable. So why don't I get a 
		// no such variable error? (Blackboard does now support this)
		//response.value = "course=1,unit=u1";
		// break up the launch data into value pairs
		var launchData = new Object();
		var sections = scormNS.SCORMLaunchData.value.split(",");
		for (var i in sections) {
			var valuePair = sections[i].split("=");
			launchData[valuePair[0]] = valuePair[1];
			//myTrace("launchData." + valuePair[0] + "=" + valuePair[1]);
		}
		_global.ORCHID.commandLine.course = launchData.course;
		if (launchData.unit != undefined) {
			_global.ORCHID.commandLine.startingPoint = "unit:" + launchData.unit;
		} else if (launchData.exercise != undefined) {
			_global.ORCHID.commandLine.startingPoint = "ex:" + launchData.exercise;
		} else {
			_global.ORCHID.commandLine.startingPoint = "menu";
		}
	} else {
		myTrace(scormNS.getCMIName("launchData") + " error =" + scormNS.SCORMLaunchData.error);
		// v6.3.4 If this element is not implemented, try reading parameters
		// passed to the start module (which you asked for earlier - scormStart)
		// start=1-u1
		//myTrace("so try using start=" + scormNS.launchStart);
		if (scormNS.launchStart != "" && scormNS.launchStart != undefined) {
			var launchData = scormNS.launchStart.split("-");
			//myTrace("giving course=" + launchData[0]);
			_global.ORCHID.commandLine.course = launchData[0];
			//myTrace("use course=" + _global.ORCHID.commandLine.course);
			//v6.4.2 Units don't have u at the front now, just regular ID
			// but you can assume that SCORM is only going to supply a unit ID
			// (if it does do an exercise, assume it will tag on 'ex:')
			//if (launchData[1].indexOf("u") >= 0) {
			//	_global.ORCHID.commandLine.startingPoint = "unit:" + launchData[1];
			//} else if (launchData[1].indexOf("e") >= 0) {
			//	_global.ORCHID.commandLine.startingPoint = "ex:" + launchData[1];
			//} else {
			//	// so assume default is just the main menu
			//	_global.ORCHID.commandLine.startingPoint = "menu";
			//}
			if (launchData[1].indexOf("ex:") == 0) {
				_global.ORCHID.commandLine.startingPoint = launchData[1];
			} else {
				_global.ORCHID.commandLine.startingPoint = "unit:" + launchData[1];
			}
		} else {
			_global.ORCHID.commandLine.course = undefined;
			// so assume default is just the main menu
			_global.ORCHID.commandLine.startingPoint = "menu";
		}
		//myTrace("after all that, starting point=" + _global.ORCHID.commandLine.startingPoint);
	}
	myTrace("LMS start course=" + _global.ORCHID.commandLine.course,0);
	myTrace("LMS start point=" + _global.ORCHID.commandLine.startingPoint,0);
	// v6.5.1 Also pick up the cmi.entry information to double check that suspend data is valid
	if (scormNS.SCORMEntryData.error==undefined) {
		scormNS.entryData = scormNS.SCORMEntryData.value;
		myTrace("LMS entry data=" + scormNS.SCORMEntryData.value);
	} else {
		myTrace(scormNS.getCMIName("entryData") + " error=" + scormNS.SCORMEntryData.error);
		// so just set it to empty string
		scormNS.entryData = "";
	}
	// Is it safe to be this strict? Or should I clear out anything in suspendData only if entry=ab-initio?
	// Or does it depend on the LMS?
	if (scormNS.entryData == "resume") {
		myTrace("use suspend data as entry is a resumption");
		// and ask for the suspend data (hopefully set in the LMS)
		if (scormNS.SCORMSuspendData.error==undefined) {
			scormNS.suspendData = scormNS.SCORMSuspendData.value;
			myTrace("suspend data=" + scormNS.SCORMSuspendData.value);
		} else {
			myTrace(scormNS.getCMIName("suspendData") + " error=" + scormNS.SCORMSuspendData.error);
		}
	} else {
		myTrace("kill suspend data as entry is new - or special");
		scormNS.suspendData = "";
	}
	//v6.5.5.5 Are objectives supported?
	if (scormNS.SCORMObjectives.error == undefined) {
		myTrace(scormNS.getCMIName("objective.count") + "=" + scormNS.SCORMObjectives.value);
		scormNS.LMSCanUseObjectives = true;
		scormNS.objectives = new Object();
		scormNS.objectives.count = scormNS.SCORMObjectives.value;
	} else {
		myTrace(scormNS.getCMIName("objective.count") + " error=" + scormNS.SCORMObjectives.error);
		scormNS.LMSCanUseObjectives = false;
	}

	// That is all you want at the moment
	// v6.4.2 I want to acknowledge that this module is running right at the start
	// not here. I need another way to know when it is OK to move on.
	//_global.ORCHID.root.controlNS.remoteOnData(scormNS.moduleName);
	// set a flag so that anyone else knows it is safe to go on
	scormNS.stillLoading = false;
	//myTrace("finished, so set stillLoading to " + _global.ORCHID.root.scormHolder.scormNS.stillLoading);	
}

// ********
// Handling the bookmark
// ********
// read the bookmark to see if you are coming back into the middle of a unit
scormNS.getBookmark = function(exerciseID) {
	//myTrace("get " + scormNS.getCMIName("bookmark"));
	// v6.4.3 Update to JSFG
	//scormNS.LMSGetValue(scormNS.getCMIName("bookmark"),"SCORMBookmark",scormNS.getBookmarkCallback);
	var cmiData = [{name:scormNS.getCMIName("bookmark"), variable:"SCORMBookmark"}];
	scormNS.LMSGetValue(cmiData, scormNS.getBookmarkCallback);
}
// callback from reading the bookmark - or not
// v6.4.3 Update to JSFG
scormNS.getBookmarkCallback = function(response) {
	//var response = scormNS.SCORMBookmark;
	//myTrace("getBookmarkCallback " + response.value + " " + response.error);
	if (response.value != "" && response.error == undefined) {
		var nothingElseBookmark = "none";
		var thisBookmark = undefined;
		// v6.5.1 If you don't have a entry status of "resume" - then your bookmark is questionable.
		// It seems that Moodle isn't clearing it out very well when you complete a SCO.
		if (response.value=="none") {
			myTrace("no bookmark set");
		} else if (scormNS.entryData != "resume") {
			myTrace("LMS ** got a bookmark, yet I am not resuming this SCO");
		} else {
			// Don't overwrite any other starting point in case this bookmark is not valid
			//_global.ORCHID.commandLine.startingPoint = "ex:" + response.value;
			//v6.4.3 Blackboard shares one bookmark between different SCOs
			// so add the startingPoint to the bookmark so you can find yours
			// since the startingPoint will be unique for each SCO
			// So expecting bookmark to look like "unit:u4@ex:154|unit:u5@ex:116"
			//v6.4.3 See complication in setBookmark section.
			// But Blackboard does now seem to be maintaining different bookmarks.
			var fullBookmark = response.value;
			var bookmarkArray = fullBookmark.split("|");
			var breakBookmark;
			for (var i in bookmarkArray) {
				// check each bookmark pair - is there a recorded starting point?
				if (bookmarkArray[i].indexOf("@")>0) {
					breakBookmark = bookmarkArray[i].split("@");
					if (breakBookmark[0] == _global.ORCHID.commandLine.startingPoint) {
						thisBookmark = breakBookmark[1];
						break;
					}
				} else {
				// no recorded starting point, so must be a pure bookmark, use as a default
					nothingElseBookmark = bookmarkArray[i];
				}
			}
		}
		if (thisBookmark == undefined) thisBookmark = nothingElseBookmark;
			
		myTrace("LMS bookmark " + thisBookmark,0);
		scormNS.startingFromBookmark(thisBookmark);
	} else if (response.error != undefined && response.error != "") {
		// an error
		myTrace(scormNS.getCMIName("bookmark") + " error =" + response.error,0);
		// so open from the manifest settings anyway
		//scormNS.startingFromManifest();
		_global.ORCHID.root.controlNS.startingDirect();
	} else {
		// not really an error, just no defined bookmark
		myTrace("LMS, no bookmark set",0);
		//scormNS.startingFromManifest();
		_global.ORCHID.root.controlNS.startingDirect();
	}
}
scormNS.startingFromBookmark = function(id) {
	//myTrace("startingFromBookmark " + _global.ORCHID.commandLine.startingPoint);
	//myTrace("startingFromBookmark " + id);
	//var startInfo = _global.ORCHID.commandLine.startingPoint.split(":");
	var startInfo = id.split(":");
	var startingType = startInfo[0];
	var startingID = startInfo[1];
	//var startingID = id;
	// v6.3.5 You can only have exercises as bookmarks, save any searching
	// or embarrasing hits. Blackboard returns a whole long string as the inital
	// bookmark for instance.
	if (startingType != "ex") {
		var thisScaffoldItem = null
	} else {
		var thisScaffoldItem = _global.ORCHID.course.scaffold.getObjectByID(startingID);
	}
	// once you have the exercise ID, send it to the normal exercise creation point
	//myTrace("so that is exercise " + thisScaffoldItem.id);
	// v6.3.4 Any bookmarks that have been set that don't match a proper scaffold id
	// will come back as null. So in that case start from the manifest.
	if (thisScaffoldItem == null) {
		myTrace("not a valid bookmark");
		//scormNS.startingFromManifest();
		_global.ORCHID.root.controlNS.startingDirect();
	} else {
		_global.ORCHID.root.controlNS.createExercise(thisScaffoldItem);		
	}
}
// set the bookmark that shows where to come back to
// v6.4.3 No longer do anything here, but wrap it up with score writing
// You cannot be sure of the timing if you get two separate calls from Orchid.
scormNS.setBookmark = function(exerciseID) {
}

// These functions are called from outside this module
scormNS.getCourseID = function() {
	return _global.ORCHID.commandLine.course;
}
scormNS.getStartingID = function() {
	//myTrace("ask LMS for starting point");
	// first of all you need to know if you are starting where the sco always starts
	// or if you have saved a bookmark for this sco that will let you start somewhere else
	this.getBookmark();
}
scormNS.exit = function(justExit) {
	//myTrace("start SCORM exit process");
	this.setExitStatus(justExit);
}
scormNS.setScore = function(scoreRecord) {
	// save the score record in this namespace
	scormNS.scoreRecord = scoreRecord;
	// There is no point sending empty score records to the LMS as it (probably) can't cope
	// so just skip over these. No, might as well record an empty raw score.
	//if (scormNS.scoreRecord.score >= 0 && !scormNS.LMSCannotSaveScore) {
	// v6.3.5 But it is worth seeing if you already know you cannot save records
	// v6.3.6 Drop the idea of using objectives and simply use suspend_data
	// v6.5.5.5 Resurrect it to get better record keeping, but use suspend_data for our main counting
	
	// We got the objectives count on our init call, now we can just add to it.
	if (scormNS.LMSCanUseObjectives) {
		myTrace("send this score record to the LMS for objective " + scormNS.objectives.count);
		//myTrace("objectiveID=" + scormNS.getCMIName("objective.id",scormNS.objectives.count));
		// SCORM says that this string should have no spaces in it! Why - I have no idea.
		// Also can't have question marks! What about other punctuation?
		// Moodle implementation has regex '^\\w{1,255}$' - so allowing letters, digits and underscores only.
		var objectiveName = _global.ORCHID.session.currentItem.caption.split(" ").join("_");
		objectiveName = objectiveName.split(":").join("_");
		objectiveName = objectiveName.split("?").join("_");
		objectiveName = objectiveName.split("'").join("_");
		objectiveName = objectiveName.split("!").join("_");
		objectiveName = objectiveName.split("-").join("_");
		//var objectiveRegExp = new RegExp("\W","g");
		//var objectiveName = objectiveName.replace(objectiveRegExp,"_");
		myTrace("new name=" + objectiveName);
		var cmiData = [{name:scormNS.getCMIName("objective.id",scormNS.objectives.count), value:objectiveName, variable:"SCORMSetObjectiveID"},
					{name:scormNS.getCMIName("objective.status",scormNS.objectives.count), value:"completed", variable:"SCORMSetObjectiveStatus"}];
		// only send the score if it is valid (0 to 100)
		if (scormNS.scoreRecord.score>=0 && scormNS.scoreRecord.score<=100) {
			myTrace("write score for the objective of " + scormNS.scoreRecord.score);
			cmiData.push({name:scormNS.getCMIName("objective.score",scormNS.objectives.count), value:scormNS.scoreRecord.score, variable:"SCORMSetObjectiveScore"});
		}
		scormNS.LMSSetValue(cmiData,scormNS.setObjectivesCallback);
		// Update our local count
		scormNS.objectives.count++;
	} else {
		//v6.3.6 Clearly objectives are not implemented by this LMS.
		// Save this record's info in the suspend_data
		// Surely we should be saving here whether or not we are using the objectives?
		scormNS.saveScoreInSuspendData();
	}
	
}
scormNS.setObjectivesCallback = function(response) {
	if (response.value == "true") {
		myTrace("set objective successfully");
		//var success = true;
	} else {
		// You can't write the objectives, though they are implemented
		myTrace("set objectives failed: error=" + response.error,0);
		//var success = false;
	}
	// Go ahead and save the score in suspend data anyway
	scormNS.saveScoreInSuspendData();
	
}
// v6.3.6 This function is used to save scores in the suspend_data if you know, or suspect
// that you cannot use the objectives structure from the LMS. Would it be simpler just to
// always (and only) do this? Especially as objectives is an optional SCORM object!?
// v6.5.5.5 Lets try adding it in again, but with handling that says "well fine" if the LMS doesn't support objectives.
scormNS.saveScoreInSuspendData = function() {
	// First, nothing to do if this is not a valid score record
	if (scormNS.scoreRecord.score >= 0) {
		// v6.3.6 Use cmi.suspend_data to hold scores for LMS that don't support objectives?
		//var totalScore = 0;
		//var numExercises = 0;
		// What is currently in suspendData?
		//myTrace("current suspend=" + scormNS.suspendData);
		// Takes the form of exXXX:YY|exXXX:YY (where YY is the %)
		
		// Break the string into an array of scores
		var suspendScores = scormNS.suspendData.split("|");
		// And check that the expected tag is the first element (proves the structure)
		var suspendDataTag = suspendScores[0];
		var suspendExpectedTag = "score-so-far";
		if (suspendDataTag == suspendExpectedTag) {
			//var suspendNumExercises = suspendScores.length - 1;
			//var suspendAverageScore = suspendScore[1];
			//myTrace("from earlier suspend, avgScore=" + suspendAverageScore + ", numEx=" + suspendNumExercises);
			//totalScore = suspendAverageScore + suspendNumExercises;
		} else {
			myTrace("empty or unexpected suspend data, so make a new copy");
			// make a nice clean suspend object
			suspendScores = new Array(suspendExpectedTag);
		}
		// add in the value from this record
		suspendScores.push(scormNS.scoreRecord.itemID + ":" + scormNS.scoreRecord.score);
		scormNS.suspendData = suspendScores.join("|");
		//totalScore += scormNS.scoreRecord.score;
		//numExercises = suspendNumExercises + 1;
		//var averageScore = totalScore / numExercises;
		//myTrace("so, totalScore=" + totalScore + ", numEx=" + numExercises + ", avg=" + averageScore);
		//scormNS.suspendData = "score-so-far|" + averageScore + "|" + numExercises;

		// Then write it out in case you later exit without a chance to write out
		// v6.4.3 Upgrade to JSFG
		//scormNS.LMSSetValue(scormNS.getCMIName("suspendData"),scormNS.suspendData,"SCORMSetSuspendData",scormNS.setSuspendDataCallback);
		var cmiData = [{name:scormNS.getCMIName("suspendData"), value:scormNS.suspendData, variable:"SCORMSetSuspendData"}];
		scormNS.LMSSetValue(cmiData,scormNS.setSuspendDataCallback);
	} else {
		myTrace("empty record, so nothing to save",1);
		// v6.3.4 Make sure you trigger an event on the score record that it is time to go on
		// Return true as nothing was needed and nothing was done!
		//scormNS.scoreRecord.onReturnCode(true);
		//v6.4.3 But you do need to trigger the bookmark saving - which also does the
		// above onReturnCode call.
		scormNS.setSuspendDataCallback({value:"true"});
	}
}
// v6.3.6 Check on writing of suspend_data
scormNS.setSuspendDataCallback = function(response) {
	if (response.value == "true") {
		myTrace("set suspend data successfully");
		var success = true;
	} else {
		myTrace("set suspend data failed: error=" + response.error,0);
		var success = false;
	}
	// v6.4.3 Now you need to set the bookmark - held in suspense
	// Now simply read from global.
	var bookmark = _global.ORCHID.session.nextItem.id;
	myTrace("pick up bookmark:" + bookmark);
	//v6.4.3 Since Blackboard shares one bookmark between many SCOs, you should record
	// the starting point along with the bookmark. See reading for idea. But I am sure
	// that the LMS will overwrite this back to empty once you complete one SCO anyway,
	// so it is pointless. An alternative is to say that you add the startingPoint
	// and that if you don't match, you ignore. This will at least let Blackboard run
	// two units even if it can't save them.
	// v6.4.3 Upgrade to JSFG
	if (bookmark == undefined) {
		//myTrace(scormNS.getCMIName("bookmark") + " to undefined");
		//scormNS.LMSSetValue(scormNS.getCMIName("bookmark"),"none","SCORMSetBookmark",scormNS.setBookmarkCallback);
		var builtBookmark = "none";
	} else {
		//v6.4.3 Expecting bookmark to look like "unit:u4@ex:116"
		var builtBookmark = _global.ORCHID.commandLine.startingPoint + "@" + "ex:" + bookmark;
		//myTrace(scormNS.getCMIName("bookmark") + " to ex:" + exerciseID);
		//scormNS.LMSSetValue(scormNS.getCMIName("bookmark"),builtBookmark,"SCORMSetBookmark",scormNS.setBookmarkCallback);
	}
	var cmiData = [{name:scormNS.getCMIName("bookmark"), value:builtBookmark, variable:"SCORMSetBookmark"}];
	scormNS.LMSSetValue(cmiData,scormNS.setBookmarkCallback);
	// v6.3.4 Make sure you trigger an event on the score record that it is time to go on
	scormNS.scoreRecord.onReturnCode(success);
}
// Once you have set the bookmark, for testing sake you can immediately read it as a check
// Can take this out once all is well.
scormNS.setBookmarkCallback = function(response) {
	if (response.value == "true") {
		myTrace("set bookmark successfully");
	}
	// v6.3.6 main problem was due to Dokeos not supporting bookmark (or suspend)
	/*
	if (response.value == "true") {
		scormNS.LMSGetValue(scormNS.getCMIName("bookmark"),"SCORMBookmark",scormNS.checkingBookmarkCallback);
	}
	*/
	// v6.4.1.4 Since some LMS cache calls to LMSSetValue - we need to commit once a score/bookmark
	// combination is written. But don't send main commit callback as that is part of exit process
	scormNS.LMSCommit(scormNS.setValueCallback);
}

scormNS.commitCallback = function(response) {	
	//myTrace("commitCallback with value:" + response.value + " error:" + response.error);
	if (response.value == "true") {
		myTrace("SCORM commit successful");
		// send the final LMS message
	} else {
		myTrace("SCORM commit failed",0);
		// but what on earth can you do - tell them that their scores are lost
		// (or just that they might be lost).
	}
	//myTrace("call scormNS.LMSTerminate");
	scormNS.LMSTerminate(scormNS.exitCallback);
}
// v6.4.3 Update for JSFG
scormNS.exitCallback = function(response) {	
	//myTrace("exitCallback with value:" + response.value + " error:" + response.error);
	//var response = responses[0];
	if (response.value == "true") {
		myTrace("SCORM termination successful",0);
	} else {
		myTrace("SCORM termination failed",0);
	}
	// callback into the normal exit routine
	_global.ORCHID.root.gotoAndStop("exit");
}

// functions for setting exit status before exiting
scormNS.setExitStatus = function(justExit) {
	// v6.3.6 Allow yourself to be called in 'emergency' exit mode
	// (probably licence failure)
	if (justExit) {
		myTrace("request to justExit");
		// v6.4.3 Upgrade to JSFG
		//scormNS.LMSSetValue(scormNS.getCMIName("exit"),"suspend","SCORMSetExit",scormNS.setExitStatusCallback);
		var cmiData = [{name:scormNS.getCMIName("exit"), value:"suspend", variable:"SCORMSetExit"}];
		scormNS.LMSSetValue(cmiData,scormNS.setExitStatusCallback);
	} else {
	
		// set several variables in the model, but only really check the return on the last
		// to avoid a huge stack of callbacks. After all, if one call fails, you will probably
		// still want to keep going with the others.
		// How long have they spent in this session (accumulated by LMS)
		var now = new Date().getTime();
		//myTrace("start time=" + _global.ORCHID.session.startTime);
		var startTime = _global.ORCHID.session.startTime.getTime();
		//myTrace("in milliseconds=" + startTime);
		var timeSpent = now - startTime;
		// v6.3.6 Do a reality check - don't set the time if it is over 24 hours
		// as presumably meaningless
		if (timeSpent > (24 * 60 * 60 * 1000)) {
			timeSpent = 0;
		}
		//myTrace("time spent=" + timeSpent);
		var timeParts = new Array();
		// SCORM needs HHHH:MM:SS.SS
		timeParts[0] = _global.ORCHID.root.objectHolder.make2digitString(Math.floor(timeSpent / (1000*60*60)),4);
		//myTrace("hours=" + timeParts[0]);
		timeParts[1] = _global.ORCHID.root.objectHolder.make2digitString(Math.floor((timeSpent - (timeParts[0]*(1000*60*60))) / (1000*60)));
		timeParts[2] = _global.ORCHID.root.objectHolder.make2digitString(Math.floor((timeSpent - (timeParts[0]*(1000*60*60)) - (timeParts[1]*(1000*60))) / 1000));
		//timeParts[3] = _global.ORCHID.root.objectHolder.make2digitString(0);
		var timeString = timeParts.join(":");
		// milliseconds (which we don't bother with) are appended after a . rather than a :
		timeString = timeString + ".00";
		//myTrace("this session lasted " + timeString,0);	
		//scormNS.LMSSetValue(scormNS.getCMIName("sessionTime"),timeString,"SCORMSetTime",scormNS.setTimeCallback);
		var cmiData = [{name:scormNS.getCMIName("sessionTime"), value:timeString, variable:"SCORMSetTime"}];
		scormNS.LMSSetValue(cmiData,scormNS.setTimeCallback);
	}
}
scormNS.setTimeCallback = function() {
	if (response.value == "true") {
		myTrace("set time successfully");
	}
	// You should only set score.raw and lesson_status="passed/failed" when the SCO is done
	// There are different ways to tell if the SCO is done. If the SCO is a unit, then you are
	// done when there is no next exercise set. If the SCO is an exercise, you are always done!
	// If the SCO is the whole course, it will be rather more complicated. I don't think this
	// will happen.
	// NOTE: this isn't quite good enough as if you come back in from a resume, the startingPoint
	// will use the resume exercise ID. So you need to check against the launch data as that is the
	// point where the manifest intentions are clear. Now I have NOT overruled startingPoint when
	// reading the bookmark, so it should be valid.
	if (_global.ORCHID.session.nextItem.id == undefined &&
		_global.ORCHID.commandLine.startingPoint.indexOf("unit")>=0) {
		myTrace("this is the last exercise in the unit, so SCO is over",1);
		// and what is their average score? 
		// v6.3.6 Drop the use of objectives, prefer the use of suspend_data
		/*
		// To find out you should read all the objectives and average them. If they have done 
		// one exercise twice, then (as per Results Manager) both scores are included.
		// NOTE: one problem here seems to be that the last exercise score might not have actually
		// finished being set, so you may miss it in the objectives count.
		scormNS.LMSGetValue("cmi.objectives._count", "SCORMObjectivesCount", scormNS.readAllObjectivesCallback);
		*/
		// The score from the last exercise is sure to have been written already
		scormNS.writeAverageScore();
		// the rest of this function goes to the callback as this might take a little while
		// so you cannot go on with the exit until it is done.
		// v6.3.6 You know you have finished, so set the lesson_status accordingly. You might
		// overwrite this later if scores and mastery are all set
		// v6.4.2 In fact, this is get written AFTER the mastery stuff, so I think it should 
		// go in the same place
		//scormNS.LMSSetValue(scormNS.getCMIName("lessonStatus"),"completed","SCORMSetStatus",scormNS.setValueCallback);
	} else if (_global.ORCHID.commandLine.startingPoint.indexOf("ex")>=0) {
		myTrace("this is the only exercise, so SCO is over",1);
		// v6.3.6 Make it part of standard process
		//scormNS.scoreOneExercise();
		scormNS.writeAverageScore();
		// v6.3.6 You know you have finished, so set the lesson_status accordingly. You might
		// overwrite this later if scores and mastery are all set
		// v6.4.2 In fact, this is get written AFTER the mastery stuff, so I think it should 
		// go in the same place
		//scormNS.LMSSetValue(scormNS.getCMIName("lessonStatus"),"completed","SCORMSetStatus",scormNS.setValueCallback);
	// If they leave in the meantime you should set to suspend
	} else {
		myTrace("this is NOT the last exercise, so SCO is suspending",1);
		
		// v6.3.6 You know you have not finished, so set the lesson_status accordingly. 
		//scormNS.LMSSetValue(scormNS.getCMIName("lessonStatus"),"incomplete","SCORMSetStatus",scormNS.setLessonStatusCallback);
		var cmiData = [{name:scormNS.getCMIName("lessonStatus"), value:"incomplete", variable:"SCORMSetStatus"}];
		scormNS.LMSSetValue(cmiData,scormNS.setLessonStatusCallback);
	}
}
scormNS.setLessonStatusCallback = function(response) {
	if (response.value == "true") {
		myTrace("set lesson status successfully");
	}
	if (_global.ORCHID.session.nextItem.id == undefined &&
		_global.ORCHID.commandLine.startingPoint.indexOf("unit")>=0) {
		//scormNS.LMSSetValue(scormNS.getCMIName("exit"),"","SCORMSetExit",scormNS.setExitStatusCallback);
		var buildStatus = "";
		//var buildStatus = null;
	} else if (_global.ORCHID.commandLine.startingPoint.indexOf("ex")>=0) {
		//scormNS.LMSSetValue(scormNS.getCMIName("exit"),"","SCORMSetExit",scormNS.setExitStatusCallback);
		var buildStatus = "";
		//var buildStatus = null;
	} else {
		//scormNS.LMSSetValue(scormNS.getCMIName("exit"),"suspend","SCORMSetExit",scormNS.setExitStatusCallback);
		var buildStatus = "suspend";
	}
	var cmiData = [{name:scormNS.getCMIName("exit"), value:buildStatus, variable:"SCORMSetStatus"}];
	scormNS.LMSSetValue(cmiData,scormNS.setExitStatusCallback);
}
// I think that this can actually become part of writeAverageScore
/*
scormNS.scoreOneExercise = function() {
	var averageScore = scormNS.scoreRecord.score;
	scormNS.LMSSetValue(scormNS.getCMIName("rawScore"),averageScore,"SCORMSetScore",scormNS.setValueCallback);
	// so did they pass (if a masteryscore was set by the LMS)?
	// this should also really check that this is a credit course
	if (averageScore >= _global.ORCHID.commandLine.masteryScore) {
		scormNS.LMSSetValue(scormNS.getCMIName("lessonStatus"),"passed","SCORMSetValue2",scormNS.setValueCallback);
	} else {
		scormNS.LMSSetValue(scormNS.getCMIName("lessonStatus"),"failed","SCORMSetValue2",scormNS.setValueCallback);
	}
	// the SCO is finished, first clear any bookmark (although the LMS might do this as well)
	scormNS.setBookmark();
	scormNS.LMSSetValue(scormNS.getCMIName("exit"),"","SCORMSetExit",scormNS.setExitStatusCallback);
}
score-so-far|e100:13|e102:20|e103:25|e104:0
0e100e102e103e104
*/
// v6.3.6 No longer use objectives, prefer suspend_data
scormNS.writeAverageScore = function() {
	// Takes the form of score-so-far|exXXX:YY|exXXX:YY (where YY is the %)
	var suspendScores = scormNS.suspendData.split("|");
	// And check that the expected tag is the first element (proves the structure)
	var suspendDataTag = suspendScores[0];
	var suspendExpectedTag = "score-so-far";
	var averageScore = 0;
	if (suspendDataTag == suspendExpectedTag) {
		for (var i=1; i< suspendScores.length; i++) {
			averageScore+=parseInt(suspendScores[i].split(":")[1]);
		}
		averageScore = averageScore / (suspendScores.length-1);
	}
	if (isNaN(averageScore) || averageScore < 0) {
		myTrace("incorrect averageScore of " + averageScore + " changed to 0",0);
		averageScore = 0;
	} else if (averageScore > 100) {
		myTrace("incorrect averageScore of " + averageScore + " changed to 100",0);
		averageScore = 100;
	}
	//v6.4.2.1 Just in case some LMS can't cope with fractions, no harm in rounding
	scormNS.averageScore = Math.round(averageScore);
	//myTrace("average score=" + averageScore,1);
	//scormNS.LMSSetValue(scormNS.getCMIName("rawScore"),scormNS.averageScore,"SCORMSetScore",scormNS.setScoreCallback);
	var cmiData = [{name:scormNS.getCMIName("rawScore"), value:scormNS.averageScore, variable:"SCORMSetScore"}];
	scormNS.LMSSetValue(cmiData,scormNS.setScoreCallback);
}
scormNS.setScoreCallback = function(response) {
	if (response.value == "true") {
		myTrace("set raw score successfully");
	}	
	// v6.5.1 It might make sense to clear the suspend data since you have now written out the score.
	scormNS.suspendData = "";
	var cmiData = [{name:scormNS.getCMIName("suspendData"), value:scormNS.suspendData, variable:"SCORMSetSuspendData"}];
	scormNS.LMSSetValue(cmiData,scormNS.setSuspendDataClearingCallback);
}
scormNS.setSuspendDataClearingCallback = function(response) {
	// so did they pass (if a masteryscore was set by the LMS)?
	// this should also really check that this is a credit course
	// v6.3.5 Or should this be sorted out by the LMS only?
	// read from cmi.student_data.mastery_score
	if (_global.ORCHID.commandLine.masteryScore > 0) {
		if (scormNS.averageScore >= _global.ORCHID.commandLine.masteryScore) {
			//scormNS.LMSSetValue(scormNS.getCMIName("lessonStatus"),"passed","SCORMSetStatus",scormNS.setLessonStatusCallback);
			var cmiData = [{name:scormNS.getCMIName("lessonStatus"), value:"passed", variable:"SCORMSetStatus"}];
		} else {
			//scormNS.LMSSetValue(scormNS.getCMIName("lessonStatus"),"failed","SCORMSetStatus",scormNS.setLessonStatusCallback);
			var cmiData = [{name:scormNS.getCMIName("lessonStatus"), value:"failed", variable:"SCORMSetStatus"}];
		}
	} else {
		//v6.4.2 If no mastery stuff, just say it is complete
		//scormNS.LMSSetValue(scormNS.getCMIName("lessonStatus"),"completed","SCORMSetStatus",scormNS.setLessonStatusCallback);
		var cmiData = [{name:scormNS.getCMIName("lessonStatus"), value:"completed", variable:"SCORMSetStatus"}];
	}
	scormNS.LMSSetValue(cmiData,scormNS.setLessonStatusCallback);
}
scormNS.setExitStatusCallback = function(response) {
	if (response.value == "true") {
		myTrace("exit status set successfully");
	} else {
		myTrace("exit status set failed: error=" + response.error,0);
	}
	// whatever happens we might as well go on with the exiting
	scormNS.LMSCommit(scormNS.commitCallback);
}

// general callback after setting a non-critical parameter
scormNS.setValueCallback = function(response) {
	if (response.value == "true") {
		//myTrace("set value successful (" + response.name + ")");
	} else {
		myTrace("set value failed: error=" + response.error,0);
	}
}
// callback from reading the bookmark - or not
scormNS.checkingBookmarkCallback = function(response) {
	myTrace("checkingBookmarkCallback value=" + response.value + " error=" + response.error);
}

// Register those calls that can be triggered from outside
if (scormNS.communication.ExternalInterface) {
	var extIntInstance:Object = scormNS;
	//var extIntIMethodName:String = "LMSGetValueReturn";
	//var extIntIMethod:Function = scormNS.LMSGetValueReturn;
	//var wasSuccessful:Boolean = ExternalInterface.addCallback(extIntIMethodName, extIntInstance, extIntIMethod);
	//myTrace("ExternalInterface.addCallback." + extIntIMethodName + "=" + wasSuccessful);
	var extIntIMethodName:String = "LMSTrace";
	var extIntIMethod:Function = scormNS.LMSTrace;
	var wasSuccessful:Boolean = ExternalInterface.addCallback(extIntIMethodName, extIntInstance, extIntIMethod);
	myTrace("ExternalInterface.addCallback." + extIntIMethodName + "=" + wasSuccessful);
}

// **********
// unused code
// **********
/*
scormNS.readAllObjectivesCallback = function(response) {
	if (response.error == undefined) {
		scormNS.numObjectives = parseInt(response.value);
		myTrace("numObjectives=" + scormNS.numObjectives);
		if (scormNS.numObjectives == 0 || isNaN(scormNS.numObjectives)) {
			// they didn't do anything this session
			scormNS.numObjectives=0;
			scormNS.readScoreCallback();
		} else {
			// otherwise queue up a series of calls to read each objective's score
			scormNS.countObjectives=0;
			scormNS.countScores=0;
			scormNS.totalScore=0;
			for (var i=0; i<scormNS.numObjectives; i++) {
				var objectiveName = "cmi.objectives." + i + ".score.raw";
				myTrace("read " + objectiveName);
				scormNS.LMSGetValue(objectiveName,"SCORMScore"+i,scormNS.readScoreCallback);
			}
		}
	} else {
		myTrace("error, no objectives read, exit anyway");
		scormNS.numObjectives=0;
		scormNS.readScoreCallback(response);
	}
}
scormNS.readScoreCallback = function(response) {
	// each score that comes back, count it towards the expected number
	scormNS.countObjectives++;
	// if it is a valid response, add in the number
	if (response.error == undefined) {
		if (isNaN(parseInt(response.value))) {
			myTrace("read an objective that had no score");
			// this is a progress record that was not marked, so whilst valid it is not to be counted
		} else {
			myTrace("read an objective with score=" + response.value);
			scormNS.countScores++;
			scormNS.totalScore+= parseInt(response.value);
		}
	} else {
		myTrace("read an objective, but score error");
	}
	// once you have read as many scores as you expect, do the math
	// write out the result and proceed with the exit
	// How to handle the exit if you get stuck here somehow?
	// First condition is if an error occured while reading the objectives
	if (scormNS.numObjectives==0) {
		myTrace("something wrong as no objectives");
		// so the SCO is finished, badly
		scormNS.setBookmark();
		scormNS.LMSSetValue("cmi.core.lesson_status","completed","SCORMSetValue2",scormNS.setValueCallback);
		scormNS.LMSSetValue("cmi.core.exit","","SCORMSetExit",scormNS.setExitStatusCallback);
	// the normal condition where several objectives can be read from the LMS
	} else if (scormNS.countObjectives >= scormNS.numObjectives) {
		myTrace("counted=" + scormNS.countObjectives + " num=" + scormNS.numObjectives);
		if (scormNS.countScores <= 0) {
			var averageScore = 0;
		} else {
			var averageScore = Math.round(scormNS.totalScore / scormNS.countScores);
		}
		scormNS.LMSSetValue("cmi.core.score.raw",averageScore,"SCORMSetScore",scormNS.setValueCallback);
		// so did they pass (if a masteryscore was set by the LMS)?
		// this should also really check that this is a credit course
		if (averageScore >= _global.ORCHID.commandLine.masteryScore) {
			scormNS.LMSSetValue("cmi.core.lesson_status","passed","SCORMSetValue2",scormNS.setValueCallback);
		} else {
			scormNS.LMSSetValue("cmi.core.lesson_status","failed","SCORMSetValue2",scormNS.setValueCallback);
		}
		// the SCO is finished
		scormNS.setBookmark();
		scormNS.LMSSetValue("cmi.core.exit","","SCORMSetExit",scormNS.setExitStatusCallback);
	} else {
		myTrace("counted objectives=" + scormNS.countObjectives);
	}
}
*/
//v6.3.6 Drop the use of objectives
/*
scormNS.objectivesCountCallback = function(response) {
	// we need a successful call to go on
	//myTrace("objective response=" + response.value + " error=" + response.error);
	if (response.error == undefined) {
		// v6.3.5 And that response should be a number, otherwise invalid data
		if (!isNaN(parseInt(response.value))) {
			// now we know the next free objective, we can set it
			// as usual, we make several calls, but only test the response from one (the last one)
			var objectiveName = "cmi.objectives." + parseInt(response.value);
			//myTrace("set objectives to root " + objectiveName);
			scormNS.LMSSetValue(objectiveName + ".id", scormNS.scoreRecord.itemID, "SCORMSetValue0", scormNS.setValueCallback);
			// APO uses -1 to indicate a progress record that cannot have a score. The LMS cannot accept this
			// so leave the raw score empty.
			if (scormNS.scoreRecord.score >= 0) {
				scormNS.LMSSetValue(objectiveName + ".score.raw", scormNS.scoreRecord.score, "SCORMSetValue1", scormNS.setValueCallback);
			} else {
				scormNS.LMSSetValue(objectiveName + ".score.raw", "", "SCORMSetValue1", scormNS.setValueCallback);
			}
			scormNS.LMSSetValue(objectiveName + ".status", "completed", "SCORMSetValue2", scormNS.setObjectiveCallback);		
		} else {
			myTrace("cannot count existing objectives to set this one");
			//v6.3.6 Clearly objectives are not implemented by this LMS.
			// So save this record's info in the suspend_data
			scormNS.saveScoreInSuspend();
			// how to warn the user that their score is not being saved?
			scormNS.scoreRecord.onReturnCode(false);
			// v6.3.5 and don't bother trying to save any other scores.
			scormNS.LMSCannotSaveScore = true;
		}
	} else {
		myTrace("countObjectives error:" + response.error);
		//v6.3.6 Clearly objectives are not implemented by this LMS.
		// So save this record's info in the suspend_data
		scormNS.saveScoreInSuspend();
		// how to warn the user that their score is not being saved?
		scormNS.scoreRecord.onReturnCode(false);
		// v6.3.5 and don't bother trying to save any other scores.
		scormNS.LMSCannotSaveScore = true;
	}	
}
scormNS.setObjectiveCallback = function(response) {
	if (response.value == "true") {
		//myTrace("set objective successfully");
		var success = true;
	} else {
		myTrace("set objective failed: error=" + response.error);
		var success = false;
	}
	// v6.3.4 Make sure you trigger an event on the score record that it is time to go on
	scormNS.scoreRecord.onReturnCode(success);
}
*/


// ***********
// Just for testing
// ***********
//v6.3.5 Tests to show how APO works with the current LMS
scormNS.runTests = function (){
	// see the scripts on the justTest layer
	//myTrace("runTestsrom " + this);
	this.justTest.checkInit();
	this.justTest.getAllVariables();
	//this.justTest.setAllVariables();
	//this.checkCommit();
	//this.checkExit();
}
//this.scope = "this";
//scormNS.scope = "scormNS";
scormNS.justTest = new Object();
//scormNS.justTest.scope = "scormNS.justTest";
scormNS.justTest.myInterface = scormNS.myInterface;
scormNS.justTest.LMSGetValue = scormNS.LMSGetValue;
scormNS.justTest.LMSSetValue = scormNS.LMSSetValue;
scormNS.justTest.setupLog = function() {
	// set up the log
	this.myInterface.createTextField("scormLog",0,50,50,500,450);
	var logText = this.myInterface.scormLog;
	var myScroll = this.myInterface.attachMovie("FScrollBarSymbol", "log_sb", 1);
	logText.multiline = true;
	logText.wordWrap = true;
	logText.selectable = true;
	logText.border = true;
	logText.background = true;
	logText.backgroundColor = 0xFFFFCC;
	var thisTF = new TextFormat();
	thisTF.font = "Verdana";
	thisTF.size = 10;
	logText.setNewTextFormat(thisTF);
	this.addToLog = function(msg) {
		this.myInterface.scormLog.text += msg + newline;
		myTrace(msg);
	}
	this.addToLog("starting tests...");
	myScroll.setScrollTarget(logText);
	var myExit = this.myInterface.attachMovie("FPushButtonSymbol", "myExit", 2);
	var mySuspend = this.myInterface.attachMovie("FPushButtonSymbol", "mySuspend", 3);
	myExit._x = 50; myExit._y = 20;
	myExit.setLabel("exit");
	myExit.setClickHandler("finished", scormNS.justTest);
	mySuspend._x = 200; mySuspend._y = 20;
	mySuspend.setLabel("suspend");
	mySuspend.setClickHandler("suspend", scormNS.justTest);
}
scormNS.justTest.checkInit = function() {
	//myTrace("checkInit in " + this.scope);
	this.setupLog();
	// Check that you were initialised properly
	this.addToLog("test initialisation");
	this.LMSGetValue("xxInit", "SCORMInitVar", this.initCallback, true);	
	this.LMSGetValue("xxVersion", "SCORMjsVersion", this.jsVersionCallback, true);
	this.LMSGetValue("xxStart", "SCORMStart", this.startCallback, true);
}
scormNS.justTest.initCallback = function(response) {
	if (response.error == undefined) {
		scormNS.justTest.addToLog("SCORMInitVar=[" + response.value + "]");
	} else {
		scormNS.justTest.addToLog("SCORMInitVar failed with " + response.error);
	}
}
scormNS.justTest.jsVersionCallback = function(response) {
	if (response.error == undefined) {
		scormNS.justTest.addToLog("SCORMjsVersion=[" + response.value + "]");
		scormNS.version = response.value;
	} else {
		scormNS.justTest.addToLog("SCORMjsVersion failed with " + response.error);
	}
}
scormNS.justTest.startCallback = function(response) {
	if (response.error == undefined) {
		scormNS.justTest.addToLog("SCORMStart=[" + response.value + "]");
	} else {
		scormNS.justTest.addToLog("SCORMStart failed with " + response.error);
	}
}
// basic lms variables
scormNS.justTest.getAllVariables = function() {
	scormNS.justTest.addToLog("=====");
	this.addToLog("test basic variables");
	// This just requests all variables that APO needs from SCORM
	this.LMSGetValue(scormNS.getCMIName("launchData"), "SCORMLaunch", this.launchCallback);
}
scormNS.justTest.launchCallback = function(response) {
	if (response.error == undefined) {
		scormNS.justTest.addToLog(scormNS.getCMIName("launchData") + "=[" + response.value + "]");
	} else {
		scormNS.justTest.addToLog(scormNS.getCMIName("launchData") + " failed with " + response.error);
	}
	scormNS.justTest.addToLog();
	scormNS.justTest.LMSGetValue(scormNS.getCMIName("suspendData"), "SCORMSuspend", scormNS.justTest.suspendCallback);
}
scormNS.justTest.suspendCallback = function(response) {
	if (response.error == undefined) {
		scormNS.justTest.addToLog(scormNS.getCMIName("suspendData") + "=[" + response.value + "]");
	} else {
		scormNS.justTest.addToLog(scormNS.getCMIName("suspendData") + " failed with " + response.error);
	}
	scormNS.justTest.addToLog();
	scormNS.justTest.LMSGetValue(scormNS.getCMIName("studentName"), "SCORMName", scormNS.justTest.nameCallback);
}
scormNS.justTest.nameCallback = function(response) {
	if (response.error == undefined) {
		scormNS.justTest.addToLog(scormNS.getCMIName("studentName") + "=[" + response.value + "]");
	} else {
		scormNS.justTest.addToLog(scormNS.getCMIName("studentName") + " failed with " + response.error);
	}
	scormNS.justTest.addToLog();
	scormNS.justTest.LMSGetValue("cmi.objectives._count", "SCORMObjectivesCount", scormNS.justTest.objectivesCountCallback);
}
scormNS.justTest.objectivesCountCallback = function(response) {
	if (response.error == undefined) {
		scormNS.justTest.addToLog("cmi.objectives._count=[" + response.value + "]");
	} else {
		scormNS.justTest.addToLog("cmi.objectives._count failed with " + response.error);
	}
	scormNS.justTest.addToLog();
	scormNS.justTest.LMSGetValue(scormNS.getCMIName("interfaceLanguage"), "SCORMLanguage", scormNS.justTest.languageCallback);
}
scormNS.justTest.languageCallback = function(response) {
	if (response.error == undefined) {
		scormNS.justTest.addToLog(scormNS.getCMIName("interfaceLanguage") + "=[" + response.value + "]");
	} else {
		scormNS.justTest.addToLog(scormNS.getCMIName("interfaceLanguage") + " failed with " + response.error);
	}
	scormNS.justTest.addToLog();
	scormNS.justTest.LMSGetValue(scormNS.getCMIName("bookmark"), "SCORMBookmark", scormNS.justTest.bookmarkCallback);
}
/* write only
scormNS.justTest.timeCallback = function(response) {
	if (response.error == undefined) {
		scormNS.justTest.addToLog("cmi.core.session_time=[" + response.value + "]");
	} else {
		scormNS.justTest.addToLog("cmi.core.session_time failed with " + response.error);
	}
	scormNS.justTest.addToLog();
	scormNS.justTest.LMSGetValue("cmi.core.lesson_location", "SCORMBookmark", scormNS.justTest.bookmarkCallback);
}
*/
scormNS.justTest.bookmarkCallback = function(response) {
	if (response.error == undefined) {
		scormNS.justTest.addToLog(scormNS.getCMIName("bookmark") + "=[" + response.value + "]");
	} else {
		scormNS.justTest.addToLog(scormNS.getCMIName("bookmark") + " failed with " + response.error);
	}
	scormNS.justTest.addToLog();
	scormNS.justTest.LMSGetValue(scormNS.getCMIName("version"), "SCORMVersion", scormNS.justTest.versionCallback);
}
scormNS.justTest.versionCallback = function(response) {
	if (response.error == undefined) {
		scormNS.justTest.addToLog(scormNS.getCMIName("version") + "=[" + response.value + "]");
	} else {
		scormNS.justTest.addToLog(scormNS.getCMIName("version") + " with " + response.error);
	}
	scormNS.justTest.addToLog();
	scormNS.justTest.LMSGetValue(scormNS.getCMIName("rubbish"), "SCORMVersion", scormNS.justTest.rubbishCallback);
}
scormNS.justTest.rubbishCallback = function(response) {
	if (response.error == undefined) {
		scormNS.justTest.addToLog(scormNS.getCMIName("rubbish") + "=[" + response.value + "]");
	} else {
		scormNS.justTest.addToLog(scormNS.getCMIName("rubbish") + " with " + response.error);
	}
	scormNS.justTest.addToLog("======");
	scormNS.justTest.setAllVariables();
}
// basic lms variables
scormNS.justTest.setAllVariables = function() {
	this.addToLog("test setting variables");
	var thisVar = "ex:e102";
	this.LMSSetValue(scormNS.getCMIName("bookmark"),thisVar,"SCORMSetValue",this.setBookmarkCallback);
}
scormNS.justTest.setBookmarkCallback = function(response) {
	// send a commit to see if that helps fix the bookmark problem
	//scormNS.LMSCommit(scormNS.justTest.pureCommitCallback);
	if (response.error == undefined) {
		scormNS.justTest.addToLog(scormNS.getCMIName("bookmark") + " set=[" + response.value + "]");
	} else {
		scormNS.justTest.addToLog(scormNS.getCMIName("bookmark") + " set failed with " + response.error);
	}
	scormNS.justTest.addToLog("read bookmark again");
	scormNS.justTest.LMSGetValue(scormNS.getCMIName("bookmark"), "SCORMBookmark", scormNS.justTest.newBookmarkCallback);
}
scormNS.justTest.newBookmarkCallback = function(response) {
	if (response.error == undefined) {
		scormNS.justTest.addToLog(scormNS.getCMIName("bookmark") + "=[" + response.value + "]");
	} else {
		scormNS.justTest.addToLog(scormNS.getCMIName("bookmark") + " failed with " + response.error);
	}
	scormNS.justTest.addToLog();
	// SCORM needs HHHH:MM:SS.SS
	var thisVar = "0000:12:45.00";
	scormNS.justTest.LMSSetValue(scormNS.getCMIName("sessionTime"),thisVar,"SCORMSetTime",scormNS.justTest.setValueCallback);
	scormNS.justTest.addToLog();
	var nextVar = "rubbish";
	scormNS.justTest.LMSSetValue(scormNS.getCMIName("rubbish"),nextVar,"SCORMSetRubbish",scormNS.justTest.setRubbishCallback);
}
scormNS.justTest.setRubbishCallback = function(response) {
	if (response.error == undefined) {
		scormNS.justTest.addToLog(scormNS.getCMIName("rubbish") + " set=[" + response.value + "]");
	} else {
		scormNS.justTest.addToLog(scormNS.getCMIName("rubbish") + " failed with " + response.error);
	}
	scormNS.justTest.addToLog();
	var nextVar = "score-so-far|e103:76";
	scormNS.justTest.LMSSetValue(scormNS.getCMIName("suspendData"),nextVar,"SCORMSetSuspendData", scormNS.justTest.setSuspendDataCallback);
}
scormNS.justTest.setSuspendDataCallback = function(response) {
//	scormNS.LMSCommit(scormNS.justTest.pureCommitCallback);
	if (response.error == undefined) {
		scormNS.justTest.addToLog(scormNS.getCMIName("suspendData") + " set=[" + response.value + "]");
	} else {
		scormNS.justTest.addToLog(scormNS.getCMIName("suspendData") + " failed with " + response.error);
	}
	scormNS.justTest.addToLog("read suspend data again");
	scormNS.justTest.LMSGetValue(scormNS.getCMIName("suspendData"), "SCORMSuspendData", scormNS.justTest.newSuspendDataCallback);
}
scormNS.justTest.newSuspendDataCallback = function(response) {
	if (response.error == undefined) {
		scormNS.justTest.addToLog(scormNS.getCMIName("suspendData") + "=[" + response.value + "]");
	} else {
		scormNS.justTest.addToLog(scormNS.getCMIName("suspendData") + " failed with " + response.error);
	}
	scormNS.justTest.addToLog();
	scormNS.justTest.addScore("0");
}
scormNS.justTest.addScore = function(objectivesCount) {
	var objectiveName = "cmi.objectives." + objectivesCount;
	//myTrace("set objectives to root " + objectiveName);
	var thisScore;
	if (objectivesCount == "0") {
		thisScore = {id:"e101", score:"60", next:"1"};
	} else if (objectivesCount == "1") {
		thisScore = {id:"e102", score:"40"};
	}
	scormNS.justTest.LMSSetValue(objectiveName + ".id", thisScore.id, "SCORMSetValue0", scormNS.setValueCallback);
	scormNS.LMSSetValue(objectiveName + ".score.raw", thisScore.score, "SCORMSetValue1", scormNS.setValueCallback);
	scormNS.LMSSetValue(objectiveName + ".status", "completed", "SCORMSetValue2", scormNS.setObjectiveCallback);		
	if (thisScore.next != undefined) {
		scormNS.justTest.addScore(thisScore.next);
	} else {
		//scormNS.justTest.suspend();
		scormNS.justTest.addToLog("tests all finished, click to exit please");
	}
}
scormNS.justTest.suspend = function() {
	clearInterval(scormNS.justTest.exitInt);
	scormNS.justTest.addToLog("start suspend");
	scormNS.justTest.LMSSetValue(scormNS.getCMIName("exit"),"suspend","SCORMSetExit",scormNS.justTest.setExitStatusCallback);
}
scormNS.justTest.finished = function() {
	clearInterval(scormNS.justTest.exitInt);
	scormNS.justTest.addToLog("start finish");
	scormNS.justTest.LMSSetValue(scormNS.getCMIName("rawScore"),"50","SCORMSetScore",scormNS.justTest.setValueCallback);
	scormNS.justTest.LMSSetValue(scormNS.getCMIName("lessonStatus"),"passed","SCORMSetValue2",scormNS.justTest.setValueCallback);
	scormNS.LMSSetValue(scormNS.getCMIName("exit"),"","SCORMSetExit",scormNS.justTest.setExitStatusCallback);
}
scormNS.justTest.setExitStatusCallback = function(response) {
	if (response.value == "true") {
		scormNS.justTest.addToLog("exit status set successfully");
	} else {
		scormNS.justTest.addToLog("exit status set failed: error=[" + response.error + "]");
	}
	// whatever happens we might as well go on with the exiting
	scormNS.LMSCommit(scormNS.justTest.commitCallback);
}
scormNS.justTest.commitCallback = function(response) {	
	//myTrace("commitCallback with value:" + response.value + " error:" + response.error);
	if (response.value == "true") {
		scormNS.justTest.addToLog("commit successful");
	} else {
		scormNS.justTest.addToLog("SCORM commit failed");
		// but what on earth can you do - tell them that their scores are lost
		// (or just that they might be lost).
	}
	//myTrace("call scormNS.LMSTerminate");
	scormNS.LMSTerminate(scormNS.justTest.exitCallback);
}
scormNS.justTest.pureCommitCallback = function(response) {	
	//myTrace("commitCallback with value:" + response.value + " error:" + response.error);
	if (response.value == "true") {
		scormNS.justTest.addToLog("commit successful");
	} else {
		scormNS.justTest.addToLog("SCORM commit failed");
	}
}
scormNS.justTest.exitCallback = function(response) {	
	//myTrace("exitCallback with value:" + response.value + " error:" + response.error);
	if (response.value == "true") {
		scormNS.justTest.addToLog("SCORM termination successful");
	} else {
		scormNS.justTest.addToLog("SCORM termination failed");
	}
	// callback into the normal exit routine
	_global.ORCHID.root.gotoAndStop("exit");
}

// ***********
// Original code for events
// ***********
// There is a lot of sequential processing taking place here, some
// of it doesn't need to be, but due to the asynchronous calls it is easier
// that way. The main rules follow:
// INITIALISE
//	The LMS call will have been made by the calling html page, so all
//	you have to do here is wait for the returnCode. But you also wait for
//	the LMS version (supplied by the APIWrapper) and then ask for the student
// 	name and the launch data.
//
// STARTING POINT
//	Read the LMS bookmark. If it is valid you will use this rather than the launch data.
//  Other starting points come from parameters passed to the module (picked up
//  by the javascript) or hard-coded into a special starting page.
//
// MARKING
//	Each exercise creates an objective when it is marked
//	No. No longer. Now use suspend_data to gather each score in a string.
//
// EXITING
//	When APO decides it wants to exit it does the following:
//	Set the scores and lesson status
//	Run an LMS Commit
//	Run an LMW Exit

//
// These functions are internal to the module
// v6.4.3 replaced these functions
/*
scormNS.initialise = function () {
	// v6.3.3 Since you are talking to the LMS through SCORM, get the 
	// initial variables you need now. These include 
	// course
	// starting point (unit, exercise)
	// user details
	//_parent.controlNS.remoteOnData(scormNS.moduleName);
	//myTrace("scorm.initialise");
	// v6.3.5 You could use a progress bar here since a little time might
	// be taken waiting for these values (especially if there is an error).
	// You would then clear it in finishInit.
	// Note: the SCORMStart.html page will actually call LMSInitialize so all
	// this call is doing is preparing to receive the return value. The initial
	// variable will just be ignored. ditto for jsVersion and start below.
	// v6.3.6 Now control calls javascript:LMSInitialize to stop the html risking
	// sending the variable to a stub if you use onLoad.
	scormNS.LMSGetValue("xxInit", "SCORMInitVar", scormNS.initCallback, true);
	// v6.3.6 Move the next calls into initCallBack as if that fails you shouldn't go on.
	// v6.4.2 prepare a flag used to hold back the rest of the program until we are done here.
	scormNS.stillLoading = true;
};
scormNS.initCallback = function(response) {
	//myTrace("initCallback with value:" + response.value + " error:" + response.error);
	if (response.value == "true") {
		//myTrace("SCORMInitVar successfully read");
		// v6.3.6 Let the starting page tell you which LMS it is running under, if it wants to
		scormNS.LMSGetValue("xxLMS", "SCORMthisLMS", scormNS.LMSCallback, true);
	} else {
		myTrace("SCORM initialisation failed");
		// stop the program running or run on without using SCORM?
		// probably the former.
		// v6.3.6 Switch SCORM off so that the exit process doesn't try to connect to the API
		_global.ORCHID.commandLine.scorm = false;
		// v6.3.6 Don't say the you have initialised if failure
		//_root.controlNS.remoteOnData(scormNS.moduleName);
		_global.ORCHID.root.controlNS.sendError({literal:"notInSCORM"});
	}
}
// v6.3.6 So that a deficient LMS can let you know who it is
// You would normally expect not to receive anything, and if we do not get anything
// immediately we will not wait.
scormNS.LMSCallback = function(response) {
	//myTrace("LMSCallback with value:" + response.value + " error:" + response.error);
	if (response.error == undefined) {
		switch (response.value) {
			case "CLiKS":
			case "DOKEOS":
			case "Blackboard":
			case "WebCT":
			case "RELOAD":
			case "Lotus":
			case "Ganesha":
			case "EOICampus":
			case "Moodle":
				scormNS.LMS = response.value;
				break;
			default:
				scormNS.LMS = "generic";
		}
	} else {
		myTrace("no LMS name");
		scormNS.LMS = "generic";
	}
	myTrace("LMS reports its name as " + scormNS.LMS);
	// v6.4.3 Move these calls until you know the LMS name, just in case you need
	// to do anything LMS specific.
	scormNS.LMSGetValue("xxVersion", "SCORMjsVersion", scormNS.jsVersionCallback, true);
}
// v6.3.6 Really you should wait for LMS name before going on. However, since it will certainly
// be set for any case where it is necessary, a wait would just be silly. So go on anyway.
scormNS.jsVersionCallback = function(response) {
	//myTrace("versionCallback with value:" + response.value + " error:" + response.error);
	if (response.error == undefined) {
		myTrace("running from " + scormNS.LMS + " js:SCORM v" + response.value);
		scormNS.version = response.value;
		// this value will let you set the variable names you need for talking to
		// different versions of SCORM (1.2 and 1.3)
	} else {
		// we will make an assumption about the version then (in getCMIName)
		myTrace("No LMS version from JS, " + response.error);
	}
	scormNS.LMSGetValue("xxStart", "SCORMStart", scormNS.startCallback, true);
}
scormNS.startCallback = function(response) {
	//myTrace("nameCallback with value:" + response.value + " error:" + response.error);
	if (response.error==undefined) {
		myTrace("LMS start parameter=" + response.value);
		scormNS.launchStart = response.value;
	} else {
		//myTrace("no LMS start, " + response.error);
		scormNS.launchStart = undefined;
	}
	// next ask for the student's name
	scormNS.LMSGetValue(scormNS.getCMIName("studentName"), "SCORMName", scormNS.nameCallback);
}
scormNS.nameCallback = function(response) {
	//myTrace("nameCallback with value:" + response.value + " error:" + response.error);
	if (response.error==undefined) {
		_global.ORCHID.commandLine.username = response.value;
	} else {
		// v6.3.6 If no name sent (should be impossible), then better not to go on
		// with getting SCORM information as we will have to login anyway. Or we
		// could assume the user is the anonymous one (set empty name).
		_global.ORCHID.commandLine.username = "";
		myTrace(scormNS.getCMIName("studentName") + " error =" + response.error);
	}
	// v6.3.6 LMS specific - CLiKS throws an error if you ask for some variables
	// v6.3.6 No longer - so remove this particular LMS
	if (scormNS.LMS.indexOf("[none]")>=0) {
		var fakeResponse = {error:"401"}; // is this the right error number?
		scormNS.languageCallback(fakeResponse);
		//scormNS.cmiVersionCallback(fakeResponse);
	} else {
		// also ask for other information about the student
		// Oh, this is set by the sco, so presumably I need to display the language selector and
		// then remember it if chosen by the student.
		scormNS.LMSGetValue(scormNS.getCMIName("interfaceLanguage"), "SCORMLanguage", scormNS.languageCallback);
	}
}
scormNS.languageCallback = function(response) {
	//myTrace("nameCallback with value:" + response.value + " error:" + response.error);
	if (response.error==undefined) {
		// v6.3.6 Need a function to query loaded literals to see if we can use
		// the requested language...
		if (response.value == "EN" || 
			response.value == "ES" || 
			response.value == "FR" || 
			response.value == "TH" || 
			response.value == "SV" || 
			response.value == "ZHO") {
			_global.ORCHID.commandLine.language = response.value;
			myTrace("set language to " + response.value);
		} else if (response.value == "English") {
			_global.ORCHID.commandLine.language = "EN";
			myTrace("set language to EN");
		} else if (response.value == "Thai") {
			_global.ORCHID.commandLine.language = "TH";
			myTrace("set language to TH");
		} else {
			_global.ORCHID.commandLine.language = "EN";
			myTrace("LMS language not recognised (" + response.value + ")");
		}
	} else {
		myTrace(scormNS.getCMIName("interfaceLanguage") + " error=" + response.error);
	}
	// finally, pick up the (possibly) passed course/unit ids (just in case launch_data is not implemented)
	// ?start=1-u9; course=1, unit=9
	//scormNS.LMSGetValue("xxUnit", "SCORMUnit", scormNS.unitCallback, true);
	//v6.3.6 Also ask for the datamodel version (though I don't use it yet)
	scormNS.LMSGetValue(scormNS.getCMIName("version"), "SCORMVersion", scormNS.cmiVersionCallback);
}
scormNS.cmiVersionCallback = function(response) {
	//myTrace("cmiVersionCallback with value:" + response.value + " error:" + response.error);
	if (response.error == undefined) {
		myTrace(scormNS.getCMIName("version") + response.value);
		scormNS.dataversion = response.value;
	} else {
		myTrace(scormNS.getCMIName("version") + " error=" + response.error);
		scormNS.dataversion = undefined;
	}
	// v6.4.2 If an LMS doesn't want to give you some of these things, waiting for the
	// timeout could cause you to be ready to start without knowing everything.
	// So, ask for more things at once.
	// ask for the launch data (hopefully set in the manifest)
	scormNS.LMSGetValue(scormNS.getCMIName("launchData"), "SCORMLaunchData", scormNS.launchCallback);
}

scormNS.launchCallback = function(response) {
	//myTrace("launchCallback with value:" + response.value + " error:" + response.error);
	// expecting "course=1,unit=u6,exercise=e101" (spaces are bad, bad, bad)
	// Too many LMS don't do error handling, so we can't rely on that to tell us that
	// launch_data is not supported. Thus assume the launch_data ALWAYS should have a value
	// and if it doesn't you need to try other ways of seeing where to start.
	if (response.error==undefined && response.value!="") {
		// debug with preset launch_data - Blackboard does not seem to pass this through
		// likewise, Dokeos does not support this variable. So why don't I get a 
		// no such variable error? (Blackboard does now support this)
		//response.value = "course=1,unit=u1";
		// break up the launch data into value pairs
		var launchData = new Object();
		var sections = response.value.split(",");
		for (var i in sections) {
			var valuePair = sections[i].split("=");
			launchData[valuePair[0]] = valuePair[1];
			//myTrace("launchData." + valuePair[0] + "=" + valuePair[1]);
		}
		_global.ORCHID.commandLine.course = launchData.course;
		if (launchData.unit != undefined) {
			_global.ORCHID.commandLine.startingPoint = "unit:" + launchData.unit;
		} else if (launchData.exercise != undefined) {
			_global.ORCHID.commandLine.startingPoint = "ex:" + launchData.exercise;
		} else {
			_global.ORCHID.commandLine.startingPoint = "menu";
		}
	} else {
		myTrace(scormNS.getCMIName("launchData") + " error =" + response.error);
		// v6.3.4 If this element is not implemented, try reading parameters
		// passed to the start module (which you asked for earlier - scormStart)
		// start=1-u1
		//myTrace("so try using start=" + scormNS.launchStart);
		if (scormNS.launchStart != "" && scormNS.launchStart != undefined) {
			var launchData = scormNS.launchStart.split("-");
			//myTrace("giving course=" + launchData[0]);
			_global.ORCHID.commandLine.course = launchData[0];
			//myTrace("use course=" + _global.ORCHID.commandLine.course);
			//v6.4.2 Units don't have u at the front now, just regular ID
			// but you can assume that SCORM is only going to supply a unit ID
			// (if it does do an exercise, assume it will tag on 'ex:')
			//if (launchData[1].indexOf("u") >= 0) {
			//	_global.ORCHID.commandLine.startingPoint = "unit:" + launchData[1];
			//} else if (launchData[1].indexOf("e") >= 0) {
			//	_global.ORCHID.commandLine.startingPoint = "ex:" + launchData[1];
			//} else {
			//	// so assume default is just the main menu
			//	_global.ORCHID.commandLine.startingPoint = "menu";
			//}
			if (launchData[1].indexOf("ex:") == 0) {
				_global.ORCHID.commandLine.startingPoint = launchData[1];
			} else {
				_global.ORCHID.commandLine.startingPoint = "unit:" + launchData[1];
			}
		} else {
			_global.ORCHID.commandLine.course = undefined;
			// so assume default is just the main menu
			_global.ORCHID.commandLine.startingPoint = "menu";
		}
		//myTrace("after all that, starting point=" + _global.ORCHID.commandLine.startingPoint);
	}
	myTrace("LMS start course=" + _global.ORCHID.commandLine.course,0);
	myTrace("LMS start point=" + _global.ORCHID.commandLine.startingPoint,0);
	// and ask for the suspend data (hopefully set in the LMS)
	scormNS.LMSGetValue(scormNS.getCMIName("suspendData"), "SCORMSuspendData", scormNS.suspendDataCallback);
}
scormNS.suspendDataCallback = function(response) {
	//myTrace("nameCallback with value:" + response.value + " error:" + response.error);
	if (response.error==undefined) {
		scormNS.suspendData = response.value;
		myTrace("suspend data=" + response.value);
	} else {
		myTrace(scormNS.getCMIName("suspendData") + " error=" + response.error);
	}
	// That is all you want at the moment
	scormNS.finishInit();
}
scormNS.finishInit = function() {
	// v6.4.2 I want to acknowledge that this module is running right at the start
	// not here. I need another way to know when it is OK to move on.
	//_global.ORCHID.root.controlNS.remoteOnData(scormNS.moduleName);
	// set a flag so that anyone else knows it is safe to go on
	scormNS.stillLoading = false;
	myTrace("set stillLoading to " + _global.ORCHID.root.scormHolder.scormNS.stillLoading);
}
*/
// v6.3.5 Moved to control so that other functions can use it as well
// controlNS.startingDirect
/*
scormNS.startingFromManifest = function() {
	myTrace("startingFromManifest " + _global.ORCHID.commandLine.startingPoint);
	// first ask LMS for the starting point (expecting "unit:u1")
	var startInfo = _global.ORCHID.commandLine.startingPoint.split(":");
	var startingType = startInfo[0];
	var startingID = startInfo[1];
	
	// if scorm doesn't want to start at a particular place
	if (startingID == undefined || startingType == "menu") {
		// so we are just going to let APO display the menu in the normal way
		//myTrace("LMS says menu please");
		_global.ORCHID.viewObj.displayScreen("MenuScreen");
		
	// otherwise, what does scorm want us to do?
	} else {
		// figure out if we need to work out the first exercise in the unit
		if (startingType == "unit") {
			//myTrace("LMS says unit=" + startingID);
			var itemList = _global.ORCHID.course.scaffold.getItemsByID(startingID);
			var thisScaffoldItem = itemList[0];
		// if it is an exercise, just use that
		} else if (startingType == "ex") {
			//myTrace("LMS says exercise=" + startingID);
			var thisScaffoldItem = _global.ORCHID.course.scaffold.getObjectByID(startingID);
		}
		// once you have the exercise ID, send it to the normal exercise creation point
		//myTrace("so that is exercise " + thisScaffoldItem.id);
		// v6.3.4 Any starting point that doesn't match a proper scaffold id
		// will come back as null. So in that case start from the menu.
		if (thisScaffoldItem == null) {
			myTrace("not a valid starting point");
			_global.ORCHID.viewObj.displayScreen("MenuScreen");
		} else {
			_root.controlNS.createExercise(thisScaffoldItem);		
		}
	}	
}
*/
