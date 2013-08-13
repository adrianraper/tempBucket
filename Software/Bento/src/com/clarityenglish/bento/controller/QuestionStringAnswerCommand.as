package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.model.ExerciseProxy;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.bento.vo.content.model.answer.Feedback;
	import com.clarityenglish.bento.vo.content.model.answer.TextAnswer;
	import com.newgonzo.commons.utils.StringUtil;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.ObjectUtil;
	
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
			var disabled:Boolean = note.getBody().disabled;
			
			var textAnswer:TextAnswer = getTextAnswer(question, answerString, exercise.isCaseSensitive());
			
			var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(exercise)) as ExerciseProxy;
			exerciseProxy.questionAnswer(question, textAnswer, key, disabled);
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
			// TODO. If they correct answer has " in it, then ' should also be acceptable. Are there other equivalences?
			for each (var textAnswer:TextAnswer in question.answers) {
				if ((isCaseSensitive) ? answerString == textAnswer.value : answerString.toLowerCase() == textAnswer.value.toLowerCase()) {
					return textAnswer;
				}
			}
			
			// If we reached here then no answer was matched so create a new one, including the unmatched feedback if there was any
			var xmlString:String = "";
			// gh#515 protect apostrophe/quote characters from XML string syntax
			xmlString += '<answer value="' + answerString.replace(/(")/g, "&quot;") + '">';
			if (question.unmatchedFeedbackSource) xmlString += '<feedback source="' + question.unmatchedFeedbackSource + '" />';
			xmlString += '</answer>';
			
			return new TextAnswer(new XML(xmlString));
		}
		
	}
	
}