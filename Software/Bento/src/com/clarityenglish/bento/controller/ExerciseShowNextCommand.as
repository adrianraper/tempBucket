package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.ExerciseProxy;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.bento.vo.content.model.answer.NodeAnswer;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class ExerciseShowNextCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			// TODO. I think it would be neater to have this one command for next and previous
			// and send it a variable telling it which way to go.
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var exercise:Exercise = bentoProxy.currentExercise;
			var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(exercise)) as ExerciseProxy;
			var exerciseHasQuestions:Boolean = (exercise.model.questions.length > 0);
			
			// Trac 210. Can you simply stop the exercise now, or do you need any warning first?
			// Rules. If the exercise hasn't been marked, yet something has been done, warn them
			if (!exerciseProxy.exerciseMarked && exerciseProxy.exerciseDirty) {
				// Trigger a notification to warn them and handle the response
				sendNotification(BBNotifications.WARN_DATA_LOSS, { type:"lose_answers", action:"show_next" });
				
			// Or if it has been marked and there is feedback that they haven't seen, warn them
			} else if (exerciseProxy.exerciseMarked && exerciseProxy.hasExerciseFeedback()) {
				sendNotification(BBNotifications.WARN_DATA_LOSS, { type:"feedback_not_seen", action:"show_next" });
				
			} else {
				var exerciseNode:XML = bentoProxy.getNextExerciseNode();
				
				if (exerciseNode) {
					sendNotification(BBNotifications.EXERCISE_SHOW, bentoProxy.menuXHTML.href.createRelativeHref(Href.EXERCISE, exerciseNode.@href));
				} else {
					sendNotification(BBNotifications.EXERCISE_SECTION_FINISHED);
				}
			}
		}
		
	}
	
}