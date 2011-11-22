/*
Simple Command - PureMVC
 */
package com.clarityenglish.common.controller {
	
	import com.clarityenglish.common.model.ProgressProxy;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
    
	/**
	 * SimpleCommand
	 */
	public class ScoreWriteCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			
			var data:Object = note.getBody();
			
			// coverage of an exercise is always 100%
			var coverage:int = 100;
			var totalQ:uint =  data.correct + data.wrong + data.skipped;
			if (totalQ<=0) {
				// Historically we have always used -1 to indicate an unmarked exercise
				var percent:int = -1;
			} else {
				percent = Math.round(100 * data.correct / totalQ);
			}
			var progressProxy:ProgressProxy = facade.retrieveProxy(ProgressProxy.NAME) as ProgressProxy;
			progressProxy.writeScore(percent, data.correct, data.wrong, data.skipped, coverage, data.duration);
		}
		
	}
}