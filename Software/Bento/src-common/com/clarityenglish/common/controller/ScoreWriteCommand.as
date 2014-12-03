/*
Simple Command - PureMVC
 */
package com.clarityenglish.common.controller {
	
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.SCORMProxy;
	import com.clarityenglish.bento.vo.ExerciseMark;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.MemoryProxy;
	import com.clarityenglish.common.model.ProgressProxy;
	import com.clarityenglish.common.vo.content.Bookmark;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
    
	/**
	 * SimpleCommand
	 */
	public class ScoreWriteCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var data:ExerciseMark = note.getBody() as ExerciseMark;
			
			var progressProxy:ProgressProxy = facade.retrieveProxy(ProgressProxy.NAME) as ProgressProxy;
			progressProxy.writeScore(data);
			
			// #336 If you are running in SCORM, you also need to write a score to the LMS
			var scormProxy:SCORMProxy = facade.retrieveProxy(SCORMProxy.NAME) as SCORMProxy;
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			// gh#877
			if (configProxy.getConfig().scorm && !scormProxy.isScormCompleted()) {
				// gh#881
				var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
				if (bentoProxy.currentExercise) {
					var exercise:Exercise = bentoProxy.currentExercise;
					if (!exercise.hasQuestions()) {
						var hasQuestion:Boolean = false;
					} else {
						hasQuestion = true;
					}
				}
				
				if (data.correctPercent < 0) {
					scormProxy.writeScore(data.UID, 0, hasQuestion);
				} else {
					scormProxy.writeScore(data.UID, data.correctPercent, hasQuestion);
				}	
			}
			
			// gh#1067 Write a bookmark to show you have completed this exercise
			var bookmark:Bookmark = new Bookmark(data.UID);
			var memories:Object = {lastExerciseCompleted:bookmark.uid};
			var memoryProxy:MemoryProxy = facade.retrieveProxy(MemoryProxy.NAME) as MemoryProxy;
			memoryProxy.writeMemory(memories);
			
		}
		
	}
}