/*
Simple Command - PureMVC
 */
package com.clarityenglish.progressWidget.controller {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.progressWidget.Constants;
	import com.clarityenglish.progressWidget.model.ProgressProxy;
	import com.clarityenglish.progressWidget.model.ContentProxy;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
	import com.clarityenglish.utils.TraceUtils;		
			
	/**
	 * SimpleCommand
	 */
	public class LoggedInCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var data:Object = note.getBody();
			
			// Pick up data about the logged in user. If we have lots of data, it would be better to have 
			// a user object, not to add lots of constants.
			Constants.userID = data.userID.toString();
			Constants.userType = data.userType as Number;
			
			// What objects am I going to deal with in this application?
			facade.registerProxy(new ContentProxy());
			facade.registerProxy(new ProgressProxy());
			
			// Send another COPY_LOADED notification in case the language has changed (this forces everything to update its copy)
			sendNotification(CommonNotifications.COPY_LOADED);
		}
		
	}
}