package com.clarityenglish.rotterdam.builder.controller {
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.ObjectUtil;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class MediaUploadCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var uploadId:String;
		
		private var fileReference:FileReference;
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			uploadId = note.getType();
			log.info("Opening upload dialog with uploadId=" + uploadId);
			
			// TODO: note.getBody() will eventually tell us what we are allowed to upload
			var imageTypes:FileFilter = new FileFilter("Images (*.jpg, *.jpeg, *.gif, *.png)", "*.jpg; *.jpeg; *.gif; *.png");
			var videoTypes:FileFilter = new FileFilter("Videos (*.flv)", "*.flv");
			var audioTypes:FileFilter = new FileFilter("Audio (*.mp3)", "*.mp3");
			var filesTypes:FileFilter = new FileFilter("Files (*.pdf, *.doc, *.ppt, *.xls)", "*.pdf; *.doc; *.ppt; *.xls");
			
			var allTypes:Array = [ imageTypes, videoTypes, audioTypes, filesTypes ];
			fileReference = new FileReference();
			fileReference.browse(allTypes);
			
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
			var uploadScript:String = configProxy.getConfig().remoteGateway + "/services/RotterdamUpload.php";
			
			sendNotification(RotterdamNotifications.MEDIA_UPLOAD_START, null, uploadId);
			fileReference.upload(new URLRequest(uploadScript));
		}
		
		private function onUploadProgress(e:ProgressEvent):void {
			sendNotification(RotterdamNotifications.MEDIA_UPLOAD_PROGRESS, e, uploadId);
		}
		
		private function onUploadCompleteData(e:DataEvent):void {
			var response:Object = JSON.parse(e.data);
			sendNotification(RotterdamNotifications.MEDIA_UPLOADED, null, uploadId);
			destroy();
		}
		
		private function onUploadIOError(e:IOErrorEvent):void {
			sendNotification(RotterdamNotifications.MEDIA_UPLOAD_ERROR, e.text, uploadId);
			destroy();
		}
		
		private function onUploadSecurityError(e:SecurityErrorEvent):void {
			sendNotification(RotterdamNotifications.MEDIA_UPLOAD_ERROR, e.text, uploadId);
			destroy();
		}
		
	}
	
}