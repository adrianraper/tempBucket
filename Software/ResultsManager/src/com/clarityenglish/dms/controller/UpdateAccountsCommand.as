/*
Simple Command - PureMVC
 */
package com.clarityenglish.dms.controller {
	import com.clarityenglish.dms.model.AccountProxy;
	import com.clarityenglish.dms.view.account.events.AccountEvent;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 */
	public class UpdateAccountsCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var e:AccountEvent = note.getBody() as AccountEvent;
			
			var accountProxy:AccountProxy = facade.retrieveProxy(AccountProxy.NAME) as AccountProxy;
			accountProxy.updateAccounts(e.accounts);
		}
		
	}
}