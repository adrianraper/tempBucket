package com.clarityenglish.rotterdam.builder.controller {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.rotterdam.builder.view.error.SavingErrorView;
	import com.clarityenglish.rotterdam.builder.view.error.events.SaveEvent;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	
	import flash.display.DisplayObject;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileReference;
	
	import mx.controls.Button;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.managers.PopUpManager;
	import mx.managers.PopUpManagerChildList;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	import spark.components.TitleWindow;
	
	public class CourseSaveErrorCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var titleWindow:TitleWindow;
		
		private var xmlToDownload:String;
		
		private var savingErrorView:SavingErrorView;
		
		private var courseID:String;
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
			
			// Create the title window; maintain a reference so that the command doesn't get garbage collected until the window is shut
			titleWindow = new TitleWindow();
			titleWindow.styleName = "errorTitleWindow";
			
			savingErrorView = new SavingErrorView();
			titleWindow.addElement(savingErrorView);
			
			xmlToDownload = note.getBody() as String;
			courseID = courseProxy.courseID;
			
			// Create and centre the popup
			PopUpManager.addPopUp(titleWindow, FlexGlobals.topLevelApplication as DisplayObject, true, PopUpManagerChildList.POPUP, FlexGlobals.topLevelApplication.moduleFactory);
			PopUpManager.centerPopUp(titleWindow);
			
			// Show the close button
			titleWindow.closeButton.visible = false;

			// Listen for the save request
			titleWindow.addEventListener(SaveEvent.COURSE_SAVE_ERROR, onSave);
			
			// Listen for the close event so that we can cleanup
			titleWindow.addEventListener(CloseEvent.CLOSE, onClosePopUp);
			
		}

		/**
		 * gh#751 Push the xml as a file to the user's browser
		 * This triggers the file dialog, and lets you save locally. Would it better to use the browser through ExternalInterface?
		 */
		protected function onSave(event:SaveEvent = null):void {
			
			var fileReference:FileReference = new FileReference();
			fileReference.addEventListener(Event.CANCEL, onDownloadCancel);
			fileReference.addEventListener(Event.COMPLETE, onDownloadCompleteData);
			fileReference.addEventListener(IOErrorEvent.IO_ERROR, onDownloadIOError);
			fileReference.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadSecurityError);
			
			fileReference.save(xmlToDownload, 'menu-' + courseID + '.xml');
		}
		
		private function onDownloadCompleteData(e:Event):void {
			onClosePopUp();
		}
		private function onDownloadCancel(e:Event):void {
			onClosePopUp();
		}
		private function onDownloadIOError(e:IOErrorEvent):void {
			onWorstCase();
		}		
		private function onDownloadSecurityError(e:SecurityErrorEvent):void {
			onWorstCase();
		}

		/**
		 * Change the text of the warning message
		 */
		protected function onWorstCase():void {
			var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
			savingErrorView.problemLabel.text = copyProvider.getCopyForId("hmmmLabel");
			savingErrorView.message.text = copyProvider.getCopyForId("worstCaseError");
		}
		
		/**
		 * Close the popup and make all variables eligible for garbage collection
		 * 
		 * @param event
		 */
		protected function onClosePopUp(event:CloseEvent = null):void {
			
			titleWindow.removeEventListener(CloseEvent.CLOSE, onClosePopUp);
			
			PopUpManager.removePopUp(titleWindow);
			titleWindow = null;
		}
		
	}
	
}