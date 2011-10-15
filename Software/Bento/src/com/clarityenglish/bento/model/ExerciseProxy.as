package com.clarityenglish.bento.model {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.vo.content.model.Answer;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.bento.vo.content.model.TextAnswer;
	
	import flash.utils.Dictionary;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class ExerciseProxy extends Proxy implements IProxy {
		
		public static const NAME:String = "ExerciseProxy";
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		/**
		 * This maintains a map of the answers that will count towards the exercise score
		 */
		private var markableAnswers:Dictionary;
		
		/**
		 * This maintains a map of the currently selected answers
		 */
		private var selectedAnswers:Dictionary;
		
		private var delayedMarking:Boolean = false;
		
		public function ExerciseProxy() {
			super(NAME);
			
			markableAnswers = new Dictionary(true);
			selectedAnswers = new Dictionary(true);
		}
		
		public function getSelectedAnswerForQuestion(question:Question):Answer {
			return selectedAnswers[question];
		}
		
		/**
		 * TODO: Need to figure out what to do for questions that have multiple answers (e.g. DragAndDrop3)
		 * 
		 * Possibilities:
		 * 1. Map question to array
		 * 2. Composite pattern on answer (MultiAnswer)
		 * 
		 * TODO: Need to figure out how this will work with dynamic views and custom exercises (i.e. whether they will have questions and answers)
		 * 
		 * @param question
		 * @param answer
		 */
		public function questionAnswer(question:Question, answerOrString:*):void {
			var answer:Answer;
			if (answerOrString is String) {
				// When answerOrString is a String it means that the user has entered something (i.e. in a GapFill).  In this situation we need to construct
				// a TextAnswer with the value they have entered, and a derived score.
				var answerString:String = answerOrString;
				
				// TODO: This is badly in the wrong place
				var score:int = question.getScoreForAnswerString(answerString);
				
				answer = new TextAnswer(<Answer value={answerString} score={score} />);
			} else if (answerOrString is Answer) {
				answer = answerOrString;
			} else {
				throw new Error("questionAnswer received an answer that was neither an Answer nor a String");
			}
			
			log.debug("Answered question {0} - {1} [result: {2}, score: {3}]", question, answer, answer.result, answer.score);
			
			// If delayed marking is off and this is the first answer for the question record this seperately
			if (!delayedMarking && !markableAnswers[question]) markableAnswers[question] = answer;
			
			// Set the currently selected answer for this question
			selectedAnswers[question] = answer;
			
			// Send a notification to say the question has been answered
			sendNotification(BBNotifications.QUESTION_ANSWERED, { question: question, delayedMarking: delayedMarking } );
		}
		
	}
	
}