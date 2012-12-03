/*
Simple Command - PureMVC
 */
package com.clarityenglish.common.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.common.model.LoginProxy;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
    
	/**
	 * SimpleCommand
	 */
	public class LogoutCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			loginProxy.logout();
			
			sendNotification(BBNotifications.BENTO_RESET); // #61
		}
		
	}
}