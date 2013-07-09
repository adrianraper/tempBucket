/*
Simple Command - PureMVC
 */
package com.clarityenglish.bento.controller.recorder {
	import com.clarityenglish.bento.RecorderNotifications;
	import com.clarityenglish.bento.model.AudioProxy;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
    
	/**
	 * SimpleCommand
	 */
	public class CompareToCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var audioProxy:AudioProxy = facade.retrieveProxy(RecorderNotifications.MODEL_PROXY_NAME) as AudioProxy;
			audioProxy.loadMP3(note.getBody() as String);
		}
		
	}
}