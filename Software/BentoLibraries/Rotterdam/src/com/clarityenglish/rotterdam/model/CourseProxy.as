/*
Proxy - PureMVC
*/
package com.clarityenglish.rotterdam.model {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.rotterdam.vo.Course;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import mx.rpc.Fault;
	
	import org.davekeen.delegates.IDelegateResponder;
	import org.davekeen.delegates.RemoteDelegate;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	/**
	 * A proxy
	 */
	public class CourseProxy extends Proxy implements IProxy, IDelegateResponder {
		
		public static const NAME:String = "CourseProxy";
		
		public function CourseProxy(data:Object = null) {
			super(NAME, data);
		}
		
		public function courseCreate(course:Course):void {
			new RemoteDelegate("courseCreate", [ course ], this).execute();
		}
		
		public function courseSave(xhtml:XHTML):void {
			new RemoteDelegate("courseSave", [ xhtml.href.filename, xhtml.xml ], this).execute();
		}
		
		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		
		public function onDelegateResult(operation:String, data:Object):void {
			switch (operation) {
				case "courseCreate":
					sendNotification(RotterdamNotifications.COURSE_CREATED);
					break;
				case "courseSave":
					sendNotification(RotterdamNotifications.COURSE_SAVED);
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
