package com.clarityenglish.ielts.controller {
	import com.clarityenglish.common.CommonNotifications;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class LoggedInCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			// Put the user/account data that came back into - where??
			var data:Object = note.getBody();
			trace(data.userID.toString());

			// Send another COPY_LOADED notification in case the language has changed (this forces everything to update its copy)
			sendNotification(CommonNotifications.COPY_LOADED);
		}
		
	}
}
