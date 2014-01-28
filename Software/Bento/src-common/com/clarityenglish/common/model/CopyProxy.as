﻿/*
Proxy - PureMVC
*/
package com.clarityenglish.common.model {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.clarityenglish.common.vo.config.Config;
	
	import mx.rpc.Fault;
	import mx.utils.ObjectUtil;
	
	import org.davekeen.delegates.IDelegateResponder;
	import org.davekeen.delegates.RemoteDelegate;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	/**
	 * A proxy
	 */
	public class CopyProxy extends Proxy implements IProxy, CopyProvider, IDelegateResponder {
		
		public static const NAME:String = "CopyProxy";
		
		// gh#20
		// defaultLanguageCode doesn't decide the initial languageCode when getCopy be code, instead it is inside CopyOps. 
		public static var defaultLanguageCode:String = "EN";
		public static var languageCode:String;
		
		private var copy:XML;
		//private var defaultCopy:XML;
		
		public function CopyProxy(data:Object = null) {
			super(NAME, data);
		}
		
		public function getCopy():void {
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var config:Config = configProxy.getConfig();
			var param:Array = [ defaultLanguageCode, config.productCode, config.loginOption, config.dbHost ];
			new RemoteDelegate("getCopy", param, this).execute();
		}
		
		/*#problem with login Screen:
		public function setLanguageCode(languageString:String):void {
			trace("enter the setLanguageCode");
			if (languageString != defaultLanguageCode){
				sendNotification(CommonNotifications.COPY_LOAD, languageString);
			}
			this.languageCode = languageString;
		}*/
		
		/**
		 * Return the copy for the given id.  If the id is not found the id itself is returned and a message sent to the output window.
		 * This method takes an optional object which, if given, performs substitutions of attributes to {attributeName} in the copy.  For
		 * example, if the copy is "My name is {name}" and the replaceObj is { name: "Dave" } this will subsitute {name} for "Dave" before
		 * returning the result.
		 *
		 * @param	id
		 * @param	replaceObj
		 * @return
		 */
		public function getCopyForId(id:String, replaceObj:Object = null):String {
			if (!this.copy)
				throw new Error("Copy literals have not been loaded yet");
			
			//gh#20 track whether the language code be set successfully 
			//trace("the language code is in CopyProxy is "+ languageCode);
			var result:XMLList = copy..language.(@code == languageCode)..lit.(@name == id);
			if (result.length() == 0) {
				//trace("Unable to find literal for id '" + id + "' - this needs to be added to literals.xml");
				
				// in which case try in English
				if (languageCode != defaultLanguageCode) {
					result = copy..language.(@code == defaultLanguageCode)..lit.(@name == id);
					if (result.length() == 0) {
						return id;
					}
				} else {
					return id;
				}
			}
			var str:String = result.toString();
			
			// Do the substitution if required
			if (replaceObj) {
				for (var searchString:String in replaceObj) {
					var regExp:RegExp = new RegExp("\{" + searchString + "\}", "g");
					str = str.replace(regExp, replaceObj[searchString]);
				}
			}
			return str;
		}
		
		public function getCodeForId(id:String):uint {
			if (!this.copy)
				throw new Error("Copy literals have not been loaded yet");
			
			var result:XMLList = copy..language.(@code == languageCode)..lit.(@name == id).@code;
			
			// gh#127 You need to fall back to default language code if the code is not found
			if (result.length() == 0) {
				if (languageCode != defaultLanguageCode) {
					result = copy..language.(@code == defaultLanguageCode)..lit.(@name == id).@code;
					if (result.length() == 0)
						return 0;
					
				} else {
					// Not really sure what makes sense to return if you can't find the code
					return 0;
					
				}
			}
			
			return new Number(result[0]);
		}
		// gh#11
		public function getLanguageCode():String {
			return languageCode;
		}
		public function getDefaultLanguageCode():String {
			return defaultLanguageCode;
		}
		
		public function getBentoErrorForId(id:String, replaceObj:Object = null, isFatal:Boolean = true):BentoError {
			if (!this.copy)
				throw new Error("Copy literals have not been loaded yet");

			var copy:String = getCopyForId(id, replaceObj);
			var code:uint = getCodeForId(id);
		
			var bentoError:BentoError = new BentoError();
			bentoError.errorContext = copy;
			bentoError.errorNumber = code;
			bentoError.isFatal = isFatal;
			return bentoError;
		}
		
		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		
		public function onDelegateResult(operation:String, data:Object):void {
			switch (operation) {
				case "getCopy":
					//issue:#11 refined code, if the language code is not defaultLanugageCode, the ielts.xml will be load twice.  
					//We store the default languageCode literals in defaultCopy for backup to the other language if the literal is missing
					/*#problem with login Screen:
					copy = new XML(data);					
					if (copy..language.@code == defaultLanguageCode) { 
						defaultCopy = copy;
						
					sendNotification(CommonNotifications.COPY_LOADED);
					} else {
						trace("copy load at second time");
						
					}*/
					if (!copy) {
						//trace("the first copy is "+XML(data));
					}
					
					copy = new XML(data);
					sendNotification(CommonNotifications.COPY_LOADED);
					break;
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Result from unknown operation: " + operation);
			}
		}
		
		public function onDelegateFault(operation:String, fault:Fault):void {
			sendNotification(CommonNotifications.TRACE_ERROR, operation + ": " + fault.faultString);
		}
	
	}
}
