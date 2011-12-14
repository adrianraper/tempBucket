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
				
				// Perhaps here is the best place to write out the score, rather than in MarkingShowCommand
				// a) non-marked exercises are covered
				// b) dynamic-view exercises are covered
				// c) the full time of the exercise, including feedback study, is covered.
				var exercise:Exercise = bentoProxy.currentExercise;
				var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(exercise)) as ExerciseProxy;
				var thisExerciseMark:ExerciseMark = exerciseProxy.getExerciseMark();

				// Add more data to the exerciseMark ready to send it as a score
				thisExerciseMark.duration = Math.round(exerciseProxy.duration / 1000);
				thisExerciseMark.UID = bentoProxy.getCurrentExerciseUID();
				
				// Trigger a notification to write the score out
				sendNotification(BBNotifications.SCORE_WRITE, thisExerciseMark);

				bentoProxy.currentExercise = null;
				facade.removeProxy(ExerciseProxy.NAME(exercise));
				sendNotification(BBNotifications.EXERCISE_STOPPED, exercise);
				
				
			}
		}
		
	}
	
}