package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.model.ExerciseProxy;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.bento.vo.content.model.answer.NodeAnswer;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class QuestionNodeAnswerCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var exercise:Exercise = note.getBody().exercise as Exercise;
			
			var question:Question = note.getBody().question as Question;
			var nodeAnswer:NodeAnswer = note.getBody().nodeAnswer;
			var key:Object = note.getBody().key;
			var disabled:Boolean = note.getBody().disabled;
			
			var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(exercise)) as ExerciseProxy;
			exerciseProxy.questionAnswer(question, nodeAnswer, key, disabled);
		}
		
	}
	
}