package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.ExerciseProxy;
	import com.clarityenglish.bento.model.SCORMProxy;
	import com.clarityenglish.bento.vo.Href;
	
	import mx.core.FlexGlobals;
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
			var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(bentoProxy.currentExercise)) as ExerciseProxy;
			
			// #210, #256 - warning messages when leaving an exercise
			if (exerciseProxy.attemptToLeaveExercise(note)) {
				var exerciseNode:XML = bentoProxy.getExerciseNodeWithOffset(note.getBody() as int);
				
				sendNotification(BBNotifications.CLOSE_ALL_POPUPS, FlexGlobals.topLevelApplication); // #265
				
				if (exerciseNode) {
					sendNotification(BBNotifications.EXERCISE_SHOW, bentoProxy.menuXHTML.href.createRelativeHref(Href.EXERCISE, exerciseNode.@href));
				} else {
					// #336 This could be a good place to do SCORM writing if all exercises finished
					// But where will you 
					var scormProxy:SCORMProxy = facade.retrieveProxy(SCORMProxy.NAME) as SCORMProxy;
					scormProxy.completeSCO();
					
					sendNotification(BBNotifications.EXERCISE_SECTION_FINISHED);
				}
			}
		}
		
	}
	
}