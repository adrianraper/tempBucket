/*******************************************************************************
**
** FileName: APIWrapper.js
**
*******************************************************************************/

/*******************************************************************************
**
** Concurrent Technologies Corporation (CTC) grants you ("Licensee") a non-
** exclusive, royalty free, license to use, modify and redistribute this
** software in source and binary code form, provided that i) this copyright
** notice and license appear on all copies of the software; and ii) Licensee does
** not utilize the software in a manner which is disparaging to CTC.
**
** This software is provided "AS IS," without a warranty of any kind.  ALL
** EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES, INCLUDING ANY
** IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR NON-
** INFRINGEMENT, ARE HEREBY EXCLUDED.  CTC AND ITS LICENSORS SHALL NOT BE LIABLE
** FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING OR
** DISTRIBUTING THE SOFTWARE OR ITS DERIVATIVES.  IN NO EVENT WILL CTC  OR ITS
** LICENSORS BE LIABLE FOR ANY LOST REVENUE, PROFIT OR DATA, OR FOR DIRECT,
** INDIRECT, SPECIAL, CONSEQUENTIAL, INCIDENTAL OR PUNITIVE DAMAGES, HOWEVER
** CAUSED AND REGARDLESS OF THE THEORY OF LIABILITY, ARISING OUT OF THE USE OF
** OR INABILITY TO USE SOFTWARE, EVEN IF CTC  HAS BEEN ADVISED OF THE POSSIBILITY
** OF SUCH DAMAGES.
**
*******************************************************************************/

/*******************************************************************************
** Edited by Clarity for Author Plus Online use
**
** Usage:  The return value is always a string
**  		If an error is detected, the return value will be "false" and a separate 
**		SetVariable call with the error code is additionally made
**
*******************************************************************************/
var _Debug = true;  // set this to false to turn debugging off
var _Info = true;  // set this to false to turn information messages off
var _version="1.2"; // use this to have the same javascript for SCORM 1.2 or 1.3 LMS

// Define exception/error codes
var _NoError = 0;
var _GeneralException = 101;
var _GeneralInitializationFailure = 102;
var _AlreadyInitialized = 103;
var _ContentInstanceTerminated = 104;
var _GeneralTerminationFailure = 111;
var _TerminationBeforeInitialization = 112;
var _TerminationAfterTermination = 113;
var _ReceivedDataBeforeInitialization = 122;
var _ReceivedDataAfterTermination = 123;
var _StoreDataBeforeInitialization = 132;
var _StoreDataAfterTermination = 133;
var _CommitBeforeInitialization = 142;
var _CommitAfterTermination = 143;
var _GeneralArgumentError = 201;
var _GeneralGetFailure = 301;
var _GeneralSetFailure = 351;
var _GeneralCommitFailure = 391;
var _UndefinedDataModelElement = 401;
var _UnimplementedDataModelElement = 402;
var _DataModelElementValueNotInitialized = 403;
var _DataModelElementIsReadOnly = 404;
var _DataModelElementIsWriteOnly = 405;
var _DataModelElementTypeMismatch = 406;
var _DataModelElementValueOutOfRange = 407;

// local variable definitions
var apiHandle = null;
var API = null;
//var findAPITries = 0;

/*******************************************************************************
**
** Function: doInitialize()
** Inputs:  None
** Return:  true if the initialization was successful, or
**  		false if the initialization failed.
**
** Description:
** Initialize communication with LMS by calling the Initialize
** function which will be implemented by the LMS.
**
*******************************************************************************/
function doInitialize() {
	if (_Debug == true) alert("in doInitialize");
	var api = getAPIHandle();
	if (api == null) {
		if (_Debug == true) alert("Initialize was not successful.");
		return "false";
	} else {
		if (_version=="1.3") {
			if (_Debug == true) alert ("got api for v1.3");
			return api.Initialize("").toString();
		} else {
			if (_Debug == true) alert ("got api for v1.2");
			return api.LMSInitialize("").toString();
		}
	}
}

/*******************************************************************************
**
** Function doTerminate()
** Inputs:  None
** Return:   true if successful
**           false if failed.
**
** Description:
** Close communication with LMS by calling the Terminate
** function which will be implemented by the LMS
**
*******************************************************************************/
function doTerminate() {
	var api = getAPIHandle();
	if (api == null) {
		if (_Debug == true) alert("Terminate was not successful.");
		return "false";
	} else {
		if (_version=="1.3") {
			return api.Terminate("").toString();
		} else {
			return api.LMSFinish("").toString();
		}
	}
}

/*******************************************************************************
**
** Function doGetValue(name)
** Inputs:  name - string representing the cmi data model defined category or
**             element
** Return:  The value presently assigned by the LMS to the cmi data model
**       element defined by the element or category identified by the name
**       input value.
**
** Description:
** Wraps the call to the GetValue method
**
*******************************************************************************/
function doGetValue(name) {
	var api = getAPIHandle();
	if (api == null) {
		if (_Debug == true) alert("GetValue was not successful.");
		return "";
	} else {
		if (_version=="1.3") {
			return api.GetValue(name).toString();
		} else {
			return api.LMSGetValue(name).toString();
		}
	}
}

/*******************************************************************************
**
** Function doSetValue(name, value)
** Inputs:  name -string representing the data model defined category or element
**          value -the value that the named element or category will be assigned
** Return:   true if successful
**           false if failed.
**
** Description:
** Wraps the call to the SetValue function
**
*******************************************************************************/
function doSetValue(name, value) {
	var api = getAPIHandle();
	if (api == null) {
		if (_Debug == true) alert("SetValue was not successful.");
		return "false";
	} else {
		if (_version=="1.3") {
			return api.SetValue(name, value).toString();
		} else {
			return api.LMSSetValue(name, value).toString();
		}
	}
}

/*******************************************************************************
**
** Function doCommit()
** Inputs:  None
** Return:  None
**
** Description:
** Call the Commit function 
**
*******************************************************************************/
function doCommit() {
	var api = getAPIHandle();
	if (api == null)  {
		if (_Debug == true) alert("Commit was not successful.");
		return "false";
	}  else   {
		if (_version=="1.3") {
		      return api.Commit("").toString();
		} else {
		      return api.LMSCommit("").toString();
		}
	}	
}

/*******************************************************************************
**
** Function doErrorHandler()
** Inputs:  None
** Return:  The current value of the LMS Error Code
**
** Description:
** Determines if an error was encountered by the previous API call
** and if so, displays a message to the user.  If the error code
** has associated text it is also displayed.
**
*******************************************************************************/
function doErrorHandler() {
	var api = getAPIHandle();
	if (api == null) {
		if (_Debug == true) alert("Cannot get LMS api.");
		return null;
	}

   // check for errors caused by or from the LMS
   // although GetLastError will return a string, javascript will compare OK to a number
	if (_version=="1.3") {
		var errCode = api.GetLastError();
	} else {
		var errCode = api.LMSGetLastError();
	}
	if (errCode != _NoError)   {
		if (_Debug == true)   {
			// an error was encountered so display the error description
			if (_version=="1.3") {
				var errDescription = api.GetErrorString(errCode);
				errDescription += "\n";
				errDescription += api.GetDiagnostic(null);
				// by passing null to GetDiagnostic, we get any available diagnostics
				// on the previous error. This is LMS specifc, 'null' works with the ADL Sample RTE.
			} else {
				var errDescription = api.LMSGetErrorString(errCode);
				errDescription += "\n";
				errDescription += api.LMSGetDiagnostic(null);
			}
		       alert(errDescription);
		}
	}
	//alert("send back error code=" + errCode)
	return errCode;
}

/******************************************************************************
**
** Function getAPIHandle()
** Inputs:  None
** Return:  value contained by APIHandle
**
** Description:
** Returns the handle to API object if it was previously set,
** otherwise it returns null
**
*******************************************************************************/
function getAPIHandle()
{
   if (apiHandle == null)
   {
      apiHandle = getAPI();
   }

   return apiHandle;
}

/*******************************************************************************
**
** Function findAPI(win)
** Inputs:  win - a Window Object
** Return:  If an API object is found, it's returned, otherwise null is returned
**
** Description:
** This function looks for an object named API in parent and opener windows
**
*******************************************************************************/
function findAPI(win) {
	// Added thanks to Tim from www.scorm.com
	var findAPITries=0;
	if (_version=="1.3") {
		while ((win.API_1484_11 == null) && (win.parent != null) && (win.parent != win)) {
			findAPITries++;
			if (findAPITries > 500) {
				if (_Debug == true) alert("Error finding API -- too deeply nested.");
				return null;
			}
			win = win.parent;
		}
		return win.API_1484_11;
	} else {
		while ((win.API == null) && (win.parent != null) && (win.parent != win)) {
			findAPITries++;
			if (findAPITries > 500) {
				if (_Debug == true) alert("Error finding API -- too deeply nested.");
				return null;
			}
			win = win.parent;
		}
		return win.API;
	}
}

/*******************************************************************************
**
** Function getAPI()
** Inputs:  none
** Return:  If an API object is found, it's returned, otherwise null is returned
**
** Description:
** This function looks for an object named API, first in the current window's 
** frame hierarchy and then, if necessary, in the current window's opener window
** hierarchy (if there is an opener window).
**
*******************************************************************************/
function getAPI()
{
	// Code changed following example from Tim at www.scorm.com
	//Search all the parents of the current window if there are any
	var theAPI = null;
	var searchedParent = false;
	var searchedOpener = false;
	if ((window.parent != null) && (window.parent != window))
	{
		theAPI = findAPI(window);
		searchedParent = true;
	}
	// If we didn't find the API in this window's chain of parents,
	// then search all the parents of the opener window if there is one
	if ((theAPI == null) && (window.top.opener != null) && (typeof(window.top.opener) != "undefined"))
	{
		theAPI = findAPI(window.top.opener);
		searchedOpener = true;
	}
	//alert("theAPI=" + theAPI);
	if (theAPI == null)
	{
		if (_Debug == true) alert("Unable to find an API adapter from parent(" + searchedParent + ") or opener(" + searchedOpener + ").");
	}
	return theAPI;
}
