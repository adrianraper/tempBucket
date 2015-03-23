/*
Simple Command - PureMVC
 */
package com.clarityenglish.common.controller {
	import com.clarityenglish.common.events.LoginEvent;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.common.vo.config.Config;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
    
	/**
	 * SimpleCommand
	 */
	public class LoginCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var loginEvent:LoginEvent = note.getBody() as LoginEvent;
			
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var config:Config = configProxy.getConfig();
			if (loginEvent.selectedProductCode) {
				config.productCode = loginEvent.selectedProductCode; // Change the product code here to the user selected one.
				config.paths.menuFilename = config.configFilename; // Reset the menu file name to the string like menu-{productCode}-{productVersion} otherwise it won't change.
				config.buildMenuFilename();
			}
			loginProxy.login(loginEvent.user, loginEvent.loginOption, loginEvent.verified, loginEvent.demoVersion);
		}
		
	}
}