/*
Simple Command - PureMVC
 */
package com.clarityenglish.resultsmanager.controller {
	import com.clarityenglish.resultsmanager.model.UploadProxy;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 */
	public class UploadXMLCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var uploadProxy:UploadProxy = facade.retrieveProxy(UploadProxy.NAME) as UploadProxy;
			
			// The upload method takes the notification to send on completion as a parameter (this is a neat way of chaining together
			// an upload and a remote method call).  The body and type are also given, and are just passed directly through to the complete
			// notification.
			uploadProxy.upload(note.getBody().completeNotification, note.getBody().completeBody, note.getBody().completeType);
		}
		
	}
}