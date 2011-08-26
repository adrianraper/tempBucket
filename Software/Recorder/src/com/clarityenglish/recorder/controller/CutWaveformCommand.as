/*
Simple Command - PureMVC
 */
package com.clarityenglish.recorder.controller {
	import com.clarityenglish.recorder.model.AudioProxy;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	import org.puremvc.as3.multicore.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 */
	public class CutWaveformCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var audioProxy:AudioProxy = facade.retrieveProxy(note.getType()) as AudioProxy;
			audioProxy.cutWaveform(note.getBody().left, note.getBody().right);
		}
		
	}
}