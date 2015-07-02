package com.clarityenglish.rotterdam.builder.controller {
import com.clarityenglish.common.model.CopyProxy;
import com.clarityenglish.common.model.interfaces.CopyProvider;
import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.rotterdam.builder.view.uniteditor.AuthoringView;
	import com.clarityenglish.rotterdam.builder.view.uniteditor.ContentSelectorView;
	import com.clarityenglish.rotterdam.builder.view.uniteditor.events.AuthoringEvent;
	import com.clarityenglish.rotterdam.builder.view.uniteditor.events.ContentEvent;
	import com.clarityenglish.rotterdam.builder.view.uniteditor.ui.TitleSettingsWindow;
	import com.clarityenglish.textLayout.util.TLFUtil;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
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
	
	public class AuthoringWindowShowCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var tempWidgetId:String;
		
		private var node:XML;
		
		private var type:String;
		
		private var titleWindow:TitleWindow;
		private var authoringView:AuthoringView;
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			node = note.getBody().node as XML;
			type = note.getBody().type;
			tempWidgetId = note.getType();
			log.info("Opening authoring dialog with type=" + type + " and tempWidgetId=" + tempWidgetId);
			
			// Create the title window; maintain a reference so that the command doesn't get garbage collected until the window is shut
			titleWindow = new TitleSettingsWindow();
			titleWindow.styleName = "authoringTitleWindow";
			titleWindow.addEventListener(TitleWindowBoundsEvent.WINDOW_MOVING, onWindowMoving, false, 0, true);
			titleWindow.addEventListener(AuthoringEvent.OPEN_SETTINGS, onOpenSettings);

            var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
            titleWindow.title = copyProvider.getCopyForId('authoringTitleWindow');

            authoringView = new AuthoringView();
			authoringView.percentWidth = authoringView.percentHeight = 100;
			authoringView.widgetNode = node;
			titleWindow.addElement(authoringView);
			
			// Create and centre the popup (this popup is modal)
			PopUpManager.addPopUp(titleWindow, FlexGlobals.topLevelApplication as DisplayObject, true, PopUpManagerChildList.POPUP, FlexGlobals.topLevelApplication.moduleFactory);
			PopUpManager.centerPopUp(titleWindow);
			
			// TODO Are we going to use the close button as a Cancel?
 			titleWindow.closeButton.visible = true;
			titleWindow.addEventListener(CloseEvent.CLOSE, onClosePopUp);
		}
		
		/**
		 * Open the settings screen
		 * 
		 */
		protected function onOpenSettings(event:AuthoringEvent):void {
			log.info("caught AuthoringEvent in authoring windows show command");
			authoringView.openSettings();
		}
		
		/**
		 * Close the popup and make all variables eligible for garbage collection
		 * 
		 * @param event
		 */
		protected function onClosePopUp(event:CloseEvent = null):void {
			titleWindow.removeEventListener(CloseEvent.CLOSE, onClosePopUp);
			titleWindow.removeEventListener(TitleWindowBoundsEvent.WINDOW_MOVING, onWindowMoving);
			titleWindow.removeEventListener(AuthoringEvent.OPEN_SETTINGS, onOpenSettings);
			
			delete node.@tempid;
			
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