/*
Simple Command - PureMVC
 */
package com.clarityenglish.common.controller {
	import com.clarityenglish.common.events.EmailEvent;
	import com.clarityenglish.common.model.EmailProxy;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 */
	public class SendEmailCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var emailEvent:EmailEvent = note.getBody() as EmailEvent;
			
			var emailProxy:EmailProxy = facade.retrieveProxy(EmailProxy.NAME) as EmailProxy;
			// ctp#214
			if (emailEvent.type == EmailEvent.PREVIEW_EMAIL) {
				emailProxy.previewGroupEmail(emailEvent.templateDefinition, emailEvent.manageables);
			} else {
				emailProxy.sendGroupEmail(emailEvent.templateDefinition, emailEvent.manageables);
			}
		}
		
	}
}