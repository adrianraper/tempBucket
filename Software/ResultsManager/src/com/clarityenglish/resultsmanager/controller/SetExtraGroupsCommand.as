/*
Simple Command - PureMVC
 */
package com.clarityenglish.resultsmanager.controller {
	import com.clarityenglish.resultsmanager.model.ManageableProxy;
	import com.clarityenglish.resultsmanager.view.management.events.ExtraGroupsEvent;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 */
	public class SetExtraGroupsCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var e:ExtraGroupsEvent = note.getBody() as ExtraGroupsEvent;
			
			var manageableProxy:ManageableProxy = facade.retrieveProxy(ManageableProxy.NAME) as ManageableProxy;
			manageableProxy.setExtraGroups(e.user, e.groups);
		}
		
	}
}