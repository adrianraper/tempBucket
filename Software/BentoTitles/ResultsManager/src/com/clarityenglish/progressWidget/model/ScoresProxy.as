/*
Proxy - PureMVC
*/
package com.clarityenglish.progressWidget.model {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.progressWidget.ApplicationFacade;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.Reportable;
	import com.clarityenglish.progressWidget.PWNotifications;
	import org.davekeen.delegates.IDelegateResponder;
	import org.davekeen.delegates.RemoteDelegate;
	import org.davekeen.utils.DateUtils;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	import com.clarityenglish.utils.TraceUtils;

	/**
	 * A proxy
	 */
	public class ScoresProxy extends Proxy implements IProxy, IDelegateResponder {
		
		public static const NAME:String = "ScoresProxy";

		public function ScoresProxy(data:Object = null) {
			super(NAME, data);
			
		}
		
		public function getCoverage(trackables:Array, fromDate:Date, toDate:Date):void {
			// We want to pull the product codes from the trackables array
			//TraceUtils.myTrace("in scoresProxy for");
			var titleIDs:Array = new Array();
			for each (var title:Title in trackables) {
				//TraceUtils.myTrace("product=" + title.productCode);
				titleIDs.push(title.productCode);
			}
			TraceUtils.myTrace("scoresProxy for " + titleIDs.toString() + " fromDate=" + DateUtils.dateToAnsiString(fromDate) + " toDate=" + DateUtils.dateToAnsiString(toDate));
			new RemoteDelegate("getCoverage", [ titleIDs, DateUtils.dateToAnsiString(fromDate), DateUtils.dateToAnsiString(toDate) ], this).execute();
		}
		public function getEveryonesCoverage(trackables:Array, fromDate:Date, toDate:Date, country:String=null):void {
			// We want to pull the product codes from the trackables array
			//TraceUtils.myTrace("in scoresProxy for");
			var titleIDs:Array = new Array();
			for each (var title:Title in trackables) {
				//TraceUtils.myTrace("product=" + title.productCode);
				titleIDs.push(title.productCode);
			}
			TraceUtils.myTrace("scoresProxy for everyone " + titleIDs.toString() + " fromDate=" + DateUtils.dateToAnsiString(fromDate) + " toDate=" + DateUtils.dateToAnsiString(toDate) + " limit to " + country);
			new RemoteDelegate("getEveryonesCoverage", [ titleIDs, DateUtils.dateToAnsiString(fromDate), DateUtils.dateToAnsiString(toDate), country ], this).execute();
		}
		
		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		
		public function onDelegateResult(operation:String, data:Object):void{
			TraceUtils.myTrace("scoresProxy result for " + operation);
			switch (operation) {
				case "getCoverage":
					sendNotification(PWNotifications.SCORES_LOADED, data);
					break;
				case "getEveryonesCoverage":
					sendNotification(PWNotifications.EVERYONES_SCORES_LOADED, data);
					break;
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Result from unknown operation: " + operation);
			}
		}
		
		public function onDelegateFault(operation:String, data:Object):void{
			sendNotification(CommonNotifications.TRACE_ERROR, operation + ": " + data);
			
			switch (operation) {
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Fault from unknown operation: " + operation);
			}
		}
		
	}
}