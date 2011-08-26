/*
Simple Command - PureMVC
 */
package com.clarityenglish.recorder.controller {
	import com.clarityenglish.recorder.ApplicationFacade;
	import com.clarityenglish.recorder.model.AudioProxy;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	import org.puremvc.as3.multicore.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 */
	public class CompareToCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var audioProxy:AudioProxy = facade.retrieveProxy(ApplicationFacade.MODEL_PROXY_NAME) as AudioProxy;
			audioProxy.loadMP3(note.getBody() as String);
		}
		
	}
}