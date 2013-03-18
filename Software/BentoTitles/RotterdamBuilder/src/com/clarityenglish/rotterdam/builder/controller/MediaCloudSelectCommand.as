package com.clarityenglish.rotterdam.builder.controller {
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.rotterdam.builder.view.filemanager.FileManagerView;
	import com.clarityenglish.rotterdam.builder.view.filemanager.events.FileManagerEvent;
	import com.clarityenglish.rotterdam.builder.view.uniteditor.events.ContentEvent;
	
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
	
	public class MediaCloudSelectCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var tempWidgetId:String;
		
		private var node:XML;
		
		private var titleWindow:TitleWindow;
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			node = note.getBody().node;
			tempWidgetId = note.getType();
			log.info("Opening cloud select dialog with tempWidgetId=" + tempWidgetId);
			
			// Create the title window; maintain a reference so that the command doesn't get garbage collected until the window is shut
			titleWindow = new TitleWindow();
			titleWindow.styleName = "markingTitleWindow"; //... if we want to skin the title window
			titleWindow.title = "Resources Cloud";
			titleWindow.addEventListener(TitleWindowBoundsEvent.WINDOW_MOVING, onWindowMoving, false, 0, true);
			
			var fileManagerView:FileManagerView = new FileManagerView();
			fileManagerView.percentWidth = fileManagerView.percentHeight = 100;
			fileManagerView.typeFilter = note.getBody().typeFilter;
			fileManagerView.selectMode = true;
			//gh#158
			fileManagerView.popUpMode = true;
			titleWindow.addElement(fileManagerView);
			
			// Create and centre the popup (this popup is modal)
			PopUpManager.addPopUp(titleWindow, FlexGlobals.topLevelApplication as DisplayObject, true, PopUpManagerChildList.POPUP, FlexGlobals.topLevelApplication.moduleFactory);
			PopUpManager.centerPopUp(titleWindow);
			
			// Hide the close button
			titleWindow.closeButton.visible = false;
			
			// Listen for the close event so that we can cleanup
			titleWindow.addEventListener(FileManagerEvent.FILE_SELECT, onFileSelect);
			//gh #212
			titleWindow.addEventListener(FileManagerEvent.FILE_CANCEL, onFileCancel);
			titleWindow.addEventListener(CloseEvent.CLOSE, onClosePopUp);
		}
		
		/**
		 * The user has selected some media so update the node accordingly
		 * 
		 * @param event
		 */
		protected function onFileSelect(event:FileManagerEvent):void {
			node.@src = event.mediaNode.@filename;
		}
		
		//alice
		protected function onFileCancel(event:FileManagerEvent):void {
			if (!node.hasOwnProperty("@src"))
				facade.sendNotification(RotterdamNotifications.WIDGET_DELETE, node);
		}
		
		/**
		 * Close the popup and make all variables eligible for garbage collection
		 * 
		 * @param event
		 */
		protected function onClosePopUp(event:CloseEvent = null):void {
			titleWindow.removeEventListener(CloseEvent.CLOSE, onClosePopUp);
			titleWindow.removeEventListener(FileManagerEvent.FILE_SELECT, onFileSelect);
			titleWindow.removeEventListener(TitleWindowBoundsEvent.WINDOW_MOVING, onWindowMoving);
			
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