/*
Simple Command - PureMVC
 */
package com.clarityenglish.dms.controller {
	import com.clarityenglish.dms.model.AccountProxy;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 */
	public class LoggedOutCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			facade.removeProxy(AccountProxy.NAME);
		}
		
	}
}