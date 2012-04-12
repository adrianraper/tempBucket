package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.ExerciseProxy;
	
	import mx.core.FlexGlobals;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class ExerciseRestartCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			// Restart an exercise by showing a clone of the current Href.  This will have the same effect as starting a new exercise
			// as the app will see that the Href is a new instance, hence resetting everything (but ultimately loading the same xml).
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(bentoProxy.currentExercise)) as ExerciseProxy;
			
			// #210, #256 - warning messages when leaving an exercise
			if (exerciseProxy.attemptToLeaveExercise(note)) {
				sendNotification(BBNotifications.CLOSE_ALL_POPUPS, FlexGlobals.topLevelApplication); // #265
				sendNotification(BBNotifications.EXERCISE_SHOW, bentoProxy.currentExercise.href.clone());
			}
		}
		
	}
	
}