package com.clarityenglish.rotterdam.builder.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	
	import mx.core.FlexGlobals;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class MediaUploadCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var tempWidgetId:String;
		
		private var node:XML;
		
		private var fileReference:FileReference;
		
		private static var uploadCount:int; // This keeps track of uploads in progress for UPLOADS_DIRTY and UPLOADS_CLEAN gh#90
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			node = note.getBody().node;
			tempWidgetId = note.getType();
			log.info("Opening upload dialog with tempWidgetId=" + tempWidgetId);
			
			fileReference = new FileReference();
			fileReference.browse(note.getBody().typeFilter);
			
			fileReference.addEventListener(Event.CANCEL, onUploadCancel);
			fileReference.addEventListener(Event.SELECT, onUploadSelect);
			fileReference.addEventListener(ProgressEvent.PROGRESS, onUploadProgress);
			fileReference.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadCompleteData);
			fileReference.addEventListener(IOErrorEvent.IO_ERROR, onUploadIOError);
			fileReference.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onUploadSecurityError);
		}
		
		private function destroy():void {
			// TODO: Be sure that its actually a good idea to remove the id attribute
			delete node.@tempid;
			
			fileReference.removeEventListener(Event.CANCEL, onUploadCancel);
			fileReference.removeEventListener(Event.SELECT, onUploadSelect);
			fileReference.removeEventListener(ProgressEvent.PROGRESS, onUploadProgress);
			fileReference.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadCompleteData);
			fileReference.removeEventListener(IOErrorEvent.IO_ERROR, onUploadIOError);
			fileReference.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onUploadSecurityError);
			fileReference = null;
		}
		
		private function onUploadCancel(e:Event):void {
			//gh #212
			if (!node.hasOwnProperty("@src")) {
				facade.sendNotification(RotterdamNotifications.WIDGET_DELETE, node);
			}			
			destroy();
		}
		
		private function onUploadSelect(e:Event):void {
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var uploadScript:String = configProxy.getConfig().remoteGateway + "/services/RotterdamUpload.php";
			
			// GH #32
			if (FlexGlobals.topLevelApplication.parameters.sessionid) uploadScript += "?PHPSESSID=" + FlexGlobals.topLevelApplication.parameters.sessionid;
			
			sendNotification(RotterdamNotifications.MEDIA_UPLOAD_START, null, tempWidgetId);
			fileReference.upload(new URLRequest(uploadScript));
		}
		
		private function onUploadProgress(e:ProgressEvent):void {
			sendNotification(RotterdamNotifications.MEDIA_UPLOAD_PROGRESS, e, tempWidgetId);
		}
		
		private function onUploadCompleteData(e:DataEvent):void {
			var response:Object = JSON.parse(e.data);
			
			// Merge returned keys/values into the node's attributes (apart from success)
			for (var key:String in response) {
				if (key != "success") node.@[key] = response[key];
			}
			
			sendNotification(RotterdamNotifications.MEDIA_UPLOADED, null, tempWidgetId);
			destroy();
		}
		
		private function onUploadIOError(e:IOErrorEvent):void {
			sendNotification(RotterdamNotifications.MEDIA_UPLOAD_ERROR, e.text, tempWidgetId);
			destroy();
		}
		
		private function onUploadSecurityError(e:SecurityErrorEvent):void {
			sendNotification(RotterdamNotifications.MEDIA_UPLOAD_ERROR, e.text, tempWidgetId);
			destroy();
		}
		
		private function increaseUploadCount():void {
			uploadCount++;
			sendNotification(BBNotifications.ITEM_DIRTY, "uploads"); // gh#90
		}
		
		private function decreaseUploadCount():void {
			uploadCount--;
			if (uploadCount == 0) sendNotification(BBNotifications.ITEM_CLEAN, "uploads"); // gh#90
		}
		
	}
	
}