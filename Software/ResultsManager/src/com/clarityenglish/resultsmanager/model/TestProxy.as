/*
Proxy - PureMVC
*/
package com.clarityenglish.resultsmanager.model {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.*;
	import com.clarityenglish.common.vo.tests.ScheduledTest;
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
	public class TestProxy extends Proxy implements IProxy, IDelegateResponder {
		
		public static const NAME:String = "TestProxy";

		public function TestProxy(data:Object = null) {
			super(NAME, data);	
		}
		
		public function getTests(group:Group):void {
			var contentProxy:ContentProxy = facade.retrieveProxy(ContentProxy.NAME) as ContentProxy;
			var thisTitle:Title = contentProxy.titles[0] as Title;
			new RemoteDelegate("getTests", [ group, thisTitle.id ], this).execute();
		}
		public function addTest(test:ScheduledTest):void {
			new RemoteDelegate("addTest", [ test ], this).execute();
		}
		public function updateTest(test:ScheduledTest):void {
			new RemoteDelegate("updateTest", [ test ], this).execute();
		}
		//public function deleteTest(test:ScheduledTest):void {
		//	new RemoteDelegate("deleteTest", [ test ], this).execute();
		//}
		
		public function onDelegateResult(operation:String, data:Object):void{
			switch (operation) {
				case "getTests":
					sendNotification(RMNotifications.TESTS_LOADED, data);
					break;
				case "updateTest":					
					sendNotification(RMNotifications.TEST_UPDATED, data);
					break;
				case "addTest":
					sendNotification(RMNotifications.TEST_ADDED, data);
					break;
				//case "deleteTest":
				//	sendNotification(RMNotifications.TEST_DELETED, data);
				//	break;
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Result from unknown operation: " + operation);
			}
		}
		
		public function onDelegateFault(operation:String, data:Object):void{
			sendNotification(CommonNotifications.TRACE_ERROR, operation + ": " + data);
			
			switch (operation) {
				case "updateTest":
				//case "deleteTest":
				case "addTest":
				case "getTests":
					break;
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Fault from unknown operation: " + operation);
			}
		}
		
	}
}