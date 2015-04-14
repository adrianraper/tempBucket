/*
Simple Command - PureMVC
 */
package com.clarityenglish.resultsmanager.controller {
	import com.clarityenglish.resultsmanager.model.ManageableProxy;
	import com.clarityenglish.resultsmanager.view.management.events.ManageableEvent;
	import com.clarityenglish.common.vo.manageable.Group;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 */
	public class MoveManageablesCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var e:ManageableEvent = note.getBody() as ManageableEvent;
			
			var manageableProxy:ManageableProxy = facade.retrieveProxy(ManageableProxy.NAME) as ManageableProxy;
			manageableProxy.moveManageables(e.manageables, e.parentGroup as Group);
		}
		
	}
}