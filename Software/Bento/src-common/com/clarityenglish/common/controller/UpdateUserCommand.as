/*
Simple Command - PureMVC
 */
package com.clarityenglish.common.controller {
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.resultsmanager.vo.manageable.User;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
    
	/**
	 * SimpleCommand
	 */
	public class UpdateUserCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			loginProxy.updateUser(note.getBody() as Object);
		}
		
	}
}