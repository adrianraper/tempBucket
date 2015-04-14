/*
Proxy - PureMVC
*/
package com.clarityenglish.resultsmanager.model {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.resultsmanager.ApplicationFacade;
	import com.clarityenglish.resultsmanager.Constants;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	/**
	 * A proxy
	 */
	public class UploadProxy extends Proxy implements IProxy {
		
		public static const NAME:String = "UploadProxy";
		
		public var fileReference:FileReference;
		
		private var completeNotification:String;
		private var completeBody:Object;
		private var completeType:String;
		
		private var copyProvider:CopyProvider;
		
		public function UploadProxy(data:Object = null) {
			super(NAME, data);
			
			// Create the FileReference and add upload listeners
			fileReference = new FileReference();
			fileReference.addEventListener(Event.COMPLETE, completeHandler);
			fileReference.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, uploadCompleteDataHandler);
			fileReference.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			fileReference.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			fileReference.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			fileReference.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			
			// Get the copy provider
			copyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
		}
		
		public function upload(completeNotification:String, completeBody:Object = null, completeType:String = null):void {
			this.completeNotification = completeNotification;
			this.completeBody = completeBody;
			this.completeType = completeType;
			
			// Construct the URL request to the upload script
			var request:URLRequest = new URLRequest(Constants.HOST + Constants.UPLOAD_SCRIPT + "?SESSIONID=" + Constants.SESSIONID);
			
			try {
				fileReference.upload(request);
				sendNotification(CommonNotifications.TRACE_NOTICE, copyProvider.getCopyForId("uploading"));
			} catch (e:Error) {
				//trace(e.getStackTrace());
				sendNotification(CommonNotifications.TRACE_ERROR, copyProvider.getCopyForId("uploadScriptError"));
			}		
		}
		
		private function completeHandler(e:Event):void { }
		
		private function uploadCompleteDataHandler(e:DataEvent):void {
			var result:Boolean = (e.data == "1");
			
			if (result) {
				sendNotification(CommonNotifications.TRACE_NOTICE, copyProvider.getCopyForId("uploadComplete"));
				sendNotification(completeNotification, completeBody, completeType);
			} else {
				//trace(e);
				sendNotification(CommonNotifications.TRACE_ERROR, copyProvider.getCopyForId("uploadCompleteError"));
			}
		}
		
		private function cancelHandler(e:Event):void { }
		
		private function httpStatusHandler(e:HTTPStatusEvent):void { }
		
		private function ioErrorHandler(e:IOErrorEvent):void {
			//trace(e);
			sendNotification(CommonNotifications.TRACE_ERROR, copyProvider.getCopyForId("uploadIOError") + " [" + e.text + "]");
		}
		
		private function progressHandler(e:ProgressEvent):void {
			var progressPercent:Number = Math.round(e.bytesLoaded / e.bytesTotal * 100);
			sendNotification(CommonNotifications.TRACE_NOTICE, copyProvider.getCopyForId("uploading") + " " + progressPercent + "%");
		}
		
		private function securityErrorHandler(e:SecurityErrorEvent):void {
			//trace(e);
			sendNotification(CommonNotifications.TRACE_ERROR, copyProvider.getCopyForId("uploadSecurityError"));
		}
		
	}
}