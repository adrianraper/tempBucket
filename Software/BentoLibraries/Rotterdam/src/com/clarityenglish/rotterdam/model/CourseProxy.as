/*
Proxy - PureMVC
*/
package com.clarityenglish.rotterdam.model {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	
	import mx.rpc.Fault;
	import mx.utils.ObjectUtil;
	
	import org.davekeen.delegates.IDelegateResponder;
	import org.davekeen.delegates.RemoteDelegate;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	/**
	 * A proxy
	 */
	public class CourseProxy extends Proxy implements IProxy, IDelegateResponder {
		
		public static const NAME:String = "CourseProxy";
		
		private var xml:XML;
		
		public function CourseProxy(data:Object = null) {
			super(NAME, data);
		}
		
		public function getCourses():void {
			// TODO: This could actually use XHTMLProxy and XHTML_LOADED... would be MUCH neater and we could run the course selector off an href like normal 
			new RemoteDelegate("getCourses", [], this).execute();
		}
		
		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		
		public function onDelegateResult(operation:String, data:Object):void {
			switch (operation) {
				case "getCourses":
					xml = new XML(data);
					sendNotification(RotterdamNotifications.COURSES_LOADED, xml);
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
