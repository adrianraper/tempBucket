/*
Simple Command - PureMVC
 */
package com.clarityenglish.resultsmanager.controller {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.resultsmanager.RMNotifications;
	import com.clarityenglish.resultsmanager.Constants;
	import com.clarityenglish.resultsmanager.model.LicenceProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.resultsmanager.RMApplication;
	import com.clarityenglish.resultsmanager.ApplicationFacade;
	import com.clarityenglish.resultsmanager.model.ContentProxy;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.resultsmanager.model.ManageableProxy;
	import com.clarityenglish.resultsmanager.model.ReportProxy;
	import com.clarityenglish.resultsmanager.view.ApplicationMediator;
	import com.clarityenglish.common.events.LoginEvent;
	import mx.core.Application;
	import org.davekeen.delegates.RemoteDelegate;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
	import com.clarityenglish.utils.TraceUtils;	
    
	/**
	 * SimpleCommand
	 */
	public class StartupCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			// If the host is defined in the FlashVars then set it
			if (Application.application.parameters.host) Constants.HOST = Application.application.parameters.host;
			
			// If the sessionid is defined in the FlashVars then set it
			if (Application.application.parameters.sessionid) Constants.SESSIONID = Application.application.parameters.sessionid;
			
			// v3.4 Can I also figure out the domain here so that it can be used if necessary?
			Constants.BASE_FOLDER = Application.application.url.replace('ResultsManager.swf','');
			
			// Configure the delegate
			RemoteDelegate.setGateway(Constants.AMFPHP_BASE + "gateway.php");
			RemoteDelegate.setService(Constants.AMFPHP_SERVICE);
			
			// Register the copy and login proxies (all other proxies are registered on a successful login)
			facade.registerProxy(new CopyProxy());
			facade.registerProxy(new LoginProxy());
			
			// Register the main mediator
			facade.registerMediator(new ApplicationMediator(note.getBody() as RMApplication));
			//TraceUtils.myTrace("RM.StartUpCommand.4");
			
			// If the username/password are defined as FlashVars then automate the login
			var username:String = Application.application.parameters.username;
			var password:String = Application.application.parameters.password;
			// v4.3 If you pass in the dbHost as FlashVars, then send that to php too
			// No, this can be done in loginProxy (where we also add rootID if that has been sent)
			//var dbHost:uint = Application.application.parameters.dbHost;
			
			if (username && password) sendNotification(CommonNotifications.LOGIN, new LoginEvent(LoginEvent.LOGIN, username, password));
			
			// If directStart is defined, pick that up
			var directStart:String = Application.application.parameters.directStart;
			if (directStart) {
				TraceUtils.myTrace("startupcommand, directStart=" + directStart);
				sendNotification(RMNotifications.DIRECT_START, directStart);
			}
			
		}
		
	}
}