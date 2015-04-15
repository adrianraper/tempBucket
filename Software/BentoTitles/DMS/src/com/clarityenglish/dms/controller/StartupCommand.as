/*
Simple Command - PureMVC
 */
package com.clarityenglish.dms.controller {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.events.LoginEvent;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.dms.Constants;
	import com.clarityenglish.dms.DMSApplication;
	import com.clarityenglish.dms.view.ApplicationMediator;
	import mx.core.Application;
	import org.davekeen.delegates.RemoteDelegate;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 */
	public class StartupCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			// If the host is defined in the FlashVars then set it
			// gh#1190 This will not be sent, let Constants sort it out
			if (Application.application.parameters.host) Constants.HOST = Application.application.parameters.host;
			
			// If the sessionid is defined in the FlashVars then set it
			if (Application.application.parameters.sessionid) Constants.SESSIONID = Application.application.parameters.sessionid;
			
			// Get the SWF bridge id (used for generating RSA codes with the localconnectionrsa.swf movie)
			Constants.SWFBRIDGEID = Application.application.parameters.swfbridgeid;
			
			// Configure the delegate
			RemoteDelegate.setGateway(Constants.AMFPHP_BASE + "gateway.php");
			RemoteDelegate.setService(Constants.AMFPHP_SERVICE);
			
			// Register the copy and login proxies (all other proxies are registered on a successful login)
			facade.registerProxy(new CopyProxy());
			facade.registerProxy(new LoginProxy());
			
			// Register the main mediator
			facade.registerMediator(new ApplicationMediator(note.getBody() as DMSApplication));
			
			// If the username/password are defined as FlashVars then automate the login
			var username:String = Application.application.parameters.username;
			var password:String = Application.application.parameters.password;
			
			// In debug mode automatically log in as davedms/password
			if (Constants.DEBUG_MODE) {
				//username = "dmsviewer";
				username = "davedms";
				password = "password";
			}
			
			if (username && password) sendNotification(CommonNotifications.LOGIN, new LoginEvent(LoginEvent.LOGIN, username, password));

		}
		
	}
}