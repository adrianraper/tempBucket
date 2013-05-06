/*
Simple Command - PureMVC
 */
package com.clarityenglish.dms.controller {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.DictionaryProxy;
	import com.clarityenglish.dms.model.EmailProxy;
	import com.clarityenglish.dms.Constants;
	import com.clarityenglish.dms.model.AccountProxy;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 */
	public class LoggedInCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var data:Object = note.getBody();
			
			Constants.userID = data.userID.toString();
			Constants.userType = data.userType as Number;
			// v3.6 If I send back database details as well, pick them up here for display
			Constants.dbDetails = data.dbDetails as String;
			
			// v3.0.5 Change status handling
			facade.registerProxy(new DictionaryProxy( [ "accountStatus",
														"accountType",
														"customerType",
														"resellers",
														"termsConditions",
														"products",
														"languageCode",
														"versionCode",
														"loginOption",
														"selfRegisterOption",
														"licenceType"
													  ] ));
			facade.registerProxy(new AccountProxy());
			facade.registerProxy(new EmailProxy());
			
			// EmailProxy doesn't automatically get the templates so do this by hand
			(facade.retrieveProxy(EmailProxy.NAME) as EmailProxy).getEmailTemplates();
			
			// Send another COPY_LOADED notification in case the language has changed (this forces everything to update its copy)
			sendNotification(CommonNotifications.COPY_LOADED);
		}
		
	}
}