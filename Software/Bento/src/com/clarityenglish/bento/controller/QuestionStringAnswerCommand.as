package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.model.ExerciseProxy;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.bento.vo.content.model.answer.TextAnswer;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class QuestionStringAnswerCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var question:Question = note.getBody().question as Question;
			var answerString:String = note.getBody().answerString;
			var key:Object = note.getBody().key;
			
			var textAnswer:TextAnswer = getTextAnswer(question, answerString);
			
			var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME) as ExerciseProxy;
			exerciseProxy.questionAnswer(question, textAnswer, key);
		}
		
		/**
		 * If the entered text already exists as a predefined answer return that, or create a blank one.
		 * 
		 * @param question
		 * @param answerString
		 * @return 
		 */
		private function getTextAnswer(question:Question, answerString:String):TextAnswer {
			for each (var textAnswer:TextAnswer in question.answers) {
				if (answerString == textAnswer.value) {
					return textAnswer;
				}
			}
			
			return new TextAnswer(<Answer value={answerString} />);
		}
		
	}
	
}