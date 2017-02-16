package com.clarityenglish.testadmin {
	import com.clarityenglish.resultsmanager.RMNotifications;
	import com.clarityenglish.common.CommonNotifications;
	import org.puremvc.as3.interfaces.IFacade;
	import org.puremvc.as3.patterns.facade.Facade;
	import com.clarityenglish.resultsmanager.model.*;
	import com.clarityenglish.testadmin.view.*;
	import com.clarityenglish.testadmin.controller.*;
	import com.clarityenglish.resultsmanager.controller.*;
	import com.clarityenglish.common.controller.*;
	
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
			
			registerCommand(RMNotifications.STARTUP, com.clarityenglish.testadmin.controller.StartupCommand);
			registerCommand(CommonNotifications.LOGIN, LoginCommand);
			registerCommand(CommonNotifications.LOGOUT, LogoutCommand);
			registerCommand(CommonNotifications.LOGGED_IN, com.clarityenglish.testadmin.controller.LoggedInCommand);
			registerCommand(CommonNotifications.LOGGED_OUT, LoggedOutCommand);
			registerCommand(RMNotifications.ADD_GROUP, AddGroupCommand);
			registerCommand(RMNotifications.ADD_USER, AddUserCommand);
			registerCommand(RMNotifications.UPDATE_GROUPS, UpdateGroupsCommand);
			registerCommand(RMNotifications.UPDATE_USERS, UpdateUsersCommand);
			registerCommand(RMNotifications.DELETE_MANAGEABLES, DeleteManageablesCommand);
			registerCommand(RMNotifications.MOVE_MANAGEABLES, MoveManageablesCommand);
			// v3.5 Do not use anymore
			registerCommand(RMNotifications.IMPORT_MANAGEABLES, ImportManageablesCommand);
			// v3.6.1 Allow moving and importing
			registerCommand(RMNotifications.IMPORT_MOVE_MANAGEABLES, ImportManageablesCommand);
			// gh#1487
			registerCommand(RMNotifications.UPDATE_TEST, UpdateTestCommand);
			registerCommand(RMNotifications.DELETE_TEST, UpdateTestCommand);
			registerCommand(RMNotifications.ADD_TEST, UpdateTestCommand);
			registerCommand(CommonNotifications.SEND_EMAIL, SendEmailCommand);
			// ctp#214
			registerCommand(CommonNotifications.PREVIEW_EMAIL, SendEmailCommand);
			
		}
	}
	
}