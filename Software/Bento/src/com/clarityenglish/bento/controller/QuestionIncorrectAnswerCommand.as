package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.model.ExerciseProxy;
	import com.clarityenglish.bento.vo.content.Exercise;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class QuestionIncorrectAnswerCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var exercise:Exercise = note.getBody() as Exercise;
			var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(exercise)) as ExerciseProxy;
			exerciseProxy.questionIncorrectAnswer();
		}
		
	}
	
}