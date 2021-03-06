﻿/*
Proxy - PureMVC
*/
package com.clarityenglish.resultsmanager.model {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.resultsmanager.ApplicationFacade;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.resultsmanager.RMNotifications;
	import org.davekeen.delegates.IDelegateResponder;
	import org.davekeen.delegates.RemoteDelegate;
	import org.davekeen.utils.DateUtils;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	import com.clarityenglish.utils.TraceUtils;


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
		
		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		
		public function onDelegateResult(operation:String, data:Object):void{
			switch (operation) {
				case "getUsageForTitle":
					sendNotification(RMNotifications.USAGE_LOADED, data);
					break;
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Result from unknown operation: " + operation);
			}
		}
		
		public function onDelegateFault(operation:String, data:Object):void{
			sendNotification(CommonNotifications.TRACE_ERROR, operation + ": " + data);
			
			switch (operation) {
				case "getUsageForTitle":
					break;
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Fault from unknown operation: " + operation);
			}
		}
		
	}
}