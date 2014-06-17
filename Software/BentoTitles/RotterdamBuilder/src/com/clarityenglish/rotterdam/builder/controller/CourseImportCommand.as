package com.clarityenglish.rotterdam.builder.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	
	import mx.core.FlexGlobals;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class CourseImportCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var fileReference:FileReference;
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			fileReference = new FileReference();
			fileReference.browse(new FileFilter("Archives (*.zip)", "*.zip"));
			
			fileReference.addEventListener(Event.CANCEL, onUploadCancel);
			fileReference.addEventListener(Event.SELECT, onUploadSelect);
			fileReference.addEventListener(ProgressEvent.PROGRESS, onUploadProgress);
			fileReference.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadCompleteData);
			fileReference.addEventListener(IOErrorEvent.IO_ERROR, onUploadIOError);
			fileReference.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onUploadSecurityError);
		}
		
		private function destroy():void {
			
			fileReference.removeEventListener(Event.CANCEL, onUploadCancel);
			fileReference.removeEventListener(Event.SELECT, onUploadSelect);
			fileReference.removeEventListener(ProgressEvent.PROGRESS, onUploadProgress);
			fileReference.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadCompleteData);
			fileReference.removeEventListener(IOErrorEvent.IO_ERROR, onUploadIOError);
			fileReference.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onUploadSecurityError);
			fileReference = null;
		}
		
		private function onUploadCancel(e:Event):void {
			destroy();
		}
		
		private function onUploadSelect(e:Event):void {
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
			var uploadScript:String = configProxy.getConfig().remoteGateway + "/services/RotterdamImport.php";
			
			// gh#32
			if (FlexGlobals.topLevelApplication.parameters.sessionid) uploadScript += "?PHPSESSID=" + FlexGlobals.topLevelApplication.parameters.sessionid;
			
			sendNotification(RotterdamNotifications.MEDIA_UPLOAD_START, null, tempWidgetId);
			fileReference.upload(new URLRequest(uploadScript));
		}
		
		private function onUploadProgress(e:ProgressEvent):void {
			sendNotification(RotterdamNotifications.MEDIA_UPLOAD_PROGRESS, e, tempWidgetId);
		}
		
		private function onUploadCompleteData(e:DataEvent):void {
			var response:Object = JSON.parse(e.data);
			
			if (!response.success) {
				sendNotification(RotterdamNotifications.COURSE_IMPORT_ERROR, { message: response.message });
			} else {
				// TODO: Merge returned units into the course
				
				sendNotification(RotterdamNotifications.COURSE_IMPORTED, null);
			}
			
			destroy();
		}
		
		private function onUploadIOError(e:IOErrorEvent):void {
			sendNotification(RotterdamNotifications.COURSE_IMPORT_ERROR, { message: e.text });
			destroy();
		}
		
		private function onUploadSecurityError(e:SecurityErrorEvent):void {
			sendNotification(RotterdamNotifications.COURSE_IMPORT_ERROR, { message: e.text });
			destroy();
		}
		
	}
	
}