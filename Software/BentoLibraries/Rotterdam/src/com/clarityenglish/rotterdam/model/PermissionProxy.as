/*
Proxy - PureMVC
*/
package com.clarityenglish.rotterdam.model {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.clarityenglish.common.vo.content.Course;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.AsyncToken;
	import mx.rpc.Fault;
	import mx.utils.XMLNotifier;
	
	import org.davekeen.delegates.IDelegateResponder;
	import org.davekeen.delegates.RemoteDelegate;
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.facade.Facade;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	/**
	 * A proxy
	 */
	public class PermissionProxy extends Proxy implements IProxy, IDelegateResponder {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public static const NAME:String = "PermissionProxy";
		
		private var _currentUnit:XML;
		
		public function PermissionProxy(data:Object = null) {
			super(NAME, data);
			
		}
		
		public function reset():void {
		}
		
		public function get currentCourse():XHTML {
			// The current course actually comes from the currently loaded menuXHTML, since for Rotterdam each menu.xml contains a single course (although this should
			// maybe return the course node for clarity)
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			return bentoProxy.menuXHTML;
		}
		
		private function get courseNode():XML {	
			return currentCourse.selectOne("script#model[type='application/xml'] course");
		}
		
		public function courseCreate(courseObj:Object):AsyncToken {
			return new RemoteDelegate("courseCreate", [ courseObj ], this).execute();
		}
		
		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		
		public function onDelegateResult(operation:String, data:Object):void {
			switch (operation) {
				case "getPermission":
					sendNotification(RotterdamNotifications.COURSE_CREATED, data);
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
