package com.clarityenglish.rotterdam.controller {
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;
	
	import mx.core.FlexGlobals;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class ResourceGetPermissionCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var urlLoader:URLLoader;
		
		private var widgetId:String;
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			if (configProxy) {
				var permissionScript:String = configProxy.getConfig().remoteGateway + "services/permission.php";
				
				var widget:XML = (note.getBody() as XML);
				widgetId = widget.@id;
				var parameters:String = "?provider=" + widget.@permissionProvider; // + "&src=" + widget.@src;
				
				urlLoader = new URLLoader();
				urlLoader.addEventListener(Event.COMPLETE, function(e:Event):void {
					if (e.target.data) {
						onGrant(e.target.data);
					} else {
						onDenial();
					}
				});
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onFailure, false, 0, true);
				urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onFailure, false, 0, true);
				urlLoader.load(new URLRequest(permissionScript + parameters));
			}
		}
		
		private function onGrant(token:String):void {
			sendNotification(RotterdamNotifications.RESOURCE_GOT_PERMISSION, token, widgetId);
			urlLoader = null;
		}
		
		private function onDenial():void {
			sendNotification(RotterdamNotifications.RESOURCE_DENIED_PERMISSION);
			urlLoader = null;
		}
		
		private function onFailure(e:Event = null):void {
			sendNotification(RotterdamNotifications.RESOURCE_PERMISSION_REQUEST_FAILED);
			urlLoader = null;
		}
		
	}
	
}