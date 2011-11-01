package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.model.ExerciseProxy;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.bento.vo.content.model.answer.TextAnswer;
	import com.newgonzo.commons.utils.StringUtil;
	
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
			
			var exercise:Exercise = note.getBody().exercise as Exercise;
			var question:Question = note.getBody().question as Question;
			var answerString:String = note.getBody().answerString;
			var key:Object = note.getBody().key;
			
			var textAnswer:TextAnswer = getTextAnswer(question, answerString, exercise.isCaseSensitive());
			
			var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME) as ExerciseProxy;
			exerciseProxy.questionAnswer(exercise, question, textAnswer, key);
		}
		
		/**
		 * If the entered text already exists as a predefined answer return that, or create a blank one.
		 * 
		 * @param question
		 * @param answerString
		 * @return 
		 */
		private function getTextAnswer(question:Question, answerString:String, isCaseSensitive:Boolean):TextAnswer {
			// Always trim the answer before comparison (#20)
			if (answerString)
				answerString = StringUtil.trim(answerString);
			
			// Search for the answer.  Case sensitivity is controlled by the exercise settings (#20).
			for each (var textAnswer:TextAnswer in question.answers) {
				if ((isCaseSensitive) ? answerString == textAnswer.value : answerString.toLowerCase() == textAnswer.value.toLowerCase()) {
					return textAnswer;
				}
			}
			
			return new TextAnswer(<Answer value={answerString} />);
		}
		
	}
	
}