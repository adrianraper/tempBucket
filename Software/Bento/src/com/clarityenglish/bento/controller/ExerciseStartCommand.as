package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.ExerciseProxy;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.common.model.ConfigProxy;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class ExerciseStartCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var exercise:Exercise = note.getBody() as Exercise;
						
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			
			if (bentoProxy.currentExercise)
				sendNotification(BBNotifications.EXERCISE_STOP, bentoProxy.currentExercise);
			
			bentoProxy.currentExercise = exercise;
			
			var exerciseProxy:ExerciseProxy = new ExerciseProxy(exercise);
			facade.registerProxy(exerciseProxy);
			
			// Start recording the duration
			exerciseProxy.startExercise();
			
			log.info("Exercise started - " + exercise.href);
			
			sendNotification(BBNotifications.EXERCISE_STARTED, exercise);
			
			// Check to see if this user is already running
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			configProxy.checkInstance();
			
		}
		
	}
	
}