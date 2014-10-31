/*
Proxy - PureMVC
*/
package com.clarityenglish.common.model {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.clarityenglish.common.vo.config.Config;
	
	import mx.rpc.Fault;
	
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
		
		private var parsedCopy:Object;
		
		public function CopyProxy(data:Object = null) {
			super(NAME, data);
		}
		
		public function getCopy():void {
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var config:Config = configProxy.getConfig();
			var param:Array = [ defaultLanguageCode, config.productCode, config.loginOption, config.dbHost ];
			new RemoteDelegate("getCopy", param, this).execute();
		}
		
		/**
		 * Take the XML and parse it into objects to give us O(1) lookup time gh#1074
		 */
		protected function parseCopy(data:Object):void {
			var copy:XML = new XML(data);
			parsedCopy = {};
			for each (var language:XML in copy.language) {
				parsedCopy[language.@code] = function():Object {
					var literals:Object = {};
					for each (var literal:XML in language.group.lit) {
						literals[literal.@name] = { text: literal.toString() };
						if (literal.attribute("code").length() > 0) literals[literal.@name].code = parseInt(literal.@code);
					}
					return literals;
				}();
			}
		}
		
		/**
		 * Get the literal for the given id, if it exists
		 */
		protected function getLiteral(id:String):Object {
			return parsedCopy[languageCode][id] ? parsedCopy[languageCode][id] : (parsedCopy[defaultLanguageCode][id] ? parsedCopy[defaultLanguageCode][id] : null);
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
			if (!this.parsedCopy)
				throw new Error("Copy literals have not been loaded yet");
			
			// Return either the language literal, the default language literal or as a last resort the literal id
			var literal:Object = getLiteral(id);
			var str:String = literal ? literal.text : id;
			
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
			if (!this.parsedCopy)
				throw new Error("Copy literals have not been loaded yet");
			
			var literal:Object = getLiteral(id);
			
			return (literal) ? new Number(literal.code) : 0;
		}
		
		// gh#11
		public function getLanguageCode():String {
			return languageCode;
		}
		
		public function getDefaultLanguageCode():String {
			return defaultLanguageCode;
		}
		
		public function getBentoErrorForId(id:String, replaceObj:Object = null, isFatal:Boolean = true):BentoError {
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
					parseCopy(data);
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
