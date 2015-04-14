package com.clarityenglish.dms {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.controller.LoginCommand;
	import com.clarityenglish.common.controller.LogoutCommand;
	import org.puremvc.as3.interfaces.IFacade;
	import org.puremvc.as3.patterns.facade.Facade;
	import com.clarityenglish.dms.model.*;
	import com.clarityenglish.dms.view.*;
	import com.clarityenglish.dms.controller.*;
	
	/**
	* ...
	* @author Dave Keen
	*/
	public class ApplicationFacade extends Facade implements IFacade {
		// Notification name constants
		
		public static function getInstance():ApplicationFacade {
			if (instance == null) instance = new ApplicationFacade();
			return instance as ApplicationFacade;
		}
		
		// Register commands with the controller
		override protected function initializeController():void {
			super.initializeController();
			
			registerCommand(DMSNotifications.STARTUP, StartupCommand);
			registerCommand(CommonNotifications.LOGIN, LoginCommand);
			registerCommand(CommonNotifications.LOGOUT, LogoutCommand);
			registerCommand(CommonNotifications.LOGGED_IN, LoggedInCommand);
			registerCommand(CommonNotifications.LOGGED_OUT, LoggedOutCommand);
			registerCommand(DMSNotifications.ADD_ACCOUNT, AddAccountCommand);
			registerCommand(DMSNotifications.UPDATE_ACCOUNTS, UpdateAccountsCommand);
			registerCommand(DMSNotifications.DELETE_ACCOUNTS, DeleteAccountsCommand);
			registerCommand(DMSNotifications.ARCHIVE_ACCOUNTS, ArchiveAccountsCommand);
			registerCommand(DMSNotifications.CHANGE_EMAIL_TO_LIST, ChangeEmailToListCommand);
			registerCommand(DMSNotifications.SHOW_IN_RESULTS_MANAGER, ShowInResultsManagerCommand);
		}
		
	}
	
}