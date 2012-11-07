/*
Proxy - PureMVC
*/
package com.clarityenglish.common.model {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.vo.config.BentoError;
	
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
		
		//issue:#20
		//public static var languageCode:String = "EN";
		public static var languageCode:String;
		
		private var copy:XML;
		private var copyEN:XML;
		
		public function CopyProxy(data:Object = null) {
			super(NAME, data);
		}
		
		public function getCopy():void {
			new RemoteDelegate("getCopy", [], this).execute();
		}
		
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
			
			//issue:#20 track wheter the language code be set successfully 
			trace("the language code is in CopyProxy is "+ languageCode);
			var result:XMLList = copy..language.(@code == languageCode)..lit.(@name == id);
			if (result.length() == 0) {
				trace("Unable to find literal for id '" + id + "' - this needs to be added to literals.xml");
				//issue:#11 load ielts.xml twice 
				copy = this.copyEN;
				
				// in which case try in English
				if (languageCode != "EN") {
					result = copy..language.(@code == "EN")..lit.(@name == id);
					if (result.length() == 0) {
						trace("Not in English either");
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
			trace("str is "+str);
			return str;
		}
		
		public function getCodeForId(id:String):uint {
			if (!this.copy)
				throw new Error("Copy literals have not been loaded yet");
			
			var result:XMLList = copy..language.(@code == languageCode)..lit.(@name == id).@code;
			if (result.length() == 0)
				return 1;
			
			return new Number(result[0]);
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
					//issue:#11 if the language code is not EN, the ielts.xml will be load twice. 
					//We store the default en literals in copyEN for backup to the other language if the literal is missing
					if(!copy) {
						copy = new XML(data);
					} else {
						copyEN = copy;
						copy = new XML(data);
					}
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
