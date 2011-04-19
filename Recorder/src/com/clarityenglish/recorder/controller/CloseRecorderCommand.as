/*
Simple Command - PureMVC
 */
package com.clarityenglish.recorder.controller {
	import com.clarityenglish.recorder.model.LocalConnectionProxy;
	//import com.clarityenglish.recorder.model.LocalConnectionClient;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	import org.puremvc.as3.multicore.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 */
	public class CloseRecorderCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var localConnectionProxy:LocalConnectionProxy = facade.retrieveProxy(LocalConnectionProxy.NAME) as LocalConnectionProxy;
			localConnectionProxy.recorderClosing();
		}
		
	}
}