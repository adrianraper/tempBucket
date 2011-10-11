package com.clarityenglish.bento.model {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.vo.content.model.Answer;
	import com.clarityenglish.bento.vo.content.model.Question;
	
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
		 * This maintains a map of the currently selected answers
		 */
		private var firstSelectedAnswers:Dictionary;
		
		/**
		 * This maintains a map of the currently selected answers
		 */
		private var currentlySelectedAnswers:Dictionary;
		
		public function ExerciseProxy() {
			super(NAME);
			
			firstSelectedAnswers = new Dictionary(true);
			currentlySelectedAnswers = new Dictionary(true);
		}
		
		/**
		 * TODO: Need to figure out what to do for questions that have multiple answers (e.g. DragAndDrop3)
		 * Possibilities:
		 * 1. Map question to array
		 * 2. Composite pattern on answer (MultiAnswer)
		 * 
		 * @param question
		 * @param answer
		 */
		public function questionAnswer(question:Question, answer:Answer):void {
			log.debug("Answered question {0} - {1} [result: {2}, score: {3}]", question, answer, answer.result, answer.score);
			
			// If this is the first answer for the question record this seperately
			if (!firstSelectedAnswers[question]) firstSelectedAnswers[question] = answer;
			
			// Set the currently selected answer for this question
			currentlySelectedAnswers[question] = answer;
			
			// Send a notification to say the question has been answered
			sendNotification(BBNotifications.QUESTION_ANSWERED, { question: question, answer: answer } );
		}
		
	}
}