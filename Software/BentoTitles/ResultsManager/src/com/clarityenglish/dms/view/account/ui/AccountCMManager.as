﻿package com.clarityenglish.dms.view.account.ui {
	import com.clarityenglish.common.events.SearchEvent;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.view.interfaces.CopyReceiver;
	import com.clarityenglish.resultsmanager.vo.manageable.User;
	import com.clarityenglish.dms.Constants;
	import com.clarityenglish.dms.view.account.events.AccountEvent;
	import com.clarityenglish.dms.vo.account.Account;
	
	import eu.orangeflash.managers.CMManager;
	
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.ui.ContextMenuItem;
	
	/**
	 * ...
	 * @author ...
	 */
	public class AccountCMManager extends CMManager implements CopyReceiver {
		
		private var addAccountMenuItem:ContextMenuItem;
		private var editAccountMenuItem:ContextMenuItem;
		private var deleteAccountMenuItem:ContextMenuItem;
		private var archiveAccountMenuItem:ContextMenuItem; // gh#911
		private var generateReportMenuItem:ContextMenuItem;
		private var searchMenuItem:ContextMenuItem;
		private var clearSearchMenuItem:ContextMenuItem;
		private var addToEmailListMenuItem:ContextMenuItem;
		private var setAsEmailListMenuItem:ContextMenuItem;
		private var openInRMMenuItem:ContextMenuItem;
		
		public function AccountCMManager(target:InteractiveObject) {
			super(target);
			
			generateReportMenuItem = add("", function(e:Event):void { dispatchEvent(new AccountEvent(AccountEvent.GENERATE_REPORT, null, null, true)); } );
			addAccountMenuItem = add("", function(e:Event):void { dispatchEvent(new AccountEvent(AccountEvent.ADD_ACCOUNT, null, null, true)); }, true );
			editAccountMenuItem = add("", function(e:Event):void { dispatchEvent(new AccountEvent(AccountEvent.EDIT_ACCOUNT, null, null, true)); } );
			deleteAccountMenuItem = add("", function(e:Event):void { dispatchEvent(new AccountEvent(AccountEvent.DELETE_ACCOUNTS, null, null, true)); } );
			// gh#911
			archiveAccountMenuItem = add("", function(e:Event):void { dispatchEvent(new AccountEvent(AccountEvent.ARCHIVE_ACCOUNTS, null, null, true)); } );
			searchMenuItem = add("", function(e:Event):void { dispatchEvent(new SearchEvent(SearchEvent.SEARCH, null, true)); }, true );
			clearSearchMenuItem = add("", function(e:Event):void { dispatchEvent(new SearchEvent(SearchEvent.CLEAR_SEARCH, null, true)); }, false, false );
			addToEmailListMenuItem = add("", function(e:Event):void { dispatchEvent(new AccountEvent(AccountEvent.ADD_TO_EMAIL_TO_LIST, null, null, true)); }, true );
			setAsEmailListMenuItem = add("", function(e:Event):void { dispatchEvent(new AccountEvent(AccountEvent.SET_EMAIL_TO_LIST, null, null, true)); } );
			openInRMMenuItem = add("", function(e:Event):void { dispatchEvent(new AccountEvent(AccountEvent.SHOW_IN_RESULTS_MANAGER, null, null, true)); }, true);
		}
		
		public function setCopyProvider(copyProvider:CopyProvider):void{
			addAccountMenuItem.caption = copyProvider.getCopyForId("addAccountMenuItem");
			editAccountMenuItem.caption = copyProvider.getCopyForId("editAccountMenuItem");
			deleteAccountMenuItem.caption = copyProvider.getCopyForId("deleteAccountMenuItem");
			archiveAccountMenuItem.caption = copyProvider.getCopyForId("archiveAccountMenuItem"); // gh#911
			generateReportMenuItem.caption = copyProvider.getCopyForId("generateReportMenuItem");
			searchMenuItem.caption = copyProvider.getCopyForId("searchMenuItem");
			clearSearchMenuItem.caption = copyProvider.getCopyForId("clearSearchMenuItem");
			addToEmailListMenuItem.caption = copyProvider.getCopyForId("addToEmailListMenuItem");
			setAsEmailListMenuItem.caption = copyProvider.getCopyForId("setAsEmailListMenuItem");
			openInRMMenuItem.caption = copyProvider.getCopyForId("openInRMMenuItem");
		}
		
		private function configureMenuItems():void {
			addAccountMenuItem.visible = editAccountMenuItem.visible =
										 deleteAccountMenuItem.visible = (Constants.userType == User.USER_TYPE_DMS);
		}
		
		public function enableBySelectedContent(selectedItems:Array):void {
			// Set visible menu items based on user type.  Its not really necessary for this to happen everytime, but there
			// isn't really any other obvious place to put it and its a cheap operation anyway.
			configureMenuItems();
			
			editAccountMenuItem.enabled = (selectedItems.length == 1);
			deleteAccountMenuItem.enabled = (selectedItems.length > 0);
			generateReportMenuItem.enabled = (selectedItems.length > 0);
			addToEmailListMenuItem.enabled = (selectedItems.length > 0);
			setAsEmailListMenuItem.enabled = (selectedItems.length > 0);
			openInRMMenuItem.enabled = (selectedItems.length == 1);
			// gh#911
			archiveAccountMenuItem.enabled = true; 
			var account:Account =  (selectedItems[0] as Account);
			if (account.accountStatus == 11)
				archiveAccountMenuItem.enabled = false;
		}
		
		/**
		 * This method is called when search is turned on or off so we know whether or not to enabled the Clear search button
		 * 
		 * @param	searchActive Whether or not search is currently active
		 */
		public function setIsSearchActive(searchActive:Boolean):void {
			clearSearchMenuItem.enabled = searchActive;
		}
		
	}
	
}