package com.clarityenglish.resultsmanager.view.management.ui {
	import com.clarityenglish.common.view.interfaces.CopyReceiver;
	import com.clarityenglish.common.vo.content.Content;
	import com.clarityenglish.resultsmanager.Constants;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.resultsmanager.view.management.events.ManageableEvent;
	import com.clarityenglish.resultsmanager.view.management.events.ReportEvent;
	import com.clarityenglish.resultsmanager.view.management.events.ContentEvent;
	import com.clarityenglish.common.events.SearchEvent;
	import com.clarityenglish.resultsmanager.view.shared.events.SelectEvent;
	import com.clarityenglish.common.vo.manageable.Group;
	import com.clarityenglish.common.vo.manageable.Manageable;
	import com.clarityenglish.common.vo.manageable.User;
	import eu.orangeflash.managers.CMManager;
	import flash.display.InteractiveObject;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import org.davekeen.utils.ClassUtils;
	import com.clarityenglish.utils.TraceUtils;
	import nl.demonsters.debugger.MonsterDebugger;
	
	/**
	 * ...
	 * @author DefaultUser (Tools -> Custom Arguments...)
	 */
	public class ManageableCMManager extends CMManager implements CopyReceiver {
		
		private var generateReportMenuItem:ContextMenuItem;
		
		private var addGroupMenuItem:ContextMenuItem;
		private var addTeacherMenuItem:ContextMenuItem;
		private var addReporterMenuItem:ContextMenuItem;
		private var addAuthorMenuItem:ContextMenuItem;
		private var addLearnerMenuItem:ContextMenuItem;
		private var assignClassesMenuItem:ContextMenuItem;
		
		private var selectExpiredUsersMenuItem:ContextMenuItem;
		
		private var searchMenuItem:ContextMenuItem;
		//private var clearSearchMenuItem:ContextMenuItem;
		
		private var exportMenuItem:ContextMenuItem;
		//private var archiveMenuItem:ContextMenuItem;
		private var importMenuItem:ContextMenuItem;
		
		private var deleteMenuItem:ContextMenuItem;
		private var detailsMenuItem:ContextMenuItem;
		
		// v3.4 To check that a group is clear for editing
		//private var checkEditingClarityContentMenuItem:ContextMenuItem;
		private var resetEditingClarityContentMenuItem:ContextMenuItem;
		//private var testMenuItem:ContextMenuItem;
		
		public function ManageableCMManager(target:InteractiveObject) {
			// Note that this second parameter is for hideBuiltInContextItems
			super(target, true);
			
			generateReportMenuItem = add("", function(e:Event):void { dispatchEvent(new ReportEvent(ReportEvent.SHOW_REPORT_WINDOW, null, null, true)); } );
			addGroupMenuItem = add("", function(e:Event):void { dispatchEvent(new ManageableEvent(ManageableEvent.ADD_GROUP, null, null, true)); }, true );
			addTeacherMenuItem = add("", function(e:Event):void { dispatchEvent(new ManageableEvent(ManageableEvent.ADD_TEACHER, null, null, true)); } );
			addReporterMenuItem = add("", function(e:Event):void { dispatchEvent(new ManageableEvent(ManageableEvent.ADD_REPORTER, null, null, true)); } );
			// v3.3 There really isn't any such thing as an author!
			// v3.4 Now there is
			addAuthorMenuItem = add("", function(e:Event):void { dispatchEvent(new ManageableEvent(ManageableEvent.ADD_AUTHOR, null, null, true)); } );
			addLearnerMenuItem = add("", function(e:Event):void { dispatchEvent(new ManageableEvent(ManageableEvent.ADD_LEARNER, null, null, true)); } );
			assignClassesMenuItem = add("", function(e:Event):void { dispatchEvent(new ManageableEvent(ManageableEvent.ASSIGN_CLASSES, null, null, true)); } );
			selectExpiredUsersMenuItem = add("", function(e:Event):void { dispatchEvent(new SelectEvent(SelectEvent.EXPIRED_USERS, null, true)); }, true );
			searchMenuItem = add("", function(e:Event):void { dispatchEvent(new SearchEvent(SearchEvent.SEARCH, null, true)); }, true );
			//clearSearchMenuItem = add("", function(e:Event):void { dispatchEvent(new SearchEvent(SearchEvent.CLEAR_SEARCH, null, true)); }, false, false );
			exportMenuItem = add("", function(e:Event):void { dispatchEvent(new ManageableEvent(ManageableEvent.EXPORT, null, null, true)); }, true );
			//archiveMenuItem = add("", function(e:Event):void { dispatchEvent(new ManageableEvent(ManageableEvent.ARCHIVE, null, null, true)); } );
			importMenuItem = add("", function(e:Event):void { dispatchEvent(new ManageableEvent(ManageableEvent.IMPORT, null, null, true)); } );
			deleteMenuItem = add("", function(e:Event):void { dispatchEvent(new ManageableEvent(ManageableEvent.DELETE, null, null, true)); }, true );
			detailsMenuItem = add("", function(e:Event):void { dispatchEvent(new ManageableEvent(ManageableEvent.DETAILS, null, null, true)); } );
			resetEditingClarityContentMenuItem = add("", function(e:Event):void { dispatchEvent(new ContentEvent(ContentEvent.RESET_CONTENT, null, null, null, null, true)); }, true );
			// v3.5 This is an odd menu entry, what's the point?
			//checkEditingClarityContentMenuItem = add("", function(e:Event):void { dispatchEvent(new ContentEvent(ContentEvent.CHECK_FOLDER, null, null, null, null, true)); } );
		}
		
		public function setCopyProvider(copyProvider:CopyProvider):void {
			generateReportMenuItem.caption = copyProvider.getCopyForId("generateReportMenuItem");
			addGroupMenuItem.caption = copyProvider.getCopyForId("addGroupMenuItem");
			addTeacherMenuItem.caption = copyProvider.getCopyForId("addTeacherMenuItem");
			addReporterMenuItem.caption = copyProvider.getCopyForId("addReporterMenuItem");
			addAuthorMenuItem.caption = copyProvider.getCopyForId("addAuthorMenuItem");
			addLearnerMenuItem.caption = copyProvider.getCopyForId("addLearnerMenuItem");
			assignClassesMenuItem.caption = copyProvider.getCopyForId("assignClassesMenuItem");
			selectExpiredUsersMenuItem.caption = copyProvider.getCopyForId("selectExpiredUsersMenuItem");
			searchMenuItem.caption = copyProvider.getCopyForId("searchMenuItem");
			// v3.4 I have hit my limit on items, so drop 'clear search' as there is a button for this.
			// Actually I'm not sure that was the problem, but anyway, this is a needles CM item
			//clearSearchMenuItem.caption = copyProvider.getCopyForId("clearSearchMenuItem");
			exportMenuItem.caption = copyProvider.getCopyForId("exportMenuItem");
			//archiveMenuItem.caption = copyProvider.getCopyForId("archiveMenuItem");
			importMenuItem.caption = copyProvider.getCopyForId("importMenuItem");
			// v3.4 The Flash Player 10.1 release adds "Delete..." to the list of captions that can't be displayed in a contextMenu
			// It used to be allowed. So I am using "Delete ..." to get round this for now.
			deleteMenuItem.caption = copyProvider.getCopyForId("deleteMenuItem");
			detailsMenuItem.caption = copyProvider.getCopyForId("detailsMenuItem");
			resetEditingClarityContentMenuItem.caption = copyProvider.getCopyForId("resetEditingClarityContentMenuItem");
			//checkEditingClarityContentMenuItem.caption = copyProvider.getCopyForId("checkEditingClarityContentMenuItem");
		}
		
		public function configureMenuItems():void {
			//MonsterDebugger.trace(this, "configure");
			// v3.4 I had testMenuItem.visible set here and it crashed the function silently. Caused all sorts of mischief
			// as selectedManageable was not working with related events.
			addTeacherMenuItem.visible = addReporterMenuItem.visible
										= addAuthorMenuItem.visible
										= assignClassesMenuItem.visible
										= Constants.userType == User.USER_TYPE_ADMINISTRATOR;
			
			// v3.5 Also block the add user types if they have 0 licences
			if (Constants.maxReporters <=0) addReporterMenuItem.visible=false;
			if (Constants.maxTeachers <=0) addTeacherMenuItem.visible=false;
			if (Constants.maxAuthors <= 0) addAuthorMenuItem.visible = false;
			
			//					   = archiveMenuItem.visible
			importMenuItem.visible = exportMenuItem.visible
								   = deleteMenuItem.visible
								   = addGroupMenuItem.visible
								   = addLearnerMenuItem.visible
								   = selectExpiredUsersMenuItem.visible
								   = Constants.userType != User.USER_TYPE_REPORTER;
								   
			// v3.4
			//checkEditingClarityContentMenuItem.visible = resetEditingClarityContentMenuItem.visible
			//						= (Constants.userType == User.USER_TYPE_AUTHOR ||
			//							Constants.userType == User.USER_TYPE_ADMINISTRATOR);
								   
			// If we are in non-student mode then disable a few more menu items
			// AR Must stop reports being generated in this mode too. Although it would be nicer to disable them not totally hide.
			if (Constants.noStudents && addLearnerMenuItem.visible) addLearnerMenuItem.enabled = false;
			if (Constants.noStudents && generateReportMenuItem.visible) generateReportMenuItem.enabled = false;
			if (Constants.noStudents && selectExpiredUsersMenuItem.visible) selectExpiredUsersMenuItem.enabled = false;
			//addLearnerMenuItem.visible	= selectExpiredUsersMenuItem.visible 
			//							= generateReportMenuItem.visible
			//							= !Constants.noStudents;
		}
		
		public function enableBySelectedManageables(selectedItems:Array):void {
			// Set visible menu items based on user type.  Its not really necessary for this to happen everytime, but there
			// isn't really any other obvious place to put it and its a cheap operation anyway.
			//MonsterDebugger.trace(this, "manageableCMManager");
			//MonsterDebugger.trace(this, selectedItems.length);
			configureMenuItems();
			if (selectedItems.length == 0) {
				// If no item is selected in the tree disable the menu
				//							   = archiveMenuItem.enabled
				//							   = checkEditingClarityContentMenuItem.enabled
				generateReportMenuItem.enabled = addGroupMenuItem.enabled
											   = addAuthorMenuItem.enabled
											   = addTeacherMenuItem.enabled
											   = addReporterMenuItem.enabled
											   = addLearnerMenuItem.enabled
											   = assignClassesMenuItem.enabled
											   = searchMenuItem.enabled
											   = exportMenuItem.enabled
											   = importMenuItem.enabled
											   = detailsMenuItem.enabled
											   = resetEditingClarityContentMenuItem.enabled
											   = deleteMenuItem.enabled
											   = false;
			} else if (selectedItems.length > 1) {
				//							   = checkEditingClarityContentMenuItem.enabled
				generateReportMenuItem.enabled = addGroupMenuItem.enabled
											   = addAuthorMenuItem.enabled
											   = addTeacherMenuItem.enabled
											   = addReporterMenuItem.enabled
											   = addLearnerMenuItem.enabled
											   = assignClassesMenuItem.enabled
											   = searchMenuItem.enabled
											   = importMenuItem.enabled
											   = resetEditingClarityContentMenuItem.enabled
											   = false;
				
				//exportMenuItem.enabled = archiveMenuItem.enabled = true;
				exportMenuItem.enabled = true;
				
				// Can't delete yourself
				var deleteEnabled:Boolean = true;
				for each (var manageable:Manageable in selectedItems) {
					// v3.4 Multi-group users
					//if (manageable is User && (manageable as User).id == Constants.userID) {
					if (manageable is User && (manageable as User).userID == Constants.userID) {
						deleteEnabled = false;
						break;
					}
				}
				// TODO: This should be as complex as the single deletion below.
				deleteMenuItem.enabled = deleteEnabled;
				
				// Reports can be generated on multiple manageables if they are all groups
				generateReportMenuItem.enabled = (ClassUtils.checkObjectClasses(selectedItems) == Group);
				
				// Details can be edited on multiple manageables if they are all users
				// However, if the multiple users contains a teacher and the logged in user is a teacher we can't edit details (ticket #73)
				// repeat for authors too (should be a bit better than this)
				detailsMenuItem.enabled = (ClassUtils.checkObjectClasses(selectedItems) == User &&
										   !(Constants.userType == User.USER_TYPE_TEACHER && User.containsUserOfType(selectedItems, User.USER_TYPE_TEACHER)) &&
										   !(Constants.userType == User.USER_TYPE_AUTHOR && User.containsUserOfType(selectedItems, User.USER_TYPE_AUTHOR)));
				
			} else {
				// If a group is selected enable the 'add' menu items
				// AR also make selectedExpiredUsers a group only function
				var selectedItem:Manageable = selectedItems[0] as Manageable;

				//						 = checkEditingClarityContentMenuItem.enabled
				addGroupMenuItem.enabled = addTeacherMenuItem.enabled
										 = addAuthorMenuItem.enabled
										 = addReporterMenuItem.enabled
										 = addLearnerMenuItem.enabled
										 = selectExpiredUsersMenuItem.enabled
										 = resetEditingClarityContentMenuItem.enabled
										 = (selectedItem is Group);
				
				// Reports, details, delete and export are always enabled when something is selected
				// AR I don't want to generate reports on teachers etc, just students (and groups).
				// If a teacher is part of a group report, well never mind. The SQL will filter out their results.
				//generateReportMenuItem.enabled = true;
				if (selectedItem is User) {
					if ((selectedItem as User).userType == User.USER_TYPE_STUDENT) {
						generateReportMenuItem.enabled = true;
					} else {
						generateReportMenuItem.enabled = false;
					}
				} else {
					generateReportMenuItem.enabled = true;
				}
				//detailsMenuItem.enabled = exportMenuItem.enabled = archiveMenuItem.enabled = true;
				detailsMenuItem.enabled = exportMenuItem.enabled = true;
				
				// Everyone can see and change their own details (though not their expiry date)
				// Be careful when doing (selectedItem as User) as this will crash if selectedItem is not user!
				//TraceUtils.myTrace("selected.id=" + selectedItem.id + " selected.type=" + (selectedItem as User).userType + " your.id=" + Constants.userID + " your.type=" + Constants.userType);
				// v3.4 Multi-group users
				//if (selectedItem is User && Constants.userID == selectedItem.id) {
				// Following is all about blocking details of users, if you are looking at a group just go ahead
				if (selectedItem is User) {
					if (Constants.userID == (selectedItem as User).userID) {
						//TraceUtils.myTrace("you clicked on yourself, see details");
						detailsMenuItem.enabled = true;
					} else {
						// Reporters and authors can't see anyone else's details
						// v3.4 No, authors are pretty powerful. Also, reporters should be able to see group details (for what its worth)
						//if ((Constants.userType == User.USER_TYPE_REPORTER) || (Constants.userType == User.USER_TYPE_AUTHOR)) {
						if ((Constants.userType == User.USER_TYPE_REPORTER)) {
							//TraceUtils.myTrace("you are reporter, can't see user details");
							detailsMenuItem.enabled = false;
						} else {
							// No-one can see the admin details (except themselves)
							if ((selectedItem as User).userType == User.USER_TYPE_ADMINISTRATOR) {
								//TraceUtils.myTrace("no-one sees admin");
								detailsMenuItem.enabled = false;
							} else {
								// Teachers and authors can't get details on other teachers and authors (ticket #73)
								//if ((Constants.userType == User.USER_TYPE_TEACHER && (selectedItem as User).userType == User.USER_TYPE_TEACHER)) {
								if ((Constants.userType == User.USER_TYPE_TEACHER ||
									 Constants.userType == User.USER_TYPE_AUTHOR) && ((selectedItem as User).userType == User.USER_TYPE_TEACHER ||
																						(selectedItem as User).userType == User.USER_TYPE_AUTHOR)) {
									//TraceUtils.myTrace("you are teacher/author, can't see another teacher/author");
									detailsMenuItem.enabled = false;
								}
							}
						}
					}			
				}
				// Can't delete yourself
				// v3.4 Multi-group users
				//deleteMenuItem.enabled = (selectedItem is Group || (selectedItem is User && Constants.userID != selectedItem.id));
				// Start with the assumption that you can't delete this
				deleteMenuItem.enabled = false;

				// A reporter shouldn't be able to delete anything
				if (Constants.userType == User.USER_TYPE_REPORTER) {
					//deleteMenuItem.enabled = false;
				} else {
					// Teachers and authors can't delete other teachers and authors. Can they delete reporters? I suppose not.
					// No-one can delete themselves
					if (selectedItem is User && Constants.userID == (selectedItem as User).userID) {
						//deleteMenuItem.enabled = false;
					// Administrator can delete anything
					} else if (Constants.userType == User.USER_TYPE_ADMINISTRATOR) {
						deleteMenuItem.enabled = true;
					// Teachers and authors can delete any group
					} else if (Constants.userType == User.USER_TYPE_TEACHER || Constants.userType == User.USER_TYPE_AUTHOR) {
						if (selectedItem is Group) {
							deleteMenuItem.enabled = true;
						} else {
							// and they can delete any learner, but no-one else
							if (selectedItem is User && (selectedItem as User).userType == User.USER_TYPE_STUDENT) {
								deleteMenuItem.enabled = true;
							}
						}
					}
					//deleteMenuItem.enabled = (selectedItem is Group || (selectedItem is User && Constants.userID != (selectedItem as User).userID));
				}

				//TraceUtils.myTrace("delete menu item is enabled=" + deleteMenuItem.enabled + " and visible=" + deleteMenuItem.visible);
				
				// Things you can just do on groups
				searchMenuItem.enabled = importMenuItem.enabled	= (selectedItem is Group);
				
				// You can assign classes to teachers, reporters and authors
				assignClassesMenuItem.enabled = ((selectedItem is User) && ((selectedItem as User).userType == User.USER_TYPE_TEACHER ||
																			(selectedItem as User).userType == User.USER_TYPE_REPORTER ||
																			(selectedItem as User).userType == User.USER_TYPE_AUTHOR));
			}
		}
		
		/**
		 * This method is called when search is turned on or off so we know whether or not to enabled the Clear search button
		 * 
		 * @param	searchActive Whether or not search is currently active
		 */
		public function setIsSearchActive(searchActive:Boolean):void {
			//clearSearchMenuItem.enabled = searchActive;
		}
		
	}
	
}