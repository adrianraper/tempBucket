/*
Simple Command - PureMVC
 */
package com.clarityenglish.testadmin.controller {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.EmailProxy;
	import com.clarityenglish.testadmin.ApplicationFacade;
	import com.clarityenglish.resultsmanager.Constants;
	import com.clarityenglish.resultsmanager.model.ContentProxy;
	import com.clarityenglish.resultsmanager.model.EmailOptsProxy;
	import com.clarityenglish.resultsmanager.model.LicenceProxy;
	import com.clarityenglish.resultsmanager.model.LoginOptsProxy;
	import com.clarityenglish.resultsmanager.model.ManageableProxy;
	import com.clarityenglish.resultsmanager.model.ReportProxy;
	import com.clarityenglish.resultsmanager.model.TestProxy;
	import com.clarityenglish.resultsmanager.model.UploadProxy;
	import com.clarityenglish.resultsmanager.model.UsageProxy;
	import com.clarityenglish.utils.TraceUtils;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;

	/**
	 * SimpleCommand
	 */
	public class LoggedInCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var data:Object = note.getBody();
			
			// Maybe there should be a better object to keep information about the logged in user/account
			Constants.userID = data.userID.toString();
			Constants.userType = data.userType as Number;
			Constants.noStudents = data.noStudents as Boolean;
			Constants.manageablesCount = data.manageablesCount as Number;
			Constants.prefix = data.prefix as String;
			Constants.groupID = data.groupID.toString();
			Constants.parentGroupIDs = data.parentGroups;
			// TODO This is terrible, but just until we work out how to do a preview like start of AP
			Constants.userName = data.userName as String;
			Constants.password = data.password as String;
			// v3.5.1 For displaying
			Constants.accountName = data.accountName as String;
			// v3.5 For checking if you even try to add new usertypes
			Constants.maxTeachers = data.maxTeachers as Number;
			Constants.maxAuthors = data.maxAuthors as Number;
			Constants.maxReporters = data.maxReporters as Number;
			// v3.6 For RM licence type
			Constants.licenceType = data.licenceType as Number;
			
			//TraceUtils.myTrace("prefix is "+Constants.prefix);
			//TraceUtils.myTrace("loggedInCommand for " + Constants.userID + " as " + Constants.userType + " called " + Constants.userName); // + " data.userID=" + data.userID);
			//TraceUtils.myTrace("member of group(s) " + Constants.groupID.toString() + "=" + Constants.parentGroupIDs.toString());
			
			// Configure the result manager proxies
			facade.registerProxy(new UploadProxy());
			facade.registerProxy(new ManageableProxy());
			facade.registerProxy(new ContentProxy());
			facade.registerProxy(new ReportProxy());
			facade.registerProxy(new LicenceProxy());
			facade.registerProxy(new UsageProxy());
			facade.registerProxy(new LoginOptsProxy());
			facade.registerProxy(new EmailOptsProxy());
			facade.registerProxy(new TestProxy());
			facade.registerProxy(new EmailProxy());
			
			// Send another COPY_LOADED notification in case the language has changed (this forces everything to update its copy)
			sendNotification(CommonNotifications.COPY_LOADED);
		}
		
	}
}