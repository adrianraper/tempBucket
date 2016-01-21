package com.clarityenglish.ielts.controller {
	import com.clarityenglish.ielts.view.title.UpgradeView;
	
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
	
	public class IELTSUpgradeWindowShowCommand extends SimpleCommand {
		
		/**
		 * DEPRECATED July 2012
		 */
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var titleWindow:TitleWindow;
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			titleWindow = new TitleWindow();
			titleWindow.styleName = "noTitleWindow";
			
			var view:UpgradeView = new UpgradeView();
			titleWindow.addElement(view);
			
			// Create and centre the popup
			PopUpManager.addPopUp(titleWindow, FlexGlobals.topLevelApplication as DisplayObject, true, PopUpManagerChildList.POPUP, FlexGlobals.topLevelApplication.moduleFactory);
			PopUpManager.centerPopUp(titleWindow);
			
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
		
		/*error|ErrorView #teacherButton {
			skinClass: ClassReference("skins.ielts.login.LoginButtonSkin");
		}
		error|ErrorView #candidateButton {
			skinClass: ClassReference("skins.ielts.login.LoginButtonSkin");
		}*/
		
	}
}
