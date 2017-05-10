﻿/*
Simple Command - PureMVC
*/
package com.clarityenglish.testadmin.controller {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.resultsmanager.RMNotifications;
	import com.clarityenglish.resultsmanager.model.LicenceProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.testadmin.TestAdmin;
	import com.clarityenglish.resultsmanager.Constants;
	import com.clarityenglish.testadmin.ApplicationFacade;
	import com.clarityenglish.testadmin.view.ApplicationMediator;
	import com.clarityenglish.resultsmanager.model.ContentProxy;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.resultsmanager.model.ManageableProxy;
	import com.clarityenglish.resultsmanager.model.ReportProxy;
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
			// gh#1314, gh#372
			if (Application.application.parameters.sessionID) {
				Constants.SESSIONID = Application.application.parameters.sessionID;
			} else {
				Constants.SESSIONID = this.generateSessionId();
			}
			
			// v3.4 Can I also figure out the domain here so that it can be used if necessary?
			Constants.BASE_FOLDER = Application.application.url.replace('TestAdmin.swf','');
			
			// Configure the delegate
			// gh#1314
			RemoteDelegate.setGateway(Constants.AMFPHP_BASE + "gateway.php", { PHPSESSID: Constants.SESSIONID });			
			RemoteDelegate.setService(Constants.AMFPHP_SERVICE);
			
			// Register the copy and login proxies (all other proxies are registered on a successful login)
			facade.registerProxy(new CopyProxy());
			facade.registerProxy(new LoginProxy());
			
			// Register the main mediator
			// gh#1487 hack to work out if we want test admin view or regular management view
			facade.registerMediator(new ApplicationMediator(note.getBody() as TestAdmin, Application.application.parameters.directStart));
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
			
			// Hide followUp for now until fully tested
			Constants.followUp = (Application.application.parameters.followUp);
			
		}
		private function generateSessionId():String {
			// Interleave a timestamp with a random string of letters
			var chars:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
			var numChars:Number = chars.length - 1;
			var buildId:String = '';
			var timeStamp:Date = new Date();
			var timeChars:String = timeStamp.getTime().toString();
			for (var ix:uint = 0; ix < timeChars.length; ix++)
				buildId += timeChars.charAt(ix) + chars.charAt(Math.floor(Math.random() * numChars));
			return buildId;
		}
		
	}
}