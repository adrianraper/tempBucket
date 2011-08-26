// v6.4.3 Updated for JavaScriptFlashGateway
// v6.5 Updated for swfobject and ExternalInterface

// variables used throughout the script
function thisMovie() {
	// v6.5.5.6 Changed - no don't do this otherwise older SCORMStarts will break
	var movieName = "APOStart";
	//var movieName = "orchid";
	var isIE = navigator.appName.indexOf("Microsoft") != -1;
	return (isIE) ? window[movieName] : document[movieName];
}
//var mySCOObj;
// v6.3.6 Optional parameter for passing name of the LMS. You only need to use this if a particular
// LMS reacts badly when you are using get/set so that you cannot catch errors in the code.
var _LMS="CLiKS"; // CLiKS from NIIT
var _LMS="TestTrack";
var _LMS="Blackboard";
var _LMS="Moodle"; // default
//if (_Debug == true) alert("loading ExtIntSCORMScripts.js");
// v6.4.1.4 Since you will try to terminate if this page is unloaded, only do it once
var _alreadyTerminated;

// the variable _parameters MUST be defined before calling this script.
// It can either be hard-coded in an html file or it can be read from the windows.location

// The following function is used to pass URL parameters to the sco.
// It is known NOT to work with RELOAD as its use changes relative references to absolute ones.
var _parameters = window.location.search;
var URLparams=[];
function getURLParams(strSearch) {
	//alert("from LMS parameters=" + strSearch);
	var idx = strSearch.indexOf('?');
	if (idx != -1) {
		var pairs = strSearch.substring(idx+1, strSearch.length).split('&');
		for (var i=0; i<pairs.length; i++) {
			nameVal = pairs[i].split('=');
			URLparams[nameVal[0]] = nameVal[1];
		}
	}
}

// v6.4.3 new direct functions called from Flash via proxy
function LMSInitialize(returnFunction) {
	var rc=0;
	var errCode=0;
	var varArray = new Array();
	//if (_Debug == true) alert("a. LMSInitialize");
	// Note that you CAN run the call like this, but it is obliterated by the next flashProxy.call.
	//flashProxy.call("LMSTrace", "dss.js.call LMSInitialize");	
	//thisMovie().LMSTrace("dss.js.call LMSInitialize");

	//v6.4.3 Acknowledge that you are controlled by SCO right now
	_alreadyTerminated = false;
	rc = doInitialize();
	if (_Debug == true) alert("b. LMSInitialize.rc=" + rc);
	if (rc == "false"){
		errCode = "noAPI";
		//mySCOObj.SetVariable("SCORMInitVar", "error:"+errCode);
		varArray.push({variable:"SCORMInitVar", error:errCode})
	} else {
		// the LMS has successfully initialised with this SCO, so send back the version number written in the APIWrapper.js file
		// Note, there is an official cmi._version as well which the application will have to get separately if it wants
		// v6.3.6 Send the [optional] LMS name to allow specific processing
		//alert("setVariable on " + mySCOObj);
		//v6.4.3 Different method of setting variables
		//mySCOObj.SetVariable("SCORMInitVar", rc);
		varArray.push({variable:"SCORMInitVar", value:"true"})
		varArray.push({variable:"SCORMthisLMS", value:_LMS})
		varArray.push({variable:"SCORMjsVersion", value:_version})
		// has the SCO been started with parameters passed on URL line?
		// Note: You can get these better using swfobject I think...
		getURLParams(_parameters);
		if (URLparams["start"] != undefined){
			//alert("passed start=" + URLparams["start"]);
			varArray.push({variable:"SCORMStart", value:URLparams["start"]})
		} else {
			// pass a variable so that APO doesn't hang around waiting
			//alert("send start=undefined");
			varArray.push({variable:"SCORMStart", value:"undefined"})
		}
	}
	//flashProxy.call("LMSGetValueReturn", varArray);	
	//alert("ExternalInterface reply to " + returnFunction);
	//alert("return from js, array.length=" + varArray.length);
	// You can either call Flash, or just return the array since Flash doesn't mind waiting
	//thisMovie(movieName).returnFunction(varArray);
	return varArray;
}
// v6.4.3 new direct functions called from Flash via proxy
function LMSTerminate(returnFunction) {
	var rc=0;
	var errCode=0;
	var varArray = new Array();
	// v6.4.1.4 Stop this happening a second time for this sco
	if (_alreadyTerminated) {
		rc="true";
	} else {
		rc = doTerminate();
	}
	// v6.4.3 Use Flash Javascript Integration Kit to set variables
	if (rc == "false"){
		errCode = doErrorHandler();
		//mySCOObj.SetVariable("SCORMExitVar", "error:"+errCode);
		varArray.push({variable:"SCORMExitVar", error:errCode})
	} else {
		// v6.4.1.4 Allow for this to be stopped on a second attempt
		_alreadyTerminated = true;
		//mySCOObj.SetVariable("SCORMExitVar", rc);
		varArray.push({variable:"SCORMExitVar", value:rc})
	}
	//flashProxy.call(returnFunction, varArray);	
	return varArray;
}
// v6.4.3 new direct functions called from Flash via proxy
function LMSCommit(returnFunction) {
	var rc=0;
	var errCode=0;
	var varArray = new Array();
	//alert("call LMS with Commit");
	rc = doCommit();
	// v6.4.3 Use Flash Javascript Integration Kit to set variables
	if (rc == "false"){
		errCode = doErrorHandler();
		//mySCOObj.SetVariable("SCORMCommit", "error"+errCode);
		varArray.push({variable:"SCORMCommit", error:errCode})
	} else {
		//mySCOObj.SetVariable("SCORMCommit", rc);
		varArray.push({variable:"SCORMCommit", value:rc})
	}
	//flashProxy.call(returnFunction, varArray);	
	return varArray;
}

function LMSGetValue(args, returnFunction) {
	if (_Debug == true) alert("call LMSGetValue, return function " + returnFunction + " args=" + args.length);
	// args is an array of objects {name:cmi._version, variable:SCORMversion}
	var rc=0;
	var errCode=0;
	var varArray = new Array();
	// First of all, handle a bunch of requests that come in in one call
	for (var i in args) {
		//alert("call LMSGetValue, request " + args[i].name + " goes back to " + args[i].variable);
		rc = doGetValue(args[i].name);
		errCode = doErrorHandler();
		//alert("got back errCode=" + errCode);
		// v6.4.3 Use Flash Javascript Integration Kit to set variables
		if (errCode != _NoError) {
			//alert("setting getValue error for " + args[i].name);
			//mySCOObj.SetVariable(F_intData[1], "error:"+errCode);
			varArray.push({variable:args[i].variable, error:errCode})
		} else {
			// v6.5.1 Since ExternalInterface changes empty strings to "null", it is safer to be explicit with null
			if (rc == "") {
				rc=null;
				//alert("sending back empty string, so convert to null");
			}
			// As a Linux system treats UTF characters differently to Windows, escape them at this point
			// But you need to use encodeURI instead of escape to get good URLencoded strings
			//varArray.push({variable:args[i].variable, value:rc});
			//alert("call LMSGetValue, request " + args[i].name + " goes back as " + encodeURI(rc));
			varArray.push({variable:args[i].variable, value:encodeURI(rc)});
		}
	}
	//flashProxy.call("LMSGetValueReturn", varArray);	
	//flashProxy.call(returnFunction, varArray);	
	return varArray;
}
function LMSSetValue(args, returnFunction) {
	if (_Debug == true) alert("call LMSSetValue, return function " + returnFunction + " args=" + args.length);
	// args is an array of objects {name:cmi.core.session_time, value:"00:10;28", variable:SCORMsetValue}
	var rc=0;
	var errCode=0;
	var varArray = new Array();
	// First of all, handle a bunch of requests that come in in one call
	for (var i in args) {
		// v6.5.1 Using ExtInterface causes empty strings to get passed and lost (turned to "null" in this script)
		// but this is a valid data item to return for several items. Dangerous to test for the string "null", so use a real null instead.
		if (args[i].value == null) {
			args[i].value="";
			//alert("call LMSSetValue, set " + args[i].name + " to " + args[i].value + " isEmptyString=" + (args[i].value==""));
		}
		if (_Debug == true) alert("call LMSSetValue, set " + args[i].name + " to " + args[i].value);
		rc = doSetValue(args[i].name, args[i].value);
		// v6.4.3 Use Flash Javascript Integration Kit to set variables
		if (rc == "false"){
			errCode = doErrorHandler();
			//alert("setting getValue error for " + args[i].name);
			//mySCOObj.SetVariable(F_intData[1], "error:"+errCode);
			varArray.push({variable:args[i].variable, error:errCode})
		} else {
			varArray.push({variable:args[i].variable, value:rc});
		}
	}
	//flashProxy.call("LMSGetValueReturn", varArray);	
	//flashProxy.call(returnFunction, varArray);	
	return varArray;
}
//v6.4.3 Different method to leave when browser controlling the quit - direct calls
unloadPage = function(){
	if (_alreadyTerminated != true) {
		//alert("unloadPage - do termination");
		rc = doSetValue("cmi.core.exit", "suspend");
		rc = doCommit();
		rc = doTerminate();		
	} else {
		//alert("unloadPage - done termination already");
	}
}