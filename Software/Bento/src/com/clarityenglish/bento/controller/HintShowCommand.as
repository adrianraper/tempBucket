package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.vo.content.model.Hint;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.textLayout.components.XHTMLRichText;
	import com.clarityenglish.textLayout.events.XHTMLEvent;
	import com.clarityenglish.textLayout.vo.XHTML;
	import com.newgonzo.web.css.CSSComputedStyle;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.IFocusManagerComponent;
	import mx.managers.PopUpManager;
	import mx.managers.PopUpManagerChildList;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	import spark.components.Scroller;
	import spark.components.TextInput;
	import spark.components.TitleWindow;
	import spark.events.TitleWindowBoundsEvent;
	
	public class HintShowCommand extends SimpleCommand {
		
		private static var titleWindow:TitleWindow;
		
		private static var titleWindowAdded:Boolean;
		
		private var question:Question;
		
		override public function execute(note:INotification):void {
			super.execute(note);
			
			question = note.getBody().question;
			
			var hint:Hint = question.hint;
			
			if (!hint) return;
			
			var xhtml:XHTML = note.getBody().exercise as XHTML;
			
			var hintNode:XML = xhtml.selectOne("#" + hint.source);
			
			if (hintNode) {
				if (!titleWindow) {
					titleWindow = new TitleWindow();
					titleWindow.styleName = "feedbackTitleWindow";
					titleWindow.title = hint.title;
					titleWindow.addEventListener(TitleWindowBoundsEvent.WINDOW_MOVING, onWindowMoving);
				} else {
					titleWindow.removeElement(titleWindow.getElementAt(0));
				}
				
				// Create an XHTMLRichText component and add it to the title window
				var xhtmlRichText:XHTMLRichText = new XHTMLRichText();
				
				// Default to 300 width, variable height unless defined otherwise in the XML
				xhtmlRichText.width = (isNaN(hint.width)) ? 300 : hint.width;
				if (!isNaN(hint.height))
					xhtmlRichText.height = hint.height;
				
				xhtmlRichText.xhtml = xhtml;
				xhtmlRichText.nodeId = "#" + hint.source;
				
				// #127
				var scroller:Scroller = new Scroller();
				scroller.viewport = xhtmlRichText;
				titleWindow.addElement(scroller);
				
				if (!titleWindowAdded)
					setTimeout(addPopupWindow, 150);
			}
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
		 * Keep the window on the screen (#197)
		 *
		 * @param event
		 */
		protected function onWindowMoving(event:TitleWindowBoundsEvent):void {
			if (event.afterBounds.left < 0) {
				event.afterBounds.left = 0;
			} else if (event.afterBounds.right > titleWindow.systemManager.stage.stageWidth) {
				event.afterBounds.left = titleWindow.systemManager.stage.stageWidth - event.afterBounds.width;
			}
			
			if (event.afterBounds.top < 0) {
				event.afterBounds.top = 0;
			} else if (event.afterBounds.bottom > titleWindow.systemManager.stage.stageHeight) {
				event.afterBounds.top = titleWindow.systemManager.stage.stageHeight - event.afterBounds.height;
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
	}
}
