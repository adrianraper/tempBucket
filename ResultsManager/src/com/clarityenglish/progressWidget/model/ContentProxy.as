/*
Proxy - PureMVC
*/
package com.clarityenglish.progressWidget.model {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.progressWidget.ApplicationFacade;
	import com.clarityenglish.common.vo.content.Content;
	import com.clarityenglish.common.vo.content.Course;
	import com.clarityenglish.common.vo.content.Exercise;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.content.Unit;
	import com.clarityenglish.common.vo.manageable.Group;
	import com.clarityenglish.progressWidget.PWNotifications;
	import mx.core.Application;
	import org.davekeen.delegates.IDelegateResponder;
	import org.davekeen.delegates.RemoteDelegate;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	import com.clarityenglish.utils.TraceUtils;
	import org.puremvc.as3.patterns.observer.Notification;
	/**
	 * A proxy
	 */
	public class ContentProxy extends Proxy implements IProxy, IDelegateResponder {
		namespace embed;
		embed static var title:Title;
		embed static var unit:Unit;
		embed static var course:Course;
		embed static var exercise:Exercise;
		
		public static const NAME:String = "ContentProxy";

		private var _titles:Array;
		
		public function ContentProxy(data:Object = null) {
			super(NAME, data);
			
			var params:Array = [ ];
			if (Application.application.parameters.rootID) params.push(new Number(Application.application.parameters.rootID));
			if (Application.application.parameters.productCode) params.push(new Number(Application.application.parameters.productCode));
			TraceUtils.myTrace("contentProxy for productCode=" + Application.application.parameters.productCode);
			new RemoteDelegate("getContent", params, this).execute();
		}
		
		public function get titles():Array { return _titles; }
		
		public function set titles(value:Array):void {
			_titles = value;
		}
		
		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		
		public function onDelegateResult(operation:String, data:Object):void {
			switch (operation) {
				case "getContent":
					TraceUtils.myTrace("contentProxy.getContent trigger CONTENT_LOADED");
					titles = data as Array;
					// v3.1 Now you have the content object, you can play with it in the view
					sendNotification(PWNotifications.CONTENT_LOADED, titles);
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