package com.clarityenglish.clearpronunciation.controller {
	import com.clarityenglish.clearpronunciation.view.course.ui.YouWillView;
	
	import flash.display.DisplayObject;
	
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	import mx.managers.PopUpManagerChildList;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	import spark.components.TitleWindow;
	import spark.events.TitleWindowBoundsEvent;
	
	public class YouWillShowCommand extends SimpleCommand {
		
		private var titleWindow:TitleWindow;
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			titleWindow = new TitleWindow();
			titleWindow.styleName = "noTitleTitleWindow";
			titleWindow.addEventListener(TitleWindowBoundsEvent.WINDOW_MOVING, onWindowMoving);
			titleWindow.addEventListener(CloseEvent.CLOSE, onClosePopUp);
			
			var youWillView:YouWillView = new YouWillView();
			youWillView.labelString = note.getBody() as String;
			titleWindow.addElement(youWillView);
			
			PopUpManager.addPopUp(titleWindow, FlexGlobals.topLevelApplication as DisplayObject, false, PopUpManagerChildList.POPUP, FlexGlobals.topLevelApplication.moduleFactory);
			PopUpManager.centerPopUp(titleWindow);
		}
		
		protected function onClosePopUp(event:CloseEvent = null):void {
			titleWindow.removeEventListener(CloseEvent.CLOSE, onClosePopUp);
			titleWindow.removeEventListener(TitleWindowBoundsEvent.WINDOW_MOVING, onWindowMoving);
			
			PopUpManager.removePopUp(titleWindow);
			titleWindow = null;
		}
		
		protected function onWindowMoving(evt:TitleWindowBoundsEvent):void {
			if (evt.afterBounds.left < 0) {
				evt.afterBounds.left = 0;
			} else if (evt.afterBounds.right > FlexGlobals.topLevelApplication.width) {
				evt.afterBounds.left = FlexGlobals.topLevelApplication.width - evt.afterBounds.width;
			}
			
			if (evt.afterBounds.top < 0) {
				evt.afterBounds.top = 0;
			} else if (evt.afterBounds.bottom > FlexGlobals.topLevelApplication.height) {
				evt.afterBounds.top = FlexGlobals.topLevelApplication.height - evt.afterBounds.height;
			}
		}
	}
}