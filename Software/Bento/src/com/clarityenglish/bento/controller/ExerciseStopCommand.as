package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.ExerciseProxy;
	import com.clarityenglish.bento.vo.ExerciseMark;
	import com.clarityenglish.bento.vo.content.Exercise;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class ExerciseStopCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			
			log.info("Exercise stopped");
			
			// Stop the current exercise (if there is one) and clean up
			if (bentoProxy.currentExercise) {
				var exercise:Exercise = bentoProxy.currentExercise;
				var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(exercise)) as ExerciseProxy;
				var exerciseHasQuestions:Boolean = exercise.hasQuestions();
				
				// #294 - if the exercise has no questions then the score gets written here (if it does have questions it gets written when then marking window opens)
				// a) non-marked exercises are covered
				// b) the full time of the exercise, including feedback study, is covered.
				if (!exercise.hasQuestions()) {
					var exerciseMark:ExerciseMark = exerciseProxy.getExerciseMark();
					
					// Add more data to the exerciseMark ready to send it as a score
					exerciseMark.duration = Math.round(exerciseProxy.duration / 1000);
					exerciseMark.UID = bentoProxy.getExerciseUID(exercise.href);
					
					sendNotification(BBNotifications.SCORE_WRITE, exerciseMark);
				} else if (exercise.hasQuestions() && exercise.hasNoMarking()) { //gh#1139
					exerciseMark = new ExerciseMark();
					exerciseMark.duration = Math.round(exerciseProxy.duration / 1000);
					exerciseMark.UID = bentoProxy.getExerciseUID(exercise.href);
					exerciseMark.noMarking = true;

					sendNotification(BBNotifications.SCORE_WRITE, exerciseMark);
				}
				
				bentoProxy.currentExercise = null;
				facade.removeProxy(ExerciseProxy.NAME(exercise));
				sendNotification(BBNotifications.EXERCISE_STOPPED, exercise);
				
			}
		}
		
	}
	
}