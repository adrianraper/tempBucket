package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.common.model.ConfigProxy;
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.core.FlexGlobals;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	/**
	 * #472
	 */
	public class NetworkCheckAvailability extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var urlLoader:URLLoader;
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			if (configProxy) {
				var url:String = configProxy.getConfig().checkNetworkAvailabilityUrl;
				
				if (url) {
					urlLoader = new URLLoader();
					urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, function(e:HTTPStatusEvent):void {
						if (e.status == 200) onSuccess();
					});
					urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onFailure, false, 0, true);
					urlLoader.addEventListener(IOErrorEvent.NETWORK_ERROR, onFailure, false, 0, true);
					urlLoader.load(new URLRequest(url));
				}
			}
		}
		
		private function onSuccess(e:Event = null):void {
			sendNotification(BBNotifications.NETWORK_AVAILABLE);
			urlLoader = null;
		}
		
		private function onFailure(e:Event = null):void {
			sendNotification(BBNotifications.NETWORK_UNAVAILABLE);
			urlLoader = null;
		}
			
	}
}