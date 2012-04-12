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
	
	public class ExerciseShowOffsetCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var exercise:Exercise = bentoProxy.currentExercise;
			var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(exercise)) as ExerciseProxy;
			var exerciseHasQuestions:Boolean = (exercise.model.questions.length > 0);
			
			// #210, #256 - warning messages when leaving an exercise
			if (exerciseProxy.isLeavingGoingToLoseAnswers()) {
				sendNotification(BBNotifications.WARN_DATA_LOSS, { type: "lose_answers", action: BBNotifications.EXERCISE_SHOW_NEXT });
			} else if (exerciseProxy.isLeavingGoingToMissFeedback()) {
				sendNotification(BBNotifications.WARN_DATA_LOSS, { type: "feedback_not_seen", action: BBNotifications.EXERCISE_SHOW_NEXT });
			} else {
				var exerciseNode:XML = bentoProxy.getExerciseNodeWithOffset(note.getBody() as int);
				if (exerciseNode) {
					sendNotification(BBNotifications.EXERCISE_SHOW, bentoProxy.menuXHTML.href.createRelativeHref(Href.EXERCISE, exerciseNode.@href));
				} else {
					sendNotification(BBNotifications.EXERCISE_SECTION_FINISHED);
				}
			}
		}
		
	}
	
}