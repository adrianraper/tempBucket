/*
Simple Command - PureMVC
 */
package com.clarityenglish.progressWidget.controller {
	import com.clarityenglish.resultsmanager.model.UsageProxy;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 */
	public class LoggedOutCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			facade.removeProxy(UsageProxy.NAME);
		}
		
	}
}