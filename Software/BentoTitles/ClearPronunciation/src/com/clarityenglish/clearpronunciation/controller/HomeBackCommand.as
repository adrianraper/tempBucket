package com.clarityenglish.clearpronunciation.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.ExerciseProxy;
	
	import mx.core.FlexGlobals;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class HomeBackCommand extends SimpleCommand {
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var next:Function = note.getBody() as Function;
			if (bentoProxy.currentExercise) {
				var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(bentoProxy.currentExercise)) as ExerciseProxy;
				
				// conside that user will back to home from widget exercise page
				if (exerciseProxy.attemptToLeaveExercise(note)) {
					sendNotification(BBNotifications.CLOSE_ALL_POPUPS, FlexGlobals.topLevelApplication); // #265
					next();
				}
			} else {
				next();
			}
		}
	}
}