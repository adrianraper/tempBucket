package com.clarityenglish.common.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.view.error.ErrorView;
	import com.clarityenglish.common.vo.config.BentoError;
	
	import flash.display.DisplayObject;
	
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
	
	public class ShowErrorCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var titleWindow:TitleWindow;
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			// Create the title window; maintain a reference so that the command doesn't get garbage collected until the window is shut
			titleWindow = new TitleWindow();
			titleWindow.title = "Sorry, there is a problem:";
			
			var errorView:ErrorView = new ErrorView();
			errorView.error = note.getBody() as BentoError;
			titleWindow.addElement(errorView);
			
			// Create and centre the popup
			PopUpManager.addPopUp(titleWindow, FlexGlobals.topLevelApplication as DisplayObject, true, PopUpManagerChildList.POPUP, FlexGlobals.topLevelApplication.moduleFactory);
			PopUpManager.centerPopUp(titleWindow);
			
			// Show the close button
			// TODO. It might be easier for the user to also have an OK button that does the same thing as this close.
			titleWindow.closeButton.visible = true;
			
			// Listen for the close event so that we can cleanup
			titleWindow.addEventListener(CloseEvent.CLOSE, onClosePopUp);
			
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
			
			// Exit the program
			sendNotification(CommonNotifications.EXIT);
		}
		
	}
	
}