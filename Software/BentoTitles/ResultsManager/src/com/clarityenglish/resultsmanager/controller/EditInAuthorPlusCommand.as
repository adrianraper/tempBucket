/*
Simple Command - PureMVC
 */
package com.clarityenglish.resultsmanager.controller {
	import com.clarityenglish.common.vo.content.Content;
	import com.clarityenglish.common.vo.content.Exercise;
	import com.clarityenglish.common.vo.manageable.Manageable;
	import com.clarityenglish.resultsmanager.model.ContentProxy;
	import com.clarityenglish.resultsmanager.view.management.events.ContentEvent;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
	import nl.demonsters.debugger.MonsterDebugger;
    
	/**
	 * SimpleCommand
	 */
	public class EditInAuthorPlusCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var e:ContentEvent = note.getBody() as ContentEvent;
			
			//MonsterDebugger.trace(this, e);
			var contentProxy:ContentProxy = facade.retrieveProxy(ContentProxy.NAME) as ContentProxy;
			contentProxy.editInAuthorPlus(e.editedUID, e.caption);
		}
		
	}
}