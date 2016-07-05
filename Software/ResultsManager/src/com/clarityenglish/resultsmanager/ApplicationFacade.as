package com.clarityenglish.resultsmanager {
	import com.clarityenglish.common.CommonNotifications;
	import org.puremvc.as3.interfaces.IFacade;
	import org.puremvc.as3.patterns.facade.Facade;
	import com.clarityenglish.resultsmanager.model.*;
	import com.clarityenglish.resultsmanager.view.*;
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
			
			registerCommand(RMNotifications.STARTUP, StartupCommand);
			registerCommand(CommonNotifications.LOGIN, LoginCommand);
			registerCommand(CommonNotifications.LOGOUT, LogoutCommand);
			registerCommand(CommonNotifications.LOGGED_IN, LoggedInCommand);
			registerCommand(CommonNotifications.LOGGED_OUT, LoggedOutCommand);
			registerCommand(RMNotifications.ADD_GROUP, AddGroupCommand);
			registerCommand(RMNotifications.ADD_USER, AddUserCommand);
			registerCommand(RMNotifications.UPDATE_GROUPS, UpdateGroupsCommand);
			registerCommand(RMNotifications.UPDATE_USERS, UpdateUsersCommand);
			registerCommand(RMNotifications.DELETE_MANAGEABLES, DeleteManageablesCommand);
			registerCommand(RMNotifications.MOVE_MANAGEABLES, MoveManageablesCommand);
			// v3.5 Do not use anymore
			//registerCommand(RMNotifications.ALLOCATE_LICENCES, AllocateLicencesCommand);
			//registerCommand(RMNotifications.UNALLOCATE_LICENCES, UnallocateLicencesCommand);
			registerCommand(RMNotifications.EXPORT_MANAGEABLES, ExportManageablesCommand);
			registerCommand(RMNotifications.ARCHIVE_MANAGEABLES, ArchiveManageablesCommand);
			registerCommand(RMNotifications.IMPORT_MANAGEABLES, ImportManageablesCommand);
			// v3.6.1 Allow moving and importing
			registerCommand(RMNotifications.IMPORT_MOVE_MANAGEABLES, ImportManageablesCommand);
			registerCommand(RMNotifications.UPLOAD_XML, UploadXMLCommand);
			registerCommand(RMNotifications.SET_EXTRA_GROUPS, SetExtraGroupsCommand);
			registerCommand(RMNotifications.SET_CONTENT_VISIBLE, SetContentVisibleCommand);
			registerCommand(RMNotifications.UPDATE_LOGIN_OPTS, UpdateLoginOptsCommand);
			registerCommand(RMNotifications.UPDATE_EMAIL_OPTS, UpdateEmailOptsCommand);
			// v3.4
			registerCommand(RMNotifications.EDIT_EXERCISE, EditInAuthorPlusCommand);
			registerCommand(RMNotifications.MOVE_CONTENT_AFTER, EditedContentCommand);
			registerCommand(RMNotifications.MOVE_CONTENT_BEFORE, EditedContentCommand);
			registerCommand(RMNotifications.INSERT_CONTENT_AFTER, EditedContentCommand);
			registerCommand(RMNotifications.INSERT_CONTENT_BEFORE, EditedContentCommand);
			registerCommand(RMNotifications.COPY_CONTENT_AFTER, EditedContentCommand);
			registerCommand(RMNotifications.COPY_CONTENT_BEFORE, EditedContentCommand);
			registerCommand(RMNotifications.RESET_CONTENT, EditedContentCommand);
			registerCommand(RMNotifications.CHECK_FOLDER, EditedContentCommand);
			// gh#1487
			registerCommand(RMNotifications.UPDATE_TEST_DETAIL, UpdateTestDetailCommand);
			registerCommand(RMNotifications.DELETE_TEST_DETAIL, UpdateTestDetailCommand);
			registerCommand(RMNotifications.ADD_TEST_DETAIL, UpdateTestDetailCommand);
			registerCommand(CommonNotifications.SEND_EMAIL, SendEmailCommand);
			
		}
	}
	
}