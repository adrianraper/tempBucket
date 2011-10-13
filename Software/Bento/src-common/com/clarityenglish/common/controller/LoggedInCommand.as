/*
Simple Command - PureMVC
*/
package com.clarityenglish.common.controller {
	import com.clarityenglish.common.CommonNotifications;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
	
	/**
	 * SimpleCommand
	 */
	public class LoggedInCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var data:Object = note.getBody();
			
			// AR We will get back the data for this user, their group and the title (account).
			// There is additional data for licence attributes and ...
			// Is this right, using the proxy to store the model data?
			// Yes it would be fine, but probably overkill. Can use the LoginProxy to store this too.
			// Or perhaps it would all go nicely in ConfigProxy?
			
			//facade.registerProxy(new UserProxy(data.user));
			//facade.registerProxy(new AccountProxy(data.account));
			//facade.registerProxy(new GroupProxy(data.group));
			
			// Send another COPY_LOADED notification in case the language has changed (this forces everything to update its copy)
			sendNotification(CommonNotifications.COPY_LOADED);
		}
		
	}
}