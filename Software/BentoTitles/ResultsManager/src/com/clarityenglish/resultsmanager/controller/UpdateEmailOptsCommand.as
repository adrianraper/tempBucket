/*
Simple Command - PureMVC
 */
package com.clarityenglish.resultsmanager.controller {
	import com.clarityenglish.resultsmanager.model.EmailOptsProxy;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
	import com.clarityenglish.utils.TraceUtils;
    
	/**
	 * SimpleCommand
	 */
	public class UpdateEmailOptsCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var emailOptsArray:Array = note.getBody() as Array;
			//// TraceUtils.myTrace("UpdateEmailOptsCommand with " + emailOptsArray.length + ' items');
			var emailOptsProxy:EmailOptsProxy = facade.retrieveProxy(EmailOptsProxy.NAME) as EmailOptsProxy;
			
			// Take data from the notification object and put into the proxy
			emailOptsProxy.clearEmailItems();

			for (var i:uint = 0; i < emailOptsArray.length; i++ ) {
				var emailItem:Object = emailOptsArray[i];
				//// TraceUtils.myTrace(i + ':' + emailItem.email + ':' + emailItem.messageType);
				emailOptsProxy.setEmailItem(i, emailItem.email, emailItem.messageType);
			}
				
			// Then save from the proxy
			emailOptsProxy.saveEmailOpts();
		}
		
	}
}