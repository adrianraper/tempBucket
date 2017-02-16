/*
Proxy - PureMVC
*/
package com.clarityenglish.common.model {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
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
		
		public static var languageCode:String = "EN";

		private var copy:XML;
		
		public function CopyProxy(data:Object = null) {
			super(NAME, data);
			
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
			var result:XMLList = copy..language.(@code == languageCode)..lit.(@name == id);
			if (result.length() == 0) {
				trace("Unable to find literal for id '" + id + "' - this needs to be added to literals.xml");
				// in which case try in English
				if (languageCode!="EN") {
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
			
			return str;
		}
		
		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		
		public function onDelegateResult(operation:String, data:Object):void{
			switch (operation) {
				case "getCopy":
					copy = new XML(data);
					sendNotification(CommonNotifications.COPY_LOADED);
					break;
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Result from unknown operation: " + operation);
			}
		}
		
		public function onDelegateFault(operation:String, data:Object):void{
			if (data as String == 'errorLostAuthentication') {
				sendNotification(CommonNotifications.AUTHENTICATION_ERROR, "You have been timed out. Please sign in again to keep working.");	
			} else {
				sendNotification(CommonNotifications.TRACE_ERROR, operation + ": " + data);
			}
		}
		
	}
}