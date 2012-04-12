package com.clarityenglish.bento.controller {
	import mx.events.CloseEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.managers.ISystemManager;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	import spark.components.TitleWindow;
	
	public class CloseAllPopUpsCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var systemManager:ISystemManager = note.getBody().systemManager;
			
			// First gather all the popped up title windows into a vector
			var titleWindow:TitleWindow;
			var titleWindows:Vector.<TitleWindow> = new Vector.<TitleWindow>();
			for (var n:uint = 0; n < systemManager.popUpChildren.numChildren; n++) {
				titleWindow = systemManager.popUpChildren.getChildAt(n) as TitleWindow;
				if (titleWindow) titleWindows.push(titleWindow);
			}
			
			// Then go through dispatching CloseEvents on them
			for each (titleWindow in titleWindows)
				titleWindow.dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
	}
	
}