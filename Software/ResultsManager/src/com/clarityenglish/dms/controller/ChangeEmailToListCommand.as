/*
Simple Command - PureMVC
 */
package com.clarityenglish.dms.controller {
	import com.clarityenglish.dms.model.EmailProxy;
	import com.clarityenglish.dms.view.account.events.AccountEvent;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 */
	public class ChangeEmailToListCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var accountEvent:AccountEvent = note.getBody() as AccountEvent;
			var emailProxy:EmailProxy = facade.retrieveProxy(EmailProxy.NAME) as EmailProxy;
			
			switch (note.getType()) {
				case AccountEvent.ADD_TO_EMAIL_TO_LIST:
					emailProxy.addAccountsToToList(accountEvent.accounts);
					break;
				case AccountEvent.SET_EMAIL_TO_LIST:
					emailProxy.setAccountsAsToList(accountEvent.accounts);
					break;
				default:
					throw new Error("Unknown change email type " + note.getType());
			}
		}
		
	}
}