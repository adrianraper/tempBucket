/*
Proxy - PureMVC
*/
package com.clarityenglish.resultsmanager.model {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.*;
	import com.clarityenglish.common.vo.tests.TestDetail;
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
	public class TestDetailsProxy extends Proxy implements IProxy, IDelegateResponder {
		
		public static const NAME:String = "TestProxy";

		public function TestDetailsProxy(data:Object = null) {
			super(NAME, data);	
		}
		
		public function getTestDetails(group:Group):void {
			new RemoteDelegate("getTestDetails", [ group ], this).execute();
		}
		public function addTestDetail(testDetail:TestDetail):void {
			new RemoteDelegate("addTestDetail", [ testDetail ], this).execute();
		}
		public function updateTestDetail(testDetail:TestDetail):void {
			new RemoteDelegate("updateTestDetail", [ testDetail ], this).execute();
		}
		public function deleteTestDetail(testDetail:TestDetail):void {
			new RemoteDelegate("deleteTestDetail", [ testDetail ], this).execute();
		}
		
		public function onDelegateResult(operation:String, data:Object):void{
			switch (operation) {
				case "getTestDetails":
					sendNotification(RMNotifications.TEST_DETAILS_LOADED, data);
					break;
				case "updateTestDetail":
					sendNotification(RMNotifications.TEST_DETAIL_UPDATED, data);
					break;
				case "addTestDetail":
					sendNotification(RMNotifications.TEST_DETAIL_ADDED, data);
					break;
				case "deleteTestDetail":
					sendNotification(RMNotifications.TEST_DETAIL_DELETED, data);
					break;
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Result from unknown operation: " + operation);
			}
		}
		
		public function onDelegateFault(operation:String, data:Object):void{
			sendNotification(CommonNotifications.TRACE_ERROR, operation + ": " + data);
			
			switch (operation) {
				case "updateTestDetail":
				case "deleteTestDetail":
				case "addTestDetail":
				case "getTestDetails":
					break;
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Fault from unknown operation: " + operation);
			}
		}
		
	}
}