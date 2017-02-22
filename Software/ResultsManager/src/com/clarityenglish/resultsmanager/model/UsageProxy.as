/*
Proxy - PureMVC
*/
package com.clarityenglish.resultsmanager.model {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.resultsmanager.ApplicationFacade;
	import com.clarityenglish.resultsmanager.RMNotifications;
	import com.clarityenglish.utils.TraceUtils;
	
	import org.davekeen.delegates.IDelegateResponder;
	import org.davekeen.delegates.RemoteDelegate;
	import org.davekeen.utils.DateUtils;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;

	/**
	 * A proxy
	 */
	public class UsageProxy extends Proxy implements IProxy, IDelegateResponder {
		
		public static const NAME:String = "UsageProxy";

		public function UsageProxy(data:Object = null) {
			super(NAME, data);	
		}
		
		public function getUsage(title:Title, fromDate:Date, toDate:Date):void {
			TraceUtils.myTrace("usageProxy fromDate=" + DateUtils.dateToAnsiString(fromDate) + " toDate=" + DateUtils.dateToAnsiString(toDate));
			
			// Ticket #95 - don't respect timezones so pass dates as an ANSI string
			//new RemoteDelegate("getUsageForTitle", [ title, fromDate, toDate ], this).execute();
			new RemoteDelegate("getUsageForTitle", [ title, DateUtils.dateToAnsiString(fromDate), DateUtils.dateToAnsiString(toDate) ], this).execute();
		}
		
		public function getFixedUsage(title:Title, fromFixDate:Date, toFixDate:Date):void {						
			new RemoteDelegate("getFixedUsageForTitle", [ title, DateUtils.dateToAnsiString(fromFixDate), DateUtils.dateToAnsiString(toFixDate) ], this).execute();
		}
		// gh#1487
		public function getTestUse(productCode:String):void {
			new RemoteDelegate("getUsageForTest", [ productCode ], this).execute();
		}
		
		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		
		public function onDelegateResult(operation:String, data:Object):void{
			switch (operation) {
				case "getUsageForTitle":
					sendNotification(RMNotifications.USAGE_LOADED, data);
					break;
				case "getUsageForTest":
					sendNotification(RMNotifications.TEST_LICENCES_LOADED, data);
					break;
				case "getFixedUsageForTitle":
					sendNotification(RMNotifications.FIXEDUSAGE_LOADED, data);
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