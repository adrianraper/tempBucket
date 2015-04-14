/*
Simple Command - PureMVC
 */
package com.clarityenglish.progressWidget.controller {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.events.LoginEvent;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.progressWidget.model.ContentProxy;
	import com.clarityenglish.progressWidget.model.ProgressProxy;
	import com.clarityenglish.progressWidget.Constants;
	import com.clarityenglish.progressWidget.PWApplication;
	import com.clarityenglish.progressWidget.ApplicationFacade;
	import com.clarityenglish.progressWidget.view.ApplicationMediator;
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
			
			// Configure the delegate
			RemoteDelegate.setGateway(Constants.AMFPHP_BASE + "gateway.php");
			RemoteDelegate.setService(Constants.AMFPHP_SERVICE);
			
			// Register the main mediator
			facade.registerMediator(new ApplicationMediator(note.getBody() as PWApplication));
			
			// Register the copy proxy - common to all paths
			facade.registerProxy(new CopyProxy());
			
			// TraceUtils.myTrace("userID=" + Application.application.parameters.userID);
			// TraceUtils.myTrace("rootID=" + Application.application.parameters.rootID);
			// TraceUtils.myTrace("praductCode=" + Application.application.parameters.productCode);
			// TraceUtils.myTrace("env=" + Application.application.parameters.env);
			// If the userID, rootID and productCode are all sent in FlashVars, then there is no login required.
			if (Application.application.parameters.userID && Application.application.parameters.rootID && Application.application.parameters.productCode) {
				Constants.userID = Application.application.parameters.userID.toString();
			
				// TraceUtils.myTrace("passed userID=" + Constants.userID + " so skip login");
				// What objects am I going to deal with in this application?
				facade.registerProxy(new ContentProxy());
				facade.registerProxy(new ProgressProxy());
				
			} else {
				// Register the login proxies (all other proxies are registered on a successful login)
				facade.registerProxy(new LoginProxy());
				
				// If the username/password are defined as FlashVars then automate the login
				var username:String = Application.application.parameters.username;
				var password:String = Application.application.parameters.password;
				// TraceUtils.myTrace("go to login for " + Application.application.parameters.username);
				
				if (username && password) sendNotification(CommonNotifications.LOGIN, new LoginEvent(LoginEvent.LOGIN, username, password));
			}
		}
		
	}
}