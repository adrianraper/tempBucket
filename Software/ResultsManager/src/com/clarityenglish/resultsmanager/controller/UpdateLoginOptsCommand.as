/*
Simple Command - PureMVC
 */
package com.clarityenglish.resultsmanager.controller {
	import com.clarityenglish.resultsmanager.model.LoginOptsProxy;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
	import com.clarityenglish.utils.TraceUtils;
    
	/**
	 * SimpleCommand
	 */
	public class UpdateLoginOptsCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var loginOpts:Object = note.getBody();
			
			var loginOptsProxy:LoginOptsProxy = facade.retrieveProxy(LoginOptsProxy.NAME) as LoginOptsProxy;
			loginOptsProxy.setLoginTypeLoginOpt(loginOpts.loginTypeOption);
			loginOptsProxy.setAnonLoginAllowed(loginOpts.anonLoginOption);
			loginOptsProxy.setPasswordRequired(loginOpts.passwordRequiredOption);
			
			loginOptsProxy.setCanUnregisteredUsersLogin(loginOpts.unregisteredLearnersOption);
			//TraceUtils.myTrace("UpdateLoginOptsCommand.loginOpts.unregisteredLearnersOption=" + loginOpts.unregisteredLearnersOption);
			for each (var selfRegisterObj:Object in loginOpts.selfRegisterArray)
				loginOptsProxy.setRequiredSelfRegisterFields(selfRegisterObj.field, selfRegisterObj.enabled);
			
			loginOptsProxy.saveLoginOpts();
		}
		
	}
}