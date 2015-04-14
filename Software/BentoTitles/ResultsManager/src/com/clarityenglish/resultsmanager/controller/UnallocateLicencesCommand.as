/*
Simple Command - PureMVC
 */
package com.clarityenglish.resultsmanager.controller {
	import com.clarityenglish.resultsmanager.model.LicenceProxy;
	import com.clarityenglish.resultsmanager.view.licence.events.LicenceEvent;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 * No longer used.
	 */
	public class UnallocateLicencesCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var licenceEvent:LicenceEvent = note.getBody() as LicenceEvent;
			
			var licenceProxy:LicenceProxy = facade.retrieveProxy(LicenceProxy.NAME) as LicenceProxy;
			licenceProxy.unallocateLicences(licenceEvent.users, licenceEvent.title);
		}
		
	}
}