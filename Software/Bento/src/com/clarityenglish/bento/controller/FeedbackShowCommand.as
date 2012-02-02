package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.vo.content.model.answer.Feedback;
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
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.managers.PopUpManager;
	import mx.managers.PopUpManagerChildList;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	import spark.components.Scroller;
	import spark.components.TitleWindow;
	import spark.events.TitleWindowBoundsEvent;
	
	public class FeedbackShowCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var titleWindow:TitleWindow;

		private var feedback:Feedback;
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			feedback = note.getBody().feedback as Feedback;
			var xhtml:XHTML = note.getBody().exercise as XHTML;
			var substitutions:Object = note.getBody().substitutions;
			
			var feedbackNode:XML = xhtml.selectOne("#" + feedback.source);
			if (feedbackNode) {
				
				if (substitutions) {
					// Since we might change the XHTML during the substitution phase, we need to clone it
					xhtml = xhtml.clone();
					
					// Do string substitutions
					var xmlString:String = xhtml.xml;
					
					for (var find:String in substitutions) {
						var replace:String = substitutions[find];
						xmlString = xmlString.replace("{{=" + find + "}}", replace);
					}
					
					xhtml.xml = new XML(xmlString);
				}
				
				// Create the title window; maintain a reference so that the command doesn't get garbage collected until the window is shut
				titleWindow = new TitleWindow();
				titleWindow.styleName = "feedbackTitleWindow";
				titleWindow.title = feedback.title;
				titleWindow.addEventListener(TitleWindowBoundsEvent.WINDOW_MOVING, onWindowMoving);
				
				// Create an XHTMLRichText component and add it to the title window
				var xhtmlRichText:XHTMLRichText = new XHTMLRichText();
				
				// Default to 300 width, variable height unless defined otherwise in the XML
				xhtmlRichText.width = (isNaN(feedback.width)) ? 300 : feedback.width;
				if (!isNaN(feedback.height)) xhtmlRichText.height = feedback.height;
				
				xhtmlRichText.xhtml = xhtml;
				xhtmlRichText.nodeId = "#" + feedback.source;
				xhtmlRichText.addEventListener(XHTMLEvent.CSS_PARSED, onCssParsed);
				
				// #127
				var scroller:Scroller = new Scroller();
				scroller.viewport = xhtmlRichText;
				titleWindow.addElement(scroller);
				
				// This is very hacky, but otherwise the feedback popup can hijack uncommitted textfields and break the tab flow.  There is probably
				// a neater way to do this, but this works and doesn't seem to do any harm.
				setTimeout(addPopupWindow, 150);
			} else {
				log.error("Unable to find feedback source {0}", feedback.source);
			}
		}
		
		private function addPopupWindow():void {
			// Create and centre the popup
			PopUpManager.addPopUp(titleWindow, FlexGlobals.topLevelApplication as DisplayObject, feedback.modal, PopUpManagerChildList.POPUP, FlexGlobals.topLevelApplication.moduleFactory);
			PopUpManager.centerPopUp(titleWindow);
			
			// Listen for the close event so that we can cleanup
			titleWindow.addEventListener(CloseEvent.CLOSE, onClosePopUp);
			
			// Add a keyboard listener so the user can close the feedback window with the keyboard.  This listener needs a brief delay before being
			// added as otherwise its possible to trigger the feedback window with the same key that closes it, hence closing it instantly.
			setTimeout(function():void {
				(FlexGlobals.topLevelApplication as DisplayObject).stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboardDown);
			}, 300);
		}
		
		protected function onCssParsed(event:Event):void {
			var xhtmlRichText:XHTMLRichText = event.target as XHTMLRichText;
			
			xhtmlRichText.removeEventListener(XHTMLEvent.CSS_PARSED, onCssParsed);
			
			var style:CSSComputedStyle = xhtmlRichText.css.style(<feedback class={"feedback titlebar " + ((feedback.answer) ? feedback.answer.markingClass : "")} />);
			if (style.backgroundColor) titleWindow.setStyle("popUpBarColor", style.backgroundColor);
			if (style.opacity) titleWindow.setStyle("popUpBarAlpha", style.opacity);
			if (style.color) titleWindow.setStyle("popUpBarTextColor", style.color);
		}
		
		/**
		 * The escape and enter keys also close the popup
		 * 
		 * @param event
		 */
		protected function onKeyboardDown(event:KeyboardEvent):void {
			if (event.keyCode == Keyboard.ESCAPE || event.keyCode == Keyboard.ENTER)
				onClosePopUp();
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
			titleWindow.removeEventListener(CloseEvent.CLOSE, onClosePopUp);
			titleWindow.removeEventListener(TitleWindowBoundsEvent.WINDOW_MOVING, onWindowMoving);
			(FlexGlobals.topLevelApplication as DisplayObject).stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyboardDown);
			
			PopUpManager.removePopUp(titleWindow);
			titleWindow = null;
			feedback = null;
		}
		
	}
	
}