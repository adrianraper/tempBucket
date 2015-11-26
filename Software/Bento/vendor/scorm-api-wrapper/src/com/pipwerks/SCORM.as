/*
pipwerks SCORM Wrapper for ActionScript 3
v1.1.20111123

Created by Philip Hutchison, January 2008
https://github.com/pipwerks/scorm-api-wrapper

Adapted by Adrian Raper, Clarity, May 2012

Copyright (c) Philip Hutchison
MIT-style license: http://pipwerks.mit-license.org/

FLAs published using this file must be published using AS3.
SWFs will only work in Flash Player 9 or higher.

This wrapper is designed to be SCORM version-neutral (it works
with SCORM 1.2 and SCORM 2004). It also requires the pipwerks
SCORM API JavaScript wrapper in the course's HTML file. The
wrapper can be downloaded from http://github.com/pipwerks/scorm-api-wrapper/

This class uses ExternalInterface. Testing in a local environment
will FAIL unless you set your Flash Player settings to allow local
SWFs to execute ExternalInterface commands.

Use at your own risk! This class is provided as-is with no implied warranties or guarantees.
*/

package com.pipwerks {
	
	import flash.external.*;
	
	public class SCORM {
		
		private var _version:String;
		private var _studentName:String;
		private var _studentID:String;
		private var _studentLanguage:String;
		private var _launchData:Object;
		private var _entry:String;
		private var _suspendData:String;
		private var _objectiveCount:uint;
		private var _bookmark:Object;
		private var _complete:Boolean;
		
		private var __connectionActive:Boolean = false,
			__debugActive:Boolean = true;
		
		public function SCORM() {
			
			var is_EI_available:Boolean = ExternalInterface.available,
				wrapperFound:Boolean = false,
				debugMsg:String = "Initializing SCORM class. Checking dependencies: ";
			
			if(is_EI_available){
				
				debugMsg += "ExternalInterface.available evaluates true. ";
				
				wrapperFound = Boolean(ExternalInterface.call("pipwerks.SCORM.isAvailable"));
				debugMsg += "SCORM.isAvailable() evaluates " +String(wrapperFound) +". ";
				
				if(wrapperFound){
					
					debugMsg += "SCORM class file ready to go!  :) ";
					
				} else {
					
					debugMsg += "The required JavaScript SCORM API wrapper cannot be found in the HTML document.  Course cannot load.";
					
				}
				
			} else {
				
				debugMsg += "ExternalInterface is NOT available (this may be due to an outdated version of Flash Player).  Course cannot load.";
				
			}
			
			__displayDebugInfo(debugMsg);
			
		}
		
		
		
		// --- public functions --------------------------------------------- //
		
		public function set debugMode(status:Boolean):void {
			this.__debugActive = status;
		}
		
		public function get debugMode():Boolean {
			return this.__debugActive;
		}
		
		public function connect():Boolean {
			__displayDebugInfo("pipwerks.SCORM.connect() called from class file");
			return __connect();
		}
		
		public function disconnect():Boolean {
			return __disconnect();
		}
		
		public function get(parameter:String):String {
			var str:String = __get(parameter);
			__displayDebugInfo("public function get returned: " +str);
			return str;
		}
		
		public function set(parameter:String, value:String):Boolean {
			return __set(parameter, value);
		}
		
		public function save():Boolean {
			return __save();
		}
		
		// Clarity
		/**
		 * This function turns nice names into the version dependent cmi name and passes them onto the LMS
		 */
		public function getParameter(parameterName:String, index:uint = 0):String {
			return get(__cmiName(parameterName, index));
		}
		public function setParameter(parameterName:String, value:String, index:uint = 0):Boolean {
			return set(__cmiName(parameterName, index), value);
		}
		
		// Getter and setters for all variables
		public function get version():String {
			return _version;	
		}
		public function set version(value:String):void {
			if (_version != value)
				_version = value;
		}
		public function get studentName():String {
			return _studentName;
		}
		public function set studentName(value:String):void {
			if (_studentName != value)
				_studentName = value;
		}
		public function get studentID():String {
			return _studentID;
		}
		public function set studentID(value:String):void {
			if (_studentID != value)
				_studentID = value;
		}
		public function get studentLanguage():String {
			return _studentLanguage;
		}
		public function set studentLanguage(value:String):void {
			if (_studentLanguage != value)
				_studentLanguage = value;
		}
		public function get launchData():Object {
			return _launchData;
		}
		public function set launchData(value:Object):void {
			if (_launchData != value)
				_launchData = value;
		}
		public function get entry():String {
			return _entry;
		}
		public function set entry(value:String):void {
			if (_entry != value)
				_entry = value;
		}
		public function get suspendData():String {
			return _suspendData;
		}
		public function set suspendData(value:String):void {
			if (_suspendData != value)
				_suspendData = value;
		}
		public function get objectiveCount():uint {
			return _objectiveCount;
		}
		public function set objectiveCount(value:uint):void {
			if (_objectiveCount != value)
				_objectiveCount = value;
		}
		// TODO: Not sure if this is the right way to set an object?
		public function get bookmark():Object {
			return _bookmark;
		}
		public function set bookmark(value:Object):void {
			if (_bookmark != value)
				_bookmark = value;
		}
		public function get complete():Boolean {
			return _complete;
		}
		public function set complete(value:Boolean):void {
			_complete = value;
		}
		
		// --- private functions --------------------------------------------- //
		
		private function __cmiName(name:String, index:uint = 0):String {
			switch (name) {
				case "studentName":
					trace("CMI names from version " + this.version);
					if (this.version == "2004") {
						return "cmi.learner_name";
					} else {
						return "cmi.core.student_name";
					}
					break;
				// v6.5.6 Added to see if useful for HCT
				case "studentID":
					if (this.version == "2004") {
						return "cmi.learner_id";
					} else {
						return "cmi.core.student_id";
					}
					break;
				case "interfaceLanguage":
					if (this.version == "2004") {
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
					if (this.version == "2004") {
						return "cmi.location";
					} else {
						return "cmi.core.lesson_location";
					}
					break;
				case "sessionTime":
					if (this.version == "2004") {
						return "cmi.session_time";
					} else {
						return "cmi.core.session_time";
					}
					break;
				case "lessonStatus":
					if (this.version == "2004") {
						return "cmi.completion_status";
					} else {
						return "cmi.core.lesson_status";
					}
					break;
				case "exit":
					if (this.version == "2004") {
						return "cmi.exit";
					} else {
						return "cmi.core.exit";
					}
					break;
				// v6.5.1 Added to help ensure that suspend data is fresh for a re-run of a SCO
				case "entry":
					if (this.version == "2004") {
						return "cmi.entry";
					} else {
						return "cmi.core.entry";
					}
					break;
				case "rawScore":
					if (this.version == "2004") {
						return "cmi.score.raw";
					} else {
						return "cmi.core.score.raw";
					}
					break;
				case "maxScore":
					if (this.version == "2004") {
						return "cmi.score.max";
					} else {
						return "cmi.core.score.max";
					}
					break;
				case "minScore":
					if (this.version == "2004") {
						return "cmi.score.min";
					} else {
						return "cmi.core.score.min";
					}
					break;
				case "objective.count":
					return "cmi.objectives._count";
					break;
				case "objective.id":
                    // gh#1405 According to the specs, both versions should use dot notation. But Moodle seems to understand _ NOT .
                    if (this.version == "2004") {
                        return "cmi.objectives." + String(index) + ".id";
                    } else {
                        return "cmi.objectives_" + String(index) + ".id";
                    }
					break;
				case "objective.score":
                    if (this.version == "2004") {
                        return "cmi.objectives." + String(index) + ".score.raw";
                    } else {
                        return "cmi.objectives_" + String(index) + ".score.raw";
                    }
					break;
                // gh#1405
				case "objective.status":
                    if (this.version == "2004") {
                        return "cmi.objectives." + String(index) + ".completion_status";
                    } else {
                        return "cmi.objectives_" + String(index) + ".status";
                    }
                    break;
					break;
				case "rubbish":
					return "cmi.rubbish";
					break;
				default:
					trace("badly called getCMIName with " + name);
					// This allows you to call this function even if you already made the full name
					return name;
			}
			return '';
		}
		
		private function __connect():Boolean {
			
			var result:Boolean = false;
			if(!__connectionActive){
				
				var eiCall:String = String(ExternalInterface.call("pipwerks.SCORM.init"));
				result = __stringToBoolean(eiCall);
				
				if (result){
					__connectionActive = true;
					
					// Clarity, get the scorm version here too
					eiCall = String(ExternalInterface.call("pipwerks.SCORM.lmsVersion"));
					if (eiCall)
						this.version = eiCall;
					
				} else {
					var errorCode:int = __getDebugCode();
					if(errorCode){
						var debugInfo:String = __getDebugInfo(errorCode);
						__displayDebugInfo("pipwerks.SCORM.init() failed. \n"
							+"Error code: " +errorCode +"\n"
							+"Error info: " +debugInfo);
					} else {
						__displayDebugInfo("pipwerks.SCORM.init failed: no response from server.");
					}
				}
			} else {
				__displayDebugInfo("pipwerks.SCORM.init aborted: connection already active.");
			}
			
			__displayDebugInfo("__connectionActive: " +__connectionActive);
			
			return result;
		}
		
		private function __disconnect():Boolean {
			
			var result:Boolean = false;
			if(__connectionActive){
				var eiCall:String = String(ExternalInterface.call("pipwerks.SCORM.quit"));
				result = __stringToBoolean(eiCall);
				if (result){
					__connectionActive = false;
				} else {
					var errorCode:int = __getDebugCode();
					var debugInfo:String = __getDebugInfo(errorCode);
					__displayDebugInfo("pipwerks.SCORM.quit() failed. \n"
						+"Error code: " +errorCode +"\n"
						+"Error info: " +debugInfo);
				}
			} else {
				__displayDebugInfo("pipwerks.SCORM.quit aborted: connection already inactive.");
			}
			return result;
		}
		
		
		private function __get(parameter:String):String {
			
			var returnedValue:String = "";
			
			if (__connectionActive){
				
				returnedValue = String(ExternalInterface.call("pipwerks.SCORM.get", parameter));
				var errorCode:int = __getDebugCode();
				
				//GetValue returns an empty string on errors
				//Double-check errorCode to make sure empty string
				//is really an error and not field value
				if (returnedValue == "" && errorCode != 0){
					var debugInfo:String = __getDebugInfo(errorCode);
					__displayDebugInfo("pipwerks.SCORM.get(" +parameter +") failed. \n"
						+"Error code: " +errorCode +"\n"
						+"Error info: " +debugInfo);
				}
			} else {
				__displayDebugInfo("pipwerks.SCORM.get(" +parameter +") failed: connection is inactive.");
			}
			return returnedValue;
		}
		
		
		private function __set(parameter:String, value:String):Boolean {
			
			var result:Boolean = false;
			if (__connectionActive){
				var eiCall:String = String(ExternalInterface.call("pipwerks.SCORM.set", parameter, value));
				result = __stringToBoolean(eiCall);
				if(!result){
					var errorCode:int = __getDebugCode();
					var debugInfo:String = __getDebugInfo(errorCode);
					__displayDebugInfo("pipwerks.SCORM.set(" +parameter +") failed. \n"
						+"Error code: " +errorCode +"\n"
						+"Error info: " +debugInfo);
				}
			} else {
				__displayDebugInfo("pipwerks.SCORM.set(" +parameter +") failed: connection is inactive.");
			}
			return result;
		}
		
		
		private function __save():Boolean {
			
			var result:Boolean = false;
			if(__connectionActive){
				var eiCall:String = String(ExternalInterface.call("pipwerks.SCORM.save"));
				result = __stringToBoolean(eiCall);
				if(!result){
					var errorCode:int = __getDebugCode();
					var debugInfo:String = __getDebugInfo(errorCode);
					__displayDebugInfo("pipwerks.SCORM.save() failed. \n"
						+"Error code: " +errorCode +"\n"
						+"Error info: " +debugInfo);
				}
			} else {
				__displayDebugInfo("pipwerks.SCORM.save() failed: API connection is inactive.");
			}
			return result;
		}
		
		
		// --- debug functions ----------------------------------------------- //
		
		private function __getDebugCode():int {
			var code:int = int(ExternalInterface.call("pipwerks.SCORM.debug.getCode"));
			return code;
		}
		
		private function __getDebugInfo(errorCode:int):String {
			var result:String = String(ExternalInterface.call("pipwerks.SCORM.debug.getInfo", errorCode));
			return result;
		}
		
		private function __getDiagnosticInfo(errorCode:int):String {
			var result:String = String(ExternalInterface.call("pipwerks.SCORM.debug.getDiagnosticInfo", errorCode));
			return result;
		}
		
		private function __displayDebugInfo(msg:String):void {
			if(__debugActive){
				trace(msg);
				ExternalInterface.call("pipwerks.UTILS.trace", msg);
			}
		}
		
		private function __stringToBoolean(value:*):Boolean {
			
			var t:String = typeof value;
			
			switch(t){
				
				case "string": return (/(true|1)/i).test(value);
				case "number": return !!value;
				case "boolean": return value;
				// Clarity, changed to return a Boolean
				//case "undefined": return null;
				case "undefined": return false;
				default: return false;
					
			}
			
		}
		
		
		
	} // end SCORM class
} // end package