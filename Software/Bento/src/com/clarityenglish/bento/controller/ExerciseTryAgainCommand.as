package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.ExerciseProxy;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.bento.vo.content.model.answer.AnswerMap;
	
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class ExerciseTryAgainCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(bentoProxy.currentExercise)) as ExerciseProxy;
			
			exerciseProxy.unmarkExercise();
		}
		
		/*public override function execute(note:INotification):void {
			super.execute(note);
			
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			
			if (!bentoProxy.currentExercise) {
				log.error("Attempted to try again when no exercise was running");
				return;
			}
			
			var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(bentoProxy.currentExercise)) as ExerciseProxy;
			
			// Get all the currently selected answers
			var allSelectedAnswerMaps:Dictionary = exerciseProxy.getAllSelectedAnswerMaps();
			
			// Restart the exercise
			sendNotification(BBNotifications.EXERCISE_RESTART);
			
			keep = new Object();
			setTimeout(replayAnswers, 2000, allSelectedAnswerMaps);
		}
		
		var keep:Object;
		
		private function replayAnswers(allSelectedAnswerMaps:Dictionary):void {
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(bentoProxy.currentExercise)) as ExerciseProxy;
			
			// Replay all the selected answers on the exercise
			for (var questionObj:* in allSelectedAnswerMaps) {
				var question:Question = questionObj as Question;
				var answerMap:AnswerMap = allSelectedAnswerMaps[question];
				
				for each (var key:Object in answerMap.keys)
					exerciseProxy.questionAnswer(question, answerMap.get(key), key);
				
			}
		}*/
		
	}
	
}