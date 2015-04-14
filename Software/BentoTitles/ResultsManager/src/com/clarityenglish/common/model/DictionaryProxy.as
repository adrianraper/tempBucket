/*
Proxy - PureMVC
*/
package com.clarityenglish.common.model {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.vo.dictionary.DictionarySingleton;
	import org.davekeen.delegates.IDelegateResponder;
	import org.davekeen.delegates.RemoteDelegate;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;

	/**
	 * A proxy
	 */
	public class DictionaryProxy extends Proxy implements IProxy, IDelegateResponder {
		
		public static const NAME:String = "DictionaryProxy";
		
		private var dictionary:DictionarySingleton;
		
		public function DictionaryProxy(data:Object = null) {
			super(NAME, data);
			
			if (!data) throw new Error("DictionaryProxy must be instantiated with a list of dictionary names");			
			
			// Get the singleton dictionary object to store our data
			dictionary = DictionarySingleton.getInstance();
			
			new RemoteDelegate("getDictionaries", [ data as Array ], this).execute();
		}
		
		public function getDictionary(dictionaryName:String):Array {
			return dictionary[dictionaryName];
		}
		
		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		
		public function onDelegateResult(operation:String, data:Object):void{
			switch (operation) {
				case "getDictionaries":
					for (var dictionaryName:String in data)
						dictionary[dictionaryName] = data[dictionaryName];
					
					sendNotification(CommonNotifications.DICTIONARIES_LOADED);
					break;
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Result from unknown operation: " + operation);
			}
		}
		
		public function onDelegateFault(operation:String, data:Object):void{
			sendNotification(CommonNotifications.TRACE_ERROR, operation + ": " + data);
		}
		
	}
}