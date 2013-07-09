/*
Simple Command - PureMVC
 */
package com.clarityenglish.bento.controller.recorder {
	import com.clarityenglish.bento.model.AudioProxy;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
    
	/**
	 * SimpleCommand
	 */
	public class ClearWaveformCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var audioProxy:AudioProxy = facade.retrieveProxy(note.getType()) as AudioProxy;
			audioProxy.clearWaveform();
		}
		
	}
}