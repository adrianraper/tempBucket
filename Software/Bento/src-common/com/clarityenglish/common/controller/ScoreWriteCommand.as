/*
Simple Command - PureMVC
 */
package com.clarityenglish.common.controller {
	
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.vo.ExerciseMark;
	import com.clarityenglish.common.model.ProgressProxy;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
    
	/**
	 * SimpleCommand
	 */
	public class ScoreWriteCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			
			var data:ExerciseMark = note.getBody() as ExerciseMark;
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;

			// coverage of an exercise is always 100%
			data.coverage = 100;
			data.UID = bentoProxy.getCurrentExerciseUID();
			
			// Add the UID to the mark object
			
			var progressProxy:ProgressProxy = facade.retrieveProxy(ProgressProxy.NAME) as ProgressProxy;
			progressProxy.writeScore(data);
		}
		
	}
}