/*
 Mediator - PureMVC
 */
package com.clarityenglish.dms.view.account {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.DictionaryProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.dms.DMSNotifications;
	import com.clarityenglish.dms.model.AccountProxy;
	import com.clarityenglish.dms.view.account.events.AccountEvent;
	import flash.events.Event;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	import com.clarityenglish.dms.view.account.components.*;
	import com.clarityenglish.dms.view.account.*;
	//import nl.demonsters.debugger.MonsterDebugger;
	
	/**
	 * A Mediator
	 */
	public class AccountMediator extends Mediator implements IMediator {
	
		// Cannonical name of the Mediator
		public static const NAME:String = "AccountMediator";
		
		public function AccountMediator(viewComponent:Object) {
			// pass the viewComponent to the superclass where 
			// it will be stored in the inherited viewComponent property
			super(NAME, viewComponent);
		}
		
		private function get accountView():AccountView {
			return viewComponent as AccountView;
		}
		
		/**
		 * Setup event listeners and register sub-mediators
		 */
		override public function onRegister():void {
			super.onRegister();
			
			accountView.addEventListener(AccountEvent.GENERATE_REPORT, onGenerateReport);
			accountView.addEventListener(AccountEvent.ADD_ACCOUNT, onAddAccount);
			accountView.addEventListener(AccountEvent.DELETE_ACCOUNTS, onDeleteAccounts);
			accountView.addEventListener(AccountEvent.UPDATE_ACCOUNTS, onUpdateAccounts);
			accountView.addEventListener(AccountEvent.GET_ACCOUNT_DETAILS, onGetAccountDetails);
			accountView.addEventListener(AccountEvent.ADD_TO_EMAIL_TO_LIST, onChangeEmailToList);
			accountView.addEventListener(AccountEvent.SET_EMAIL_TO_LIST, onChangeEmailToList);
			accountView.addEventListener(AccountEvent.SHOW_IN_RESULTS_MANAGER, onShowInResultsManager);
			accountView.addEventListener(AccountEvent.GET_ACCOUNTS, onGetAccounts);
			accountView.addEventListener(AccountEvent.CHANGE_ACCOUNT_TYPE, onChangeAccountType);
		}
		
		/**
		 * Get the Mediator name.
		 * <P>
		 * Called by the framework to get the name of this
		 * mediator. If there is only one instance, we may
		 * define it in a constant and return it here. If
		 * there are multiple instances, this method must
		 * return the unique name of this instance.</P>
		 * 
		 * @return String the Mediator name
		 */
		override public function getMediatorName():String {
			return AccountMediator.NAME;
		}
        
		/**
		 * List all notifications this Mediator is interested in.
		 * <P>
		 * Automatically called by the framework when the mediator
		 * is registered with the view.</P>
		 * 
		 * @return Array the list of Nofitication names
		 */
		override public function listNotificationInterests():Array {
			return [CommonNotifications.COPY_LOADED,
					DMSNotifications.ACCOUNTS_LOADED,
					DMSNotifications.ACCOUNT_DETAILS_LOADED,
					DMSNotifications.REPORT_TEMPLATES_LOADED,
					DMSNotifications.ACCOUNTS_RESET,
					DMSNotifications.EMAIL_TO_LIST_CHANGED];
		}

		/**
		 * Handle all notifications this Mediator is interested in.
		 * <P>
		 * Called by the framework when a notification is sent that
		 * this mediator expressed an interest in when registered
		 * (see <code>listNotificationInterests</code>.</P>
		 * 
		 * @param INotification a notification 
		 */
		override public function handleNotification(note:INotification):void {
			//MonsterDebugger.trace(this, note.getName());
			switch (note.getName()) {
				case CommonNotifications.COPY_LOADED:
					var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
					accountView.setCopyProvider(copyProvider);
					break;
				// v3.0.6 Reset the account parameters if you getAccounts from fresh
				case DMSNotifications.ACCOUNTS_RESET:
					accountView.individualAccounts.selected = false;
					//accountView.closedAccounts.selected = false;
					break;
				case DMSNotifications.ACCOUNTS_LOADED:
					//MonsterDebugger.trace(this, note.getBody());
					accountView.setDataGridDataProvider(note.getBody());
					break;
				case DMSNotifications.ACCOUNT_DETAILS_LOADED:
					//MonsterDebugger.trace(this, note.getBody());
					accountView.onEditAccountDisplay(note.getBody() as Array);
					break;
				case DMSNotifications.EMAIL_TO_LIST_CHANGED:
					// We need to let the view know when the email list has changed so it can update the colour of the email column
					accountView.updateEmailColumnStyle();
					break;
				case DMSNotifications.REPORT_TEMPLATES_LOADED:
					//MonsterDebugger.trace(this, note.getBody());
					accountView.reportTemplateDefinitions = note.getBody() as Array;
					break;
				default:
					break;
			}
		}
		
		private function onGenerateReport(e:AccountEvent):void {
			var accountProxy:AccountProxy = facade.retrieveProxy(AccountProxy.NAME) as AccountProxy;
			accountProxy.generateReport(e.accounts, e.reportTemplate);
		}
		
		private function onAddAccount(e:AccountEvent):void {
			sendNotification(DMSNotifications.ADD_ACCOUNT, e);
		}
		
		private function onUpdateAccounts(e:AccountEvent):void {
			sendNotification(DMSNotifications.UPDATE_ACCOUNTS, e);
		}
		
		private function onGetAccountDetails(e:AccountEvent):void {
			//MonsterDebugger.trace(this, e);
			var accountProxy:AccountProxy = facade.retrieveProxy(AccountProxy.NAME) as AccountProxy;
			accountProxy.getAccountDetails(e.account.id);
		}
		
		private function onDeleteAccounts(e:AccountEvent):void {
			sendNotification(DMSNotifications.DELETE_ACCOUNTS, e);
		}
		
		private function onChangeEmailToList(e:AccountEvent):void {
			sendNotification(DMSNotifications.CHANGE_EMAIL_TO_LIST, e, e.type);
		}
		
		private function onShowInResultsManager(e:AccountEvent):void {
			sendNotification(DMSNotifications.SHOW_IN_RESULTS_MANAGER, e);
		}
		
		private function onGetAccounts(e:AccountEvent):void {
			//MonsterDebugger.trace(this, "account mediator");
			var accountProxy:AccountProxy = facade.retrieveProxy(AccountProxy.NAME) as AccountProxy;
			//accountProxy.getAccounts(e.showIndividuals);
			accountProxy.getAccounts();
		}
		
		// v3.0.6 This changes the account type and then calls getAccounts (or rather the proxy does)
		private function onChangeAccountType(e:AccountEvent):void {
			var accountProxy:AccountProxy = facade.retrieveProxy(AccountProxy.NAME) as AccountProxy;
			//accountProxy.changeAccountType(e.showIndividuals, e.closedAccounts);
			accountProxy.changeAccountType(e.showIndividuals);
		}
		
	}
}
