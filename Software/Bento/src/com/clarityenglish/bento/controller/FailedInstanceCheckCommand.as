package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.ExerciseProxy;
	import com.clarityenglish.bento.view.warning.WarningView;
	import com.clarityenglish.bento.vo.content.Exercise;
	
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
	
	public class FailedInstanceCheckCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var titleWindow:TitleWindow;
		
		public override function execute(note:INotification):void {
			super.execute(note);

			// Stop the exercise you have just loaded, or are loading
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			sendNotification(BBNotifications.EXERCISE_STOP, bentoProxy.currentExercise);
			
			var type:String = note.getBody().type as String;
			var action:String = note.getBody().action as String;

			// Create the title window; maintain a reference so that the command doesn't get garbage collected until the window is shut
			titleWindow = new TitleWindow();
			titleWindow.styleName = "warningTitleWindow";
			titleWindow.title = "Error";
			
			var warningView:WarningView = new WarningView();
			warningView.type = type;
			warningView.action = action;
			titleWindow.addElement(warningView);
			
			// Create and centre the popup
			PopUpManager.addPopUp(titleWindow, FlexGlobals.topLevelApplication as DisplayObject, true, PopUpManagerChildList.POPUP, FlexGlobals.topLevelApplication.moduleFactory);
			PopUpManager.centerPopUp(titleWindow);
			
			// Hide the close button
			titleWindow.closeButton.visible = false;
			
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
		}
		
	}
	
}