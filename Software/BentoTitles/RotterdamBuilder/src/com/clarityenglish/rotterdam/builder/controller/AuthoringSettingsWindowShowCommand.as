package com.clarityenglish.rotterdam.builder.controller {
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.rotterdam.builder.view.uniteditor.AuthoringSettingsView;
	
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
	import spark.events.TitleWindowBoundsEvent;
	
	public class AuthoringSettingsWindowShowCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var tempWidgetId:String;
		
		private var type:String;
		
		private var titleWindow:TitleWindow;
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var href:Href = note.getBody().href as Href;
			
			// Create the title window; maintain a reference so that the command doesn't get garbage collected until the window is shut
			titleWindow = new TitleWindow();
			titleWindow.styleName = "markingTitleWindow"; //... if we want to skin the title window
			titleWindow.title = "Authoring Settings";
			titleWindow.addEventListener(TitleWindowBoundsEvent.WINDOW_MOVING, onWindowMoving, false, 0, true);
			
			var authoringSettingsView:AuthoringSettingsView = new AuthoringSettingsView();
			authoringSettingsView.percentWidth = authoringSettingsView.percentHeight = 100;
			authoringSettingsView.href = href;
			titleWindow.addElement(authoringSettingsView);
			
			// Create and centre the popup (this popup is modal)
			PopUpManager.addPopUp(titleWindow, FlexGlobals.topLevelApplication as DisplayObject, true, PopUpManagerChildList.POPUP, FlexGlobals.topLevelApplication.moduleFactory);
			PopUpManager.centerPopUp(titleWindow);
			
			// Hide the close button
			titleWindow.closeButton.visible = false;
			
			titleWindow.addEventListener(CloseEvent.CLOSE, onClosePopUp);
		}
		
		/**
		 * Close the popup and make all variables eligible for garbage collection
		 * 
		 * @param event
		 */
		protected function onClosePopUp(event:CloseEvent = null):void {
			titleWindow.removeEventListener(CloseEvent.CLOSE, onClosePopUp);
			titleWindow.removeEventListener(TitleWindowBoundsEvent.WINDOW_MOVING, onWindowMoving);
			
			PopUpManager.removePopUp(titleWindow);
			titleWindow = null;
		}
		
		protected function onWindowMoving(evt:TitleWindowBoundsEvent):void {
			if (evt.afterBounds.left < 0) {
				evt.afterBounds.left = 0;
			} else if (evt.afterBounds.right > evt.target.systemManager.stage.stageWidth) {
				evt.afterBounds.left = evt.target.systemManager.stage.stageWidth - evt.afterBounds.width;
			}
			
			if (evt.afterBounds.top < 0) {
				evt.afterBounds.top = 0;
			} else if (evt.afterBounds.bottom > evt.target.systemManager.stage.stageHeight) {
				evt.afterBounds.top = evt.target.systemManager.stage.stageHeight - evt.afterBounds.height;
			}
		}
		
	}
	
}