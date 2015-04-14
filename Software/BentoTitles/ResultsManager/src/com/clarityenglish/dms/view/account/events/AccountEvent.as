package com.clarityenglish.dms.view.account.events {
	import com.clarityenglish.dms.vo.account.Account;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author ...
	 */
	public class AccountEvent extends Event {
		
		public static const ADD_ACCOUNT:String = "add_account";
		public static const EDIT_ACCOUNT:String = "edit_account";
		public static const DELETE_ACCOUNTS:String = "delete_accounts";
		public static const ARCHIVE_ACCOUNTS:String = "archive_accounts";
		public static const GET_ACCOUNT_DETAILS:String = "get_account_details";
		public static const UPDATE_ACCOUNTS:String = "update_accounts";
		public static const ADD_TO_EMAIL_TO_LIST:String = "add_to_email_to_list";
		public static const SET_EMAIL_TO_LIST:String = "set_email_to_list";
		public static const GENERATE_REPORT:String = "generate_report";
		public static const SHOW_IN_RESULTS_MANAGER:String = "show_in_results_manager";
		public static const GET_ACCOUNTS:String = "get_accounts";
		public static const CHANGE_ACCOUNT_TYPE:String = "change_account_type";
		
		public var accounts:Array;
		public var reportTemplate:String;
		// v3.4
		public var individualAccounts:Boolean;
		// gh#911
		public var archivedAccounts:Boolean;
		
		public function AccountEvent(type:String, accounts:Array = null, reportTemplate:String = "", bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			
			this.accounts = accounts;
			this.reportTemplate = reportTemplate;
		}
		
		public function get account():Account {
			if (accounts.length != 1)
				throw new Error("Unable to get a single account from AccountEvent as there are " + accounts.length + " objects");
				
			return accounts[0] as Account;
		}
		
		public function set account(a:Account):void {
			accounts = [ a ];
		}
		
		// v3.4 Can you add a setter to an event to avoid putting too many attributes in the constructor?
		public function get showIndividuals():Boolean {
			return individualAccounts;
		}
		public function set showIndividuals(flag:Boolean):void {
			individualAccounts = flag;
		}
		// gh#911
		public function get showArchived():Boolean {
			return archivedAccounts;
		}
		public function set showArchived(flag:Boolean):void {
			archivedAccounts = flag;
		}
		
		public override function clone():Event { 
			return new AccountEvent(type, accounts, reportTemplate, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("AccountEvent", "type", "accounts", "reportTemplate", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}