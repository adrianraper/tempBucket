package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.answer.Feedback;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.textLayout.components.XHTMLRichText;
	
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
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
	
	public class ShowFeedbackCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var titleWindow:TitleWindow;
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var exercise:Exercise = note.getBody().exercise as Exercise;
			var feedback:Feedback = note.getBody().feedback as Feedback;
			
			if (exercise.selectOne("#" + feedback.source)) {
				// Create the title window; maintain a reference so that the command doesn't get garbage collected until the window is shut
				titleWindow = new TitleWindow();
				titleWindow.title = feedback.title;
				
				// Create an XHTMLRichText component and add it to the title window
				var xhtmlRichText:XHTMLRichText = new XHTMLRichText();
				xhtmlRichText.width = 300;
				xhtmlRichText.xhtml = exercise;
				xhtmlRichText.nodeId = "#" + feedback.source;
				
				titleWindow.addElement(xhtmlRichText);
				
				// Create the popup
				PopUpManager.addPopUp(titleWindow, FlexGlobals.topLevelApplication as DisplayObject, true, PopUpManagerChildList.POPUP, FlexGlobals.topLevelApplication.moduleFactory);
				
				PopUpManager.centerPopUp(titleWindow);
				
				// Listen for the close event so that we can cleanup
				titleWindow.addEventListener(CloseEvent.CLOSE, onClosePopUp);
				FlexGlobals.topLevelApplication.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboardDown);
				
			} else {
				log.error("Unable to find feedback source {0}", feedback.source);
			}
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
		 * Close the popup and make all variables eligible for garbage collection
		 * 
		 * @param event
		 */
		protected function onClosePopUp(event:CloseEvent = null):void {
			titleWindow.removeEventListener(CloseEvent.CLOSE, onClosePopUp);
			FlexGlobals.topLevelApplication.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyboardDown);
			
			PopUpManager.removePopUp(titleWindow);
			titleWindow = null;
		}
		
	}
	
}