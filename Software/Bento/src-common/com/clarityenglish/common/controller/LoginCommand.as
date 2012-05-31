/*
Simple Command - PureMVC
 */
package com.clarityenglish.common.controller {
	import com.clarityenglish.common.events.LoginEvent;
	import com.clarityenglish.common.model.LoginProxy;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
    
	/**
	 * SimpleCommand
	 */
	public class LoginCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var loginEvent:LoginEvent = note.getBody() as LoginEvent;
			
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			loginProxy.login(loginEvent.user, loginEvent.loginOption);
		}
		
	}
}