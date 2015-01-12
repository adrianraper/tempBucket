package com.clarityenglish.bento.controller
{
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	import mx.controls.Label;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.IFocusManagerComponent;
	import mx.managers.PopUpManager;
	import mx.managers.PopUpManagerChildList;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	import spark.components.Label;
	import spark.components.Scroller;
	import spark.components.TextInput;
	import spark.components.TitleWindow;
	import spark.events.TitleWindowBoundsEvent;
	
	public class FeedbackReminderShowCommand extends SimpleCommand {
		
		private static var titleWindow:TitleWindow;
		
		private static var titleWindowAdded:Boolean;
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
			
			var text:String = note.getBody() as String;
			// Create the title window; maintain a reference so that the command doesn't get garbage collected until the window is shut
			titleWindow = new TitleWindow();
			//titleWindow.styleName = "markingTitleWindow"; ... if we want to skin the title window
			titleWindow.styleName = "feedbackTitleWindow";
			titleWindow.title = copyProvider.getCopyForId('exerciseFeedbackButton');

			titleWindow.addEventListener(TitleWindowBoundsEvent.WINDOW_MOVING, onWindowMoving, false, 0, true);
			
			var label:spark.components.Label = new spark.components.Label();
			label.text = text;
			label.top = 20;
			label.right = 20;
			label.left = 20;
			label.bottom = 20;
			titleWindow.addElement(label);
			
			if (!titleWindowAdded) setTimeout(addPopupWindow, 150);
		}
		
		private function addPopupWindow():void {
			// Create and centre the popup
			PopUpManager.addPopUp(titleWindow, FlexGlobals.topLevelApplication as DisplayObject, false, PopUpManagerChildList.POPUP, FlexGlobals.topLevelApplication.moduleFactory);
			PopUpManager.centerPopUp(titleWindow);
			
			titleWindowAdded = true;
			
			// Listen for the close event so that we can cleanup
			titleWindow.addEventListener(CloseEvent.CLOSE, onClosePopUp);
			
			// Add a keyboard listener so the user can close the feedback window with the keyboard.  This listener needs a brief delay before being
			// added as otherwise its possible to trigger the feedback window with the same key that closes it, hence closing it instantly.
			setTimeout(function():void {
				(FlexGlobals.topLevelApplication as DisplayObject).stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboardDown);
			}, 300);
		}
		
		/**
		 * The escape and enter keys also close the popup
		 * 
		 * @param event
		 */
		protected function onKeyboardDown(event:KeyboardEvent):void {
			if (event.keyCode == Keyboard.ESCAPE) {
				onClosePopUp();
			} else if (event.keyCode == Keyboard.ENTER) {
				var focus:IFocusManagerComponent = titleWindow.focusManager.getFocus();
				if (!focus || !(focus is TextInput)) // #265(d) - don't close the popup if focus is in a gapfill
					onClosePopUp();
			}
		}
		
		/**
		 * Close the popup and make all variables eligible for garbage collection
		 * 
		 * @param event
		 */
		protected function onClosePopUp(event:CloseEvent = null):void {
			if (titleWindow) {
				titleWindow.removeEventListener(CloseEvent.CLOSE, onClosePopUp);
				titleWindow.removeEventListener(TitleWindowBoundsEvent.WINDOW_MOVING, onWindowMoving);
			}
			
			PopUpManager.removePopUp(titleWindow);
			
			(FlexGlobals.topLevelApplication as DisplayObject).stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyboardDown);
			
			titleWindowAdded = false;
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