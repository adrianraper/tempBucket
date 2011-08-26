/**
 * Functions for It's Your Job SCORM module
 * Author:	WZ
 * Date:	26th Nov 2010
 * Version:	1.0
 */
var _alreadyTerminated;
var _LMSversion = "1.2";
var params; // This is for SCORM page settings
//var _Debug = true; // This is debug option
var courseStr;
var ex_num = 5;

function loadPage(frameId){
	document.getElementById(frameId).src = pageInit();
}

function unloadPage(){
	if (_alreadyTerminated != true) {
		var data = "sid="+params.sid+"&prefix="+params.prefix+"&"+courseStr;
		var retStr = sendRequest("http://claritymain/Software/Common/SCORMQuery.php", data);
		var retArr = retStr.split("&");
		var progress = retArr[0].split("=")[1];
		progress = progress / ex_num;
		if(progress < 100){
			var lesson_status = "incomplete";
			var exit = "suspend";
		}else{
			var lesson_status = "completed";
			var exit = "";			
		}
		var score = retArr[1].split("=")[1];
		var spendTime = retArr[2].split("=")[1];
		if(_LMSversion == "1.2"){
			rc = doSetValue("cmi.core.score.raw", score);
			rc = doSetValue("cmi.core.session_time", spendTime);
			rc = doSetValue("cmi.core.lesson_status", lesson_status);
			rc = doSetValue("cmi.core.exit", exit);
		}else{
			rc = doSetValue("cmi.score.raw", score);
			rc = doSetValue("cmi.session_time", spendTime);
			rc = doSetValue("cmi.completion_status", lesson_status);
			rc = doSetValue("cmi.exit", exit);
		}
		
		rc = doCommit();
		rc = doTerminate();		
	} else {
		alert("unloadPage - done termination already");
	}
}

function pageInit(){
	var scoInitArr = LMSInitialize();
	_LMSversion = scoInitArr[1].value;
	if(_LMSversion == "1.2"){ // SCORMjsVersion
		var args = new Array(
					{name:"cmi.core.student_name", variable:"SCORMusername"},
					{name:"cmi.core.student_id", variable:"SCORMuserid"},
					{name:"cmi.student_preference.language", variable:"SCORMuserlanguage"},
					{name:"cmi._version", variable:"SCORMversion"},
					{name:"cmi.launch_data", variable:"SCORMlaunchdata"},
					{name:"cmi.core.entry", variable:"SCORMentry"},
					{name:"cmi.suspend_data", variable:"SCORMsuspenddata"},
					{name:"cmi.objectives._count", variable:"SCORMcount"}
					);
	}else if(_LMSversion == "1.3"){
		var args = new Array(
					{name:"cmi.learner_name", variable:"SCORMusername"},
					{name:"cmi.learner_id", variable:"SCORMuserid"},
					{name:"cmi.learner_perference.language", variable:"SCORMuserlanguage"},
					{name:"cmi._version", variable:"SCORMversion"},
					{name:"cmi.launch_data", variable:"SCORMlaunchdata"},
					{name:"cmi.core.entry", variable:"SCORMentry"},
					{name:"cmi.suspend_data", variable:"SCORMsuspenddata"},
					{name:"cmi.objectives._count", variable:"SCORMcount"}
					);		
	}else{
		var args = new Array(
					{name:"cmi.core.student_name", variable:"SCORMusername"},
					{name:"cmi.core.student_id", variable:"SCORMuserid"},
					{name:"cmi.student_preference.language", variable:"SCORMuserlanguage"},
					{name:"cmi._version", variable:"SCORMversion"},
					{name:"cmi.launch_data", variable:"SCORMlaunchdata"},
					{name:"cmi.core.entry", variable:"SCORMentry"},
					{name:"cmi.suspend_data", variable:"SCORMsuspenddata"},
					{name:"cmi.objectives._count", variable:"SCORMcount"}
					);
	}
	var scoValArr = LMSGetValue(args);
	params.username = scoValArr[0].value;
	params.sid = scoValArr[1].value;
	var courseInfo = new Array();
	for( var j in scoValArr){
		//alert(scoValArr[j].variable + " = " + scoValArr[j].value);
		if(scoValArr[j].variable == "SCORMlaunchdata"){
			var launchdata = scoValArr[j].value;
			var tempArr = launchdata.split(",");
			for(var k in tempArr){
				var vArr = tempArr[k].split("=");
				courseInfo.push({name:vArr[0], value:vArr[1]}); 
			}
		}
	}
	//for( var m in courseInfo){
	//	alert(courseInfo[m].name + " = " + courseInfo[m].value);
	//}
	var paramStr = "?";
	for( var i in params){
		paramStr += i + "=" + eval("params." + i) + "&";
	}
	//paramStr = paramStr.slice(0, paramStr.length - 1);
	courseStr = "course=" + courseInfo[0].value;
	courseStr += "&startingPoint=" + courseInfo[1].name + ":" + courseInfo[1].value;
	if(courseInfo[2] != null){
		courseStr += "&practice=" + courseInfo[2].value;
	}
	if(courseInfo[3] != null){
		ex_num = courseInfo[3].value;
	}
	var destURL = targetURL + paramStr + courseStr;
	return destURL;
}

function LMSInitialize() {
	var rc = 0;
	var errCode = 0;
	var varArray = new Array();
	_alreadyTerminated = false;
	
	rc = doInitialize();
	if (rc == "false"){
		errCode = "noAPI";
		varArray.push({variable:"SCORMInitVar", error:errCode});
	} else {
		varArray.push({variable:"SCORMInitVar", value:"true"});
		varArray.push({variable:"SCORMjsVersion", value:_version});
	}
	return varArray;
}

function LMSGetValue(args) {
	// args is an array of objects {name:cmi._version, variable:SCORMversion}
	var rc = 0;
	var errCode = 0;
	var varArray = new Array();
	// First of all, handle a bunch of requests that come in in one call
	for (var i in args) {
		rc = doGetValue(args[i].name);
		errCode = doErrorHandler();
		if (errCode != _NoError) {
			varArray.push({variable:args[i].variable, error:errCode});
		} else {
			// v6.5.1 Since ExternalInterface changes empty strings to "null", it is safer to be explicit with null
			if (rc == "") {
				rc = null;
			}
			// As a Linux system treats UTF characters differently to Windows, escape them at this point
			// But you need to use encodeURI instead of escape to get good URLencoded strings
			varArray.push({variable:args[i].variable, value:encodeURI(rc)});
		}
	}
	return varArray;
}

function LMSSetValue(obj) {
	var rc=0;
	var errCode=0;
	var retObj = {};
	// First of all, handle a bunch of requests that come in in one call
	//alert(obj);
	for (var i in obj) {
		// v6.5.1 Using ExtInterface causes empty strings to get passed and lost (turned to "null" in this script)
		// but this is a valid data item to return for several items. Dangerous to test for the string "null", so use a real null instead.
		//alert(i + "=" + eval("obj." + i));
		if (eval("obj." + i) == null) {
			obj.i = "";
		}

		rc = doSetValue(i, eval("obj." + i));
		if (rc == "false"){
			errCode = doErrorHandler();
			retObj.i = errCode;
		} else {
			retObj.i = rc;
		}
	}
	return retObj;
}

function sendRequest(url, data){
	var xmlhttp = null;
	if (window.XMLHttpRequest){
		xmlhttp = new XMLHttpRequest();
	}else if (window.ActiveXObject){
		xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
	}
	if(xmlhttp != null){
		xmlhttp.open("GET", url + "?" + data, false); // This must use synchronous mode
		try{
			//xmlhttp.setRequestHeader("Content-type","application/x-www-form-urlencoded");
			xmlhttp.send();
		}catch(e){
			alert("XMLHttp Request Error! Please contact the administrator.");
		}
		return xmlhttp.responseText;
	}else{
		alert("Your browser does not support XMLHTTP.");
	}
}