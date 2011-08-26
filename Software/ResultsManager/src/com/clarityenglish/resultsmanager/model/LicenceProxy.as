/*
Proxy - PureMVC
*/
package com.clarityenglish.resultsmanager.model {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.resultsmanager.ApplicationFacade;
	import com.clarityenglish.resultsmanager.RMNotifications;
	import com.clarityenglish.resultsmanager.view.management.ManageablesMediator;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.User;
	import flash.utils.Dictionary;
	import mx.utils.ObjectUtil;
	import org.davekeen.delegates.IDelegateResponder;
	import org.davekeen.delegates.RemoteDelegate;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;

	/**
	 * v3.2 This whole proxy is deprecated. However it is still run with an empty table for now.
	 */
	public class LicenceProxy extends Proxy implements IProxy, IDelegateResponder {
		
		public static const NAME:String = "LicenceProxy";
		
		private var licencesDict:Dictionary;

		public function LicenceProxy(data:Object = null) {
			super(NAME, data);
			
			getLicences();
		}
		
		private function getLicences():void {
			new RemoteDelegate("getLicences", [], this).execute();
		}
		
		public function isUserInTitle(user:User, title:Title):Boolean {
			// If there are no licences for the title return false
			if (!licencesDict[title.productCode]) return false;
			
			// Otherwise check that the licenses contains the data
			var licenceArray:Array = licencesDict[title.productCode];
			
			// v3.4 Multi-group users
			//return licenceArray.indexOf(user.id) > -1;
			return licenceArray.indexOf(user.userID) > -1;
		}
		
		public function getUsersInTitle(title:Title):Array {
			// If there are no licences for the title return an empty array
			if (!licencesDict[title.productCode]) return [ ];
			
			// Otherwise return the array
			return licencesDict[title.productCode];
		}
		
		public function allocateLicences(users:Array, title:Title):void {
			// Turn the manageables array into an array of ids
			var userIdArray:Array = users.map(function(user:User, index:int, array:Array):String {
				// v3.4 Multi-group users
				//return user.id;
				return user.userID;
			} );
			
			new RemoteDelegate("allocateLicences", [ userIdArray, title.productCode ], this).execute();
		}
		
		public function unallocateLicences(users:Array, title:Title):void {
			// Turn the manageables array into an array of ids
			var userIdArray:Array = users.map(function(user:User, index:int, array:Array):String {
				// v3.4 Multi-group users
				//return user.id;
				return user.userID;
			} );
			
			new RemoteDelegate("unallocateLicences", [ userIdArray, title.productCode ], this).execute();
		}
		
		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		
		public function onDelegateResult(operation:String, data:Object):void {
			switch (operation) {
				case "getLicences":
					// Annoyingly AMFPHP returns associative arrays as object so we need to convert this to a dictionary
					licencesDict = new Dictionary();
					
					for (var key:String in data) {
						var keyNumber:Number = new Number(key);
						licencesDict[keyNumber] = data[key] as Array;
					}
					
					sendNotification(RMNotifications.LICENCES_LOADED, licencesDict);
					break;
				case "allocateLicences":
				case "unallocateLicences":
					getLicences();
					break;
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Result from unknown operation: " + operation);
			}
		}
		
		public function onDelegateFault(operation:String, data:Object):void {
			//sendNotification(ApplicationFacade.TRACE_ERROR, operation + ": " + data);
			
			// Don't show function name as this is sometimes an expected error
			sendNotification(CommonNotifications.TRACE_ERROR, data);
			
			switch (operation) {
				case "getLicences":
					break;
				case "allocateLicences":
				case "unallocateLicences":
					getLicences();
					break;
			}
		}
		
	}
}