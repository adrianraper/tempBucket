/*
Simple Command - PureMVC
 */
package com.clarityenglish.resultsmanager.controller {
	import com.clarityenglish.resultsmanager.model.ContentProxy;
	import com.clarityenglish.resultsmanager.model.LicenceProxy;
	import com.clarityenglish.resultsmanager.model.LoginOptsProxy;
	import com.clarityenglish.resultsmanager.model.ManageableProxy;
	import com.clarityenglish.resultsmanager.model.ReportProxy;
	import com.clarityenglish.resultsmanager.model.UploadProxy;
	import com.clarityenglish.resultsmanager.model.UsageProxy;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 */
	public class LoggedOutCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			// Configure the result manager proxies
			facade.removeProxy(UploadProxy.NAME);
			facade.removeProxy(ManageableProxy.NAME);
			facade.removeProxy(ContentProxy.NAME);
			facade.removeProxy(ReportProxy.NAME);
			facade.removeProxy(LicenceProxy.NAME);
			facade.removeProxy(UsageProxy.NAME);
			facade.removeProxy(LoginOptsProxy.NAME);
		}
		
	}
}