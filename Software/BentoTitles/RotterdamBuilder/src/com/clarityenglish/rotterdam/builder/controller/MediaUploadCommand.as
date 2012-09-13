package com.clarityenglish.rotterdam.builder.controller {
	import com.clarityenglish.common.model.ConfigProxy;
	
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
		
		private var fileReference:FileReference;
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			// TODO: note.getBody() will tell us what we are allowed to upload
			var imageTypes:FileFilter = new FileFilter("Images (*.jpg, *.jpeg, *.gif, *.png)", "*.jpg; *.jpeg; *.gif; *.png");
			var videoTypes:FileFilter = new FileFilter("Videos (*.flv)", "*.flv");
			var audioTypes:FileFilter = new FileFilter("Audio (*.mp3)", "*.mp3");
			var filesTypes:FileFilter = new FileFilter("Files (*.pdf, *.doc, *.ppt, *.xls)", "*.pdf; *.doc; *.ppt; *.xls");
			
			var allTypes:Array = [ imageTypes, videoTypes, audioTypes, filesTypes ];
			fileReference = new FileReference();
			fileReference.browse(allTypes);
			
			fileReference.addEventListener(Event.SELECT, onUploadSelect);
			fileReference.addEventListener(ProgressEvent.PROGRESS, onUploadProgress);
			fileReference.addEventListener(Event.COMPLETE, onUploadComplete);
			fileReference.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadCompleteData);
			fileReference.addEventListener(IOErrorEvent.IO_ERROR, onUploadIOError);
			fileReference.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onUploadSecurityError);
		}
		
		private function destroy():void {
			fileReference.removeEventListener(Event.SELECT, onUploadSelect);
			fileReference.removeEventListener(ProgressEvent.PROGRESS, onUploadProgress);
			fileReference.removeEventListener(Event.COMPLETE, onUploadComplete);
			fileReference.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadCompleteData);
			fileReference.removeEventListener(IOErrorEvent.IO_ERROR, onUploadIOError);
			fileReference.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onUploadSecurityError);
			fileReference = null;
		}
		
		private function onUploadSelect(e:Event):void {
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var uploadScript:String = configProxy.getConfig().remoteGateway + "/services/RotterdamUpload.php";
			
			fileReference.upload(new URLRequest(uploadScript));
			//coreSignalBus.progressBarStart.dispatch("Progress", "Uploading file to server...", true);
		}
		
		private function onUploadProgress(e:ProgressEvent):void {
			//coreSignalBus.progressBarProgress.dispatch(e);
		}
		
		private function onUploadComplete(e:Event):void {
			//coreSignalBus.progressBarComplete.dispatch();
		}
		
		private function onUploadCompleteData(e:DataEvent):void {
			/*coreSignalBus.progressBarChangeMessage.dispatch("Opening...");
			// Decode the JSON response
			var response:Object = JSON.decode(e.data);
			
			if (response.success) {
				// If the response was successful then load the just created MediaItem (the id will be in response.result)
				entityService.getRepository(MediaItem).load(new Number(response.result)).addResponder(
					new AsyncResponder(
						function (e:ResultEvent, token:Object):void {
							coreSignalBus.progressBarComplete.dispatch();
							
							var mediaItem:MediaItem = e.result as MediaItem;
							mediaItem.title = response.filename;
							entitySignalBus.entityPersisted.dispatch(mediaItem);
							mediaSignalBus.mediaViewWindowOpen.dispatch(mediaItem, new PopUpResponder(null, "newMediaItem"));
						},
						function (e:FaultEvent, token:Object):void {
							coreSignalBus.progressBarComplete.dispatch();
							
							Alert.show(resourceManager.getString("media", "uploadFailure") + " [" + e.fault.faultString + "]", resourceManager.getString("multimecore", "errorTitle")); 
						}
					)
				);
			} else {
				// If the response was unsuccessful display the error message in an alert
				Alert.show(resourceManager.getString("media", "uploadFailure") + " [" + response.fault + "]", resourceManager.getString("multimecore", "errorTitle")); 
			}*/
			
			var response:Object = JSON.parse(e.data);
			trace(ObjectUtil.toString(response));
			destroy();
		}
		
		private function onUploadIOError(e:IOErrorEvent):void {
			//coreSignalBus.progressBarComplete.dispatch();
			//Alert.show(resourceManager.getString("media", "uploadIoError") + " [" + e.text + "]", resourceManager.getString("multimecore", "errorTitle"));
			destroy();
		}
		
		private function onUploadSecurityError(e:SecurityErrorEvent):void {
			//coreSignalBus.progressBarComplete.dispatch();
			//Alert.show(resourceManager.getString("media", "uploadSecurityError") + " [" + e.text + "]", resourceManager.getString("multimecore", "errorTitle"));
			destroy();
		}
		
	}
	
}